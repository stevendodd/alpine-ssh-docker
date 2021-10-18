#!/bin/sh

if [ -f setEnvironment.sh ]
then
  source ./setEnvironment.sh
else
	DOCKERUSER=docker
    CONTAINERHOST=XX.XX.XX.XX
fi

RHOME="~/docker-qnap-controller"
CONTROL=${RHOME}/docker-qnap.sh


delete()
{
	ssh ${DOCKERUSER}@${CONTAINERHOST} \
	"if [ -f ${CONTROL} ]; then ${CONTROL} delete; rm -Rf ${RHOME}; fi"
}


if [ "$1" = "deploy" ]; then
    ./mkimage.sh
    delete
	ssh ${DOCKERUSER}@${CONTAINERHOST} "mkdir ${RHOME}"
	scp build/docker-compose.yml ${DOCKERUSER}@${CONTAINERHOST}:${RHOME}
	scp src/scripts/docker-qnap.sh ${DOCKERUSER}@${CONTAINERHOST}:${RHOME}
	ssh ${DOCKERUSER}@${CONTAINERHOST} "${CONTROL} deploy"
	
elif [ "$1" = "delete" ]; then
	delete
	
else
	echo "Usage controlServer.sh [deploy|delete]"
fi
