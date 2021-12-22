#!/bin/bash

# description
# preparation for using Zabbix API and python script as admin tools
# last update : 2021 12 09
# version number : 1

# sources
# https://github.com/q1x/zabbix-gnomes
# https://github.com/southbridgeio/zabbix-review-export-import
# https://github.com/selivan/zabbix-import

zbx_username=""
zbx_password=""
zbx_api=""

#-----------------------#
#		Functions		#
#-----------------------#

home ()
{
	if [[ $(pwd) != $HOME ]] ; then
	cd $HOME
	fi
}

check_variables ()
{
	if [[ $zbx_username == "" ]] ; then
		echo "zbx_username is missing"
		exit 1
	elif [[ $zbx_password == "" ]] ; then
		echo "zbx_password is missing"
		exit 2
	elif [[ $zbx_api == "" ]] ; then
		echo "zbx_api is missing"
		exit 3
	fi
}

update ()
{
	sudo apt update
	sudo apt upgrade -y 
	sudo apt autoremove -y 
} 

installing_python_and_pip ()
{
	sudo apt install python python3 -y # if not already installed
	sudo apt install python-pip python3-pip -y
	
	#--	Set Python3 as default
	sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
	
	#--	Useful for ?
	# sudo apt install python3-distutils
	
	#--	Upgrading pip if needed
	python -m pip install --upgrade pip
}

git_repositories ()
{
	sudo apt install git -y
	git clone https://github.com/q1x/zabbix-gnomes && touch $HOME/.zbx.conf
	git clone https://github.com/southbridgeio/zabbix-review-export-import && python -m pip install -r zabbix-review-export-import/requirements.txt
	git clone https://github.com/selivan/zabbix-import && chmod u+x $HOME/zabbix-import/zbx-import.py
}

preparation_installation_pip  ()
{
	#--	Required for using Zabbix API
	python -m pip install pyzabbix
	
	#--	Useful for beautifying python code
	# python -m pip install flake8
	
	#--	For working with graphs (zgetgraph.py specifically) install Pillow (a fork of PIL):
	# python -m pip install pillow
	
	#--	ModuleNotFoundError: No module named 'ConfigParser'
	python -m pip install configparser
	
	#--	Useful for formatting python code
	python -m pip install autopep8
	
	#--	Make modules executable in $HOME
	source ~/.profile
	echo "source ~/.profile has been run"
	
	#-- PEP 8 (for Python Extension Proposal) to make python code consistent
	autopep8 -i $HOME/zabbix-gnomes/*.py
	autopep8 -i $HOME/zabbix-import/*.py
	autopep8 -i $HOME/zabbix-review-export-import/*.py
	
	#--	Edit 'module import' for each python file in zabbix-gnomes folder
	sudo sed -i 's/import ConfigParser/import configparser/' $HOME/zabbix-gnomes/*.py
	
	#--	Correct unexpected issues with this module & replacement
	if [[ $(grep "Config = ConfigParser.ConfigParser()" $HOME/zabbix-gnomes/*.py) ]] ; then
		sudo sed -i 's/Config = ConfigParser.ConfigParser()/Config = configparser.ConfigParser()/' $HOME/zabbix-gnomes/*.py
	fi
}

zbx_conf ()
{
	echo ""
	echo "Fulfilling '.zbx.conf'"
	echo ""
	echo "[Zabbix API]" > $HOME/.zbx.conf
	echo "username=$zbx_username" >> $HOME/.zbx.conf
	echo "password=$zbx_password" >> $HOME/.zbx.conf
	echo "api=$zbx_api" >> $HOME/.zbx.conf
	echo "no_verify=true" >> $HOME/.zbx.conf
}

help_menu ()
{
	echo ""
	echo "----- Help Menu -----"
	echo ""
	echo "In this folder 'zabbix-review-export-import'"
	echo "To add multiple host groups : ./zgcreate.py hostgroup hostgroup2 hostgroup3"
	echo "To delete multiple host groups : ./zgdelete.py -N hostgroup hostgroup2 hostgroup3 # does not work w/o -N"
	echo ""
	echo "In this folder 'zabbix-gnomes'"
	echo "To display help menu : ./zabbix-export.py --help"
	echo "To backup all hosts in the current folder & to save as XML format : ./zabbix-export.py --zabbix-url https://zabbix.example.com --zabbix-username user --zabbix-password password --only hosts"
	echo ""
}

#-------------------#
#		Start		#
#-------------------#
home

check_variables

update

installing_python_and_pip

git_repositories

preparation_installation_pip

zbx_conf

help_menu