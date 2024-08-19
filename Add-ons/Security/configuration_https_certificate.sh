#!/bin/bash

CER_DIR=$PWD/CER/$(date +%Y)
FILE="zabbix.conf"
FQDN=$(hostname -f)

check_files () {
	sudo apt-get install locate > /dev/null
	sudo find $CER_DIR -type f \( -name "*.cer" -o -name "*.key" \)

	if [ $? -eq 1 ] ; then
		echo "Some files are missing (*.cer, *.key)"
		exit 2
	fi
}

check_files

cp $CER_DIR/$FQDN.cer -t /etc/ssl/certs && echo "Cert moved successfully" || echo "$FQDN.cer not found"
cp $CER_DIR/$FQDN.key -t /etc/ssl/private && echo "Private key moved successfully" || echo "$FQDN.key not found"

sudo a2enmod ssl
sudo a2ensite $FILE
sudo systemctl restart apache2.service
