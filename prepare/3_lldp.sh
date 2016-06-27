#!/bin/bash


cd /etc/yum.repos.d/
yum install wget 
wget http://download.opensuse.org/repositories/home:vbernat/RHEL_7/home:vbernat.repo 
yum install lldpd
systemctl enable lldpd
systemctl start lldpd

lldpctl