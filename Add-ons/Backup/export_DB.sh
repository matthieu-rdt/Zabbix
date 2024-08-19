#!/bin/bash

#-----------#
# Variables #
#-----------#

export DATABASE="zabbix"
export ROOT_FOLDER="/zabbix_database"
export DUMP_FOLDER="${ROOT_FOLDER}/backup/database_$(date +%F)"
export LOG_FILE="${ROOT_FOLDER}/logs/transfer_logs_$(date +%F).txt"
export SQL_FILE="${DUMP_FOLDER}/zabbix_backup_$(date +%F).sql"
export USERNAME="root"

#-----------#
# Functions #
#-----------#

check_vars () {
	var_names=("$@")
	for var_name in "${var_names[@]}"; do
		[ -z "${!var_name}" ] && echo "$var_name is unset." && var_unset=true
	done
		[ -n "$var_unset" ] && exit 1
	return 0
}

get_current_datetime () {
	date +"on %F at %T"
}

#-------#
# Start #
#-------#

check_vars DATABASE ROOT_FOLDER DUMP_FOLDER LOG_FILE SQL_FILE USERNAME

echo "export started $(get_current_datetime)" >> $LOG_FILE

if !	[ -d $DUMP_FOLDER ] ; then
	mkdir -p $DUMP_FOLDER
fi
#	mysqldump -h localhost -u $USERNAME --single-transaction -B $DATABASE | gzip > $SQL_FILE.gz
	touch $SQL_FILE.gz
