#!/bin/bash

rabbitmqctl add_user openstack $PASSWORD
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

if [ ! -f /.dbsynced ]; then
	# Keystone
	mysql -e "CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$PASSWORD';"
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	
	export OS_TOKEN=$PASSWORD
	export OS_URL=http://$HOSTIP:35357/v3
	export OS_IDENTITY_API_VERSION=3
	
	openstack service create --name keystone --description "OpenStack Identity" identity
	openstack endpoint create --region RegionOne identity public http://$HOSTIP:5000/v2.0
	openstack endpoint create --region RegionOne identity internal http://$HOSTIP:5000/v2.0
	openstack endpoint create --region RegionOne identity admin http://$HOSTIP:35357/v2.0
	
	openstack project create --domain default --description "Admin Project" admin
	openstack user create --domain default --password $PASSWORD admin
	openstack role create admin
	openstack role add --project admin --user admin admin
	openstack project create --domain default --description "Service Project" service
	
	touch /.dbsynced
fi