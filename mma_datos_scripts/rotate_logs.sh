#!/bin/bash


# $1 = Directorio
# $2 = fichero
#
function envia {
	FILE_CMDFTP=`mktemp`
	PWD_OLD=`pwd`
	cd ${1}
	ENTO=`echo ${1} | sed -e 's/\/mma\/datos\/Analizadores\///g' | sed -e 's/\/temp//g'` 
	# Transferencia SFTP a CL005041
	echo "Transferencia a CL005041. Comienza a las [`date`]"
	echo cd kiuwan_logs > ${FILE_CMDFTP}
	echo cd ${ENTO} >> ${FILE_CMDFTP}
	echo mput ${1}/${2}.gz >> ${FILE_CMDFTP}
	echo quit >> ${FILE_CMDFTP}
	cat ${FILE_CMDFTP} 
	sleep 2
	/mma/datos/scripts/sshpass -p 'PACPass' sftp -o BatchMode=no -o GlobalKnownHostsFile=/mma/datos/scripts/known_hosts_cl005041 -b ${FILE_CMDFTP} PACUser@cl005041.mutua.es
	EXIT_F="$?"
	sleep 2
	echo "Transferencia a CL005041. Codigo de retorno [${EXIT_F}]"
	rm ${FILE_CMDFTP}
	echo "Transferencia a CL005041. Terminada a las [`date`]"
	cd ${PWD_OLD}
}

function envia_kwlog {
	FILE_CMDFTP=`mktemp`
	PWD_OLD=`pwd`
	cd ${1}
	# Transferencia SFTP a CL005041
	echo "Transferencia a CL005041. Comienza a las [`date`]"
	echo cd kiuwan_logs > ${FILE_CMDFTP}
	echo mput ${2} >> ${FILE_CMDFTP}
	echo quit >> ${FILE_CMDFTP}
	cat ${FILE_CMDFTP} 
	sleep 2
	/mma/datos/scripts/sshpass -p 'PACPass' sftp -o BatchMode=no -o GlobalKnownHostsFile=/mma/datos/scripts/known_hosts_cl005041 -b ${FILE_CMDFTP} PACUser@cl005041.mutua.es
	EXIT_F="$?"
	sleep 2
	echo "Transferencia a CL005041. Codigo de retorno [${EXIT_F}]"
	rm ${FILE_CMDFTP}
	echo "Transferencia a CL005041. Terminada a las [`date`]"
	cd ${PWD_OLD}
}


# $1 directorio de logs
# $2 fichero log
# $3 Z = realizar gzip
function rotado { 
	#Variables
	FECHA=`date +%Y-%m-%d`
	ROTATETIME=`date +%Y-%m-%d:%H:%M:%S` 
 
	cd $1
	cp $2 $2.$FECHA
	echo "Rotado de $1/$2 a las $ROTATETIME" > $2
	chmod 775 $2
	if [ "$3" == "Z" ]
	then
		/bin/gzip -9 $2.$FECHA
		# find $1 -name "$2.*" -mtime +90 -exec rm -vf {} \;
		envia ${1} $2.$FECHA
	else 
		if [ "$1" == "/mma/logs" ]
		then
			envia_kwlog ${1} $2.$FECHA
		fi
	fi
}

#Rotado y compresion
rotado /mma/logs kiuwanMutua.log X
rotado /mma/logs taskSpooler.log X
rotado /mma/datos/Analizadores/DESA/temp agent.log Z
rotado /mma/datos/Analizadores/PREP/temp agent.log Z
rotado /mma/datos/Analizadores/EXPL/temp agent.log Z
rotado /mma/datos/Analizadores/Distribuido/temp agent.log Z
