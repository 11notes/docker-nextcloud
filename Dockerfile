# :: Header
    FROM nextcloud:22.0.0-fpm-alpine
    ENV NEXTCLOUD_UPDATE=1

# :: Run
USER root

# :: prepare
    RUN set -ex; \
        apk add --no-cache \
        shadow;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex;\
            APP_UID="$(id -u www-data)"; \
            APP_GID="$(id -g www-data)"; \
            find / -not -path "/proc/*" -user $APP_UID -exec chown -h -R 1000:1000 {} \;; \
            find / -not -path "/proc/*" -group $APP_GID -exec chown -h -R 1000:1000 {} \;

        RUN set -ex; \
            usermod -u 1000 www-data; \
            groupmod -g 1000 www-data; \
            chown -R 1000:1000 \
                /var/www \
                /usr/local/etc/php/conf.d/ \
                /usr/local/etc/php-fpm.d/ \
                /usr/local/bin

# :: Start
    RUN chmod +x /usr/local/bin/entrypoint.sh
    USER www-data
    ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
    CMD ["php-fpm"]