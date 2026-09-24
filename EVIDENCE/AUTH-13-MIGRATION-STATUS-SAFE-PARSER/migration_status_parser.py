"""Strict, offline parser for a bounded Laravel ``migrate:status`` stdout.

``parse_migration_status`` accepts only caller-supplied bytes or str. It does not
read files, environment variables, or processes. A successful return contains
only the four fixed target states and aggregate counts. Every rejection returns
only ``{"ok": False, "error": SAFE_CATEGORY}``, never input or partial results.
Even success describes one CLI migration-ledger view, not database schema,
backup validity, or the web worker's configuration.
"""

import re


MAX_INPUT_BYTES = 128 * 1024

TARGETS = (
    "0001_01_01_000000_create_users_table",
    "2026_03_11_144705_create_personal_access_tokens_table",
    "2026_03_23_200000_add_synthetic_flags_to_users_table",
    "2026_04_09_120000_add_account_layer_fields_to_users_table",
)

_SEPARATOR = r"(?:[ \t]*\.+[ \t]*|[ \t]{2,})"
_HEADER = re.compile(
    rf"^[ \t]*Migration[ \t]+name{_SEPARATOR}Batch[ \t]*/[ \t]*Status[ \t]*$"
)
_ROW = re.compile(
    rf"^[ \t]*(?P<name>[0-9]{{4}}_[0-9]{{2}}_[0-9]{{2}}_"
    rf"[0-9]{{6}}_[a-z][a-z0-9_]*){_SEPARATOR}"
    rf"(?:(?:\[(?P<batch>[1-9][0-9]*)\][ \t]+Ran)|(?P<pending>Pending))[ \t]*$"
)


def _error(category: str) -> dict[str, object]:
    return {"ok": False, "error": category}


def parse_migration_status(raw: bytes | str) -> dict[str, object]:
    """Parse a complete, uncolored CLI output or return a safe error category.

    Accepted input is at most 128 KiB of strict UTF-8, with only printable ASCII,
    tabs, CRLF/LF, one header, contiguous unique rows, and a final blank line.
    Rows need a compliant timestamped migration name, flexible dot/space leader,
    then exactly ``Pending`` or ``[positive batch] Ran``. Four fixed targets must
    all occur. No status or count is returned until the entire output passes.
    """
    if isinstance(raw, bytes):
        if len(raw) > MAX_INPUT_BYTES:
            return _error("OUTPUT_TOO_LARGE")
        try:
            text = raw.decode("utf-8", errors="strict")
        except UnicodeDecodeError:
            return _error("INVALID_UTF8")
    elif isinstance(raw, str):
        try:
            if len(raw.encode("utf-8", errors="strict")) > MAX_INPUT_BYTES:
                return _error("OUTPUT_TOO_LARGE")
        except UnicodeEncodeError:
            return _error("INVALID_UTF8")
        text = raw
    else:
        return _error("INVALID_INPUT")

    if any(character not in "\t\r\n" and not 32 <= ord(character) <= 126 for character in text):
        return _error("UNSAFE_OUTPUT")

    text = text.replace("\r\n", "\n")
    if "\r" in text:
        return _error("UNSAFE_OUTPUT")
    if not text.endswith("\n\n"):
        return _error("INCOMPLETE_OUTPUT")

    lines = text.split("\n")
    while lines and not lines[-1].strip(" \t"):
        lines.pop()
    while lines and not lines[0].strip(" \t"):
        lines.pop(0)
    if len(lines) < 2 or not _HEADER.fullmatch(lines[0]):
        return _error("MALFORMED_OUTPUT")

    states: dict[str, str] = {}
    ran = 0
    pending = 0
    for line in lines[1:]:
        if len(line) > 512 or not line.strip(" \t"):
            return _error("MALFORMED_OUTPUT")
        match = _ROW.fullmatch(line)
        if match is None:
            return _error("MALFORMED_OUTPUT")
        name = match.group("name")
        if name in states:
            return _error("DUPLICATE_ROW")
        status = "Pending" if match.group("pending") else "Ran"
        states[name] = status
        if status == "Ran":
            ran += 1
        else:
            pending += 1

    if any(name not in states for name in TARGETS):
        return _error("TARGET_MISSING")
    if len(states) != ran + pending:
        return _error("MALFORMED_OUTPUT")
    return {
        "ok": True,
        "targets": {name: states[name] for name in TARGETS},
        "total": len(states),
        "ran": ran,
        "pending": pending,
    }
