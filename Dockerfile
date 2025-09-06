ARG VERSION=8.4
ARG FLAVOR=cli
ARG VARIANT=dev
# dev or prod
ARG DEBIAN_RELEASE=trixie
#debian release name ex: bookwork trixie (alphine not suported)

FROM php:${VERSION}-${FLAVOR}-${DEBIAN_RELEASE} AS build
ARG FLAVOR
ARG VERSION
ARG VARIANT

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
#keep apt cache for cache mount
RUN rm -f /etc/apt/apt.conf.d/docker-clean ;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::RecommendsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;


RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    IPE_ICU_EN_ONLY=1 IPE_KEEP_SYSPKG_CACHE=true install-php-extensions \
    bcmath \
    gd \
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
    ssh2 \
    yaml-stable \
    inotify-stable \
    sockets;
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    test "$VARIANT" = "dev" && install-php-extensions xdebug || true
#end base
#create a stripped php.ini
RUN echo ';stripped version of /usr/local/etc/php/php.ini-production' > /usr/local/etc/php/php.ini ;\
    cat /usr/local/etc/php/php.ini-production \
    #strip empty
    | grep -E '^[\s]*[^;]' \
    #strip comments
    | sed -zE 's/(\[\w+\]\s*\n)+(\[\w+\])/\2/g' >> /usr/local/etc/php/php.ini

RUN set -xe ;\
    #set locale for machine parsing dpkg-query
    export LOCALE=C.UTF-8 ;\
    #append readme
    echo -e '\nBuild info:\n###\ntag: ${VERSION}-${FLAVOR}-prod\n' >> /README.md ;\
    #save required packages
    ldd `php-config --php-binary` $(find `php-config --extension-dir` -name *.so) \
    | grep -E '=> /' \
    | sed -E 's/^.* => (\/.*) \(0x[a-f0-9]+\)$.*/\1/m' \
    | xargs realpath \
    | xargs dpkg-query --search \
    | sed -E 's/^(.*)\: .*/\1/m' \
    | sed -E 's/,/\n/m' \
    | sort -u > /tmp/packages ;\
    #strip tests
    rm -rf /usr/local/lib/php/test ;\
    # smoke test
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0

FROM debian:${DEBIAN_RELEASE}-slim
ARG VARIANT
RUN --mount=from=build,target=/tmp/build --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -xe ;\
    #install the bare minimum
    export DEBIAN_FRONTEND=noninteractive ;\
    rm /etc/apt/apt.conf.d/docker-clean ;\
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::RecommendsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    echo 'APT::AutoRemove::SuggestsImportant "false";' >> /etc/apt/apt.conf.d/99-custom ;\
    apt-get update ;\
    apt-mark auto '.*' > /dev/null;\
    cp /tmp/build/tmp/packages /tmp/packages ;\
    echo ca-certificates >> /tmp/packages  ;\
    if [ "$VARIANT" = "dev" ]; then \
    echo git screen default-mysql-client curl sudo nano ssh bind9-utils traceroute procps htop openssl ssh-client \
    | sed -E 's/ /\n/m' \
    >> /tmp/packages ;\
    fi ;\
    cat /tmp/packages ;\
    cat /tmp/packages | xargs -tr apt-get install -y ;\
    apt-get autoremove ;\
    apt-get purge ~c ;\
    cp -vr /tmp/build/usr/local/bin /tmp/build/usr/local/etc /tmp/build/usr/local/lib /usr/local/ ;\
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0 ;\
    #append readme info
    /bin/echo -e '\nPHP info:\n###\n````' >> /README.md ;\
    php -i 2>&1 >> /README.md ;\
    /bin/echo -e '\n```\nInstalled Packages:\n###\n```' >> /README.md ;\
    cat /tmp/packages >>/README.md ;\
    echo '```' >> /README.md ;\
    rm /tmp/packages;

LABEL version="${VERSION}" \
    flavor="${FLAVOR}" \
    orig-tag=${VERSION}-${FLAVOR}-${DEBIAN_RELEASE} \
    variant=${VARIANT}

ENTRYPOINT ["docker-php-entrypoint"]
