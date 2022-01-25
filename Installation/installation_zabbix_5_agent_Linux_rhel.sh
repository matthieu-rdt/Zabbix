#!/bin/bash

# description
# installation of Zabbix agent for rhel
# last update : 2021 06 01
# version number : 2

# sources
# https://www.zabbix.com/documentation/current/manual
# https://bestmonitoringtools.com/zabbix-agent-linux-install-on-ubuntu-centos-rhel-debian-rasbian/
# https://fedoraproject.org/wiki/EPEL

#-----------------------#
#	Functions	#
#-----------------------#

install_zabbix_agent_rhel ()
{
	sudo $pktm check-update && sudo $pktm update
	sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	
	rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release- 5.0-1.el$(rpm -E %{rhel}).noarch.rpm
	sudo $pktm clean all
	sudo $pktm install zabbix-agent -y
}

firewall_configuration () 
{
	sudo firewall-cmd --permanent --add-port=22/tcp
	sudo firewall-cmd --permanent --add-port=10050/tcp
	sudo firewall-cmd --permanent --add-port=10051/tcp
	sudo firewall-cmd --reload
}

enable_zabbix-agent ()
{
	sudo systemctl enable zabbix-agent
	sudo systemctl reload-or-restart zabbix-agent
	sudo $pktm autoremove -y
}

#-------------------#
#	Start	    #
#-------------------#

if	[ -z $1 ] ; then
        	echo "Run $0 rhel"
        	exit 1

elif	[ $# -ne 1 ] ; then
        	echo "Only one parameter is required"
        	exit 2

elif !	[[ $1 == rhel ]] ; then
        	echo "Indicate rhel (case sensitive)"
        	exit 3

elif	[[ $UID -eq 0 ]] ; then 
		echo "Run as user"
		exit 5
elif
	if [ -z $(command -v yum) ]; then
		pktm="dnf"
	else
		pktm="yum"
	fi
fi

install_zabbix_agent_rhel

firewall_configuration

enable_zabbix-agent
