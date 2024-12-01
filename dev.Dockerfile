ARG VERSION
ARG FLAVOR=cli

FROM php:${VERSION}-${FLAVOR} as build
ARG FLAVOR
ARG VERSION
LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}-${FLAVOR} \
    variant=base

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
#keep apt cache for cache mount
RUN rm -f /etc/apt/apt.conf.d/docker-clean ;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::RecommendsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99-custom 


RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    IPE_ICU_EN_ONLY=1 IPE_KEEP_SYSPKG_CACHE=true install-php-extensions \
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

#additional dev packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    IPE_KEEP_SYSPKG_CACHE=ture install-php-extensions \
    xdebug-stable \
    @composer


#create a stripped php.ini
RUN echo ';stripped version of /usr/local/etc/php/php.ini-development' > /usr/local/etc/php/php.ini ;\
    cat /usr/local/etc/php/php.ini-development | grep -E '^[\s]*[^;]' | sed -zE 's/(\[\w+\]\s*\n)+(\[\w+\])/\2/g' >> /usr/local/etc/php/php.ini;\
#configure xdebug
    echo xdebug.mode = debug,develop >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN set -xe ;\
    #save required packages
    ldd `php-config --php-binary` $(find `php-config --extension-dir` -name *.so) \
    | grep -E '=> /' \
    | sed -E 's/^.* => (\/.*) \(0x[a-f0-9]+\)$.*/\1/m' \
    | xargs basename -a \
    | xargs dpkg-query --search \
    | cut -d: -f1 \
    | sort -u > /tmp/packages ;\
    # smoke test
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0

FROM debian:bookworm-slim
ADD README.md /README.md

LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR} \
    variant=dev
RUN --mount=from=build,target=/tmp/build --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -xe ;\
    #install the bare minimum
    export DEBIAN_FRONTEND=noninteractive ;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::RecommendsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    rm /etc/apt/apt.conf.d/docker-clean ;\
    apt-get update ;\
    apt-mark auto '.*' > /dev/null;\
    cat /tmp/build/tmp/packages | xargs -tr apt-get install -y \
        ca-certificates \
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
        iotop \
        openssl ;\
    apt-get autoremove ;\
    apt-get purge ~c ;\
    apt-get update ;\
    cp -vr /tmp/build/usr/local/bin /tmp/build/usr/local/etc /tmp/build/usr/local/lib /usr/local/ ;\
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0 ;\
    #append readme info
    echo -e '\nBuild info:\n###\ntag: ${VERSION}-${FLAVOR}-dev' >> /README.md ;\
    echo -e '\nPHP info:\n###\n````' >> /README.md ;\
    php -i 2>&1 >> /README.md ;\
    echo -e '\n```\n' >> /README.md

ENTRYPOINT ["docker-php-entrypoint"]