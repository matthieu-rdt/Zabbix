#!/bin/bash

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
function ConfirmChoice ()
{
        ConfYorN="";
                while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ]
                do
                        echo -n $1 "(y/n) : "
                        read ConfYorN
                done
        [ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

function configure_new_disk ()
{
	# Get the new disk name
	lsblk
	sleep 3

	read -p "choose the block device you want to use for DB ? " block

	sudo mkfs.ext4 /dev/$block
	[ ! -d $dbpath ] && sudo mkdir -p $dbpath

	# Get UUID
	blkid=`sudo blkid | grep $block | awk '{ print $2 }'`

	# FSTAB
	echo "# Database is on /dev/$block" | sudo tee -a /etc/fstab
	echo "$blkid $dbpath   ext4    defaults        0       2" | sudo tee -a /etc/fstab
	sudo mount -a
}

function fine_tuning ()
{
#	If you have this kind of message : [Warning] Aborted connection 423 to db: 'zabbix' user: 'zabbix' host: 'localhost' (Got timeout reading communication packets)
	sudo sed -i 's/#max_allowed_packet/max_allowed_packet' /etc/mysql/mariadb.conf.d/50-server.cnf
}

read -p "Indicate the DB path you want to use for DB ? (without '/' at the end) " dbpath 

echo "Stop MariaDB service" ; sleep 3
sudo systemctl stop mariadb.service

ConfirmChoice "Do you have a new disk to configure (format partition, edit fstab) ?" && configure_new_disk 

sudo rsync -av /var/lib/mysql $dbpath

# Rename old DB
sudo mv /var/lib/mysql /var/lib/mysql.bak

# Change DB path
sudo cp -p /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnff
sudo sed -i "s|= /var/lib/mysql|= $dbpath/mysql|" /etc/mysql/mariadb.conf.d/50-server.cnf

# Uncomment if needed
#fine_tuning

# Check the new location is effective
sudo mysql -uroot -e "select @@datadir;"

echo "Start MariaDB service" ; sleep 3
sudo systemctl start mariadb.service
