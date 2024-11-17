ARG VERSION=8.3
ARG FLAVOR=cli

FROM php:${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}
ARG FLAVOR
ARG VERSION
LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR}

ADD README.md /README.md

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

#keep apt cache
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    DEBIAN_FRONTEND=noninteractive apt-get update
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    screen \
    default-mysql-client \
    curl \
    sudo \
    nano \
    ssh \
    bind9-utils \
    traceroute \
    procps \
    iotop

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    IPE_KEEP_SYSPKG_CACHE=ture install-php-extensions \
    sockets-stable \
    bcmath-stable \
    gd-stable \
    imagick \
    exif-stable \
    mysqli-stable \
    pgsql-stable \
    pdo_mysql-stable \
    pdo_pgsql-stable \
    redis-stable \
    soap-stable \
    opcache-stable \
    gmp-stable \
    tidy-stable \
    xdebug-stable\
    inotify-stable \
    bz2-stabe \
    lz4 \
    lzf \
    zip-stable \
    mcrypt-stable \
    ssh2 \
    yaml-stable \
    @composer

