ARG VERSION=8.3
ARG FLAVOR=cli

FROM baseimage:${VERSION}-${FLAVOR}
ARG FLAVOR
ARG VERSION
LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}-${FLAVOR} \
    variant=prod

#remove obselete config files and pagages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked DEBIAN_FRONTEND=noninteractive \
    apt-get purge ~c

#create a stripped php.ini
RUN echo ';stripped version of /usr/local/etc/php/php.ini-production' > /usr/local/etc/php/php.ini ;\
    cat /usr/local/etc/php/php.ini-production | grep -E '^[\s]*[^;]' | sed -zE 's/(\[\w+\]\s*\n)+(\[\w+\])/\2/g' >> /usr/local/etc/php/php.ini

#append readme
RUN echo '' >> /README.md ;\
    echo 'Build info:' >> /README.md ;\
    echo '###' >> /README.md ;\
    echo '```' >> /README.md ;\
    echo VARIANT=dev >> /README.md ;\
    echo FLAVOR=${FLAVOR} >> /README.md ;\
    echo '```' >> /README.md ;\
    echo '' >> /README.md ;\
    echo 'PHP info:' >> /README.md ;\
    echo '###' >> /README.md ;\
    echo '```' >> /README.md ;\
    php -i >> /README.md ;\
    echo '```' >> /README.md
