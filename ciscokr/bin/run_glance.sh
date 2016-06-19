#!/bin/bash

sudo -u glance -E -s /usr/bin/glance-api &
sudo -u glance -E -s /usr/bin/glance-registry &
sleep 2
glance image-create --name "cirros-0.3.4-x86_64" --file /root/ciscokr/image/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress &
