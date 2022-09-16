#!/bin/bash

# description
# backup Zabbix configuration files

# note
# Copy a file from the remote system to the local system
# scp user@example.com:/path/to/folder/file.txt .

# area for improvements
# use profile.d
# use for loop instead of 1, 2, etc

backup_folder_h1=$HOME/Zabbix_backup/$host1
backup_folder_h2=$HOME/Zabbix_backup/$host2
host1=""
host2=""
zabbix_files="$1"

host_1 ()
{
	if ! [ -d $backup_folder_h1 ] ; then
		mkdir $backup_folder_h1
	fi
	while read -r file ; do
		scp zabbix@$host1:$file $backup_folder_h1
	done < $zabbix_files
}

host_2 ()
{
	if ! [ -d $backup_folder_h2 ] ; then
		mkdir $backup_folder_h2
	fi
	while read -r file ; do
		scp zabbix@$host2:$file $backup_folder_h2
	done < $zabbix_files
}

host_1

host_2
