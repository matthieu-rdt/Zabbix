#!/bin/bash

# description
# add or delete host groups in your Zabbix GUI using python scripts

# sources
# https://github.com/q1x/zabbix-gnomes

file_add="$1"
file_delete="$2"

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
function ConfirmChoice ()
{
	ConfYorN="";
	while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ] ; do
		echo -n $1 "(y/n) : "
		read ConfYorN
	done
	[ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

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
		exit 2
		if [[ -z $2 ]] ; then
			echo "Fill in a file if you've got host groups to delete !"
			exit 3
		fi
	fi 
}

conf_file_exists ()
{
	if ! [[ -f $HOME/.zbx.conf ]] ; then
		echo ".zbx.conf does not exist & will be created"
		echo "API credentials must be added inside"
		touch $HOME/.zbx.conf
		exit 4
	fi
}

create_host_groups ()
{
	if [[ -f $HOME/zgcreate.py ]] ; then
	#	Python script call
		while IFS= read -r line
		do
			$HOME/./zgcreate.py "$line"
		done < $file_add
	else
		echo "zgcreate.py is missing
		exit 5
	fi
}

delete_host_groups ()
{
	if [[ -f $HOME/zgdelete.py ]] ; then
	# 	Python script call
		while IFS= read -r line
		do
			$HOME/./zgdelete.py -N "$line"
		done < $file_delete
	else
		echo "zgdelete.py is missing
		exit 55
	fi
}

#-------------------#
#	Start	    #
#-------------------#

home

check_args $1 $2

#	Check API credentials to connect to Zabbix GUI
conf_file_exists

ConfirmChoice "Do you have some host groups to add ?" && create_host_groups || echo "no action"

ConfirmChoice "Do you have some host groups to delete ?" && delete_host_groups || echo "no action"
