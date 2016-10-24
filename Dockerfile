FROM jedisct1/phusion-baseimage-latest
MAINTAINER Daniel Haus <daniel.haus@businesstools.de>

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -yq \
        nginx \
        nodejs \
        python \
        python-software-properties \
        build-essential \
        curl \
        zip && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -yq --force-yes \
        php7.0-cli \
        php7.0-fpm \
        php7.0-mysql \
        php7.0-pgsql \
        php7.0-sqlite3 \
        php7.0-ldap \
        php7.0-curl \
        php7.0-gd \
        php7.0-mcrypt \
        php7.0-mbstring \
        php7.0-intl \
        php7.0-xmlrpc \
        php7.0-json \
        php7.0-bz2 \
        php7.0-tidy \
        php7.0-opcache \
        php7.0-xml \
        php7.0-xsl \
        php7.0-zip \
        composer \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Fix npm inside docker image
# see https://github.com/npm/npm/issues/9863
RUN cd $(npm root -g)/npm \
    && npm install fs-extra \
    && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js

# Circumvent missing package problem ("nan") with node-gyp
# https://github.com/ncb000gt/node.bcrypt.js/issues/428
RUN cd $(npm root -g)/npm && \
    npm install nan && \
    npm install -g node-gyp

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" \
        /etc/php/7.0/fpm/php.ini \
        /etc/php/7.0/cli/php.ini && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g"    /etc/php/7.0/fpm/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"  /etc/php/7.0/fpm/php.ini && \
    sed -i "s/;clear_env\s*=\s*no/clear_env = no/"      /etc/php/7.0/fpm/pool.d/www.conf && \
    mkdir -p                \
        /var/www            \
        /run/php            \
        /etc/service/nginx  \
        /etc/service/phpfpm

ADD etc/default.conf    /etc/nginx/sites-available/default
ADD nginx.sh            /etc/service/nginx/run
ADD phpfpm.sh           /etc/service/phpfpm/run

RUN chmod +x \
        /etc/service/nginx/run \
        /etc/service/phpfpm/run

RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
