#!/bin/bash

cat << EOF > /etc/yum.repos.d/opflex.repo
[opflex]
name=opflex repo
baseurl=http://$CTRL_IP/opflex
failovermethod=priority
enabled=1
gpgcheck=0
EOF

yum install -y --setopt=tsflags=nodocs epel-release
yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm
yum install -y --setopt=tsflags=nodocs openstack-selinux
yum update -y && yum upgrade -y
