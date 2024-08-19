#!/bin/bash
#
# This shell does backups using rsync
#
# Syntax:$0 -s <backup-source-folder> [-h <destination-host>] -d <backup-destination-folder> [-M <mail-address>]
#-----------------------------------------------------------------------------------------------------------------------------------------------

#-----------#
# Variables #
#-----------#

export BackupSource=""
export BackupDestination=""
export HostDestination=""
export Subject=""
export MailTo=""
while getopts "s:d:h:M:" option; do
	case $option in
	s)
		BackupSource=$OPTARG
		;;
	d)
		BackupDestination=$OPTARG
		;;
	h)
		HostDestination=$OPTARG
		;;
	M)
		MailTo=$OPTARG
		;;
	*)
		exit 1
	esac
done

#-----------#
# Functions #
#-----------#

SendingMessage() {
	if [ "$MailTo" != "" ]
	then
	        MailSubject="Subject:[$(hostname)][$(basename $0)][$1] : ${BackupType} backup of ${BackupSource} to ${BackupDestination}"
		shift
	        (
	        echo "$MailSubject"
	        while [ $# -ne 0 ]
	        do
	                echo $1
	                shift
	        done
	        ) | sendmail -f noreply@al-enterprise.com -v $MailTo
	else
		echo "[$(hostname)][$(basename $0)][$1] : ${BackupType} backup of ${BackupSource} to ${BackupDestination}" 1>&2
		shift
	        while [ $# -ne 0 ]
	        do
	                echo $1
	                shift
	        done
	fi
}

#------------------#
# Check Parameters #
#------------------#

# Backup source value is mandatory and must exist if not remote
#--------------------------------------------------------------
[ ! -d "${BackupSource}" ] && { SendingMessage Failure "$(basename ${0}) $(date '+%F-%T'):Source directory '${BackupSource}' does not exist"; }

# Host destination value is checked
#----------------------------------
ping -c4 -q $HostDestination || { SendingMessage Failure "$(basename ${0}) $(date '+%F-%T'):Host '${HostDestination} is not reachable"; }

# Backup destination value is mandatory
#--------------------------------------
[ "$BackupDestination" = "" ]  && { SendingMessage Failure "$(basename ${0}) $(date '+%F-%T'):Backup destination is mandatory"; }

#-------#
# Start #
#-------#

# Synchronise the source directory with the destination directory 
#----------------------------------------------------------------
if [ "$HostDestination" != "" ]
then
	rsync -av --delete --partial --log-file=$LOG_FILE "${BackupSource}" $HostDestination:"${BackupDestination}" >&2 && SendingMessage Success || SendingMessage Failure
else
	rsync -av --delete --partial --log-file=$LOG_FILE "${BackupSource}" "${BackupDestination}" >&2 && SendingMessage Success || SendingMessage Failure
fi
