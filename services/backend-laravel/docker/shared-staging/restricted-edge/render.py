"""Render one vhost from an Owner-approved private input file."""

import argparse
import ipaddress
import json
import os
from pathlib import Path, PurePosixPath
import re


def public_ipv4(value):
    if not isinstance(value, str):
        raise ValueError("A canonical public IPv4 literal is required")
    address = ipaddress.IPv4Address(value)
    special = (ipaddress.IPv4Network("192.0.0.0/24"), ipaddress.IPv4Network("192.88.99.0/24"))
    if (str(address) != value or not address.is_global or address.is_multicast
            or any(address in reserved for reserved in special)):
        raise ValueError("A publicly routable IPv4 address is required")
    return str(address)


def render(inputs, template):
    paths = {"fullchain": "FULLCHAIN", "key": "KEY", "upstream_leaf": "UPSTREAM_LEAF"}
    sources = {"app": "APP_SOURCES", "web_admin": "WEB_ADMIN_SOURCES",
               "api_admin": "API_ADMIN_SOURCES", "activation": "ACTIVATION_SOURCES"}
    mode_keys = set(inputs) - {*paths, *sources}
    if mode_keys not in ({"host"}, {"public_ip"}) or not {*paths, *sources} <= inputs.keys():
        raise ValueError("The staging input fields must match the vhost contract")
    ip_mode = "public_ip" in mode_keys
    if ip_mode:
        host = public_ipv4(inputs["public_ip"])
        if inputs["api_admin"] != [] or inputs["activation"] != []:
            raise ValueError("IP mode keeps API administrators and activation closed")
        host_gate = (
            f"if ($host != {host}) {{ return 421; }}\n    "
            rf'if ($http_host !~ "^{re.escape(host)}(?::443)?$") {{ return 421; }}'
        )
        sni_gate = ""
        ipv6_listener = ""
    else:
        host = inputs["host"]
        label = r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?"
        if not isinstance(host, str) or len(host) > 253 or not re.fullmatch(rf"(?:{label}\.)+[a-z]{{2,63}}", host):
            raise ValueError("An exact canonical DNS hostname is required")
        host_gate = f"if ($host != {host}) {{ return 421; }}"
        sni_gate = f"if ($ssl_server_name != {host}) {{ return 421; }}"
        ipv6_listener = "listen [::]:443 ssl;"
    replacements = {"HOST": host, "HOST_GATE": host_gate, "SNI_GATE": sni_gate,
                    "IPV6_LISTENER": ipv6_listener}
    for field, placeholder in paths.items():
        path = inputs[field]
        if (not isinstance(path, str) or not re.fullmatch(r"/[a-zA-Z0-9_./-]+", path)
                or str(PurePosixPath(path)) != path or ".." in PurePosixPath(path).parts):
            raise ValueError(f"Invalid absolute path for {field}")
        replacements[placeholder] = path

    for field, placeholder in sources.items():
        entries = inputs[field]
        if not isinstance(entries, list) or len(entries) > 32 or (not entries and field in {"app", "web_admin"}):
            raise ValueError(f"Missing or invalid approved sources for {field}")
        if any(not isinstance(entry, str) or "/" not in entry for entry in entries):
            raise ValueError(f"Explicit CIDRs are required for {field}")
        addresses = [ipaddress.ip_network(entry, strict=True) for entry in entries]
        if (any(addr.prefixlen != addr.max_prefixlen or (ip_mode and addr.version != 4) or addr.network_address.is_unspecified
                or addr.network_address.is_multicast for addr in addresses)
                or len(set(addresses)) != len(addresses)):
            raise ValueError(f"Only distinct exact source addresses are allowed for {field}")
        replacements[placeholder] = "\n    ".join(f"{addr} 1;" for addr in addresses)

    return re.sub(r"@([A-Z][A-Z0-9_]*)@", lambda match: replacements[match[1]], template)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("private_inputs", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    template = Path(__file__).with_name("nginx.conf.in").read_text(encoding="utf-8")
    config = render(json.loads(args.private_inputs.read_text(encoding="utf-8")), template)
    fd = os.open(args.output, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as out:
        out.write(config)


if __name__ == "__main__":
    main()
