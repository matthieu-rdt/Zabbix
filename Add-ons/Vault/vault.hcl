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
  path = "/opt/vault/data"
}

# HTTPS listener
listener "tcp" {
  address       = "IP_ADDRESS:8200"
  tls_cert_file = "/opt/vault/tls/FQDN.cer"
  tls_key_file  = "/opt/vault/tls/FQDN.key"
  tls_disable = false
}

# HA Parameters
#api_addr = "https://FQDN:8200"
#cluster_addr = "https://FQDN:8201"

## Options
# HTTP listener
#listener "tcp" {
#  address       = "IP_ADDRESS:8200"
#  tls_disable = 1
#}

# RAFT storage
#storage "raft" {
#  path = "/opt/vault/data"
#  node_id = "node_1"
#}
