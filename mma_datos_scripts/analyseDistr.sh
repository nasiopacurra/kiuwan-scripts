#!/bin/bash 
# $1 -> fichero .INFO de analisis Distribuido
#
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $0 $FECHA ] $1 ">> $FILELOG
 echo $1
}
FILELOG=/mma/logs/taskSpooler.log
PROC=`echo $0 | sed -e 's/analyseDistr.sh/ts_analyseDistr.sh/g'`
log " Encolando pid = $$ Proceso = /mma/datos/scripts/${PROC} $1 "
/usr/local/bin/ts -S 8
/usr/local/bin/ts sh /mma/datos/scripts/${PROC} $1 
