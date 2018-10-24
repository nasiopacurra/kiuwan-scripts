#!/bin/bash
# Procesos de Apache
echo "==== PROCESOS APACHE ================================="
PADRE=`ps -aux |grep "httpd"|grep apache|awk '{print $2}'`
ps --forest -o pid,ppid,stat,time,cmd -g $(ps -o sid= -p ${PADRE})
# Procesos de sshd
echo "==== PROCESOS SSHD ==================================="
for PADRE in $(ps -aux |grep "ftpkiuw+"|grep "analyse.sh"|grep -v "color"|awk '{print $2}'); do
	echo "Proceso: [${PADRE}][$$]"
	ps --forest -o pid,ppid,stat,time,cmd -g $(ps -o sid= -p ${PADRE})
done
