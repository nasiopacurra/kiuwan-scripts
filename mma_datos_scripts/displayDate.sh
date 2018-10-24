#!/bin/bash
# Script Name : displayDate.sh
# Created By : Entechlog, Sep 2014
# Move system date and hostname to a variable
TODAY=$(date)
HOST=$(hostname)
# Display date\time and system name
echo '----------------------------------'
echo Date: $TODAY Host: $HOST
echo '----------------------------------'
echo "== Proceso: $0"

if [ $# != 2 ]; then
	echo "Es necesario introducir 2 parámetro: $0 <<subsistema> <paquete>"
	exit -1
fi
prmSubs=$1
prmIden=$2
#
# Directorio de entrega de paquetes
PATHENT=/mma/datos/ftproot
#
# Directorio temporal de backup
PATHBCK=/mma/datos/ftpbackup

FECHA=`date "+%Y%m%d%H%M%S"`

echo "==Parametros de Entrada==================="
echo " (1)prmSubs = $prmSubs "
echo " (2)prmIden = $prmIden "
echo "=========================================="
echo "= Fecha de ejecucion: $FECHA"
echo 
echo "= Copiando $prmIden a $FECHA@$prmIden"
echo
cp -r $PATHENT/$prmIden $PATHBCK/$FECHA@$prmIden
FIL1=/tmp/fichero1.out
if [ -f $FIL1 ]; then
	rm -fr $FIL1
fi
ls -la $PATHBCK/$FECHA@$prmIden | awk '{print $9}' | sed -e '1d' -e '2d' -e '3d' > $FIL1
NUMLIN=`wc -l $FIL1 | awk '{print $1}'`
echo [$FECHA] Objetos a analizar: [$NUMLIN]

while read A ; do
	NUMLIN=`wc -l $PATHBCK/$FECHA@$prmIden/$A | awk '{print $1}'`
	echo [$FECHA] $A lineas analizadas: [$NUMLIN]
done < $FIL1

rm -fr $FIL1
echo
echo "=========================================="
echo 

# Return code of shell script for mainframe error handling
echo 'Return code of shell script is: ' $?
