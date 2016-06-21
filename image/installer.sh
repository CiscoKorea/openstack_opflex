#!/bin/bash

yum install -y --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm
yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm
yum install -y --setopt=tsflags=nodocs openstack-selinux

yum update -y && yum upgrade -y

yum install -y --setopt=tsflags=nodocs \
	net-tools wget \
	mariadb mariadb-server MySQL-python \
	rabbitmq-server \
	httpd mod_wsgi memcached \
	createrepo \
	python_pip python_pbr \
	openstack-utils \
	python-openstackclient \
	openstack-dashboard \
	openstack-keystone python-memcached \
	openstack-glance python-glance python-glanceclient \
	openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console \
	openstack-nova-novncproxy openstack-nova-scheduler python-novaclient \
	openstack-neutron openstack-neutron-ml2 python-neutronclient which \
	openstack-heat-api openstack-heat-api-cfn openstack-heat-engine python-heatclient \
	openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification \
	openstack-ceilometer-central openstack-ceilometer-alarm python-ceilometerclient

yum clean all
