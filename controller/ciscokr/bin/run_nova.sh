#!/bin/bash

sudo -u nova -E -s /usr/bin/nova-api &
sudo -u nova -E -s /usr/bin/nova-cert &
sudo -u nova -E -s /usr/bin/nova-consoleauth &
sudo -u nova -E -s /usr/bin/nova-scheduler &
sudo -u nova -E -s /usr/bin/nova-conductor &
sudo -u nova -E -s /usr/bin/nova-novncproxy --web /usr/share/novnc/ &