#!/bin/bash

# description
# backup Zabbix configuration files 

# note
# Copy a file from the remote system to the local system
# scp user@example.com:/path/to/folder/file.txt .


host1=""
host2=""
zabbix_file=""

host_1 ()
{
	while IFS= read -r file ; do
		if test -f "$file"; then
			scp zabbix@$host1:$file /Zabbix_backup/$host1/
		fi
	done < $zabbix_files
}

host_2 ()
{
	while IFS= read -r file ; do
		if test -f "$file"; then
			scp zabbix@$host2:$file /Zabbix_backup/$host2/
		fi
	done < $zabbix_files
}

host_1
host_2
