"""Fixed, review-pending local known_hosts read entry. Do not run before Phase B."""

import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys


KNOWN_HOSTS = Path(r"C:\Users\zcxve\.ssh\known_hosts")
DEPENDENCY = Path(
    r"D:\EliteSync-v10\EVIDENCE\AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE\known_host_candidate.py"
)
DEPENDENCY_SHA256 = "2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346"
KNOWN_HOSTS_LIMIT = 65536
DEPENDENCY_LIMIT = 16384
FINGERPRINT = re.compile(r"SHA256:[A-Za-z0-9+/]{43}\Z", re.ASCII)
ALGORITHMS = frozenset({"ssh-ed25519", "ecdsa-sha2-nistp256", "ssh-rsa"})
PARSER_REASONS = frozenset(
    {
        "TARGET_NOT_FOUND",
        "INVALID_INPUT",
        "INPUT_LIMIT",
        "FORMAT_INVALID",
        "MARKER_UNSUPPORTED",
        "HOST_FORMAT_INVALID",
        "PORT_OR_PATTERN_UNSUPPORTED",
        "AMBIGUOUS_TARGET",
        "ALGORITHM_UNSUPPORTED",
        "KEY_FORMAT_INVALID",
    }
)


class _EntryError(ValueError):
    def __init__(self, category):
        self.category = category


def _negative(reason):
    return {
        "status": "REJECTED",
        "reason": reason,
        "algorithm": "UNKNOWN",
        "fingerprint_candidate": None,
        "match_kind": "UNKNOWN",
        "trust": "LOCAL_RECORD_CANDIDATE_ONLY",
        "port": "UNKNOWN",
    }


def _is_reparse(metadata):
    return stat.S_ISLNK(metadata.st_mode) or bool(
        getattr(metadata, "st_file_attributes", 0)
        & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400)
    )


def _file_identity(metadata):
    return (
        metadata.st_dev,
        metadata.st_ino,
        metadata.st_size,
        metadata.st_mtime_ns,
        metadata.st_ctime_ns,
    )


def _read_verified(path, limit, ops):
    """Read one exact regular file using one open; reject observed identity drift."""

    if not path.is_absolute() or type(limit) is not int or limit < 1:
        raise _EntryError("FIXED_INPUT_INVALID")
    try:
        for parent in reversed(path.parents):
            info = ops.lstat(str(parent))
            if _is_reparse(info) or not stat.S_ISDIR(info.st_mode):
                raise _EntryError("PATH_UNSAFE")
        before = ops.lstat(str(path))
        if _is_reparse(before) or not stat.S_ISREG(before.st_mode) or before.st_ino == 0:
            raise _EntryError("PATH_UNSAFE")
        if before.st_size < 0 or before.st_size > limit:
            raise _EntryError("SIZE_LIMIT")
        flags = os.O_RDONLY | getattr(os, "O_BINARY", 0) | getattr(os, "O_NOFOLLOW", 0)
        handle = ops.open(str(path), flags)
        try:
            opened = ops.fstat(handle)
            if _is_reparse(opened) or not stat.S_ISREG(opened.st_mode):
                raise _EntryError("PATH_UNSAFE")
            if _file_identity(before) != _file_identity(opened):
                raise _EntryError("IDENTITY_CHANGED")
            data = ops.read(handle, limit + 1)
            after_handle = ops.fstat(handle)
        finally:
            ops.close(handle)
        after_path = ops.lstat(str(path))
        if (
            _is_reparse(after_path)
            or not stat.S_ISREG(after_path.st_mode)
            or _file_identity(before) != _file_identity(after_handle)
            or _file_identity(before) != _file_identity(after_path)
        ):
            raise _EntryError("IDENTITY_CHANGED")
        if type(data) is not bytes or len(data) != before.st_size or len(data) > limit:
            raise _EntryError("READ_INCOMPLETE_OR_CHANGED")
        return data
    except _EntryError:
        raise
    except Exception:
        raise _EntryError("READ_FAILED") from None


def _locked_parser_from_bytes(source, expected_sha256):
    if type(source) is not bytes or hashlib.sha256(source).hexdigest().upper() != expected_sha256:
        raise _EntryError("DEPENDENCY_MISMATCH")
    try:
        namespace = {"__name__": "auth120_locked"}
        exec(compile(source, "<locked-auth120>", "exec"), namespace)
        parser = namespace["extract_known_host_candidate"]
        if not callable(parser):
            raise _EntryError("DEPENDENCY_INVALID")
        return parser
    except _EntryError:
        raise
    except Exception:
        raise _EntryError("DEPENDENCY_INVALID") from None


def _real_parser_loader(ops):
    source = _read_verified(DEPENDENCY, DEPENDENCY_LIMIT, ops)
    return _locked_parser_from_bytes(source, DEPENDENCY_SHA256)


def _project(parsed):
    if type(parsed) is not dict or set(parsed) != {
        "status", "reason", "algorithm", "fingerprint_candidate", "match_kind", "trust", "port"
    }:
        return _negative("PARSER_RESULT_INVALID")
    if parsed["trust"] != "LOCAL_RECORD_CANDIDATE_ONLY" or parsed["port"] != "UNKNOWN":
        return _negative("PARSER_RESULT_INVALID")
    if parsed["status"] == "FINGERPRINT_CANDIDATE":
        if (
            parsed["reason"] == "NONE"
            and type(parsed["algorithm"]) is str
            and parsed["algorithm"] in ALGORITHMS
            and type(parsed["match_kind"]) is str
            and parsed["match_kind"] in ("PLAIN", "HASHED")
            and type(parsed["fingerprint_candidate"]) is str
            and FINGERPRINT.fullmatch(parsed["fingerprint_candidate"])
        ):
            return {
                "status": "FINGERPRINT_CANDIDATE",
                "reason": "NONE",
                "algorithm": parsed["algorithm"],
                "fingerprint_candidate": parsed["fingerprint_candidate"],
                "match_kind": parsed["match_kind"],
                "trust": "LOCAL_RECORD_CANDIDATE_ONLY",
                "port": "UNKNOWN",
            }
        return _negative("PARSER_RESULT_INVALID")
    if (
        parsed["status"] in ("NO_MATCH", "REJECTED")
        and type(parsed["reason"]) is str
        and parsed["reason"] in PARSER_REASONS
        and parsed["algorithm"] == "UNKNOWN"
        and parsed["fingerprint_candidate"] is None
        and parsed["match_kind"] == "UNKNOWN"
        and (parsed["status"] != "NO_MATCH" or parsed["reason"] == "TARGET_NOT_FOUND")
    ):
        return _negative(parsed["reason"])
    return _negative("PARSER_RESULT_INVALID")


def run_once(ops=os, parser_loader=None):
    """Fixed main path uses os and the locked parser; tests inject synthetic ops."""

    try:
        parser = (parser_loader or _real_parser_loader)(ops)
        data = _read_verified(KNOWN_HOSTS, KNOWN_HOSTS_LIMIT, ops)
        return _project(parser(data))
    except _EntryError as error:
        return _negative(error.category)
    except Exception:
        return _negative("ENTRY_FAILED")


def main():
    result = _negative("ARGS_UNSUPPORTED") if len(sys.argv) != 1 else run_once()
    print(json.dumps(result, ensure_ascii=True, sort_keys=True, separators=(",", ":")))
    return 0 if result["status"] == "FINGERPRINT_CANDIDATE" else 1


if __name__ == "__main__":
    raise SystemExit(main())
