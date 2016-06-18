#!/bin/bash

docker pull centos:7

docker run \
 -ti \
 --privileged \
 --net host \
 --name base \
 -v /root/openstack_opflex/base_image:/root/base_image:ro \
 centos:7 \
 /root/base_image/start.sh

docker commit base ciscokr/openstack_base

