#! /usr/bin/env bash
set -eu # exit on error or undefined variable

# Variables
export ZABBIX_PHP_TIMEZONE=${ZABBIX_PHP_TIMEZONE:-"UTC"}
export ZABBIX_DB_NAME=${ZABBIX_DB_NAME:-"zabbix"}
export ZABBIX_DB_USER=${ZABBIX_DB_USER:-"zabbix"}
export ZABBIX_DB_PASS=${ZABBIX_DB_PASS:-"zabbix"}
export ZABBIX_DB_HOST=${ZABBIX_DB_HOST:-"localhost"}
export ZABBIX_DB_PORT=${ZABBIX_DB_PORT:-"3306"}
export ZABBIX_INSTALLATION_NAME=${ZABBIX_INSTALLATION_NAME:-""}
if [ ! -z "$ZABBIX_DB_LINK" ] ; then
    eval export ZABBIX_DB_HOST=\$${ZABBIX_DB_LINK}_TCP_ADDR
    eval export ZABBIX_DB_PORT=\$${ZABBIX_DB_LINK}_TCP_PORT
fi

# Templates
cat <<EOF > /.my.cnf
[client]
user=$ZABBIX_DB_USER
password=$ZABBIX_DB_PASS
host=$ZABBIX_DB_HOST
port=$ZABBIX_DB_PORT
EOF

j2 /root/conf/zabbix.conf.php > /etc/zabbix/zabbix.conf.php
j2 /root/conf/zabbix_server.conf > /etc/zabbix/zabbix_server.conf

# Service commands
[ $# -eq 1 ] &&
    case "$1" in
        # Install tables into MySQL
        setup-db)
            apt-get install -qq -y --no-install-recommends mysql-client
            zcat /usr/share/zabbix-server-mysql/{schema,images,data}.sql.gz | mysql $ZABBIX_DB_NAME
            apt-get purge -qq -y mysql-client
            exit 0
            ;;
    esac

# Logging
rm -f /var/run/{nginx,php5-fpm,zabbix/zabbix_server}.pid
LOGFILES=$(echo /var/log/{nginx/error,nginx/http.error,php5-fpm,supervisord,zabbix-server/zabbix_server}.log)
( umask 0 && truncate -s0 $LOGFILES ) && tail --pid $$ -n0 -F $LOGFILES &

# Launch
exec /usr/bin/supervisord -n
