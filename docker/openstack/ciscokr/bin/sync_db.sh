#!/bin/bash

if [ ! -f /.dbsynced ]; then


	(sleep 10 && \
	mysql -e "CREATE DATABASE keystone; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$PASSWORD';" && \
	su -s /bin/sh -c "keystone-manage db_sync" keystone) &
	
	touch /.dbsynced
fi




