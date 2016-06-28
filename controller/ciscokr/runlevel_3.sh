#!/bin/bash

echo "START RUN LEVEL 3"

echo "Start Memcached"
$_BIN/run_memcached.sh
echo "Start Httpd"
$_BIN/run_httpd.sh