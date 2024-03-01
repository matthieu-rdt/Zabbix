#!/bin/bash

# description
# configuration Vault for : Ubuntu, Debian, RHEL

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
CONFIG_FILE=/etc/vault.d/vault.hcl
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
	cat << EOF > $CONFIG_FILE
	# Copyright (c) HashiCorp, Inc.
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
	#}

	EOF
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
