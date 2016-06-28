#!/bin/bash

systemctl stop libvirtd openstack-nova-compute neutron-opflex-agent agent-ovs
rm -rf /var/log/nova/*
rm -rf /var/log/neutron/*

META_AGENTS=`ps -ef | grep neutron-metadata-agent | awk '{print $2}'`

for i in $META_AGENTS; do
        kill $i >> /dev/null
done

SUPERVISORD=`ps -ef | grep supervisord | awk '{print $2}'`

for i in $SUPERVISORD; do
        kill $i >> /dev/null
done
