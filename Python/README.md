Python scripts for Zabbix
--

A collection of various scripts to automate tasks with the Zabbix API

### 1) Create hosts by using a CSV file :
-`zabbix_create_host.py`  
-`hosts_list.csv`

#### Usage example
```
./zabbix_create_host.py hosts_list.csv
```

### 2) Export/Import Zabbix objects :
-`zabbix-export.py`  
-`zabbix-import.py`  
-`requirements.txt`

#### Usage example
```
./zgdelete.py -N host
```

### 3) Create or delete Host groups & Get an inventory :
-`zgcreate.py`  
-`zgdelete.py`  
-`zgetinventory.py`

#### Usage example
```
./zgcreate.py host
```

#### Configuration

These programs can use .ini style configuration files to retrieve the needed API connection information.
To use this type of storage, create a conf file (the default is $HOME/.zbx.conf) that contains at least the [Zabbix API] section and any of the other parameters:

```
[Zabbix API]
username=johndoe
password=verysecretpassword
api=https://zabbix.mycompany.com/path/to/zabbix/frontend/
no_verify=true
```

Setting `no_verify` to `true` will disable TLS/SSL certificate verification when using https
