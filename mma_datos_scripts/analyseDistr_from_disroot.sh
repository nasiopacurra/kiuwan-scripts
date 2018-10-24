#!/bin/bash 
# $1 -> fichero .INFO de analisis Distribuido
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $FILELOG
 echo $1
}
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas
# Directorio de Binarios Analizadores de Kiuwan
PATHBIN=/mma/datos/Analizadores
# Directorio Temporal de descargas GIT/SVN para descarga 
DIRTEMP=/mma/temp
#Directorio de Backup si ha ido todo bien
DIRBACK=/mma/datos/disbackup

FILELOG=/mma/logs/kiuwanMutua.log
PROC=$0

export _JAVA_OPTIONS=-Duser.home=/mma/temp

log "=========================================="
log " pid = $$ Proceso = $PROC "                                                 
log "==Parametros de Entrada==================="
log " (1)fichero INFO = $1 "
log "=========================================="
if [ -f ${PATHBIN}/Distribuido/temp/analysis.lock ]
then
	log "Existe fichero analysis.lock en Analizador"
	ls -la ${PATHBIN}/Distribuido/temp/analysis.lock
	exit 2
fi

if [ $# -eq 2 ] 
then
	USERKW=$2
	# STTY_SAVE=`stty -g`
	# stty -echo
	# echo -n "Introduzca password [${USERKW}]: "
	# read PASSKW
	# stty ${STTY_SAVE}
	PASSKW=xxxxxxxxxxxxxxxxx
fi
URL=""
RAMA=""
REPO=""
VERS=""
APPL=""
CODT=""
USER=""
FILEINFO=$1
if [ -r "$FILEINFO" ]; then
	# Cargamos el fichero como si fueran variables
	. $FILEINFO
	
	log " URL  = [${URL}]"
	log " RAMA = [${RAMA}]"
	log " REPO = [${REPO}]"
	log " VERS = [${VERS}]"
	log " APPL = [${APPL}]"
	log " CODT = [${CODT}]"
	log " USER = [${USER}]"
	cd /mma/datos/scripts
	if [ ${#USER} -eq 7 ]; then 
		USER_EMAIL=`./obtenerEmail.php ${USER}`
	else
		USER_EMAIL=${USER}
	fi
	DOMINIO=`echo ${USER_EMAIL} | awk -F "@" '{ print $2 }'`
	if [ "x${DOMINIO}" != "x" ]; then 
		PROVEEDOR=`cat proveedores.dic |grep "@${DOMINIO}" | awk '{print $2}'`
		if [ "x${PROVEEDOR}" == "x" ]; then 
			PROVEEDOR="Proveedor_No_Encontrado_${DOMINIO}"
		fi
	else 
		PROVEEDOR="Sin_Proveedor"
	fi
	log " USER_EMAIL = [$USER_EMAIL]"
	log " DOMINIO .. = [$DOMINIO]"
	log " PROVEEDOR  = [$PROVEEDOR]"

	FECHA=`date "+%Y%m%d%H%M%S"`
	DIRKW=${DIRTEMP}/${APPL}_${FECHA}
	mkdir ${DIRKW}
	case ${REPO} in
        GIT)
			log "Realizando Checkout de GIT"
			URLGIT=`echo ${URL} | sed -e 's/http\:\/\//http\:\/\/testgit\:GITMutua01\@/g'` 
			git init ${DIRKW}
			git --version 
			PWDBCK=`pwd`
			cd ${DIRKW}
			git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*
			git config remote.origin.url ${URLGIT}
			git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
			git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*
			if  echo "${RAMA}" | grep -q -i "tags"; then
				git rev-parse ${VERS}
				REV=`git rev-parse ${VERS}`
			else
				git rev-parse refs/remotes/${RAMA}
				REV=`git rev-parse refs/remotes/${RAMA}`
			fi
			log "Revision obtenida para ${RAMA} : [$REV]"
			git config core.sparsecheckout
			git checkout -f ${REV}
			rm -fr ${DIRKW}/.git
			cd ${PWDBCK}
		;;
        SVN)
			log "Realizando Checkout de SVN"
			# si es un SNAPSHOT tenemos que tirar del trunk directamente
			if  echo "${VERS}" | grep -q -i "SNAPSHOT"; then
				log "Snapshot detectado [${URL}]"
				svn export --quiet --force --username testsvn --password SVNMutua01 --non-interactive ${URL} ${DIRKW}
				EXIT_S="$?"
			else # si es una release, debe de estar en un tag
				URLSVN=`echo ${URL} | sed -e 's/trunk/tags/g'` 
				log "Release detectada [${URLSVN}/${VERS}]"
				svn export --quiet --force --username testsvn --password SVNMutua01 --non-interactive ${URLSVN}/${VERS} ${DIRKW}
				EXIT_S="$?"
			fi 
			log "Terminacion SVN [${EXIT_S}]"
			if [ "${EXIT_S}" != "0" ]; then
				rm -fr ${DIRKW}
				exit ${EXIT_S}
			fi
		;;
	esac
	# Parametros del Agente Kiuwan
	# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
	# -s <pathDir>               --> ruta de los fuentes
	# -cr <changeRequest>        --> DESA -> nombre del miembro, PREP-> nombre del paquete EXPL -> NA
	# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria (EXPL no aplica porque no hay auditoria)
	# -crs <changeRequestStatus> --> DESA -> inprogress, PREP->resolved, EXPL -> Promote (Futuro)
	# -as <analisisScore>        --> DESA->partialDelivery, PREP-> partialDelivery, EXPL-> no aplica
	KWLABEL=${APPL}_${VERS}
	KWCR=${CODT}
	KWPROVIDER=${PROVEEDOR}
	KWMODEL=DeudaTecnicaMM
	if  echo "${VERS}" | grep -q -i "SNAPSHOT"; then
		PARMS="-m ${KWMODEL} -s ${DIRKW} -cr ${KWCR} -l ${KWLABEL} -crs inprogress .kiuwan.application.provider=${KWPROVIDER}"
	else
		PARMS="-m ${KWMODEL} -s ${DIRKW} -cr ${KWCR} -l ${KWLABEL} -crs resolved .kiuwan.application.provider=${KWPROVIDER}"
	fi
	cd $PATHBIN/Distribuido/bin
	if [ $# -eq 2 ]
	then
		# creando aplicacion si tenemos $USERKW
		log "Lanzando agente Kiuwan ($PATHBIN/Distribuido/bin) para CREAR la aplicacion ${APPL} desde -s ${DIRKW} con ${USERKW}"
		log "./agent.sh -c -n ${APPL} -s ${DIRKW}"
		./agent.sh -c -m ${KWMODEL} -n ${APPL} -s ${DIRKW} --user ${USERKW} --pass ${PASSKW}
		EXIT_C="$?"
		log "Codigo de Retorno: [$EXIT_C]"
		log "Esperando 1 min a conciliacion en www.kiuwan.es"
		sleep 1m
	fi
	log "Lanzando agente Kiuwan ($PATHBIN/Distribuido/bin) para la aplicacion ${APPL} con ${PARMS}"
	log "./agent.sh -n ${APPL} ${PARMS}"
	
	# sacar la URL del analisis y enviar por email al idwin
	FILEOUT=/tmp/analyse_temp_${FECHA}.log
	./agent.sh -m ${KWMODEL} -n $APPL $PARMS >> ${FILEOUT}
	EXIT_F="$?"
	log "Codigo de Retorno: [$EXIT_F]"
	# cambiamos permisos del directorio temporal del analizador
	DIRTEMP=`cat ${FILEOUT} | grep "Created dir:" |awk '{print$3}'`
	WHOAMI=`whoami`
	log "Cambiando permisos: [ ${DIRTEMP} ]"
	chmod -R 775 ${DIRTEMP}
	chown -R ${WHOAMI}:kiuwan ${DIRTEMP}
	
	if [ "$EXIT_F" != "0" ]; then
		TEXTO="[ERROR:$EXIT_F][srkmkiuwan][$FILEINFO]"
		cat ${FILEOUT} | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
	else
		sleep 1
		URLANA=`cat ${FILEOUT} | grep "Analysis results URL:" |awk '{print$4}'`
		log "Analysis results URL:[ $URLANA ]"
		rm -fr ${FILEOUT}
		
		if [ "x${DOMINIO}" != "x" ]; then 
			if [ ${PROVEEDOR:0:9} == "Proveedor" ]; then
				TEXTO="[ERROR] [srkmkiuwan] analyseDistr.sh $FILEINFO Sin Proveedor"
			else
				TEXTO="[srkmkiuwan] analyseDistr.sh $FILEINFO "
				# movemos el .INFO si ha ido todo bien
				log "Moviendo ${FILEINFO} a ${DIRBACK}"
				mv $FILEINFO ${DIRBACK}
			fi
		else
			TEXTO="[ERROR] [srkmkiuwan] analyseDistr.sh $FILEINFO Sin Dominio"
		fi
		CUERPO="File.INFO = [$FILEINFO]
URL ...... = [${URL}]
RAMA ..... = [${RAMA}]
REPO ..... = [${REPO}]
VERS ..... = [${VERS}]
APPL ..... = [${APPL}]
CODT ..... = [${CODT}]
USER ..... = [${USER}]
USER_EMAIL = [$USER_EMAIL]
DOMINIO .. = [$DOMINIO]
PROVEEDOR  = [$PROVEEDOR]
URL ...... = [$URLANA]"
		echo "$CUERPO" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
		# Registro para NEXT_baselines.csv
		echo "${URL};${REPO};${APPL}" >> /mma/datos/kiuwanSubsistemas/Distr_baselines/NEXT_baselines.csv

	fi	
	if [ "x${APPL}" != "x" ]; then
		if [ -d "${PATHANA}/Distr/${APPL}" ]; then 
			rm -fr ${PATHANA}/Distr/${APPL}
		fi 
		cp -R ${DIRKW} ${PATHANA}/Distr/${APPL}
		chmod -R 775 ${PATHANA}/Distr/${APPL}
		chown -R ${WHOAMI}:kiuwan ${PATHANA}/Distr/${APPL}
	fi
	# Borramos el directorio temporal del analisis 
	#rm -fr ${DIRKW}
fi
 
exit 0 
