"""Bounded, synthetic-only supervision of fixed Python child snippets.

This module never accepts a command or returns child output. It does not prove
process-tree cleanup or suitability for any protected preflight command.
"""

from __future__ import annotations

import subprocess
import sys
import threading
import time
from dataclasses import dataclass, field


_SNIPPETS = {
    "normal": "import sys; sys.stdout.buffer.write(b'ok')",
    "nonzero": "import sys; sys.stdout.buffer.write(b'x'); sys.exit(7)",
    "stdout_limit": "import sys; sys.stdout.buffer.write(b'x' * 65536)",
    "stderr_limit": "import sys; sys.stderr.buffer.write(b'y' * 65536)",
    "timeout": "import time; time.sleep(5)",
}
_STATUSES = frozenset({
    "COMPLETE", "EXIT_NONZERO", "TIMEOUT", "STDOUT_LIMIT", "STDERR_LIMIT",
    "START_ERROR", "TERMINATION_UNCERTAIN",
})


@dataclass
class _StreamCount:
    limit: int
    observed: int = 0
    overflow: bool = False
    error: bool = False
    done: threading.Event = field(default_factory=threading.Event)


def _count_stream(pipe, counter: _StreamCount, changed: threading.Event) -> None:
    try:
        while True:
            # The extra byte is only an overflow witness; no bytes are retained.
            remaining = counter.limit + 1 - counter.observed
            if remaining <= 0:
                counter.overflow = True
                changed.set()
                return
            part = pipe.read(min(4096, remaining))
            if not part:
                return
            counter.observed += len(part)
            if counter.observed > counter.limit:
                counter.overflow = True
                changed.set()
                return
    except (OSError, ValueError):
        counter.error = True
        changed.set()
    finally:
        counter.done.set()
        changed.set()


def _stop_direct_child(process: subprocess.Popen[bytes]) -> bool:
    if process.poll() is not None:
        return True
    try:
        process.terminate()
        process.wait(timeout=0.3)
        return True
    except (OSError, subprocess.TimeoutExpired):
        pass
    try:
        process.kill()
        process.wait(timeout=0.3)
        return True
    except (OSError, subprocess.TimeoutExpired):
        return process.poll() is not None


def run_synthetic(
    scenario: str, *, wall_seconds: float = 1.0,
    stdout_limit: int = 32, stderr_limit: int = 32,
) -> dict[str, str | int | None]:
    """Run one internally fixed synthetic child; report metadata, never content.

    The execution deadline excludes at most 0.6 seconds of bounded stop attempts
    and short reader joins. Only the direct child can be checked here.
    """
    if scenario not in _SNIPPETS:
        raise ValueError("unknown synthetic scenario")
    if not (isinstance(wall_seconds, (int, float)) and 0 < wall_seconds <= 2):
        raise ValueError("invalid synthetic wall limit")
    if not (type(stdout_limit) is int and 0 <= stdout_limit <= 256):
        raise ValueError("invalid synthetic stdout limit")
    if not (type(stderr_limit) is int and 0 <= stderr_limit <= 256):
        raise ValueError("invalid synthetic stderr limit")

    try:
        process = subprocess.Popen(
            [sys.executable, "-I", "-B", "-c", _SNIPPETS[scenario]],
            shell=False,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
    except OSError:
        return {"status": "START_ERROR", "exit_code": None,
                "stdout_bytes": 0, "stderr_bytes": 0}

    assert process.stdin is not None
    assert process.stdout is not None
    assert process.stderr is not None
    process.stdin.close()
    stdout = _StreamCount(stdout_limit)
    stderr = _StreamCount(stderr_limit)
    changed = threading.Event()
    readers = [
        threading.Thread(target=_count_stream, args=(process.stdout, stdout, changed), daemon=True),
        threading.Thread(target=_count_stream, args=(process.stderr, stderr, changed), daemon=True),
    ]
    for reader in readers:
        reader.start()

    deadline = time.monotonic() + wall_seconds
    status = "TERMINATION_UNCERTAIN"
    while True:
        if stdout.overflow:
            status = "STDOUT_LIMIT"
            break
        if stderr.overflow:
            status = "STDERR_LIMIT"
            break
        if stdout.error or stderr.error:
            break
        if time.monotonic() >= deadline:
            status = "TIMEOUT"
            break
        exit_code = process.poll()
        if exit_code is not None and stdout.done.is_set() and stderr.done.is_set():
            status = "COMPLETE" if exit_code == 0 else "EXIT_NONZERO"
            break
        changed.wait(timeout=min(0.01, max(0, deadline - time.monotonic())))
        changed.clear()

    if status not in {"COMPLETE", "EXIT_NONZERO"} and not _stop_direct_child(process):
        status = "TERMINATION_UNCERTAIN"
    for reader in readers:
        reader.join(timeout=0.1)
    if not stdout.done.is_set() or not stderr.done.is_set() or stdout.error or stderr.error:
        status = "TERMINATION_UNCERTAIN"
    # Closing a pipe held by an unresponsive reader can itself block.
    if stdout.done.is_set():
        process.stdout.close()
    if stderr.done.is_set():
        process.stderr.close()
    assert status in _STATUSES
    return {
        "status": status,
        "exit_code": process.poll(),
        "stdout_bytes": stdout.observed,
        "stderr_bytes": stderr.observed,
    }
