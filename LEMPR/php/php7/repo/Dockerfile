From php:7.0-cli-alpine

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

COPY repo/init.sh /
RUN chmod +x /init.sh
CMD ["sh", "-c", "/init.sh"]
