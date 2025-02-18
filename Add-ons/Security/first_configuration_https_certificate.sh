#!/bin/bash

CER_DIR=$HOME/CER/$(date +%Y)
DIR="/etc/apache2/sites-available"
FILE="zabbix.conf"
CONFIG_FILE="${DIR}/${FILE}"
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

sudo cp $CER_DIR/$FQDN.cer -t /etc/ssl/certs && echo "Cert moved successfully" || echo "$FQDN.cer not found"
sudo cp $CER_DIR/$FQDN.key -t /etc/ssl/private && echo "Private key moved successfully" || echo "$FQDN.key not found"

cat << EOF >> $CONFIG_FILE
<VirtualHost *:443>
	ServerAdmin info@example.com
	ServerName $FQDN/zabbix
	ServerAlias www.example.com

	DocumentRoot /usr/share/zabbix/

	# SSL configuration
	SSLEngine on
	SSLCertificateFile /etc/ssl/certs/$FQDN.cer
	SSLCertificateKeyFile /etc/ssl/private/$FQDN.key

	# Log files
#	ErrorLog /var/www/html/example.com/log/error.log
#	CustomLog /var/www/html/example.com/log/access.log combined
</VirtualHost>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

sudo a2enmod ssl
sudo a2ensite $FILE
sudo systemctl restart apache2.service
