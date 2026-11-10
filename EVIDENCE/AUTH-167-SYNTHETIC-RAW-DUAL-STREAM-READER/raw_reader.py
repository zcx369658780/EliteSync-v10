"""Synthetic-only, anonymous-pipe experiment; never returns pipe contents.

The counters describe os.read requests and returned bytes, not Python internal
copies, kernel pipe buffers, producer memory, or a protected process.
"""

from __future__ import annotations

import os
import threading
from dataclasses import dataclass, field
from typing import Callable


_BLOCK = 8
_MAX_LIMIT = 256
_SCENARIOS = frozenset({"zero", "exact", "over", "both_over", "peer_close", "read_error"})


@dataclass
class _Count:
    limit: int
    requests: list[int] = field(default_factory=list)
    completions: list[int] = field(default_factory=list)
    actual: int = 0
    peak_retained: int = 0
    overflow: bool = False
    eof: bool = False
    error: bool = False
    done: bool = False
    thread_id: int | None = None


def _drain(fd: int, count: _Count, read_fn: Callable[[int, int], bytes], gate: threading.Event) -> None:
    count.thread_id = threading.get_ident()
    try:
        gate.wait()
        while True:
            request = min(count.limit + 1 - count.actual, _BLOCK)
            if request <= 0:
                count.error = True
                return
            count.requests.append(request)
            part = read_fn(fd, request)
            completed = len(part)
            count.completions.append(completed)
            if completed > request:
                count.error = True
                return
            count.actual += completed
            count.peak_retained = max(count.peak_retained, completed)
            if not part:
                count.eof = True
                return
            if count.actual > count.limit:
                count.overflow = True
                return
            # No body is copied to the result, decoded, logged, or queued.
    except (OSError, ValueError, TypeError):
        count.error = True
    finally:
        count.done = True


def _read_pair(
    out_fd: int, err_fd: int, out_limit: int, err_limit: int,
    *, read_fn: Callable[[int, int], bytes] = os.read,
) -> dict[str, object]:
    counts = (_Count(out_limit), _Count(err_limit))
    gate = threading.Event()
    threads = (
        threading.Thread(target=_drain, args=(out_fd, counts[0], read_fn, gate), daemon=True),
        threading.Thread(target=_drain, args=(err_fd, counts[1], read_fn, gate), daemon=True),
    )
    for thread in threads:
        thread.start()
    gate.set()
    for thread in threads:
        thread.join(timeout=1.0)

    cleaned = all(not thread.is_alive() for thread in threads)
    if cleaned:
        os.close(out_fd)
        os.close(err_fd)
    if not cleaned or not all(count.done for count in counts):
        status = "THREAD_UNCERTAIN"
    elif any(count.error or not (count.eof or count.overflow) for count in counts):
        status = "READ_ERROR"
    elif counts[0].overflow and counts[1].overflow:
        status = "BOTH_LIMIT"
    elif counts[0].overflow:
        status = "STDOUT_LIMIT"
    elif counts[1].overflow:
        status = "STDERR_LIMIT"
    else:
        status = "COMPLETE"
    return {
        "status": status,
        "threads_cleaned": cleaned,
        "distinct_reader_threads": counts[0].thread_id != counts[1].thread_id,
        "stdout": _metadata(counts[0]),
        "stderr": _metadata(counts[1]),
    }


def _metadata(count: _Count) -> dict[str, object]:
    return {
        "limit": count.limit,
        "requests": tuple(count.requests),
        "completions": tuple(count.completions),
        "actual_returned": count.actual,
        "peak_retained": count.peak_retained,
        "overflow": count.overflow,
        "eof": count.eof,
        "read_error": count.error,
    }


def run_synthetic(scenario: str, *, stdout_limit: int = 8, stderr_limit: int = 8) -> dict[str, object]:
    """Run one fixed artificial-byte scenario with two local anonymous pipes."""
    if scenario not in _SCENARIOS:
        raise ValueError("unknown synthetic scenario")
    if not (type(stdout_limit) is int and 0 <= stdout_limit <= _MAX_LIMIT):
        raise ValueError("invalid stdout limit")
    if not (type(stderr_limit) is int and 0 <= stderr_limit <= _MAX_LIMIT):
        raise ValueError("invalid stderr limit")

    sizes = {
        "zero": (0, 0),
        "exact": (stdout_limit, stderr_limit),
        "over": (stdout_limit + 1, 0),
        "both_over": (stdout_limit + 1, stderr_limit + 1),
        "peer_close": (stdout_limit, 0),
        "read_error": (1, 0),
    }
    out_size, err_size = sizes[scenario]
    out_fd, out_write = os.pipe()
    err_fd, err_write = os.pipe()
    try:
        if out_size:
            os.write(out_write, b"X" * out_size)
        if err_size:
            os.write(err_write, b"Y" * err_size)
    finally:
        os.close(out_write)
        os.close(err_write)

    if scenario == "read_error":
        failed = False

        def synthetic_error(fd: int, size: int) -> bytes:
            nonlocal failed
            if fd == out_fd and not failed:
                failed = True
                raise OSError("synthetic read failure")
            return os.read(fd, size)

        return _read_pair(out_fd, err_fd, stdout_limit, stderr_limit, read_fn=synthetic_error)
    return _read_pair(out_fd, err_fd, stdout_limit, stderr_limit)
