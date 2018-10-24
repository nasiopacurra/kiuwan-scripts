#!/bin/bash
#
echo "== Proceso: $0"

if [[ $# < 1 ]]; then
	echo "Parametro Incorrecto: $0 [sinDominio|Distribuido|Mainframe] [.yyyy-mm-dd] "
	exit -1
fi
echo "Parametro: $1 "

if [[ "$1" == "sinDominio" ]]; then
	echo " Relacion de Dominios"
	cat /mma/logs/kiuwanMutua.log$2 | grep DOMINIO | awk '{print $9}' | sort | uniq
	
	echo " Relacion de Dominios VACIOS"
	cat /mma/logs/kiuwanMutua.log$2 | grep DOMINIO | grep "\[\]"
	echo " Detalle de ejecuciones con Dominio VACIOS"
	for f in `cat /mma/logs/kiuwanMutua.log$2 | grep DOMINIO | grep "\[\]" | awk '{ print $2}'`; do 
		echo "==================================="
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f "
		echo "==================================="
		echo " "
	done
	exit 0
fi

if [[ "$1" == "Distribuido" ]]; then
	echo " Relacion de codigos de Retorno"
	cat /mma/logs/kiuwanMutua.log$2 | grep analyseDistr.sh | grep Retorno: | grep -v "\[0\]"
	echo " Detalle de ejecuciones con codigos de Retorno <> 0"
	for f in `cat /mma/logs/kiuwanMutua.log$2 | grep analyseDistr.sh | grep Retorno: | grep -v "\[0\]" | awk '{ print $2}'`; do 
		echo "==================================="
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f "
		echo "==================================="
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f " | grep "Sincronizando" | grep "ftpbackup"
		echo " "
	done
	exit 0
fi

if [[ "$1" == "Mainframe" ]]; then
	echo " Relacion de codigos de Retorno"
	cat /mma/logs/kiuwanMutua.log$2 | grep analyse.sh | grep Retorno: | grep -v "\[0\]"
	echo " Detalle de ejecuciones con codigos de Retorno <> 0"
	for f in `cat /mma/logs/kiuwanMutua.log$2 | grep analyse.sh | grep Retorno: | grep -v "\[0\]" | awk '{ print $2}'`; do 
		echo "==================================="
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f "
		echo "==================================="
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f " | grep "Sincronizando" | grep "ftpbackup"
		echo " "
	done
	
	echo " Resumen para recuperaciones"
	echo " ==========================="
	for f in `cat /mma/logs/kiuwanMutua.log$2 | grep analyse.sh | grep Retorno: | grep -v "\[0\]" | awk '{ print $2}'`; do 
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f " | grep "Sincronizando" | grep "ftpbackup"
	done
	
	echo " Comandos para recuperaciones"
	echo " ==========================="
	for f in `cat /mma/logs/kiuwanMutua.log$2 | grep analyse.sh | grep Retorno: | grep -v "\[0\]" | awk '{ print $2}'`; do 
		cat /mma/logs/kiuwanMutua.log$2 | grep "\[ $f " | grep "Sincronizando" | grep "ftpbackup" | awk '{print $9}' | sed -e 's/_/ /g' | sed -e 's/\/mma\/datos\/ftpbackup\//\.\/analyse_from_backup\.sh /g'
	done
	exit 0
fi