"""Bounded independent-process tests using only temporary synthetic files."""

import hashlib
import os
import pathlib
import runpy
import subprocess
import sys
import tempfile
import threading
import time


PROBE_SHA256 = "88b8bde3e61a47a1e6b50a5b947619a29e9cf465d987512205dc818bd5e259b6"
PARSER_SHA256 = "9ac7451fae3d0a956b7d62546d0ccd97f06fbf383ddd190b6fd5a983314e4d3d"
LIMIT = 2048
CHILD = r'''
import os, sys
mode, scenario, _pid_path = sys.argv[1:4]
version = b"mysqldump  Ver 10.11.14-MariaDB\n"
if scenario == "first_nonzero" and mode == "--version": sys.exit(17)
if scenario == "second_nonzero" and mode == "--help": sys.exit(23)
if scenario == "stderr" and mode == "--help": os.write(2, b"SECRET_MARKER_116")
if mode == "--version": os.write(1, version)
else: os.write(1, version + b"Usage: synthetic SECRET_MARKER_116\n")
'''


def capture_process(argv: list[str]) -> tuple[str, bytes, bytes, int | None]:
    """Keep both streams bounded; return raw bytes only to this test process."""
    deadline = time.monotonic() + 3
    try:
        proc = subprocess.Popen(
            argv, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, shell=False, env={}, bufsize=0, close_fds=True,
        )
    except OSError:
        return "START_FAILED", b"", b"", None
    buffers = [bytearray(), bytearray()]
    exceeded = threading.Event()
    read_failed = threading.Event()

    def drain(index, pipe):
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
        threading.Thread(target=drain, args=(0, proc.stdout), daemon=True),
        threading.Thread(target=drain, args=(1, proc.stderr), daemon=True),
    ]
    for reader in readers:
        reader.start()
    reason = None
    while True:
        if exceeded.is_set():
            reason = "LIMIT"
            break
        if read_failed.is_set():
            reason = "INCOMPLETE"
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
            return "TERMINATION_FAILED", b"", b"", proc.poll()
    else:
        try:
            proc.wait(timeout=0)
        except subprocess.TimeoutExpired:
            reason = "INCOMPLETE"
    try:
        proc.stdout.close()
        proc.stderr.close()
    except (OSError, ValueError):
        return "INCOMPLETE", b"", b"", proc.returncode
    for reader in readers:
        reader.join(timeout=0.2)
    if any(reader.is_alive() for reader in readers) or read_failed.is_set():
        return "INCOMPLETE", b"", b"", proc.returncode
    return reason or "COMPLETE", bytes(buffers[0]), bytes(buffers[1]), proc.returncode


def main() -> None:
    checks = 0
    evidence = pathlib.Path(__file__).resolve().parent.parent
    probe = evidence / "AUTH-115-REMOTE-READONLY-PROBE-PROGRAM-SYNTHETIC-CANDIDATE" / "probe_program.py"
    parser = evidence / "AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC" / "single_exit_parser.py"
    assert hashlib.sha256(probe.read_bytes()).hexdigest() == PROBE_SHA256
    assert hashlib.sha256(parser.read_bytes()).hexdigest() == PARSER_SHA256
    parse_single_exit = runpy.run_path(str(parser))["parse_single_exit"]
    adapter = pathlib.Path(__file__).with_name("test_adapter.py")

    with tempfile.TemporaryDirectory(prefix="auth116-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        fake_tool = root / "synthetic-tool.bin"
        fake_tool.write_bytes(b"SYNTHETIC_FILE_BYTES_ONLY")
        fake_hash = hashlib.sha256(fake_tool.read_bytes()).hexdigest()
        child = root / "synthetic_child.py"
        child.write_text(CHILD, encoding="utf-8")
        pid_path = root / "pid"

        def run(scenario):
            argv = [
                sys.executable, "-B", str(adapter), str(probe), str(fake_tool),
                fake_tool.name, fake_hash, str(fake_tool.stat().st_size),
                "500", "mysqldump", str(child), scenario, str(pid_path),
            ]
            return capture_process(argv)

        state, out, err, code = run("normal")
        assert (state, code, err) == ("COMPLETE", 0, b"")
        assert out.count(b"\n") == 1 and out.endswith(b"\n")
        assert b"SECRET_MARKER_116" not in out and str(fake_tool).encode() not in out
        parsed = parse_single_exit(out, err, code, stdout_complete=True, stderr_complete=True)
        assert parsed["status"] == "PROTOCOL_CONSISTENT_TEXT_CANDIDATE"
        checks += 1

        for scenario in ("first_nonzero", "second_nonzero", "stderr", "write_failure"):
            state, out, err, code = run(scenario)
            assert (state, code, out, err) == ("COMPLETE", 1, b"", b"")
            parsed = parse_single_exit(out, err, code, stdout_complete=True, stderr_complete=True)
            assert parsed["status"] == "SSH_NONZERO_EXIT"
            checks += 1

        state, out, err, code = run("hang_launch")
        assert state == "TIMEOUT" and code is not None
        assert b"SECRET_MARKER_116" not in out + err
        checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
