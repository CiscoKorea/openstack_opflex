#!/bin/bash

echo "Setting!!!"

# Mysql #################################################################################
echo "Mysql"

$_BIN/do_permissions.sh /var/lib/mysql/
$_BIN/do_permissions.sh /var/log/mariadb/
cp $_BIN/run_mariadb_sudo.sh /var/lib/mysql/
chown mysql /var/lib/mysql/run_mariadb_sudo.sh

cat << EOF > /etc/my.cnf.d/mariadb_openstack.cnf
[mysqld]
bind-address = 0.0.0.0
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8
EOF
echo "/etc/my.cnf.d/mariadb_openstack.cnf"
cat /etc/my.cnf.d/mariadb_openstack.cnf
echo ""

cat << EOF > /etc/my.cnf.d/client.cnf
[client]
user=root
password=$CTRL_PASS
[client-mariadb]
EOF
echo "/etc/my.cnf.d/client.cnf"
cat /etc/my.cnf.d/client.cnf | grep -v "#" | grep -i "\W"
echo ""

# Rabbit MQ #################################################################################
echo "RabbitMQ"

cat >/etc/rabbitmq/rabbitmq.config << EOF
[ {rabbit, [{default_user, <<"admin">>}, {default_pass, <<"$CTRL_PASS">>}]} ].
EOF
echo "/etc/rabbitmq/rabbitmq.config"
cat /etc/rabbitmq/rabbitmq.config | grep -v "#" | grep -i "\W"
echo ""

/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management >> /tmp/rabbit.log

# HTTPD #################################################################################
echo "HTTP"

