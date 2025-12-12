#!/bin/bash

if [ -z $1 ]; then
	EXIM_VERSION="4.99"
	echo "Version argument not provided. Defaulting to $EXIM_VERSION"
else
	EXIM_VERSION=$1
fi
echo "Building version $EXIM_VERSION"

if [ -z $2 ]; then
	EXPORT_DIR=${HOME}/debs
else
	EXPORT_DIR=$2
fi

if [ ! -d $EXPORT_DIR ]; then
	mkdir -p $EXPORT_DIR
fi

CPUS=$(lscpu | grep '^CPU(s):' | awk '{ print $2 }');
docker build --build-arg EXIM_VERSION=$EXIM_VERSION --build-arg CPUS=$CPUS -t build/st-exim .

docker image inspect build/st-exim >/dev/null 2>&1
RET=$?
if [ $RET != 0 ]; then
	echo "Failed to build image with 'docker build --build-arg EXIM_VERSION=$EXIM_VERSION --build-arg CPUS=$CPUS -t build/st-exim'. Return code $RET"
	exit
else
	echo "Built docker image: build/st-exim"
fi

CONTAINER=$(docker run -d build/st-exim)
RET=$?
if [ $RET != 0 ]; then
	echo "Failed to run container ($CONTAINER) with 'docker run -d build/st-exim' Return code $RET"
	exit
fi

docker cp $CONTAINER:/st-exim-${EXIM_VERSION}_amd64.deb ${EXPORT_DIR}/

echo Cleaning up...
sleep 5
docker rm $CONTAINER >/dev/null
docker image rm build/st-exim -f >/dev/null
if [ -f ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_amd64.deb ]; then
	echo "Package build and exported to: ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_amd64.deb"
else
	echo "Failed to export package st-exim-${EXIM_VERSION}_amd64.deb to ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_amd64.deb"
fi
