#!/bin/bash

cd /root/ciscokr
PWD=`pwd`
export _ROOT=$PWD
export _BIN=$_ROOT/bin
export _IMG=$_ROOT/image
export _PKG=$_ROOT/package
export _CONF=/root/conf

if [ "$APIC_MODE" == "apic_ml2" ]; then
	export APIC_PLUGINS=cisco_apic_l3,metering,lbaas
	export APIC_DRIVER=cisco_apic_ml2
elif [ "$APIC_MODE" == "gbp" ]; then
	export APIC_PLUGINS=group_policy,servicechain,apic_gbp_l3,metering
	export APIC_DRIVER=apic_gbp
else
	exit 1
fi

TICK1=5
TICK2=6
TICK3=30

function idle {
	while true; do
		read -p "Type \"bash\" or \"exit\" > " KEY
			case $KEY in
			exit ) break ;;
			bash ) /bin/bash ;;
			* ) echo "$KEY";;
		esac
	done
}

function main {
	echo "RUNNING OPENSTACK!!!"
	echo ""
	echo "$CTRL_NAME" > /proc/sys/kernel/hostname
	if [ ! -f /.first_run ]; then
		echo "$CTRL_NAME" > /etc/hostname
		echo "" >> /etc/hosts
		cat $_CONF/OpenstackNodes.conf >> /etc/hosts
		mkdir -p /var/www/html/opflex
		cp $_PKG/* /var/www/html/opflex/
		createrepo /var/www/html/opflex >> /dev/null
		chown -R apache:apache /var/www/html/opflex
		$_ROOT/setting.sh >> /tmp/running.log
		touch /.first_run
	fi
	$_ROOT/runlevel_1.sh
	(sleep $TICK1 && $_ROOT/runlevel_2.sh) &
	(sleep $TICK2 && $_ROOT/runlevel_3.sh) &
	(sleep $TICK3 && $_ROOT/runlevel_4.sh && $_ROOT/runlevel_5.sh) &
	idle
}

main