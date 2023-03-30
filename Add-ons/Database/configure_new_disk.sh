#!/bin/bash

# description
# configure a new disk with EXT4
# next step : add XFS

#-----------------------#
#	Functions	#
#-----------------------#

configure_new_disk ()
{
	# Get the new disk name
	lsblk

	read -p "choose the block device you want to use for DB ? " block

	sudo cfdisk /dev/$block

	# '1' because cfdisk created 1 partition
	sudo mkfs.ext4 /dev/$block'1'

	read -p "Enter a path for the mountpoint (without '/' at the end) " mountpoint
	[ ! -d $mountpoint ] && sudo mkdir -p $mountpoint

	# Get UUID
	blkid=`sudo blkid | grep $block | awk '{ print $2 }'`

	# FSTAB
	echo "# folder is on /dev/$block" | sudo tee -a /etc/fstab
	echo "$blkid $mountpoint ext4 defaults	0	2" | sudo tee -a /etc/fstab
	sudo mount -a
}

#-------------------#
#	Start	    #
#-------------------#

configure_new_disk
