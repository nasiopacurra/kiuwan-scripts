#!/bin/bash
#
function logbs { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $0 $FECHA ] $1 ">> $LOGBS
 echo $1
}
shopt -s nullglob
FECHA=`date "+%Y%m%d%H%M%S"`

## =========================================================
## Proceso de Carga de Directorio desde zip
## =========================================================
DIRTSQL=/mma/datos/kiuwanSubsistemas/TransacSQL
DIRHOME=`pwd`

FECHA=`date "+%Y%m%d" --date="-1 day"`
#FECHA="20180630"

FILEFTP=/mma/datos/ftproot/TransacSQL/gen-bi-kiuwan-${FECHA}.zip
DIRIN=${DIRTSQL}/D${FECHA}_Baseline

# -------------------------------------------------------
# workaround para repetir
if [ -d ${DIRIN} ]; then 
	echo "Borrando ${DIRIN}"
	rm -fr ${DIRIN}
fi
# -------------------------------------------------------

if [ -f ${FILEFTP} ]; then 
	if [ ! -d ${DIRIN} ]; then
		echo "No Existe Directorio y Existe Archivo: Tengo que actuar"
		cd ${DIRTSQL}
		echo "Desempaquetando ${FILEFTP}"
		unzip -qq ${FILEFTP}
		if [ -d  ${DIRTSQL}/${FECHA} ]; then 
			echo "Renombrado ${DIRTSQL}/${FECHA} como ${DIRIN}"
			mv ${DIRTSQL}/${FECHA} ${DIRIN}
			echo "Cambiando permisos de ${DIRIN}"
			chmod -R 755 ${DIRIN}
			# cambiar el link de openGrok
			DIROG=/mma/datos/opengrok/src
			echo "Eliminado link de OpenGrok ${DIROG}/TransacSQL"
			rm -fr ${DIROG}/TransacSQL
			echo "Creando link de Opengrok contra ${DIRKW}/D${FECHA}_Baseline/"
			ln -s ${DIRIN}/ ${DIROG}/TransacSQL
		fi
	fi
fi

# Parametrizacion Variable
# Con subdirectorios = UO's
DIRANA=/mma/datos/Analizadores/Distribuido

# fichero de log para errores y procesos en paralelo
LOGBS=/mma/logs/TransacSQL_Baselines.log

# Parametrizacion Fija
DIRTMP=/tmp
TKCOLA=COLA_tsql
PFILE=${TKCOLA}_${FECHA}
# Obtenemos el numero de procesos en paralelo posibles segun las CPU existentes
PROC=`cat /proc/cpuinfo |grep cores|wc -l`
# forzamos procesos en paralelo
PROC=2
# Comprobamos si es un Padre
if [ $# == 0 ]; then
	## =========================================================
	## Proceso Principal de generacion de paralelismo
	## =========================================================
	logbs "== INICIO - Proceso: $0 (padre)"
	logbs "Paralelismo: [${PROC}]"
	CNT=0
	rm -fr ${DIRTMP}/${TKCOLA}_*.cola
	for u in `ls ${DIRIN} |grep -v "\."`; do
		for d in `ls ${DIRIN}/${u} |grep -v "\."`; do
			CNT=$(( ${CNT}+1 ))
			echo ${u}/${d} >> ${DIRTMP}/${PFILE}_${CNT}.cola
			# Control de replica
			if [ "${PROC}" = "${CNT}" ]; then 
				CNT=0
			fi
		done
	done
	# Lanzamiento en Paralelo
	# nos posicionamos en el mismo directorio donde lanzamos
	cd $DIRHOME
	# ejecutamos un hilo pasando un archivo-tmp con datos
	for i in `seq 1 $PROC`; do
		FILE=${DIRTMP}/${PFILE}_${i}.cola
		logbs "Lanzamos [$0 ${FILE}]"
		sleep 5
		$0 $FILE &
	done
	logbs "== FINAL - Proceso: $0 (padre)"
else
	## =========================================================
	## Proceso Hijo
	## =========================================================
	logbs "== INICIO - Proceso: $0 (hijo) [$1]"
	FILE=$1
	logbs "Lectura de ${FILE}"
	nFich=`cat ${FILE} | wc -l`
	logbs " Fichero: [${FILE}] con [${nFich}] ficheros a analizar"
	
	# conserva el separador de campo
	oldIFS=$IFS   
	# nuevo separador de campo, el caracter fin de línea
	IFS=$'\n'     
	for kwUOAPP in $(cat ${FILE}); do
		kwUO=`echo ${kwUOAPP} | awk -F "/" '{ print $1 }'`
		kwAPP=`echo ${kwUOAPP} | awk -F "/" '{ print $2 }'`
		kwDIR=${DIRIN}/${kwUO}/${kwAPP}
		logbs "== ./agent.sh [${kwAPP}] en [${kwDIR}]"
		cd ${DIRANA}/bin
		./agent.sh -c -m DeudaTecnicaMM -n $kwAPP -s $kwDIR  --user amateos@mutua.es --pass xxxxxxxxxxxxxxxxxxxxxx
		EXIT_F="$?"
		if [ "$EXIT_F" != "0" ]; then
			logbs "== Codigo de Retorno: [$EXIT_F] ./agent.sh [${kwAPP}] en [${kwDIR}]"
		else 
			logbs "== Codigo de Retorno: [$EXIT_F]"
		fi
		# espera impuesta por limitacion de llamada a api.kiuwan.es de 1000 llamadas/hora
		logbs " Esperamos 10 seg para el siguiente analisis"
		sleep 10
	done
	# restablece el separador de campo predeterminado
	IFS=$old_IFS  

	logbs "== FINAL - Proceso: $0 (hijo) [$1]"
fi

exit 0
