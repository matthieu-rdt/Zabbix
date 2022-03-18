#!/bin/bash

#-----------------------#
#	Variables	#
#-----------------------#

include_path=(
"/tome"
)

#-----------------------#
#	Functions	#
#-----------------------#

conditions ()
{
	lsb_release -i | cut -d':' -f2 | grep -E '[DU].*'
	if [ $(echo $?) -ne 0 ] ; then
		echo "Only Works with Debian-based"
		exit 1
	fi

	if [ ${include_path[$1]} == "/tome" ] ; then
		echo "Edit your paths, here is an example :"
		echo "/home"
		echo "/etc"
		echo "Or simply '/'"
		exit 2
	fi
}

clamd_conf ()
{
	for i in ${include_path[@]}
	do
		echo "OnAccessIncludePath $i" | sudo tee -a /etc/clamav/clamd.conf > /dev/null
	done

	echo "OnAccessExcludeUname clamav" | sudo tee -a /etc/clamav/clamd.conf > /dev/null
	echo "OnAccessPrevention yes" | sudo tee -a /etc/clamav/clamd.conf > /dev/null
	echo "OnAccessDisableDDD yes" | sudo tee -a /etc/clamav/clamd.conf > /dev/null

	sudo sed -i "s/LocalSocketGroup clamav/LocalSocketGroup root/" /etc/clamav/clamd.conf
	sudo sed -i "s/User clamav/User root/" /etc/clamav/clamd.conf
}

clamonacc () 
{
	sudo touch /etc/systemd/system/clamonacc.service

	echo "[Unit]" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "Description=ClamAV On Access Scanner" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "Requires=clamav-daemon.service" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "After=clamav-daemon.service" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "After=syslog.target" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "After=network-online.target" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "[Service]" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "Type=simple" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "User=root" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "ExecStartPre=/bin/bash -c "while [ ! -S /var/run/clamav/clamd.ctl ]; do sleep 1; done"" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "ExecStart=/usr/sbin/clamonacc -F --fdpass --config-file=/etc/clamav/clamd.conf --log=/var/log/clamav/clamonacc.log" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "[Install]" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null
	echo "WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/clamonacc.service > /dev/null

	sudo chmod 644 /etc/systemd/system/clamonacc.service
	sudo systemctl enable --now clamonacc
}

#-------------------#
#	Start	    #
#-------------------#

conditions

sudo apt update && sudo apt install clamav clamav-daemon

sudo service clamav-freshclam stop
sudo freshclam
sudo service clamav-freshclam start

sudo systemctl start clamav-daemon

clamd_conf

clamonacc

sudo systemctl restart clamav-daemon

sudo apt install curl
echo "Scan test" && sleep 3
curl https://www.eicar.org/download/eicar.com.txt | clamdscan -
