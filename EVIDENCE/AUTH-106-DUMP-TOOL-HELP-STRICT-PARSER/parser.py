"""Pure, deliberately narrow parser for supplied synthetic dump-tool text.

It never launches a process or establishes provenance for the supplied bytes.
"""

from __future__ import annotations

import re


PROTOCOL_VERSION = 1
OPTIONS = (
    "--databases",
    "--routines",
    "--events",
    "--triggers",
    "--single-transaction",
    "--quick",
    "--lock-tables",
    "--opt",
    "--no-data-med",
)
MAX_VERSION_BYTES = 256
MAX_HELP_BYTES = 24_576
MAX_HELP_LINES = 240

_BANNER = re.compile(
    r"(?P<tool>mariadb-dump|mysqldump)  Ver "
    r"(?P<major>[0-9]+)\.(?P<minor>[0-9]+)\.(?P<patch>[0-9]+)-MariaDB"
    r"(?: for [A-Za-z0-9._()+/ -]{1,80})?"
)
_OPTION = re.compile(r"  (?:-[A-Za-z0-9], )?(?P<name>--[a-z][a-z0-9-]{0,39})(?:  [A-Za-z0-9 .,:;()/+-]{1,160})?")


def _result(version_bytes: int, help_bytes: int) -> dict:
    return {
        "protocol_version": PROTOCOL_VERSION,
        "version_text_state": "UNKNOWN",
        "options": {name: "UNKNOWN" for name in OPTIONS},
        "version_bytes": version_bytes,
        "help_bytes": help_bytes,
        "error_class": "NONE",
    }


def _decode(data: bytes, maximum: int, max_lines: int) -> tuple[str | None, str | None]:
    if len(data) > maximum:
        return None, "INPUT_TOO_LARGE"
    try:
        value = data.decode("utf-8", errors="strict")
    except UnicodeDecodeError:
        return None, "INVALID_UTF8"
    if not value.endswith("\n") or "\x00" in value:
        return None, "INCOMPLETE_OR_CONTROL"
    if "\r" in value.replace("\r\n", ""):
        return None, "INCOMPLETE_OR_CONTROL"
    value = value.replace("\r\n", "\n")
    if any(ord(char) < 32 and char != "\n" for char in value):
        return None, "INCOMPLETE_OR_CONTROL"
    if len(value.splitlines()) > max_lines:
        return None, "TOO_MANY_LINES"
    return value, None


def parse_dump_text(
    version_stdout: bytes,
    version_stderr: bytes,
    version_exit: int,
    help_stdout: bytes,
    help_stderr: bytes,
    help_exit: int,
    *,
    version_complete: bool,
    help_complete: bool,
) -> dict:
    """Classify bytes only; option presence is never a host-capability verdict."""
    sizes = (
        len(version_stdout) if isinstance(version_stdout, bytes) else 0,
        len(help_stdout) if isinstance(help_stdout, bytes) else 0,
    )
    result = _result(*sizes)

    if (
        not all(isinstance(x, bytes) for x in (version_stdout, version_stderr, help_stdout, help_stderr))
        or type(version_exit) is not int
        or type(help_exit) is not int
        or type(version_complete) is not bool
        or type(help_complete) is not bool
    ):
        result["error_class"] = "INVALID_INPUT_TYPE"
        return result
    if not version_complete or not help_complete:
        result["error_class"] = "CAPTURE_INCOMPLETE"
        return result
    if version_stderr or help_stderr:
        result["error_class"] = "STDERR_PRESENT"
        return result
    if version_exit != 0 or help_exit != 0:
        result["error_class"] = "NONZERO_EXIT"
        return result

    version_text, error = _decode(version_stdout, MAX_VERSION_BYTES, 1)
    if error:
        result["error_class"] = error
        return result
    help_text, error = _decode(help_stdout, MAX_HELP_BYTES, MAX_HELP_LINES)
    if error:
        result["error_class"] = error
        return result

    version_line = version_text.removesuffix("\n")
    banner = _BANNER.fullmatch(version_line)
    if not banner:
        result["error_class"] = "VERSION_LAYOUT_UNKNOWN"
        return result
    if banner["major"] != "10" or banner["minor"] != "11":
        result["error_class"] = "VERSION_OUT_OF_RANGE"
        return result
    result["version_text_state"] = "MATCH_10_11_TEXT"

    lines = help_text.splitlines()
    tool = banner["tool"]
    if (
        len(lines) < 4
        or lines[0] != version_line
        or lines[1] != f"Usage: {tool} [OPTIONS] database [tables]"
        or lines[2] != "Options:"
        or lines[-1] != "End options."
    ):
        result["error_class"] = "HELP_LAYOUT_UNKNOWN"
        return result

    found: set[str] = set()
    for line in lines[3:-1]:
        match = _OPTION.fullmatch(line)
        if not match:
            result["error_class"] = "HELP_LAYOUT_UNKNOWN"
            return result
        name = match["name"]
        if name in found:
            result["error_class"] = "DUPLICATE_OPTION_LINE"
            return result
        found.add(name)

    result["options"] = {
        name: "PRESENT_IN_TEXT" if name in found else "ABSENT_IN_TEXT"
        for name in OPTIONS
    }
    return result
