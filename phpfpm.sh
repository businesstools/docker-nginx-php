#!/bin/sh

PHP_FPM="php-fpm$PHP_VERSION"

$PHP_FPM -c "/etc/php/$PHP_VERSION/fpm"
