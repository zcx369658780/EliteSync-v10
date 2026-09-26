"""Synthetic-only local process capture wired to the accepted AUTH-110 parser."""

from __future__ import annotations

import hashlib
import os
from pathlib import Path
import subprocess
import threading
import time


LIMIT = 2048
PARSER_SHA256 = "ff6268d37c539f89843ee40652d3f284c4bc848aeb40e95527475d32ca7b25b0"
PARSER_NAME = "AUTH-110-BOUNDED-PROJECTION-TRANSPORT-PARSER-SYNTHETIC"
OPTIONS = (
    "--databases", "--routines", "--events", "--triggers",
    "--single-transaction", "--quick", "--lock-tables", "--opt",
    "--no-data-med",
)


def capture_and_parse_synthetic(
    executable: str,
    argv: tuple[str, ...],
    *,
    timeout_seconds: float,
    remote_exit_candidate: int | None,
    remote_exit_source: str,
) -> dict:
    """Use only with a temporary synthetic child, never a live SSH/tool path."""
    def safe(status: str, parsed: dict | None = None) -> dict:
        if parsed is None:
            parsed = {
                "status": status,
                "version_candidate": "UNKNOWN",
                "help_text_state": "UNKNOWN",
                "version_bytes": 0,
                "help_bytes": 0,
                "option_states": {name: "UNKNOWN" for name in OPTIONS},
                "identity_state": "UNVERIFIED",
            }
        return {
            **parsed,
            "capture_state": status,
            "process_source": "SYNTHETIC_LOCAL_PROCESS_ONLY",
            "remote_exit_source": "UNVERIFIED_CALLER_CANDIDATE",
        }

    if (
        type(executable) is not str or not os.path.isabs(executable) or "\x00" in executable
        or type(argv) is not tuple
        or not all(type(value) is str and "\x00" not in value for value in argv)
        or type(timeout_seconds) not in (int, float)
        or not 0 < timeout_seconds <= 30
        or remote_exit_source != "UNVERIFIED"
        or (remote_exit_candidate is not None and (
            type(remote_exit_candidate) is not int
            or not -2**31 <= remote_exit_candidate < 2**31
        ))
    ):
        return safe("INVALID_INPUT")

    deadline = time.monotonic() + timeout_seconds
    try:
        process = subprocess.Popen(
            [executable, *argv], stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            shell=False, env={}, bufsize=0, close_fds=True,
        )
    except (OSError, ValueError):
        return safe("SPAWN_FAILED")

    buffers = [bytearray(), bytearray()]
    exceeded = threading.Event()
    read_failed = threading.Event()

    def drain(index: int, pipe) -> None:
        try:
            while True:
                chunk = pipe.read(4096)
                if not chunk:
                    return
                room = LIMIT - len(buffers[index])
                if len(chunk) > room:
                    buffers[index].extend(chunk[:max(0, room)])
                    exceeded.set()
                    return
                buffers[index].extend(chunk)
        except (OSError, ValueError):
            read_failed.set()

    readers = [
        threading.Thread(target=drain, args=(0, process.stdout), daemon=True),
        threading.Thread(target=drain, args=(1, process.stderr), daemon=True),
    ]
    for reader in readers:
        reader.start()

    reason = None
    while True:
        if exceeded.is_set():
            reason = "TRANSPORT_LIMIT"
            break
        if read_failed.is_set():
            reason = "CAPTURE_INCOMPLETE"
            break
        if process.poll() is not None and not any(reader.is_alive() for reader in readers):
            break
        if time.monotonic() >= deadline:
            reason = "TIMEOUT"
            break
        time.sleep(min(0.005, max(0, deadline - time.monotonic())))

    if reason is not None:
        try:
            if process.poll() is None:
                process.kill()
            process.wait(timeout=2)
        except (OSError, subprocess.TimeoutExpired):
            return safe("TERMINATION_FAILED")
    else:
        try:
            process.wait(timeout=0)
        except subprocess.TimeoutExpired:
            reason = "CAPTURE_INCOMPLETE"

    try:
        process.stdout.close()
        process.stderr.close()
    except (OSError, ValueError):
        return safe("CAPTURE_INCOMPLETE")
    for reader in readers:
        reader.join(timeout=0.2)
    if any(reader.is_alive() for reader in readers) or read_failed.is_set():
        return safe("CAPTURE_INCOMPLETE")
    if reason is not None:
        return safe(reason)
    if process.returncode != 0:
        return safe("LOCAL_NONZERO_EXIT")
    if buffers[1]:
        return safe("LOCAL_STDERR_PRESENT")

    # Load the accepted pure parser by exact source hash, without bytecode writes.
    try:
        source_path = Path(__file__).resolve().parent.parent / PARSER_NAME / "transport_parser.py"
        source = source_path.read_bytes()
        if hashlib.sha256(source).hexdigest() != PARSER_SHA256:
            return safe("PARSER_SOURCE_MISMATCH")
        namespace = {"__name__": "_auth110_pinned_parser"}
        exec(compile(source, "<pinned-auth110-parser>", "exec"), namespace)
        parsed = namespace["parse_transport"](
            bytes(buffers[0]), bytes(buffers[1]), process.returncode,
            remote_exit_candidate, stdout_complete=True, stderr_complete=True,
        )
    except Exception:
        return safe("PARSER_UNAVAILABLE")
    return safe("CAPTURE_COMPLETE", parsed)
