#!/bin/bash
#
# Funcion de escritura en Log de Baseline
function logbs { 
 FECHA=`date "+%Y%m%d%H%M%S"`
 echo "[ $$ $PROC $FECHA ] $1 ">> $LOGBS
 echo $1
}
# Directorio de Analisis de Kiuwan
PATHANA=/mma/datos/kiuwanSubsistemas
# Directorio de Binarios Analizadores de Kiuwan
PATHBIN=/mma/datos/Analizadores
# Fichero de log de procesos baselines
LOGBS=/mma/logs/EXPL_Baselines.log
PROC=$0
export _JAVA_OPTIONS=-Duser.home=/mma/temp
FILEOUT=/tmp/analisisSemanal.txt

logbs "=Comienzo Proceso Analisis Semanal========"
logbs " pid = $$ Proceso = $PROC "
logbs "=========================================="

TEXTOUT="[srkmkiuwan] $0 " 
echo $TEXTOUT > $FILEOUT
echo "==========================================" >> $FILEOUT
ls $PATHANA/EXPL_baselines|grep -v "\." >> $FILEOUT
echo "==========================================" >> $FILEOUT

logbs "Analizando directorio de semillas $PATHANA/EXPL_baselines ..." 
for f in `ls $PATHANA/EXPL_baselines|grep -v "\."`; do 

	logbs "Analizando $PATHANA/EXPL/$f .."
	cd $PATHBIN/EXPL/bin
	./agent.sh -m DeudaTecnicaMM -n $f -s $PATHANA/EXPL/$f
	EXIT_F="$?"
	logbs "Codigo de Retorno Analizador: [$EXIT_F]"
	if [ "$EXIT_F" != "0" ]
	then
		TEXTO="[ERROR:$EXIT_F][srkmkiuwan][ analisisSemanal $PATHANA/EXPL/$f ]"
		CUERPO=" ./agent.sh -n $f -s $PATHANA/EXPL/$f "
		echo "$CUERPO" | mailx -s "$TEXTO" -S smtp="relay.mutua.es:25" amateos@mutua.es
	else 
		logbs "Borrando semilla semanal $PATHANA/EXPL_baselines/$f .."
		rm -fr $PATHANA/EXPL_baselines/$f
	fi
done

logbs "=Final Proceso Analisis Semanal==========="

cat $LOGBS | grep "\[ $$ " >> $FILEOUT
cat $FILEOUT | mailx -s "$TEXTOUT" -S smtp="relay.mutua.es:25" -c cpuerto@mutua.es,ctoribio@mutua.es amateos@mutua.es
rm -fr $FILEOUT
exit 0
