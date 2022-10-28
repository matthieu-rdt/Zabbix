#!/bin/bash

remote_user=""

sync_important_files=(
"path/file/to/save"
)

grep -E --quiet '=""$' $0
if [ $? -eq 0 ] ; then
	echo 'fulfil variable user'
	exit 3
fi

sudo apt list rsync
if [ $? -eq 1 ] ; then
	sudo apt install rsync
fi

for file in "${sync_important_files[@]}" ; do
	# if $file is a file AND if line does not start with #
	if [[ -f $file && ! $file =~ ^# ]] ; then
		rsync -az --delete $file $remote_user:$file
	fi
done
