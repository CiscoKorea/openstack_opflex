#!/bin/bash

echo "START RUN LEVEL 2"

if [ ! -f /.rabbit_registered ]; then

	# Create Rabbit User
	rabbitmqctl add_user openstack $PASSWORD
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"
	
	# Touch !
	touch /.rabbit_registered
fi