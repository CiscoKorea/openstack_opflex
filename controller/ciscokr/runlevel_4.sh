#!/bin/bash

echo "START RUN LEVEL 4"

if [ ! -f /.registered ]; then

	# Active Keystone Data
	echo "Active Keystone Data"
	mysql -e "CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$CTRL_PASS'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$CTRL_PASS';"
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	
	export OS_TOKEN=$CTRL_PASS
	export OS_URL=http://$CTRL_IP:35357/v3
	export OS_IDENTITY_API_VERSION=3
	
	openstack service create --name keystone --description "OpenStack Identity" identity
	openstack endpoint create --region RegionOne identity public http://$CTRL_IP:5000/v2.0
	openstack endpoint create --region RegionOne identity internal http://$CTRL_IP:5000/v2.0
	openstack endpoint create --region RegionOne identity admin http://$CTRL_IP:35357/v2.0
	
	openstack project create --domain default --description "Admin Project" admin
	openstack user create --domain default --password $CTRL_PASS admin
	openstack role create admin
	openstack role add --project admin --user admin admin
	openstack project create --domain default --description "Service Project" service
	
	# Create Database ##########################################################
	echo "Create Databases"
	mysql -e "CREATE DATABASE glance; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$CTRL_PASS'; GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$CTRL_PASS';"
	mysql -e "CREATE DATABASE nova; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$CTRL_PASS'; GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$CTRL_PASS';"
	mysql -e "CREATE DATABASE neutron; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY '$CTRL_PASS'; GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY '$CTRL_PASS';"
	
	# Deploy Database ##########################################################
	echo "Deploy Databases"
	su -s /bin/sh -c "glance-manage db_sync" glance >> /dev/null
	su -s /bin/sh -c "nova-manage db sync" nova >> /dev/null
	su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron >> /dev/null
	
	# Create Users ##########################################################
	echo "Create Users"
	openstack user create --domain default --password $CTRL_PASS glance
	openstack user create --domain default --password $CTRL_PASS nova
	openstack user create --domain default --password $CTRL_PASS neutron
	
	# Register Roles ##########################################################
	echo "Register Roles"
	openstack role add --project service --user glance admin
	openstack role add --project service --user nova admin
	openstack role add --project service --user neutron admin
	
	# Create Services ##########################################################
	echo "Create Services"
	openstack service create --name glance --description "OpenStack Image service" image
	openstack service create --name nova --description "OpenStack Compute" compute
	openstack service create --name neutron --description "OpenStack Networking" network
	
	# Create Endpoint ##########################################################
	echo "Create Endpoints"
	openstack endpoint create --region RegionOne image public http://$CTRL_IP:9292
	openstack endpoint create --region RegionOne image internal http://$CTRL_IP:9292
	openstack endpoint create --region RegionOne image admin http://$CTRL_IP:9292
	
	openstack endpoint create --region RegionOne compute public http://$CTRL_IP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute internal http://$CTRL_IP:8774/v2/%\(tenant_id\)s
	openstack endpoint create --region RegionOne compute admin http://$CTRL_IP:8774/v2/%\(tenant_id\)s
	
	openstack endpoint create --region RegionOne network public http://$CTRL_IP:9696
	openstack endpoint create --region RegionOne network internal http://$CTRL_IP:9696
	openstack endpoint create --region RegionOne network admin http://$CTRL_IP:9696
	
	# Opflex ##########################################################
	echo "Install OpFlex Plugins"
	
	if [ "$PLUGIN_VERSION" == "2" ]; then
		rpm -Uvh $_PKG/neutron-opflex-agent-2015.2.0-10.el7.noarch.rpm \
		$_PKG/apicapi-1.0.8-71.el7.noarch.rpm \
		$_PKG/neutron-ml2-driver-apic-2015.2.0-19.el7.noarch.rpm >> /dev/null
		if [ "$APIC_MODE" == "gbp" ]; then
			echo "GBP"
			rpm -Uvh $_PKG/python-gbpclient-0.11.1-8.el7.noarch.rpm \
			$_PKG/python-django-horizon-gbp-2015.2.1-8.el7.noarch.rpm \
			$_PKG/openstack-dashboard-gbp-2015.2.1-8.el7.noarch.rpm \
			$_PKG/openstack-heat-gbp-2015.2.1-8.el7.noarch.rpm \
			$_PKG/openstack-neutron-gbp-2015.2.1-8.el7.noarch.rpm >> /dev/null
		fi
	elif [ "$PLUGIN_VERSION" == "3" ]; then
		rpm -Uvh $_PKG/neutron-opflex-agent-2015.2.0-10.el7.noarch.rpm \
		$_PKG/apicapi-1.0.9-74.el7.noarch.rpm \
		$_PKG/neutron-ml2-driver-apic-2015.2.1-32.el7.noarch.rpm >> /dev/null
		if [ "$APIC_MODE" == "gbp" ]; then
			echo "GBP"
			rpm -Uvh $_PKG/python-gbpclient-0.11.2-16.el7.noarch.rpm \
			$_PKG/python-django-horizon-gbp-2015.2.3-16.el7.noarch.rpm \
			$_PKG/openstack-dashboard-gbp-2015.2.3-16.el7.noarch.rpm \
			$_PKG/openstack-heat-gbp-2015.2.2-16.el7.noarch.rpm \
			$_PKG/openstack-neutron-gbp-2015.2.3-16.el7.noarch.rpm >> /dev/null
		fi
	fi
	
	cat << EOF > /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
[DEFAULT]
debug=True
apic_system_id = $APIC_ID
[opflex]
networks = '*'
[ml2_cisco_apic]
apic_hosts = $APIC_HOST
apic_username = $APIC_USER
apic_password = $APIC_PASS
apic_use_ssl = True
apic_name_mapping = use_name
apic_agent_report_interval = 30
apic_agent_poll_interval = 2
apic_provision_infra = True
apic_provision_hostlinks = True
enable_optimized_dhcp = False
enable_optimized_metadata = False
EOF
	
	if [ -n $APIC_VPCPAIR ]; then
		echo "apic_vpc_pairs = $APIC_VPCPAIR" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
	fi
	
	if [ "$APIC_MODE" == "gbp" ]; then
		echo "[group_policy]" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
		echo "policy_drivers=implicit_policy,apic" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
		echo "[group_policy_implicit_policy]" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
		echo "default_ip_pool=$APIC_GBPPOOL" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
	fi

	cat $_CONF/Switch.conf >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini

	touch /.registered
fi