cat << EOF > /etc/httpd/conf/httpd.conf
ServerRoot "/etc/httpd"
ServerName $CTRL_NAME
Listen 0.0.0.0:80
Include conf.modules.d/*.conf
User apache
Group apache
ServerAdmin root@localhost
<Directory />
    AllowOverride none
    Require all denied
</Directory>
DocumentRoot "/var/www/html"
<Directory "/var/www">
    AllowOverride None
    Require all granted
</Directory>
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" combined
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>
<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule mime_module>
    TypesConfig /etc/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType text/html .shtml
    AddOutputFilter INCLUDES .shtml
</IfModule>
AddDefaultCharset UTF-8
<IfModule mime_magic_module>
    MIMEMagicFile conf/magic
</IfModule>
EnableSendfile on
IncludeOptional conf.d/*.conf
EOF
echo "/etc/httpd/conf/httpd.conf"
cat /etc/httpd/conf/httpd.conf | grep -v "#" | grep -i "\W"
echo ""

# YUM.REPOS.D #################################################################################
#echo "Yum"
#
#cat << EOF > /etc/yum.repos.d/opflex.repo
#[opflex]
#name=opflex repo
#baseurl=http://$CTRL_IP/opflex
#failovermethod=priority
#enabled=1
#gpgcheck=0
#EOF
#echo "/etc/yum.repos.d/opflex.repo"
#cat /etc/yum.repos.d/opflex.repo | grep -v "#" | grep -i "\W"
#echo ""

# Keystone #################################################################################
echo "Keystone"

cat << EOF > /etc/keystone/keystone.conf
[DEFAULT]
admin_token = $CTRL_PASS
verbose = True
[database]
connection = mysql://keystone:$CTRL_PASS@$CTRL_IP/keystone
[memcache]
servers = localhost:11211
[token]
provider = uuid
driver = memcache
[revoke]
driver = sql
EOF
echo "/etc/keystone/keystone.conf"
cat /etc/keystone/keystone.conf | grep -v "#" | grep -i "\W"
echo ""

# Horizon #################################################################################
echo "Horizon"

cat << EOF > /etc/openstack-dashboard/local_settings
import os
from django.utils.translation import ugettext_lazy as _
from openstack_dashboard import exceptions
from openstack_dashboard.settings import HORIZON_CONFIG
DEBUG = False
TEMPLATE_DEBUG = DEBUG
WEBROOT = '/dashboard/'
ALLOWED_HOSTS = ['*',]
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "volume": 2,
}
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
LOCAL_PATH = '/tmp'
SECRET_KEY='2244df4676587cddc918'
CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': '127.0.0.1:11211',
    }
}
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
OPENSTACK_HOST = "$CTRL_IP"
OPENSTACK_KEYSTONE_URL = "http://%s:5000/v2.0" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
OPENSTACK_KEYSTONE_BACKEND = {
    'name': 'native',
    'can_edit_user': True,
    'can_edit_group': True,
    'can_edit_project': True,
    'can_edit_domain': True,
    'can_edit_role': True,
}
OPENSTACK_HYPERVISOR_FEATURES = {
    'can_set_mount_point': False,
    'can_set_password': False,
    'requires_keypair': False,
}
OPENSTACK_CINDER_FEATURES = {
    'enable_backup': False,
}
OPENSTACK_NEUTRON_NETWORK = {
    'enable_router': True,
    'enable_quotas': True,
    'enable_ipv6': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': True,
    'enable_firewall': True,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
    'default_ipv4_subnet_pool_label': None,
    'default_ipv6_subnet_pool_label': None,
    'profile_support': None,
    'supported_provider_types': ['*'],
    'supported_vnic_types': ['*']
}
IMAGE_CUSTOM_PROPERTY_TITLES = {
    "architecture": _("Architecture"),
    "kernel_id": _("Kernel ID"),
    "ramdisk_id": _("Ramdisk ID"),
    "image_state": _("Euca2ools state"),
    "project_id": _("Project ID"),
    "image_type": _("Image Type"),
}
IMAGE_RESERVED_CUSTOM_PROPERTIES = []
API_RESULT_LIMIT = 1000
API_RESULT_PAGE_SIZE = 20
SWIFT_FILE_TRANSFER_CHUNK_SIZE = 512 * 1024
DROPDOWN_MAX_ITEMS = 30
TIME_ZONE = "UTC"
POLICY_FILES_PATH = '/etc/openstack-dashboard'
POLICY_FILES_PATH = '/etc/openstack-dashboard'
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'null': {
            'level': 'DEBUG',
            'class': 'django.utils.log.NullHandler',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['null'],
            'propagate': False,
        },
        'requests': {
            'handlers': ['null'],
            'propagate': False,
        },
        'horizon': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_dashboard': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'novaclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'cinderclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'keystoneclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'glanceclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'neutronclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'heatclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'ceilometerclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'troveclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'swiftclient': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'openstack_auth': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'nose.plugins.manager': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
        'iso8601': {
            'handlers': ['null'],
            'propagate': False,
        },
        'scss': {
            'handlers': ['null'],
            'propagate': False,
        },
    }
}
SECURITY_GROUP_RULES = {
    'all_tcp': {
        'name': _('All TCP'),
        'ip_protocol': 'tcp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_udp': {
        'name': _('All UDP'),
        'ip_protocol': 'udp',
        'from_port': '1',
        'to_port': '65535',
    },
    'all_icmp': {
        'name': _('All ICMP'),
        'ip_protocol': 'icmp',
        'from_port': '-1',
        'to_port': '-1',
    },
    'ssh': {
        'name': 'SSH',
        'ip_protocol': 'tcp',
        'from_port': '22',
        'to_port': '22',
    },
    'smtp': {
        'name': 'SMTP',
        'ip_protocol': 'tcp',
        'from_port': '25',
        'to_port': '25',
    },
    'dns': {
        'name': 'DNS',
        'ip_protocol': 'tcp',
        'from_port': '53',
        'to_port': '53',
    },
    'http': {
        'name': 'HTTP',
        'ip_protocol': 'tcp',
        'from_port': '80',
        'to_port': '80',
    },
    'pop3': {
        'name': 'POP3',
        'ip_protocol': 'tcp',
        'from_port': '110',
        'to_port': '110',
    },
    'imap': {
        'name': 'IMAP',
        'ip_protocol': 'tcp',
        'from_port': '143',
        'to_port': '143',
    },
    'ldap': {
        'name': 'LDAP',
        'ip_protocol': 'tcp',
        'from_port': '389',
        'to_port': '389',
    },
    'https': {
        'name': 'HTTPS',
        'ip_protocol': 'tcp',
        'from_port': '443',
        'to_port': '443',
    },
    'smtps': {
        'name': 'SMTPS',
        'ip_protocol': 'tcp',
        'from_port': '465',
        'to_port': '465',
    },
    'imaps': {
        'name': 'IMAPS',
        'ip_protocol': 'tcp',
        'from_port': '993',
        'to_port': '993',
    },
    'pop3s': {
        'name': 'POP3S',
        'ip_protocol': 'tcp',
        'from_port': '995',
        'to_port': '995',
    },
    'ms_sql': {
        'name': 'MS SQL',
        'ip_protocol': 'tcp',
        'from_port': '1433',
        'to_port': '1433',
    },
    'mysql': {
        'name': 'MYSQL',
        'ip_protocol': 'tcp',
        'from_port': '3306',
        'to_port': '3306',
    },
    'rdp': {
        'name': 'RDP',
        'ip_protocol': 'tcp',
        'from_port': '3389',
        'to_port': '3389',
    },
}
REST_API_REQUIRED_SETTINGS = ['OPENSTACK_HYPERVISOR_FEATURES']
EOF
echo "/etc/openstack-dashboard/local_settings"
cat /etc/openstack-dashboard/local_settings | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/httpd/conf.d/wsgi-keystone.conf
Listen 0.0.0.0:5000
Listen 0.0.0.0:35357
<VirtualHost *:5000>
    WSGIDaemonProcess keystone-public processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-public
    WSGIScriptAlias / /usr/bin/keystone-wsgi-public
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>
<VirtualHost *:35357>
    WSGIDaemonProcess keystone-admin processes=5 threads=1 user=keystone group=keystone display-name=%{GROUP}
    WSGIProcessGroup keystone-admin
    WSGIScriptAlias / /usr/bin/keystone-wsgi-admin
    WSGIApplicationGroup %{GLOBAL}
    WSGIPassAuthorization On
    <IfVersion >= 2.4>
      ErrorLogFormat "%{cu}t %M"
    </IfVersion>
    ErrorLog /var/log/httpd/keystone-error.log
    CustomLog /var/log/httpd/keystone-access.log combined

    <Directory /usr/bin>
        <IfVersion >= 2.4>
            Require all granted
        </IfVersion>
        <IfVersion < 2.4>
            Order allow,deny
            Allow from all
        </IfVersion>
    </Directory>
</VirtualHost>
EOF
echo "/etc/httpd/conf.d/wsgi-keystone.conf"
cat /etc/httpd/conf.d/wsgi-keystone.conf | grep -v "#" | grep -i "\W"
echo ""

# Glance #################################################################################
echo "Glance"

cat << EOF > /etc/glance/glance-api.conf
[DEFAULT]
notification_driver = noop
verbose = True
[database]
connection = mysql://glance:$CTRL_PASS@$CTRL_IP/glance
[keystone_authtoken]
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = $CTRL_PASS
[paste_deploy]
flavor = keystone
[glance_store]
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
EOF
echo "/etc/glance/glance-api.conf"
cat /etc/glance/glance-api.conf | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/glance/glance-registry.conf
[DEFAULT]
notification_driver = noop
verbose = True
[database]
connection = mysql://glance:$CTRL_PASS@$CTRL_IP/glance
[keystone_authtoken]
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = glance
password = $CTRL_PASS
[paste_deploy]
flavor = keystone
EOF
echo "/etc/glance/glance-registry.conf"
cat /etc/glance/glance-registry.conf | grep -v "#" | grep -i "\W"
echo ""

# Nova #################################################################################
echo "Nova"

cat << EOF > /etc/nova/nova.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
my_ip = $CTRL_IP
vncserver_listen = $CTRL_IP
vncserver_proxyclient_address = $CTRL_IP
verbose = True
network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
enabled_apis = osapi_compute,metadata
[database]
connection = mysql://nova:$CTRL_PASS@$CTRL_IP/nova
[oslo_messaging_rabbit]
rabbit_host = $CTRL_IP
rabbit_userid = openstack
rabbit_password = $CTRL_PASS
[keystone_authtoken]
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = $CTRL_PASS
[glance]
host = $HOSTIP
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[neutron]
url = http://$CTRL_IP:9696
auth_strategy = keystone
admin_auth_url = http://$CTRL_IP:35357/v2.0
admin_tenant_name = service
admin_username = neutron
admin_password = $CTRL_PASS
service_metadata_proxy = True
metadata_proxy_shared_secret = $CTRL_PASS
EOF
echo "/etc/nova/nova.conf"
cat /etc/nova/nova.conf | grep -v "#" | grep -i "\W"
echo ""

# Neutron #################################################################################
echo "Neutron"

cat << EOF > /etc/neutron/neutron.conf
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
core_plugin = ml2
service_plugins = $APIC_PLUGINS
allow_overlapping_ips = True
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
nova_url = http://$CTRL_IP:8774/v2
verbose = True
[database]
connection = mysql://neutron:$CTRL_PASS@$CTRL_IP/neutron
[oslo_messaging_rabbit]
rabbit_host = $CTRL_IP
rabbit_userid = openstack
rabbit_password = $CTRL_PASS
[keystone_authtoken]
admin_tenant_name = %SERVICE_TENANT_NAME%
admin_user = %SERVICE_USER%
admin_password = %SERVICE_PASSWORD%
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $CTRL_PASS
[nova]
auth_url = http://$CTRL_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
region_name = RegionOne
project_name = service
username = nova
password = $CTRL_PASS
EOF
echo "/etc/neutron/neutron.conf"
cat /etc/neutron/neutron.conf | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/neutron/metadata_agent.ini
[DEFAULT]
admin_tenant_name = %SERVICE_TENANT_NAME%
admin_user = %SERVICE_USER%
admin_password = %SERVICE_PASSWORD%
auth_uri = http://$CTRL_IP:5000
auth_url = http://$CTRL_IP:35357
auth_region = RegionOne
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $CTRL_PASS
nova_metadata_ip = $CTRL_IP
metadata_proxy_shared_secret = $CTRL_PASS
verbose = True
EOF
echo "/etc/neutron/metadata_agent.ini"
cat /etc/neutron/metadata_agent.ini | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/neutron/dhcp_agent.ini
[DEFAULT]
dhcp_driver = apic_ml2.neutron.agent.linux.apic_dhcp.ApicDnsmasq
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
ovs_integration_bridge = br-int
enable_isolated_metadata = True
verbose = True
EOF
echo "/etc/neutron/dhcp_agent.ini"
cat /etc/neutron/dhcp_agent.ini | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = opflex,flat,vlan,gre,vxlan
tenant_network_types = opflex
mechanism_drivers = $APIC_DRIVER
[ml2_type_vlan]
network_vlan_ranges = physnet1:2000:2100
bridge_mappings = physnet1:br-int
[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
[ovs]
local_ip = $CTRL_IP
EOF
echo "/etc/neutron/plugins/ml2/ml2_conf.ini"
cat /etc/neutron/plugins/ml2/ml2_conf.ini | grep -v "#" | grep -i "\W"
echo ""

cat << EOF > /etc/neutron/plugins/ml2/openvswitch_agent.ini
[ovs]
enable_tunneling = False
integration_bridge = br-int
[agent]
[securitygroup]
EOF
echo "/etc/neutron/plugins/ml2/openvswitch_agent.ini"
cat /etc/neutron/plugins/ml2/openvswitch_agent.ini | grep -v "#" | grep -i "\W"
echo ""

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

# Heat #################################################################################
echo "Heat"

if [ "$APIC_MODE" == "gbp" ]; then
	openstack-config --set /etc/heat/heat.conf DEFAULT plugin_dirs /usr/lib/python2.7/site-packages/gbpautomation/heat
fi

echo "/etc/heat/heat.conf"
cat /etc/heat/heat.conf | grep -v "#" | grep -i "\W"
echo ""
