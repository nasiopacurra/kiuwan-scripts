#!/bin/bash
#
# Scripts para comprobar directorios y zip de TransacSQL
#
DIRKW=/mma/datos/kiuwanSubsistemas/TransacSQL
DIRFTP=/mma/datos/ftproot/TransacSQL

#FECHA=`date "+%Y%m%d" --date="-1 day"`
FECHA="20180531"
# workaround para repetir
if [ -d ${DIRKW}/D${FECHA}_Baseline ]; then 
  echo "Borrando ${DIRKW}/D${FECHA}_Baseline"
  rm -fr ${DIRKW}/D${FECHA}_Baseline
fi

echo ${FECHA}
ls -dla ${DIRKW}/D*_Baseline
ls -la ${DIRFTP}/gen-bi-*.zip
PWD_OLD=`PWD`
if [ -f ${DIRFTP}/gen-bi-kiuwan-${FECHA}.zip ]; then 
  if [ ! -d ${DIRKW}/D${FECHA}_Baseline ]; then
    echo "No Existe Directorio y Existe Archivo: Tengo que actuar"
    cd ${DIRKW}
    echo "Desempaquetando ${DIRFTP}/gen-bi-kiuwan-${FECHA}.zip"
    unzip -qq ${DIRFTP}/gen-bi-kiuwan-${FECHA}.zip
    if [ -d  ${DIRKW}/${FECHA} ]; then 
      echo "Renombrado ${DIRKW}/${FECHA} como ${DIRKW}/D${FECHA}_Baseline"
      mv ${DIRKW}/${FECHA} ${DIRKW}/D${FECHA}_Baseline
      echo "Cambiando permisos de ${DIRKW}/D${FECHA}_Baseline"
      chmod -R 755 ${DIRKW}/D${FECHA}_Baseline
      # cambiar el link de openGrok
      DIROG=/mma/datos/opengrok/src
      echo "Eliminado link de OpenGrok ${DIROG}/TransacSQL"
      rm -fr ${DIROG}/TransacSQL
      echo "Creando link de Opengrok contra ${DIRKW}/D${FECHA}_Baseline/"
      ln -s ${DIRKW}/D${FECHA}_Baseline/ ${DIROG}/TransacSQL
    fi
  fi
fi

cd ${PWD_OLD}
exit 0
