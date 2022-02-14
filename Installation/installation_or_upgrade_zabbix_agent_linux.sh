#!/bin/bash

# description
# installation of Zabbix agent for multiple distros (ubuntu, debian, rhel)

# sources
# https://www.zabbix.com/documentation/current/manual
# https://bestmonitoringtools.com/zabbix-agent-linux-install-on-ubuntu-centos-rhel-debian-rasbian/
# https://fedoraproject.org/wiki/EPEL

#-----------------------#
#       Arrays		#
#-----------------------#

debian_version=(
"https://repo.zabbix.com/zabbix/5.0/"$2"/pool/main/z/zabbix-release/zabbix-release_5.0-1+$(lsb_release -sc)_all.deb"
"https://repo.zabbix.com/zabbix/5.2/"$2"/pool/main/z/zabbix-release/zabbix-release_5.2-1+"$2$(lsb_release -sr)"_all.deb"
"https://repo.zabbix.com/zabbix/5.4/"$2"/pool/main/z/zabbix-release/zabbix-release_5.4-1+"$2$(lsb_release -sr)"_all.deb"
)

rhel_version=(
"rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.0-1.el$(rpm -E %{rhel}).noarch.rpm"
"rpm -Uvh https://repo.zabbix.com/zabbix/5.2/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.2-1.el$(rpm -E %{rhel}).noarch.rpm"
"rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/$(rpm -E %{rhel})/x86_64/zabbix-release-5.4-1.el$(rpm -E %{rhel}).noarch.rpm"
)

#-----------------------#
#       Variables       #
#-----------------------#

ip_server=""

#-----------------------#
# 	Functions 	#
#-----------------------#

install_or_upgrade_zabbix_agent_debian_ubuntu ()
{
	sudo apt update && sudo apt upgrade -y

case $3 in

	"5.0")
		curl -O "${debian_version[$1]}"
		sudo dpkg -i zabbix-release_5.0-1+$(lsb_release -sc)_all.deb
    	;;

	"5.2")
		curl -O "${debian_version[$2]}"
		sudo dpkg -i zabbix-release_5.2-1+$2$(lsb_release -sr)_all.deb
	;;

	"5.4")
		curl -O "${debian_version[$3]}"
		sudo dpkg -i zabbix-release_5.4-1+$2$(lsb_release -sr)_all.deb
	;;

	*)
		exit 9
    	;;

esac

	sudo apt update
	sudo apt install zabbix-agent -y
}

install_or_upgrade_zabbix_agent_rhel ()
{
	sudo yum check-update && sudo yum update
	sudo sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

case $3 in
	"5.0")
		curl -O "${rhel_version[$1]}"
	;;

	"5.2")
		curl -O "${rhel_version[$2]}"
	;;

	"5.4")
		curl -O "${rhel_version[$3]}"
	;;

	*)
		exit 99
	;;

esac

	sudo yum clean all
	sudo yum install zabbix-agent -y
}

edit_ipserver_hostmetadata_hostname ()
{
	sudo cp -p /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.back
	sudo sed -i "s/^Server=.*/Server=$ip_server/" /etc/zabbix/zabbix_agentd.conf
	sudo sed -i "s/^ServerActive=.*/ServerActive=$ip_server/" /etc/zabbix/zabbix_agentd.conf

#	Set up dynamically HostMetadata
	sudo sed -i "s/# HostMetadataItem=/HostMetadataItem=system.uname/g" /etc/zabbix/zabbix_agentd.conf 

#	You can either leave the default hostname or set it up dynamically
	sudo sed -i "s/Hostname=Zabbix server/# Hostname=Zabbix server/g" /etc/zabbix/zabbix_agentd.conf

#	Set up dynamically "Hostname"
	sudo sed -i "s/# HostnameItem=system.hostname/HostnameItem=system.hostname/g" /etc/zabbix/zabbix_agentd.conf 
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

enable_zabbix-agent ()
{
	sudo systemctl enable zabbix-agent
	sudo systemctl reload-or-restart zabbix-agent
	sudo apt-get autoremove -y
}

#-------------------#
#	Start	    #
#-------------------#

if	[ -z $1 ] ; then
       		echo "Try '$0 --help' for more information."
       		exit 1

elif	[[ $1 == "--help" ]] ; then
		echo "First argument (mandatory) :"
		echo "install / upgrade"
		echo "Second argument (mandatory) :"
		echo "ubuntu / debian / rhel"
		echo "Third argument (mandatory) :"
		echo "5.0 / 5.2 / 5.4"
		echo "For instance, you want to install zabbix agent and use ubuntu :"
		echo "$0 install ubuntu 5.0"
		exit 6

elif	[ $# -eq 3 ] ; then
		if !	[[ $1 == install || $1 == upgrade ]] ; then
			echo "Indicate as first argument one of these : install / upgrade (case sensitive)"
			exit 2
		elif !	[[ $2 == ubuntu || $2 == debian || $2 == rhel ]] ; then
			echo "Indicate as second argument one of these : ubuntu / debian / rhel (case sensitive)"
			exit 22
		elif !	[[ $3 == 5.0 || $3 == 5.2 || $3 == 5.4 ]] ; then
			echo "Indicate as third argument one of these : 5.0 / 5.2 / 5.4 (case sensitive)"
			exit 222
		fi

elif	[ $# -ne 3 ] ; then
		echo "Missing arguments"
		exit 3
		
elif	[[ $1 == install && $ip_server == "" ]] ; then
        	echo "edit 'ip_server', line 14"
        	exit 4
		
elif	[[ $UID -eq 0 ]] ; then 
		echo "Run as user"
		exit 5
fi
 
if	[[ $1 == install ]] ; then
		if	[[ $2 == ubuntu || $2 == debian ]] ; then
			install_or_upgrade_zabbix_agent_debian_ubuntu $1 $2 $3
			edit_ipserver_hostmetadata_hostname
			ufw_configuration
			enable_zabbix-agent
		else
			install_or_upgrade_zabbix_agent_rhel $1 $2 $3
			edit_ipserver_hostmetadata_hostname
			firewall_configuration
			enable_zabbix-agent
		fi

elif	[[ $1 == upgrade ]] ; then
		if	[[ $2 == ubuntu || $2 == debian ]] ; then
			install_or_upgrade_zabbix_agent_debian_ubuntu $1 $2 $3
		else
			install_or_upgrade_zabbix_agent_rhel $1 $2 $3
		fi
fi