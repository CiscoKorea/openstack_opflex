FROM ciscokr/openstack_base
MAINTAINER Openstack Liberty <hyjang@cisco.com>

# Environment
ENV HOSTIP 127.0.0.1
ENV HOSTNAME base
ENV PASSWORD cisco123

# Volume Link
VOLUME ["/var/lib/mysql" "/root/ciscokr"]

# Port Open
EXPOSE 80 3306 5672 15672 4369 5000 11211 25672 35357

# Start Services
ENTRYPOINT ["/root/ciscokr/start.sh"]
