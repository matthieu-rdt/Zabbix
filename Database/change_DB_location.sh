#!/bin/bash

if [ $SHELL == /usr/bin/zsh ] ; then
	exit 11
fi

# Get the new disk name
lsblk && sleep 5

read -p "choose the block device you want to use for DB ? " block
read -p "choose the DB path you want to use for DB ? (without '/' at the end) " dbpath 

echo "Stop MariaDB service"
sudo systemctl stop mariadb.service

sudo mkfs.ext4 /dev/$block
sudo mkdir -p $dbpath

# Get UUID
blkid=`sudo blkid | grep $block | awk '{ print $2 }'`

# FSTAB
echo "# Database is on /dev/$block" | sudo tee -a /etc/fstab
echo "$blkid $dbpath   ext4    defaults        0       2" | sudo tee -a /etc/fstab
sudo mount -a

sudo rsync -av /var/lib/mysql $dbpath

# Rename old DB
sudo mv /var/lib/mysql /var/lib/mysql.bak

# Change DB path
sudo cp -p /etc/mysql/mariadb.conf.d/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnff
sudo sed -i "s|= /var/lib/mysql|= $dbpath/mysql|" /etc/mysql/mariadb.conf.d/50-server.cnf

# Check the new location is effective
sudo mysql -uroot -p -e "select @@datadir;"
