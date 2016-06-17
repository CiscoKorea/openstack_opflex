#!/bin/bash

exec /usr/sbin/apachectl -DFOREGROUND >> /root/httpd.log &
