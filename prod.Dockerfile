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
