# description
# installation of Zabbix agent for Windows
# last update : 2021 01 27
# version number 1

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

# download Zabbix agent on the user's desktop
Invoke-WebRequest https://www.zabbix.com/downloads/5.0.1/zabbix_agent-5.0.1-windows-amd64-openssl.zip -OutFile "$DirectoryPath\zabbix_agent-5.0.1-windows-amd64-openssl.zip"

# unzip Zabbix agent
Expand-Archive -LiteralPath "$DirectoryPath\zabbix_agent-5.0.1-windows-amd64-openssl.zip" -DestinationPath "$DirectoryPath\" -Confirm:$false

# create a new directory called "Zabbix"
New-Item -Path "C:\Program Files\" -Name "Zabbix" -ItemType "directory"

# Copy file to Zabbix directory
Copy-Item "$DirectoryPath\zabbix_agent-5.0.1-windows-amd64-openssl\bin\zabbix_agentd.exe" -Destination "C:\Program Files\Zabbix"
Copy-Item "$DirectoryPath\zabbix_agent-5.0.1-windows-amd64-openssl\conf\zabbix_agentd.conf" -Destination "C:\Program Files\Zabbix"

## "Sed" to edit configuration file

# set the IP address for Server
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "Server=.*", "ServerActive=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

# set the IP address for ServerActive
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "ServerActive=.*", "ServerActive=$IpAddr"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

# define HostMetadataItem
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "# HostMetadataItem=", "HostMetadataItem=system.uname"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

# set up dynamically "Hostname"
Get-Content "C:\Program Files\Zabbix\zabbix_agentd.conf" | %{$_ -replace "# HostnameItem=system.hostname", "HostnameItem=system.hostname[host]"} | Set-Content "C:\Program Files\Zabbix\zabbix_agentd.conf"

# installation
"C:\Program Files\Zabbix\zabbix_agentd.exe" -c "C:\Program Files\Zabbix\zabbix_agentd.conf" -i
