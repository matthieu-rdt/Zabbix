#!/bin/bash

# Name of the 'Host' in $HOME/.ssh/config
remote_host=""

sync_important_files=(
# add a comment
'path/file/to/save'
)

#-----------------------#
#	Functions       #
#-----------------------#

sync_all_files ()
{
	# if $file is a file AND if line does not start with #
	if [[ -f $file && ! $file =~ ^# ]] ; then
		rsync -avz --delete $file $remote_host:$file
	fi
}

#-------------------#
#       Start       #
#-------------------#

if	[ -z $remote_host ] ; then
	echo 'fulfil variable remote_host'
	exit 3
fi

grep -qw 'Host' $HOME/.ssh/config
if	[ $? -eq 1 ] ; then
	echo 'No shortcuts found in the config file'
	echo 'Visit https://linuxize.com/post/using-the-ssh-config-file/ for further information'
	echo 'Downloading SSH script'
	wget https://raw.githubusercontent.com/matthieu-rdt/Toolbox/master/Linux/SSH.sh && chmod u+x SSH.sh
	exit 4
fi

sudo apt list rsync
if	[ $? -eq 1 ] ; then
	echo 'Installing rsync'
	sudo apt-get install rsync -y
fi

for file in "${sync_important_files[@]}" ; do
	ssh $remote_host "if ! [ -d $file ] ; then mkdir -p $(dirname $file) ; fi"
	ssh $remote_host cat $file | diff - $file
	if [ $? -eq 1 ] ; then
		echo 'Changes found at $(date "+%T") on $(date "+%A %d %B %Y")'
		sync_all_files
	fi
done
