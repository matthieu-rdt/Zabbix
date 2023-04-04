#!/bin/bash 

# Description
# Export templates from Zabbix & sort them by site

#-----------------------#
#       Variables       #
#-----------------------#

ZABBIX_URL=$(hostname -f)
USER=""

#-----------------------#
#	Functions	#
#-----------------------#

preparation ()
{
	if	[ -f /etc/profile.d/password.sh ] ; then
		sudo touch /etc/profile.d/password.sh
	fi

	read -sp 'Your Zabbix GUI password ' passwd
	password=$(echo $passwd | openssl enc -aes-256-cbc  -a -salt -pbkdf2|base64)
	echo "export ZABBIX_PASSWORD=$password" | sudo tee /etc/profile.d/password.sh > /dev/null

	grep -Eq 'export ZABBIX_PASSWORD=[a-zA-Z].*' /etc/profile.d/password.sh
	if	[ $? -eq 1 ] ; then
		echo 'ZABBIX_PASSWORD is empty'
		exit 3
	fi

	echo "Zabbix password is encrypted and ready to use to export objects !"
	exit 2
}


#-----------------------#
#	Start		#
#-----------------------#

if	[ -z $USER ] ; then
	echo 'USER is not provided'
	exit 4
fi

preparation 

./zabbix-export.py --save-yaml --zabbix-url http://$ZABBIX_URL --zabbix-username $USER --zabbix-password $ZABBIX_PASSWORD --only templates

cd templates

#	Remove blank spaces in template names
for f in *\ *; do mv "$f" "${f// /_}"; done

for d in Brest Chennai Colombes Illkirch Saint-Pete Shanghai; do mkdir $d; done

find . -name '*_BRE_MatthieuR.yaml' | xargs mv -t Brest
find . -name '*_AnandS.yaml' | xargs mv -t Chennai
find . -name '*_COL_LLe.yaml' | xargs mv -t Colombes
find . -name '*_ILL_LLe.yaml' | xargs mv -t Illkirch
find . -name '*_SPB.yaml' | xargs mv -t Saint-Pete
find . -name '*_SHA_JimW.yaml' | xargs mv -t Shanghai

mkdir ../our_templates

mv Brest Chennai Colombes Illkirch Saint-Pete Shanghai -t ../our_templates

cd ../our_templates
