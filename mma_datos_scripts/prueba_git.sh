#!/bin/bash
#
echo "Cloning the remote Git repository"
URL0=http://srkmcontdelivery.mutua.es/apparq/segurosRurales-app.git
URL=`echo ${URL0} | sed -e 's/http\:\/\//http\:\/\/testgit\:GITMutua01\@/g'` 
APPL=ARQUITECTURA-APP-SegurosRurales
RAMA=origin/develop
DIRTEMP=/mma/temp
FECHATMST=`date "+%Y%m%d%H%M%S"`
DIRKW=${DIRTEMP}/${APPL}_${FECHATMST}
echo "Cloning repository ${URL0}"
mkdir ${DIRKW}
git init ${DIRKW}
git --version # timeout=10
PWDBCK=`pwd`
cd ${DIRKW}
git fetch --tags --progress ${URL} +refs/heads/*:refs/remotes/origin/*
git config remote.origin.url ${URL}
git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git config remote.origin.url ${URL}
git fetch --tags --progress ${URL} +refs/heads/*:refs/remotes/origin/*
git rev-parse refs/remotes/${RAMA}^{commit}
REV=`git rev-parse refs/remotes/${RAMA}^{commit}`
git config core.sparsecheckout
git checkout -f ${REV}
rm -fr ${DIRKW}/.git
ls -la ${DIRKW} 
cd ${PWDBCK}
#rm -fr ${DIRKW} 

