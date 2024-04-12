#!/bin/bash

#-----------#
# Variables #
#-----------#

DATABASE="zabbix"
DEST_HOST="$1"
DEST_FOLDER=""
LOG_FILE=""
SQL_FILE=""
USERNAME=""

#-----------#
# Functions #
#-----------#

check_vars ()
{
        var_names=("$@")
        for var_name in "${var_names[@]}"; do
                [ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
        done
                [ -n "$var_unset" ] && exit 1
        return 0
}

get_current_datetime () {
        date +"on_%F_at_%T"
}

#-------#
# Start #
#-------#

if	[ $# -ne 1 ] ; then
	echo "Please provide a destination host"
	exit 2
fi

check_vars DATABASE DEST_HOST DEST_FOLDER LOG_FILE SQL_FILE USERNAME

echo "sync started $(get_current_datetime)" >> $LOG_FILE

mysqldump -h localhost -u $USERNAME --single-transaction -B $DATABASE | gzip > $SQL_FILE.gz

echo "rsync copy started $(get_current_datetime)" >> $LOG_FILE

rsync -ahPvz $SQL_FILE.gz $DEST_HOST:$DEST_FOLDER

echo "sync completed $(get_current_datetime)" >> $LOG_FILE
