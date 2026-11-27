ARG BASE_IMAGE=elitesync-v2-shared-staging:7e0009df-20261122
FROM ${BASE_IMAGE}

# Use the audited local image's installed dependencies. The build context
# contains only tracked application files and this Dockerfile.
COPY app/ app/
# Keep the base image's runtime-owned bootstrap/cache directory.
COPY bootstrap/*.php bootstrap/
COPY config/ config/
COPY database/ database/
COPY public/ public/
COPY resources/ resources/
COPY routes/ routes/
COPY tools/natal/ tools/natal/
COPY tools/ziwei/iztro-runner/package*.json tools/ziwei/iztro-runner/
COPY composer.lock composer.lock

ENV NATAL_PYTHON=/opt/elitesync-natal/bin/python \
    NATAL_NODE=/usr/local/bin/node \
    NATAL_JPL_KERNEL=/opt/elitesync-data/de440s.bsp \
    NATAL_BAIDU_LOOKUP_ENABLED=false

RUN test -w bootstrap/cache \
    && sha256sum --check /usr/local/share/elitesync-r0/locks.sha256 \
    && "$NATAL_PYTHON" -m pip check \
    && "$NATAL_NODE" --version
