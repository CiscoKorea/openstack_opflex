#!/bin/bash

PWD=`pwd`

rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chmod 777 /var/lib/mysql

docker run\
 -d \
 --rm \
 --privileged \
 --net host \
 --name os_opflex \
 --env-file $PWD/conf/Environment.conf \
 -v /var/lib/mysql:/var/lib/mysql:rw \
 -v $PWD/ciscokr:/root/ciscokr:ro \
 -v $PWD/conf:/root/conf:ro \
 ciscokr/openstack_opflex
