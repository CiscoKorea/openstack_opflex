#!/bin/bash

yum install -y --setopt=tsflags=nodocs \
	net-tools wget \
	openvswitch \
	openstack-neutron-ml2 openstack-neutron-openvswitch

systemctl enable openvswitch
systemctl start openvswitch

if [ "$APIC_MODE" == "apic_ml2" ]; then
	export APIC_PLUGINS=cisco_apic_l3,metering,lbaas
	export APIC_DRIVER=cisco_apic_ml2
elif [ "$APIC_MODE" == "gbp" ]; then
	export APIC_PLUGINS=group_policy,servicechain,apic_gbp_l3,metering
	export APIC_DRIVER=apic_gbp
else
	exit 1
fi

cat << EOF > /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
core_plugin = ml2
service_plugins = $APIC_PLUGINS
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

cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = opflex,flat,vlan,gre,vxlan
tenant_network_types = opflex
mechanism_drivers = $APIC_DRIVER
[ml2_type_vlan]
network_vlan_ranges = physnet1:2000:2100
bridge_mappings = physnet1:br-int
[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
[ovs]
local_ip = $HOST_IP
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
    "log": {"level": "debug2"},
    "opflex": {
        "domain": "comp/prov-OpenStack/ctrlr-[$APIC_ID]-$APIC_ID/sw-InsiemeLSOid",
        "name": "$HOST_NAME",
        "peers": [{"hostname": "10.0.0.30", "port": "8009"}],
        "ssl": {"mode": "enabled","ca-store": "/etc/ssl/certs/"}
    },
    "endpoint-sources": {"filesystem": ["/var/lib/opflex-agent-ovs/endpoints"]},
    "renderers": {
        "stitched-mode": {
            "ovs-bridge-name": "br-int",
            "encap": {"vlan": {"encap-iface": "$DATA_INTF"}},
            "flowid-cache-dir": "/var/lib/opflex-agent-ovs/ids"
        }
    }
}
EOF

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
chown -R neutron /var/lib/opflex-agent-ovs
ovs-vsctl add-port br-int $DATA_INTF
sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /usr/lib/systemd/system/neutron-openvswitch-agent.service