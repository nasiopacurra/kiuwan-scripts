#!/bin/bash 
# $1 -> fichero .INFO de analisis Distribuido
#
# ========================================================
# =============   F U N C I O N E S    ===================
# ========================================================
function log { 
	FECHA=`date "+%Y%m%d%H%M%S"`
	echo "[ $$ ${PROC} ${FECHA} ] ${1} " >> ${FILELOG}
	echo ${1}
}
# ========================================================
# Cargar las variables que vienen en fichero
# ========================================================
function f_CargaVars { 

	# Inicializamos variables
	URL=""
	RAMA=""
	REPO=""
	VERS=""
	APPL=""
	CODT=""
	USER=""
	CHECK=""
	TIPAN=""

	# Cargamos el fichero como si fueran variables
	. ${FILEINFO}

	# Visualizamos Variables
	log " URL  = [${URL}]"
	log " RAMA = [${RAMA}]"
	log " REPO = [${REPO}]"
	log " VERS = [${VERS}]"
	log " APPL = [${APPL}]"
	log " CODT = [${CODT}]"
	log " USER = [${USER}]"
	log " CHECK = [${CHECK}]"
	log " TIPAN = [${TIPAN}]"

	PWD_backup=`pwd`
	cd ${DIRSCRIPTS}
	# Cargamos usuario y password 
	# USERKW=
	# PASSKW=
	. ${DIRSCRIPTS}/_kiuwan.properties
	cd ${PWD_backup}
	
}

