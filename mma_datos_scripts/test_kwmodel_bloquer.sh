#!/bin/bash
#
USERKW=amateos@mutua.es
PASSKW=xxxxxxxxxxxxxxxxxxxx
DIRKW=/mma/datos/kiuwanSubsistemas/Distr/appactuarial-ms-tarificador/
APPL=integracion
APPLUO=Actuarial
VERS=1.0.0
KWLABEL=${APPL}_${VERS}
KWCR=appactuarial-ms-tarificador
KWPROVIDER=Profile
KWMODEL=CQM_Blocker
PARMS=""
#PARMS="${PARMS} -m ${KWMODEL} "
PARMS="${PARMS} -s ${DIRKW} "
PARMS="${PARMS} -wr "
PARMS="${PARMS} -cr ${KWCR} "
PARMS="${PARMS} -l ${KWLABEL} "
PARMS="${PARMS} -crs inprogress "
PARMS="${PARMS} --user ${USERKW} "
PARMS="${PARMS} --pass ${PASSKW} "
PARMS="${PARMS} ignore=clones "
PARMS="${PARMS} .kiuwan.application.provider=${KWPROVIDER} "
PARMS="${PARMS} .kiuwan.application.portfolio.UO=${APPLUO} "
PWD_OLD=`pwd`
cd /mma/datos/Analizadores/Distribuido/bin
# ./agent.sh -c -n $APPL -s ${DIRKW} --user ${USERKW} --pass ${PASSKW}
echo "./agent.sh -n $APPL $PARMS"
./agent.sh -n $APPL $PARMS
EXIT_F="$?"
echo "Codigo de Retorno: [$EXIT_F]"
cd ${PWD_OLD}


