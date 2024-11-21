ARG VERSION=8.3
ARG FLAVOR=cli

FROM baseimage:${VERSION}-${FLAVOR}
ARG FLAVOR
ARG VERSION
LABEL version="$VERSION" \
    flavor="$FLAVOR" \
    orig-tag=${VERSION}${FLAVOR:+${VERSION:+-}}${FLAVOR} \
    variant=prod

# Only install these on cli
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked IPE_KEEP_SYSPKG_CACHE=ture \
    if [ "${FLAVOR}" == "cli" ] ;then ;install-php-extensions \
    inotify-stable \
    sockets-stable \
    @composer \
    fi

#remove obselete config files and pagages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked DEBIAN_FRONTEND=noninteractive \
    apt-get purge ~c

#append readme
RUN echo VARIANT=prod >> /README.md
RUN echo FLAVOR=${FLAVOR} >> /README.md
RUN echo >> /README.md
RUN php -i >> /README.md
RUN echo '```' >> /README.md
