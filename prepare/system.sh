#!/bin/bash


NETPATH=/etc/sysconfig/network-scripts
DHCPATH=/etc/dhcp
BOND_SLAVES=$1
VMAC=$2
#ifconfig enp8s0 | grep ether | awk '{print $2}'

function usage {
	echo "system.sh \"BOND_NIC1 BOND_NIC2 ...\" <BOND_VMAC>
	exit 1
}

if [ "$BOND_SLAVES" == "" ]; then
	usage
elif [ "$VMAC" == "" ]; then
	usage
fi

for s in $BOND_SLAVES
do
cp $NETPATH/ifcfg-$s $NETPATH/backup-$s
cat << EOF > $NETPATH/ifcfg-$s
TYPE=Ethernet
BOOTPROTO=none
NAME=$s
DEVICE=$s
ONBOOT=yes
MASTER=bond0
SLAVE=yes
MTU=1600
EOF
done

cat << EOF > $NETPATH/ifcfg-bond0 
DEVICE=bond0
BOOTPROTO=none
ONBOOT=yes
MTU=1600
BONDING_OPTS="mode=4 miimon=100 lacp_rate=1"
EOF

cat << EOF > $NETPATH/ifcfg-bond0.4093
PERSISTENT_DHCLIENT=1
DHCPRELEASE=1
DEVICE=bond0.4093
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

cat << EOF > $NETPATH/route-bond0.4093
ADDRESS0=224.0.0.0
NETMASK0=240.0.0.0
GATEWAY0=0.0.0.0
METRIC0=1000
EOF

cat << EOF > $DHCPATH/dhclient-bond0.4093.conf
send dhcp-client-identifier 01:$VMAC;
request subnet-mask, domain-name, domain-name-servers, host-name;
send host-name compute01;
option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;
option ms-classless-static-routes code 249 = array of unsigned integer 8;
option wpad code 252 = string;
also request rfc3442-classless-static-routes;
also request ms-classless-static-routes;
also request static-routes;
also request wpad;
also request ntp-servers;
EOF

#service network restart
