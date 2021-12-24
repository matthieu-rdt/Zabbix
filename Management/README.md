# Zabbix management scripts
* ## preparation_zabbix_API.sh
To prepare your environment to use Zabbix API

### These variables must be completed

#### Line 13
* #### zbx_username

#### Line 14
* #### zbx_password

#### Line 15
* #### zbx_api

### Syntax
```
./preparation_zabbix_API.sh
```

***

* ## zabbix_host_groups.sh
To create or delete host groups

### Syntax
```
./zabbix_host_groups.sh file_to_add.txt file_to_del.txt
```

***

* ## import_hosts_templates.sh
After exporting your hosts/templates, this script allows you to import them through a list you must indicated as parameter

### Syntax
```
./import_hosts_templates.sh templates_list.txt
```
