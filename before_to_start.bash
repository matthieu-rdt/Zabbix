#!/bin/bash

# description
# before to start from clone or template
# last update : 2021 08 18
# version number : 1

#-----------------------#
#	Functions	#
#-----------------------#

change_the_hostname () {
	# on recupere le hostname a changer
	old=$(hostname)

	# modifie le hostname par celui ecrit par l'utilisateur
	read -p 'your new hostname : ' hostname
	hostnamectl set-hostname $hostname

	# modifie le "hostname.home" et le "hostname" a la deuxième ligne
	grep -w $old /etc/hosts |  sed -i "2s/$old/$hostname/g" /etc/hosts # grep cherche l'ancien hostname et sed remplace par le nouveau
}

create_an_user () {
	read -p 'write the OLD login name : ' old_user
	read -p 'write the NEW login name : ' new_user

	# creation du nouvel utilisateur et son /home
	# useradd is native binary compiled with the system. But, adduser is a perl script which uses useradd binary in back-end
	useradd $new_user --home /home/$new_user/ --create-home --groups sudo --shell /bin/bash

	# mot de passe pour le nouvel utilisateur
	passwd $new_user

	# suppression de l'ancien utilisateur
	pkill -9 -u $old_user && userdel --remove $old_user
}

check_net_int_conf_file () {
	grep -quiet allow-hotplug /etc/network/interfaces 2> /dev/null
	if	[[ $(echo $?) -eq 0 ]] ; then
		sed -i 's/allow-hotplug/auto/' /etc/network/interfaces
	fi
}

#-------------------#
#	Start	    #
#-------------------#

# si ce n est pas root OU qu on n est pas dans /root
if	[[ $UID -ne 0 || $(pwd) != "/root" ]] ; then 
		echo "Run 'su root' & 'mv $0 -t /root/'"
		echo "And then"
		echo "Run 'su - root' ; $0'"
		exit 1
fi

# update packages
apt update && apt -y upgrade && apt -y autoremove

# VMware tools & sudo
apt -y install open-vm-tools sudo

change_the_hostname

passwd root

check_net_int_conf_file

# message
echo "shut the VM down & feel free to make a snapshot before going further !" ; sleep 5

create_an_user
