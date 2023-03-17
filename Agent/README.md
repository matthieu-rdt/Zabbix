## Scripts for installing and/or upgrading Zabbix

### To install/upgrade Zabbix agent

\- installation_or_upgrade_zabbix_agent_Linux.sh

> #### First, fill in this variable, line 31
>
> `ip_server`
>
> #### As first argument, you can use
>
> `install`  
> `upgrade`
>
> #### As second argument, you can use
>
> `ubuntu`  
> `debian`  
> `rhel`
> 
> #### As third argument, you can use
>
> `5.0`  
> `5.4`  
> `6.0`

### Example

```bash
./installation_or_upgrade_zabbix_agent_Linux.sh install ubuntu 5.0
```

***

### To install Zabbix agent 2

\- installation_zabbix_agent_2_Linux.sh

> #### First, fill in this variable, line 18
>
> `ip_server`
> 
> #### Note
>
> `If you already installed Zabbix agent, to use Zabbix agent 2, Zabbix agent must be uninstalled`

### Example

```bash
./installation_zabbix_agent_2_Linux.sh ubuntu --disable-zabbix-agent
```

***

### To install Zabbix agent Windows

\- installation_zabbix_agent_Windows.ps1

> #### Edit the path where to save Zabbix agent
>
> `$DirectoryPath`
>
> #### Set IP address of Zabbix server
>
> `$IpAddr`

### Example

```powershell
./installation_zabbix_agent_Windows.ps1
```
