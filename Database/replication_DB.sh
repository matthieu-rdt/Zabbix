#!/bin/bash

# description
# setup a database replication by using MariaDB/MySQL

#-----------------------#
#	Variables	#
#-----------------------#

#	Complete remote information
fqdn=""
ip_server=""

#	Complete local information
local_ip=""
user_password=""

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

function mariadb_server_cnf
{
	sudo sed -i "s/bind-address = 127.0.0.1/bind-address = $local_ip/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#server-id = 1/server-id = $1/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#log_bin = /var/log/mysql/mysql-bin.log/log_bin = /var/log/mysql/mysql-bin.log/" /etc/mysql/mariadb.conf.d/50-server.cnf
}

#-----------------#
#      Start      #
#-----------------#

#if $1 est vide, echo numero de node

sudo sed -i "/`hostname -f`/a $ip_server $fqdn" /etc/hosts

if [ `ping -c1 $ip_server | echo $?` -eq 1 || `ping -c1 $fqdn | echo $?` -eq 1 ] 
	echo "cannot ping $fqdn"
	exit 1
fi

if [ `sudo dpkg -l | grep mariadb | echo $?` -eq 1 ] ; then
	sudo apt install mariadb-server -y
	echo "Installing MariaDB"
fi

ConfirmChoice "Do you configure node 1 ?" && mariadb_server_cnf $1

sudo systemctl restart mariadb.service

read -sp "Root password of MariaDB : " root_password
sudo mysql -uroot -p$root_password -e "GRANT REPLICATION SLAVE ON *.* TO 'replication'@'"$ip_server"' IDENTIFIED BY '"$user_password"';"
sudo mysql -uroot -p$root_password -e "FLUSH PRIVILEGES;"
sudo mysql -uroot -p$root_password -e "SHOW MASTER STATUS;"

mysql_bin=`sudo mysql -uroot -p$root_password -e "SHOW MASTER STATUS;" | grep mysql | awk '{ print $1 }'`
position=`sudo mysql -uroot -p$root_password -e "SHOW MASTER STATUS;" | grep mysql | awk '{ print $2 }'`

instruction=(
"You will have to run these commands manually :"
""
"This command must be run in the OTHER node"
"CHANGE MASTER TO MASTER_HOST="$ip_server", MASTER_USER='replication', MASTER_PASSWORD="$user_password", MASTER_LOG_FILE="$mysql_bin", MASTER_LOG_POS=$position;"
"Once the slaves configured, you can run"
"START SLAVE;"
)

for line in "${instruction[@]}" ; do
	echo $line
done
