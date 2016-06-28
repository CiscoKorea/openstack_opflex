#!/bin/bash

function getval {
        while true;
        do
                echo -n "Input $2 : "
                read VAL
                echo -n "\"$VAL\" is correct ? (y) : "
                read KEY
                case $KEY in
                        [Yy]) break;;
                        *) continue;;
                esac
        done
        echo ""
        export $1="$VAL"
}

getval CTRL_IP "Controller IP"
getval CTRL_PASS "Controller Password"
getval HOST_IP "This Host IP"
getval DATA_INTF "Data Network Inteface"
getval APIC_ID "APIC Identify Name"
getval APIC_MODE "APIC Mode \"apic_ml2\" or \"gbp\""

if [ "$APIC_MODE" == "apic_ml2" ]; then
	export APIC_PLUGINS=cisco_apic_l3,metering,lbaas
	export APIC_DRIVER=cisco_apic_ml2
elif [ "$APIC_MODE" == "gbp" ]; then
	export APIC_PLUGINS=group_policy,servicechain,apic_gbp_l3,metering
	export APIC_DRIVER=apic_gbp
else
	exit 1
fi

# INSTALL PACKAGE ########################################################################
cat << EOF > /etc/yum.repos.d/opflex.repo
[opflex]
name=opflex repo
baseurl=http://$CTRL_IP/opflex
failovermethod=priority
enabled=1
gpgcheck=0
EOF

yum install -y --setopt=tsflags=nodocs \
	openstack-neutron-ml2 openstack-neutron-openvswitch \
	openstack-neutron-vpnaas openstack-neutron-lbaas openstack-neutron-fwaas
yum install -y --setopt=tsflags=nodocs neutron-opflex-agent agent-ovs

systemctl enable neutron-dhcp-agent neutron-opflex-agent agent-ovs

# SETTING ################################################################################

######### NEUTRON #########
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

######### METADATA #########
cat << EOF > /etc/neutron/metadata_agent.ini
[DEFAULT]
admin_tenant_name = %SERVICE_TENANT_NAME%
admin_user = %SERVICE_USER%
admin_password = %SERVICE_PASSWORD%
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_region = RegionOne
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $CTRL_PASS
nova_metadata_ip = $CTRL_IP
metadata_proxy_shared_secret = $CTRL_PASS
verbose = True
EOF

######### DHCP #########
cat << EOF > /etc/neutron/dhcp_agent.ini
[DEFAULT]
dhcp_driver = apic_ml2.neutron.agent.linux.apic_dhcp.ApicDnsmasq
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
ovs_integration_bridge = br-int
enable_isolated_metadata = True
verbose = True
EOF

######### MODULAR2 #########
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

######### OPENVSWITCH #########
cat << EOF > /etc/neutron/plugins/ml2/openvswitch_agent.ini 
[ovs]
enable_tunneling = False
integration_bridge = br-int
[agent]
[securitygroup]
EOF

######### OPFLEXOVS #########
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

######### COMMON #########
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
chown -R neutron /var/lib/opflex-agent-ovs
sed -i 's,plugins/openvswitch/ovs_neutron_plugin.ini,plugin.ini,g' /usr/lib/systemd/system/neutron-openvswitch-agent.service
