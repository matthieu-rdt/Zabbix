#!/bin/bash

# Name of the 'Host' in $HOME/.ssh/config
remote_host=""

# Path of the script to make some changes after rsync
script_path="$(pwd)/make_changes_after_rsync.sh"

#-----------------------#
#	Functions       #
#-----------------------#

red_text ()
{
	echo -e "\033[0;31m$1\033[0m"
}

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

	# if $file is a file AND if line does not start with #
	if [[ -f $file && ! $file =~ ^# ]] ; then
		rsync -avz --delete $file $remote_host:$file
	fi
}

apply_further_changes ()
{
	if	[ -x "$script_path" ] ; then
		path_sync_files_list="$(pwd)/sync_files_list.txt"
		# Change dynamically path at each iteration
		sed -i 's|source.*|source '$path_sync_files_list'|' "$script_path"
		# Change dynamically path at each iteration (directory after ssh <host> = /root)
		sed -i '/# mandatory to apply some changes if needed/a '$path_sync_files_list "$path_sync_files_list"
		ssh $remote_host "$(< $script_path)"
	fi
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

if	[ ! -f "$(pwd)/sync_files_list.txt" ] || [ ! -f "$(pwd)/make_changes_after_rsync.sh" ] ; then
	echo "Downloading sync_files_list.txt"
	curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Backup/sync_files_list.txt"
	red_text "Open sync_files_list.txt and add the files you want to synchronise"

	echo "Downloading make_changes_after_rsync.sh"
	curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Backup/make_changes_after_rsync.sh"
	exit 4
else
	source "$(pwd)/sync_files_list.txt"
fi

check_ssh_config

grep -E --quiet '=""$' $0
if	[ $? -eq 0 ] ; then
	echo 'fulfil variables'
	exit 5
fi


for file in "${sync_important_files[@]}" ; do
	ssh $remote_host "if ! [ -d $file ] ; then mkdir -p $(dirname $file) ; fi"
	ssh $remote_host cat $file | diff - $file
	if [ $? -eq 1 ] ; then
		echo "Changes found at $(date "+%T") on $(date "+%A %d %B %Y")"
		sync_all_files
	fi
done

apply_further_changes
