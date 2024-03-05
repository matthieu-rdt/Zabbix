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

vault_hcl () {
echo "# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: BUSL-1.1

# Full configuration options can be found at https://developer.hashicorp.com/vault/docs/configuration

# Log Section
log_level = "info"
log_file = "/var/log/vault.log"

# Enable Web Interface
ui = true

# Storage Type
storage "file" {
path = \""$STORAGE_PATH"\"
}

# HTTPS listener
listener "tcp" {
address       = "$IP_ADDR:8200"
tls_cert_file = "/opt/vault/tls/$FQDN.cer"
tls_key_file  = "/opt/vault/tls/$FQDN.key"
tls_disable = false
}

# HA Parameters
#api_addr = "https://$FQDN:8200"
#cluster_addr = "https://$FQDN:8201"

## Options
# HTTP listener
#listener "tcp" {
#  address     = "17.18.19.0:8200"
#  tls_disable = 1
#}

# RAFT storage
#storage "raft" {
#  path = "/opt/vault/data"
#  node_id = "node_1"
#}" | tee /etc/vault.d/vault.hcl }

permissions ()
{
	# Certificate & Key permissions
	chmod 600 /opt/vault/tls/*
	chown -R vault:vault /opt/vault

	# Log file permission
	touch /var/log/vault.log
	chown vault:vault /var/log/vault.log

	# Data Storage permission
	chmod 755 $STORAGE_PATH
	chown -R vault:vault $STORAGE_PATH
}

cert_key

vault_hcl

permissions
