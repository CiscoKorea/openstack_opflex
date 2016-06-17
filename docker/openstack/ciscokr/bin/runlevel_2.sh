#!/bin/bash

rabbitmqctl add_user openstack $PASSWORD
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

if [ ! -f /.dbsynced ]; then
	mysql -e "CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$PASSWORD';"
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	touch /.dbsynced
fi