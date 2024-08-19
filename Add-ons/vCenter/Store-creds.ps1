# Set and encrypt credentials to file using default method

# Change vCenter FQDN according to your env
$vCenter = $args[0]

# Change folder path to store credentials
$FolderPath = "/usr/local/share/powershell/Credentials"

if (Test-Path -Path $FolderPath) {
        "$FolderPath exists"
}
else {
        New-Item "$FolderPath" -Type Directory
}

$Credential = Get-Credential
$Credential | Export-CliXml -Path "$FolderPath/$vCenter"