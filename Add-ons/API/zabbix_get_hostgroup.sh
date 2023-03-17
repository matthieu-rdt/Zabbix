#!/bin/bash

# Note
# Change 'Discovered hosts' by another Host group of your choice to retrieve its id to add your hosts automatically

IP=""

curl --header "Content-Type: application/json" --request POST --data
'{
"jsonrpc": "2.0",
"method": "hostgroup.get",
"params":
{
    "output": [ "groupid"],
    "filter":{"name":["Discovered hosts"] }
},
"id": 1,
"auth": ""
}' http://$IP/zabbix/api_jsonrpc.php
