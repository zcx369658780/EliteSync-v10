"""Pure redaction of supplied synthetic dump-tool captures; no process or I/O."""

from __future__ import annotations

import re


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
MAX_HELP_LINES = 300
_VERSION = re.compile(
    r"(?:mariadb-dump|mysqldump)  Ver "
    r"(?P<number>10\.11\.[0-9]+)-MariaDB"
    r"(?: for [A-Za-z0-9._()+/ -]{1,80})?"
)
_SHA256 = re.compile(r"[0-9a-f]{64}")
_OPTION_LINE = re.compile(r"\s+(?:-[A-Za-z0-9],\s+)?--[a-z][a-z0-9-]{0,39}(?:\s|=|$)")


def _blank(version_size: int, help_size: int) -> dict:
    return {
        "protocol_version": 1,
        "version_candidate": "UNKNOWN",
        "tool_sha256_candidate": "UNKNOWN",
        "help_text_state": "UNKNOWN",
        "help_bytes": help_size,
        "version_bytes": version_size,
        "option_states": {name: "UNKNOWN" for name in OPTIONS},
        "error_class": "NONE",
    }


def _decode(data: bytes, maximum: int, maximum_lines: int) -> tuple[str | None, str | None]:
    if len(data) > maximum:
        return None, "OUTPUT_LIMIT"
    try:
        value = data.decode("utf-8", "strict")
    except UnicodeDecodeError:
        return None, "INVALID_UTF8"
    if not value.endswith("\n"):
        return None, "TRUNCATED_OR_UNTERMINATED"
    if "\r" in value.replace("\r\n", ""):
        return None, "CONTROL_CHAR"
    value = value.replace("\r\n", "\n")
    if any(ord(char) < 32 and char != "\n" for char in value):
        return None, "CONTROL_CHAR"
    if len(value.splitlines()) > maximum_lines:
        return None, "LINE_LIMIT"
    return value, None


def project_capture(
    *,
    tool_name: str,
    tool_sha256: str,
    tool_is_regular: bool,
    alias_is_symlink: bool,
    version_argv: tuple[str, ...],
    help_argv: tuple[str, ...],
    version_stdout: bytes,
    version_stderr: bytes,
    version_exit: int,
    help_stdout: bytes,
    help_stderr: bytes,
    help_exit: int,
    version_complete: bool,
    help_complete: bool,
) -> dict:
    """Return fixed fields only; all option states remain UNKNOWN by design."""
    version_size = len(version_stdout) if isinstance(version_stdout, bytes) else 0
    help_size = len(help_stdout) if isinstance(help_stdout, bytes) else 0
    result = _blank(version_size, help_size)

    if (
        tool_name not in ("mysqldump", "mariadb-dump")
        or type(tool_sha256) is not str
        or not _SHA256.fullmatch(tool_sha256)
        or type(tool_is_regular) is not bool
        or type(alias_is_symlink) is not bool
        or type(version_argv) is not tuple
        or type(help_argv) is not tuple
        or not all(type(x) is str for x in version_argv + help_argv)
        or not all(type(x) is bytes for x in (version_stdout, version_stderr, help_stdout, help_stderr))
        or type(version_exit) is not int
        or type(help_exit) is not int
        or type(version_complete) is not bool
        or type(help_complete) is not bool
    ):
        result["error_class"] = "INVALID_INPUT"
        return result
    if version_argv != ("--no-defaults", "--version") or help_argv != ("--no-defaults", "--help"):
        result["error_class"] = "DEFAULTS_NOT_DISABLED_FIRST"
        return result
    if not tool_is_regular or alias_is_symlink:
        result["error_class"] = "TOOL_IDENTITY_UNRESOLVED"
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
    match = _VERSION.fullmatch(version_line)
    if not match or not version_line.startswith(tool_name + "  Ver "):
        result["error_class"] = "VERSION_UNKNOWN"
        return result
    if help_text.count(version_line) != 1 or not help_text.startswith(version_line + "\n"):
        result["error_class"] = "HELP_LAYOUT_UNKNOWN"
        return result
    option_lines = [line for line in help_text.splitlines() if _OPTION_LINE.fullmatch(line)]
    if len(option_lines) != len(set(option_lines)):
        result["error_class"] = "DUPLICATE_OPTION_LINE"
        return result

    result["version_candidate"] = match["number"]
    result["tool_sha256_candidate"] = tool_sha256
    result["help_text_state"] = "BOUNDED_UNPARSED"
    return result
