#!/bin/bash
#
FILE=_kiuwan.properties
USER=amateos@mutua.es

stty -echo
printf "Password [${USER}]: "
read PASS
stty echo
printf "\n"

echo USERKW=${USER} > ${FILE}
echo PASSKW=${PASS} >> ${FILE}

if [ -f ".gitignore" ]; then
  num=`cat .gitignore | grep ${FILE} |wc -l`
  if [ ${num} -eq 0 ]; then
    echo ${FILE} >> .gitignore
  fi
else
  echo ${FILE} > .gitignore
fi

cat .gitignore
cat ${FILE}

exit 0


