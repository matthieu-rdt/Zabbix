#!/bin/bash

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
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

configure_new_disk ()
{
	# Get the new disk name
	lsblk ; sleep 3

	read -p "choose the block device you want to use for DB ? " block

	sudo cfdisk /dev/$block

	# '1' because cfdisk created 1 partition
	sudo mkfs.ext4 /dev/$block'1'

	[ ! -d $DBfolder ] && sudo mkdir -p $DBfolder

	# Get UUID
	blkid=`sudo blkid | grep $block | awk '{ print $2 }'`

	# FSTAB
	echo "# Database is on /dev/$block" | sudo tee -a /etc/fstab
	echo "$blkid $DBfolder ext4 defaults	0	2" | sudo tee -a /etc/fstab
	sudo mount -a
}

fine_tuning ()
{
#	If you have this kind of message : [Warning] Aborted connection 423 to db: 'zabbix' user: 'zabbix' host: 'localhost' (Got timeout reading communication packets)
	sudo sed -i 's/#max_allowed_packet/max_allowed_packet' /etc/mysql/mariadb.conf.d/50-server.cnf
}

#-------------------#
#	Start	    #
#-------------------#

sudo mysql -uroot -e "select @@datadir;"

read -p "Copy paste the current DB path : " currentDB
read -p "Write the folder to be used for DB ? (without '/' at the end) " DBfolder

echo "Stop MariaDB service" ; sleep 3
sudo systemctl stop mariadb.service

ConfirmChoice "Do you have a new disk to configure (new partition table, new filesystem, edit fstab) ?" && configure_new_disk 

sudo rsync -av $currentDB $DBfolder

# Change DB path
sudo cp -p /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnff
sudo sed -i "s|$currentDB|$DBfolder/mysql|" /etc/mysql/mariadb.conf.d/50-server.cnf

# Uncomment if needed
#fine_tuning

echo "Start MariaDB service" ; sleep 3
sudo systemctl start mariadb.service

# Check the new location is effective
sudo mysql -uroot -e "select @@datadir;"

echo "Do not forget to EDIT /etc/fstab accordingly" ; sleep 5
