FROM jedisct1/phusion-baseimage-latest:16.04
MAINTAINER Daniel Haus <daniel.haus@businesstools.de>

# Fix npm inside docker image
# see https://github.com/npm/npm/issues/9863
#
# Circumvent missing package problem ("nan") with node-gyp
# https://github.com/ncb000gt/node.bcrypt.js/issues/428

ENV DEBIAN_FRONTEND noninteractive
RUN (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -) && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -yq \
        nginx \
        nodejs \
        yarn \
        python \
        python-software-properties \
        build-essential \
        curl \
        zip && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -yq --force-yes \
        php7.1-cli \
        php7.1-fpm \
        php7.1-mysql \
        php7.1-pgsql \
        php7.1-sqlite3 \
        php7.1-ldap \
        php7.1-curl \
        php7.1-gd \
        php7.1-mcrypt \
        php7.1-mbstring \
        php7.1-intl \
        php7.1-xmlrpc \
        php7.1-json \
        php7.1-bz2 \
        php7.1-tidy \
        php7.1-opcache \
        php7.1-xml \
        php7.1-xsl \
        php7.1-zip \
        composer \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    cd $(npm root -g)/npm \
    && npm install fs-extra \
    && sed -i -e s/graceful-fs/fs-extra/ -e s/fs.rename/fs.move/ ./lib/utils/rename.js && \
    cd $(npm root -g)/npm && \
    npm install nan && \
    npm install -g node-gyp && \
    sed -i "s/;date.timezone =.*/date.timezone = UTC/" \
        /etc/php/7.1/fpm/php.ini \
        /etc/php/7.1/cli/php.ini && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    sed -i "s/;daemonize\s*=\s*yes/daemonize = no/g"    /etc/php/7.1/fpm/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"  /etc/php/7.1/fpm/php.ini && \
    sed -i "s/;clear_env\s*=\s*no/clear_env = no/"      /etc/php/7.1/fpm/pool.d/www.conf && \
    mkdir -p                \
        /var/www            \
        /run/php            \
        /etc/service/nginx  \
        /etc/service/phpfpm

COPY etc/default.conf /etc/nginx/sites-available/default
COPY etc/gzip.conf    /etc/nginx/conf.d/gzip.conf
COPY nginx.sh         /etc/service/nginx/run
COPY phpfpm.sh        /etc/service/phpfpm/run

RUN chmod +x \
        /etc/service/nginx/run \
        /etc/service/phpfpm/run && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
