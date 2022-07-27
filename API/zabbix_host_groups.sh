#!/bin/bash

# description
# add or delete host groups in your Zabbix GUI using python scripts

# sources
# https://github.com/q1x/zabbix-gnomes

file_add="$1"
file_del="$2"

#-----------------------#
#	Functions	#
#-----------------------#

home ()
{
	if [[ $(pwd) != $HOME ]] ; then
		cd $HOME
	fi
}

check_args ()
{
	if [[ -z $1 ]] ; then
		echo "Fill in a file if you've got host groups to add !"
		exit 1
		if [[ -z $2 ]] ; then
			echo "Fill in a file if you've got host groups to delete !"
			exit 2
		fi
	fi 
}

conf_file_exists ()
{
	if ! [[ -f $HOME/.zbx.conf ]] ; then
		echo ".zbx.conf does not exist & will be created"
		echo "API credentials must be added inside"
		touch $HOME/.zbx.conf
	fi
}

create_host_groups ()
{
	if [[ -f $HOME/zabbix-gnomes/zgcreate.py ]] ; then
	#	Python script call
		while IFS= read -r line
		do
			$HOME/zabbix-gnomes/./zgcreate.py "$line"
		done < "$file_add"
	else
		echo "zgcreate.py is missing
		exit 1
	fi
}

delete_host_groups ()
{
	if [[ -f $HOME/zabbix-gnomes/zgdelete.py ]] ; then
	# 	Python script call
		while IFS= read -r line
		do
			$HOME/zabbix-gnomes/./zgdelete.py -N "$line"
		done < "$file_del"
	else
		echo "zgdelete.py is missing
		exit 2
	fi
}

#-------------------#
#	Start	    #
#-------------------#

home

check_args $1 $2

#	Check API credentials to connect to Zabbix GUI
conf_file_exists

read -p 'Do you want to create host groups [y or press Enter] ? ' c_hstgrp

if [[ $c_hstgrp == y && -n $1 ]] ; then
	create_host_groups
else
	echo "no action"
fi

read -p 'Do you want to delete host groups [y or press Enter] ? ' d_hstgrp

if [[ $d_hstgrp == y && -n $2 ]] ; then
	delete_host_groups
else
	echo "no action"
fi 
