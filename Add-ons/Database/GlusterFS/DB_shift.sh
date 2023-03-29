#!/bin/bash

# description
# script is specific to
# - reconfiguring Zabbix server instance after a shift between replicated databases
# - using Zabbix HA cluster and/or glusterfs

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

egrep -q '=""$' $0
if      [ $? -eq 0 ] ; then
	echo "Variables are empty"
	exit 3
fi

grep -q $ZABBIX_NODE ~/.ssh/config
if	[ $? -eq 0 ] ; then
	echo "Stop MariaDB & Zabbix server services on $ZABBIX_NODE" ; sleep 2
	ssh $ZABBIX_NODE 'sudo systemctl stop {zabbix-server,mariadb}.service'
else
	echo "$ZABBIX_NODE or file do not exist"
	exit 2
fi

# localhost will host the DB
sudo sed -i 's/^DBHost=.*/DBHost='$IPADDR'/' $backend
sudo sed -i '5s/= '.*'/= \x27'$IPADDR'\x27\;/' $frontend

# remote host to connect to DB
ssh $ZABBIX_NODE "sudo sed -i 's/^DBHost=.*/DBHost=$IPADDR/'" $backend
ssh $ZABBIX_NODE "sudo sed -i '5s/= '.*'/= \x27$IPADDR\x27;/'" $frontend

echo "Start MariaDB & Zabbix server services on localhost" ; sleep 2
sudo systemctl start mariadb
sudo systemctl restart zabbix-server

echo "Start Zabbix server services on $ZABBIX_NODE" ; sleep 2
ssh $ZABBIX_NODE 'sudo systemctl restart zabbix-server.service'
