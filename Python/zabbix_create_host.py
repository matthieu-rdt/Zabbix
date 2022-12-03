#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""https://www.zabbix.com/documentation/current/en/manual/api/reference/hostinterface/object"""

from os.path import exists as file_exists
from pyzabbix import ZabbixAPI
from progressbar import ProgressBar, Percentage, ETA, ReverseBar, RotatingMarker, Timer
import csv

CSV_FILE = "/home/mark/hosts_list.csv"
ZABBIX_API_ADDRESS = "http://ip/zabbix"
USER = ""
PASSWORD = ""

# Edit IP address
zapi = ZabbixAPI(ZABBIX_API_ADDRESS)
# Credentials by default
zapi.login(user=USER, password=PASSWORD)

arq = csv.reader(open(CSV_FILE))

lines = sum(1 for line in arq)

f = csv.reader(open(CSV_FILE), delimiter=';')
bar = ProgressBar(maxval=lines, widgets=[Percentage(), ReverseBar(), ETA(), RotatingMarker(), Timer()]).start()

for i, [hostname, ip, dns, group] in enumerate(f):
    zapi.host.create(
        host=hostname,
        status=1,
        interfaces=[{
            'type': 1,
            'main': 1,
            'useip': 1,
            'ip': ip,
            'dns': str(dns),
            'port': 10050
        }],
        groups=[{
            'groupid': int(group)
        }],
        templates=[{
            'templateid': 10001
        }]
    )
    
    bar.update(i)

bar.finish
print(" ")
