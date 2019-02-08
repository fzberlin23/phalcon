FROM php:7.2-apache

RUN apt-get update

RUN apt-get install -y vim less git

RUN apt-get install -y libcurl3-dev
RUN docker-php-ext-install curl

RUN docker-php-ext-install mysqli

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl-cert-snakeoil.key -out /etc/ssl/certs/ssl-cert-snakeoil.pem -subj "/C=AT/ST=Vienna/L=Vienna/O=Security/OU=Development/CN=example.com"

RUN a2enmod rewrite
RUN a2ensite default-ssl
RUN a2enmod ssl

RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data

#RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -ri -e 's!;date.timezone =!date.timezone = "Europe/Berlin"!g' /usr/local/etc/php/php.ini

# compile phalcon from sources
RUN git clone https://github.com/phalcon/cphalcon /root/cphalcon
WORKDIR /root/cphalcon
RUN git checkout tags/v3.4.2
WORKDIR /root/cphalcon/build
RUN ./install
RUN sed -ri -e 's!;extension=xsl!;extension=xsl\nextension=phalcon.so!g' /usr/local/etc/php/php.ini

# phalcon dev tools
RUN git clone git://github.com/phalcon/phalcon-devtools.git /opt/phalcon
RUN ln -s /opt/phalcon/phalcon.php /usr/bin/phalcon
RUN chmod ugo+x /usr/bin/phalcon

EXPOSE 80
