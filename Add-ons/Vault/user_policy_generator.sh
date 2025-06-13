#!/bin/bash

# description
# create a user role with a low-privilege policy

# sources
# https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started
# https://www.tharunshiv.com/vault-setup/

# Variables
SITE=""
USERNAME=""

cat >> $USERNAME.hcl << EOF
# gives user full rights to manage $SITE credentials
path "$SITE/*" {
  capabilities = ["create", "read", "update", "patch", "delete", "list"]
}

# allow user to see authentication methods
path "/sys/auth" {
  capabilities = ["read", "list"]
}

# allow user to see users' list in userpass method
path "/auth/userpass/users/*" {
  capabilities = ["read", "list"]
}

# allow user '$USERNAME' to update its password
path "auth/userpass/users/$USERNAME" {
  capabilities = ["read", "list", "update"]
}

# allow user '' to see the policies' list
path "/sys/policies/acl/*" {
  capabilities = ["read", "list"]
}
EOF

# apply to vault
vault policy write $USERNAME $USERNAME.hcl

# apply policy to user
vault write auth/userpass/users/$USERNAME \
password=$USERNAME \
policies=$USERNAME
