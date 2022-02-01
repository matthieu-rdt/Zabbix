## Zabbix management scripts

### To prepare your environment to use Zabbix API :
\- preparation_zabbix_API.sh

### These variables must be completed

> #### Line 13
> `zbx_username`
>
> #### Line 14
> `zbx_password`
>
> #### Line 15
> `zbx_api`

### Syntax
```
./preparation_zabbix_API.sh
```

***


### To create or delete host groups, you can use :
\- zabbix_host_groups.sh

### Syntax
```
./zabbix_host_groups.sh file_to_add.txt file_to_del.txt
```

***

### After exporting your hosts/templates, this script allows you to import them through a list you must indicated as parameter :
\- import_hosts_templates.sh


### Syntax
```
./import_hosts_templates.sh templates_list.txt
```
