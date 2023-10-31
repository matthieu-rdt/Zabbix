#!/bin/bash

update ()
{
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove
	sudo apt autoclean
	sudo apt clean
}

update

echo 'Installing PowerShell'
wget https://github.com/PowerShell/PowerShell/releases/download/v7.2.14/powershell-lts_7.2.14-1.deb_amd64.deb
sudo dpkg -i powershell-lts_7.2.14-1.deb_amd64.deb
sudo apt install powershell-lts

echo 'Downloading Microsoft profile'
wget https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/PowerShell/Microsoft.PowerShell_profile.ps1
cp Microsoft.PowerShell_profile.ps1 -t $HOME/.config/powershell
#cp Microsoft.PowerShell_profile.ps1 -t /root/.config/powershell

echo 'Preparing environment'
sudo touch /etc/profile.d/powershell.sh
echo 'export PWSH_SCRIPTS_DIR="/usr/local/share/powershell/Scripts"' | sudo tee /etc/profile.d/powershell.sh
