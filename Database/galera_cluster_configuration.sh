#!/bin/bash

# description
# setup a database replication by using Galera Cluster for MariaDB/MySQL

# sources
https://www.server-world.info/en/note?os=Debian_11&p=mariadb&f=5
https://computingforgeeks.com/how-to-setup-mariadb-galera-cluster-on-debian/

#-----------------------#
#	Variables	#
#-----------------------#

ip_node_1=""
ip_node_2=""
#ip_node_3

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
function ConfirmChoice ()
{
        ConfYorN="";
                while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ]
                do
                        echo -n $1 "(y/n) : "
                        read ConfYorN
                done
        [ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

function mariadb_server_cnf ()
{
	sudo sed -i "s/bind-address.* = 127.0.0.1/#bind-address           = 127.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf

		galera=(
		"[galera]"
		"wsrep_on=ON"
		"wsrep_provider=/usr/lib/galera/libgalera_smm.so"
		"binlog_format=row"
		"default_storage_engine=InnoDB"
		"innodb_autoinc_lock_mode=2"
		"bind-address=0.0.0.0"
		"wsrep_cluster_name="MariaDB_Cluster"	# any cluster name"
		)

		case $1 in

		"1")
		echo "wsrep_node_address="$ip_node_1"   # own IP address" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
		;;

		"2")
		echo "wsrep_node_address="$ip_node_2"   # own IP address" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
		;;

#		"3")
#		echo "wsrep_node_address="$ip_node_3"   # own IP address" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
#		;;

		*)
		echo -n "No node number input"
		exit 22
		;;

		esac

	for line in "${galera[@]}" ; do
		echo $line | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	done
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

ConfirmChoice "Is it the first node of the cluster ?" && sudo galera_new_cluster

echo "wsrep_cluster_address="gcomm://$ip_node_1,$ip_node_2,$ip_node_3"" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl restart mariadb.service

sudo mysql -uroot -e "show status like 'wsrep_%';"
