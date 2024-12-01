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
    ssh2 \
    yaml-stable \
    inotify-stable \
    sockets;
#end base
#create a stripped php.ini
RUN echo ';stripped version of /usr/local/etc/php/php.ini-production' > /usr/local/etc/php/php.ini ;\
    cat /usr/local/etc/php/php.ini-production | grep -E '^[\s]*[^;]' | sed -zE 's/(\[\w+\]\s*\n)+(\[\w+\])/\2/g' >> /usr/local/etc/php/php.ini


RUN set -xe ;\
    #append readme
    echo -e '\nBuild info:\n###\ntag: ${VERSION}-${FLAVOR}-prod\n' >> /README.md ;\
    #save required packages
    ldd `php-config --php-binary` $(find `php-config --extension-dir` -name *.so) \
    | grep -E '=> /' \
    | sed -E 's/^.* => (\/.*) \(0x[a-f0-9]+\)$.*/\1/m' \
    | xargs basename -a \
    | xargs dpkg-query --search \
    | cut -d: -f1 \
    | sort -u > /tmp/packages ;\
    #strip tests
    rm -rf /usr/local/lib/php/test ;\
    # smoke test
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0

FROM debian:bookworm-slim
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
    cat /tmp/build/tmp/packages | xargs -tr apt-get install -y ca-certificates ;\
    apt-get autoremove ;\
    apt-get purge ~c ;\
    cp -vr /tmp/build/usr/local/bin /tmp/build/usr/local/etc /tmp/build/usr/local/lib /usr/local/ ;\
    test "$(php -m 2>&1 | tee /dev/stderr | grep 'PHP Warning' | wc -l)" -eq 0 ;\
    #append readme info
    echo -e '\nPHP info:\n###\n````' >> /README.md ;\
    php -i 2>&1 >> /README.md ;\
    echo '```' >> /README.md


LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}-${FLAVOR} \
    variant=prod

ENTRYPOINT ["docker-php-entrypoint"]