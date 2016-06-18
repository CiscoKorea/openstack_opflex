#!/bin/bash

echo "START RUN LEVEL 5"

CB=/root/ciscokr/bin
CF=/root/ciscokr/files

sudo -u glance -E -s /usr/bin/glance-api &
sudo -u glance -E -s /usr/bin/glance-registry &

#exec /usr/bin/nova-api &
#exec /usr/bin/nova-cert &
#exec /usr/bin/nova-consoleauth &
#exec /usr/bin/nova-scheduler &
#exec /usr/bin/nova-conductor &
#exec /usr/bin/nova-novncproxy --web /usr/share/novnc/ $OPTIONS &