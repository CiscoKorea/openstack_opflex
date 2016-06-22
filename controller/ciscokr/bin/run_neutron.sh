#!/bin/bash

sudo -u neutron -E -s /usr/bin/neutron-server \
--config-file /usr/share/neutron/neutron-dist.conf \
--config-file /etc/neutron/neutron.conf \
--config-file /etc/neutron/plugin.ini \
--config-file /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini \
--log-file /var/log/neutron/server.log &



