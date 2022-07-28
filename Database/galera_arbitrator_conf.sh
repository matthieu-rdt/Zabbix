#!/bin/bash

# description
# setup Galera Arbitrator for avoiding split-brain situations

sudo apt install galera-arbitrator-4

#	Configuration file
sudo vi /etc/default/garb

sudo service garb start
