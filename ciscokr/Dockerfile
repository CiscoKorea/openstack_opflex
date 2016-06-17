FROM ciscokr/openstack_base
MAINTAINER Openstack Liberty <hyjang@cisco.com>

#yum install -y python-openstackclient && \
#yum install -y --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm && \
#yum install -y --setopt=tsflags=nodocs https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm && \
#yum install -y --setopt=tsflags=nodocs openstack-selinux && \
#yum install -y --setopt=tsflags=nodocs net-tools wget openstack-utils && \
#yum install -y --setopt=tsflags=nodocs mariadb mariadb-server MySQL-python && \
#yum install -y --setopt=tsflags=nodocs rabbitmq-server && \
#yum install -y --setopt=tsflags=nodocs httpd mod_wsgi memcached && \
#yum install -y --setopt=tsflags=nodocs openstack-dashboard && \
#yum install -y --setopt=tsflags=nodocs openstack-keystone python-memcached && \
#yum install -y --setopt=tsflags=nodocs openstack-glance python-glance python-glanceclient && \
#yum install -y --setopt=tsflags=nodocs openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient && \
#yum install -y --setopt=tsflags=nodocs openstack-neutron openstack-neutron-ml2 python-neutronclient which && \
#yum install -y --setopt=tsflags=nodocs openstack-heat-api openstack-heat-api-cfn openstack-heat-engine python-heatclient && \
#yum install -y --setopt=tsflags=nodocs openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification openstack-ceilometer-central openstack-ceilometer-alarm python-ceilometerclient && \
#yum -y update && \
#yum -y upgrade && \
#yum clean all

# Environment
ENV HOSTIP 192.168.56.101
ENV HOSTNAME base
ENV PASSWORD cisco123

RUN yum install -y python-openstackclient

# Volume Link
VOLUME ["/var/lib/mysql", "/root/ciscokr"]

# Port Open
EXPOSE 80 3306 5672 15672 4369 5000 11211 25672 35357

# Start Services
ENTRYPOINT ["/root/ciscokr/start.sh"]
