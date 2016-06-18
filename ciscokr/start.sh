#!/bin/bash

CB=/root/ciscokr/bin
CF=/root/ciscokr/files
L2T=10
L3T=15
L4T=20
ITC=40

function idle {
	while true; do
		read -p "Type \"exit\" to Exit > " KEY
			case $KEY in
			exit ) break ;;
			shell ) /bin/bash ;;
			* ) echo "$KEY";;
		esac
	done
}

function running {
	echo "RUNNING OPENSTACK!!!"
	echo "$HOSTNAME" > /proc/sys/kernel/hostname
	if [ ! -f /.first_run ]; then
		echo "$HOSTNAME $HOSTIP" >> /etc/hosts
		cp -ax $CF/* /
		$CB/setting.sh
		touch /.first_run
	fi
	$CB/runlevel_1.sh
	(sleep $L2T && $CB/runlevel_2.sh) &
	(sleep $L3T && $CB/runlevel_3.sh) &
	(sleep $L4T && $CB/runlevel_4.sh && $CB/runlevel_5.sh) &
	sleep $ITC
	echo "START IDLE"
	idle
}

function debugging {
	echo "RUNNING DEBUGGING"
	/bin/bash
	echo "EXIT"
}

if [ "$1" == "debug" ]; then
	debugging
else
	running
fi
