#!/bin/bash

yum install -y --setopt=tsflags=nodocs epel-release
yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm
yum install -y --setopt=tsflags=nodocs openstack-selinux

yum install -y --setopt=tsflags=nodocs \
	net-tools wget \
	openvswitch \
	openstack-neutron-ml2 openstack-neutron-openvswitch \
	openstack-neutron-fwaas openstack-neutron-lbaas openstack-neutron-vpnaas

systemctl enable openvswitch
systemctl start openvswitch


cat << EOF > /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
core_plugin = ml2
service_plugins = group_policy,servicechain,apic_gbp_l3
allow_overlapping_ips = True
verbose = True
[oslo_messaging_rabbit]
rabbit_host = $CTRL_IP
rabbit_userid = openstack
rabbit_password = $CTRL_PASS
[keystone_authtoken]
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $CTRL_PASS
EOF