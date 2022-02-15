#!/bin/bash

# description
# Initialisation before to start from a clone or a template

#-----------------------#
#	Functions	#
#-----------------------#

update () {

# 	Update packages
	sudo apt update 
	sudo apt upgrade -y
	sudo apt autoremove -y

# 	Installating VMware tools & sudo
	sudo apt install open-vm-tools sudo -y
}

change_the_hostname () {
#	Get old hostname
	old=$(hostname)

#	New hostname fulfilled by user
	read -p 'your new hostname : ' hostname
	sudo hostnamectl set-hostname $hostname

#	Modifying "hostname.home" and "hostname" at the second line
	grep -w $old /etc/hosts | sudo sed -i "2s/$old/$hostname/g" /etc/hosts
}

check_net_int_conf_file () {
#	For Debian
	grep -w allow-hotplug /etc/network/interfaces 2> /dev/null
	if	[[ $(echo $?) -eq 0 ]] ; then
		sudo sed -i 's/allow-hotplug/auto/' /etc/network/interfaces
	fi
}

create_an_user () {
	read -p 'write your NEW username : ' username
	read -ps 'write your NEW password : ' password

#	Creating new user and /home
# Info:	useradd is native binary compiled with the system / adduser is a perl script which uses useradd binary in back-end
	sudo useradd $username --create-home --home /home/$username/ --groups sudo --shell /bin/bash --password $password
}

# Inactive
pwd_root () {
	if !	[[ $UID -eq 0 || $(pwd) == "/root" ]] ; then 
		echo "Run 'su root' & 'mv $0 -t /root/'"
		echo "And then"
		echo "Run 'su - root' ; $0'"
		exit 1
	fi
}

#-------------------#
#	Start	    #
#-------------------#

update

change_the_hostname

echo "Root password"
sudo passwd root

check_net_int_conf_file

create_an_user

#	Message
echo "'logout' to use your new login : $username"
