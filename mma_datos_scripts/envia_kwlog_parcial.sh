#!/bin/bash

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

# envia_kwlog /mma/logs taskSpooler.log.2018-10-19
# envia_kwlog /mma/logs taskSpooler.log.2018-10-20
# envia_kwlog /mma/logs taskSpooler.log.2018-10-21

envia_kwlog /mma/logs kiuwanMutua.log.2018-10-19
envia_kwlog /mma/logs kiuwanMutua.log.2018-10-20
envia_kwlog /mma/logs kiuwanMutua.log.2018-10-21
