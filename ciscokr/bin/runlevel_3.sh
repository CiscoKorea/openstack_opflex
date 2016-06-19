#!/bin/bash

echo "START RUN LEVEL 3"
CB=/root/ciscokr/bin

$CB/run_memcached.sh
$CB/run_httpd.sh