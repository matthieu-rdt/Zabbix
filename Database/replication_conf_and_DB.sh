#!/bin/bash

# description
# setup a master/slave replication & to use slave as a backup node

#-----------------------
#	Variables
#-----------------------

DATABASE=""
DUMP=""
REMOTE_NODE=""
USER=""
ZABBIX_SERVER=""

#-----------------------
#	Functions
#-----------------------

sync_DB ()
{
	echo 'Running mysqldump with '$USER
	mysqldump -h localhost -u $USER --create-options -B $DATABASE > $DUMP

	echo 'Sending dump to '$REMOTE_NODE
	rsync -av $DUMP $REMOTE_NODE:$DUMP

	echo 'Restoring DB DUMP'
	ssh $REMOTE_NODE "mysql -uroot zabbix < $DUMP"
}

sync_configuration_files ()
{
	echo 'rsync configuration files to '$REMOTE_NODE
	rsync -av $ZABBIX_SERVER $REMOTE_NODE:$ZABBIX_SERVER
}

#-----------------------
#	Start
#-----------------------

grep -E --quiet '=""$' $0
if	[ $? -eq 0 ] ; then	
	echo 'Fulfil variables'
	exit 2
fi

sync_DB

sync_configuration_files
