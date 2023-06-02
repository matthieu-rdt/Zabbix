#!/bin/bash

FQDN=$(hostname -f)
config_file=

sudo locate *.c[es]r
if [ $? -eq 1 ] ; then
	echo "Some files are missing (*.cer, *.key)"
	exit 2
fi

cat << EOF >> $config_file
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
sudo systemctl reload apache2.service
