"""Synthetic process output only; never reads files or network."""

import json
import sys
import time


mode = sys.argv[1] if len(sys.argv) == 2 else "invalid"
receipt = {
    "stage": "KEY_BASE64",
    "category": "FORMAT_INVALID",
    "checked_entries": 3,
    "prior_target_candidate": "NO",
    "port": "UNKNOWN",
    "host_key_trust": "UNKNOWN",
}

if mode == "normal":
    sys.stdout.write(json.dumps(receipt, separators=(",", ":")) + "\n")
elif mode == "stderr":
    sys.stderr.write("SYNTHETIC_SECRET_STDERR\n")
    sys.stdout.write(json.dumps(receipt, separators=(",", ":")) + "\n")
elif mode == "overflow":
    sys.stdout.write("x" * 3000 + "\n")
elif mode == "timeout":
    time.sleep(5)
else:
    sys.stdout.write("SYNTHETIC_SECRET_INVALID\n")
