#!/bin/bash

# description
# Configure partitioning for MySQL / MariaDB database tables

FILE=zabbix_mariadb_partitioning.sql
is_number='^[0-9]+$'

#-----------------------#
#	Functions	#
#-----------------------#

pre_check ()
{
	sudo apt-get install curl > /dev/null

	echo 'Downloading function ConfirmChoice'
	curl -sO https://raw.githubusercontent.com/matthieu-rdt/Toolbox/master/Linux/ConfirmChoice.sh

	source $HOME/ConfirmChoice.sh

	echo 'Before we continue please make a backup of the Zabbix database, but if the installation is new than there is no need for backup'
	ConfirmChoice "Continue ?" && continue || exit 2

	rm $HOME/ConfirmChoice.sh
}

fine_tuning ()
{
	echo 'Downloading zabbix_mariadb_partitioning.sql'
	curl -sO https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Database/zabbix_mariadb_partitioning.sql

	read -p 'How many days of history do you want to keep ? (7 by default) ' history
	read -p 'How many days of trend do you want to keep ? (365 by default) ' trend

	if	[[ $history =~ $is_number || $trend =~ $is_number ]] ; then
		sed "s/\('history.*'\), 7/\1, $history/g" $FILE
		sed "s/\('trends.*'\), 365/\1, $trend/g" $FILE
	else
		echo 'history & trend must be a digit'
		exit 3
	fi

	read -p 'Write your DB username : ' username
	read -sp 'Write your DB password : ' password
	read -p 'Write your DB name : ' name

	sudo mysql -u$username -p$password $name < $FILE
}

enable_scheduler ()
{
#	Manage partitions automatically using MySQL event scheduler (recommended)

	sudo sed -i '#table_cache/a event_scheduler = ON' /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo systemctl restart mysql
	mysql -u$username -p$password $name -e "CREATE EVENT zabbix_partitioning ON SCHEDULE EVERY 1 DAY DO CALL partition_maintenance_all('zabbix');"
}

#-------------------#
#	Start	    #
#-------------------#

pre_check

fine_tuning

enable_scheduler
