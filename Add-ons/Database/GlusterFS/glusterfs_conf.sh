#!/bin/bash

# description
# setup a database replication by using GlusterFS for Zabbix 6 and greater

# sources
# https://docs.gluster.org/en/v3
# https://www.digitalocean.com/community/tutorials/how-to-create-a-redundant-storage-pool-using-glusterfs-on-ubuntu-20-04

#-----------------------#
#       Variables       #
#-----------------------#

NODE1=""
NODE2=""
DEFAULT_MOUNTPOINT="/data/glusterfs"
VOLUME=""

#-----------------------#
#	Functions	#
#-----------------------#

ConfirmChoice ()
{
	ConfYorN="";
	while [ "${ConfYorN}" != "y" ] && [ "${ConfYorN}" != "Y" ] && [ "${ConfYorN}" != "n" ] && [ "${ConfYorN}" != "N" ]
	do
		echo -n "$1" "(y/n) : "
		read ConfYorN
	done
	[ "${ConfYorN}" == "y" ] || [ "${ConfYorN}" == "Y" ] && return 0 || return 1
}

#-----------------#
#      Start      #
#-----------------#

grep -q $NODE1 /etc/hosts && grep -q $NODE2 /etc/hosts ; echo $?
if	[ $? -eq 1 ] ; then
	echo 'Configure /etc/hosts by adding your cluster nodes'
	exit 2
fi

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install glusterfs-server -y ; sudo systemctl enable --now glusterd

ConfirmChoice "Are you configuring the primary node ?" && \
gluster peer probe $NODE2 ; gluster peer status ; sleep 3

ConfirmChoice "Create default mountpoint ($DEFAULT_MOUNTPOINT) ?" && mkdir -p $DEFAULT_MOUNTPOINT || \
read -p 'Enter mountpoint path ' DEFAULT_MOUNTPOINT
mkdir -p $DEFAULT_MOUNTPOINT

ConfirmChoice "Are you configuring the primary node ?" && \
gluster volume create $VOLUME replica 2 $NODE1:/$DEFAULT_MOUNTPOINT $NODE2:/$DEFAULT_MOUNTPOINT \
echo "Starting volume $VOLUME" \
gluster volume start $VOLUME

# Create replication point
read -p 'Enter replication path ' REPLICATION
mkdir -p $REPLICATION

# Auto mount
ConfirmChoice "Are you configuring the primary node ?" && \
echo "$NODE2:/$VOLUME $REPLICATION glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
echo "$NODE1:/$VOLUME $REPLICATION glusterfs defaults,_netdev 0 0" | sudo tee -a /etc/fstab
