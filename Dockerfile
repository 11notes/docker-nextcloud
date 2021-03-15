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
                        supervisor \
                        shadow;

        RUN set -ex; \
                apk add --no-cache --virtual .build \
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
                apk del .build

        RUN mkdir -p \
                /var/log/supervisord \
                /var/run/supervisord;

        # :: copy root filesystem changes
                COPY ./rootfs /
                RUN chmod +x /usr/local/bin/*

        # :: docker -u 1000:1000 (no root initiative)
                RUN set -ex; \
                        APP_UID="$(id -u www-data)"; \
                        APP_GID="$(id -g www-data)"; \
                        find / -not -path "/proc/*" -user $APP_UID -exec chown -h -R 1000:1000 {} \; ;\
                        find / -not -path "/proc/*" -group $APP_GID -exec chown -h -R 1000:1000 {} \;  ;\
                        usermod -u 1000 www-data; \
                        groupmod -g 1000 www-data; \
                        chown -R www-data:www-data \
                                /var/www \
                                /usr/local/etc/php/conf.d/ \
                                /usr/local/etc/php-fpm.d/ \
                                /var/log/supervisord \
                                /var/run/supervisord \
                                /usr/local/bin

# :: Start
        USER www-data
        ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
        CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]