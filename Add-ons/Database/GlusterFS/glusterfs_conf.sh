#!/bin/bash

# description
# setup a database replication by using GlusterFS for Zabbix 6 and greater

# note
# /!\ script needs to be run on each node at the same time /!\

# sources
# https://docs.gluster.org/en/v3
# https://www.digitalocean.com/community/tutorials/how-to-create-a-redundant-storage-pool-using-glusterfs-on-ubuntu-20-04

#-----------------------#
#       Variables       #
#-----------------------#

NODE1=""
NODE2=""
MOUNTPOINT=""
REPLICATION=""
VOLUME=""

#-----------------------#
#       Functions       #
#-----------------------#

ConfirmChoice ()
{
        ConfYorN="";
        while [ "${ConfYorN}" != "y" ] && [ "${ConfYorN}" != "Y" ] && [ "${ConfYorN}" != "n" ] && [ "${ConfYorN}" != "N" ]
        do
                echo -n "$1" "(y/n) : "
                read -r ConfYorN
        done
        [ "${ConfYorN}" == "y" ] || [ "${ConfYorN}" == "Y" ] && return 0 || return 1
}

check_vars ()
{
	var_names=("$@")
	for var_name in "${var_names[@]}"; do
		[ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
	done
		[ -n "$var_unset" ] && exit 1
	return 0
}

#-----------------#
#      Start      #
#-----------------#

check_vars NODE1 NODE2 MOUNTPOINT REPLICATION VOLUME

ConfirmChoice "Configure $NODE1 (primary node) ?" &&
{
	grep -q "$NODE1" /etc/hosts && grep -q "$NODE2" /etc/hosts
	if      [ $? -eq 1 ] ; then
		echo 'Opening /etc/hosts to add the nodes of your cluster'
		vi /etc/hosts
	fi

	if !    [ "$(hostname)" = "$NODE1" ] ; then
		echo 'Configuring hostname ...'
		sudo hostnamectl set-hostname "$NODE1"
		loginctl terminate-user "$(who | awk '{print $1}')"
	fi

	echo 'Installing GlusterFS ... ' ; sleep 2
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install glusterfs-server -y ; sudo systemctl enable --now glusterd

	ConfirmChoice "GlusterFS must be installed on each cluster's node, continue ?" && \
	gluster peer probe "$NODE2" ; sleep 2

	ConfirmChoice "Create mountpoint : $MOUNTPOINT ?" && mkdir -p "$MOUNTPOINT"

	ConfirmChoice "$MOUNTPOINT must be created on each cluster's node, continue ?" && \
	gluster volume create "$VOLUME" replica 2 transport tcp "$NODE1":/"$MOUNTPOINT" "$NODE2":/"$MOUNTPOINT" && \
	echo "Starting volume $VOLUME ..." ; sleep 2 && \
	gluster volume start "$VOLUME"

	ConfirmChoice "Create replication point : $REPLICATION ?" && mkdir -p "$REPLICATION"

	# Auto mount
	ConfirmChoice "Mount all ?" && \
	echo "$NODE2:/$VOLUME $REPLICATION glusterfs defaults,_netdev 0 2" | sudo tee -a /etc/fstab && mount -a
}

ConfirmChoice "Configure $NODE2 ?" &&
{
	grep -q "$NODE1" /etc/hosts && grep -q "$NODE2" /etc/hosts
	if      [ $? -eq 1 ] ; then
		echo 'Opening /etc/hosts to add the nodes of your cluster'
		sudo vi /etc/hosts
	fi

	if !    [ "$(hostname)" = "$NODE2" ] ; then
		echo 'Configuring hostname ...'
		sudo hostnamectl set-hostname "$NODE2"
		loginctl terminate-user "$(who | awk '{print $1}')"
	fi

	echo 'Installing GlusterFS ... ' ; sleep 2
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install glusterfs-server -y ; sudo systemctl enable --now glusterd

	ConfirmChoice "Create mountpoint : $MOUNTPOINT ?" && mkdir -p "$MOUNTPOINT"
	ConfirmChoice "Create replication point : $REPLICATION ?" && mkdir -p "$REPLICATION"

	# Auto mount
	ConfirmChoice "Mount all ?" && \
	echo "$NODE1:/$VOLUME $REPLICATION glusterfs defaults,_netdev 0 2" | sudo tee -a /etc/fstab && mount -a
}
