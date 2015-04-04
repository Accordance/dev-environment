#!/bin/bash

VBoxManage sharedfolder add boot2docker-vm -name home -hostpath /Users
VBoxManage modifyvm "boot2docker-vm" --natpf1 "orientdb-bin,tcp,127.0.0.1,2424,,2424"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "orientdb-web,tcp,127.0.0.1,2480,,2480"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "nginx,tcp,127.0.0.1,8000,,8000"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "redis,tcp,127.0.0.1,6379,,6379"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "consul,tcp,127.0.0.1,8500,,8500"
VBoxManage modifyvm "boot2docker-vm" --natpf1 "mongo,tcp,127.0.0.1,27017,,27017"
