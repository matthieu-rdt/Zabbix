#!/bin/bash

ip_server=""
fqdn=""

sed -i '/127.0.0.1/a $ip_server  $fqdn' test.txt

ping -c1 $fqdn

if [ `sudo dpkg -l | grep mariadb | echo $?` -eq 1 ] ; then
	sudo apt install mariadb-server
	echo "Installing MariaDB"
fi

sudo sed -i 's/bind-address = 127.0.0.1/bind-address = $ip_server/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/#server-id = 1/server-id = 1/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/#log_bin = /var/log/mysql/mysql-bin.log/log_bin = /var/log/mysql/mysql-bin.log/' /etc/mysql/mariadb.conf.d/50-server.cnf

sudo systemctl restart mariadb.service


