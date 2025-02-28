#!/bin/bash

if [ -z $1 ]; then
	echo "Please provide desired version tag as an argument"
	exit
else
	EXIM_VERSION=$1
	echo "Building version $EXIM_VERSION"
fi

if [ -z $2 ]; then
	EXPORT_DIR=${HOME}/debs
else
	EXPORT_DIR=$2
fi

if [ ! -d $EXPORT_DIR ]; then
	mkdir -p $EXPORT_DIR
fi

CPUS=$(lscpu | grep '^CPU(s):' | awk '{ print $2 }');
docker build --build-arg EXIM_VERSION=$EXIM_VERSION --build-arg CPUS=$CPUS -t build/mc-exim .

docker image inspect build/mc-exim >/dev/null 2>&1
RET=$?
if [ $RET != 0 ]; then
	echo "Failed to build image with 'docker build --build-arg EXIM_VERSION=$EXIM_VERSION -t build/mc-exim -f Containerfile'. Return code $RET"
	exit
else
	echo "Built docker image: build/mc-exim"
fi

CONTAINER=$(docker run -d build/mc-exim)
RET=$?
if [ $RET != 0 ]; then
	echo "Failed to run container ($CONTAINER) with 'docker run -d build/mc-exim' Return code $RET"
	exit
fi

docker cp $CONTAINER:/mc-exim-${EXIM_VERSION}_amd64.deb ${EXPORT_DIR}/

echo Cleaning up...
sleep 5
docker rm $CONTAINER >/dev/null
docker image rm build/mc-exim -f >/dev/null
if [ -f ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb ]; then
	echo "Package build and exported to: ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb"
else
	echo "Failed to export package mc-exim-${EXIM_VERSION}_amd64.deb to ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb"
fi
