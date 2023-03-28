#!/bin/bash

# description
# script is specific to reconfiguring Zabbix server instance after a shift between replicated databases
# script is specific to using glusterfs

# note
# SSH connection is required between nodes (~/.ssh/config)

# sources
# https://www.zabbix.com/documentation/current/en/manual/concepts/server/ha

#-----------------------#
#       Variables       #
#-----------------------#

# FILES
backend="/etc/zabbix/zabbix_server.conf"
frontend="/etc/zabbix/web/zabbix.conf.php"

# Current DB host to stop
ZABBIX_NODE=""

# New DB host
IPADDR=""

#-------------------#
#	Start	    #
#-------------------#

grep
if	[ $? -eq 0 ] ; then
	echo "Variables are empty"
	exit 3
fi

grep -q $ZABBIX_NODE ~/.ssh/config
if	[ $? -eq 0 ] ; then
	echo "Stop MariaDB service on $ZABBIX_NODE" ; sleep 2
	if [ `whoami` = root ] ; then
		ssh $ZABBIX_NODE 'systemctl stop mariadb.service'
	else
		ssh $ZABBIX_NODE 'sudo systemctl stop mariadb.service'
	fi
else
	echo "$ZABBIX_NODE or file do not exist"
	exit 2
fi

# localhost will host the DB
sed -i "s/DBHost=.*/DBHost=$IPADDR/" $backend
sed -i "5s/= '.*'/= '"$IPADDR"'/" $frontend

# remote host to connect to DB
ssh $ZABBIX_NODE "sed -i 's/DBHost=.*/DBHost=$IPADDR/'" $backend
ssh $ZABBIX_NODE "sed -i '5s/= '.*'/= \x27$IPADDR\x27;/'" $frontend

echo "Start MariaDB service on localhost" ; sleep 2
sudo systemctl start mariadb.service

echo "Restart Zabbix server service" ; sleep 2
if [ `whoami` = root ] ; then
	systemctl restart zabbix-server.service ; sleep 3
	ssh $ZABBIX_NODE 'systemctl restart zabbix-server.service'
else
	sudo systemctl restart zabbix-server.service ; sleep 3
	ssh $ZABBIX_NODE 'sudo systemctl restart zabbix-server.service'
fi
