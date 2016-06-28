#!/bin/bash

systemctl start libvirtd openstack-nova-compute neutron-opflex-agent agent-ovs

for i in {0..5};
do
	echo "BEFORE PERMIT"
	ls -l /var/run/ | grep opflex | awk '{print $3 ":" $4 " - " $9}'
	chown neutron:neutron /var/run/opflex-agent-ovs-notif.sock >> /dev/null
	chown neutron:neutron /var/run/opflex-agent-ovs-inspect.sock >> /dev/null
	echo "AFTER PERMIT"
	ls -l /var/run/ | grep opflex | awk '{print $3 ":" $4 " - " $9}'
	sleep 1
done

systemctl status libvirtd openstack-nova-compute neutron-opflex-agent agent-ovs | grep -e Loaded -e Active

echo ""
echo "Finished"