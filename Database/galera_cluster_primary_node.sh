#!/bin/bash

# description
# setup a database replication by using Galera Cluster for MariaDB/MySQL

# sources
# https://www.server-world.info/en/note?os=Debian_11&p=mariadb&f=5
# https://computingforgeeks.com/how-to-setup-mariadb-galera-cluster-on-debian/

#-----------------------#
#       Variables       #
#-----------------------#

cluster_name=""
node_name=""
ip_node_1=""
ip_node_2=""
#ip_node_3

FILE=$(find . -type f -name 60-galera.cnf)

#-----------------------#
#	Functions	#
#-----------------------#

function galera_cnf ()
{
	while IFS= read -r line;
	do
		echo $line | sudo tee /etc/mysql/mariadb.conf.d/60-galera.cnf > /dev/null
	done < $FILE
}

function sed_variables ()
{
	sudo sed -i "s/|cluster_name|/$cluster_name/" 	/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i "s/|node_name|/$node_name/" 	/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i "s/|ip_node_1|/$ip_node_1/" 	/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i "s/|ip_node_2|/$ip_node_2/" 	/etc/mysql/mariadb.conf.d/60-galera.cnf
#	sudo sed -i "s/|ip_node_3|/$ip_node_3/" 	/etc/mysql/mariadb.conf.d/60-galera.cnf
}

function red_text ()
{
	echo -e "\033[0;31m$1\033[0m"
}

#-----------------#
#      Start      #
#-----------------#

grep -E --quiet '=""$' $0

if	[ $? -eq 0 ] ; then
	echo "The variables list is empty"
	exit 2
fi

sudo apt install curl > /dev/null

if	[ ! -f "$FILE" ] ; then
	echo "Downloading 60-galera.cnf"
	curl -O https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Database/60-galera.cnf

galera_cnf $FILE

sed_variables

sudo systemctl stop mariadb

sudo galera_new_cluster

red_text "To add an additional node to the cluster, run 'galera_cluster_another_node.sh'"
red_text "Change the "wsrep_node_name" and "wsrep_node_address" options if you use them"
