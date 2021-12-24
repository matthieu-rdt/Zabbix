#!/bin/bash

# description
# upgrade zabbix up to version number 5.4 for multiple distros (ubuntu, debian, rhel)
# last update : 2021 06 01
# version number : 2

# sources
# https://www.zabbix.com/documentation/current/manual
# https://bestmonitoringtools.com/upgrade-zabbix-to-the-latest-version/

# RUN AS USER

################		VARIABLES		###############
OS=$1
################		END VARIABLES	###############

#################		FUNCTIONS		###############
check_installed_database ()
{
	dpkg -l | grep -q postgresql

	if	[[ $(echo $?) -eq 0 ]] ; then 
		echo "PostgreSQL detected"
		echo "It works only with MariaDB and MySQL"
		exit 6
	fi
}

upgrade_ubuntu_debian ()
{
	echo "Downloading and installing package for $OS"
	sudo dpkg --purge zabbix-release
	curl -O "https://repo.zabbix.com/zabbix/5.4/$OS/pool/main/z/zabbix-release/zabbix-release_5.4-1+$OS$(lsb_release -sr)_all.deb"
	sudo dpkg -i zabbix-release_5.4-1+$OS$(lsb_release -sr)_all.deb
	sudo apt update
	sudo apt install -y --only-upgrade zabbix-server-mysql zabbix-frontend-php
	sudo systemctl reload-or-restart zabbix-server.service zabbix-agent.service
}

upgrade_rhel () 
{
	echo "Downloading and installing package for $OS"
	if [ -z $(command -v yum) ]; then
		pktm="dnf"
	else
		pktm="yum"
	fi
	sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.4-1.el$(rpm -E %{rhel}).noarch.rpm
	sudo $pktm clean all
	sudo $pktm upgrade -y zabbix-server-mysql zabbix-web-mysql
	sudo systemctl reload-or-restart zabbix-server.service zabbix-agent.service
}
#################		END FUNCTIONS	###############

#################		START			###############

if		[ -z $OS ] ; then
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
		
elif	[[ $UID -eq 0 ]] ; then 
		echo "Run as user"
		exit 5
fi

echo -e "You can follow your upgrade with :\ntail -f /var/log/zabbix/zabbix_server.log\ntail -f /var/log/zabbix/zabbix_proxy.log (if you've got proxy)" ; sleep 5

check_installed_database

#	Zabbix server and frontend

if		[[ $OS == ubuntu || $OS == debian ]] ; then
		upgrade_ubuntu_debian $OS
else
		upgrade_rhel
fi

#	Check the upgrade status with the command

cat /var/log/zabbix/zabbix_server.log | grep database

#	Check if the upgrade was successful

sudo zabbix_server -V | grep zabbix_server

#################		END				###############