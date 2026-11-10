"""Synthetic Python children stand in for a tool; no real tool is launched."""

import os
import pathlib
import subprocess
import sys
import tempfile
from unittest import mock

import integrated


CHILD = r'''
import os, sys, threading, time
mode, scenario, pid_path = sys.argv[1:4]
version = b"mysqldump  Ver 10.11.14-MariaDB\n"
if scenario == "nonzero" and mode == "--help": sys.exit(23)
if scenario == "version_nonzero" and mode == "--version": sys.exit(19)
if scenario == "stderr" and mode == "--help": os.write(2, b"SECRET_MARKER_73")
if scenario == "burst" and mode == "--help":
    threads = [threading.Thread(target=lambda fd: os.write(fd, b"Q" * 60000), args=(fd,)) for fd in (1, 2)]
    for thread in threads: thread.start()
    for thread in threads: thread.join()
    sys.exit(0)
if scenario == "limit" and mode == "--help":
    os.write(1, b"SECRET_MARKER_73" * 3000)
    sys.exit(0)
if scenario == "timeout" and mode == "--help":
    with open(pid_path, "w", encoding="ascii") as handle: handle.write(str(os.getpid()))
    time.sleep(10)
if mode == "--version":
    if scenario == "version_mismatch": version = b"mysqldump  Ver 99.1.1-MariaDB\n"
    os.write(1, version)
else:
    if scenario == "help_mismatch": version = b"mariadb-dump  Ver 10.11.14-MariaDB\n"
    if scenario == "control": version += b"\x1b[31m"
    if scenario == "invalid_utf8": version += b"\xff"
    os.write(1, version + b"Usage: synthetic only SECRET_MARKER_73\n")
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
    real_popen = subprocess.Popen
    with tempfile.TemporaryDirectory(prefix="auth109-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        child = root / "synthetic_child.py"
        child.write_text(CHILD, encoding="utf-8")
        marker = root / "child_pid"

        def check(scenario: str, *, timeout: float = 2):
            calls = []

            def launch(argv, **kwargs):
                calls.append(tuple(argv))
                assert argv == [sys.executable, "--no-defaults", argv[2]]
                assert argv[2] in ("--version", "--help")
                assert kwargs["shell"] is False and kwargs["env"] == {}
                return real_popen(
                    [sys.executable, "-B", str(child), argv[2], scenario, str(marker)],
                    stdin=kwargs["stdin"], stdout=kwargs["stdout"],
                    stderr=kwargs["stderr"], shell=False, env={}, bufsize=0,
                    close_fds=True,
                )

            with mock.patch.object(integrated.subprocess, "Popen", side_effect=launch):
                result = integrated.observe_synthetic(
                    sys.executable, expected_tool_name="mysqldump",
                    expected_sha256="a" * 64, timeout_seconds=timeout,
                )
            return result, calls

        result, calls = check("normal")
        assert [call[1:] for call in calls] == [
            ("--no-defaults", "--version"), ("--no-defaults", "--help")
        ]
        assert (result["error_class"], result["version_candidate"], result["help_text_state"]) == (
            "NONE", "10.11.14", "BOUNDED_UNPARSED"
        )
        assert set(result["option_states"].values()) == {"UNKNOWN"}
        checks += 1

        result, calls = check("version_mismatch")
        assert result["error_class"] == "VERSION_UNKNOWN" and len(calls) == 2
        assert result["version_candidate"] == "UNKNOWN"
        checks += 1

        result, calls = check("help_mismatch")
        assert result["error_class"] == "HELP_LAYOUT_UNKNOWN" and len(calls) == 2
        assert result["version_candidate"] == "UNKNOWN"
        checks += 1

        for scenario, category, expected_calls in (
            ("version_nonzero", "NONZERO_EXIT", 1),
            ("nonzero", "NONZERO_EXIT", 2),
            ("stderr", "STDERR_PRESENT", 2),
            ("burst", "OUTPUT_LIMIT", 2),
            ("limit", "OUTPUT_LIMIT", 2),
            ("control", "CONTROL_CHAR", 2),
            ("invalid_utf8", "INVALID_UTF8", 2),
        ):
            result, calls = check(scenario)
            assert result["error_class"] == category and len(calls) == expected_calls
            assert result["version_candidate"] == "UNKNOWN"
            assert result["help_text_state"] == "UNKNOWN"
            assert "SECRET_MARKER_73" not in repr(result)
            assert str(child) not in repr(result)
            checks += 1

        result, calls = check("timeout", timeout=0.5)
        assert result["error_class"] == "TIMEOUT" and len(calls) == 2
        assert result["version_candidate"] == "UNKNOWN"
        assert marker.exists() and stopped(int(marker.read_text(encoding="ascii")))
        checks += 1

        with mock.patch.object(integrated.subprocess, "Popen") as fake:
            result = integrated.observe_synthetic(
                "relative", expected_tool_name="mysqldump", expected_sha256="a" * 64
            )
            assert result["error_class"] == "INVALID_INPUT"
            fake.assert_not_called()
        checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
