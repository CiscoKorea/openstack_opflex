#!/bin/bash

echo "START RUN LEVEL 5"

$_BIN/run_glance.sh &
$_BIN/run_nova.sh &
$_BIN/run_neutron.sh &
#$_BIN/run_cinder.sh &
#$_BIN/run_swift.sh &
#$_BIN/run_heat.sh &
#$_BIN/run_ceilometer.sh &