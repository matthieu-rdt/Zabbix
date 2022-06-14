#!/bin/bash

# description
# setup a database replication by using Galera Cluster for MariaDB/MySQL

# sources
# https://www.server-world.info/en/note?os=Debian_11&p=mariadb&f=5
# https://computingforgeeks.com/how-to-setup-mariadb-galera-cluster-on-debian/

#-----------------------#
#	Variables	#
#-----------------------#

ip_node_1=""
ip_node_2=""
#ip_node_3

#-----------------------#
#	Functions	#
#-----------------------#

function mariadb_server_cnf ()
{
	sudo sed -i "s/bind-address.* = 127.0.0.1/#bind-address           = 127.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf

		galera=(
		"[galera]"
		"wsrep_on=ON"
		"wsrep_provider=/usr/lib/galera/libgalera_smm.so"
		"wsrep_cluster_address=\"gcomm://\""
		"binlog_format=row"
		"default_storage_engine=InnoDB"
		"innodb_autoinc_lock_mode=2"
		"bind-address=0.0.0.0"
		"wsrep_cluster_name=\"MariaDB_Cluster\""
		)


	for line in "${galera[@]}" ; do
		echo $line | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null
	done

		case $1 in

		"1")
		echo "wsrep_node_address=\"$ip_node_1\"" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null
		;;

		"2")
		echo "wsrep_node_address=\"$ip_node_2\"" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null
		;;

	#	"3")
	#	echo "wsrep_node_address=\"$ip_node_3\"" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf > /dev/null
	#	;;

		*)
		echo "No node number input"
		exit 22
		;;

		esac
}

#-----------------#
#      Start      #
#-----------------#

grep -E --quiet '=""$' $0

if	[ `echo $?` -eq 0 ] ; then
		echo "The variables list is empty"
		exit 2
fi

sudo systemctl stop mariadb

mariadb_server_cnf $1

if	[ $1 -eq 1 ] ; then
	sudo galera_new_cluster
else
	echo "" ; echo "galera_new_cluster has been run" ; echo ""
fi

sudo systemctl restart mariadb.service

sudo sed -i "s|"gcomm://"|"gcomm://$ip_node_1,$ip_node_2"|" /etc/mysql/mariadb.conf.d/50-server.cnf

echo "You can restart MariaDB service :"
echo "sudo systemctl restart mariadb.service"
