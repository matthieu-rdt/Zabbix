#!/bin/bash

# description
# backup Zabbix configuration files 

# note
# Copy a file from the remote system to the local system
# scp user@example.com:/path/to/folder/file.txt .


host1=""
host2=""
zabbix_files="$1"

host_1 ()
{
	while read -r file ; do
		scp zabbix@$host1:$file /Zabbix_backup/$host1/
	done < $zabbix_files
}

host_2 ()
{
	while read -r file ; do
		scp zabbix@$host2:$file /Zabbix_backup/$host2/
	done < $zabbix_files
}

host_1
host_2
