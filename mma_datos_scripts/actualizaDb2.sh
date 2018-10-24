#!/bin/bash 
# $1 -> Entorno [DESA|PREP|EXPL]
# $2 -> Fecha [Faammdd]
#
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $FILELOG
 echo $1
}
# Directorio de entrega por FTP
PATHENT=/mma/datos/ftproot
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas

FILELOG=/mma/logs/kiuwanMutua.log
PROC=$0

log "=========================================="
log " pid = $$ Proceso = $PROC "
log "==Parametros de Entrada==================="
log " (1)entorno = $1 "
log " (2)fecha   = $2 "
log "=========================================="

log "Actualizando $PATHANA/$1/DB2 con $PATHENT/$1/DB2 ..."
cp $PATHENT/$1/DB2/DB2CATLG.$2 $PATHANA/$1/DB2/DB2CATLG.$2
EXIT_F1="$?"
cp $PATHENT/$1/DB2/DB2PLNTB.$2 $PATHANA/$1/DB2/DB2PLNTB.$2
EXIT_F2="$?"
if [ "${EXIT_F1}" == "0" ]; then
	log "Borrando $PATHENT/$1/DB2/DB2CATLG.$2 ...."
	rm -fr $PATHENT/$1/DB2/DB2CATLG.$2 
	log "Actualizando $PATHANA/$1/DB2CATLG.current a fecha $2..."
	rm -fr $PATHANA/$1/DB2/DB2CATLG.current
	ln -s $PATHANA/$1/DB2/DB2CATLG.$2 $PATHANA/$1/DB2/DB2CATLG.current
fi
if [ "${EXIT_F1}" == "0" ]; then
	log "Borrando $PATHENT/$1/DB2/DB2PLNTB.$2 ...."
	rm -fr $PATHENT/$1/DB2/DB2PLNTB.$2
	log "Actualizando $PATHANA/$1/DB2PLNTB.current a fecha $2..."
	rm -fr $PATHANA/$1/DB2/DB2PLNTB.current
	ln -s $PATHANA/$1/DB2/DB2PLNTB.$2 $PATHANA/$1/DB2/DB2PLNTB.current
fi

# Chapuza ---- INICIO (chequeo de los datos enviados)
FECHABCK=`date "+%Y%m%d%H%M%S"`
TEXTO="[srkmkiuwan] actualizaDb2 $1_$2_$FECHABCK"
echo "$TEXTO" | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es amateos@mutua.es
# Chapuza ---- FINAL

# Return code of shell script for mainframe error handling
log "Return code of shell script is:  ${EXIT_F1}${EXIT_F2}"

exit 0
