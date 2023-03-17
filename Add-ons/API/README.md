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

### To create a single or multiple host groups, you can use :
\- zabbix_host_groups.sh

### Example #1

```bash
./zabbix_host_groups.sh one_host_group
```

### Example #2

```bash
./zabbix_host_groups.sh host_groups_list.txt
```

***
