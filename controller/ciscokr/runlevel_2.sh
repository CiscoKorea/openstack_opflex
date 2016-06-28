#!/bin/bash

echo "START RUN LEVEL 2"

if [ ! -f /.rabbit_registered ]; then

	# Create Rabbit User
	rabbitmqctl add_user openstack $CTRL_PASS >> /tmp/running.log
	rabbitmqctl set_permissions openstack ".*" ".*" ".*" >> /tmp/running.log
	
	# Touch !
	touch /.rabbit_registered
fi