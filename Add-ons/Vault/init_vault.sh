#!/bin/bash

# description
# initialisation Vault server

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

ENV_VARS_FILE=""
FQDN=$(hostname -f)
INIT_FILE=/opt/vault/init_vault.txt

setup_env ()
{
	cat << EOF > $ENV_VARS_FILE
	export VAULT_ADDR="https://$FQDN:8200"
	export VAULT_CACERT="/opt/vault/tls/$FQDN.cer"
	export VAULT_TOKEN="$TOKEN"
	EOF
}

permissions ()
{
	cd /opt/vault/
	chmod -R 600 *
	chown -R vault:vault *
}

vault operator init > $INIT_FILE

TOKEN="$(grep 'Initial Root Token:' $INIT_FILE | awk '{print $NF}')"

setup_env

permissions
