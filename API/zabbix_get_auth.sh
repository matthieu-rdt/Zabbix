#!/bin/bash

user=""
password=""
IP=""

# Get "auth" to connect to Zabbix
curl --header "Content-Type: application/json" --request POST --data '{
"jsonrpc": "2.0",
"method": "user.login",
"params": {"user": "$user", "password": "$password"},
"id": 1,
"auth": null}' "http://$IP/zabbix/api_jsonrpc.php"

