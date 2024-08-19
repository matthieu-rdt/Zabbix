#!/bin/bash

CONFIG="$1"
FQDN=$(hostname -f)

openssl genrsa -out $FQDN.key 4096

if      [ -z $CONFIG ] ; then
        openssl req -new -key $FQDN.key -out $FQDN.csr -sha256
else
        openssl req -new -key $FQDN.key -out $FQDN.csr -sha256 -config $CONFIG
fi

mkdir -p CER/$(date +%Y)
mv $FQDN.csr -t CER/$(date +%Y)
mv $FQDN.key -t CER/$(date +%Y)
