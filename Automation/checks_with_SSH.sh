#!/bin/bash

# description
# Running a job by using SSH from Zabbix server to a host

# sources
# https://www.zabbix.com/documentation/current/en/manual/web_interface/frontend_sections/administration/scripts

#	Remote host credentials
USER=""
IP=""
KEYNAME=""

if	[ $(whoami) != root ] ; then
	echo 'RUN AS ROOT'
	exit 2
fi

if	[ -z $USER ] || [ -z $IP ] && [ -z $KEYNAME ] ; then
	echo 'Fulfil variables'
	exit 3
fi

sed -i '/# SSHKeyLocation=/a SSHKeyLocation=\/home\/zabbix\/.ssh/' /etc/zabbix/zabbix_server.conf

grep -E '^zabbix' /etc/passwd | sed 's|/var/lib|/home|' /etc/passwd

systemctl restart zabbix-server.service

sudo -u zabbix ssh-keygen -t rsa -b 4096

if	[ -n $KEYNAME ] ; then
	sudo -u zabbix ssh-copy-id -i /home/zabbix/.ssh/$KEYNAME $USER@$IP
else
	sudo -u zabbix ssh-copy-id $USER@$IP
fi
