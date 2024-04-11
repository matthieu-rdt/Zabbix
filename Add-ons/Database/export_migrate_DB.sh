#!/bin/bash

#-----------#
# Variables #
#-----------#

DATABASE="zabbix"
DEST_HOST="$1"
DEST_FOLDER=""
DAY_HOUR="$(date +"%F")-at-$(date +"%T")"
LOG_FILENAME=""
LOG_FILE="${LOG_FILENAME}-${DAY_HOUR}"
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

#-------#
# Start #
#-------#

if	[ $# -ne 1 ] ; then
	echo "Please provide a destination host"
	exit 2
fi

check_vars DATABASE DEST_HOST DEST_FOLDER DAY_HOUR LOG_FILENAME LOG_FILE SQL_FILE USERNAME

echo "sync started on $DAY_HOUR" >> $LOG_FILE

mysqldump -h localhost -u $USERNAME --single-transaction -B $DATABASE | gzip > $SQL_FILE.gz

echo "rsync copy started at $DAY_HOUR" >> $LOG_FILE

rsync -ahPvz $SQL_FILE.gz $DEST_HOST:$DEST_FOLDER

echo "sync completed at $DAY_HOUR" >> $LOG_FILE
