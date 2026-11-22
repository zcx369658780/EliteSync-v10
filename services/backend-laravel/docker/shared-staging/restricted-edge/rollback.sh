#!/usr/bin/env bash
set -euo pipefail
umask 077

# Roll back the newly installed include only. Keep its bytes with the snapshot.
[[ $# -eq 2 && $(id -u) -eq 0 ]]
evidence=$(realpath -e -- "$1")
expected=$2
active=/etc/nginx/conf.d/elitesync-v2-restricted.conf
[[ "$evidence" == /root/* && -d "$evidence" && $(stat -c '%u:%a' "$evidence") == 0:700 ]]
[[ "$expected" =~ ^[a-f0-9]{64}$ && -f "$active" && ! -L "$active" ]]
[[ $(sha256sum -- "$active" | cut -d ' ' -f 1) == "$expected" ]]
retained="$evidence/elitesync-v2-restricted.disabled.conf"
[[ ! -e "$retained" && ! -L "$retained" ]]
mv --no-clobber -- "$active" "$retained"
[[ ! -e "$active" && -f "$retained" ]]
sha256sum -- "$retained" > "$evidence/rollback.sha256"
nginx -t
systemctl reload nginx
