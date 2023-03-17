#!/bin/bash

# Name of the 'Host' in $HOME/.ssh/config
remote_host=""

#-----------------------#
#	Functions       #
#-----------------------#

check_ssh_config ()
{
	if	[ ! -d "$HOME/.ssh" ] ; then
		echo "Creating folder .ssh"
		mkdir -p "$HOME/.ssh"
	fi

	if	[ ! -f "$HOME/SSH.sh" ] ; then
		echo 'Downloading SSH script'
		curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Toolbox/master/Linux/SSH.sh" && chmod u+x SSH.sh
		red_text "Run it : ./SSH.sh"
		exit 2
	fi
}

sync_all_files ()
{
	sudo apt list rsync
	if	[ $? -eq 1 ] ; then
		echo 'Installing rsync'
		sudo apt-get install rsync -y
	fi
#	copy the line below and replace <file> with your file
	rsync -av <file> $remote_host:<file> 
}

#-------------------#
#       Start       #
#-------------------#

if	[ $(whoami) != root ] ; then
	echo "Run as root"
	echo "su - root"
	sudo cp $0 -t /root/
	exit 3
fi


check_ssh_config

if	[ -z $remote_host ] ; then
	echo 'fulfil variable remote_host'
	exit 5
fi


sync_all_files
