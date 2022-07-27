#!/bin/bash

# description
# import hosts, templates, etc in your Zabbix GUI using python scripts

# sources
# https://github.com/selivan/zabbix-import

templates_list="$1"

if [[ -z $1 ]] ; then
	echo "templates list is missing"
	exit 1
else
	while IFS= read -r line
	do
		$HOME/zabbix-import/./zbx-import.py -u Admin -p zabbix "$line"
	done < $templates_list
fi
