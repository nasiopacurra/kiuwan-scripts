#!/bin/bash 
#

function analizar {
    APP=$1
    PWDOLD=`pwd`
    cd /mma/datos/Analizadores/EXPL/bin
    echo "./agent.sh -c -m DeudaTecnicaMM -n ${APP} -s /mma/datos/ftproot/EXPL/${APP} --user ${USERKW} --pass ${PASSKW}"
    ./agent.sh -c -m DeudaTecnicaMM -n ${APP} -s /mma/datos/ftproot/EXPL/${APP} --user ${USERKW} --pass ${PASSKW}
    EXIT_C="$?"
    echo "Codigo de Retorno: [${EXIT_C}]"
    cd ${PWDOLD}
}


function borra_copia {

for source in `find /mma/datos/ftproot/EXPL |grep _FUENTES/`; do
	info=`echo ${source} | sed -e 's/_FUENTES/_METADATOS/g'`
	UOline=`cat ${info}`
	NOMBRE_PROGRAMA=`echo -e "${UOline:0:9}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	TIPO_PROGRAMA=`echo -e "${UOline:10:50}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	SUFIJO_UO=`echo -e "${UOline:100:8}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'`
	echo ${source} ${NOMBRE_PROGRAMA} ${TIPO_PROGRAMA} ${SUFIJO_UO}
	rm -fr /mma/datos/ftproot/EXPL/${SUFIJO_UO}/${NOMBRE_PROGRAMA}
	cp ${source} /mma/datos/ftproot/EXPL/${SUFIJO_UO}/${NOMBRE_PROGRAMA}.${TIPO_PROGRAMA}
done

}

USERKW=amateos@mutua.es
STTY_SAVE=`stty -g`
stty -echo
echo -n "Introduzca password [${USERKW}]: "
read PASSKW
stty ${STTY_SAVE}

export _JAVA_OPTIONS=-Duser.home=/mma/temp

analizar PT-DGT
analizar PT-ECON
analizar PT-GINI
analizar PT-UCTC

exit 0


