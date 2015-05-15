#!/bin/bash

DOCKER=`which docker`
HOST_IP=`ifconfig en0 | grep inet | grep 'inet\s' | awk '{print $2}'`
WORK_DIR=`pwd`
[[ $DOCKER_HOST =~ [^:]+://([^:]*) ]]
DOCKERHOST=${BASH_REMATCH[1]}

DOCKER_CMD='docker run -ti -v "'$DOCKER':'$DOCKER'" -v "/var/run/docker.sock:/var/run/docker.sock" -e HOST_IP='$HOST_IP' -e DOCKERHOST='$DOCKERHOST' -e LOG_LEVEL=INFO -e WORK_DIR="'$WORK_DIR'" accordance/dev-seed:0.0.3'
echo $DOCKER_CMD
eval $DOCKER_CMD
