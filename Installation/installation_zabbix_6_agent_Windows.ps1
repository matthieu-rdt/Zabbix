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

# Test the path exists
if ( (Test-Path -Path $DirectoryPath) -eq $false ) 
{
	Write-Host 'edit $DirectoryPath, line 12'
	break
}

# Test the IP exists
if ( $IpAddr -eq '1.2.3.4' ) 
{
	Write-Host "edit $IpAddr, line 14"
	break
}

#	Download Zabbix agent on the user's desktop
Invoke-WebRequest https://cdn.zabbix.com/zabbix/binaries/stable/6.0/6.0.9/zabbix_agent-6.0.9-windows-amd64-openssl.zip -OutFile "$DirectoryPath\zabbix_agent-6.0.9-windows-amd64-openssl.zip

#	Unzip Zabbix agent
Expand-Archive -LiteralPath "$DirectoryPath\zabbix_agent-6.0.9-windows-amd64-openssl.zip" -DestinationPath "$DirectoryPath\" -Confirm:$false

#	Create a new directory called "Zabbix"
New-Item -Path "C:\Program Files\" -Name "Zabbix" -ItemType "directory"

#	Copy file to Zabbix directory
Copy-Item "$DirectoryPath\zabbix_agent-6.0.9-windows-amd64-openssl\bin\zabbix_agentd.exe" -Destination "C:\Program Files\Zabbix"
Copy-Item "$DirectoryPath\zabbix_agent-6.0.9-windows-amd64-openssl\conf\zabbix_agentd.conf" -Destination "C:\Program Files\Zabbix"

##	"Sed" to edit configuration file

#	Set the IP address for Server
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "Server=.*", "Server=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Set the IP address for ServerActive
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "ServerActive=.*", "ServerActive=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Define HostMetadataItem
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "# HostMetadataItem=", "HostMetadataItem=system.uname"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Set up dynamically "Hostname"
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "# HostnameItem=system.hostname", "HostnameItem=system.hostname[host]"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

#	Installation
"C:\Program Files\Zabbix\zabbix_agentd.exe" -c "C:\Program Files\Zabbix\zabbix_agentd.conf" -i
