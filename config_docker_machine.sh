#!/bin/bash

# Get the path of the home Accordance directory
current_dir = `pwd`
export ACCORDANCE_DIR = `dirname $current_dir`

if [ -z "$DOCKER_MACHINE_NAME" ]; then
  export DOCKER_MACHINE_NAME = 'dev';
fi

VBoxManage sharedfolder add $DOCKER_MACHINE_NAME -name home -hostpath $ACCORDANCE_DIR
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "orientdb-bin,tcp,127.0.0.1,2424,,2424"
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "orientdb-web,tcp,127.0.0.1,2480,,2480"
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "nginx,tcp,127.0.0.1,8000,,8000"
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "redis,tcp,127.0.0.1,6379,,6379"
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "consul,tcp,127.0.0.1,8500,,8500"
VBoxManage modifyvm $DOCKER_MACHINE_NAME --natpf1 "mongo,tcp,127.0.0.1,27017,,27017"
