#!/bin/bash

#------------------------------------#
# Manage Temporary Files and Signals #
#------------------------------------#

TempFile=/tmp/$(basename ${0}).$(date '+%Y%m%d%H%M%S').$$
trap "rm -f ${TempFile}; exit 1" 1 2 3
trap "rm -f ${TempFile}; exit" 0

#-----------#
# Variables #
#-----------#

export ROOT_FOLDER="/zabbix_database"
export BACKUP_NUMBER="$1"

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

#-------#
# Start #
#-------#

check_vars BACKUP_NUMBER

cd "${ROOT_FOLDER}/backup"
ls -dt database_* | sort > ${TempFile}

BACKUP_ACTUAL_NUMBER=$(wc -l ${TempFile} | cut -d' ' -f1)
(
while [ ${BACKUP_ACTUAL_NUMBER} -gt ${BACKUP_NUMBER} ]
do
        read File
        BACKUP_ACTUAL_NUMBER=$((BACKUP_ACTUAL_NUMBER-1))
        rm -r $File
done
) < ${TempFile}
