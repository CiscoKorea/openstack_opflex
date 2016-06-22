#!/bin/bash

cat << EOF > /etc/yum.repos.d/opflex.repo
[opflex]
name=opflex repo
baseurl=http://$REPOIP/opflex
failovermethod=priority
enabled=1
gpgcheck=0
EOF

yum install -y --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm
yum install -y --setopt=tsflags=nodocs openstack-selinux
yum update -y && yum upgrade -y
yum install -y --setopt=tsflags=nodocs \
	net-tools wget \
	openstack-nova-compute sysfsutils \
	openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch \
	neutron-opflex-agent agent-ovs
yum clean all

## NOVA ##
cat << EOF > /etc/nova/nova.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
my_ip = $HOSTIP
vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $HOSTIP
novncproxy_base_url = http://$CTRLIP:6080/vnc_auto.html
verbose = True
network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
[oslo_messaging_rabbit]
rabbit_host = $CTRLIP
rabbit_userid = openstack
rabbit_password = $PASSWORD
[keystone_authtoken]
auth_uri = http://$CTRLIP:5000
auth_url = http://$CTRLIP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = $PASSWORD
[glance]
host = $CTRLIP
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[neutron]
url = http://$CTRLIP:9696
auth_strategy = keystone
admin_auth_url = http://$CTRLIP:35357/v2.0
admin_tenant_name = service
admin_username = neutron
admin_password = $PASSWORD
EOF

## Neutron ##

SERVICE_PLUGINS=cisco_apic_l3,metering,lbaas
MECHDRIVERS=cisco_apic_ml2
if [ "$APICMODE" == "gbp" ]; then
	SERVICE_PLUGINS=group_policy,servicechain,apic_gbp_l3,metering
	MECHDRIVERS=apic_gbp
fi

cat << EOF > /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
core_plugin = ml2
service_plugins = $SERVICE_PLUGINS
allow_overlapping_ips = True
verbose = True
[oslo_messaging_rabbit]
rabbit_host = $CTRLIP
rabbit_userid = openstack
rabbit_password = $PASSWORD
[keystone_authtoken]
auth_uri = http://$CTRLIP:5000
auth_url = http://$CTRLIP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $PASSWORD
EOF

cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = opflex,flat,vlan,gre,vxlan
tenant_network_types = opflex
mechanism_drivers = $MECHDRIVERS
[ml2_type_vlan]
network_vlan_ranges = physnet1:2000:2100
bridge_mappings = physnet1:br-int
[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
[ovs]
local_ip = $HOSTIP
EOF

cat << EOF > /etc/neutron/plugins/ml2/openvswitch_agent.ini 
[ovs]
enable_tunneling = False
integration_bridge = br-int
[agent]
[securitygroup]
EOF

cat << EOF > /etc/opflex-agent-ovs/opflex-agent-ovs.conf
{
    "log": {
        "level": "debug2"
    },
    "opflex": {
        "domain": "comp/prov-OpenStack/ctrlr-[$APICID]-$APICID/sw-InsiemeLSOid",
        "name": "$HOSTNAME",
        "peers": [
        {
            "hostname": "10.0.0.30",
            "port": "8009"
        }
        ],
        "ssl": {
        "mode": "enabled",
        "ca-store": "/etc/ssl/certs/"
        }
    },
    "endpoint-sources": {
        "filesystem": [
        "/var/lib/opflex-agent-ovs/endpoints"
        ]
        },
        "renderers": {
            "stitched-mode": {
                 "ovs-bridge-name": "br-int",
                "encap": {
                    "vlan": {
                        "encap-iface": "bond0"
                     }
                 },
               "flowid-cache-dir": "/var/lib/opflex-agent-ovs/ids"
            }
      }
}
EOF





ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
chown -R neutron /var/lib/opflex-agent-ovs
ovs-vsctl add-port br-int bond0.4093
sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /usr/lib/systemd/system/neutron-openvswitch-agent.service






