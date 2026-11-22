#!/bin/sh
# Run in the built image with /bin/sh as the entrypoint and the lock on stdin.
set -eu
cd /usr/local/share/elitesync-r0
sha256sum -c -
cd /var/www/html
sha256sum -c /usr/local/share/elitesync-r0/locks.sha256
/opt/elitesync-natal/bin/pip check
composer check-platform-reqs --no-dev --no-interaction
