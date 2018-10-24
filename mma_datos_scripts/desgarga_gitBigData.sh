#!/usr/bin/bash
#
function descargaGit {

    APPL=`echo ${DIRGIT} | sed -e 's/http\:\/\/srkmcontdelivery\.mutua\.es\///g' |sed -e 's/\//##/g'`
	
	echo "Creando: [${DIROUT}/${APPL}]"
	if [ -d "${DIROUT}/${APPL}" ]; then
		rm -fr ${DIROUT}/${APPL}
	else 
		mkdir ${DIROUT}/${APPL}
	fi	
	URLGIT=`echo "${DIRGIT}.git" | sed -e 's/http\:\/\//http\:\/\/testgit\:GITMutua01\@/g'` 
    echo ${URLGIT}
	git init ${DIROUT}/${APPL}
	git --version 
	PWDBCK=`pwd`
	cd ${DIROUT}/${APPL}
	git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*
	git config remote.origin.url ${URLGIT}
	git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
	git fetch --tags --progress ${URLGIT} +refs/heads/*:refs/remotes/origin/*

	RAMA=origin/master
	RAMA=origin/develop
	if [ -f .git/refs/remotes/origin/master ]
	then
		REV=`git rev-parse refs/remotes/origin/master`
		echo "existe origin/master [${REV}]"
	else 
		if [ -f .git/refs/remotes/origin/develop ]
		then
			REV=`git rev-parse refs/remotes/origin/develop`
			echo "existe origin/develop [${REV}]"
		fi
	fi
	git config core.sparsecheckout
	git checkout -f ${REV}
	# rm -fr ${DIROUT}/${APPL}/.git
	cd ${PWDBCK}
}

DIROUT=/mma/temp/gitStratio
USER=testgit
PASS=GITMutua01

 DIRGIT=http://srkmcontdelivery.mutua.es/diganalytics/bigdata-general
 descargaGit ${DIRGIT}
 DIRGIT=http://srkmcontdelivery.mutua.es/diganalytics/bigdata-spark
 descargaGit ${DIRGIT}
 DIRGIT=http://srkmcontdelivery.mutua.es/diganalytics/bigdata-ingestion
 descargaGit ${DIRGIT}
 DIRGIT=http://srkmcontdelivery.mutua.es/diganalytics/bigdata-services
 descargaGit ${DIRGIT}

