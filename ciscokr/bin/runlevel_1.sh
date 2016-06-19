#!/bin/bash

echo "START RUN LEVEL 1"
CB=/root/ciscokr/bin

$CB/run_mariadb.sh
$CB/run_rabbitmq.sh