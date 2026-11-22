"""Render one vhost from an Owner-approved private input file."""

import argparse
import ipaddress
import json
import os
from pathlib import Path, PurePosixPath
import re


def render(inputs, template):
    paths = {"fullchain": "FULLCHAIN", "key": "KEY", "upstream_leaf": "UPSTREAM_LEAF"}
    sources = {"app": "APP_SOURCES", "web_admin": "WEB_ADMIN_SOURCES",
               "api_admin": "API_ADMIN_SOURCES", "activation": "ACTIVATION_SOURCES"}
    if set(inputs) != {"host", *paths, *sources}:
        raise ValueError("The staging input fields must match the vhost contract")
    host = inputs["host"]
    label = r"[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?"
    if not isinstance(host, str) or len(host) > 253 or not re.fullmatch(rf"(?:{label}\.)+[a-z]{{2,63}}", host):
        raise ValueError("An exact canonical DNS hostname is required")

    replacements = {"HOST": host}
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
        if (any(addr.prefixlen != addr.max_prefixlen or addr.network_address.is_unspecified
                or addr.network_address.is_multicast for addr in addresses)
                or len(set(addresses)) != len(addresses)):
            raise ValueError(f"Only distinct exact source addresses are allowed for {field}")
        replacements[placeholder] = "\n    ".join(f"{addr} 1;" for addr in addresses)

    return re.sub(r"@([A-Z_]+)@", lambda match: replacements[match[1]], template)


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
