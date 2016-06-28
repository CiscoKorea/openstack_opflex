#!/bin/bash

systemctl start neutron-opflex-agent agent-ovs
systemctl status neutron-opflex-agent agent-ovs | grep -e Loaded -e Active

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

echo ""
echo "Finished"