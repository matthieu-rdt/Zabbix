#!/bin/bash

CONFIG_FILE="${DIR}/${FILE}"
DIR="/etc/apache2/sites-available"
FILE=""
FQDN=$(hostname -f)

sudo apt-get install locate > /dev/null
sudo updatedb
sudo locate *.c[es]r && sudo locate *.key

if [ $? -eq 1 ] ; then
	echo "Some files are missing (*.cer, *.key)"
	exit 2
fi

cat << EOF >> $CONFIG_FILE
<VirtualHost *:443>
	ServerAdmin info@example.com
	ServerName $FQDN
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
EOF

sudo a2enmod ssl
sudo a2ensite $FILE
sudo systemctl reload apache2.service
