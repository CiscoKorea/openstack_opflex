
# Openstack Liberty w/ OpFlex on Docker

NOW RUNNING : Keystone, Horizon

1. Create Base Image

-- HOST --  
$ docker pull centos:7  
$ docker run -ti --privileged --net host --name base centos:7 /bin/bash   
-- ON DOCKER IMAGE --   
$ yum install -y --setopt=tsflags=nodocs http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-6.noarch.rpm   
$ yum install -y --setopt=tsflags=nodocs    https://repos.fedorapeople.org/repos/openstack/openstack-liberty/rdo-release-liberty-3.noarch.rpm   
$ yum install -y --setopt=tsflags=nodocs openstack-selinux   
$ yum update -y && yum upgrade -y   
$ yum install -y --setopt=tsflags=nodocs \   
  net-tools wget openstack-utils \  
  mariadb mariadb-server MySQL-python \   
  rabbitmq-server \   
  httpd mod_wsgi memcached \   
  python-openstackclient \   
  openstack-dashboard \   
  openstack-keystone python-memcached \   
  openstack-glance python-glance python-glanceclient \   
  openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console \   
  openstack-nova-novncproxy openstack-nova-scheduler python-novaclient \   
  openstack-neutron openstack-neutron-ml2 python-neutronclient which \   
  openstack-heat-api openstack-heat-api-cfn openstack-heat-engine python-heatclient \   
  openstack-ceilometer-api openstack-ceilometer-collector openstack-ceilometer-notification \   
  openstack-ceilometer-central openstack-ceilometer-alarm python-ceilometerclient   
$ yum clean all   
$ exit   
-- HOST --   
$ docker commit base ciscokr/openstack_base   

2. Git Download

$ cd ~ && pwd   
/root   
   
$ git clone   
-- Edit "HOSTIP", "HOSTNAME", "PASSWORD" environments in Dockerfile --   
$ ./build.sh   
$ ./start.sh   
