#!/bin/bash

cd /root/ciscokr
PWD=`pwd`
export _ROOT=$PWD
export _BIN=$_ROOT/bin
export _FILE=$_ROOT/files
export _IMG=$_ROOT/image
export _PKG=$_ROOT/pakage
export _CONF=/root/conf

TICK1=5
TICK2=40

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

function main {
	echo "RUNNING OPENSTACK!!!"
	echo ""
	echo "$HOSTNAME" > /proc/sys/kernel/hostname
	if [ ! -f /.first_run ]; then
		cp -ax $_FILE/* /
		echo "$HOSTNAME $HOSTIP" >> /etc/hosts
		echo "" >> /etc/hosts
		cat $_CONF/OpenstackNodes.conf >> /etc/hosts
		$_ROOT/setting.sh
		touch /.first_run
	fi
	$_ROOT/runlevel_1.sh
	(sleep $TICK1 && $_ROOT/runlevel_2.sh) &
	(sleep $TICK1 && $_ROOT/runlevel_3.sh) &
	(sleep $TICK2 && $_ROOT/runlevel_4.sh && $_ROOT/runlevel_5.sh) &
	idle
}

main