# ========================================================
# Obtenemos en email desde LDAP
# ========================================================
function f_ObtenerEmail {
		
	USER_EMAIL=""
	
	PWD_backup=`pwd`
	cd ${DIRSCRIPTS}
	# si bien un idWin buscamos su email
	if [ ${#USER} -eq 7 ]; then 
		USER_EMAIL=`./obtenerEmail.php ${USER}`
	else
		USER_EMAIL=${USER}
	fi
	cd ${PWD_backup}
	log " USER_EMAIL = [${USER_EMAIL}]"
}

# ========================================================
# Obtenemos el Proveedor desde el Dominio del USER_EMAIL 
# con proveedores.dic
# ========================================================
function f_ObtenerProveedor {

	DOMINIO=""
	PROVEEDOR=""
	PWD_backup=`pwd`
	cd ${DIRSCRIPTS}
	# Obtenemos el dominio para conocer al Proveedor
	DOMINIO=`echo ${USER_EMAIL} | awk -F "@" '{ print $2 }'`
	if [ "x${DOMINIO}" != "x" ]; then 
		PROVEEDOR=`cat proveedores.dic |grep "@${DOMINIO}" | awk '{print $2}'`
		if [ "x${PROVEEDOR}" == "x" ]; then 
			PROVEEDOR="Proveedor_No_Encontrado_${DOMINIO}"
		fi
	else 
		PROVEEDOR="Sin_Proveedor"
	fi
	cd ${PWD_backup}
	log " DOMINIO .. = [$DOMINIO]"
	log " PROVEEDOR  = [$PROVEEDOR]"

}


# ========================================================
# Obtenemos la UO desde APPL 
# con agrupaciones.dic
# ========================================================
function f_ObtenerUO {

	UO=""
	KWUO=""
	PWD_backup=`pwd`
	cd ${DIRSCRIPTS}
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
	cd ${PWD_backup}
	log " UO = [$UO]"
	log " UO Kiuwan  = [$KWUO]"

}

# ========================================================
# Obtenemos los fuentes en DIRKW desde ${APPL} ${URL} ${REPO} ${VERS} ${RAMA}
# ========================================================
function f_ObtenerFuentes {
	
	DIRKW=${DIRTEMP}/${APPL}_${FECHA}
	mkdir ${DIRKW}

	PWD_backup=`pwd`

	case ${REPO} in
        GIT)
			log "Realizando Checkout de GIT"
			URLGIT=`echo ${URL} | sed -e 's/http\:\/\//http\:\/\/testgit\:GITMutua01\@/g'` 
			git init ${DIRKW}
			git --version 
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
		;;
	esac
	
	cd ${PWD_backup}

}

# ========================================================
# Obtenemos el Tipo de Software desde ${APPL}
# ========================================================
function f_ObtenerTipoSw {

	TIPOSW=""
	PWD_backup=`pwd`
	# comprobamos que contenga el string -lib- para ser Libreria
	if [[ `echo ${APPL} | grep -i '-lib-'` ]] then;
		TIPOSW=Libreria
	else
		TIPOSW=AplicacionWeb
	fi
	cd ${PWD_backup}
	log " TIPOSW = [$TIPOSW]"

}

# ========================================================
# Enviar Correo con resultado correcto
# ========================================================
function f_enviarCorreo {

	ASUNTO="[srkmkiuwan] bloquerDistr.sh ${FILEINFO} "
	CUERPO="File.INFO = [${FILEINFO}]
URL ...... = [${URL}]
RAMA ..... = [${RAMA}]
REPO ..... = [${REPO}]
VERS ..... = [${VERS}]
APPL ..... = [${APPL}]
CODT ..... = [${CODT}]
USER ..... = [${USER}]
USER_EMAIL = [${USER_EMAIL}]
DOMINIO .. = [${DOMINIO}]
PROVEEDOR  = [${PROVEEDOR}]
UO ....... = [${UO}]
UO Kiuwan. = [${KWUO}]
URL  ..... = [${URLANA}]"
		echo "${CUERPO}" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "${ASUNTO}" -S smtp="relay.mutua.es:25" -c ctoribio@mutua.es amateos@mutua.es
		echo "${CUERPO}" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "${ASUNTO}" -S smtp="relay.mutua.es:25" -c robot01@mutua.es ${USER_EMAIL}

}


# ========================================================
# Movemos FILEINFO de disroot a disback
# ========================================================
function f_moverFileInfo {
	
	# movemos el .INFO si ha ido todo bien
	log "Moviendo ${FILEINFO} a ${DIRBACK}"
	mv ${FILEINFO} ${DIRBACK}
	
}


# ========================================================
# Copiar ${DIRKW} con los fuentes analizados a ${PATHANA}
# ========================================================
function f_copiarAppl {

	if [ "x${APPL}" != "x" ]; then
		if [ -d "${PATHANA}/${APPL}" ]; then 
	 		rm -fr ${PATHANA}/${APPL}
	 	fi 
	 	cp -R ${DIRKW} ${PATHANA}/${APPL}
	 	chmod -R 775 ${PATHANA}/${APPL}
		WHOAMI=`whoami`
	 	chown -R ${WHOAMI}:kiuwan ${PATHANA}/${APPL}
	fi

}

# ========================================================
# Cambiamos los permisos del ${DIRTEMP} 
# desde ${FILEOUT}
# ========================================================
function f_cambiarDirTemp {

	DIRTEMP=`cat ${FILEOUT} | grep "Created dir:" |awk '{ print $3 }'`
	log "Cambiando permisos: [ ${DIRTEMP} ]"
	chmod -R 775 ${DIRTEMP}
	WHOAMI=`whoami`
	chown -R ${WHOAMI}:kiuwan ${DIRTEMP}
}

# ========================================================
# Visualizamos todos los parametros de Kiuwan 
# ========================================================
function f_displayKiuwanParameters {

	# Parametros del Agente Kiuwan
	# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
	# -s <pathDir>               --> ruta de los fuentes
	# -cr <changeRequest>        --> Codigo de trabajo 
	# -l <label>				 --> Etiqueta del analisis (Aplicacion + Version)
	# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria 
	# -crs <changeRequestStatus> --> Snapshot -> inprogress, Release->resolved

	log " KWAPPL.... = [${APPL}]"
	log " KWCR...... = [${KWCR}]"
	log " KWCRS..... = [${KWCRS}]"
	log " KWTIPAN... = [${KWTIPAN}]"
	log " KWMODEL... = [${KWMODEL}]"
	log " KWLABEL... = [${KWLABEL}]"
	log " KWAUDIT... = [${KWAUDIT}]"
	log " KWPROVIDER = [${KWPROVIDER}]"
	log " KWARQ..... = [${KWARQ}]"
	log " KWUO...... = [${KWUO}]"
	log " KWTIPOSW.. = [${KWTIPOSW}]"

}

# ========================================================
# Creamos la aplicacion en vacio desde hellWorld
# ========================================================
function f_crearApplVacia {
	
	log "La aplicacion [${APPL}] NO EXISTE: Creamos la aplicacion en vacio."
	# Parametros del Agente Kiuwan
	# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
	# -m <model>
	# -s <pathDir>               --> ruta de los fuentes
	# -l <label>				 --> Etiqueta del analisis (Aplicacion + Version)
	# -cr <changeRequest>        --> Codigo de trabajo 
	# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria 
	# -crs <changeRequestStatus> --> Snapshot -> inprogress, Release->resolved
	PARMS=""
	PARMS="${PARMS} -n ${APPL}"
	PARMS="${PARMS} -m ${KWMODEL}"
	PARMS="${PARMS} -s ${DIRSCRIPTS}/helloWorld"
	PARMS="${PARMS} -l ${KWLABEL}"
	PARMS="${PARMS} -wr"
	PARMS="${PARMS} --user ${USERKW}"
	PARMS="${PARMS} --pass ${PASSKW}"
	PARMS="${PARMS} .kiuwan.analysis.audit=${KWAUDIT}"
	PARMS="${PARMS} .kiuwan.application.provider=${KWPROVIDER}"
	PARMS="${PARMS} .kiuwan.application.portfolio.Arquitectura=${KWARQ}"
	PARMS="${PARMS} .kiuwan.application.portfolio.UO=${KWUO}"
	PARMS="${PARMS} .kiuwan.application.portfolio.TipoSoftware=${KWTIPOSW}"
	
	PWD_backup=`pwd`
	cd ${KLAPATH}/bin
	log "Lanzando agente Kiuwan (${KLAPATH}/bin)"
	# ToDo Ofuscar user&pass para display
	log "./agent.sh -c ${PARMS}"
	./agent.sh -c ${PARMS} > ${FILEOUT}
	EXIT_F="$?"
	log "Codigo de Retorno: [${EXIT_F}] "
	cd ${PWD_backup}
}

# ========================================================
# Analizamos la aplicacion 
# ========================================================
function f_analizarAppl {

	log "Analizamos la aplicacion [${APPL}] en modo inprogress."
	# Parametros del Agente Kiuwan
	# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
	# -m <model>
	# -s <pathDir>               --> ruta de los fuentes
	# -l <label>				 --> Etiqueta del analisis (Aplicacion + Version)
	# -cr <changeRequest>        --> Codigo de trabajo 
	# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria 
	# -crs <changeRequestStatus> --> Snapshot -> inprogress, Release->resolved
	PARMS=""
	PARMS="${PARMS} -n ${APPL}"
	PARMS="${PARMS} -m ${KWMODEL}"
	PARMS="${PARMS} -s ${DIRKW}"
	PARMS="${PARMS} -l ${KWLABEL}"
	PARMS="${PARMS} -wr"
	PARMS="${PARMS} -cr ${KWCR}"
	PARMS="${PARMS} -crs inprogress"
	PARMS="${PARMS} --user ${USERKW}"
	PARMS="${PARMS} --pass ${PASSKW}"
	PARMS="${PARMS} .kiuwan.analysis.audit=${KWAUDIT}"
	PARMS="${PARMS} .kiuwan.application.provider=${KWPROVIDER}"
	PARMS="${PARMS} .kiuwan.application.portfolio.Arquitectura=${KWARQ}"
	PARMS="${PARMS} .kiuwan.application.portfolio.UO=${KWUO}"
	PARMS="${PARMS} .kiuwan.application.portfolio.TipoSoftware=${KWTIPOSW}"
	
	PWD_backup=`pwd`
	cd ${KLAPATH}/bin
	log "Lanzando agente Kiuwan (${KLAPATH}/bin)"
	# ToDo Ofuscar user&pass para display
	log "./agent.sh ${PARMS}"
	./agent.sh ${PARMS} > ${FILEOUT}
	EXIT_F="$?"
	log "Codigo de Retorno: [${EXIT_F}] "
	cd ${PWD_backup}

}


# ========================================================
# =============   P R I N C I P A L    ===================
# ========================================================

# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas/Distr
# Directorio de Binarios Analizadores de Kiuwan
KLAPATH=/mma/datos/Analizadores/Distribuido
# Directorio ubicacion de scripts 
DIRSCRIPTS=/mma/datos/scripts
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


FECHA=`date "+%Y%m%d%H%M%S"`

FILEINFO=$1
if [ -r "${FILEINFO}" ] && [ -f "${DIRSCRIPTS}/_kiuwan.properties" ]; then

	# Cargamos las variables
	f_CargaVars ${FILEINFO}
	# Obtenemos el email
	f_ObtenerEmail ${USER}
	# Obtenemos el dominio y el proveedor en base a email
	f_ObtenerProveedor ${USER_EMAIL}
	# Obtenemos la UO y UO de Kiuwan en base a la aplicacion
	f_ObtenerUO ${APPL}
	# Obtenemos el portfolio Tipo_Software en base a la aplicacion
	f_ObtenerTipoSw ${APPL}


	KWLABEL=${APPL}_${VERS}
	KWCR=${CODT}
	KWPROVIDER=${PROVEEDOR}
	KWMODEL=CQM_Blocker
	KWAUDIT=AuditoriaCtoDesarrollo
	KWARQ=Distribuido
	KWTIPOSW=${TIPOSW}
	# Parametros del Agente Kiuwan
	f_displayKiuwanParameters

	# obtenemos un directorio temporal con los fuentes a analizar
	f_ObtenerFuentes ${APPL} ${URL} ${REPO} ${VERS} ${RAMA}

	# Comprobamos si existe la aplicacion en Kiuwan
	PWD_backup=`pwd`
	cd ${DIRSCRIPTS}
	bExiste=`./EXIST_application_Kiuwan.php ${APPL}`
	cd ${PWD_backup}
	if [ "${bExiste}" == "false" ]; then 
		# creamos la aplicacion en base a helloWorld
		f_crearApplVacia 
	fi
	
	FILEOUT=/tmp/analyse_temp_${FECHA}.log
	# analizamos la aplicacion y retornamos EXIT_F
	f_analizarAppl

	# cambiamos permisos del directorio temporal del analizador
	f_cambiarDirTemp ${FILEOUT}

	# Quizas tenemos que enviar analisis con RC = 10 Audit overall fail
	# comprobamos el resultado del analisis
	if [ "${EXIT_F}" != "0" ]; then
		ASUNTO="[ERROR:${EXIT_F}][srkmkiuwan][${FILEINFO}]"
		cat ${FILEOUT} | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "${ASUNTO}" -S smtp="relay.mutua.es:25" amateos@mutua.es
	else
		# esperamos para obtener la URL del analisis
		sleep 1
		URLANA=`cat ${FILEOUT} | grep "Analysis results URL:" |awk '{ print $4 }'`
		log "Analysis results URL:[ ${URLANA} ]"
		rm -fr ${FILEOUT}
	
		# Enviamos por correo evidencia del analisis
		f_enviarCorreo
		# movemos el fichero INFO a backup
		f_moverFileInfo ${FILEINFO} ${DIRBACK}

		# Registro para NEXT_baselines.csv
		echo "${URL};${REPO};${APPL}" >> /mma/datos/kiuwanSubsistemas/Distr_baselines/NEXT_baselines.csv
	
	fi
	
	# Mantener la ultima copia de fuentes de la aplicacion
	f_copiarAppl ${APPL} ${DIRKW}

	# Borramos el directorio temporal de analisis
	rm -fr ${DIRKW}

fi

exit ${EXIT_F}
