#!/bin/bash

#-----------#
# Variables #
#-----------#

DATABASE=""
DEST_HOST=""
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

#-------#
# Start #
#-------#

check_vars DATABASE DEST_HOST DEST_FOLDER LOG_FILE SQL_FILE USERNAME

echo "sync started on $(date +"%F") at $(date +"%T")" >> $LOG_FILE

mysqldump -h localhost -u $USERNAME --single-transaction -B $DATABASE > $SQL_FILE ; gzip $SQL_FILE

echo "rsync copy started at $(date +"%F") at $(date +"%T") >> $LOG_FILE

rsync -ahPvz $SQL_FILE.gz $DEST_HOST:$DEST_FOLDER

echo "sync completed at $(date +"%F") at $(date +"%T") >> $LOG_FILE
