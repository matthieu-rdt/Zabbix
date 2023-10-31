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
