FROM centos:7

MAINTAINER Cisco Korea Solution SE Openstack Liberty <hyjang@cisco.com>

RUN yum -y install --setopt=tsflags=nodocs epel-release && \ 
    yum -y install --setopt=tsflags=nodocs mariadb-server bind-utils pwgen psmisc hostname && \ 
    yum -y update && yum clean all

USER 27
VOLUME /var/lib/mysql
EXPOSE 3306

ENV PASSWORD cisco123

COPY fix-permissions.sh /
RUN chmod 755 /fix-permission.sh
RUN /fix-permissions.sh /var/lib/mysql/   && \
    /fix-permissions.sh /var/log/mariadb/ && \
    /fix-permissions.sh /var/run/

COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
COPY mariadb_openstack.cnf /etc/my.cnf.d/

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mysqld_safe"]
