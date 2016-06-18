#!/bin/bash

echo "START RUN LEVEL 1"

CB=/root/ciscokr/bin
CF=/root/ciscokr/files

$CB/run_mariadb.sh
$CB/run_rabbitmq.sh