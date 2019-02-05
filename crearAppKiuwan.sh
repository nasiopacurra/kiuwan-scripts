#!/bin/bash
#
function log {
    FECHA=`date "+%Y%m%d%H%M%S"`
    echo "[ $$ $PROC $FECHA ] $1 " 
}

KLAPATH=${KLA_HOME}
if [ ! -f "_kiuwan.properties" ]; then 
    ./kiuwan_properties.sh
fi 
# Cargamos usuario y password 
# USERKW=
# PASSKW=
. _kiuwan.properties

# Parametros del Agente Kiuwan
# -n <subsistema>            --> tiene que estar dado de alta en Kiuwan
# -s <pathDir>               --> ruta de los fuentes
# -cr <changeRequest>        --> Codigo de trabajo
# -l <label>                 --> Etiqueta del analisis (Aplicacion + Version)
# -wr <waitresults>          --> (para que te devuelva el codigo de retorno, espera resultados auditoria
# -crs <changeRequestStatus> --> Snapshot -> inprogress, Release->resolved
PWD=$(pwd)
DIRAPPL_HELLO=${PWD}/helloWorld

DIRAPPL=${PWD}/helloWorld
APPL=appcalidad-scs-pruebaAMS
VERS=0.0.0

KWUO=Calidad_y_Testing
KWLABEL=${APPL}_${VERS}
KWCR=99999
KWPROVIDER=MMA
KWMODEL=CQM_Blocker
KWAUDIT=AuditoriaCtoDesarrollo
KWARQ=Distribuido
# comprobamos que contenga el string -lib- para ser Libreria
if [[ `echo ${APPL} | grep -i '\-lib\-'` ]]; then
    KWTIPOSW=Libreria
else
    KWTIPOSW=AplicacionWeb
fi
KWTIPAN="inprogress"

bExiste=`./EXIST_application_Kiuwan.php ${APPL}`
if [ "${bExiste}" == "false" ]; then 
    log "La aplicacion NO EXISTE: creamos la aplicacion en vacio"
    PARMS=""
    PARMS="${PARMS} -n ${APPL}"
    PARMS="${PARMS} -m ${KWMODEL}"
    PARMS="${PARMS} -s ${DIRAPPL_HELLO}"
    PARMS="${PARMS} -l ${KWLABEL}"
    PARMS="${PARMS} -wr"
    PARMS="${PARMS} --user ${USERKW}"
    PARMS="${PARMS} --pass ${PASSKW}"
    PARMS="${PARMS} .kiuwan.analysis.audit=${KWAUDIT}"
    PARMS="${PARMS} .kiuwan.application.provider=${KWPROVIDER}"
    PARMS="${PARMS} .kiuwan.application.portfolio.Arquitectura=${KWARQ}"
    PARMS="${PARMS} .kiuwan.application.portfolio.UO=${KWUO}"
    PARMS="${PARMS} .kiuwan.application.portfolio.TipoSoftware=${KWTIPOSW}"

    PWD_BACK=`pwd`
    cd ${KLAPATH}/bin
    log "Lanzando agente Kiuwan (${KLAPATH}/bin)"
    log "./agent.sh -c ${PARMS}"
    ./agent.sh -c ${PARMS} 
    EXIT_F="$?"
    log "Codigo de Retorno: [${EXIT_F}] "
    cd ${PWD_BACK}
fi

# Analisis inprogress 
PARMS=""
PARMS="${PARMS} -n ${APPL}"
PARMS="${PARMS} -m ${KWMODEL}"
PARMS="${PARMS} -s ${DIRAPPL}"
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
PWD_BACK=`pwd`
cd ${KLAPATH}/bin
log "Lanzando agente Kiuwan (${KLAPATH}/bin)"
log "./agent.sh ${PARMS}"
./agent.sh ${PARMS} 
EXIT_F="$?"
log "Codigo de Retorno: [${EXIT_F}] "
cd ${PWD_BACK}

# Analisis resolved --> --promote-baseline 
PARMS=""
PARMS="${PARMS} --promote-baseline"
PARMS="${PARMS} -n ${APPL}"
PARMS="${PARMS} -s ${DIRAPPL}"
PARMS="${PARMS} -l ${KWLABEL}"
PARMS="${PARMS} -cr ${VERS}"
PARMS="${PARMS} -pbl ${KWLABEL}"
PARMS="${PARMS} --user ${USERKW}"
PARMS="${PARMS} --pass ${PASSKW}"
PWD_BACK=`pwd`
cd ${KLAPATH}/bin
log "Lanzando agente Kiuwan (${KLAPATH}/bin)"
log "./agent.sh ${PARMS}"
./agent.sh ${PARMS} 
EXIT_F="$?"
log "Codigo de Retorno: [${EXIT_F}] "
cd ${PWD_BACK}
