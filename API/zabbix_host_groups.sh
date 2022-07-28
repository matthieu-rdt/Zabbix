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

pwd_home ()
{
	if [ $(pwd) != $HOME ] ; then
		cd $HOME
	fi
}

conf_file_exists ()
{
	if ! [ -f $HOME/.zbx.conf ] ; then
		echo ".zbx.conf does not exist & will be created"
		echo "API credentials must be added inside"
		touch $HOME/.zbx.conf
		exit 4
	fi
}

single_host_group ()
{
	echo "Host group [$line] has been created"
	$HOME/./zgcreate.py $1 > /dev/null
}

create_host_groups ()
{
	if [ -f $HOME/zgcreate.py ] ; then
	#	Python script call
		while IFS= read -r line
		do
			echo "Host group [$line] has been created"
			$HOME/./zgcreate.py "$line" > /dev/null
		done < $host_groups_list
	else
		echo "zgcreate.py is missing"
		exit 5
	fi
}

#-------------------#
#	Start	    #
#-------------------#

if [ -z $1 ] ; then
	echo "Fill in a host group OR a host groups list to add in Zabbix !"
	exit 2
fi

pwd_home

#	Check API credentials to connect to Zabbix GUI
conf_file_exists

if ! [ -s $1 ] ; then
	ConfirmChoice "Do you want to add ONE host group ?" && single_host_group || echo "no action"
fi

if [ -s $1 ] ; then
	ConfirmChoice "Do you want to add through a list ?" && create_host_groups || echo "no action"
fi
