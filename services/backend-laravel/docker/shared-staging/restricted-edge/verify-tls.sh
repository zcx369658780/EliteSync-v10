#!/usr/bin/env bash
set -euo pipefail
umask 077

[[ $# -eq 4 ]]
host=$1
chain=$2
key=$3
upstream=$4
[[ -f "$chain" && -f "$key" && -f "$upstream" ]]
[[ $(stat -Lc %u -- "$key") == 0 && $(stat -Lc %a -- "$key") =~ ^(400|600)$ ]]

openssl x509 -in "$chain" -checkend 86400 -noout >/dev/null
openssl x509 -in "$chain" -noout -ext subjectAltName | grep 'DNS:' >/dev/null
openssl verify -purpose sslserver -verify_hostname "$host" -untrusted "$chain" "$chain" >/dev/null
[[ $(openssl x509 -in "$chain" -pubkey -noout | openssl dgst -sha256) == \
   "$(openssl pkey -in "$key" -passin pass: -pubout | openssl dgst -sha256)" ]]

openssl verify -purpose sslserver -CAfile "$upstream" -verify_ip 127.0.0.1 "$upstream" >/dev/null
expected=$(openssl x509 -in "$upstream" -outform DER | sha256sum)
actual=$(openssl s_client -connect 127.0.0.1:18446 -verify_return_error \
    -verify_ip 127.0.0.1 -CAfile "$upstream" -showcerts </dev/null 2>/dev/null |
    openssl x509 -outform DER | sha256sum)
[[ "$actual" == "$expected" ]]
printf '%s\n' 'public_chain_hostname_and_key=PASS' 'loopback_tls_ip_and_leaf=PASS'
