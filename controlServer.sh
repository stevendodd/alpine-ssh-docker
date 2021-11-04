#!/bin/sh

if [ -f setEnvironment.sh ]
then
  source ./setEnvironment.sh
else
	DOCKERUSER=docker
    CONTAINERHOST=XX.XX.XX.XX
fi

SCRIPT=docker-qnap.sh
RHOME="~/docker-qnap-controller"
CONTROL=${RHOME}/${SCRIPT}


delete()
{
	ssh ${DOCKERUSER}@${CONTAINERHOST} \
	"if [ -f ${CONTROL} ]; then ${CONTROL} delete; rm -Rf ${CONTROL}; fi"
}


if [ "$1" = "deploy" ]; then
    ./mkimage.sh
    delete
	ssh ${DOCKERUSER}@${CONTAINERHOST} "mkdir ${RHOME}"
	scp build/docker-compose.yml ${DOCKERUSER}@${CONTAINERHOST}:${RHOME}
	scp src/scripts/${SCRIPT} ${DOCKERUSER}@${CONTAINERHOST}:${RHOME}
	ssh ${DOCKERUSER}@${CONTAINERHOST} "${CONTROL} deploy"
	
elif [ "$1" = "delete" ]; then
	delete
	
else
	echo "Usage controlServer.sh [deploy|delete]"
fi
