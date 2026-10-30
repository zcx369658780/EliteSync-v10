#!/bin/sh
set -eu
# Thirty nonrefundable PHP-CLI slots are fsynced in the host ledger BEFORE build.
# This offline image-local gate makes that reservation a strict process ceiling.
while ! mkdir /opt/php-build-meter/lock 2>/dev/null; do sleep 0.01; done
trap 'rmdir /opt/php-build-meter/lock' EXIT
read -r count < /opt/php-build-meter/count
count=$((count + 1))
if [ "$count" -gt 30 ]; then exit 86; fi
printf '%s\n' "$count" > /opt/php-build-meter/count
printf '%s\n' "$*" >> /opt/php-build-meter/invocations
sync -f /opt/php-build-meter/count
sync -f /opt/php-build-meter/invocations
rmdir /opt/php-build-meter/lock
trap - EXIT
exec /usr/local/bin/php.unmetered-build-binary "$@"
