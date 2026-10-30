FROM elitesync-v1015-running-20261030/php:input
COPY composer.phar /opt/composer.phar
COPY unzip.deb /tmp/unzip.deb
COPY php-build-meter.sh /tmp/php-build-meter.sh
RUN set -eu; \
    mkdir /opt/php-build-meter; \
    printf '0\n' > /opt/php-build-meter/count; \
    mv /usr/local/bin/php /usr/local/bin/php.unmetered-build-binary; \
    cp /tmp/php-build-meter.sh /usr/local/bin/php; chmod 0755 /usr/local/bin/php; \
    docker-php-ext-install -j2 pdo_mysql bcmath pcntl; \
    mv /usr/local/bin/php.unmetered-build-binary /usr/local/bin/php; \
    dpkg-deb --extract /tmp/unzip.deb /; \
    /usr/bin/unzip -v; \
    rm /tmp/unzip.deb /tmp/php-build-meter.sh
LABEL elitesync.task="V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030"
LABEL elitesync.parent="debe4a11d19f25179efef1d90d04e346980c2867"
