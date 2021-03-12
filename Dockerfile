# :: Header
        FROM nextcloud:21.0.0-fpm-alpine
        ENV NEXTCLOUD_UPDATE=1

# :: Run
        USER root

        RUN set -ex; \
                apk add --no-cache \
                        ffmpeg \
                        imagemagick \
                        procps \
                        samba-client \
                        supervisor;

        RUN set -ex; \
                apk add --no-cache --virtual .build-deps \
                        $PHPIZE_DEPS \
                        imap-dev \
                        krb5-dev \
                        openssl-dev \
                        samba-dev \
                        bzip2-dev; \
                docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
                docker-php-ext-install \
                        bz2 \
                        imap; \
                pecl install smbclient; \
                docker-php-ext-enable smbclient; \
                runDeps="$( \
                        scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
                        | tr ',' '\n' \
                        | sort -u \
                        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
                )"; \
                apk add --virtual .nextcloud-phpext-rundeps $runDeps; \
                apk del .build-deps

        RUN mkdir -p \
                /var/log/supervisord \
                /var/run/supervisord;

        # :: copy root filesystem changes
                COPY ./rootfs /

        # :: docker -u 1000:1000 (no root initiative)
                RUN usermod -u 1000 www-data \
                        && groupmod -g 1000 www-data \
                        && chown -R www-data:www-data \
                                /var/www \
                                /usr/local/etc/php/conf.d/

# :: Start
        USER www-data
        CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]