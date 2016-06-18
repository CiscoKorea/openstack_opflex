#!/bin/bash

CB=/root/ciscokr/bin
CF=/root/ciscokr/files

# Mysql
$CB/do_permissions.sh /var/lib/mysql/
$CB/do_permissions.sh /var/log/mariadb/
cp $CB/run_mariadb_sudo.sh /var/lib/mysql/
chown mysql /var/lib/mysql/run_mariadb_sudo.sh
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/my.cnf.d/client.cnf

# Rabbit MQ
cat >/etc/rabbitmq/rabbitmq.config <<EOF
[ {rabbit, [{default_user, <<"admin">>}, {default_pass, <<"$PASSWORD">>}]} ].
EOF
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management >> /root/rabbit.log

# HTTPD
sed -i "s/#ServerName www.example.com:80/ServerName $HOSTNAME/g" 			/etc/httpd/conf/httpd.conf
sed -i "s/Listen 80/Listen 0.0.0.0:80/g" 									/etc/httpd/conf/httpd.conf

# Keystone
sed -i "s/ADMIN_TOKEN/$PASSWORD/"											/etc/keystone/keystone.conf
sed -i "s/PASSWORD/$PASSWORD/" 												/etc/keystone/keystone.conf
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/keystone/keystone.conf

# Horizon
sed -i "s/OPENSTACK_HOST = \"HOSTIP\"/OPENSTACK_HOST = \"$HOSTIP\"/g" 		/etc/openstack-dashboard/local_settings

# Glance
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/glance/glance-api.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/glance/glance-api.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/glance/glance-registry.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/glance/glance-registry.conf

# Nova
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/nova/nova.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/nova/nova.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/nova/nova.conf

# Neutron
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/neutron/neutron.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/neutron/neutron.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/neutron.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/neutron/metadata_agent.ini
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/metadata_agent.ini
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/plugins/ml2/ml2_conf.ini
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
