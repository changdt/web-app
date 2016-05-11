FROM ubuntu
MAINTAINER Skiychan <dev@skiy.net>
MAINTAINER kkshyu <kevin830222@gmail.com>
##
# Nginx: 1.10.0
# PHP  : 7.0.6
##

ENV NGINX_VERSION 1.10.0
ENV PHP_VERSION 7.0.6

# Upgrade apt
RUN apt-get update -y && apt-get upgrade -y

# Install libraries
RUN apt-get install -y \
    gcc \
    g++ \
    autoconf \
    automake \
    libtool \
    make \
    cmake \
    git \
    curl \
    wget \
    supervisor \
    zlib1g-dev \
    openssl \
    libssl-dev \
    pkg-config \
    libsasl2-dev \
    libpcre3-dev \
    libxml2 \
    libxml2-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmcrypt-dev \
    openssh-server \
    python-setuptools && \
    apt-get clean all

# Install nginx & php packages
RUN apt-get -y install \
    nginx \
    php7.0-dev \
    php7.0-fpm \
    php7.0-curl \
    php7.0-mbstring \
    php7.0-mcrypt

# Install php7.0-redis
RUN git clone https://github.com/phpredis/phpredis.git && \
    cd phpredis && \
    git checkout php7 && \
    phpize && \
    ./configure && \
    make && make install && \
    cd .. && \
    rm -rf phpredis && \
    echo "extension=redis.so" > /etc/php/7.0/mods-available/redis.ini && \
    ln -sf /etc/php/7.0/mods-available/redis.ini /etc/php/7.0/fpm/conf.d/20-redis.ini && \
    ln -sf /etc/php/7.0/mods-available/redis.ini /etc/php/7.0/cli/conf.d/20-redis.ini

# Install php7.0-mongo
RUN pecl install mongodb && \
    echo "extension=mongodb.so" 1>/etc/php/7.0/mods-available/mongodb.ini && \
    ln -sf /etc/php/7.0/mods-available/mongodb.ini /etc/php/7.0/fpm/conf.d/20-mongodb.ini && \
    ln -sf /etc/php/7.0/mods-available/mongodb.ini /etc/php/7.0/cli/conf.d/20-mongodb.ini

# Install node
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - && \
    apt-get install -y nodejs

# Install node packages
RUN npm install -g npm gulp bower

# Install debugging tool
RUN apt-get -y install \
    vim \
    php-xdebug

#Add xdebug extension
# RUN cd /home/nginx-php && \
#     tar -zxvf XDEBUG_2_4_0RC3.tar.gz && \
#     cd xdebug-XDEBUG_2_4_0RC3 && \
#     /usr/local/php/bin/phpize && \
#     ./configure --enable-xdebug --with-php-config=/usr/local/php/bin/php-config && \
#     make && \
#     cp modules/xdebug.so /usr/local/php/lib/php/extensions/no-debug-non-zts-20151012/

# RUN cd /home/nginx-php/php-$PHP_VERSION && \
#     cp php.ini-production /usr/local/php/etc/php.ini && \
#     cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
#     cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

# ADD xdebug.ini /usr/local/php/etc/php.d/xdebug.ini

# Install composer
RUN mkdir /usr/lib/composer && \
    php -r "readfile('https://getcomposer.org/installer');" | php && \
    mv composer.phar /usr/local/bin/composer

# Create web folder
VOLUME ["/usr/share/nginx/html", "/etc/nginx/ssl", "/etc/nginx/site-enabled"]
ADD www /usr/share/nginx

# Update nginx config
ADD nginx/ssl /etc/nginx/ssl
ADD nginx/nginx.conf /etc/nginx/nginx.conf
ADD nginx/sites-enabled /etc/nginx/sites-enabled

# Update php-fpm config
ADD php-fpm /etc/php/7.0/fpm
RUN mkdir -p /run/php

# Update supervisor conf
ADD supervisor /etc/supervisor

#Start
ADD start.sh /start.sh
RUN chmod +x /start.sh

#Set port
EXPOSE 80 443 9001

#Start it
ENTRYPOINT ["/start.sh"]
