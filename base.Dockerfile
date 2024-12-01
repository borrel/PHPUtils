ARG VERSION
ARG FLAVOR=cli

FROM php:${VERSION}-${FLAVOR} AS build
ARG FLAVOR
ARG VERSION

ADD README.md /README.md
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
#keep apt cache for cache mount
RUN rm -f /etc/apt/apt.conf.d/docker-clean ;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::RecommendsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99-custom 
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked IPE_ICU_EN_ONLY=1 IPE_KEEP_SYSPKG_CACHE=true \
    install-php-extensions \
    bcmath-stable \
    gd-stable \
    imagick \
    exif \
    mysqli \
    pgsql \
    pdo_mysql \
    pdo_pgsql \
    redis-stable \
    soap \
    opcache \
    gmp \
    tidy \
    bz2 \
    lz4 \
    lzf \
    zip \
    mcrypt-stable \
    ssh2 \
    yaml-stable \
    inotify-stable \
    sockets;
