#!/bin/bash

yum install -y --setopt=tsflags=nodocs openstack-nova-compute sysfsutils
	
cat << EOF > /etc/nova/nova.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
my_ip = $HOST_IP
vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $HOST_IP
novncproxy_base_url = http://$CTRL_IP:6080/vnc_auto.html
verbose = True
network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
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
username = nova
password = $CTRL_PASS
[glance]
host = $CTRL_IP
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[neutron]
url = http://$CTRL_IP:9696
auth_strategy = keystone
admin_auth_url = http://$CTRL_IP:35357/v2.0
admin_tenant_name = service
admin_username = neutron
admin_password = $CTRL_PASS
EOF

