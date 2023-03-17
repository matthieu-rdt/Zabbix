#!/bin/bash

# description
# setup a database replication by using GlusterFS for Zabbix 6 and greater

# sources
# https://docs.gluster.org/en/v3
# https://www.digitalocean.com/community/tutorials/how-to-create-a-redundant-storage-pool-using-glusterfs-on-ubuntu-20-04

#-----------------------#
#       Variables       #
#-----------------------#



#-----------------------#
#	Functions	#
#-----------------------#



#-----------------#
#      Start      #
#-----------------#

grep -q "`hostname`" /etc/hosts && grep -q "$NODE2" /etc/hosts ; echo $?

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install glusterfs-server -y ; systemctl enable --now glusterd

gluster peer probe $NODE2

gluster peer status ; sleep 5

mkdir $
