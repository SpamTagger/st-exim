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

if [ -z $3 ]; then
	ARCH='amd64'
else
	ARCH=$3
fi

if [ ! -d $EXPORT_DIR ]; then
	mkdir -p $EXPORT_DIR
fi

CPUS=$(lscpu | grep '^CPU(s):' | awk '{ print $2 }');
echo RUNNING: docker build --platform linux/$ARCH --build-arg DEB_ARCH=$ARCH --build-arg EXIM_VERSION=$EXIM_VERSION --build-arg CPUS=$CPUS -t build/st-exim .
docker buildx build --platform linux/$ARCH --build-arg DEB_ARCH=$ARCH --build-arg EXIM_VERSION=$EXIM_VERSION --build-arg CPUS=$CPUS --output type=local,dest=${EXPORT_DIR} -t build/st-exim .

echo Cleaning up...
docker image rm build/st-exim -f >/dev/null
if [ -f ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_${ARCH}.deb ]; then
	echo "Package build and exported to: ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_${ARCH}.deb"
else
	echo "Failed to export package st-exim-${EXIM_VERSION}_${ARCH}.deb to ${EXPORT_DIR}/st-exim-${EXIM_VERSION}_${ARCH}.deb"
fi
