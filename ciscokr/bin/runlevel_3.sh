#!/bin/bash

echo "START RUN LEVEL 3"

CB=/root/ciscokr/bin
CF=/root/ciscokr/files

$CB/run_memcached.sh
$CB/run_httpd.sh