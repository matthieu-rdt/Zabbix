#!/bin/bash

# description
# add host groups in your Zabbix GUI using python scripts

# sources
# https://github.com/q1x/zabbix-gnomes

host_groups_list="$1"

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
ConfirmChoice ()
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
		done < $host_groups_list
	else
		echo "zgcreate.py is missing
		exit 5
	fi
}

#-------------------#
#	Start	    #
#-------------------#

if [[ -z $1 ]] ; then
	echo "Fill in a host group OR a host groups list to add in Zabbix !"
	exit 2
fi

home

#	Check API credentials to connect to Zabbix GUI
conf_file_exists

ConfirmChoice "Do you want to add ONE host group ?" && $HOME/./zgcreate.py $1 || echo "no action"

ConfirmChoice "Do you want to add through a list ?" && create_host_groups || echo "no action"
