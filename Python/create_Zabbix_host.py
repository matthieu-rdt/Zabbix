#!/usr/bin/python

# Author :
# https://github.com/sdestivelle

import argparse
import logging
import time
import os
import json
import xml.dom.minidom
from pyzabbix import ZabbixAPI
from sys import exit
from datetime import datetime

zapi = ZabbixAPI("http://xxxxxxxxx/zabbix/")
zapi.login("api", "zabbix")
tpl_affect = 10226
# host_group = 
# groupid = 


##################################
# Lecture du fichier csv en entree
file = args.file
#file=sys.argv[1]
file = open(file,"r")
file = csv.reader(file, delimiter=';')

#
# test des hostgroup si absent dans Zabbix
#
for [ip_address,host_name,type,host_group] in file:
    print "#### Debut du traitement"
    print "#### Traitement de la ligne: ", file.line_num
    # test que le host n'existe pas,
    host = zapi.host.get(output="extend", filter=({'host':host_name}))
    if len(host)==0:
        print("!!!   Warning - L'hote \""+ host_name + "\" n'existe pas")
        # alors test si le hostgroup n'existe pas
        hg = zapi.hostgroup.get(output="extend", filter=({'name':host_group}))
        if len(hg)==0:
            # alors creer le hostgroup et associe le host
            print("!!!   Warning - Le groupe \""+ host_group + "\" n'existe pas")
            print("***   Update - Creation du groupe: "+ host_group)
            zapi.hostgroup.create({"name": hostgroup})
            hg = zapi.hostgroup.get(output="extend", filter=({'name':host_group}))
            groupid = hg[0]["groupid"]
            print("***   Update - Creation de l'hote: "+ host_name)
            zapi.host.create({"host": host_name,
            "interfaces": [
                {
                    "type": 2,
                    "main": 1,
                    "useip": 1,
                    "ip": ip_address,
                    "dns": "",
                    "port": "161",
                    "bulk": "0",
                    "proxy_hostid": "10309"
                }
            ],
            "groups": [
                {
                    "groupid": groupid
                }
            ],
            "templates": [
                {
                    "templateid": tpl_affect
                }
            ],
            "inventory_mode": 1
            })
        else:
            groupid = hg[0]["groupid"]
            print("***   Update - Mise a jour de l'hote \""+ host_name + "\" avec le groupe \""+ hostgroup + "\"")
            zapi.host.create({"host": host_name,
            "interfaces": [
                {
                    "type": 2,
                    "main": 1,
                    "useip": 1,
                    "ip": ip_address,
                    "dns": "",
                    "port": "161",
                    "bulk": "0",
                    "proxy_hostid": "10309"
                }
            ],
            "groups": [
                {
                    "groupid": groupid
                }
            ],
            "templates": [
                {
                    "templateid": tpl_affect
                }
            ],
            "inventory_mode": 1
            })
    else:
        host = zapi.host.get(output="extend", filter=({'host':host_name}))
        hostid = host[0]["hostid"]
        groupid = hg[0]["groupid"]
        print("***   Update - Mise a jour de l'hote \""+ host_name + "\" avec le groupe \""+ host_group + "\"")
        zapi.hostgroup.massadd(
        {
        "groups": [
            {
                "groupid": groupid
            }
        ],
        "hosts": [
            {
                "hostid": hostid
            }
        ]
        })
print("***   Info - Traitement termine ***")
