#!/bin/bash

# description
# configuration Vault for : Ubuntu, Debian, RHEL

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
FILE=$HOME/vault.hcl
FQDN=$(hostname -f)
IP_ADDR=""
STORAGE_PATH=""

cert_key ()
{
	cp /etc/ssl/certs/$FQDN.cer /opt/vault/tls/
	cp /etc/ssl/private/$FQDN.key /opt/vault/tls/
}

vault_hcl ()
{
	while IFS= read -r line ; do
	echo $line | sudo tee -a /etc/vault.d/vault.hcl > /dev/null
	done < $FILE
}

permissions ()
{
	cd /opt/vault/
	chmod -R 600 *
	chown -R vault:vault *
}

if      [ ! -f "$FILE" ] ; then
	curl -sO https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Add-ons/Vault/vault.hcl
fi

cert_key

vault_hcl $FILE

permissions

touch /var/log/vault.log
