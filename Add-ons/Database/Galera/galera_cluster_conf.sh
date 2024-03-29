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
node_name="$(hostname)"
node_ip_1=""
node_ip_2=""
#node_ip_3

FILE=$HOME/60-galera.cnf

#-----------------------#
#	Functions	#
#-----------------------#

check_vars ()
{
	var_names=("$@")
	for var_name in "${var_names[@]}"; do
		[ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
	done
		[ -n "$var_unset" ] && exit 1
	return 0
}

galera_cnf ()
{
	sudo mv /etc/mysql/mariadb.conf.d/60-galera.cnf /etc/mysql/mariadb.conf.d/60-galera.cnf.back
	while IFS= read -r line ; do
		echo $line | sudo tee -a /etc/mysql/mariadb.conf.d/60-galera.cnf > /dev/null
	done < $FILE
}

sed_variables ()
{
	sudo sed -i 's/|cluster_name|/'"$cluster_name"'/' 	/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i 's/|node_name|/'"$node_name"'/' 		/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i 's/|node_ip_1|/'"$node_ip_1"'/' 		/etc/mysql/mariadb.conf.d/60-galera.cnf
	sudo sed -i 's/|node_ip_2|/'"$node_ip_2"'/' 		/etc/mysql/mariadb.conf.d/60-galera.cnf
#	sudo sed -i 's/|node_ip_3|/'"$node_ip_3"'/' 		/etc/mysql/mariadb.conf.d/60-galera.cnf
}

red_text ()
{
	echo -e "\033[0;31m$1\033[0m"
}

NodeAddress ()
{

	if	[ $1 -eq 1 ] ; then
		echo "Configuring NodeAddress with node ip $1"
		sudo sed -i '/^# NodeAddress=/a NodeAddress='"$node_ip_1"':10051' /etc/zabbix/zabbix_server.conf
	elif	[ $1 -eq 2 ] ; then
		echo "Configuring NodeAddress with node ip $1"
		sudo sed -i '/^# NodeAddress=/a NodeAddress='"$node_ip_2"':10051' /etc/zabbix/zabbix_server.conf
	elif	[ $1 -eq 3 ] ; then
		echo "Configuring NodeAddress with node ip $1"
		sudo sed -i '/^# NodeAddress=/a NodeAddress='"$node_ip_3"':10051' /etc/zabbix/zabbix_server.conf
	else
		echo "NodeAddress could not be configured"
		exit 3
	fi
}

#-----------------#
#      Start      #
#-----------------#

sudo apt-get install curl > /dev/null

if	[ ! -f "$FILE" ] ; then
	echo "Downloading 60-galera.cnf"
	curl -sO https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/Database/Galera/60-galera.cnf
	red_text "Open 60-galera.cnf & uncomment 'wsrep_cluster_address' & 'wsrep_node_address' options according to your preferences"
	exit 2
fi

check_vars cluster_name node_ip_1 node_ip_2

if !	[[ $1 -eq 1 || $1 -eq 2 || $1 -eq 3 ]] ; then
	echo "Bad or no argument provided"
	echo "1 for primary node, 2 or 3 for additional nodes"
	exit 22
elif	[ $(grep -E "^# wsrep_cluster_address" $FILE | wc -l) -eq 2 ] ; then
	echo "wsrep_cluster_address is not configured"
	exit 222
fi

galera_cnf $FILE

sed_variables

if	[ $1 -eq 1 ] ; then
	sudo systemctl stop mariadb
	sudo galera_new_cluster
else
	sudo systemctl restart mariadb
fi

echo "Configuring HANodeName"
sudo sed -i '/^# HANodeName=/a HANodeName='"$node_name" /etc/zabbix/zabbix_server.conf

NodeAddress $1

echo "Restarting Zabbix server service"
sudo systemctl restart zabbix-server.service

red_text "To add an additional node to the cluster, change the 'wsrep_node_name' and 'wsrep_node_address' options if you use them"
