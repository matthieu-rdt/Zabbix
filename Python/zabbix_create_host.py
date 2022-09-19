#!/usr/bin/env python
# -*- coding: utf-8 -*-

from pyzabbix import ZabbixAPI
import csv
from progressbar import ProgressBar, Percentage, ETA, ReverseBar, RotatingMarker, Timer

zapi = ZabbixAPI("http://172.25.160.141/zabbix")
zapi.login(user="Admin", password="zabbix")

arq = csv.reader(open('/home/test/host_list.csv'))

lines = sum(1 for line in arq)

f = csv.reader(open('/home/test/host_list.csv'), delimiter=';')
bar = ProgressBar(maxval=lines, widgets=[
                  Percentage(), ReverseBar(), ETA(), RotatingMarker(), Timer()]).start()
i = 0

for [hostname, ip] in f:
    CreateHost = zapi.host.create(
        host=hostname,
        status=1,
        interfaces=[{
            "type": 1,
            "main": "1",
            "useip": 1,
            "ip": ip,
            "dns": "",
            "port": 10050
        }],
        groups=[{
            "groupid": 2
        }],
        templates=[{
            "templateid": 10001
        }]
    )

    i += 1
    bar.update(i)

bar.finish
print(" ")
