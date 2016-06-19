FROM ciscokr/openstack_base
MAINTAINER Openstack Liberty <hyjang@cisco.com>

# Environment
ENV HOSTIP 192.168.56.101
ENV HOSTNAME base
ENV PASSWORD cisco123
ENV APICMODE gbp

# Volume Link
VOLUME ["/var/lib/mysql", "/root/ciscokr"]

# Port Open
EXPOSE 80 3306 5672 15672 4369 5000 11211 25672 35357

# Start Services
ENTRYPOINT ["/root/ciscokr/start.sh"]
