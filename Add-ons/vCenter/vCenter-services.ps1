# ENV Vars
# $env:HOME = "/usr/share/zabbix/"
# $env:PSModulePath += ":/opt/microsoft/powershell/7-lts/Modules"

# Connection
$vCenter = $args[0]
$BaseUri = "https://$vcenter/rest/"
$SessionUri = $BaseUri + "com/vmware/cis/session"
$FolderPath = "/usr/local/share/powershell/Credentials"

# Service
$ServiceName = $args[1]
$Type = $args[2]

$Credential = Import-Clixml -Path "$FolderPath/$vCenter"

$Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName + ':' + $Credential.GetNetworkCredential().Password))
$Header = @{'Authorization' = "Basic $Auth"}

# -SkipCertificateCheck additional option
$AuthResponse = (Invoke-RestMethod -Method Post -Headers $Header -Uri $SessionUri -SkipCertificateCheck).Value
$SessionHeader = @{"vmware-api-session-id" = $AuthResponse }

# -SkipCertificateCheck additional option
$Result = Invoke-Restmethod -Method Get -Headers $SessionHeader -Uri ($BaseUri + "vcenter/services") -SkipCertificateCheck
$Output = $result.value.value | select Name_Key, $Type | where { $_.Name_Key -like "*.$ServiceName.*" }
#$Output = $result.value.value | select Name_Key, State, Health
$Output.$Type
#$Output