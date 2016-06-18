#!/bin/bash

if [ ! -f /.rabbit_registered ]; then

	# Create Rabbit User
	rabbitmqctl add_user openstack $PASSWORD
	rabbitmqctl set_permissions openstack ".*" ".*" ".*"
	
	# Touch !
	touch /.rabbit_registered
fi