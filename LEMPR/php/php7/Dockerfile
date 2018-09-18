From php:7-fpm-alpine

ENV TZ=Asia/Shanghai

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --update --no-cache autoconf g++ make \
    && pecl install redis \
    && pecl install xdebug \
    && docker-php-ext-enable redis xdebug

COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.d /usr/local/etc/php-fpm.d

  
  
  
