
FROM php:8.3-cli
#php ext-gd
#RUN apt-get update && apt-get install -y \
#        libfreetype-dev libjpeg62-turbo-dev libpng-dev \
#        mysql-client \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-install -j$(nproc) gd

RUN apt-get update

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt-get update
RUN apt-get install -y git screen byobu mysql-client curl 


RUN install-php-extensions gd @composer


RUN install-php-extensions xdebug





