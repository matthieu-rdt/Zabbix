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

grep -q 'SSHKeyLocation=/home/zabbix/.ssh' /etc/zabbix/zabbix_server.conf
if	[ $? -eq 1 ] ; then
	sed -i '/# SSHKeyLocation=/a SSHKeyLocation=\/home\/zabbix\/.ssh' /etc/zabbix/zabbix_server.conf
fi

sed -i 's|zabbix:x:108:115::/var/lib/zabbix/:/usr/sbin/nologin|zabbix:x:108:115::/home/zabbix:/usr/sbin/nologin|' /etc/passwd

mkdir -p /home/zabbix/.ssh

chown -R zabbix:zabbix /home/zabbix

systemctl restart zabbix-server.service

if	[ -z $KEYNAME ] ; then
	sudo -u zabbix ssh-keygen -t rsa -b 4096
	sudo -u zabbix ssh-copy-id $USER@$IP
else
	sudo -u zabbix ssh-copy-id -i /home/zabbix/.ssh/$KEYNAME $USER@$IP
fi
