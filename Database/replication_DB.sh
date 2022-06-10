#!/bin/bash

# description
# setup a database replication by using MariaDB/MySQL

# sources
# https://linux-note.com/debian-9-mariadb-replication-master-to-master/
# https://www.linuxtricks.fr/wiki/print.php?id=248

#-----------------------#
#	Variables	#
#-----------------------#

local_ip=""

#       Complete remote information
fqdn=""
ip_server=""
replication_passwd=""

#-----------------------#
#	Functions	#
#-----------------------#

# Function from Manu
function ConfirmChoice()
{
        ConfYorN="";
                while [ "${ConfYorN}" != "y" -a "${ConfYorN}" != "Y" -a "${ConfYorN}" != "n" -a "${ConfYorN}" != "N" ]
                do
                        echo -n $1 "(y/n) : "
                        read ConfYorN
                done
        [ "${ConfYorN}" == "y" -o "${ConfYorN}" == "Y" ] && return 0 || return 1
}

function mariadb_server_cnf()
{
	sudo sed -i "s/bind-address.* = 127.0.0.1/bind-address             = $local_ip/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#server-id.* = 1/server-id               = $1/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i 's/#log_bin/log_bin /' /etc/mysql/mariadb.conf.d/50-server.cnf

	echo "#       Additional parameters"					| sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "auto-increment-increment  = 2"					| sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "auto-increment-offset     = $1" 					| sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "log_slave_updates         = 1"  					| sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "log_bin_index             = /var/log/mysql/mysql-bin.log.index"   | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "relay_log_index           = /var/log/mysql/mysql-relay-bin.index" | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
	echo "relay_log                 = /var/log/mysql/mysql-relay-bin"       | sudo tee -a /etc/mysql/mariadb.conf.d/50-server.cnf
}

#-----------------#
#      Start      #
#-----------------#

grep -E --quiet '=""$' $0

if	[ `echo $?` -eq 0 ] ; then
		echo "The variables list is empty"
		exit 2
fi

if	[ -z $1 ] ; then
		echo "Indicate a node number"
		echo "Try '$0 1'"
		exit 22
fi

sudo sed -i "/`hostname -f`/a $ip_server $fqdn" /etc/hosts

ping -c2 $ip_server > /dev/null

if	[ `echo $?` -eq 1 ] ; then
		echo "cannot ping $ip_server" 
		exit 1
fi

sudo dpkg -l | grep --quiet mariadb

if	[ `echo $?` -eq 1 ] ; then
		sudo apt install mariadb-server -y
		echo "Installing MariaDB"
fi

ConfirmChoice "Do you want to configure node $1 ?" && mariadb_server_cnf $1

sudo systemctl restart mariadb.service

sudo mysql -uroot -e "GRANT REPLICATION SLAVE ON *.* TO 'replication'@'"$ip_server"' IDENTIFIED BY '"$replication_passwd"';"
sudo mysql -uroot -e "FLUSH PRIVILEGES;"
sudo mysql -uroot -e "SHOW MASTER STATUS;"

mysql_bin=`sudo mysql -uroot -p$root_password -e "SHOW MASTER STATUS;" | grep mysql | awk '{ print $1 }'`
position=`sudo mysql -uroot -p$root_password -e "SHOW MASTER STATUS;" | grep mysql | awk '{ print $2 }'`

#	Check remote connection
sudo mysql -u replication -p $replication_passwd -h $ip_server

instruction=(
"You will have to run these commands manually :"
""
"This command must be run in the OTHER node"
"CHANGE MASTER TO MASTER_HOST='"$ip_server"', MASTER_USER='replication', MASTER_PASSWORD='"$replication_passwd"', MASTER_LOG_FILE='"$mysql_bin"', MASTER_LOG_POS=$position;"
"Once the slaves configured, you can run"
"START SLAVE;"
)

for line in "${instruction[@]}" ; do
	echo $line
done
