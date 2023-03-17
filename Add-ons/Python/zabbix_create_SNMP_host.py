#!/bin/bash

while IFS=';' read -r host ip dns
do
curl --header "Content-Type: application/json" --request POST --data '{
           "jsonrpc": "2.0",
           "method": "host.create",
           "params": {
               "host": "'$host'",
               "interfaces": [
                   {
                       "type": 2,
                       "main": 1,
                       "useip": 1,
                       "ip": "'$ip'",
                       "dns": "'$dns'",
                       "port": "161",
                       "details": {
                           "version": 3,
                           "bulk": 0,
                           "securityname": "mysecurityname",
                           "contextname": "",
                           "securitylevel": 1
                       }
                   }
               ],
               "groups": [
                   {
                       "groupid": "4"
                   }
               ]
           },
           "auth": "your_token_here"
           "id": 1
}' "http://ip/zabbix/api_jsonrpc.php"
done < hosts_list.csv
