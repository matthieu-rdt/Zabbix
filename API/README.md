## Zabbix management scripts

### To prepare your environment to use Zabbix API :
\- preparation_zabbix_API.sh

> #### These variables must be completed, line 13 to 15
>
> `zbx_username`  
> `zbx_password`  
> `zbx_api`

### Example

```bash
./preparation_zabbix_API.sh
```

***

### To create or delete host groups, you can use :
\- zabbix_host_groups.sh

### Example

```bash
./zabbix_host_groups.sh file_to_add.txt file_to_del.txt
```

***

### After exporting your hosts/templates, this script allows you to import them through a list you must indicate as parameter :
\- import_hosts_templates.sh


### Example

```bash
./import_hosts_templates.sh templates_list.txt
```
