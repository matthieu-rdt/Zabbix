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

cp $CER_DIR/$FQDN.cer -t /etc/ssl/certs && echo "Cert moved successfully" || echo "$FQDN.cer not found"
cp $CER_DIR/$FQDN.key -t /etc/ssl/private && echo "Private key moved successfully" || echo "$FQDN.key not found"

cat << EOF >> $CONFIG_FILE
<VirtualHost *:443>
	ServerAdmin info@example.com
	ServerName frbrevp-zabbix.bre.voice.ale-international.com/zabbix/
	ServerAlias www.example.com

	DocumentRoot /usr/share/zabbix/

	# SSL configuration
	SSLEngine on
	SSLCertificateFile /etc/ssl/certs/frcol-zabbix-bizop.col.voice.ale-international.com.cer
	SSLCertificateKeyFile /etc/ssl/private/frcol-zabbix-bizop.col.voice.ale-international.com.key

	# Log files
#	ErrorLog /var/www/html/example.com/log/error.log
#	CustomLog /var/www/html/example.com/log/access.log combined
</VirtualHost>
EOF

sudo a2enmod ssl
sudo a2ensite $FILE
sudo systemctl reload apache2.service
