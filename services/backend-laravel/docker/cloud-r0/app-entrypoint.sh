#!/bin/sh
set -eu
# Separate files keep credentials out of Compose interpolation and image history.
test -r /run/secrets/r0_app_key && test -r /run/secrets/r0_db_password
APP_KEY=$(cat /run/secrets/r0_app_key)
DB_PASSWORD=$(cat /run/secrets/r0_db_password)
test -n "$APP_KEY" && test -n "$DB_PASSWORD"
export APP_KEY DB_PASSWORD
exec "$@"
