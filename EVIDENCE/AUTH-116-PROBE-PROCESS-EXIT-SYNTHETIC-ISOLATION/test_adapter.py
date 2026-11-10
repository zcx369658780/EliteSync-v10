"""Run pinned AUTH-115 bytes in a separate Python process with test injection."""

import hashlib
import os
import runpy
import subprocess
import sys
import time


PROBE_SHA256 = "88b8bde3e61a47a1e6b50a5b947619a29e9cf465d987512205dc818bd5e259b6"


class _FailBuffer:
    def write(self, _data):
        raise OSError("injected output failure")

    def flush(self):
        raise OSError("injected output failure")


class _FailStdout:
    buffer = _FailBuffer()

    def flush(self):
        pass


def main() -> None:
    if len(sys.argv) != 11:
        raise SystemExit(2)
    _, probe_path, fake_path, name, sha, size, timeout_ms, tool_name, child_path, scenario, pid_path = sys.argv
    try:
        with open(probe_path, "rb") as handle:
            if hashlib.sha256(handle.read()).hexdigest() != PROBE_SHA256:
                raise SystemExit(2)
    except OSError:
        raise SystemExit(2)

    real_popen = subprocess.Popen

    def injected_popen(argv, **kwargs):
        if argv != [fake_path, "--no-defaults", argv[2]] or argv[2] not in ("--version", "--help"):
            raise OSError("injected argv mismatch")
        if kwargs.get("shell") is not False or kwargs.get("env") != {}:
            raise OSError("injected process policy mismatch")
        if scenario == "hang_launch":
            time.sleep(10)
        tool_scenario = "normal" if scenario == "write_failure" else scenario
        return real_popen(
            [sys.executable, "-B", child_path, argv[2], tool_scenario, pid_path],
            stdin=kwargs["stdin"], stdout=kwargs["stdout"], stderr=kwargs["stderr"],
            shell=False, env={}, bufsize=0, close_fds=True,
        )

    subprocess.Popen = injected_popen
    if scenario == "write_failure":
        sys.stdout = _FailStdout()
    sys.argv = [probe_path, fake_path, name, sha, size, timeout_ms, tool_name]
    runpy.run_path(probe_path, run_name="__main__")


if __name__ == "__main__":
    main()
