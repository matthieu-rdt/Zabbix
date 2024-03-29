#!/bin/bash

# Work in progress
#auth=`cat $filename | sed 's/.*result":"\([a-zA-Z0-9].*\).*/\1/'`
#sed -i '51s/"auth": ".*"/"auth": "'$token'" }'

filename=`mktemp /tmp/result_XXX_$$`

ConfirmChoice ()
{
	ConfYorN="";
	while [ "${ConfYorN}" != "y" ] && [ "${ConfYorN}" != "Y" ] && [ "${ConfYorN}" != "n" ] && [ "${ConfYorN}" != "N" ]
	do
		echo -n "$1" "(y/n) : "
		read ConfYorN
	done
	[ "${ConfYorN}" == "y" ] || [ "${ConfYorN}" == "Y" ] && return 0 || return 1
}

if      [[ $1 == login ]] ; then
        read -p 'Your Zabbix username ' user
        read -sp 'Your Zabbix password ' password
        read -p 'Your Zabbix URL (example : 192.181.1.2) ' IP
elif    [[ $1 == logout ]] ; then
        read -p 'Your Zabbix URL (example : 192.181.1.2) ' IP
else
	echo 'no parameters'
	exit 2
fi

# Get "auth" to connect to Zabbix
login ()
{
        curl --header "Content-Type: application/json" --request POST --data
	'{
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {"user": "'$user'"'', "password": "'$password'"''},
        "id": 1,
        "auth": null
	}' "http://$IP/zabbix/api_jsonrpc.php"
}

login > $filename
token=`cat $filename | cut -d':' -f3 | cut -d'"' -f2`
sed -i "52s/jeton/$token/" $0

# Logout from Zabbix API
logout ()
{
	curl --header "Content-Type: application/json" --request POST --data
	'{
	"jsonrpc": "2.0",
	"method": "user.logout",
	"params": {},
	"id": 2,
	"auth": "jeton"
	}' "http://$IP/zabbix/api_jsonrpc.php"
}

ConfirmChoice "Do you want to connect to Zabbix API" && login
ConfirmChoice "Do you want to disconnect to Zabbix API" && logout
