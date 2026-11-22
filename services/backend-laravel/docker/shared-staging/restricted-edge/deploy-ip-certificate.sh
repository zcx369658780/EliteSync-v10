#!/usr/bin/env bash
# Certbot deploy hook for an already enabled IP edge.
set -Eeuo pipefail
umask 077
[[ $# == 3 && ${EUID} == 0 && -n ${RENEWED_LINEAGE:-} ]]

ip=$1
edge_dir=$2
upstream=$3
[[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]
verifier=$(dirname -- "$(readlink -f -- "$0")")/verify-tls.sh
[[ "$edge_dir" == /* && -d "$edge_dir" && ! -L "$edge_dir" ]]
[[ $(stat -c '%u:%a' -- "$edge_dir") == 0:700 ]]
[[ -d "$edge_dir/releases" && ! -L "$edge_dir/releases" ]]
[[ $(stat -c '%u:%a' -- "$edge_dir/releases") == 0:700 ]]

exec 9>"$edge_dir/rotation.lock"
flock -x 9
previous=$(readlink -- "$edge_dir/current")
[[ "$previous" =~ ^releases/[a-zA-Z0-9._-]+$ && -d "$edge_dir/$previous" ]]
openssl x509 -in "$edge_dir/current/fullchain.pem" -noout >/dev/null

generation=$(mktemp -d "$edge_dir/releases/ip-tls.XXXXXXXX")
install -m 600 -- "$RENEWED_LINEAGE/fullchain.pem" "$generation/fullchain.pem"
install -m 600 -- "$RENEWED_LINEAGE/privkey.pem" "$generation/privkey.pem"
bash "$verifier" "$ip" "$generation/fullchain.pem" "$generation/privkey.pem" "$upstream"
if openssl x509 -in "$generation/fullchain.pem" -checkend 604800 -noout >/dev/null; then
    printf '%s\n' 'renewal_certificate_exceeds_short_lived_window=FAIL' >&2
    exit 1
fi

fingerprint() {
    openssl x509 -in "$1" -outform DER | sha256sum
}

verify_served() {
    local expected=$1 actual
    for ((attempt = 0; attempt < 8; attempt++)); do
        if actual=$(timeout 3 openssl s_client -connect 127.0.0.1:443 -noservername \
            -verify_return_error -verify_ip "$ip" -showcerts </dev/null 2>/dev/null |
            openssl x509 -outform DER 2>/dev/null | sha256sum) && [[ "$actual" == "$expected" ]]; then
            return 0
        fi
        sleep 1
    done
    return 1
}

point_to() {
    local target=$1 pointer=$generation/$2
    ln -s -- "$target" "$pointer"
    mv -Tf -- "$pointer" "$edge_dir/current"
}

old_fingerprint=$(fingerprint "$edge_dir/current/fullchain.pem")
new_fingerprint=$(fingerprint "$generation/fullchain.pem")
verify_served "$old_fingerprint"
if [[ "$old_fingerprint" == "$new_fingerprint" ]]; then
    printf '%s\n' 'renewal_current_certificate_verified=PASS'
    exit 0
fi

rollback() {
    local status=$?
    trap - EXIT
    if ! point_to "$previous" rollback-pointer || ! nginx -t -q || ! systemctl reload nginx || ! verify_served "$old_fingerprint"; then
        printf '%s\n' 'renewal_rollback_requires_attention=FAIL' >&2
    else
        printf '%s\n' 'renewal_old_served_leaf_restored=PASS' >&2
    fi
    exit "$status"
}

trap rollback EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
point_to "releases/${generation##*/}" forward-pointer
nginx -t -q
systemctl reload nginx
verify_served "$new_fingerprint"
trap - EXIT HUP INT TERM
printf '%s\n' 'renewal_new_served_leaf_verified=PASS'
