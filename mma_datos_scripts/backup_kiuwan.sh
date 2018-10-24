#!/bin/bash
# 
# Scripts de realizacion de backup 
# 
# Parametrizacion del crontab
# 
# MINUTE HOUR DOM MONTH DOW
# MINUTE 	Minutes within the hour (0–59)
# HOUR 		The hour of the day (0–23)
# DOM 		The day of the month (1–31)
# MONTH 	The month (1–12)
# DOW 		The day of the week (0–7) where 0 and 7 are Sunday.
# 
# Diario: Lunes a Sabado a las 01:00
# 0 1 * * 1-6 /mma/datos/scripts/backup_kiuwan.sh Diario
# Semanal: Domingo a las 01:00
# 0 1 * * 0 /mma/datos/scripts/backup_kiuwan.sh Semanal
# Mensual: dia 1 del mes a las 04:00
# 0 4 1 * * /mma/datos/scripts/backup_kiuwan.sh Mensual

shopt -s nullglob
# Comprobamos el parametro de entrada
case ${1} in
#       Retencion de 2 semanas = 2 x 7 dias = 14 dias
        Diario)
                TYPE_BCK=+2
        ;;
#       Retencion de 8 semanas = 8 x 7 dias = 56 dias
        Semanal)
                TYPE_BCK=+13
        ;;
#       Retencion de 12 meses = 12 x 30 dias = 360 dias
        Mensual)
                TYPE_BCK=+59
        ;;
        *)
                echo "Usage: backup_kiuwan.sh Diario|Semanal|Mensual" >&2
                exit 2
        ;;
esac

TIMESTAMP=`date +%y-%m-%d-%H%M`
BACKUP_HOME=/mma/temp/backup
FILE_CMDFTP=/mma/temp/ftpdat.dat
FILE_LOGMAIL=/mma/temp/emaildat.dat
TOKEN=SoftwareKiuwan
ADMINMAIL="amateos@mutua.es"

# Borrado obsoletos
cd ${BACKUP_HOME}
echo "Borrando archivos obsoletos: ${1}_${TOKEN}_*.tar.gz"
find ${BACKUP_HOME}/${1}_${TOKEN}_*.tar.gz -mtime ${TYPE_BCK} -exec rm -f {} \;

# Comprobacion espacio
MAXPERCENT=85
PERCENT=`df -h ${BACKUP_HOME} | awk '{print $5}' | cut -d'%' -f 1 | sed -e '1d'`
if [[ ${PERCENT} -gt ${MAXPERCENT} ]]
then
	echo "Your hard disk ${BACKUP_HOME} is ${PERCENT} full" | mailx -s "srkmkiuwan: Disk checker warning" -S smtp="relay.mutua.es:25" ${ADMINMAIL}
	exit 1
fi


# Empieza la copia
echo "Realizando Copia del directorio de scripts"
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/ scripts
echo "Realizando Copia del directorio de html"
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/www/ wsKiuwan
echo "Realizando Copia del directorio de conf de Analizadores"
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/Analizadores/DESA/ conf
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/Analizadores/PREP/ conf
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/Analizadores/EXPL/ conf
tar upf ${1}_${TOKEN}_${TIMESTAMP}.tar -C /mma/datos/Analizadores/Distribuido/ conf


echo "Realizando Compresion de Backup"
gzip ${1}_${TOKEN}_${TIMESTAMP}.tar
if [ "$?" != "0" ]
then
	echo "[ERROR] Error tar.gz --------------- ABORTANDO";
	echo "[ERROR] Error realizando el gzip --- ABORTANDO" | mailx -s "srkmkiuwan: Disk checker warning" -S smtp="relay.mutua.es:25" ${ADMINMAIL}
	exit 2
fi
echo "Terminando de comprimir"

# Transferencia SFTP a CL005041
echo "Transferencia a CL005041. Comienza a las [`date`]"
echo "Transferencia a CL005041. Comienza a las [`date`]" > ${FILE_LOGMAIL}
echo cd ${1} > ${FILE_CMDFTP}
echo mput ${1}_${TOKEN}_${TIMESTAMP}.tar.gz >> ${FILE_CMDFTP}
echo quit >> ${FILE_CMDFTP}
/mma/datos/scripts/sshpass -p 'PACPass' sftp -o BatchMode=no -o GlobalKnownHostsFile=/mma/datos/scripts/known_hosts_cl005041 -b ${FILE_CMDFTP} PACUser@cl005041.mutua.es
EXIT_F="$?"
cat ${FILE_CMDFTP} >> ${FILE_LOGMAIL}
echo "Transferencia a CL005041. Codigo de retorno [${EXIT_F}]" >> ${FILE_LOGMAIL}
echo "Transferencia a CL005041. Codigo de retorno [${EXIT_F}]"
rm ${FILE_CMDFTP}
echo "Transferencia a CL005041. Terminada a las [`date`]"
echo "Transferencia a CL005041. Terminada a las [`date`]" >> ${FILE_LOGMAIL}
if [ ${EXIT_F} = 0 ]
then
    cat ${FILE_LOGMAIL} | mailx -s "srkmkiuwan - Backup $1 Kiuwan - Tranferencia a CL005041 [OK]" -S smtp="relay.mutua.es:25" ${ADMINMAIL}
else
    cat ${FILE_LOGMAIL} | mailx -s "srkmkiuwan - Backup $1 Kiuwan - ERROR en tranferencia a CL005041" -S smtp="relay.mutua.es:25" ${ADMINMAIL}
fi
rm ${FILE_LOGMAIL}

exit 0


