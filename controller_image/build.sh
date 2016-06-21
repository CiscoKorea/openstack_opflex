#!/bin/bash

PWD=`${pwd}`

docker pull centos:7

docker run \
 -ti \
 --privileged \
 --net host \
 --name base \
 -v $PWD:/root/image:ro \
 centos:7 \
 /root/image/installer.sh

docker commit base ciscokr/openstack_base
docker rm -f base

docker build --rm --tag ciscokr/openstack_opflex .
