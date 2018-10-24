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

# Busco el $2.$3 en Directorio $1 y lo borro
log "Borrando $PATHANA/$1/DESA/*/$2.$3 ...."
find  $PATHANA/$1/ -name "$2.$3" -exec rm -fr {} \;
EXIT_F="$?"

# Chapuza ---- INICIO (chequeo de los datos enviados)
FECHABCK=`date "+%Y%m%d%H%M%S"`
TEXTO="[srkmkiuwan] delPgm $1_$2_$3_$FECHABCK"
echo "$TEXTO" | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es amateos@mutua.es
# Chapuza ---- FINAL

# Return code of shell script for mainframe error handling
log "Return code of shell script is:  0$EXIT_F"

