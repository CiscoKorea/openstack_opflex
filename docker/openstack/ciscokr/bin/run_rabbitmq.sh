#!/bin/bash

if [ ! -f /.prepared_rabbit ]; then
	cat >/etc/rabbitmq/rabbitmq.config <<EOF
[ {rabbit, [{default_user, <<"admin">>}, {default_pass, <<"$PASSWORD">>}]} ].
EOF
	(sleep 10 && rabbitmqctl add_user openstack $PASSWORD && rabbitmqctl set_permissions openstack ".*" ".*" ".*") &
	touch /.prepared_rabbit
fi

exec /usr/sbin/rabbitmq-server &


