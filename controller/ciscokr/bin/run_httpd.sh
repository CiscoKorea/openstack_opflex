#!/bin/bash

mkdir -p /var/www/html/opflex
cp $_PKG/* /var/www/html/opflex
createrepo /var/www/html/opflex
chown –R apache:apache /var/www/html/opflex

exec /usr/sbin/apachectl -DFOREGROUND >> /root/httpd.log &

