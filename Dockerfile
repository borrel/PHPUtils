ARG VERSION=8.3
ARG FLAVOR=cli

FROM php:${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}
ARG VERSION
ARG FLAVOR
LABEL version="$VERSION" \
      flavor="$FLAVOR" \
      orig-tag=${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y git screen byobu default-mysql-client curl sudo

RUN install-php-extensions xdebug 
RUN install-php-extensions gd 
RUN install-php-extensions gmp
RUN install-php-extensions mcrypt
RUN install-php-extensions soap
RUN install-php-extensions sockets
RUN install-php-extensions tidy
RUN install-php-extensions zip
RUN install-php-extensions mysqli
RUN install-php-extensions pdo_mysql
RUN install-php-extensions redis
RUN install-php-extensions opcache
RUN install-php-extensions @composer


ADD README.md /README.md



