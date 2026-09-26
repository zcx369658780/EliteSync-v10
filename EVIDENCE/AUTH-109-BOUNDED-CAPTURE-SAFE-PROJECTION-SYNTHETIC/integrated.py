"""Local bounded capture and safe projection; no discovery or remote access."""

from __future__ import annotations

import os
import re
import subprocess
import threading
import time


OPTIONS = (
    "--databases", "--routines", "--events", "--triggers",
    "--single-transaction", "--quick", "--lock-tables", "--opt",
    "--no-data-med",
)
_VERSION = re.compile(
    r"(?:mariadb-dump|mysqldump)  Ver (10\.11\.[0-9]+)-MariaDB"
    r"(?: for [A-Za-z0-9._()+/ -]{1,80})?"
)
_SHA256 = re.compile(r"[0-9a-f]{64}")
_LIMITS = (256, 24_576)
_STDERR_LIMIT = 256


def observe_synthetic(
    executable: str,
    *,
    expected_tool_name: str,
    expected_sha256: str,
    timeout_seconds: float = 10,
) -> dict:
    """Run exactly two fixed argv calls and return fixed safe fields only.

    Expected identity is a caller assertion, not a file/path/hash binding. This
    candidate must not be used for a real tool without an independent gate.
    """
    counts = [0, 0]
    exits = [None, None]

    def safe(error: str, version: str = "UNKNOWN", help_state: str = "UNKNOWN") -> dict:
        return {
            "protocol_version": 1,
            "error_class": error,
            "version_candidate": version,
            "help_text_state": help_state,
            "version_bytes": counts[0],
            "help_bytes": counts[1],
            "exit_codes": tuple(exits),
            "option_states": {option: "UNKNOWN" for option in OPTIONS},
            "identity_state": "CALLER_CANDIDATE_UNVERIFIED",
        }

    if (
        type(executable) is not str
        or not os.path.isabs(executable)
        or "\x00" in executable
        or expected_tool_name not in ("mariadb-dump", "mysqldump")
        or type(expected_sha256) is not str
        or not _SHA256.fullmatch(expected_sha256)
        or type(timeout_seconds) not in (int, float)
        or not 0 < timeout_seconds <= 30
    ):
        return safe("INVALID_INPUT")

    deadline = time.monotonic() + timeout_seconds

    def capture_one(mode: str, limit: int) -> tuple[str, bytes, int | None]:
        """Private bytes never cross the public observe_synthetic return."""
        try:
            proc = subprocess.Popen(
                [executable, "--no-defaults", mode],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                shell=False,
                env={},
                bufsize=0,
                close_fds=True,
            )
        except (OSError, ValueError):
            return "SPAWN_FAILED", b"", None

        buffers = [bytearray(), bytearray()]
        exceeded = threading.Event()
        read_failed = threading.Event()

        def drain(index: int, pipe, maximum: int) -> None:
            try:
                while True:
                    chunk = pipe.read(4096)
                    if not chunk:
                        return
                    room = maximum - len(buffers[index])
                    if len(chunk) > room:
                        buffers[index].extend(chunk[:max(0, room)])
                        exceeded.set()
                        return
                    buffers[index].extend(chunk)
            except (OSError, ValueError):
                read_failed.set()

        readers = [
            threading.Thread(target=drain, args=(0, proc.stdout, limit), daemon=True),
            threading.Thread(target=drain, args=(1, proc.stderr, _STDERR_LIMIT), daemon=True),
        ]
        for reader in readers:
            reader.start()

        reason = None
        while True:
            if exceeded.is_set():
                reason = "OUTPUT_LIMIT"
                break
            if read_failed.is_set():
                reason = "CAPTURE_INCOMPLETE"
                break
            if proc.poll() is not None and not any(reader.is_alive() for reader in readers):
                break
            if time.monotonic() >= deadline:
                reason = "TIMEOUT"
                break
            time.sleep(min(0.005, max(0, deadline - time.monotonic())))

        if reason is not None:
            try:
                if proc.poll() is None:
                    proc.kill()
                proc.wait(timeout=2)
            except (OSError, subprocess.TimeoutExpired):
                return "TERMINATION_FAILED", b"", proc.poll()
        else:
            try:
                proc.wait(timeout=0)
            except subprocess.TimeoutExpired:
                reason = "CAPTURE_INCOMPLETE"

        try:
            proc.stdout.close()
            proc.stderr.close()
        except (OSError, ValueError):
            return "CAPTURE_INCOMPLETE", b"", proc.returncode
        for reader in readers:
            reader.join(timeout=0.2)
        if any(reader.is_alive() for reader in readers) or read_failed.is_set():
            return "CAPTURE_INCOMPLETE", b"", proc.returncode
        if reason is not None:
            return reason, b"", proc.returncode
        if proc.returncode != 0:
            return "NONZERO_EXIT", b"", proc.returncode
        if buffers[1]:
            return "STDERR_PRESENT", b"", proc.returncode
        return "OK", bytes(buffers[0]), proc.returncode

    try:
        first_error, version_raw, exits[0] = capture_one("--version", _LIMITS[0])
        counts[0] = len(version_raw) if first_error == "OK" else 0
        if first_error != "OK":
            return safe(first_error)
        second_error, help_raw, exits[1] = capture_one("--help", _LIMITS[1])
        counts[1] = len(help_raw) if second_error == "OK" else 0
        if second_error != "OK":
            return safe(second_error)

        try:
            version_text = version_raw.decode("utf-8", "strict")
            help_text = help_raw.decode("utf-8", "strict")
        except UnicodeDecodeError:
            return safe("INVALID_UTF8")
        if not version_text.endswith("\n") or not help_text.endswith("\n"):
            return safe("TRUNCATED_OR_UNTERMINATED")
        if any(ord(char) < 32 and char not in "\r\n" for char in version_text + help_text):
            return safe("CONTROL_CHAR")
        if "\r" in (version_text + help_text).replace("\r\n", ""):
            return safe("CONTROL_CHAR")
        version_line = version_text.removesuffix("\n").removesuffix("\r")
        match = _VERSION.fullmatch(version_line)
        if not match or not version_line.startswith(expected_tool_name + "  Ver "):
            return safe("VERSION_UNKNOWN")
        if len(help_text.splitlines()) > 300 or not help_text.startswith(version_line + "\n"):
            return safe("HELP_LAYOUT_UNKNOWN")
        if help_text.count(version_line) != 1:
            return safe("HELP_LAYOUT_UNKNOWN")
        return safe("NONE", match.group(1), "BOUNDED_UNPARSED")
    except Exception:
        # No exception text or raw bytes may escape into an ordinary response.
        return safe("INTERNAL_FAILURE")
