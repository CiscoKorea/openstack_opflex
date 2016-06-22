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
 --entrypoint /bin/bash \
 ciscokr/openstack_opflex
