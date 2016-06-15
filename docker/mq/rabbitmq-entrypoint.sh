#!/bin/bash

if [ ! -f /.run-rabbitmq-server-firstrun ]; then
	cat >/etc/rabbitmq/rabbitmq.config <<EOF
[ {rabbit, [{default_user, <<"admin">>}, {default_pass, <<"$PASSWORD">>}]} ].
EOF

	echo "set default user = admin and default password = $PASSWORD"

	(sleep 10 && rabbitmqctl add_user openstack $PASSWORD && rabbitmqctl set_permissions openstack ".*" ".*" ".*") &

	touch /.run-rabbitmq-server-firstrun
fi

exec /usr/sbin/rabbitmq-server
