## Scripts for upgrading Zabbix server

### To upgrade Zabbix server 5

\- upgrade_zabbix_server_to_5.sh

> #### First, fill in these variables, lines 20 to 21
>
> `backup_password`  
> `database_name`  
>
> #### As argument, you can use
>
> `ubuntu`  
> `debian`  
> `rhel`

### Example

```bash
./upgrade_zabbix_server_to_5.sh ubuntu
```

***

### To upgrade Zabbix server 5.x

\- upgrade_zabbix_server_to_5.2.sh  
\- upgrade_zabbix_server_to_5.4.sh

> #### As argument, you can use
>
> `ubuntu`  
> `debian`  
> `rhel`

### Example

```bash
./upgrade_zabbix_server_to_5.2.sh rhel
```
