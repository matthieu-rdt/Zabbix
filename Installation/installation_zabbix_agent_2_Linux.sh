#!/bin/bash

# description
# installation of zabbix agent 2 for several distros : 
ubuntu, 
debian, 
rhel

# sources
# https://www.zabbix.com/documentation/current/manual/concepts/agent2
# https://bestmonitoringtools.com/zabbix-agent-linux-install-on-ubuntu-centos-rhel-debian-rasbian/
# https://fedoraproject.org/wiki/EPEL

#-----------------------#
#       Variables       #
#-----------------------#

ip_server=""

#-----------------------#
#	Functions	#
#-----------------------#

install_zabbix_agent2_ubuntu_debian ()
{
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt install zabbix-agent2 -y
}

install_zabbix_agent2_rhel ()
{
	sudo yum check-update && sudo yum update
	sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
	sudo yum install zabbix-agent2 -y
}

edit_ipserver_hostmetadata_hostname ()
{
	sudo cp -p /etc/zabbix/zabbix_agent2.conf /etc/zabbix/zabbix_agent2.conf.back
	sudo sed -i "s/^Server=.*/Server=$ip_server/" /etc/zabbix/zabbix_agent2.conf # not for server Z
	sudo sed -i "s/^ServerActive=.*/ServerActive=$ip_server/" /etc/zabbix/zabbix_agent2.conf # not for server Z
	sudo sed -i "s/# HostMetadataItem=/HostMetadataItem=system.uname/g" /etc/zabbix/zabbix_agent2.conf # set up dynamically HostMetadata

#	You can either leave the default hostname or set it up dynamically
	sudo sed -i "s/Hostname=Zabbix server/# Hostname=Zabbix server/g" /etc/zabbix/zabbix_agent2.conf
	sudo sed -i "s/# HostnameItem=system.hostname/HostnameItem=system.hostname/g" /etc/zabbix/zabbix_agent2.conf # set up dynamically "Hostname"
}

ufw_configuration ()
{
	yes | sudo ufw enable
	sudo ufw allow 22/tcp
	sudo ufw allow 10050/tcp
	sudo ufw allow 10051/tcp
}

firewall_configuration () 
{
	sudo firewall-cmd --permanent --add-port=22/tcp
	sudo firewall-cmd --permanent --add-port=10050/tcp
	sudo firewall-cmd --permanent --add-port=10051/tcp
	sudo firewall-cmd --reload
}

enable_zabbix-agent2 ()
{
	sudo systemctl enable zabbix-agent2
	sudo systemctl reload-or-restart zabbix-agent2
	sudo apt-get autoremove -y
}

disable_zabbix_agent ()
{
	sudo systemctl disable zabbix-agent
	sudo systemctl stop zabbix-agent
}

#-------------------#
#	Start	    #
#-------------------#

if	[ -z $1 ] ; then
       		echo "Try '$0 --help' for more information."
        	exit 1

elif	[[ $1 == "--help" ]] ; then
		echo "First argument (mandatory) :"
		echo "ubuntu / debian / rhel"
		echo "Second argument (optional) :"
		echo "--disable-zabbix-agent"
		echo "Note : if you already installed Zabbix agent, to use Zabbix agent 2, this argument is mandatory"
		echo "For instance, you want to install zabbix agent 2 and so to disable zabbix agent :"
		echo "$0 ubuntu --disable-zabbix-agent"
		exit 6

elif	[ $# -gt 2 ] ; then
        	echo "Only two parameters (maximum) are required"
        	exit 2

elif !	[[ $1 == ubuntu || $1 == debian || $1 == rhel ]] ; then
        	echo "Indicate one of these : ubuntu / debian / rhel (case sensitive)"
        	exit 3
		
elif	[[ $ip_server == "" ]] ; then
        	echo "edit 'ip_server', line 14"
        	exit 4
		
elif	[[ $UID -eq 0 ]] ; then 
		echo "Run as user"
		exit 5
fi
 

if	[[ $1 == ubuntu || $1 == debian ]] ; then
		install_zabbix_agent2_ubuntu_debian
		edit_ipserver_hostmetadata_hostname
		ufw_configuration
		enable_zabbix-agent2
		if	[[ $2 == "--disable-zabbix-agent" ]] ; then
				disable_zabbix_agent
else
		install_zabbix_agent2_rhel
		edit_ipserver_hostmetadata_hostname
		firewall_configuration
		enable_zabbix-agent2
		if	[[ $2 == "--disable-zabbix-agent" ]] ; then
				disable_zabbix_agent
fi
