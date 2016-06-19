#!/bin/bash

CB=/root/ciscokr/bin
CF=/root/ciscokr/files
TICK1=10
TICK2=20
TICK3=30

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
	(sleep $TICK1 && $CB/runlevel_2.sh && $CB/runlevel_3.sh) &
	(sleep $TICK2 && $CB/runlevel_4.sh && $CB/runlevel_5.sh) &
	sleep $TICK3
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
