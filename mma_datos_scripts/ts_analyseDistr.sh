#!/bin/bash 
# $1 -> fichero .INFO de analisis Distribuido
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $FILELOG
 echo $1
}
function logbs { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $LOGBS
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
LOGBS=/mma/logs/Distr_Baselines.log
PROC=$0

export _JAVA_OPTIONS=-Duser.home=/mma/temp

log "=========================================="
log " pid = $$ Proceso = $PROC "                                                 
log "==Parametros de Entrada==================="
log " (1)fichero INFO = $1 "
log "=========================================="
URL=""
RAMA=""
REPO=""
VERS=""
APPL=""
CODT=""
USER=""
CHECK=""
TIPAN=""
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
	log " CHECK = [${CHECK}]"
	log " TIPAN = [${TIPAN}]"

	cd /mma/datos/scripts
	# Si nos pasan el idWin buscamos el email
	if [ ${#USER} -eq 7 ]; then 
		USER_EMAIL=`./obtenerEmail.php ${USER}`
	else
		USER_EMAIL=${USER}
	fi
	# Buscamos el proveedor en base al dominio del email
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

	# debemos de obtener la KWUO
	# tenemos agrupaciones.dic y buscamos APPL hasta el primer "-"
	UO=`echo ${APPL} | awk -F "-" '{ print $1 }'`
	if [ "x${UO}" != "x" ]; then 
		KWUO=`cat agrupaciones.dic | grep -v "#" | grep "${UO}," | awk -F "," '{print $3}'`
		if [ "x${KWUO}" == "x" ]; then 
			KWUO="UO_Kiuwan_No_Encontrada_${UO}"
		fi
	else 
		KWUO="Sin_UO Asignada"
	fi
	log " UO = [$UO]"
	log " UO Kiuwan  = [$KWUO]"
	
	# Descargamos el codigo a analizar
	FECHA=`date "+%Y%m%d%H%M%S"`
	DIRKW=${DIRTEMP}/${APPL}_${FECHA}
	mkdir ${DIRKW}
	case ${REPO} in
        GIT)
			log "Realizando Checkout de GIT"
			URLGIT=`echo ${URL} | sed -e 's/http\:\/\//http\:\/\/testgit\:xxxxxxxxxxxxxxxxx\@/g'` 
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
				svn export --quiet --force --username testsvn --password xxxxxxxxxxxxxxxxx --non-interactive ${URL} ${DIRKW}
				EXIT_S="$?"
			else # si es una release, debe de estar en un tag
				URLSVN=`echo ${URL} | sed -e 's/trunk/tags/g'` 
				log "Release detectada [${URLSVN}/${VERS}]"
				svn export --quiet --force --username testsvn --password xxxxxxxxxxxxxxx --non-interactive ${URLSVN}/${VERS} ${DIRKW}
				EXIT_S="$?"
			fi 
			log "Terminacion SVN [${EXIT_S}]"
		;;
	esac
	
	
	# Parametros del Agente Kiuwan
	# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
	# -s <pathDir>               --> ruta de los fuentes
	# -cr <changeRequest>        --> para Distribuido es el Codigo de trabajo
	# -wr <waitresults>          --> Se espera a la auditoria
	# -crs <changeRequestStatus> --> inprogess o resolved 
	# -as <analisisScore>        --> para Distribuido siempre es completeDelivey
	# -m <model>                 --> modelo de analisis "DeudaTecnicaMM" o "CQM_Blocker"
	# -l <label>                 --> para Distribuido es <appl>_<version>
	# -promote-baseline          --> cuando crs=resolved hacemos promote
	# -pbl <promoteBaselineLabel>--> etiqueta para el promote <version>
	# .kiuwan.application.provider=${KWPROVIDER} --> Portfolio del Sistema
	# .kiuwan.application.portfolio.UO=${KWUO} --> Portfolio personalizado (busqueda en diccionario)
	# .kiuwan.application.portfolio.Arquitectura=${KWARQ} --> Portfolio personalizado (Distribuido|Mainframe|TransacSQL)
	# .kiuwan.application.portfolio.TipoSoftware=${KWTPSW} --> Portfolio personalizado (AplicacionWeb|Libreria|TransacSQL|<elementosHost>
	KWLABEL=${APPL}_${VERS}
	KWCR=${CODT}
	KWPROVIDER=${PROVEEDOR}
	KWMODEL=DeudaTecnicaMM
	if  echo "${VERS}" | grep -q -i "SNAPSHOT"; then
		PARMS="-m ${KWMODEL} -s ${DIRKW} -cr ${KWCR} -l ${KWLABEL} -crs inprogress .kiuwan.application.provider=${KWPROVIDER} .kiuwan.application.portfolio.UO=${KWUO}"
	else
		PARMS="-m ${KWMODEL} -s ${DIRKW} -cr ${KWCR} -l ${KWLABEL} -crs resolved .kiuwan.application.provider=${KWPROVIDER} .kiuwan.application.portfolio.UO=${KWUO}"
	fi
	cd $PATHBIN/Distribuido/bin
	log "Lanzando agente Kiuwan ($PATHBIN/Distribuido/bin) para la aplicacion $APPL con $PARMS"
	log "./agent.sh -n $APPL $PARMS"
	
	# sacar la URL del analisis y enviar por email al idwin
	FILEOUT=/tmp/analyse_temp_${FECHA}.log
	./agent.sh -n $APPL $PARMS > ${FILEOUT}
	EXIT_F="$?"
	log "Codigo de Retorno: [$EXIT_F] A"
	# Comprobamos el returncode=24 Application not found
	if [ "$EXIT_F" == "24" ]; then
		USERKW=amateos@mutua.es
		PASSKW=xxxxxxxxxxxxxxxxxxx
		log "Lanzando agente Kiuwan ($PATHBIN/Distribuido/bin) para creacion de la aplicacion $APPL"
		log "./agent.sh -c -n ${APPL} -s ${DIRKW}"
		./agent.sh -c -n ${APPL} -m ${KWMODEL} -s ${DIRKW} --user ${USERKW} --pass ${PASSKW} > ${FILEOUT}
		EXIT_F="$?"
		log "ReturnCode de Creacion: [$EXIT_F] B"
		# ./agent.sh -n $APPL $PARMS > ${FILEOUT}
		# EXIT_F="$?"
		# log "Codigo de Retorno: [$EXIT_F] C"
	fi
	
	
	# cambiamos permisos del directorio temporal del analizador
	DIRTEMP=`cat ${FILEOUT} | grep "Created dir:" |awk '{ print $3 }'`
	WHOAMI=`whoami`
	log "Cambiando permisos: [ ${DIRTEMP} ]"
	chmod -R 775 ${DIRTEMP}
	chown -R ${WHOAMI}:kiuwan ${DIRTEMP}
	
	
	if [ "$EXIT_F" != "0" ]; then
		TEXTO="[ERROR:$EXIT_F][srkmkiuwan][$FILEINFO]"
		cat ${FILEOUT} | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
	else
		sleep 1
		URLANA=`cat ${FILEOUT} | grep "Analysis results URL:" |awk '{ print $4 }'`
		log "Analysis results URL:[ $URLANA ]"
		rm -fr ${FILEOUT}
		
		if [ "x${DOMINIO}" != "x" ]; then 
			if [ "x${PROVEEDOR:0:9}" == "xProveedor" ]; then
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
UO ....... = [${UO}]
UO Kiuwan. = [${KWUO}]
URL  ..... = [$URLANA]"
		echo "$CUERPO" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" -c ctoribio@mutua.es amateos@mutua.es
		echo "$CUERPO" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" -c robot01@mutua.es $USER_EMAIL
		# Registro para NEXT_baselines.csv
		echo "${URL};${REPO};${APPL}" >> /mma/datos/kiuwanSubsistemas/Distr_baselines/NEXT_baselines.csv
	fi	
	
	# mantenemos la ultima copia de la aplicacion 
	if [ "x${APPL}" != "x" ]; then
		if [ -d "${PATHANA}/Distr/${APPL}" ]; then 
			rm -fr ${PATHANA}/Distr/${APPL}
		fi 
		cp -R ${DIRKW} ${PATHANA}/Distr/${APPL}
		chmod -R 775 ${PATHANA}/Distr/${APPL}
		chown -R ${WHOAMI}:kiuwan ${PATHANA}/Distr/${APPL}
	fi
	
	# Borramos el directorio temporal de analisis
	rm -fr ${DIRKW}
fi
 
exit 0 
