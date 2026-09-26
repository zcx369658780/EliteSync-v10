"""Phase A synthetic candidate. Never use with a real tool or host."""

from __future__ import annotations

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import threading
import time


IDENTITY_SOURCE_SHA256 = "d4d8cba362362892fd55791bae8955dd12490d893e7c998d22e66fe7cc1c9c18"
IDENTITY_SOURCE_DIR = "AUTH-114-EXECUTABLE-IDENTITY-BOUNDARY-SYNTHETIC"
OPTIONS = (
    "--databases", "--routines", "--events", "--triggers",
    "--single-transaction", "--quick", "--lock-tables", "--opt",
    "--no-data-med",
)
VERSION = re.compile(
    r"(?:mariadb-dump|mysqldump)  Ver (10\.11\.[0-9]{1,8})-MariaDB"
    r"(?: for [A-Za-z0-9._()+/ -]{1,80})?"
)
LIMITS = {"--version": 256, "--help": 24_576}
STDERR_LIMIT = 256


def _identity_function():
    source_path = Path(__file__).resolve().parent.parent / IDENTITY_SOURCE_DIR / "file_identity.py"
    source = source_path.read_bytes()
    if hashlib.sha256(source).hexdigest() != IDENTITY_SOURCE_SHA256:
        return None
    namespace = {"__name__": "_auth114_pinned_identity"}
    exec(compile(source, "<pinned-auth114-identity>", "exec"), namespace)
    return namespace["inspect_file_identity"]


def _capture(executable: str, mode: str, deadline: float) -> tuple[bytes, int] | None:
    try:
        process = subprocess.Popen(
            [executable, "--no-defaults", mode],
            stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            shell=False, env={}, bufsize=0, close_fds=True,
        )
    except Exception:
        return None

    buffers = [bytearray(), bytearray()]
    exceeded = threading.Event()
    reader_failed = threading.Event()

    def drain(index: int, pipe, maximum: int) -> None:
        try:
            while True:
                chunk = pipe.read(4096)
                if not chunk:
                    return
                remaining = maximum - len(buffers[index])
                if len(chunk) > remaining:
                    buffers[index].extend(chunk[:max(0, remaining)])
                    exceeded.set()
                    return
                buffers[index].extend(chunk)
        except Exception:
            reader_failed.set()

    readers = [
        threading.Thread(target=drain, args=(0, process.stdout, LIMITS[mode]), daemon=True),
        threading.Thread(target=drain, args=(1, process.stderr, STDERR_LIMIT), daemon=True),
    ]
    for reader in readers:
        reader.start()

    failed = False
    while True:
        if exceeded.is_set() or reader_failed.is_set():
            failed = True
            break
        if process.poll() is not None and not any(reader.is_alive() for reader in readers):
            break
        if time.monotonic() >= deadline:
            failed = True
            break
        time.sleep(min(0.005, max(0, deadline - time.monotonic())))

    if failed:
        try:
            if process.poll() is None:
                process.kill()
            process.wait(timeout=2)
        except Exception:
            return None
    else:
        try:
            process.wait(timeout=0)
        except Exception:
            return None

    try:
        process.stdout.close()
        process.stderr.close()
    except Exception:
        return None
    for reader in readers:
        reader.join(timeout=0.2)
    if failed or reader_failed.is_set() or any(reader.is_alive() for reader in readers):
        return None
    if process.returncode != 0 or buffers[1]:
        return None
    return bytes(buffers[0]), process.returncode


def _safe_text(raw: bytes, max_lines: int) -> str | None:
    try:
        value = raw.decode("utf-8", "strict")
    except UnicodeDecodeError:
        return None
    if not value.endswith("\n") or len(value.splitlines()) > max_lines:
        return None
    if "\r" in value.replace("\r\n", ""):
        return None
    if any(
        (ord(char) < 32 and char not in "\r\n")
        or 127 <= ord(char) <= 159
        for char in value
    ):
        return None
    return value.replace("\r\n", "\n")


def main(argv: list[str] | tuple[str, ...]) -> int:
    """Return 0 only after writing one fixed JSON line; every failure returns 1."""
    try:
        if len(argv) != 6 or not all(type(value) is str for value in argv):
            return 1
        executable, filename, expected_hash, size_text, timeout_text, tool_name = argv
        if tool_name not in ("mysqldump", "mariadb-dump"):
            return 1
        if not size_text.isascii() or not size_text.isdecimal():
            return 1
        if not timeout_text.isascii() or not timeout_text.isdecimal():
            return 1
        max_bytes = int(size_text)
        timeout_ms = int(timeout_text)
        if not 1 <= timeout_ms <= 10_000:
            return 1
        inspect = _identity_function()
        if inspect is None:
            return 1
        identity = inspect(executable, expected_hash, filename, max_bytes)
        if identity["category"] != "FILE_BYTES_MATCH":
            return 1

        deadline = time.monotonic() + timeout_ms / 1000
        version_capture = _capture(executable, "--version", deadline)
        if version_capture is None:
            return 1
        help_capture = _capture(executable, "--help", deadline)
        if help_capture is None:
            return 1
        version_raw, version_exit = version_capture
        help_raw, help_exit = help_capture
        version_text = _safe_text(version_raw, 1)
        help_text = _safe_text(help_raw, 300)
        if version_text is None or help_text is None:
            return 1
        version_line = version_text.removesuffix("\n")
        match = VERSION.fullmatch(version_line)
        if not match or not version_line.startswith(tool_name + "  Ver "):
            return 1
        if not help_text.startswith(version_line + "\n") or help_text.count(version_line) != 1:
            return 1

        payload = {
            "protocol_version": 1,
            "error_class": "NONE",
            "version_candidate": match.group(1),
            "help_text_state": "BOUNDED_UNPARSED",
            "version_bytes": len(version_raw),
            "help_bytes": len(help_raw),
            "exit_codes": [version_exit, help_exit],
            "option_states": {name: "UNKNOWN" for name in OPTIONS},
            "identity_state": "CALLER_CANDIDATE_UNVERIFIED",
        }
        line = (json.dumps(payload, ensure_ascii=True, separators=(",", ":")) + "\n").encode("utf-8")
        if len(line) > 2048:
            return 1
        sys.stdout.buffer.write(line)
        sys.stdout.buffer.flush()
        return 0
    except Exception:
        return 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
