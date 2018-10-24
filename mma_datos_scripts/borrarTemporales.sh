#!/bin/bash

function borramiento {
	echo "==========================================" >> $FILEOUT
	echo " Borrando ficheros en $1/$2" >> $FILEOUT
	ls -la $1/$2 | grep -v agent | grep $1 >> $FILEOUT
	rm -fr $1/$2
	echo " Ficheros $1/$2 Borrados" >> $FILEOUT
	ls -la $1/$2 | grep -v agent | grep $1 >> $FILEOUT
}

FECHA=`date "+%Y%m%d%H%M%S"`
FILEOUT=/tmp/borrarTemporales.txt
TEXTO="[srkmkiuwan] $$ $0 $FECHA"
echo "==========================================" > $FILEOUT
echo $TEXTO >> $FILEOUT
# Borrado MIME en temporal
borramiento /tmp MIME*.tmp
# Borrador de Temporales de Analizadores
borramiento /mma/datos/Analizadores/DESA/temp *_*.*
borramiento /mma/datos/Analizadores/PREP/temp *_*.*
borramiento /mma/datos/Analizadores/EXPL/temp *_*.*
borramiento /mma/datos/Analizadores/Distribuido/temp *-*.*

cat $FILEOUT | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es

rm -fr $FILEOUT

exit 0
