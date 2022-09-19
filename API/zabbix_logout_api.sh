#!/bin/bash

IP=""

# Logout from Zabbix API
curl --header "Content-Type: application/json" --request POST --data '{
"jsonrpc": "2.0",
"method": "user.logout",
"params": {},
"id": 2,
"auth": "186f9f0a1d77c893d0c39641fafb1c7z" }' "http://$IP/zabbix/api_jsonrpc.php"
