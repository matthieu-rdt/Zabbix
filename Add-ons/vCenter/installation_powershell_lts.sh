#!/bin/bash

FILE=powershell_7.4.1-1.deb_amd64.deb

update ()
{
	sudo apt update
	sudo apt upgrade -y
	sudo apt autoremove -y
}

update

echo 'Installing PowerShell'
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/$FILE
sudo dpkg -i $FILE
sudo apt-get install -f

echo 'To fine-tune your environment, you can download the files below'
echo 'File : startup_personal_profile.ps1'
echo 'File : Microsoft.PowerShell_profile.ps1'

# sudo cp Microsoft.PowerShell_profile.ps1 -t $HOME/.config/powershell

echo 'To prepare environment if any'
# sudo touch /etc/profile.d/powershell.sh
# echo 'export PWSH_SCRIPTS_DIR="/usr/local/share/powershell/Scripts"' | sudo tee /etc/profile.d/powershell.sh
# source /etc/profile.d/powershell.sh
