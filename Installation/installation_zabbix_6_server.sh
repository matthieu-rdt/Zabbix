#!/bin/bash

# description
# installation Zabbix Server for : ubuntu, debian
# compatible versions : ubuntu 20.04 and lower,  debian 11 and lower 

# sources
# https://www.zabbix.com/documentation/current/manual
# https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-zabbix-to-securely-monitor-remote-servers-on-ubuntu-18-04
# https://bestmonitoringtools.com/how-to-install-zabbix-server-on-ubuntu/
# https://bestmonitoringtools.com/how-to-install-zabbix-server-on-debian/

# RUN AS USER

#-----------------------#
#	Variables	#
#-----------------------#

OS=$1
root_password=""
user_password=""
backup_password=""

#-----------------------#
#	Functions	#
#-----------------------#

install_lamp_server ()
{
	sudo apt-get install curl ufw apache2 default-mysql-server php libapache2-mod-php php-mysql php-{gd,bcmath,mbstring,xml,ldap,json} -y
}

ufw_configuration ()
{
#	If no direction is supplied, the rule applies to incoming traffic
	yes | sudo ufw enable
	if [[ $OS == ubuntu ]] ; then
		sudo ufw allow "Apache Full"
	else
		sudo ufw allow "WWW Full"
	fi
	sudo ufw allow 22/tcp
	sudo ufw allow 10050/tcp
	sudo ufw allow 10051/tcp
}

install_zabbix_server ()
{
	curl -O "https://repo.zabbix.com/zabbix/6.0/$OS/pool/main/z/zabbix-release/zabbix-release_6.0-1+$OS$(lsb_release -rs)_all.deb"
	sudo dpkg -i zabbix-release_6.0-1+$OS$(lsb_release -rs)_all.deb
	sudo apt-get update
	sudo apt-get install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-agent -y
	sudo systemctl reload apache2
}

create_database_botbackup_and_import_schema ()
{
	sudo mysql -uroot -p$root_password -e "create database zabbix character set utf8 collate utf8_bin;"
	sudo mysql -uroot -p$root_password -e "grant all privileges on zabbix.* to zabbix@localhost identified by '"$user_password"';"

	sudo mysql -uroot -p$root_password -e "create user 'botbackup'@'localhost' identified by '"$backup_password"';"
	sudo mysql -uroot -p$root_password -e "grant select, show view, reload, lock tables, replication client, event, trigger on *.* to 'botbackup'@'localhost';"

	sudo mysql -uroot -p$root_password -e "flush privileges;"

#	Import initial schema and data
	zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p$user_password zabbix
}

highlighted_text ()
{
	echo "" ; echo -e "\e[7m$1\e[0m" ; echo ""
}

edit_passwd_and_timezone ()
{
	sudo cp -p /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.back
	sudo sed -i "/^# DBPassword=/a DBPassword=$user_password" /etc/zabbix/zabbix_server.conf
	sudo sed -i "s/# StartDiscoverers=1/StartDiscoverers=3/" /etc/zabbix/zabbix_server.conf # increase number if needed

	#sudo cp -p /etc/zabbix/apache.conf /etc/zabbix/apache.conf.back
	#sudo sed -i "s/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Paris/g" /etc/zabbix/apache.conf

#	Mandatory for the "Check of pre-requisites"
	sudo cp -p /etc/php/7.3/apache2/php.ini /etc/php/7.3/apache2/php.ini.back
	sudo sed -i "s/;date.timezone =/date.timezone = \"Europe\/Paris\"/g" /etc/php/7.3/apache2/php.ini
}

