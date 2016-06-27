#!/bin/bash

sudo -u nova -E -s /usr/bin/nova-api >> /tmp/nova-api.log &
sudo -u nova -E -s /usr/bin/nova-cert >> /tmp/nova-cert.log &
sudo -u nova -E -s /usr/bin/nova-consoleauth >> /tmp/nova-consoleauth.log &
sudo -u nova -E -s /usr/bin/nova-scheduler >> /tmp/nova-scheduler.log &
sudo -u nova -E -s /usr/bin/nova-conductor >> /tmp/nova-conductor.log &
sudo -u nova -E -s /usr/bin/nova-novncproxy --web /usr/share/novnc/ &