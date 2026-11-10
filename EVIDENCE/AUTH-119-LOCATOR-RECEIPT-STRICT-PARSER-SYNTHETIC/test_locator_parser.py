"""Synthetic byte-only checks; no subprocesses, files, or network calls."""

import json

from locator_parser import parse_locator_receipt


BASE = {
    "protocol": "AUTH119_LOCATOR_V1",
    "precheck": "PASS",
    "host_identity": "MATCH_CLAIM",
    "host_key": "MATCH_CLAIM",
    "attempt_count": 1,
    "locator_result": "ONE_ABSOLUTE_REGULAR_PATH_CANDIDATE",
    "reason": "NONE",
    "tool_bytes_identity": "UNKNOWN",
    "process_binding": "UNKNOWN",
    "db_privilege": "UNKNOWN",
}
SECRET = "SYNTHETIC_SECRET_PATH_MARKER"


def wire(changes=None):
    value = dict(BASE)
    if changes:
        value.update(changes)
    return json.dumps(value, separators=(",", ":"), ensure_ascii=True).encode() + b"\n"


def check(payload, expected="REJECTED", *, stderr=b"", out_complete=True, err_complete=True, code=0):
    actual = parse_locator_receipt(payload, stderr, out_complete, err_complete, code)
    assert actual["status"] == expected, actual
    assert actual["path_candidate"] is (expected == "PATH_CANDIDATE_UNVERIFIED")
    assert actual["host_identity"] == "UNVERIFIED_PROTOCOL_DECLARATION"
    assert actual["host_key"] == "UNVERIFIED_PROTOCOL_DECLARATION"
    assert all(actual[key] == "UNKNOWN" for key in ("tool_bytes_identity", "process_binding", "db_privilege"))
    assert SECRET not in repr(actual)
    return actual


checks = 0


def run(payload, expected="REJECTED", **kwargs):
    global checks
    result = check(payload, expected, **kwargs)
    checks += 1
    return result


good = wire()
run(good, "PATH_CANDIDATE_UNVERIFIED")
run(wire({"locator_result": "NOT_FOUND", "reason": "NOT_FOUND"}), "REMOTE_NEGATIVE")
run(wire({"locator_result": "REJECTED", "reason": "REJECTED"}), "REMOTE_NEGATIVE")
run(wire({"precheck": "FAIL", "host_key": "UNKNOWN", "locator_result": "UNKNOWN", "reason": "PRECHECK_FAILED"}), "REMOTE_NEGATIVE")
run(wire({"precheck": "FAIL", "locator_result": "UNKNOWN", "reason": "PRECHECK_FAILED"}))
run(wire({"locator_result": "NOT_FOUND"}))
run(wire({"precheck": "FAIL"}))
run(wire({"host_key": "UNKNOWN"}))
run(wire({"host_identity": "MISMATCH_CLAIM"}))
run(wire({"attempt_count": 2}))
run(wire({"attempt_count": True}))
run(wire({"protocol": "OTHER"}))
run(wire({"tool_bytes_identity": "MATCH_CLAIM"}))
run(wire({"extra": SECRET}))
value = dict(BASE)
del value["reason"]
run(json.dumps(value).encode() + b"\n")
run(good[:-1])
run(good + b"{}\n")
run(b"\xef\xbb\xbf" + good)
run(b"\xff\n")
run(b"{\"protocol\":\"AUTH119_LOCATOR_V1\",\"protocol\":\"AUTH119_LOCATOR_V1\"}\n")
run(good[:-1] + b"\x1b\n")
run(good[:-1] + b"\x7f\n")
run(good[:-1] + b"\r\n")
run(b" " * 2048 + b"\n")
run(good, stderr=SECRET.encode())
run(good, out_complete=False)
run(good, err_complete=False)
run(good, code=255)
run(good, code=1)
run(good, code=None)
run(good, code=True)
run(wire({"reason": SECRET}))
run(wire({"locator_result": SECRET}))
run(wire({"host_key": SECRET}))
run(wire({"host_key": []}))
run(wire({"locator_result": {}}))
run(wire({"reason": []}))
run(good, stderr=b"x" * 2049)
large_out = run(SECRET.encode() * 100_000)
assert large_out["reason"] == "STREAM_LIMIT"
assert large_out["stdout_bytes"] == 2049
assert large_out["stderr_bytes"] == 0
large_err = run(good, stderr=SECRET.encode() * 100_000)
assert large_err["reason"] == "STREAM_LIMIT"
assert large_err["stdout_bytes"] == len(good)
assert large_err["stderr_bytes"] == 2049
run(None)
run(b"[" * 1000 + b"]" * 1000 + b"\n")

print(f"SYNTHETIC_CHECKS_PASS={checks}")
