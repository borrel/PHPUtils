ARG VERSION=8.3
ARG FLAVOR=cli

FROM php:${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}

LABEL VERSION="$VERSION" \
      FLAVOR="$FLAVOR" \
      orig-tag=${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y git screen byobu default-mysql-client curl sudo

RUN install-php-extensions xdebug gd gmp mcrypt soap sockets tidy zip mysqli pdo_mysql redis opcache @composer

ADD README.md /README.md



