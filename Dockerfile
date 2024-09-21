
FROM gitpod/workspace-full:2022-05-08-14-31-53
#php ext-gd
#RUN apt-get update && apt-get install -y \
#        libfreetype-dev libjpeg62-turbo-dev libpng-dev \
#        mysql-client \
#    && docker-php-ext-configure gd --with-freetype --with-jpeg \
#    && docker-php-ext-install -j$(nproc) gd
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/


RUN install-php-extensions gd @composer


RUN install-php-extensions xdebug





