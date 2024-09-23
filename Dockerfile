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

RUN echo -n 'gd gmp mcrypt mysqli opcache pdo_mysql redis soap sockets tidy xdebug zip @composer' | \
    xargs -i -d ' ' sh -c "echo -n ':' ; echo -n ':group:' ;echo -n ':ext-' ;echo "'{}'" ;echo Installing "'{}'" ;install-php-extensions '{}' ;echo -n ':' ;echo -n ':endgroup:' ; echo ':'"

#    xargs -it -L1 -d ' ' echo '::group::{}' ';' install-php-extensions '{}' ';' echo '::endgroup::' ';exit 100'

ADD README.md /README.md
