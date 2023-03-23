#!/bin/bash

# description
# script to reconfigure Zabbix server after a shift between databases

# note
# SSH connection is required between nodes

# sources
# https://www.zabbix.com/documentation/current/en/manual/concepts/server/ha

#-----------------------#
#       Variables       #
#-----------------------#

# FILES
backend="/etc/zabbix/zabbix_server.conf"
frontend="/etc/zabbix/web/zabbix.conf.php"

# NAMES
ZABBIX_NODE=""
IPaddr=""
USER=""
PASSWORD=""

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
ConfirmChoice ()
{
	ConfYorN="";
	while [ "${ConfYorN}" != "y" ] && [ "${ConfYorN}" != "Y" ] && [ "${ConfYorN}" != "n" ] && [ "${ConfYorN}" != "N" ]
	do
		echo -n "$1" "(y/n) : "
		read ConfYorN
	done
	[ "${ConfYorN}" == "y" ] || [ "${ConfYorN}" == "Y" ] && return 0 || return 1
}

#-------------------#
#	Start	    #
#-------------------#

ConfirmChoice "Continue with `whoami`" || read -p 'Login : ' username && su - $username

grep -q $ZABBIX_NODE ~/.ssh/config
if	[ $? -eq 0 ] ; then
	echo "Stop MariaDB service on $ZABBIX_NODE" ; sleep 3
	ssh $ZABBIX_NODE 'sudo systemctl stop mariadb.service'
else
	echo "$ZABBIX_NODE or file do not exist"
	exit 2
fi

## Make localhost the primary server
#sed -i "5s/DBHost=.*/DBHost=$IPaddr/" $backend
#sed -i "8s/DBUser=.*/DBUser=$USER/" $backend
#sed -i "9s/DBPassword=.*/DBPassword=$PASSWORD/" $backend

#sed -i "5s/= '.*'/= 'localhost'/" $frontend
#sed -i "8s/= '.*'/= '"$USER"'/" $frontend
#sed -i "9s/= '.*'/= '"$PASSWORD"'/" $frontend

echo "Start MariaDB service on localhost" ; sleep 3
sudo systemctl start mariadb.service
