#!/bin/bash

sudo -u glance -E -s /usr/bin/nova-api &
sudo -u glance -E -s /usr/bin/nova-cert &
sudo -u glance -E -s /usr/bin/nova-consoleauth &
sudo -u glance -E -s /usr/bin/nova-scheduler &
sudo -u glance -E -s /usr/bin/nova-conductor &
sudo -u glance -E -s /usr/bin/nova-novncproxy --web /usr/share/novnc/ &