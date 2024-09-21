ARG DEV=1

FROM php:8.3-cli
#php ext-gd
#RUN apt-get update && apt-get install -y \
#        libfreetype-dev libjpeg62-turbo-dev libpng-dev \
#        mysql-client \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-install -j$(nproc) gd
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/


gRUN install-php-extenstions gd @composer


RUN test "01" -eq "0$DEV" && install-php-extenstions xdebug





