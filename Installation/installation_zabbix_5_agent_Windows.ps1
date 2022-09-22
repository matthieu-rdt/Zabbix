# description
# installation of Zabbix agent for Windows

# sources :
# https://www.zabbix.com/documentation/current/manual/concepts/agent
# https://www.zabbix.com/documentation/current/manual/appendix/install/windows_agent

# RUN AS ADMIN

# Edit the path where to save zabbix agent directory
$DirectoryPath = "C:\your\path\to\directory"

# Set IP address of Zabbix server
$IpAddr = "1.2.3.4"

# Zabbix agent version filename
$ZabbixAgentVersion = "zabbix_agent-5.0.28-windows-amd64-openssl"

# Test the path exists
if ( (Test-Path -Path $DirectoryPath) -eq $false ) 
{
	Write-Host 'edit $DirectoryPath'
	exit
}

# Test the IP exists
if ( $IpAddr -eq '1.2.3.4' ) 
{
	Write-Host 'edit $IpAddr'
	exit
}

#	Create a new directory called "Zabbix"
New-Item -Path "C:\Program Files\" -Name "Zabbix" -ItemType "directory"

#	Download Zabbix agent on the user's desktop
Invoke-WebRequest https://cdn.zabbix.com/zabbix/binaries/stable/5.0/5.0.28/$ZabbixAgentVersion.zip -OutFile "$DirectoryPath\$ZabbixAgentVersion.zip"

# Test Zabbix agent exists
if ( (Test-Path -Path $DirectoryPath\$ZabbixAgentVersion.zip) -eq $false )
{
	Write-Host 'edit $ZabbixAgentVersion'
	exit
}

#	Unzip Zabbix agent
Expand-Archive -Path "$DirectoryPath\$ZabbixAgentVersion.zip" -DestinationPath "$DirectoryPath" -Confirm:$false

#	Copy file to Zabbix directory
Copy-Item "$DirectoryPath\bin\zabbix_agentd.exe" -Destination "C:\Program Files\Zabbix"

##	"Sed" to edit configuration file

#	Set the IP address for Server
Get-Content "$DirectoryPath\$ZabbixAgentVersion\conf\zabbix_agentd.conf" | %{$_ -replace "Server=127.0.0.1", "Server=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Set the IP address for ServerActive
Get-Content "$DirectoryPath\$ZabbixAgentVersion\conf\zabbix_agentd.conf" | %{$_ -replace "ServerActive=127.0.0.1", "ServerActive=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Define HostMetadataItem
Get-Content "$DirectoryPath\$ZabbixAgentVersion\conf\zabbix_agentd.conf" | %{$_ -replace '# HostMetadataItem=', "HostMetadataItem=system.uname"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Set up dynamically "Hostname"
Get-Content "$DirectoryPath\$ZabbixAgentVersion\conf\zabbix_agentd.conf" | %{$_ -replace '# HostnameItem=system.hostname', "HostnameItem=system.hostname[host]"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Installation
"C:\Program Files\Zabbix\zabbix_agentd.exe" -c "C:\Program Files\Zabbix\zabbix_agentd.conf" -i
