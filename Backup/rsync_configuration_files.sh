#!/bin/bash

source "$HOME/sync_files_list.txt"

# Name of the 'Host' in $HOME/.ssh/config
remote_host=""

# Path of the script to make some changes after rsync
script_path="$HOME/make_changes_after_rsync.sh"

#-----------------------#
#	Functions       #
#-----------------------#

red_text ()
{
	echo -e "\033[0;31m$1\033[0m"
}

check_ssh_config ()
{
	grep -qw 'Host' $HOME/.ssh/config
	if	[ $? -eq 1 ] || [ $? -eq 2 ] ; then
		echo 'No such file'
		echo 'Visit https://linuxize.com/post/using-the-ssh-config-file/ for further information'
		echo 'Downloading SSH script'
		curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Toolbox/master/Linux/SSH.sh" && chmod u+x SSH.sh
		exit 4
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

#-------------------#
#       Start       #
#-------------------#

required_files=($HOME/sync_files_list.txt,$HOME/make_changes_after_rsync.sh)

if	[ ! -f "${required_files[@]}" ] ; then
	echo "Downloading sync_files_list.txt
	curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Backup/sync_files_list.txt"
	red_text "Open sync_files_list.txt and add the files you want to synchronise"

	echo "Downloading make_changes_after_rsync.sh
	curl -sO "https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Backup/make_changes_after_rsync.sh"
	exit 2
fi

grep -E --quiet '=""$' $0
if	[ $? -eq 0 ] ; then
	echo 'fulfil variables'
	exit 4
fi

check_ssh_config

for file in "${sync_important_files[@]}" ; do
	ssh $remote_host "if ! [ -d $file ] ; then mkdir -p $(dirname $file) ; fi"
	ssh $remote_host cat $file | diff - $file
	if [ $? -eq 1 ] ; then
		echo "Changes found at $(date "+%T") on $(date "+%A %d %B %Y")"
		sync_all_files
	fi
done

ssh $remote_host "$(< $script_path)"
