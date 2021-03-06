#!/bin/bash

PWD=`pwd`

rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chmod 777 /var/lib/mysql

docker run\
 -it \
 --rm \
 --privileged \
 --net host \
 --name os_opflex \
 --env-file $PWD/conf/Environment.conf \
 -v $PWD/ciscokr:/root/ciscokr:rw \
 -v $PWD/conf:/root/conf:rw \
 ciscokr/openstack_opflex
 
# -v /var/lib/mysql:/var/lib/mysql:rw \