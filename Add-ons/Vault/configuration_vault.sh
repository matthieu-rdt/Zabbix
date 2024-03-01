#!/bin/bash

# description
# configuration Vault for : Ubuntu, Debian, RHEL

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
CONFIG_FILE=/etc/vault.d/vault.hcl
FILE=$HOME/vault.hcl"
FQDN=$(hostname -f)
IP_ADDR=""
STORAGE_PATH=""

cert_key ()
{
	cp /etc/ssl/certs/$FQDN.cer /opt/vault/tls/
	cp /etc/ssl/certs/$FQDN.key /opt/vault/tls/
}

vault_hcl ()
{
	if	[ ! -f "$FILE" ] ; then
		curl -sO https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/Vault/vault.hcl
	fi

	while IFS= read -r line ; do
	echo $line | sudo tee -a $CONFIG_FILE > /dev/null
	done < $FILE
}

permissions ()
{
	cd /opt/vault/
	chmod -R 600 *
	chown -R vault:vault *
}

cert_key

vault_hcl

permissions

touch /var/log/vault.log
