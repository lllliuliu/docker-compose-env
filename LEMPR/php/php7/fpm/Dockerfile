From php:7.0-fpm-alpine

ENV TZ=Asia/Shanghai

# Init
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk add --no-cache autoconf g++ libtool make \
    && apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev \
    && apk add --no-cache zip git su-exec \
    && docker-php-ext-install -j$(nproc) pdo_mysql iconv mysqli pcntl \
    && docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd\
    && apk del --no-cache freetype-dev libjpeg-turbo-dev libxml2-dev \
    && apk del --no-cache autoconf g++ libtool make

# Install pecl extends
# RUN pecl install redis \
#     && docker-php-ext-enable redis

# Clear
RUN rm -rf /tmp/* /var/cache/apk/*

COPY php.ini /usr/local/etc/php/php.ini
COPY fpm/php-fpm.d /usr/local/etc/php-fpm.d

# Entrypoint
COPY fpm/php-entrypoint /usr/local/bin/
RUN chmod +x /usr/local/bin/php-entrypoint
ENTRYPOINT ["php-entrypoint"]

CMD ["php-fpm"]
