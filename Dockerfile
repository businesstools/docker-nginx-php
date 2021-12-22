FROM jedisct1/phusion-baseimage-latest:16.04

ENV PHP_VERSION=7.4

RUN (curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -) \
    && (curl -sS http://nginx.org/keys/nginx_signing.key | sudo apt-key add -) \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" \
      | sudo tee /etc/apt/sources.list.d/yarn.list \
    && echo "deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx" \
      | sudo tee /etc/apt/sources.list.d/nginx.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -yq --no-install-recommends \
          apt-utils \
          software-properties-common \
          apt-transport-https \
          python-software-properties \
          build-essential \
          language-pack-en-base \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -yq \
          nginx \
          nodejs \
          yarn \
          python \
          curl \
          zip \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -yq \
          php${PHP_VERSION}-cli \
          php${PHP_VERSION}-fpm \
          php${PHP_VERSION}-mysql \
          php${PHP_VERSION}-pgsql \
          php${PHP_VERSION}-sqlite3 \
          php${PHP_VERSION}-ldap \
          php${PHP_VERSION}-curl \
          php${PHP_VERSION}-gd \
          php${PHP_VERSION}-mbstring \
          php${PHP_VERSION}-intl \
          php${PHP_VERSION}-xmlrpc \
          php${PHP_VERSION}-json \
          php${PHP_VERSION}-bz2 \
          php${PHP_VERSION}-tidy \
          php${PHP_VERSION}-opcache \
          php${PHP_VERSION}-xml \
          php${PHP_VERSION}-xsl \
          php${PHP_VERSION}-yaml \
          php${PHP_VERSION}-zip \
          composer \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && sed -i "s/;date.timezone =.*/date.timezone = UTC/" \
        /etc/php/${PHP_VERSION}/fpm/php.ini \
        /etc/php/${PHP_VERSION}/cli/php.ini \
    && sed -i "/listen\./s/www-data/nginx/g"               /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
    && sed -i "s/;daemonize\s*=\s*yes/daemonize = no/"     /etc/php/${PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/"  /etc/php/${PHP_VERSION}/fpm/php.ini \
    && sed -i "s/;clear_env\s*=\s*no/clear_env = no/"      /etc/php/${PHP_VERSION}/fpm/pool.d/www.conf \
    && mkdir -p \
        /var/www \
        /run/php \
        /etc/service/nginx \
        /etc/service/phpfpm \
    && npm install -g pnpm

COPY nginx.conf /etc/nginx/
COPY etc/*.conf /etc/nginx/conf.d/

COPY nginx.sh /etc/service/nginx/run
COPY phpfpm.sh /etc/service/phpfpm/run

RUN chmod +x \
        /etc/service/nginx/run \
        /etc/service/phpfpm/run && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80
