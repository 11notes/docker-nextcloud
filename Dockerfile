# ------ HEADER ------ #
FROM nextcloud:apache
ARG DEBIAN_FRONTEND=noninteractive

# ------ RUN  ------ #
RUN mkdir -p /usr/share/man/man1 \
    && apt-get update && apt-get install -y \
        supervisor \
        ffmpeg \
        libmagickwand-dev \
        libgmp3-dev \
        libc-client-dev \
        libkrb5-dev \
        smbclient \
        libsmbclient-dev \
        libreoffice \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && ln -s "/usr/include/$(dpkg-architecture --query DEB_BUILD_MULTIARCH)/gmp.h" /usr/include/gmp.h \
    && docker-php-ext-install bz2 gmp imap \
    && pecl install imagick smbclient \
    && docker-php-ext-enable imagick smbclient \
    && mkdir /var/log/supervisord /var/run/supervisord

ADD supervisord.conf /etc/supervisor/supervisord.conf
ADD smb.conf /etc/samba/smb.conf

# ------ CMD/START/STOP ------ #
CMD ["/usr/bin/supervisord"]