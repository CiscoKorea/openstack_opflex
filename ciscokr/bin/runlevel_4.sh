#!/bin/bash

if [ ! -f /.registered ]; then

	export OS_PROJECT_DOMAIN_ID=default
	export OS_USER_DOMAIN_ID=default
	export OS_PROJECT_NAME=admin
	export OS_TENANT_NAME=admin
	export OS_USERNAME=admin
	export OS_PASSWORD=$PASSWORD
	export OS_AUTH_URL=http://$HOSTIP:35357/v3
	export OS_IDENTITY_API_VERSION=3
	
	# Create Database
	mysql -u root -p -e "CREATE DATABASE glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$PASSWORD';"
	su -s /bin/sh -c "glance-manage db_sync" glance
	mysql -u root -p -e "CREATE DATABASE nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$PASSWORD';"
	su -s /bin/sh -c "nova-manage db sync" nova
	mysql -u root -p -e "CREATE DATABASE neutron; GRANT ALL PRIVILEGES ON neutrons.* TO 'neutron'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$PASSWORD';"
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron

	# Create User
	openstack user create --domain default --password $PASSWORD glance
	openstack role add --project service --user glance admin
	openstack service create --name glance --description "OpenStack Image service" image
	
	openstack user create --domain default --password $PASSWORD nova
	openstack role add --project service --user nova admin
	openstack service create --name nova --description "OpenStack Compute" compute
	
	openstack user create --domain default --password $PASSWORD neutron
	openstack role add --project service --user neutron admin
	openstack service create --name neutron --description "OpenStack Networking" network
	
	# Create Endpoint
	openstack endpoint create --region RegionOne image public http://$HOSTIP:9292
	openstack endpoint create --region RegionOne image internal http://$HOSTIP:9292
	openstack endpoint create --region RegionOne image admin http://$HOSTIP:9292
	
	openstack endpoint create --region RegionOne compute public http://$HOSTIP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute internal http://$HOSTIP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute admin http://$HOSTIP:8774/v2/%\(tenant_id\)s
	
	openstack endpoint create --region RegionOne network public http://$HOSTIP:9696
	openstack endpoint create --region RegionOne network internal http://$HOSTIP:9696
	openstack endpoint create --region RegionOne network admin http://$HOSTIP:9696

	touch /.registered
fi