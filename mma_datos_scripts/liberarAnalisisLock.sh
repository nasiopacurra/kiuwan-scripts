#!/bin/bash
if [ -f salida.out ]; then 
	rm salida.out
fi 
if [ -f /mma/datos/Analizadores/Distribuido/temp/analysis.lock ]; then
	ls -la /mma/datos/Analizadores/Distribuido/temp/analysis.lock
	wget -O salida.out http://srkmkiuwan.mutua.es/wsKiuwan/liberarLock.php
	ls -la /mma/datos/Analizadores/Distribuido/temp/analysis.lock
fi
