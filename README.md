Zabbix Server & Web UI
======================

Contains:

* Zabbix Server
* Zabbinx Front-end
* Nginx
* PHP

Processes are managed by supervisor, including cronjobs


Exports
-------

* Nginx on `80`
* Zabbix Server on `10051`
* `/etc/zabbix/alert.d/` for Zabbix alertscripts

Variables
---------

* `ZABBIX_DB_NAME=zabbix`: Database name to work on
* `ZABBIX_DB_USER=zabbix`: MySQL user
* `ZABBIX_DB_PASS=zabbix`: MySQL password
* `ZABBIX_DB_HOST=localhost`: MySQL host to connect to
* `ZABBIX_DB_PORT=3306`: MySQL port

* `ZABBIX_INSTALLATION_NAME=`: Zabbix installation name

Linking:

* `ZABBIX_DB_LINK=`: Database link name. Example: a value of "DB_PORT_3306" will fill in `ZABBIX_DB_HOST/PORT` variables

Constants in Dockerfile
-----------------------

* `ZABBIX_PHP_TIMEZONE=UTC`: Timezone to use with PHP

Example
-------

Launch database container:

    $ docker start zabbix-db || docker run --name="zabbix-db" -d -e MYSQL_ROOT_PASSWORD='root' -e MYSQL_DATABASE='zabbix' -e MYSQL_USER='zabbix' -e MYSQL_PASSWORD='zabbix' -e MYSQL_SET_KEYBUF=64M -p localhost::3306 -v /var/lib/mysql:/var/lib/mysql kolypto/mysql

Install the required tables:

    $ docker run --rm --link zabbix-db:db -e ZABBIX_DB_LINK=DB_PORT_3306 kolypto/zabbix-server /root/run.sh setup-db

Launch Zabbix container:

    $ docker start zabbix || docker run --name="zabbix" --link zabbix-db:db -e ZABBIX_DB_LINK=DB_PORT_3306 -p 80:80 -p 10051:10051 kolypto/zabbix-server

By default, you sign in as Admin:zabbix.

Enjoy! :)

Configuration Cheat-Sheet
-------------------------

Things to do at the beginning:

* Administration > Users, Users: disable guest access (group), setup user accounts & themes
* Administration > Media types: set up notification methods. For custom alertscripts, see [Custom alertscripts](https://www.zabbix.com/documentation/2.4/manual/config/notifications/media/script)
* Administration > Users, Users, "Media" tab: set up notification destinations
* Configuration > Hosts: create a new host and add items, triggers & stuff

TODO
----

* Create a way to set up and update alertscripts: `/etc/zabbix/alert.d/`. Git? Download? Update?
