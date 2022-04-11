#!/bin/bash

# description
# upgrade Zabbix Server for : Ubuntu, Debian, RHEL
# compatible versions : from Ubuntu 14.04 to 20.04, from Debian 9 to 11, from RHEL 5 to 8

# sources
# https://www.zabbix.com/documentation/current/manual
# https://bestmonitoringtools.com/upgrade-zabbix-to-the-latest-version/

# RUN AS USER

#-----------------------#
#       Variables       #
#-----------------------#

OS=$1
backup_password=""
database_name=""

#-----------------------#
#	Functions	#
#-----------------------#

check_installed_database ()
{
	dpkg -l | grep -q postgresql

	if	[[ $(echo $?) -eq 0 ]] ; then 
		echo "PostgreSQL detected"
		echo "It works only with MariaDB and MySQL"
		exit 6
	fi
}

stop_zabbix_services ()
{
	sudo systemctl stop zabbix-server
	sudo systemctl stop zabbix-proxy 2> /dev/null
}

backup_zabbix_files () 
{
	sudo mkdir -p /opt/zabbix_backup/{bin_files,conf_files,db_files,doc_files,web_files}
	
	sudo cp -rpu /etc/apache2/conf-enabled/zabbix.conf /opt/zabbix_backup/conf_files 2>/dev/null
	sudo cp -rpu /etc/httpd/conf.d/zabbix.conf /opt/zabbix_backup/conf_files 2>/dev/null
	sudo cp -rpu /etc/zabbix/zabbix_server.conf /opt/zabbix_backup/conf_files
	
	sudo cp -rpu /usr/sbin/zabbix_server /opt/zabbix_backup/bin_files
	sudo cp -rpu /usr/share/doc/zabbix-* /opt/zabbix_backup/doc_files
	sudo cp -rpu /usr/share/zabbix/ /opt/zabbix_backup/web_files
}

backup_zabbix_database ()
{
	sudo mysqldump -h localhost -u'backup' -p$backup_password --single-transaction $database_name | gzip > ~/zabbix_backup.sql
	sudo mv zabbix_backup.sql /opt/zabbix_backup/db_files/
}

upgrade_ubuntu_debian ()
{
	sudo dpkg --purge zabbix-release
	curl -O "https://repo.zabbix.com/zabbix/6.0/$OS/pool/main/z/zabbix-release/zabbix-release_6.0-1+$(lsb_release -sc)_all.deb"
	sudo dpkg -i zabbix-release_6.0-1+$(lsb_release -sc)_all.deb
	sudo apt update
	sudo apt install -y --only-upgrade zabbix-server-mysql zabbix-frontend-php
	sudo apt install -y zabbix-apache-conf
}

upgrade_rhel ()
{
	if [ -z $(command -v yum) ]; then
		pktm="dnf"
	else
		pktm="yum"
	fi
	sudo rpm -Uvh https://repo.zabbix.com/zabbix/6.0/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-6.0-1.el$(rpm -E %{rhel}).noarch.rpm
	sudo $pktm clean all
	sudo $pktm upgrade -y zabbix-server-mysql zabbix-web-mysql
	sudo $pktm install -y zabbix-apache-conf
}

start_zabbix_services ()
{
	sudo systemctl start zabbix-server
	sudo systemctl start zabbix-agent
}

#-------------------#
#	Start	    #
#-------------------#

if	[ -z $OS ] ; then
		echo "Try '$0 --help' for more information."
		exit 1

elif	[[ $OS == "--help" ]] ; then
		echo "First argument (mandatory) :"
		echo "ubuntu / debian / rhel"
		echo "For instance, you want to upgrade zabbix major version for ubuntu :"
		echo "$0 ubuntu"
		exit 6

elif	[ $# -ne 1 ] ; then
		echo "Only one parameter is required"
		exit 2

elif !	[[ $OS == ubuntu || $OS == debian || $OS == rhel ]] ; then
		echo "Indicate one of these : ubuntu / debian / rhel (case sensitive)"
		exit 3
		
elif	[[ $backup_password == "" ]] ; then
		echo "edit backup_password, line 15"
		exit 4
		
elif	[[ $database_name == "" ]] ; then
		echo "edit database_name, line 16"
		exit 44
		
elif	[[ $UID -eq 0 ]] ; then
		echo "Run as user"
		exit 5
fi

echo -e "You can follow your upgrade with :\ntail -f /var/log/zabbix/zabbix_server.log\ntail -f /var/log/zabbix/zabbix_proxy.log (if you've got proxy)" ; sleep 5

check_installed_database

stop_zabbix_services

backup_zabbix_files

#	This is tailored for Zabbix installation in combination with [ MySQL / MariaDB ]

backup_zabbix_database

#	Zabbix server and frontend

if	[[ $OS == ubuntu || $OS == debian ]] ; then
		upgrade_ubuntu_debian $OS
else
		upgrade_rhel
fi

start_zabbix_services

#	Check the upgrade status with the command

cat /var/log/zabbix/zabbix_server.log | grep database

echo "Clear browser cache and check Zabbix version" ; sleep 5

#	Check if the upgrade was successful

sudo zabbix_server -V | grep zabbix_server
