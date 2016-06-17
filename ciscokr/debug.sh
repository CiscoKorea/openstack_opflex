#!/bin/bash

rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chmod 777 /var/lib/mysql

docker run\
 -it \
 --privileged \
 --rm \
 --net host \
 --name os_opflex \
 -v /var/lib/mysql:/var/lib/mysql:rw \
 -v /root/openstack_opflex/docker/openstack/ciscokr:/root/ciscokr:rw \
 ciscokr/openstack_opflex $1