"""Synthetic entry checks only; never call main or read the real target."""

import hashlib
from pathlib import Path
import stat
from types import SimpleNamespace

from local_known_host_entry import (
    KNOWN_HOSTS,
    _locked_parser_from_bytes,
    _project,
    _read_verified,
    run_once,
)


SECRET = "SYNTHETIC_SECRET_LINE"
SYNTHETIC = SECRET.encode()
FAKE_FP = "SHA256:" + "A" * 43


def info(mode, size=0, inode=17, attrs=0, mtime=11):
    return SimpleNamespace(
        st_mode=mode, st_dev=2, st_ino=inode, st_size=size,
        st_mtime_ns=mtime, st_ctime_ns=11, st_file_attributes=attrs,
    )


class FakeOps:
    def __init__(self, data=SYNTHETIC, *, target_mode=stat.S_IFREG, attrs=0,
                 change=False, parent_reparse=False, opened_change=False, short_read=False):
        self.data = data
        self.target_mode = target_mode
        self.attrs = attrs
        self.change = change
        self.parent_reparse = parent_reparse
        self.opened_change = opened_change
        self.short_read = short_read
        self.opens = 0
        self.reads = 0
        self.closes = 0
        self.target_stats = 0

    def lstat(self, path):
        if path == str(KNOWN_HOSTS):
            self.target_stats += 1
            return info(self.target_mode, len(self.data), attrs=self.attrs,
                        mtime=12 if self.change and self.target_stats > 1 else 11)
        return info(stat.S_IFDIR, inode=4, attrs=0x400 if self.parent_reparse else 0)

    def open(self, path, flags):
        assert path == str(KNOWN_HOSTS)
        self.opens += 1
        return 9

    def fstat(self, handle):
        assert handle == 9
        return info(stat.S_IFREG, len(self.data), inode=18 if self.opened_change else 17)

    def read(self, handle, size):
        assert handle == 9
        assert size == 65537
        self.reads += 1
        return self.data[:min(size, len(self.data)) - 1] if self.short_read else self.data[:size]

    def close(self, handle):
        assert handle == 9
        self.closes += 1


def fake_parser(_data):
    return {
        "status": "FINGERPRINT_CANDIDATE", "reason": "NONE",
        "algorithm": "ssh-ed25519", "fingerprint_candidate": FAKE_FP,
        "match_kind": "HASHED", "trust": "LOCAL_RECORD_CANDIDATE_ONLY",
        "port": "UNKNOWN",
    }


checks = 0


def check(condition):
    global checks
    assert condition
    checks += 1


ops = FakeOps()
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "FINGERPRINT_CANDIDATE" and result["fingerprint_candidate"] == FAKE_FP)
check((ops.opens, ops.reads, ops.closes) == (1, 1, 1))
check(SECRET not in repr(result) and result["port"] == "UNKNOWN")

ops = FakeOps(change=True)
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "REJECTED" and result["reason"] == "IDENTITY_CHANGED")
check((ops.opens, ops.reads, ops.closes) == (1, 1, 1))

ops = FakeOps(parent_reparse=True)
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "REJECTED" and result["reason"] == "PATH_UNSAFE")
check(ops.opens == 0 and ops.reads == 0)

ops = FakeOps(opened_change=True)
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "REJECTED" and result["reason"] == "IDENTITY_CHANGED")
check((ops.opens, ops.reads, ops.closes) == (1, 0, 1))

ops = FakeOps(short_read=True)
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "REJECTED" and result["reason"] == "READ_INCOMPLETE_OR_CHANGED")
check((ops.opens, ops.reads, ops.closes) == (1, 1, 1))

for mode, attrs in ((stat.S_IFLNK, 0), (stat.S_IFREG, 0x400), (stat.S_IFDIR, 0)):
    ops = FakeOps(target_mode=mode, attrs=attrs)
    result = run_once(ops, lambda _ops: fake_parser)
    check(result["status"] == "REJECTED" and result["reason"] == "PATH_UNSAFE")
    check(ops.opens == 0 and ops.reads == 0)

ops = FakeOps(data=b"x" * 65537)
result = run_once(ops, lambda _ops: fake_parser)
check(result["status"] == "REJECTED" and result["reason"] == "SIZE_LIMIT")
check(ops.opens == 0)

ops = FakeOps(data=b"x" * 65536)
check(_read_verified(KNOWN_HOSTS, 65536, ops) == b"x" * 65536)
check((ops.opens, ops.reads, ops.closes) == (1, 1, 1))

source = b"def extract_known_host_candidate(data):\n    return {'status': 'NO_MATCH'}\n"
digest = hashlib.sha256(source).hexdigest().upper()
check(callable(_locked_parser_from_bytes(source, digest)))
try:
    _locked_parser_from_bytes(source + b"x", digest)
except ValueError as error:
    check(error.category == "DEPENDENCY_MISMATCH")
else:
    raise AssertionError("dependency mismatch accepted")

bad = fake_parser(b"")
bad["unexpected"] = SECRET
result = _project(bad)
check(result["status"] == "REJECTED" and SECRET not in repr(result))
bad = fake_parser(b"")
bad["fingerprint_candidate"] = SECRET
result = _project(bad)
check(result["status"] == "REJECTED" and result["fingerprint_candidate"] is None)
bad = fake_parser(b"")
bad["port"] = "22"
result = _project(bad)
check(result["status"] == "REJECTED" and result["port"] == "UNKNOWN")

check(KNOWN_HOSTS == Path(r"C:\Users\zcxve\.ssh\known_hosts"))
print(f"SYNTHETIC_CHECKS_PASS={checks}")
