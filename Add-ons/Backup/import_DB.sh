#!/bin/bash

export DATABASE="zabbix"
export ROOT_FOLDER="/zabbix_database"
export DUMP_FOLDER="${ROOT_FOLDER}/backup/database_$(date +%F)"
export SQL_FILE="${DUMP_FOLDER}/zabbix_backup_$(date +%F).sql"
export USERNAME="root"

gunzip $SQL_FILE.gz && mysql -u $USERNAME -b $DATABASE < $SQL_FILE
