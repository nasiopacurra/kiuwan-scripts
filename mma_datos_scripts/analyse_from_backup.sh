#!/bin/bash 
# $1 -> Entorno [DESA|PREP]
# $2 -> nombre del miembro
# $3 -> tipo de miembro 
# $4 -> Timestamp from backup
#
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $FILELOG
 echo $1
}
# Directorio de backup
PATHENT=/mma/datos/ftpbackup
# Directorio de Binarios Analizadores de Kiuwan
PATHBIN=/mma/datos/Analizadores

FILELOG=/mma/logs/kiuwanMutua.log
PROC=$0
export _JAVA_OPTIONS=-Duser.home=/mma/temp
log "=========================================="
log " pid = $$ Proceso = $PROC "                                                 
log "==Parametros de Entrada==================="
log " (1)entorno = $1 "
log " (2)miembro = $2 "
log " (3)tipo    = $3 "
log " (4)timestmp= $4 "
log "=========================================="
if [ $# -eq 5 ] 
then
	USERKW=$5
	STTY_SAVE=`stty -g`
	stty -echo
	echo -n "Introduzca password [${USERKW}]: "
	read PASSKW
	stty ${STTY_SAVE}
fi

# Analisis del archivo *.INFO de donde obtener la $UO
UO="SIN-CATALOGAR"
UOfile=$PATHENT/$1_$2_$3_$4/$2_$3/$2.INFO
if [ -r "$UOfile" ]
then 
	UOline=`cat $UOfile`
	log "[$UOline]"
	NOMBRE_PROGRAMA=`echo -e "${UOline:0:9}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	TIPO_PROGRAMA=`echo -e "${UOline:10:50}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	VERSION_PROGRAMA=`echo -e "${UOline:62:5}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e 's/[[:space:]]/./g'`
	USER_TSO=`echo -e "${UOline:69:8}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	USER_WIN=`echo -e "${UOline:79:7}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	CCID=`echo -e "${UOline:88:8}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	SUFIJO_UO=`echo -e "${UOline:98:8}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	NOMBRE_UO_ELEMXUO=`echo -e "${UOline:108:70}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -e 's/[[:space:]]/-/g'`
	USER_EMAIL=`./obtenerEmail.php ${USER_WIN}`
	DOMINIO=`echo ${USER_EMAIL} | awk -F "@" '{ print $2 }'`
	PROVEEDOR=`cat proveedores.dic |grep "@${DOMINIO}" | awk '{print $2}'`
	
	log " NOMBRE_PROGRAMA . = [$NOMBRE_PROGRAMA]"
	log " TIPO_PROGRAMA ... = [$TIPO_PROGRAMA]"
	log " VERSION_PROGRAMA  = [$VERSION_PROGRAMA]"
	log " USER_TSO ........ = [$USER_TSO]"
	log " USER_WIN ........ = [$USER_WIN]"
	log " USER_EMAIL ...... = [$USER_EMAIL]"
	log " CCID ............ = [$CCID]"
	log " SUFIJO_UO ....... = [$SUFIJO_UO]"
	log " NOMBRE_UO_ELEMXUO = [$NOMBRE_UO_ELEMXUO]"
	log " DOMINIO ......... = [$DOMINIO]"
	log " PROVEEDOR ....... = [$PROVEEDOR]"
	UO=$NOMBRE_UO_ELEMXUO
		
	# quitamos los acentos
	UO=`echo -e "${UO}" | sed -e 's/\xd0/A/g' | sed -e 's/\xd1/E/g' | sed -e 's/\xd2/I/g' | sed -e 's/\xd3/O/g' | sed -e 's/\xd4/U/g'`
	log " UO registrado = [$UO]"
else 
	log " Fichero [$UOfile] no existe o no tiene permisos de Lectura"
fi
APP=$UO\_$3

FECHABCK=`date "+%Y%m%d%H%M%S"`

# Parametros del Agente Kiuwan
# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
# -s <pathDir>               --> ruta de los fuentes
# -cr <changeRequest>        --> DESA -> nombre del miembro, PREP-> nombre del paquete EXPL -> NA
# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria (EXPL no aplica porque no hay auditoria)
# -crs <changeRequestStatus> --> DESA -> inprogress, PREP->resolved, EXPL -> Promote (Futuro)
# -as <analisisScore>        --> DESA->partialDelivery, PREP-> partialDelivery, EXPL-> no aplica
KWLABEL=${NOMBRE_PROGRAMA}_${TIPO_PROGRAMA}_${VERSION_PROGRAMA}
KWCR=${CCID}
KWPROVIDER=${PROVEEDOR}
KWMODEL=DeudaTecnicaMM
case $1 in
        DESA)
			PARMS="-m ${KWMODEL} -s $PATHENT/$1_$2_$3_$4/$2_$3 -cr $KWCR -l $KWLABEL -crs inprogress -as partialDelivery .kiuwan.application.provider=$KWPROVIDER"
		;;
        PREP)
			PARMS="-m ${KWMODEL} -s $PATHENT/$1_$2_$3_$4/$2_$3 -cr $KWCR -l $KWLABEL -crs resolved -as partialDelivery .kiuwan.application.provider=$KWPROVIDER"
		;;
        EXPL)
			PARMS=""
		;;
esac

cd $PATHBIN/$1/bin
if [ $# -eq 5 ]
then
	# creando aplicacion si tenemos $USERKW
	log "Lanzando agente Kiuwan ($PATHBIN/$1/bin) para CREAR la aplicacion $APP desde $PATHENT/$1_$2_$3_$4/$2_$3 con ${USERKW}"
	log "./agent.sh -c -n $APP -s $PATHENT/$1_$2_$3_$4/$2_$3 --user ${USERKW} --pass ${PASSKW}"
	./agent.sh -c -m ${KWMODEL} -n $APP -s $PATHENT/$1_$2_$3_$4/$2_$3 --user ${USERKW} --pass ${PASSKW}
	EXIT_C="$?"
	log "Codigo de Retorno: [$EXIT_C]"
	log "Esperando 2 min a conciliacion en www.kiuwan.es"
	sleep 2m
fi
log "Lanzando agente Kiuwan ($PATHBIN/$1/bin) para la aplicacion $APP con $PARMS"
log "./agent.sh -n $APP $PARMS"

FILEOUT=/tmp/analyse_temp_${FECHABCK}.log
./agent.sh -m ${KWMODEL} -n $APP $PARMS >> ${FILEOUT}
EXIT_F="$?"
log "Codigo de Retorno: [$EXIT_F]"
if [ "$EXIT_F" != "0" ]
then
	TEXTO="[ERROR:$EXIT_F][srkmkiuwan][$1_$2_$3_$4]"
	cat ${FILEOUT} | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
	# Return code of shell script for mainframe error handling
	log "Return code of shell script is:  0${EXIT_F:0:1}"
	exit ${EXIT_F}
fi 

sleep 1
URL=`cat ${FILEOUT} | grep "Analysis results URL:" |awk '{print$4}'`
log "Analysis results URL:[ $URL ]"
rm -fr ${FILEOUT}

TEXTO="[srkmkiuwan] analyse.sh $1_$2_$3_$4 con $UO"
CUERPO="NOMBRE_PROGRAMA . = [$NOMBRE_PROGRAMA]
TIPO_PROGRAMA ... = [$TIPO_PROGRAMA]
VERSION_PROGRAMA  = [$VERSION_PROGRAMA]
USER_TSO ........ = [$USER_TSO]
USER_WIN ........ = [$USER_WIN]
USER_EMAIL ...... = [$USER_EMAIL]
CCID ............ = [$CCID]
SUFIJO_UO ....... = [$SUFIJO_UO]
NOMBRE_UO_ELEMXUO = [$NOMBRE_UO_ELEMXUO]
DOMINIO ......... = [$DOMINIO]
PROVEEDOR ....... = [$PROVEEDOR]
APLICACION Kiuwan = [$APP]
URL ANALISIS .... = [$URL]"
echo "$CUERPO" | /usr/bin/tr -cd '\11\12\15\40-\176' | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es

# Return code of shell script for mainframe error handling
log "Return code of shell script is:  00"
exit 0

