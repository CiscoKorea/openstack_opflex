#!/bin/bash

sudo -u glance -E -s /usr/bin/glance-api >> /tmp/glance-api.log &
sudo -u glance -E -s /usr/bin/glance-registry >> /tmp/glance-registry.log &
sleep 2

export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$HOST_PASS
export OS_AUTH_URL=http://$HOST_IP:35357/v3
export OS_IMAGE_API_VERSION=2

glance image-create --name "cirros-0.3.4-x86_64" --file /root/ciscokr/image/cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility public --progress >> /tmp/running.log &
