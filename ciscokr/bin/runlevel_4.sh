#!/bin/bash

echo "START RUN LEVEL 4"

if [ ! -f /.registered ]; then

	# Active Keystone Data
	echo "Active Keystone Data"
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
	
	# Create Database
	echo "Create Databases"
	mysql -e "CREATE DATABASE glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$PASSWORD';"
	mysql -e "CREATE DATABASE nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$PASSWORD';"
	mysql -e "CREATE DATABASE neutron; GRANT ALL PRIVILEGES ON neutrons.* TO 'neutron'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$PASSWORD';"
	
	# Deploy Database
	echo "Deploy Databases"
	su -s /bin/sh -c "glance-manage db_sync" glance
	su -s /bin/sh -c "nova-manage db sync" nova
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
	
	# Create Users
	echo "Create Users"
	openstack user create --domain default --password $PASSWORD glance
	openstack user create --domain default --password $PASSWORD nova
	openstack user create --domain default --password $PASSWORD neutron
	
	# Register Roles
	echo "Register Roles"
	openstack role add --project service --user glance admin
	openstack role add --project service --user nova admin
	openstack role add --project service --user neutron admin
	
	# Create Services
	echo "Create Services"
	openstack service create --name glance --description "OpenStack Image service" image
	openstack service create --name nova --description "OpenStack Compute" compute
	openstack service create --name neutron --description "OpenStack Networking" network
	
	# Create Endpoint
	echo "Create Endpoints"
	openstack endpoint create --region RegionOne image public http://$HOSTIP:9292
	openstack endpoint create --region RegionOne image internal http://$HOSTIP:9292
	openstack endpoint create --region RegionOne image admin http://$HOSTIP:9292
	
	openstack endpoint create --region RegionOne compute public http://$HOSTIP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute internal http://$HOSTIP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute admin http://$HOSTIP:8774/v2/%\(tenant_id\)s
	
	openstack endpoint create --region RegionOne network public http://$HOSTIP:9696
	openstack endpoint create --region RegionOne network internal http://$HOSTIP:9696
	openstack endpoint create --region RegionOne network admin http://$HOSTIP:9696
	
	
	
	
	
	
	
	# Register Services
#	export OS_PROJECT_DOMAIN_ID=default
#	export OS_USER_DOMAIN_ID=default
#	export OS_PROJECT_NAME=admin
#	export OS_TENANT_NAME=admin
#	export OS_USERNAME=admin
#	export OS_PASSWORD=$PASSWORD
#	export OS_AUTH_URL=http://$HOSTIP:35357/v3
#	export OS_IDENTITY_API_VERSION=3

	touch /.registered
fi