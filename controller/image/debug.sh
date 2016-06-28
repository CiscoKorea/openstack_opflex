#!/bin/bash

PWD=`pwd`

docker run\
 -it \
 --rm \
 --privileged \
 --net host \
 --entrypoint /bin/bash \
 ciscokr/openstack_opflex
