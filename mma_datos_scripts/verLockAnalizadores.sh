#!/usr/bin/bash

function listaLock {
	echo "Archivos de lock en [$1]:"
	ls -la /mma/datos/Analizadores/$1/temp |grep lock
}

function listaFtproot {
	echo "Archivos de FtpRoot de [$1]:"
	ls -la /mma/datos/ftproot/$1/ | grep "_" 

}

listaLock DESA
listaLock PREP
listaLock EXPL
listaLock Distribuido

listaFtproot DESA
listaFtproot PREP
listaFtproot EXPL

exit 0
