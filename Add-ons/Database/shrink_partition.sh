#!/bin/bash

size=""
# S - 512 byte sectors
# K - kilobytes
# M - megabytes
# G - gigabytes

echo "stop services"
systemctl stop zabbix-server.service
systemctl stop mariadb.service
umount -l /zabbix_database

echo "disk operations"
e2fsck -f /dev/sdb1
resize2fs /dev/sdb1 $size
cfdisk /dev/sdb
mount -a

echo "check"
df -h
echo "start services"
systemctl start mariadb.service
systemctl start zabbix-server.service
