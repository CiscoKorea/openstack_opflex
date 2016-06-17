#!/bin/bash

CB=/root/ciscokr/bin
CF=/root/ciscokr/files

# Mysql File Permission
$CB/do_permissions.sh /var/lib/mysql/
$CB/do_permissions.sh /var/log/mariadb/
#$CB/do_permissions.sh /var/run/

sed -i "s/PASSWORD/$PASSWORD/g" 											/etc/my.cnf.d/client.cnf

sed -i "s/#ServerName www.example.com:80/ServerName $HOSTNAME/g" 			/etc/httpd/conf/httpd.conf
sed -i "s/Listen 80/Listen 0.0.0.0:80/g" 									/etc/httpd/conf/httpd.conf

sed -i "s/ADMIN_TOKEN/$PASSWORD/"											/etc/keystone/keystone.conf
sed -i "s/PASSWORD/$PASSWORD/" 												/etc/keystone/keystone.conf
sed -i "s/HOSTNAME/$HOSTNAME/" 												/etc/keystone/keystone.conf

sed -i "s/OPENSTACK_HOST = \"HOSTIP\"/OPENSTACK_HOST = \"$HOSTIP\"/g" 		/etc/openstack-dashboard/local_settings

#sed -i "s/WSGISocketPrefix run\/wsgi/WSGISocketPrefix \/tmp\/wsgi/g" 		/etc/httpd/conf.d/openstack-dashboard.conf