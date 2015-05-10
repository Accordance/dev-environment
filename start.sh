#!/bin/bash

DOCKER=`which docker`
HOST_IP=`ifconfig en0 | grep inet | grep 'inet\s' | awk '{print $2}'`
WORK_DIR=`pwd`
[[ $DOCKER_HOST =~ [^:]+://([^:]*) ]]
DOCKERHOST=${BASH_REMATCH[1]}

# docker run -ti -v "/usr/local/bin/docker:/usr/local/bin/docker" -v "/var/run/docker.sock:/var/run/docker.sock" -e HOST_IP=10.0.0.2 -e DOCKERHOST=192.168.59.103 -e LOG_LEVEL=DEBUG -e WORK_DIR=/Users/imoochnick/Dev/accordance/dev-environment dev /bin/bash

DOCKER_CMD='docker run -ti -v "'$DOCKER':'$DOCKER'" -v "/var/run/docker.sock:/var/run/docker.sock" -e HOST_IP='$HOST_IP' -e DOCKERHOST='$DOCKERHOST' -e LOG_LEVEL=DEBUG -e WORK_DIR="'$WORK_DIR'" dev /bin/bash'
echo $DOCKER_CMD
eval $DOCKER_CMD
