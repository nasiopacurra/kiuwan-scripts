#!/bin/bash
#
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas
for f in `ls $PATHANA/EXPL|grep -v "\."|grep -v COPYS|grep -v DB2`; do 
	touch $PATHANA/EXPL_baselines/$f
done
exit 0
