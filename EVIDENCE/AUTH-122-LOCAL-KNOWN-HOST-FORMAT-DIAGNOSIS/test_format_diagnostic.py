"""Synthetic bytes only; no real known_hosts read, entry main, or subprocess."""

import base64
import hashlib
import importlib.util
from pathlib import Path
import stat
from types import SimpleNamespace

from format_diagnostic import diagnose_format
from local_format_entry import diagnose_memory, _load_locked_auth121, _load_locked_source


AUTH120_FILE = Path(
    r"D:\EliteSync-v10\EVIDENCE\AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE\known_host_candidate.py"
)
spec = importlib.util.spec_from_file_location("auth120_synthetic", AUTH120_FILE)
auth120 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(auth120)

SECRET = b"SYNTHETIC_OTHER_HOST_SECRET"
KEY = len(b"ssh-ed25519").to_bytes(4, "big") + b"ssh-ed25519" + (32).to_bytes(4, "big") + bytes(range(32))
GOOD = auth120.TARGET.encode() + b" ssh-ed25519 " + base64.b64encode(KEY) + b"\n"
OTHER = b"other.example ssh-ed25519 " + base64.b64encode(KEY) + b"\n"


checks = 0


def check(data, stage, category, checked=0, prior="NO"):
    global checks
    got = diagnose_format(data, auth120)
    assert got == {
        "stage": stage, "category": category, "checked_entries": checked,
        "prior_target_candidate": prior, "port": "UNKNOWN", "host_key_trust": "UNKNOWN",
    }, got
    assert SECRET.decode() not in repr(got)
    checks += 1


check(b"other.example ssh-ed25519 invalid*\n", "KEY_BASE64", "FORMAT_INVALID")
check(OTHER + b"other.example ssh-ed25519 invalid*\n", "KEY_BASE64", "FORMAT_INVALID", 1)
check(GOOD + b"other.example ssh-ed25519 invalid*\n", "KEY_BASE64", "FORMAT_INVALID", 1, "YES_CANDIDATE")
check(b"x\r\n", "INPUT_CR", "FORMAT_INVALID")
check(b"x\x00\n", "INPUT_NUL", "FORMAT_INVALID")
check(b"\xff\n", "LINE_ENCODING", "FORMAT_INVALID")
check(b" " + GOOD, "LINE_WHITESPACE", "FORMAT_INVALID")
check(b"x y\n", "FIELD_COUNT", "FORMAT_INVALID")
check(GOOD, "NONE", "NO_REJECTION", 1, "YES_CANDIDATE")
check(b"x" * 65537, "INPUT_BYTES", "INPUT_LIMIT")
check(b"x" * 2049 + b"\n", "LINE_BYTES", "INPUT_LIMIT")
check(b"\n" * 257, "INPUT_LINES", "INPUT_LIMIT")
check(GOOD + GOOD, "TARGET_REPEAT", "AMBIGUOUS_TARGET", 1, "YES_CANDIDATE")
check(b"@unknown " + GOOD, "MARKER", "MARKER_UNSUPPORTED")
check(b"[" + auth120.TARGET.encode() + b"]:22 ssh-ed25519 " + base64.b64encode(KEY) + b"\n", "HOST_FIELD", "PORT_OR_PATTERN_UNSUPPORTED")
check(None, "INPUT_TYPE", "INVALID_INPUT")

result = diagnose_memory(b"other.example ssh-ed25519 invalid*\n", auth120, diagnose_format)
assert result["stage"] == "KEY_BASE64" and result["category"] == "FORMAT_INVALID"
checks += 1
result = diagnose_memory(GOOD, auth120, diagnose_format)
assert result["category"] == "DIAGNOSTIC_FAILED" and result["stage"] == "SOURCE_RESULT_MISMATCH"
checks += 1
result = _load_locked_auth121(path=Path(__file__).parent / "nonexistent-synthetic-only")
assert result is None
checks += 1

class FakeSourceOps:
    def __init__(self, source):
        self.source = source
        self.opens = 0
        self.reads = 0

    def _info(self):
        return SimpleNamespace(
            st_mode=stat.S_IFREG, st_dev=1, st_ino=7,
            st_size=len(self.source), st_mtime_ns=9, st_file_attributes=0,
        )

    def lstat(self, _path):
        return self._info()

    def open(self, _path, _flags):
        self.opens += 1
        return 7

    def fstat(self, _handle):
        return self._info()

    def read(self, _handle, _size):
        self.reads += 1
        return self.source

    def close(self, _handle):
        pass


synthetic_source = b"def synthetic_only():\n    return 7\n"
synthetic_digest = hashlib.sha256(synthetic_source).hexdigest().upper()
fake_ops = FakeSourceOps(synthetic_source)
loaded = _load_locked_source(Path(__file__).parent / "virtual-source", synthetic_digest, "synthetic_locked", fake_ops)
assert loaded["synthetic_only"]() == 7 and (fake_ops.opens, fake_ops.reads) == (1, 1)
checks += 1
fake_ops = FakeSourceOps(synthetic_source)
assert _load_locked_source(Path(__file__).parent / "virtual-source", "0" * 64, "synthetic_locked", fake_ops) is None
checks += 1

print(f"SYNTHETIC_CHECKS_PASS={checks}")
