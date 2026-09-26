"""Pure parser for synthetic, already captured locator receipt bytes.

The caller owns capture, timeout, host authentication and byte provenance. This
module performs no I/O and deliberately returns no input text or path material.
"""

import json


LIMIT = 2048
KEYS = frozenset(
    {
        "protocol",
        "precheck",
        "host_identity",
        "host_key",
        "attempt_count",
        "locator_result",
        "reason",
        "tool_bytes_identity",
        "process_binding",
        "db_privilege",
    }
)
RESULTS = frozenset(
    {"ONE_ABSOLUTE_REGULAR_PATH_CANDIDATE", "NOT_FOUND", "REJECTED", "UNKNOWN"}
)
REASONS = frozenset({"NONE", "NOT_FOUND", "REJECTED", "PRECHECK_FAILED"})
CLAIMS = frozenset({"MATCH_CLAIM", "MISMATCH_CLAIM", "UNKNOWN"})


class _InvalidReceipt(ValueError):
    pass


def _unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise _InvalidReceipt("duplicate key")
        result[key] = value
    return result


def _reject_constant(_value):
    raise _InvalidReceipt("non-JSON numeric constant")


def _safe_result(status, reason, out_count, err_count, exit_class):
    return {
        "status": status,
        "reason": reason,
        "path_candidate": status == "PATH_CANDIDATE_UNVERIFIED",
        "stdout_bytes": out_count,
        "stderr_bytes": err_count,
        "ssh_exit_class": exit_class,
        "host_identity": "UNVERIFIED_PROTOCOL_DECLARATION",
        "host_key": "UNVERIFIED_PROTOCOL_DECLARATION",
        "tool_bytes_identity": "UNKNOWN",
        "process_binding": "UNKNOWN",
        "db_privilege": "UNKNOWN",
    }


def parse_locator_receipt(stdout, stderr, stdout_complete, stderr_complete, ssh_exit):
    """Return only fixed categories for caller-supplied synthetic capture values."""

    out_count = min(len(stdout), LIMIT + 1) if type(stdout) is bytes else None
    err_count = min(len(stderr), LIMIT + 1) if type(stderr) is bytes else None
    exit_class = "ZERO" if type(ssh_exit) is int and ssh_exit == 0 else "NONZERO_OR_UNKNOWN"

    def fail(reason):
        return _safe_result("REJECTED", reason, out_count, err_count, exit_class)

    if type(stdout) is not bytes or type(stderr) is not bytes:
        return fail("INVALID_INPUT")
    if type(stdout_complete) is not bool or type(stderr_complete) is not bool:
        return fail("INVALID_INPUT")
    if out_count > LIMIT or err_count > LIMIT:
        return fail("STREAM_LIMIT")
    if not stdout_complete or not stderr_complete:
        return fail("INCOMPLETE_STREAM")
    if err_count:
        return fail("STDERR_NONEMPTY")
    if type(ssh_exit) is not int:
        return fail("SSH_EXIT_UNKNOWN")
    if ssh_exit != 0:
        return fail("SSH_EXIT_NONZERO_OR_255")
    if not stdout or not stdout.endswith(b"\n") or stdout.count(b"\n") != 1:
        return fail("FRAME_INVALID")
    if stdout.startswith(b"\xef\xbb\xbf"):
        return fail("TEXT_INVALID")
    if any(byte < 0x20 or byte == 0x7F for byte in stdout[:-1]):
        return fail("TEXT_INVALID")
    try:
        decoded = stdout[:-1].decode("utf-8", errors="strict")
        receipt = json.loads(
            decoded, object_pairs_hook=_unique_object, parse_constant=_reject_constant
        )
    except (UnicodeError, ValueError, TypeError, RecursionError):
        return fail("TEXT_INVALID")
    if type(receipt) is not dict or frozenset(receipt) != KEYS:
        return fail("SCHEMA_INVALID")
    if receipt["protocol"] != "AUTH119_LOCATOR_V1":
        return fail("SCHEMA_INVALID")
    if receipt["precheck"] not in ("PASS", "FAIL"):
        return fail("SCHEMA_INVALID")
    if any(type(receipt[key]) is not str or receipt[key] not in CLAIMS for key in ("host_identity", "host_key")):
        return fail("SCHEMA_INVALID")
    if type(receipt["attempt_count"]) is not int or receipt["attempt_count"] != 1:
        return fail("SCHEMA_INVALID")
    if type(receipt["locator_result"]) is not str or type(receipt["reason"]) is not str:
        return fail("SCHEMA_INVALID")
    if receipt["locator_result"] not in RESULTS or receipt["reason"] not in REASONS:
        return fail("SCHEMA_INVALID")
    if any(
        receipt[key] != "UNKNOWN"
        for key in ("tool_bytes_identity", "process_binding", "db_privilege")
    ):
        return fail("SCHEMA_INVALID")

    claims_match = (
        receipt["precheck"] == "PASS"
        and receipt["host_identity"] == "MATCH_CLAIM"
        and receipt["host_key"] == "MATCH_CLAIM"
    )
    locator = receipt["locator_result"]
    reason = receipt["reason"]
    if claims_match and locator == "ONE_ABSOLUTE_REGULAR_PATH_CANDIDATE" and reason == "NONE":
        return _safe_result("PATH_CANDIDATE_UNVERIFIED", "NONE", out_count, err_count, exit_class)
    if claims_match and locator == "NOT_FOUND" and reason == "NOT_FOUND":
        return _safe_result("REMOTE_NEGATIVE", "NOT_FOUND", out_count, err_count, exit_class)
    if claims_match and locator == "REJECTED" and reason == "REJECTED":
        return _safe_result("REMOTE_NEGATIVE", "REJECTED", out_count, err_count, exit_class)
    if (
        receipt["precheck"] == "FAIL"
        and (receipt["host_identity"] != "MATCH_CLAIM" or receipt["host_key"] != "MATCH_CLAIM")
        and locator == "UNKNOWN"
        and reason == "PRECHECK_FAILED"
    ):
        return _safe_result("REMOTE_NEGATIVE", "PRECHECK_FAILED", out_count, err_count, exit_class)
    return fail("PROTOCOL_CONTRADICTION")
