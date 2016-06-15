#!/bin/bash

rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chmod 777 /var/lib/mysql

docker run\
 -d \
 --rm \
 --privileged \
 --net host \
 --name os_opflex \
 -v /var/lib/mysql:/var/lib/mysql:rw \
 -v /root/openstack_opflex/ciscokr:/root/ciscokr:ro \
 ciscokr/openstack_opflex
