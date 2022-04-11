#!/bin/bash

# description

# sources
# https://www.zabbix.com/documentation/current/manual
# https://bestmonitoringtools.com/upgrade-zabbix-to-the-latest-version/

# RUN AS USER

#-----------------------#
#       Arrays		#
#-----------------------#

debian_version=(
)

rhel_version=(
)

#-----------------------#
#       Variables       #
#-----------------------#

OS=$1

#-----------------------#
# 	Functions 	#
#-----------------------#

check_installed_database ()
{
        dpkg -l | grep -q postgresql

        if      [[ $(echo $?) -eq 0 ]] ; then
                echo "PostgreSQL detected"
                echo "It works only with MariaDB and MySQL"
                exit 6
        fi
}

upgrade_ubuntu_debian ()
{
        echo "Downloading and installing packages for $OS"
        sudo dpkg --purge zabbix-release
#	case $2 in
		"5.2")
			curl -O "${debian_version[$1]}"
        		sudo dpkg -i zabbix-release_5.2-1+$OS$(lsb_release -sr)_all.deb
		;;

		"5.4")
			curl -O "${debian_version[$2]}"
			sudo dpkg -i zabbix-release_5.4-1+$OS$(lsb_release -sr)_all.deb
		;;

		*)
			exit 9
		;;

#	esac
        sudo apt update
        sudo apt install -y --only-upgrade zabbix-server-mysql zabbix-frontend-php
        sudo systemctl reload-or-restart zabbix-server.service zabbix-agent.service
}

upgrade_rhel ()
{
        echo "Downloading and installing packages for $OS"
        if [ -z $(command -v yum) ]; then
                pkgm="dnf"
        else
                pkgm="yum"
        fi
#	case $2 in
		"5.2")
			rpm -Uvh "${rhel_version[$1]}"
		;;

		"5.4")
			rpm -Uvh "${rhel_version[$2]}"
		;;

		*)
			exit 99
		;;

#	esac
        sudo $pkgm clean all
        sudo $pkgm upgrade -y zabbix-server-mysql zabbix-web-mysql
        sudo systemctl reload-or-restart zabbix-server.service zabbix-agent.service
}

conditions ()
{
	if      [ -z $OS ] ; then
			echo "Try '$0 --help' for more information."
			exit 1

	elif    [[ $OS == "--help" ]] ; then
			echo "First argument (mandatory) :"
			echo "ubuntu / debian / rhel"
			echo "Second argument (mandatory) :"
			echo "5.2 / 5.4"
			echo "For instance, you want to install zabbix agent and use ubuntu :"
			echo "$0 ubuntu 5.2"
			exit 6
	elif	[ $# -ne 2 ] ; then
			echo "Missing arguments"
			exit 3
	elif	[ $# -eq 2 ] ; then
		if !	[[ $1 == ubuntu || $1 == debian || $1 == rhel ]] ; then
			echo "Indicate as first argument one of these : ubuntu / debian / rhel (case sensitive)"
			exit 2
		elif !	[[ $2 == 5.2 || $2 == 5.4 ]] ; then
			echo "Indicate as second argument one of these : 5.2 / 5.4 (case sensitive)"
			exit 22
		fi

	elif    [[ $UID -eq 0 ]] ; then
			echo "Run as user"
			exit 5
	fi
}

#-------------------#
#       Start       #
#-------------------#

conditions $OS $2

echo -e "You can follow your upgrade with :\ntail -f /var/log/zabbix/zabbix_server.log\ntail -f /var/log/zabbix/zabbix_proxy.log (if you've got proxy)" ; sleep 5

check_installed_database

#       Zabbix server and frontend

if	[[ $OS == ubuntu || $OS == debian ]] ; then
		upgrade_ubuntu_debian $OS $2
else
		upgrade_rhel $OS $2
fi

#	Check the upgrade status with the command

cat /var/log/zabbix/zabbix_server.log | grep database

#	Check if the upgrade was successful

sudo zabbix_server -V | grep zabbix_server
