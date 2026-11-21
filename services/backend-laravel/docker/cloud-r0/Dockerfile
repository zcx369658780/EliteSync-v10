# syntax=docker/dockerfile:1
FROM node:22-bookworm-slim@sha256:47725aca53d3295ec2d3be8f62726599b3033cc262edc2c7e429909b3ac599fc AS node-deps
WORKDIR /build
COPY tools/ziwei/iztro-runner/package*.json ./
RUN npm ci --ignore-scripts --no-audit --no-fund

FROM composer:2.9@sha256:58aa755183a7cb38c0fb17321ad396d35a22a2d8a1cc73a246fb6966c87cf766 AS composer-bin

FROM php:8.4-fpm-bookworm@sha256:28194959c40be13c98ae81c138bd11e47b04efc86f0f77d6f272d7d099f06899 AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip libzip-dev libicu-dev libpng-dev libjpeg62-turbo-dev \
    python3.11 python3.11-venv tzdata ca-certificates \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" pdo_mysql bcmath intl zip pcntl gd exif \
    && rm -rf /var/lib/apt/lists/*
COPY --from=node-deps /usr/local/bin/node /usr/local/bin/node
COPY tools/natal/requirements.linux-cp311.lock /tmp/natal.lock
RUN python3.11 -m venv /opt/elitesync-natal \
    && /opt/elitesync-natal/bin/pip install --no-cache-dir --require-hashes --only-binary=:all: -r /tmp/natal.lock \
    && /opt/elitesync-natal/bin/pip check
COPY --from=composer-bin /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY composer.json composer.lock ./
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --no-scripts --no-plugins --no-interaction --prefer-dist --no-progress --no-autoloader
COPY artisan ./
COPY app ./app
COPY bootstrap ./bootstrap
COPY config ./config
COPY database ./database
COPY public ./public
COPY resources ./resources
COPY routes ./routes
COPY tools/natal ./tools/natal
COPY tools/ziwei/iztro-runner ./tools/ziwei/iztro-runner
COPY --from=node-deps /build/node_modules ./tools/ziwei/iztro-runner/node_modules
COPY docker/php-runtime.ini /usr/local/etc/php/conf.d/zz-elitesync-runtime.ini
COPY docker/cloud-r0/fpm.conf /usr/local/etc/php-fpm.d/zzz-elitesync-r0.conf
COPY --chmod=0755 docker/cloud-r0/app-entrypoint.sh /usr/local/bin/elitesync-r0
COPY docker/cloud-r0/db-preflight.php /opt/elitesync-r0/db-preflight.php
RUN composer dump-autoload --no-dev --no-scripts --no-plugins --optimize \
    && composer check-platform-reqs --no-dev \
    && mkdir -p storage/app/private storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs /opt/elitesync-data \
    && chown -R www-data:www-data storage bootstrap/cache \
    && mkdir -p /usr/local/share/elitesync-r0 \
    && dpkg-query -W > /usr/local/share/elitesync-r0/os-packages.tsv \
    && /opt/elitesync-natal/bin/pip freeze > /usr/local/share/elitesync-r0/python-packages.txt \
    && composer show --locked --no-dev --format=json > /usr/local/share/elitesync-r0/php-packages.json \
    && sha256sum composer.lock tools/natal/requirements.linux-cp311.lock tools/ziwei/iztro-runner/package-lock.json > /usr/local/share/elitesync-r0/locks.sha256
USER www-data
ENTRYPOINT ["/usr/local/bin/elitesync-r0"]
CMD ["php-fpm", "-F"]
