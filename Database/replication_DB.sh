#!/bin/bash

#-----------------------#
#       Functions       #
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

function node_1()
{
	sudo sed -i "s/bind-address = 127.0.0.1/bind-address = $ip_server/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#server-id = 1/server-id = 1/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#log_bin = /var/log/mysql/mysql-bin.log/log_bin = /var/log/mysql/mysql-bin.log/" /etc/mysql/mariadb.conf.d/50-server.cnf
}

function node_2()
{
	sudo sed -i "s/bind-address = 127.0.0.1/bind-address = $ip_server/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#server-id = 1/server-id = 2/" /etc/mysql/mariadb.conf.d/50-server.cnf
	sudo sed -i "s/#log_bin = /var/log/mysql/mysql-bin.log/log_bin = /var/log/mysql/mysql-bin.log/" /etc/mysql/mariadb.conf.d/50-server.cnf
}

#-----------------------#
#       Variables       #
#-----------------------#

ip_server=""
fqdn=""

sed -i "/`hostname -f`/a $ip_server $fqdn" /etc/hosts

if [ `ping -c1 $ip_server | echo $?` -eq 1 || `ping -c1 $fqdn | echo $?` -eq 1 ] 
	echo "cannot ping $fqdn"
	exit
fi

if [ `sudo dpkg -l | grep mariadb | echo $?` -eq 1 ] ; then
	sudo apt install mariadb-server
	echo "Installing MariaDB"
fi

ConfirmChoice "Do you configure node 1 ?" && node_1
ConfirmChoice "Do you configure node 2 ?" && node_2

sudo systemctl restart mariadb.service