configure_vmware_and_snmp_parameters ()
{
	sudo sed -i "s/# StartVMwareCollectors=0/StartVMwareCollectors=5/g" /etc/zabbix/zabbix_server.conf
	sudo sed -i "s/# VMwareFrequency=60/VMwareFrequency=60/g" /etc/zabbix/zabbix_server.conf
	sudo sed -i "s/# VMwarePerfFrequency=60/VMwarePerfFrequency=60/g" /etc/zabbix/zabbix_server.conf

#	Increase if needed
	sudo sed -i "s/# VMwareCacheSize=8M/VMwareCacheSize=32M/g" /etc/zabbix/zabbix_server.conf 
	sudo sed -i "s/# VMwareTimeout=10/VMwareTimeout=10/g" /etc/zabbix/zabbix_server.conf

	sudo sed -i "s/# CacheSize=8M/CacheSize=128M/g" /etc/zabbix/zabbix_server.conf
	sudo sed -i "s/# StartSNMPTrapper=0/StartSNMPTrapper=1/g" /etc/zabbix/zabbix_server.conf
}

enable_zabbix-server_and_cleaning-up ()
{
	sudo systemctl enable zabbix-server
	sudo systemctl reload-or-restart zabbix-server
	sudo apt-get autoremove -y
}

configure_fqdn_for_default_frontend ()
{
	fqdn=$(hostname -f)

	sudo cp -p /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/zabbix.conf

	sudo sed -i "s_#ServerName www.example.com_ServerName http://$fqdn/zabbix/_" /etc/apache2/sites-available/zabbix.conf
	sudo sed -i "s_DocumentRoot /var/www/html_DocumentRoot /usr/share/zabbix/_" /etc/apache2/sites-available/zabbix.conf

	sudo a2dissite 000-default.conf
	sudo a2dissite default-ssl.conf
	sudo a2ensite zabbix.conf

	sudo systemctl reload-or-restart apache2.service
}

create_permanent_shortcuts ()
{
	sudo touch /etc/profile.d/shortcuts.sh

	echo "export SERVERLOG=/var/log/zabbix/zabbix_server.log" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null
	echo "export CONFSERVER=/etc/zabbix/zabbix_server.conf" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null
	echo "export AGENTLOG=/var/log/zabbix/zabbix_agentd.log" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null
	echo "export CONFAGENT=/etc/zabbix/zabbix_agentd.conf" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null

	if	[[ $OS == ubuntu ]] ; then
			echo "export netint=/etc/netplan/01-netcfg.yaml" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null
	elif	[[ $OS == debian ]] ; then
			echo "export netint=/etc/network/interfaces" | sudo tee -a /etc/profile.d/shortcuts.sh > /dev/null
	fi
}

conditions () 
{
	if	[ -z $OS ] ; then
			echo "Try '$0 --help' for more information."
			exit 1

	elif	[[ $OS == "--help" ]] ; then
			echo "Pick an argument (mandatory) :"
			echo "ubuntu / debian / (rhel not yet)"
			echo "For instance, you want to install Zabbix Server for ubuntu :"
			echo "$0 ubuntu"
			exit 6

	elif	[ $# -ne 1 ] ; then
			echo "Only one parameter is required"
			exit 2

	elif !	[[ $OS == ubuntu || $OS == debian ]] ; then
			echo "Indicate one of these : ubuntu / debian (case sensitive)"
			exit 3

	elif	[[ $root_password == "" ]] ; then
			echo "edit root_password"
			exit 4

	elif	[[ $user_password == "" ]] ; then
			echo "edit user_password"
			exit 44

	elif	[[ $backup_password == "" ]] ; then
			echo "edit backup_password"
			exit 444

	elif	[[ $UID -eq 0 ]] ; then
			echo "Run as user"
			exit 5
	fi
}

#-------------------#
#	Start	    #
#-------------------#

conditions $OS

sudo apt-get update && sudo apt-get upgrade -y

install_lamp_server

ufw_configuration

install_zabbix_server

create_database_botbackup_and_import_schema

highlighted_text "type 'n' for not changing the root password and 'y' for each question to secure your database"

sudo mysql_secure_installation

edit_passwd_and_timezone

configure_vmware_and_snmp_parameters

enable_zabbix-server_and_cleaning-up

configure_fqdn_for_default_frontend

create_permanent_shortcuts $OS

logout
