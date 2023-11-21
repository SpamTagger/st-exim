#!/bin/bash

RUNTIME=podman
#RUNTIME=docker

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

$RUNTIME build --build-arg EXIM_VERSION=$EXIM_VERSION -t build/mc-exim -f Containerfile
if [[ $($RUNTIME image exists build/mc-exim) == 0 ]]; then
	echo "Failed to build image with '$RUNTIME build --build-arg EXIM_VERSION=$EXIM_VERSION -t build/mc-exim -f Containerfile'. Return code $RET"
	exit
else
	echo "Built $RUNTIME image: build/mc-exim"
fi

CONTAINER=$($RUNTIME run -d build/mc-exim)
RET=$?
if [ $RET != 0 ]; then
	echo "Failed to run container ($CONTAINER) with '$RUNTIME run -d build/mc-exim' Return code $RET"
	exit
fi

$RUNTIME cp $CONTAINER:/mc-exim-${EXIM_VERSION}_amd64.deb ${EXPORT_DIR}/
sleep 1
$RUNTIME rm $CONTAINER
if [ -f ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb ]; then
	echo "Package build and exported to: ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb"
else
	echo "Failed to export package mc-exim-${EXIM_VERSION}_amd64.deb to ${EXPORT_DIR}/mc-exim-${EXIM_VERSION}_amd64.deb"
fi
