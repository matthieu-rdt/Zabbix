#!/bin/bash

FILE=powershell_7.4.1-1.deb_amd64.deb

update ()
{
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove -y
	sudo apt autoclean
	sudo apt clean
}

update

echo 'Installing PowerShell'
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/$FILE
sudo dpkg -i $FILE
sudo apt install powershell-lts

echo 'Downloading files'
echo 'File : startup_personal_profile.ps1'
wget https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/PowerShell/startup_personal_profile.ps1
echo 'File : Microsoft.PowerShell_profile.ps1'
wget https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/PowerShell/Microsoft.PowerShell_profile.ps1

chmod u+x startup_personal_profile.ps1 && pwsh startup_personal_profile.ps1
cp Microsoft.PowerShell_profile.ps1 -t $HOME/.config/powershell

echo 'Preparing environment'
sudo touch /etc/profile.d/powershell.sh
echo 'export PWSH_SCRIPTS_DIR="/usr/local/share/powershell/Scripts"' | sudo tee /etc/profile.d/powershell.sh
source /etc/profile.d/powershell.sh
