#!/bin/bash

# description
# create a user management with low privilege policy

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
FQDN=$(hostname -f)
STORAGE_PATH=""
