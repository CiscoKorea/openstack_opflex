#!/bin/bash

rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql
chmod 777 /var/lib/mysql

docker run -it --name os_db --net host -v /var/lib/mysql:/var/lib/mysql:rw ciscokr/openstack_db
