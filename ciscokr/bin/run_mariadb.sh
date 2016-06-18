#!/bin/bash

#su -s /bin/sh -c "/var/lib/mysql/run_mariadb_sudo.sh mysqld_safe" mysql &
sudo -u mysql -E -s /run_mariadb_sudo.sh mysqld_safe
