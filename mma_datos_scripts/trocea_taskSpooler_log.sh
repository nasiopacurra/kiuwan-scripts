#!/bin/bash
#
function trocea {
    YYYY=${1:0:4}
    MM=${1:4:2}
    DD=${1:6:2}
    REGEXP="${YYYY}${MM}${DD}[0-9]\{6\}"
	ORIG=/mma/logs/taskSpooler.log.total
	FILE="/mma/logs/taskSpooler.log.${YYYY}-${MM}-${DD}"
	grep "${YYYY}${MM}${DD}[0-9]\{6\}" "${ORIG}" > ${FILE}
	cat ${ORIG} | grep "${YYYY}${MM}${DD}[0-9]\{6\}" > ${FILE}
	# cat /mma/logs/taskSpooler.log | grep "${REGEXP}" > ${FILE}
	chmod 755 ${FILE}
	numReg=`cat ${FILE} |wc -l`
	echo "Registros Filtrados: [${numReg}]"
}
trocea 20181019
exit 0
trocea 20180813
trocea 20180814
trocea 20180816
trocea 20180817
trocea 20180818
trocea 20180819
trocea 20180820
trocea 20180821
trocea 20180822
trocea 20180823
trocea 20180824
trocea 20180825
trocea 20180826
trocea 20180827
trocea 20180828
trocea 20180829
trocea 20180830
trocea 20180831
trocea 20180902
trocea 20180903
trocea 20180904
trocea 20180905
trocea 20180906
trocea 20180907
trocea 20180909
trocea 20180910
trocea 20180911
trocea 20180912
trocea 20180913
trocea 20180914
trocea 20180917
trocea 20180918
trocea 20180919
trocea 20180920
trocea 20180921
trocea 20180924
trocea 20180925
trocea 20180926
trocea 20180927
trocea 20180928
trocea 20180929
trocea 20181001
trocea 20181002
trocea 20181003
trocea 20181004
trocea 20181005
trocea 20181007
trocea 20181008
trocea 20181009
trocea 20181010
trocea 20181011
trocea 20181012
trocea 20181013
trocea 20181015
trocea 20181016
trocea 20181017
trocea 20181018

