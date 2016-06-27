#!/bin/bash

exec /usr/sbin/apachectl -DFOREGROUND >> /tmp/httpd.log &
