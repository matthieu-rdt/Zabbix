#!/bin/bash

# description
# configuration Vault for : Ubuntu, Debian, RHEL

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
FQDN=$(hostname -f)
STORAGE_PATH=""

systemctl stop vault

###################
# Copy cert & key #
###################
cp /etc/ssl/certs/$FQDN.cer /opt/vault/tls/
cp /etc/ssl/private/$FQDN.key /opt/vault/tls/

#########################
# Configure permissions #
#########################
# Cert & Key permissions
chmod 600 /opt/vault/tls/*
chown -R vault:vault /opt/vault

# Configuration file permission
chmod 644 /etc/vault.d/vault.hcl
chown vault:vault /etc/vault.d/vault.hcl

# Log file permission
touch /var/log/vault.log
chown vault:vault /var/log/vault.log

# Data Storage permission
chmod 755 $STORAGE_PATH
chown -R vault:vault $STORAGE_PATH

systemctl start vault
