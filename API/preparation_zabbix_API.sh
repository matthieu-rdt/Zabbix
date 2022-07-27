#!/bin/bash

# description
# preparation for using Zabbix API and python script as admin tools

# sources
# https://github.com/q1x/zabbix-gnomes
# https://github.com/southbridgeio/zabbix-review-export-import
# https://github.com/selivan/zabbix-import

zbx_username=""
zbx_password=""
zbx_api=""

#-----------------------#
#	Functions	#
#-----------------------#

home ()
{
	if [[ $(pwd) != $HOME ]] ; then
	cd $HOME
	fi
}

check_variables ()
{
	grep -E --quiet '=""$' $0
	if	[ $? -eq 0 ] ; then
		echo "The variables list is empty"
		exit 2
	fi
}

update ()
{
	sudo apt update
	sudo apt upgrade -y 
	sudo apt autoremove -y 
	sudo apt install git -y
} 

installing_python_and_pip ()
{
	#	If not already installed
	sudo apt install python python3 -y 
	sudo apt install python3-pip -y
	
	#	Set Python3 as default
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
	
	#	Upgrading pip if needed
	python -m pip install --upgrade pip
}

scripts ()
{
	scripts=(
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/requirements.txt"
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/zabbix-export.py"
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/zabbix-import.py"
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/zgcreate.py"
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/zgdelete.py"
	"https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Python/zgetinventory.py"
	)

	for line in "${scripts[@]}" ; do
	curl -sO $line
	done
}

preparation_installation_pip  ()
{
	#	Required for using Zabbix API
	python -m pip install pyzabbix
	
	#	Useful for beautifying python code
	# python -m pip install flake8
	
	#	For working with graphs (zgetgraph.py specifically) install Pillow (a fork of PIL):
	# python -m pip install pillow
	
	#	Make modules executable in $HOME
	source ~/.profile
	echo "source ~/.profile has been run"
}

zbx_conf ()
{
	zbx_conf=(
	""
	"Fulfilling '.zbx.conf'"
	""
	"[Zabbix API]"
	"username=$zbx_username"
	"password=$zbx_password"
	"api=$zbx_api"
	"no_verify=true"
	)

	for line in "${zbx_conf[@]}" ; do
	echo $line >> $HOME/.zbx.conf
	done
}

help_menu ()
{
	help_menu=(
	""
	"----- Help Menu -----"
	""
	"To add multiple host groups : ./zgcreate.py hostgroup hostgroup2 hostgroup3"
	"To delete multiple host groups : ./zgdelete.py -N hostgroup hostgroup2 hostgroup3 # does not work w/o -N"
	""
	"To display help menu : ./zabbix-export.py --help"
	"To backup all hosts in the current folder & to save as XML format : ./zabbix-export.py --zabbix-url https://zabbix.example.com --zabbix-username user --zabbix-password password --only hosts"
	""
	)

	for line in "${help_menu[@]}" ; do
	echo $line
	done
}

#-------------------#
#	Start	    #
#-------------------#

home

check_variables

update

installing_python_and_pip

scripts

preparation_installation_pip

zbx_conf

help_menu
