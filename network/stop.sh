#!/bin/bash

systemctl stop neutron-opflex-agent agent-ovs neutron-dhcp-agent
rm -rf /var/log/neutron/*

META_AGENTS=`ps -ef | grep neutron-metadata-agent | awk '{print $2}'`

for i in $META_AGENTS; do
        kill $i >> /dev/null
done

SUPERVISORD=`ps -ef | grep supervisord | awk '{print $2}'`

for i in $SUPERVISORD; do
        kill $i >> /dev/null
done
