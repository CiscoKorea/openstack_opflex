#!/bin/bash

NET_PATH=/etc/sysconfig/network-scripts
DHCPPATH=/etc/dhcp

function getval {
    while true;
    do
    	read -p "Input $2 : " VAL
    	read -p "\"$VAL\" is correct ? (y) : " KEY
        case $KEY in
            [Yy]) break;;
            *) continue;;
        esac
    done
    echo ""
    export $1="$VAL"
}

function getvmac {
	export VMAC=`ifconfig $1 | grep ether | awk '{print $2}' | tr ":" " " | awk '{print "fa:"$2":"$3":"$4":"$5":"$6}'`
}

function printnics {
	ifconfig -a | grep flags | tr ":" " " | tr "<" " " | tr ">" " " | awk '{print $1 "\t:" $3}'
}

# SETTING SELINUX ########################################################################

cat << EOF > /etc/selinux/config
SELINUX=disabled
SELINUXTYPE=targeted
EOF

# SETTING FORWARD ########################################################################

cat << EOF > /etc/sysctl.conf
net.ipv4.ip_forward = 1
EOF
sysctl -p

# SETTING NETWORK ########################################################################

function nic_basic {
	printnics
	getval DATA_INTF "Data Network Interface"
	getvmac $DATA_INTF
	cp $NET_PATH/ifcfg-$DATA_INTF $NET_PATH/backup-$DATA_INTF
	
	cat << EOF > $NET_PATH/ifcfg-$DATA_INTF
DEVICE=$DATA_INTF
BOOTPROTO=none
ONBOOT=yes
MTU=1600
EOF
	
}

function nic_bonding {
	printnics
    getval BOND_INTF "Bonding Interfaces"
    getvmac `echo $BOND_INTF | awk '{print $1}'`
    
    for s in $BOND_INTF
	do
		cp $NET_PATH/ifcfg-$s $NET_PATH/backup-$s
		
		cat << EOF > $NET_PATH/ifcfg-$s
TYPE=Ethernet
BOOTPROTO=none
NAME=$s
DEVICE=$s
ONBOOT=yes
MASTER=bond0
SLAVE=yes
MTU=1600
EOF

		ifdown $s && ifup $s
	done

	cat << EOF > $NET_PATH/ifcfg-bond0 
DEVICE=bond0
BOOTPROTO=none
ONBOOT=yes
MTU=1600
BONDING_OPTS="mode=4 miimon=100 lacp_rate=1"
EOF
	
	export DATA_INTF=bond0
}

getval HOST_NAME "This Host Name"
echo $HOST_NAME > /etc/hostname
echo $HOST_NAME > /proc/sys/kernel/hostname

echo "Setting Data Network Interface Mode"
echo "  1 ) Basic"
echo "  2 ) Bonding"
while true;
do
        echo -n "Input Mode : (1|2) : "
        read NIC_MODE
        case $NIC_MODE in
                1 ) nic_basic; break;;
                2 ) nic_bonding; break;;
                * ) continue;;
        esac
done

ifdown $DATA_INTF && ifup $DATA_INTF

cat << EOF > $NET_PATH/ifcfg-$DATA_INTF.4093
PERSISTENT_DHCLIENT=1
DHCPRELEASE=1
DEVICE=$DATA_INTF.4093
ONBOOT=yes
PEERDNS=yes
TYPE=Ethernet
BOOTPROTO=dhcp
VLAN=yes
ONPARENT=yes
MTU=1600
NM_CONTROLLED=no
MACADDR=$VMAC
EOF

cat << EOF > $NET_PATH/route-$DATA_INTF.4093
ADDRESS0=224.0.0.0
NETMASK0=240.0.0.0
GATEWAY0=0.0.0.0
METRIC0=1000
EOF

cat << EOF > $DHCPPATH/dhclient-$DATA_INTF.4093.conf
send dhcp-client-identifier 01:$VMAC;
request subnet-mask, domain-name, domain-name-servers, host-name;
send host-name $HOST_NAME;
option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;
option ms-classless-static-routes code 249 = array of unsigned integer 8;
option wpad code 252 = string;
also request rfc3442-classless-static-routes;
also request ms-classless-static-routes;
also request static-routes;
also request wpad;
also request ntp-servers;
EOF

ifdown $DATA_INTF.4093 && ifup $DATA_INTF.4093

# INSTALL PACKAGE ########################################################################

cat << EOF > /etc/yum.repos.d/vbernat.repo
[home_vbernat]
name=vbernat's Home Project (RHEL_7)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/vbernat/RHEL_7/
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/vbernat/RHEL_7//repodata/repomd.xml.key
enabled=1
EOF

yum install -y --setopt=tsflags=nodocs epel-release
#yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm
yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-5.noarch.rpm
yum install -y --setopt=tsflags=nodocs openstack-selinux
yum update -y && yum upgrade -y
yum install -y --setopt=tsflags=nodocs net-tools wget lldpd openvswitch

systemctl enable lldpd openvswitch
systemctl start lldpd openvswitch
ovs-vsctl add-br br-int
ovs-vsctl add-port br-int $DATA_INTF
