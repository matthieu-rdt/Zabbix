#!/bin/bash

# description
# stop a database replication

sudo mysql -uroot -e "STOP SLAVE;"
sudo mysql -uroot -e "RESET SLAVE;"
sudo mysql -uroot -e "RESET MASTER;"

sudo systemctl restart mariadb.service
