#!/bin/bash
#
function crealink {
	rm -fr $PATHANA/$1/DB2/DB2CATLG.current
	ln -s $PATHANA/$1/DB2/DB2CATLG.$2 $PATHANA/$1/DB2/DB2CATLG.current
	ls -la $PATHANA/$1/DB2/DB2CATLG.current
	rm -fr $PATHANA/$1/DB2/DB2PLNTB.current
	ln -s $PATHANA/$1/DB2/DB2PLNTB.$2 $PATHANA/$1/DB2/DB2PLNTB.current
	ls -la $PATHANA/$1/DB2/DB2PLNTB.current
}

PATHANA=/mma/datos/kiuwanSubsistemas
case $1 in
	list_all)
		echo "= DESA =========================="
		ls -la ${PATHANA}/DESA/DB2/DB2*.current
		ls -la ${PATHANA}/DESA/DB2/DB2*.F*
		echo "= PREP =========================="
		ls -la ${PATHANA}/PREP/DB2/DB2*.current
		ls -la ${PATHANA}/PREP/DB2/DB2*.F*
		echo "= EXPL =========================="
		ls -la ${PATHANA}/EXPL/DB2/DB2*.current
		ls -la ${PATHANA}/EXPL/DB2/DB2*.F*
	;;
	list)
		ls -la ${PATHANA}/DESA/DB2/DB2*.current
		ls -la ${PATHANA}/PREP/DB2/DB2*.current
		ls -la ${PATHANA}/EXPL/DB2/DB2*.current
		if [ "x$2" != "x" ]; then 
			ls -la ${PATHANA}/DESA/DB2/DB2*.F$2
			ls -la ${PATHANA}/PREP/DB2/DB2*.F$2
			ls -la ${PATHANA}/EXPL/DB2/DB2*.F$2
		fi 
	;;
    reload_all)
		crealink DESA F$2
		crealink PREP F$2
		crealink EXPL F$2
	;;
    reload_DESA)
		crealink DESA F$2
	;;
    reload_PREP)
		crealink PREP F$2
	;;
    reload_EXPL)
		crealink EXPL F$2
	;;
esac

exit 0


