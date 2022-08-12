#!/bin/bash

FQDN=$(hostname -f)
zabbix_conf=/etc/apache2/sites-available/zabbix.conf

sudo locate $FQDN > /dev/null
if [ $? -eq 1 ] ; then
	echo "Some files are missing (*.cer, *.key)"
fi

cat << EOF >> $zabbix_conf
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
EOF
