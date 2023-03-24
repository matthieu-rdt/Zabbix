#!/bin/bash

configure_new_disk ()
{

	read -p 'Enter a folder name to create ? (without '/' at the end) ' FOLDER
	[ ! -d $FOLDER ] && sudo mkdir -p $FOLDER

	# Get the new disk name
	lsblk ; sleep 2
	read -p 'Which disk do you want to partition (e.g. sda, sdb) ? ' block
	sudo cfdisk /dev/$block

	read -p 'Which FS type (ext4 or xfs) ' type
	case $type in
		"ext4")
		# '1' because cfdisk created 1 partition ;;
		sudo mkfs.ext4 /dev/$block'1' ;;
		blkid=`sudo blkid | grep $block | awk '{ print $2 }'` ;;
		read -p 'Give your disk a name ' name ;;
		echo "# $name is on /dev/$block" 				| sudo tee -a /etc/fstab ;;
		echo "$blkid $FOLDER ext4 defaults,errors=remount-ro 0 2 	| sudo tee -a /etc/fstab ;;

		"xfs")
		sudo apt install xfsprogs -y ;;
		sudo modprobe -v xfs ;;
		# '1' because cfdisk created 1 partition ;;
		sudo mkfs.xfs /dev/$block'1' ;;
		blkid=`sudo blkid | grep $block | awk '{ print $2 }'` ;;
		read -p 'Give your disk a name ' name ;;
		echo "# $name is on /dev/$block" 				| sudo tee -a /etc/fstab ;;
		echo "$blkid $FOLDER xfs defaults,errors=remount-ro 0 2 	| sudo tee -a /etc/fstab ;;

		*)
		exit 3 ;;
	esac

	sudo mount -a
}

echo 'supported FS : ext4 & xfs'

configure_new_disk
