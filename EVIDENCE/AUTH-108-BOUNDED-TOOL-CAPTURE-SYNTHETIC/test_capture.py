"""Only temporary Python children with synthetic output are launched here."""

import os
import pathlib
import sys
import tempfile

from capture import capture, dump_observation_argv


CHILD = r'''
import os, sys, threading, time
kind = sys.argv[1]
if kind == "small":
    os.write(1, b"ok\n")
elif kind == "burst":
    threads = [threading.Thread(target=lambda fd: os.write(fd, b"X" * 60000), args=(fd,)) for fd in (1, 2)]
    for thread in threads: thread.start()
    for thread in threads: thread.join()
elif kind == "nonzero":
    sys.exit(17)
elif kind == "limit":
    os.write(1, b"SYNTHETIC_SECRET_91" * 10000)
elif kind == "stderr":
    os.write(2, b"SYNTHETIC_SECRET_91")
elif kind == "control":
    os.write(1, b"\x1b[31mSYNTHETIC_SECRET_91\x00\n")
elif kind == "timeout":
    with open(sys.argv[2], "w", encoding="ascii") as handle: handle.write(str(os.getpid()))
    time.sleep(10)
    with open(sys.argv[3], "w", encoding="ascii") as handle: handle.write("survived")
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
    with tempfile.TemporaryDirectory(prefix="auth108-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        child = root / "child.py"
        child.write_text(CHILD, encoding="utf-8")

        def run(kind, *, out=256, err=256, timeout=2, extra=()):
            return capture(sys.executable, (str(child), kind, *extra), stdout_limit=out,
                           stderr_limit=err, timeout_seconds=timeout)

        result = run("small")
        assert (result.category, result.exit_code, result.complete, result.stdout_bytes) == ("OK", 0, True, 3)
        checks += 1

        result = run("burst", out=70000, err=70000)
        assert (result.category, result.stdout_bytes, result.stderr_bytes) == ("STDERR_PRESENT", 60000, 60000)
        checks += 1

        result = run("nonzero")
        assert (result.category, result.exit_code, result.complete) == ("NONZERO_EXIT", 17, True)
        checks += 1

        result = run("limit", out=64)
        assert result.category == "OUTPUT_LIMIT" and not result.complete and result.stdout_bytes == 65
        assert result.exit_code is not None
        checks += 1

        result = run("stderr")
        assert result.category == "STDERR_PRESENT" and result.stderr_bytes == len(b"SYNTHETIC_SECRET_91")
        checks += 1

        result = run("control")
        assert result.category == "OK" and result.stdout_bytes > 0
        checks += 1

        marker = root / "pid"
        survived = root / "survived"
        result = run("timeout", timeout=0.5, extra=(str(marker), str(survived)))
        assert result.category == "TIMEOUT" and not result.complete and result.exit_code is not None
        assert marker.exists() and stopped(int(marker.read_text(encoding="ascii")))
        assert not survived.exists()
        checks += 1

        for value in (result, run("stderr"), run("control"), run("limit", out=64)):
            assert "SYNTHETIC_SECRET_91" not in repr(value)
            assert str(child) not in repr(value)
        checks += 1

        assert dump_observation_argv("--version") == ("--no-defaults", "--version")
        assert dump_observation_argv("--help") == ("--no-defaults", "--help")
        assert dump_observation_argv("--defaults-file=x") is None
        checks += 1

        assert capture("relative", (), stdout_limit=1, stderr_limit=1, timeout_seconds=1).category == "INVALID_INPUT"
        checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
