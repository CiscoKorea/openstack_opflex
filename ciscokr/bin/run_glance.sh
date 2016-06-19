#!/bin/bash

sudo -u glance -E -s /usr/bin/glance-api &
sudo -u glance -E -s /usr/bin/glance-registry &

