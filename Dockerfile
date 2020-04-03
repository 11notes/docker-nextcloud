# :: Header
        FROM nextcloud:18-apache
        ARG DEBIAN_FRONTEND=noninteractive

# :: Run
        RUN apt-get update -y \
                && apt-get install -y \
                        smbclient \
                        libsmbclient-dev \
        && pecl install smbclient apcu \
        && docker-php-ext-enable smbclient apcu

        # :: docker -u 1000:1000 (no root initiative)
                RUN sed -i 's/:80/:8080/g' /etc/apache2/sites-available/000-default.conf \
                        && sed -i 's/:443/:8443/g' /etc/apache2/sites-available/default-ssl.conf
                RUN sed -i 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf \
                        && sed -i 's/Listen 443/Listen 8443/g' /etc/apache2/ports.conf

                RUN usermod -u 1000 www-data \
                        && groupmod -g 1000 www-data \
                        && chown -R www-data:www-data \
                                /var/www \
                                /usr/local/etc/php/conf.d/

# :: Start
        USER www-data