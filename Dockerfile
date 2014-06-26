# Using LTS ubuntu
FROM ubuntu:14.04
MAINTAINER "Mark Vartanyan <kolypto@gmail.com>"

# Packages: update & install
ENV DEBCONF_FRONTEND noninteractive
RUN apt-get update -qq
RUN apt-get install -qq -y --no-install-recommends python-pip supervisor
RUN apt-get install -qq -y --no-install-recommends nginx-full php5-fpm php5-mysql zabbix-server-mysql zabbix-frontend-php snmp-mibs-downloader
RUN pip install j2cli

# Const
ENV ZABBIX_PHP_TIMEZONE UTC


# Add files
ADD conf /root/conf

# Configure: nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
ADD conf/nginx-site.conf /etc/nginx/sites-enabled/zabbix
RUN nginx -t

# Configure: php
RUN j2 /root/conf/php.ini > /etc/php5/mods-available/custom.ini
RUN php5enmod custom
    # php-fpm socket has wrong permissions, so nginx can't access it :(
RUN echo "listen.mode = 0666" >> /etc/php5/fpm/pool.d/www.conf

# Configure: zabbix-server
    # broken package: pidfile dir is missinf
RUN mkdir -m0777 /var/run/zabbix/

# Configure: supervisor
ADD bin/dfg.sh /usr/local/bin/
ADD conf/supervisor-all.conf /etc/supervisor/conf.d/




# Runner
ADD run.sh /root/run.sh
RUN chmod +x /root/run.sh



# Declare
VOLUME ["/etc/zabbix/alert.d/"]
EXPOSE 80
EXPOSE 10051

CMD ["/root/run.sh"]
