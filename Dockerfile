ARG PHP_VERSION=7.4.16
FROM php:${PHP_VERSION}-apache
RUN apt-get update \
    && apt-get install -y \
        acl \
        git \
        libpng-dev \
        libicu-dev \
        libzip-dev \
        wget \
        cron \
    && docker-php-ext-install intl \
        pdo \
        pdo_mysql \
        zip \
        opcache \
    && docker-php-ext-configure intl \
#    && pecl install xdebug \
#    && docker-php-ext-enable xdebug \
    && apt-get clean all \
    && rm -rvf /var/lib/apt/lists/*  \
    && wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony/bin/symfony /usr/local/bin/symfony \
    && rm -rf /tmp/* \
    && rm -rf /etc/apache2/sites-available/* \
    && rm -rf /etc/apache2/sites-enabled/* \
    && rm -rf /var/www/* \
	;

ARG APCU_VERSION=5.1.20
RUN pecl install \
        apcu-${APCU_VERSION} \
    && pecl clear-cache \
    && docker-php-ext-enable \
        apcu \
        opcache \
    ;
# composer
COPY --from=composer:2.0.13 /usr/bin/composer /usr/bin/composer

# conf Apache2
RUN a2enmod proxy_fcgi ssl rewrite proxy proxy_http proxy_ajp \
    && echo "ServerName localhost" >> /etc/apache2/apache2.conf

COPY docker/php/php.ini /usr/local/etc/php/php.ini
COPY docker/apache/vhosts/sf.conf /etc/apache2/sites-available/sf.conf

WORKDIR /var/www/app

COPY composer.json .
COPY composer.lock .
COPY .env .

RUN mkdir -p var/logs

RUN composer install

COPY bin bin
COPY config config
COPY public public
COPY src src

RUN a2ensite sf.conf
RUN service apache2 restart

EXPOSE 80 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
