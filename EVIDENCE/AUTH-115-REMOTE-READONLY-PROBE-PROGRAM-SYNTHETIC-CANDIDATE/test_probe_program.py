"""Temporary synthetic files and Python children only; no real tool or SSH."""

import hashlib
import io
import json
import os
import pathlib
import runpy
import subprocess
import sys
import tempfile
from unittest import mock

import probe_program


CHILD = r'''
import os, sys, threading, time
mode, scenario, pid_path = sys.argv[1:4]
version = b"mysqldump  Ver 10.11.14-MariaDB\n"
if scenario == "first_nonzero" and mode == "--version": sys.exit(17)
if scenario == "second_nonzero" and mode == "--help": sys.exit(23)
if scenario == "stderr" and mode == "--help": os.write(2, b"SECRET_MARKER_115")
if scenario == "limit" and mode == "--help":
    os.write(1, b"SECRET_MARKER_115" * 2000)
    sys.exit(0)
if scenario == "burst" and mode == "--help":
    threads = [threading.Thread(target=lambda fd: os.write(fd, b"X" * 60000), args=(fd,)) for fd in (1, 2)]
    for thread in threads: thread.start()
    for thread in threads: thread.join()
    sys.exit(0)
if scenario == "timeout" and mode == "--help":
    with open(pid_path, "w", encoding="ascii") as handle: handle.write(str(os.getpid()))
    time.sleep(10)
if mode == "--version":
    if scenario == "version_mismatch": version = b"mysqldump  Ver 99.1.1-MariaDB\n"
    os.write(1, version)
else:
    if scenario == "help_mismatch": version = b"mariadb-dump  Ver 10.11.14-MariaDB\n"
    if scenario == "control": version += b"\x7f"
    os.write(1, version + b"Usage: synthetic SECRET_MARKER_115\n")
'''


class Sink:
    def __init__(self):
        self.buffer = io.BytesIO()


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
    real_popen = subprocess.Popen
    parser_path = pathlib.Path(__file__).resolve().parent.parent / (
        "AUTH-113-SINGLE-SSH-EXIT-PROTOCOL-PARSER-SYNTHETIC/single_exit_parser.py"
    )
    parse_single_exit = runpy.run_path(str(parser_path))["parse_single_exit"]
    with tempfile.TemporaryDirectory(prefix="auth115-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        fake_tool = root / "synthetic-tool.bin"
        fake_tool.write_bytes(b"SYNTHETIC_FILE_BYTES_ONLY")
        expected_sha = hashlib.sha256(fake_tool.read_bytes()).hexdigest()
        child = root / "child.py"
        child.write_text(CHILD, encoding="utf-8")
        marker = root / "pid"

        def run(scenario, *, timeout_ms="2000", sha=expected_sha, filename="synthetic-tool.bin"):
            calls = []
            sink = Sink()

            def launch(argv, **kwargs):
                calls.append(tuple(argv))
                assert argv[0] == str(fake_tool)
                assert argv[1:] in (["--no-defaults", "--version"], ["--no-defaults", "--help"])
                assert kwargs["shell"] is False and kwargs["env"] == {}
                return real_popen(
                    [sys.executable, "-B", str(child), argv[2], scenario, str(marker)],
                    stdin=kwargs["stdin"], stdout=kwargs["stdout"],
                    stderr=kwargs["stderr"], shell=False, env={}, bufsize=0,
                    close_fds=True,
                )

            args = [str(fake_tool), filename, sha, str(fake_tool.stat().st_size),
                    timeout_ms, "mysqldump"]
            with mock.patch.object(probe_program.subprocess, "Popen", side_effect=launch), \
                 mock.patch.object(probe_program.sys, "stdout", sink):
                code = probe_program.main(args)
            return code, sink.buffer.getvalue(), calls

        code, output, calls = run("normal")
        assert code == 0 and output.endswith(b"\n") and output.count(b"\n") == 1
        assert [call[1:] for call in calls] == [
            ("--no-defaults", "--version"), ("--no-defaults", "--help")
        ]
        payload = json.loads(output)
        assert payload["exit_codes"] == [0, 0]
        assert payload["version_candidate"] == "10.11.14"
        assert set(payload["option_states"].values()) == {"UNKNOWN"}
        parsed = parse_single_exit(output, b"", 0, stdout_complete=True, stderr_complete=True)
        assert parsed["status"] == "PROTOCOL_CONSISTENT_TEXT_CANDIDATE"
        assert b"SECRET_MARKER_115" not in output and str(fake_tool).encode() not in output
        checks += 1

        for scenario, expected_calls in (
            ("first_nonzero", 1), ("second_nonzero", 2), ("stderr", 2),
            ("limit", 2), ("burst", 2), ("version_mismatch", 2),
            ("help_mismatch", 2), ("control", 2),
        ):
            code, output, calls = run(scenario)
            assert code == 1 and output == b"" and len(calls) == expected_calls
            checks += 1

        code, output, calls = run("timeout", timeout_ms="500")
        assert code == 1 and output == b"" and len(calls) == 2
        assert marker.exists() and stopped(int(marker.read_text(encoding="ascii")))
        checks += 1

        for kwargs in ({"sha": "0" * 64}, {"filename": "wrong.bin"},
                       {"timeout_ms": "0"}):
            code, output, calls = run("normal", **kwargs)
            assert code == 1 and output == b"" and len(calls) == 0
            checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
