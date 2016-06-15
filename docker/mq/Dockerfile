FROM centos:7

MAINTAINER Cisco Korea Solution SE Openstack Liberty <hyjang@cisco.com>

RUN yum -y install --setopt=tsflags=nodocs epel-release && \
    yum -y install --setopt=tsflags=nodocs pwgen wget logrotate rabbitmq-server && \
    yum -y update && yum clean all

RUN /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management

COPY rabbitmq-entrypoint.sh /
RUN chmod 755 /rabbitmq-entrypoint.sh

EXPOSE 5672 15672 4369 25672
ENV PASSWORD cisco123

ENTRYPOINT ["/rabbitmq-entrypoint.sh"]
