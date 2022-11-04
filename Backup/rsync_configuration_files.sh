#!/bin/bash

remote_user=""

sync_important_files=(
"path/file/to/save"
)

check_if_folders_exist ()
{
	for file in "${sync_important_files[@]}" ; do
		ssh $remote_user "if ! [ -d $file ] ; then mkdir -p $(dirname $file) ; fi"
}

sync_all_files ()
{
	for file in "${sync_important_files[@]}" ; do
		# if $file is a file AND if line does not start with #
		if [[ -f $file && ! $file =~ ^# ]] ; then
			rsync -az --delete $file $remote_user:$file
		fi
	done
}

if	[ -z $remote_user ] ; then
	echo 'fulfil variable remote_user'
	exit 3
fi

sudo apt list rsync
if [ $? -eq 1 ] ; then
	sudo apt install rsync
fi

check_if_folders_exist 
sync_all_files 
