FROM jedisct1/phusion-baseimage-latest
MAINTAINER Daniel Haus <daniel.haus@businesstools.de>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -yq nginx python-software-properties build-essential curl

RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
RUN apt-get install -yq --force-yes \
        php7.0-cli \
        php7.0-fpm \
        php7.0-mysql \
        php7.0-pgsql \
        php7.0-sqlite3 \
        php7.0-ldap \
        php7.0-curl \
        php7.0-gd \
        php7.0-mcrypt \
        php7.0-intl \
        php7.0-xmlrpc \
        php7.0-json \
        php7.0-bz2 \
        php7.0-tidy \
        php7.0-opcache

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/"  /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/"  /etc/php/7.0/cli/php.ini

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g"    /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"  /etc/php/7.0/fpm/php.ini
RUN sed -i "s/;clear_env\s*=\s*no/clear_env = no/"      /etc/php/7.0/fpm/pool.d/www.conf

RUN mkdir -p                \
    /var/www                \
    /run/php                \
    /etc/service/nginx      \
    /etc/service/phpfpm

ADD etc/default.conf    /etc/nginx/sites-available/default
ADD nginx.sh            /etc/service/nginx/run
RUN chmod +x            /etc/service/nginx/run
ADD phpfpm.sh           /etc/service/phpfpm/run
RUN chmod +x            /etc/service/phpfpm/run

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
