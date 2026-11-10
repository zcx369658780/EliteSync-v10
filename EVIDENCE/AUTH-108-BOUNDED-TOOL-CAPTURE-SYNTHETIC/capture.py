"""Bounded local child-process capture. No tool discovery, shell, or network."""

from __future__ import annotations

import os
import subprocess
import threading
import time
from dataclasses import dataclass


@dataclass(frozen=True)
class CaptureResult:
    category: str
    exit_code: int | None
    complete: bool
    stdout_bytes: int
    stderr_bytes: int


def capture(
    executable: str,
    argv: tuple[str, ...],
    *,
    stdout_limit: int,
    stderr_limit: int,
    timeout_seconds: float,
) -> CaptureResult:
    """Capture up to each bound in memory; return fixed metadata, never output bytes.

    The caller must independently lock executable identity before real use.
    This function supplies an empty environment and never invokes a shell.
    """
    invalid = CaptureResult("INVALID_INPUT", None, False, 0, 0)
    if (
        type(executable) is not str
        or not os.path.isabs(executable)
        or "\x00" in executable
        or type(argv) is not tuple
        or not all(type(arg) is str and "\x00" not in arg for arg in argv)
        or type(stdout_limit) is not int
        or type(stderr_limit) is not int
        or stdout_limit < 0
        or stderr_limit < 0
        or type(timeout_seconds) not in (int, float)
        or not 0 < timeout_seconds <= 30
    ):
        return invalid

    try:
        proc = subprocess.Popen(
            [executable, *argv],
            stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            shell=False,
            env={},
            bufsize=0,
            close_fds=True,
        )
    except (OSError, ValueError):
        return CaptureResult("SPAWN_FAILED", None, False, 0, 0)

    counts = [0, 0]
    exceeded = threading.Event()
    reader_failed = threading.Event()

    def drain(index: int, pipe, limit: int) -> None:
        try:
            while True:
                chunk = pipe.read(4096)
                if not chunk:
                    return
                counts[index] = min(limit + 1, counts[index] + len(chunk))
                if counts[index] > limit:
                    exceeded.set()
                    return
        except OSError:
            reader_failed.set()

    readers = [
        threading.Thread(target=drain, args=(0, proc.stdout, stdout_limit), daemon=True),
        threading.Thread(target=drain, args=(1, proc.stderr, stderr_limit), daemon=True),
    ]
    for reader in readers:
        reader.start()

    deadline = time.monotonic() + timeout_seconds
    reason = None
    while True:
        if exceeded.is_set():
            reason = "OUTPUT_LIMIT"
            break
        if reader_failed.is_set():
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
            return CaptureResult("TERMINATION_FAILED", proc.poll(), False, *counts)
    else:
        try:
            proc.wait(timeout=0)
        except subprocess.TimeoutExpired:
            reason = "CAPTURE_INCOMPLETE"

    try:
        proc.stdout.close()
        proc.stderr.close()
    except OSError:
        return CaptureResult("CAPTURE_INCOMPLETE", proc.returncode, False, *counts)
    for reader in readers:
        reader.join(timeout=0.2)
    if any(reader.is_alive() for reader in readers) or reader_failed.is_set():
        return CaptureResult("CAPTURE_INCOMPLETE", proc.returncode, False, *counts)
    if reason is not None:
        return CaptureResult(reason, proc.returncode, False, *counts)
    if proc.returncode != 0:
        return CaptureResult("NONZERO_EXIT", proc.returncode, True, *counts)
    if counts[1] != 0:
        return CaptureResult("STDERR_PRESENT", proc.returncode, True, *counts)
    return CaptureResult("OK", proc.returncode, True, *counts)


def dump_observation_argv(mode: str) -> tuple[str, ...] | None:
    """Argument example only. Never discovers or starts a dump tool."""
    if mode not in ("--version", "--help"):
        return None
    return ("--no-defaults", mode)
