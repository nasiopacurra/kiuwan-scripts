#!/bin/bash
#
# Funcion de escritura en Log de Baseline
function logbs { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $LOGBS
 echo $1
}
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas
# Directorio de Binarios Analizadores de Kiuwan
PATHBIN=/mma/datos/Analizadores
# Fichero de log de procesos baselines
LOGBS=/mma/logs/Distr_Baselines.log
# Fichero de semillas para el analisis
FILENEXT=$PATHANA/Distr_baselines/NEXT_baselines.csv
FECANA=`date "+%Y%m%d"`
FILEANA=$PATHANA/Distr_baselines/D${FECANA}_baselines.csv
# Directorio Temporal de descargas GIT/SVN para descarga 
DIRTEMP=/mma/temp


PROC=$0
export _JAVA_OPTIONS=-Duser.home=/mma/temp
FILEOUT=/tmp/analisisSemanalDistr.txt

logbs "=Comienzo Proceso Analisis Semanal Distr=="
logbs " pid = $$ Proceso = $PROC "
logbs "=========================================="

TEXTOUT="[srkmkiuwan] $0 " 
echo $TEXTOUT > $FILEOUT
echo "==========================================" >> $FILEOUT
echo " Copiando [${FILENEXT}]" >> $FILEOUT
echo "       en [${FILEANA}]" >> $FILEOUT
sort ${FILENEXT} |uniq > ${FILEANA}
echo " Inicializando [${FILENEXT}]" >> $FILEOUT
echo "" > ${FILENEXT}
chmod 666 ${FILENEXT}
echo "==========================================" >> $FILEOUT
logbs "Leyendo fichero de semillas ${FILEANA} ..." 

# conserva el separador de campo
oldIFS=$IFS   
# nuevo separador de campo, el caracter fin de línea
IFS=$'\n'     
for kwLine in $(cat ${FILEANA}); do

	kwURL=`echo ${kwLine} | awk -F ";" '{ print $1 }'`
	kwREPO=`echo ${kwLine} | awk -F ";" '{ print $2 }'`
	kwAPPL=`echo ${kwLine} | awk -F ";" '{ print $3 }'`
	
	logbs "Analizando ${kwAPPL} en ${kwREPO} ${kwURL}"
	FECTEMP=`date "+%Y%m%d%H%M%S"`
	DIRKW=${DIRTEMP}/${kwAPPL}_${FECTEMP}
	logbs "Creando directorio temporal ${DIRKW} ..."
	mkdir ${DIRKW}
	case ${kwREPO} in
        GIT)
			logbs "Realizando Checkout de GIT"
			URLGIT=`echo ${kwURL} | sed -e 's/http\:\/\//http\:\/\/testgit\:GITMutua01\@/g'` 
			git init ${DIRKW}
			git --version 
			PWDBCK=`pwd`
			cd ${DIRKW}
			git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*
			git config remote.origin.url ${URLGIT}
			git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
			git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*
			
			RAMA=origin/master
			git rev-parse refs/remotes/${RAMA}
			REV=`git rev-parse refs/remotes/${RAMA}`
			logbs "Revision obtenida para ${RAMA} : [$REV]"
			git config core.sparsecheckout
			git checkout -f ${REV}
			rm -fr ${DIRKW}/.git
			cd ${PWDBCK}
		;;
        SVN)
			logbs "Realizando Checkout de SVN"
			svn export --quiet --force --username testsvn --password SVNMutua01 --non-interactive ${kwURL} ${DIRKW}
			EXIT_S="$?"
			logbs "Terminacion SVN [${EXIT_S}]"
		;;
	esac
	logbs "== ./agent.sh [${kwAPPL}] en [${DIRKW}]"
	cd ${PATHBIN}/Distribuido/bin
	./agent.sh -m DeudaTecnicaMM -n ${kwAPPL} -s ${DIRKW}
	EXIT_F="$?"
	if [ "$EXIT_F" != "0" ]; then
		logbs "== Codigo de Retorno: [$EXIT_F] ./agent.sh [${kwAPPL}] en [${DIRKW}]"
		# volvemos a dejar el repo como semilla
		# Registro para NEXT_baselines.csv
		echo "${kwURL};${kwREPO};${kwAPPL}" >> ${FILENEXT}
		TEXTO="[ERROR:$EXIT_F][srkmkiuwan][ analisisSemanalDistr [${kwAPPL}] en [${DIRKW}] ]"
		CUERPO=" ./agent.sh -n ${kwAPPL} -s ${DIRKW} "
		echo "$CUERPO" | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
	else 
		logbs "== Codigo de Retorno: [$EXIT_F]"
	fi
	if [ "x${kwAPPL}" != "x" ]; then
		if [ -d "${PATHANA}/Distr/${kwAPPL}" ]; then 
			rm -fr ${PATHANA}/Distr/${kwAPPL}
		fi 
		cp -R ${DIRKW} ${PATHANA}/Distr/${kwAPPL}
		chmod -R 775 ${PATHANA}/Distr/${kwAPPL}
		chown -R ${WHOAMI}:kiuwan ${PATHANA}/Distr/${kwAPPL}		
	fi
	
	# Borramos el directorio temporal de analisis
	logbs "Borrando directorio temporal ${DIRKW} ..."
	rm -fr ${DIRKW}
	sleep 10
done
# restablece el separador de campo predeterminado
IFS=$old_IFS  

logbs "=Final Proceso Analisis Semanal Distr====="

cat $LOGBS | grep "\[ $$ " >> $FILEOUT
##cat $FILEOUT | mailx -s "$TEXTOUT" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es,ctoribio@mutua.es amateos@mutua.es
cat $FILEOUT | mailx -s "$TEXTOUT" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es,ctoribio@mutua.es amateos@mutua.es
rm -fr $FILEOUT
exit 0
