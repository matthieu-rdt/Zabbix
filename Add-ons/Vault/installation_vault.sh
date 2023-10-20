#!/bin/bash

# description
# installation Zabbix Agent for : Ubuntu, Debian, RHEL
# compatible versions : from Ubuntu 14.04 to 20.04, from Debian 8 to 11, from RHEL 5 to 8

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

#w/ root
install_with_root ()
{
	apt install gpg -y
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
	apt-get update && apt-get install vault
}

#w/o root
install_without_root ()
{
	sudo apt install gpg -y
	wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt-get update && sudo apt-get install vault
}

if [ $(whoami) = root ] ; then
	install_with_root
else
	install_without_root
fi
