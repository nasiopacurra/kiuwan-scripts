#!/bin/bash 
# $1 -> Entorno [DESA|PREP|EXPL]
# $2 -> nombre del miembro
# $3 -> tipo de miembro 
#
#
function log { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $FILELOG
 echo $1
}
# Directorio de entrega por FTP
PATHENT=/mma/datos/ftproot
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas

FILELOG=/mma/logs/kiuwanMutua.log
PROC=$0

log "=========================================="
log " pid = $$ Proceso = $PROC "
log "==Parametros de Entrada==================="
log " (1)entorno = $1 "
log " (2)miembro = $2 "
log " (3)tipo    = $3 "
log "=========================================="

log "Actualizando $PATHANA/$1/COPYS con $PATHENT/$1/COPYS/$2.$3 ..."
cp $PATHENT/$1/COPYS/$2.$3 $PATHANA/$1/COPYS
EXIT_F="$?"
log "Borrando $PATHENT/$1/COPYS/$2.$3 ...."
rm -fr $PATHENT/$1/COPYS/$2.$3 
rm -fr $PATHENT/$1/COPYS/$2.INFO

# Chapuza ---- INICIO (chequeo de los datos enviados)
FECHABCK=`date "+%Y%m%d%H%M%S"`
TEXTO="[srkmkiuwan] addCopy $1_$2_$3_$FECHABCK"
echo "$TEXTO" | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es amateos@mutua.es
# Chapuza ---- FINAL

# Return code of shell script for mainframe error handling
log "Return code of shell script is:  0$EXIT_F"

