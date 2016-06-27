#!/bin/bash

sudo -u mysql -E -s /var/lib/mysql/run_mariadb_sudo.sh mysqld_safe >> /tmp/mariadb.log &
