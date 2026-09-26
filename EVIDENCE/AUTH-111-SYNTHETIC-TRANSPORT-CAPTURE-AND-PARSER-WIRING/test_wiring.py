"""Only temporary synthetic Python children are launched by this test."""

import json
import os
import pathlib
import sys
import tempfile

from wiring import OPTIONS, capture_and_parse_synthetic


PAYLOAD = {
    "protocol_version": 1,
    "error_class": "NONE",
    "version_candidate": "10.11.14",
    "help_text_state": "BOUNDED_UNPARSED",
    "version_bytes": 34,
    "help_bytes": 80,
    "exit_codes": [0, 0],
    "option_states": {name: "UNKNOWN" for name in OPTIONS},
    "identity_state": "CALLER_CANDIDATE_UNVERIFIED",
}
FRAME = (json.dumps(PAYLOAD, separators=(",", ":")) + "\n").encode("ascii")
CHILD = r'''
import os, sys, time, threading
kind, pid_path = sys.argv[1:3]
frame = bytes.fromhex(sys.argv[3])
if kind == "normal": os.write(1, frame)
elif kind == "parse_fail": os.write(1, b"SECRET_MARKER_85\n")
elif kind == "stdout_big": os.write(1, b"SECRET_MARKER_85" * 300)
elif kind == "stderr_big": os.write(2, b"SECRET_MARKER_85" * 300)
elif kind == "stderr":
    os.write(1, frame)
    os.write(2, b"SECRET_MARKER_85")
elif kind == "nonzero":
    os.write(1, frame)
    sys.exit(27)
elif kind == "burst":
    threads = [threading.Thread(target=lambda fd: os.write(fd, b"X" * 60000), args=(fd,)) for fd in (1, 2)]
    for thread in threads: thread.start()
    for thread in threads: thread.join()
elif kind == "timeout":
    with open(pid_path, "w", encoding="ascii") as handle: handle.write(str(os.getpid()))
    time.sleep(10)
'''


def stopped(pid: int) -> bool:
    if os.name == "nt":
        import ctypes
        kernel = ctypes.WinDLL("kernel32", use_last_error=True)
        handle = kernel.OpenProcess(0x00100000, False, pid)
        if not handle:
            return True
        try:
            return kernel.WaitForSingleObject(handle, 0) == 0
        finally:
            kernel.CloseHandle(handle)
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return True
    return False


def main() -> None:
    checks = 0
    with tempfile.TemporaryDirectory(prefix="auth111-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        child = root / "synthetic_child.py"
        marker = root / "pid"
        child.write_text(CHILD, encoding="utf-8")

        def run(kind, *, remote=0, timeout=2):
            return capture_and_parse_synthetic(
                sys.executable, ("-B", str(child), kind, str(marker), FRAME.hex()),
                timeout_seconds=timeout, remote_exit_candidate=remote,
                remote_exit_source="UNVERIFIED",
            )

        result = run("normal")
        assert result["capture_state"] == "CAPTURE_COMPLETE"
        assert result["status"] == "TEXT_CANDIDATE_ONLY"
        assert result["version_candidate"] == "10.11.14"
        assert result["remote_exit_source"] == "UNVERIFIED_CALLER_CANDIDATE"
        assert result["process_source"] == "SYNTHETIC_LOCAL_PROCESS_ONLY"
        checks += 1

        result = run("normal", remote=None)
        assert result["capture_state"] == "CAPTURE_COMPLETE"
        assert result["status"] == "EXIT_UNKNOWN"
        assert result["version_candidate"] == "UNKNOWN"
        checks += 1

        result = run("normal", remote=5)
        assert result["status"] == "REMOTE_NONZERO_EXIT"
        checks += 1

        for kind, state in (
            ("parse_fail", "CAPTURE_COMPLETE"),
            ("stdout_big", "TRANSPORT_LIMIT"),
            ("stderr_big", "TRANSPORT_LIMIT"),
            ("stderr", "LOCAL_STDERR_PRESENT"),
            ("nonzero", "LOCAL_NONZERO_EXIT"),
            ("burst", "TRANSPORT_LIMIT"),
        ):
            result = run(kind)
            assert result["capture_state"] == state
            if kind == "parse_fail":
                assert result["status"] == "JSON_INVALID"
            else:
                assert result["version_candidate"] == "UNKNOWN"
            assert "SECRET_MARKER_85" not in repr(result)
            assert str(child) not in repr(result)
            checks += 1

        result = run("timeout", timeout=0.5)
        assert result["capture_state"] == "TIMEOUT"
        assert result["version_candidate"] == "UNKNOWN"
        assert marker.exists() and stopped(int(marker.read_text(encoding="ascii")))
        checks += 1

        result = capture_and_parse_synthetic(
            "relative", (), timeout_seconds=1, remote_exit_candidate=0,
            remote_exit_source="UNVERIFIED",
        )
        assert result["status"] == "INVALID_INPUT"
        checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
