ARG VERSION=8.3
ARG FLAVOR=cli


FROM php:${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}

RUN apt-get update

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN apt-get update
RUN apt-get install -y git screen byobu default-mysql-client curl sudo


RUN install-php-extensions gd @composer


RUN install-php-extensions xdebug

ADD README.md /README.md



