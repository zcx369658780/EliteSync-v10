"""Review-pending fixed local format entry. Do not run before Phase B."""

import hashlib
import json
import os
from pathlib import Path
import stat
import sys

AUTH121 = Path(
    r"D:\EliteSync-v10\EVIDENCE\AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY\local_known_host_entry.py"
)
AUTH121_HASH = "E58812A8FCA60859899DAE8F4D87046583068BB383E92538B5AD7C2994005ABE"
AUTH120_HASH = "2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346"
DIAGNOSTIC = Path(
    r"D:\EliteSync-v10\EVIDENCE\AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS\format_diagnostic.py"
)
DIAGNOSTIC_HASH = "7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA"
MAX_SOURCE_BYTES = 16384


def _failed(stage):
    return {
        "stage": stage,
        "category": "DIAGNOSTIC_FAILED",
        "checked_entries": 0,
        "prior_target_candidate": "NO",
        "port": "UNKNOWN",
        "host_key_trust": "UNKNOWN",
    }


def _load_locked_source(path, expected_hash, module_name, ops=os):
    """Load only fixed source bytes; this never touches the known_hosts target."""

    try:
        before = ops.lstat(str(path))
        if (
            not stat.S_ISREG(before.st_mode)
            or stat.S_ISLNK(before.st_mode)
            or getattr(before, "st_file_attributes", 0)
            & getattr(stat, "FILE_ATTRIBUTE_REPARSE_POINT", 0x400)
            or before.st_size < 1
            or before.st_size > MAX_SOURCE_BYTES
        ):
            return None
        flags = os.O_RDONLY | getattr(os, "O_BINARY", 0) | getattr(os, "O_NOFOLLOW", 0)
        handle = ops.open(str(path), flags)
        try:
            opened = ops.fstat(handle)
            source = ops.read(handle, MAX_SOURCE_BYTES + 1)
            after = ops.fstat(handle)
        finally:
            ops.close(handle)
        if (
            not stat.S_ISREG(opened.st_mode)
            or (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns)
            != (opened.st_dev, opened.st_ino, opened.st_size, opened.st_mtime_ns)
            or (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns)
            != (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns)
            or type(source) is not bytes
            or len(source) != before.st_size
            or hashlib.sha256(source).hexdigest().upper() != expected_hash
        ):
            return None
        namespace = {"__name__": module_name}
        exec(compile(source, "<locked-source>", "exec"), namespace)
        return namespace
    except Exception:
        return None


def _load_locked_auth121(path=AUTH121, ops=os):
    return _load_locked_source(path, AUTH121_HASH, "auth121_locked", ops)


def _load_locked_auth120(auth121, ops=os):
    try:
        source = auth121["_read_verified"](auth121["DEPENDENCY"], auth121["DEPENDENCY_LIMIT"], ops)
        if hashlib.sha256(source).hexdigest().upper() != AUTH120_HASH:
            return None
        namespace = {"__name__": "auth120_locked"}
        exec(compile(source, "<locked-auth120>", "exec"), namespace)
        return namespace
    except Exception:
        return None


class _Namespace:
    def __init__(self, values):
        self.__dict__.update(values)


def diagnose_memory(data, api, diagnostic):
    """Require AUTH-120's original fixed failure before classifying it."""

    try:
        source_result = api.extract_known_host_candidate(data)
        if source_result.get("status") != "REJECTED" or source_result.get("reason") != "FORMAT_INVALID":
            return _failed("SOURCE_RESULT_MISMATCH")
        result = diagnostic(data, api)
        if result["category"] != "FORMAT_INVALID":
            return _failed("DIAG_INCONSISTENT")
        return result
    except Exception:
        return _failed("ENTRY_FAILED")


def run_once(ops=os):
    """Production path is fixed; tests inject synthetic ops or call diagnose_memory."""

    auth121 = _load_locked_auth121(ops=ops)
    if auth121 is None:
        return _failed("AUTH121_DEPENDENCY_FAILED")
    diagnostic = _load_locked_source(DIAGNOSTIC, DIAGNOSTIC_HASH, "auth122_diagnostic_locked", ops)
    if diagnostic is None or not callable(diagnostic.get("diagnose_format")):
        return _failed("DIAGNOSTIC_DEPENDENCY_FAILED")
    auth120 = _load_locked_auth120(auth121, ops=ops)
    if auth120 is None:
        return _failed("AUTH120_DEPENDENCY_FAILED")
    try:
        data = auth121["_read_verified"](auth121["KNOWN_HOSTS"], auth121["KNOWN_HOSTS_LIMIT"], ops)
    except Exception:
        return _failed("TARGET_READ_FAILED")
    return diagnose_memory(data, _Namespace(auth120), diagnostic["diagnose_format"])


def main():
    result = _failed("ARGS_UNSUPPORTED") if len(sys.argv) != 1 else run_once()
    print(json.dumps(result, ensure_ascii=True, sort_keys=True, separators=(",", ":")))
    return 0 if result["category"] == "FORMAT_INVALID" else 1


if __name__ == "__main__":
    raise SystemExit(main())
