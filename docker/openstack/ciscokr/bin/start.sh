#!/bin/bash

CB=/root/ciscokr/bin
L2T=10
L3T=15
L4T=20
L5T=25
ITC=30

function idle {
	while true; do
		read -p "Type \"exit\" to Exit > " KEY
			case $KEY in
			exit ) break;;
			* ) echo "$KEY";;
		esac
	done
}

function running {
	echo "$HOSTNAME $HOSTIP" >> /etc/hosts
	echo "$HOSTNAME" > /proc/sys/kernel/hostname
	chmod 755 $CB/*.sh
	cp -ax $CF/* /
	$CB/setting.sh
	$CB/runlevel_1.sh
	(sleep $L2T && $CB/runlevel_2.sh) &
	(sleep $L3T && $CB/runlevel_3.sh) &
	(sleep $L4T && $CB/runlevel_4.sh) &
	(sleep $L5T && $CB/runlevel_5.sh) &
	(sleep $ITC && idle) &
}

function debugging {
	idle
}

if [ "$1" == "debug" ]; then
	debugging
else
	running
fi
