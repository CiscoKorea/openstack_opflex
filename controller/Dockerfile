FROM ciscokr/openstack_base
MAINTAINER Openstack Liberty <hyjang@cisco.com>

# Volume Link
VOLUME ["/var/lib/mysql", "/root/ciscokr", "/root/conf"]

# Port Open
EXPOSE 80 3306 5672 15672 4369 5000 8774 9292 9696 11211 25672 35357

# Start Services
ENTRYPOINT ["/root/ciscokr/init.sh"]
