## Scripts for improving the Zabbix database

### To change the database location

\- change_DB_location.sh

### Direct use

wget https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Database/change_DB_location.sh && chmod u+x change_DB_location.sh

### Run it & let yourself be guided

```bash
./change_DB_location.sh
```

***

### To setup a database replication by using Galera Cluster, you will need :
\- galera_cluster_conf.sh  
\- 60-galera.cnf

> #### First, fill in these variables, lines 14 to 18
>
> `cluster_name`  
> `node_name`  
> `ip_node_1`  
> `ip_node_2`  
> `ip_node_3`
>
> #### As first argument, you can use
>
> #### #1
> #### #2
> #### #3

### Direct use

wget https://raw.githubusercontent.com/matthieu-rdt/Zabbix/main/Database/galera_cluster_conf.sh && chmod u+x galera_cluster_conf.sh

### Run it & let yourself be guided

```bash
./galera_cluster_conf.sh
```
