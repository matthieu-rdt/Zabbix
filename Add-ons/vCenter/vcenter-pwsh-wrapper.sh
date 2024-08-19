#!/bin/bash

vcenter=$1
service=$2
type=$3
pwsh /usr/local/share/powershell/Scripts/vCenter-Services.ps1 $vcenter $service $type