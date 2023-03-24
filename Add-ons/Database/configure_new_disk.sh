#!/bin/bash

configure_new_disk ()
{
	# Get the new disk name
	lsblk ; sleep 2

	read -p 'Which disk do you want to partition (e.g. sda, sdb) ? ' block

	sudo cfdisk /dev/$block

	read -p 'Which FS type (e.g. ext4, xfs) ' type

	# '1' because cfdisk created 1 partition
	sudo mkfs.$type /dev/$block'1'

	[ ! -d $FOLDER ] && sudo mkdir -p $FOLDER

	# Get UUID
	blkid=`sudo blkid | grep $block | awk '{ print $2 }'`

	read -p 'Give your disk a name ' name

	# /etc/fstab file
	echo "# $name is on /dev/$block" | sudo tee -a /etc/fstab
	echo "$blkid $FOLDER ext4 defaults	0	2" | sudo tee -a /etc/fstab
	sudo mount -a
}

configure_new_disk
