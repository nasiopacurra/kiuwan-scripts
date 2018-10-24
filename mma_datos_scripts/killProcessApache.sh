#!/bin/bash
if [ -F salida.out ]; then 
	rm salida.out
fi 
wget -O salida.out http://srkmkiuwan.mutua.es/wsKiuwan/killProcess.php
