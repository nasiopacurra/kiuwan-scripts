#!/bin/bash 
# $1 -> Entorno [DESA|PREP|EXPL]
# $2 -> nombre del miembro
# $3 -> tipo de miembro 
#
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $0 $FECHA ] $1 ">> $FILELOG
 echo $1
}
FILELOG=/mma/logs/taskSpooler.log
PROC=`echo $0 | sed -e 's/analyse.sh/ts_analyse.sh/g'`
log " Encolando pid = $$ Proceso = /mma/datos/scripts/${PROC} $1 $2 $3 "
/usr/local/bin/ts -S 8
/usr/local/bin/ts sh /mma/datos/scripts/${PROC} $1 $2 $3 
echo "Return code of shell script is:  00"