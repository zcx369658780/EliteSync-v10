"""Pure synthetic parser with one SSH exit candidate and no process access."""

from __future__ import annotations

import json
import re


MAX_STREAM_BYTES = 2048
OPTIONS = (
    "--databases", "--routines", "--events", "--triggers",
    "--single-transaction", "--quick", "--lock-tables", "--opt",
    "--no-data-med",
)
FIELDS = frozenset((
    "protocol_version", "error_class", "version_candidate", "help_text_state",
    "version_bytes", "help_bytes", "exit_codes", "option_states", "identity_state",
))
REMOTE_ERRORS = frozenset((
    "NONE", "INVALID_INPUT", "SPAWN_FAILED", "OUTPUT_LIMIT", "TIMEOUT",
    "TERMINATION_FAILED", "CAPTURE_INCOMPLETE", "NONZERO_EXIT",
    "STDERR_PRESENT", "INVALID_UTF8", "TRUNCATED_OR_UNTERMINATED",
    "CONTROL_CHAR", "VERSION_UNKNOWN", "HELP_LAYOUT_UNKNOWN", "INTERNAL_FAILURE",
))
VERSION = re.compile(r"10\.11\.[0-9]{1,8}")


class _Reject(Exception):
    pass


def _unique_pairs(pairs: list[tuple[str, object]]) -> dict:
    result = {}
    for key, value in pairs:
        if key in result:
            raise _Reject()
        result[key] = value
    return result


def _reject_constant(_value: str) -> None:
    raise _Reject()


def parse_single_exit(
    stdout: bytes,
    stderr: bytes,
    ssh_exit: int | None,
    *,
    stdout_complete: bool,
    stderr_complete: bool,
) -> dict:
    """Check supplied bytes only; no independent remote exit is observed."""
    def safe(status: str, version: str = "UNKNOWN", help_state: str = "UNKNOWN",
             version_bytes: int = 0, help_bytes: int = 0) -> dict:
        return {
            "status": status,
            "version_candidate": version,
            "help_text_state": help_state,
            "version_bytes": version_bytes,
            "help_bytes": help_bytes,
            "option_states": {name: "UNKNOWN" for name in OPTIONS},
            "identity_state": "UNVERIFIED",
            "ssh_exit_source": "SSH_EXIT_OBSERVED_CANDIDATE",
            "remote_program_state": "UNVERIFIED_PROTOCOL_DECLARATION",
            "tool_exit_state": "UNVERIFIED_PROTOCOL_DECLARATION",
        }

    if type(stdout) is not bytes or type(stderr) is not bytes:
        return safe("INVALID_INPUT")
    if len(stdout) > MAX_STREAM_BYTES or len(stderr) > MAX_STREAM_BYTES:
        return safe("TRANSPORT_LIMIT")
    if type(stdout_complete) is not bool or type(stderr_complete) is not bool:
        return safe("INVALID_INPUT")
    if not stdout_complete or not stderr_complete:
        return safe("TRANSPORT_INCOMPLETE")
    if stderr:
        return safe("SSH_STDERR_PRESENT")
    if type(ssh_exit) is not int or not -2**31 <= ssh_exit < 2**31:
        return safe("SSH_EXIT_UNKNOWN")
    if ssh_exit == 255:
        return safe("SSH_255_AMBIGUOUS")
    if ssh_exit != 0:
        return safe("SSH_NONZERO_EXIT")
    if not stdout or not stdout.endswith(b"\n") or stdout.count(b"\n") != 1:
        return safe("FRAME_INVALID")
    if any(byte < 32 for byte in stdout[:-1]) or b"\x7f" in stdout:
        return safe("FRAME_INVALID")

    try:
        payload = json.loads(
            stdout[:-1].decode("utf-8", "strict"),
            object_pairs_hook=_unique_pairs,
            parse_constant=_reject_constant,
        )
    except (UnicodeError, ValueError, TypeError, RecursionError, _Reject):
        return safe("JSON_INVALID")

    if type(payload) is not dict or payload.keys() != FIELDS:
        return safe("SCHEMA_INVALID")
    if type(payload["protocol_version"]) is not int or payload["protocol_version"] != 1:
        return safe("SCHEMA_INVALID")
    if type(payload["error_class"]) is not str or payload["error_class"] not in REMOTE_ERRORS:
        return safe("SCHEMA_INVALID")
    if type(payload["version_candidate"]) is not str or (
        payload["version_candidate"] != "UNKNOWN"
        and not VERSION.fullmatch(payload["version_candidate"])
    ):
        return safe("SCHEMA_INVALID")
    if type(payload["help_text_state"]) is not str or payload["help_text_state"] not in (
        "UNKNOWN", "BOUNDED_UNPARSED"
    ):
        return safe("SCHEMA_INVALID")
    if any(
        type(payload[key]) is not int or not 0 <= payload[key] <= limit
        for key, limit in (("version_bytes", 256), ("help_bytes", 24_576))
    ):
        return safe("SCHEMA_INVALID")
    exits = payload["exit_codes"]
    if type(exits) is not list or len(exits) != 2 or any(
        code is not None and (type(code) is not int or not -2**31 <= code < 2**31)
        for code in exits
    ):
        return safe("SCHEMA_INVALID")
    options = payload["option_states"]
    if type(options) is not dict or options.keys() != set(OPTIONS) or any(
        type(value) is not str or value != "UNKNOWN" for value in options.values()
    ):
        return safe("SCHEMA_INVALID")
    if payload["identity_state"] != "CALLER_CANDIDATE_UNVERIFIED":
        return safe("SCHEMA_INVALID")

    if payload["error_class"] != "NONE":
        if payload["version_candidate"] != "UNKNOWN" or payload["help_text_state"] != "UNKNOWN":
            return safe("SCHEMA_INVALID")
        return safe("REMOTE_REPORTED_FAILURE")
    if (
        exits != [0, 0]
        or payload["version_candidate"] == "UNKNOWN"
        or payload["help_text_state"] != "BOUNDED_UNPARSED"
        or payload["version_bytes"] == 0
        or payload["help_bytes"] == 0
    ):
        return safe("SCHEMA_INVALID")
    return safe(
        "PROTOCOL_CONSISTENT_TEXT_CANDIDATE", payload["version_candidate"],
        "BOUNDED_UNPARSED", payload["version_bytes"], payload["help_bytes"],
    )
