#!/bin/bash

echo "Setting!!!"

# Mysql
echo "Mysql"
$_BIN/do_permissions.sh /var/lib/mysql/
$_BIN/do_permissions.sh /var/log/mariadb/
cp $_BIN/run_mariadb_sudo.sh /var/lib/mysql/
chown mysql /var/lib/mysql/run_mariadb_sudo.sh
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/my.cnf.d/client.cnf

# Rabbit MQ
echo "RabbitMQ"
cat >/etc/rabbitmq/rabbitmq.config <<EOF
[ {rabbit, [{default_user, <<"admin">>}, {default_pass, <<"$PASSWORD">>}]} ].
EOF
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management >> /root/rabbit.log

# HTTPD
echo "HTTP"
sed -i "s/#ServerName www.example.com:80/ServerName $HOSTNAME/g" 			/etc/httpd/conf/httpd.conf
sed -i "s/Listen 80/Listen 0.0.0.0:80/g" 									/etc/httpd/conf/httpd.conf

# YUM.REPOS.D
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/yum.repos.d/opflex.repo

# Keystone
echo "Keystone"
sed -i "s/ADMIN_TOKEN/$PASSWORD/"											/etc/keystone/keystone.conf
sed -i "s/PASSWORD/$PASSWORD/" 												/etc/keystone/keystone.conf
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/keystone/keystone.conf

# Horizon
echo "Horizon"
sed -i "s/OPENSTACK_HOST = \"HOSTIP\"/OPENSTACK_HOST = \"$HOSTIP\"/g" 		/etc/openstack-dashboard/local_settings

# Glance
echo "Glance"
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/glance/glance-api.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/glance/glance-api.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/glance/glance-registry.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/glance/glance-registry.conf

# Nova
echo "Nova"
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/nova/nova.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/nova/nova.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/nova/nova.conf

# Neutron
echo "Neutron"
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/neutron/neutron.conf
sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/neutron/neutron.conf
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/neutron.conf
sed -i "s/PASSWD/$PASSWORD/g" 												/etc/neutron/metadata_agent.ini
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/metadata_agent.ini
sed -i "s/HOSTIP/$HOSTIP/g" 												/etc/neutron/plugins/ml2/ml2_conf.ini
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

# Opflex
echo "OpFlex"
sed -i "s/APICID/$APICID/g" /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
sed -i "s/APICHOST/$APICHOST/g" /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
sed -i "s/APICUSER/$APICUSER/g" /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
sed -i "s/APICPASS/$APICPASS/g" /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini

if [ "$APICMODE" == "gbp" ]; then
	echo "Set OpFlex : GBP"
	sed -i "s/SERVICE_PLUGINS/group_policy,servicechain,apic_gbp_l3,metering/g" /etc/neutron/neutron.conf
	sed -i "s/MECHDRIVERS/apic_gbp/g" /etc/neutron/plugins/ml2/ml2_conf.ini
	openstack-config --set /etc/heat/heat.conf DEFAULT plugin_dirs /usr/lib/python2.7/site-packages/gbpautomation/heat
else
	echo "Set OpFlex : APIC_ML2"
	sed -i "s/SERVICE_PLUGINS/cisco_apic_l3,metering,lbaas/g" /etc/neutron/neutron.conf
	sed -i "s/MECHDRIVERS/cisco_apic_ml2/g" /etc/neutron/plugins/ml2/ml2_conf.ini
fi

if [ "$LINKMODE" == "vpc" ]; then
	echo "apic_vpc_pairs = $VPC_PAIR" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
fi

if [ "$APICMODE" == "gbp" ]; then
	echo "[group_policy]" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
	echo "policy_drivers=implicit_policy,apic" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
	echo "[group_policy_implicit_policy]" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
	echo "default_ip_pool=$GBP_POOL" >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini
fi

cat $_CONF/Switch.conf >> /etc/neutron/plugins/ml2/ml2_conf_cisco_apic.ini



