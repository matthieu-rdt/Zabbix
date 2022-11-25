#!/bin/bash

source "$(pwd)/sync_files_list.txt"

#-------------------#
#       Start       #
#-------------------#

if	[ ! -f "$(pwd)/sync_files_list.txt" ] ; then
	echo "$(pwd)/sync_files_list.txt not found"
	exit 2
fi

for file in "${sync_important_files[@]}" ; do

	grep -q "HANodeName=$(hostname)" "$file"
	if	[ $? -eq 1 ] ; then
		sed -i 's/HANodeName=.*/HANodeName='$(hostname)'/g' "$file"
	fi

	ip=$(ip a | grep ens1[0-9].* | grep inet | cut -d'/' -f1 | cut -d' ' -f6)
	grep -q "NodeAddress=$ip:10051" "$file"
	if	[ $? -eq 1 ] ; then
		sed -i s/NodeAddress=.*/NodeAddress=$ip:10051/g "$file"
	fi

done
