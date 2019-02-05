#!/bin/bash
#
FILE=_mma.properties
USERMM=amasa3w

stty -echo
printf "Password [${USERMM}]: "
read PASSMM
stty echo
printf "\n"

echo USERMM=${USERMM} > ${FILE}
echo PASSMM=${PASSMM} >> ${FILE}

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


