## Scripts for installing and/or upgrading Zabbix

### To install Zabbix server, you can use :
\- installation_zabbix_5_server.sh
> #### First, fill in these variables, lines 21 to 23
> `root_password` <br/>
> `user_password` <br/>
> `backup_password`
>
> #### As argument, you can use :
> `ubuntu` <br/>
> `debian`

### Example
```
./installation_zabbix_5_server.sh ubuntu
```

***

### To install/upgrade Zabbix agent, you can use :
\- installation_or_upgrade_zabbix_5_agent_Linux.sh <br/>
\- installation_or_upgrade_zabbix_5.2_agent_Linux.sh

> #### First, fill in this variable, line 17
> `ip_server`
>
> #### As first argument, you can use :
> `install` <br/>
> `upgrade`
>
> #### As second argument, you can use :
> `ubuntu` <br/>
> `debian` <br/>
> `rhel`

### Example
```
./installation_or_upgrade_zabbix_5_agent_Linux.sh install ubuntu
```

***

### To install/upgrade Zabbix agent 2, you can use :
\- installation_zabbix_agent_2_Linux.sh <br/>

> #### First, fill in this variable, line 17
> `ip_server`
> #### Note : 
> `If you already installed Zabbix agent, to use Zabbix agent 2, Zabbix agent must be uninstalled`

### Example
```
./installation_zabbix_agent_2_Linux.sh ubuntu --disable-zabbix-agent
```

***

### To install/upgrade Zabbix agent Windows, you can use :
\- installation_zabbix_agent_Windows.ps1 <br/>

> #### Edit the path where to save Zabbix agent
> `$DirectoryPath`
> 
> #### Set IP address of Zabbix server
> `$IpAddr`

### Example
```
./installation_zabbix_agent_Windows.ps1
```
