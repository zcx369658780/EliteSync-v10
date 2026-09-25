"""One synthetic public-certificate fd check; raw process output stays in memory."""

from __future__ import annotations

import hashlib
import json
import os
import shutil
import subprocess
import sys
import threading
from pathlib import Path

sys.dont_write_bytecode = True

PARENT = Path(r"C:\Users\zcxve\AppData\Local\Temp")
TEMP = PARENT / "elitesync-auth60-cert-fd-readonly"
OPENSSL = Path(r"C:\Program Files\Git\usr\bin\openssl.exe")
CONFIG = Path(r"C:\Program Files\Git\usr\ssl\openssl.cnf")
SSH_EXE = Path(r"C:\Windows\System32\OpenSSH\ssh.exe")
SSH_KEY = Path(r"C:\Users\zcxve\.ssh\CodexKey.pem")
KNOWN_HOSTS = Path(r"C:\Users\zcxve\.ssh\known_hosts")
TAG = b"AUTH60_X509_FD:"
REMOTE = (
    "exec 3<&0; openssl x509 -in /dev/fd/3 -noout >/dev/null 2>/dev/null; "
    "rc=$?; printf 'AUTH60_X509_FD:%s\\n' \"$rc\""
)
CERT_MAX = 8192
STREAM_MAX = 16384


def regular_file(path: Path) -> bool:
    return path.is_file() and not is_reparse(path)


def is_reparse(path: Path) -> bool:
    attributes = getattr(path.stat(follow_symlinks=False), "st_file_attributes", 0)
    return bool(attributes & 0x400)


def safe_temp_parent() -> bool:
    if not PARENT.is_dir() or is_reparse(PARENT) or os.path.lexists(TEMP):
        return False
    if os.path.normcase(os.path.abspath(TEMP)) != os.path.normcase(str(TEMP)):
        return False
    if TEMP.parent != PARENT or PARENT.resolve(strict=True) != PARENT:
        return False
    return True


def read_stream(pipe, slot: list) -> None:
    chunks = []
    length = 0
    overflow = False
    try:
        while True:
            part = pipe.read(4096)
            if not part:
                break
            length += len(part)
            if length <= STREAM_MAX:
                chunks.append(part)
            else:
                overflow = True
    except OSError:
        overflow = True
    finally:
        pipe.close()
    slot.append((b"".join(chunks), overflow))


def capture(command: list[str], input_bytes: bytes | None, timeout: int):
    process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.PIPE, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    outputs: list[list] = [[], []]
    threads = [threading.Thread(target=read_stream, args=(pipe, slot))
               for pipe, slot in zip((process.stdout, process.stderr), outputs)]
    for thread in threads:
        thread.start()
    write_error = False
    try:
        if input_bytes:
            process.stdin.write(input_bytes)
            process.stdin.flush()
    except OSError:
        write_error = True
    finally:
        process.stdin.close()
    timed_out = False
    try:
        code = process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        process.kill()
        process.wait()
        code = None
    for thread in threads:
        thread.join()
    if write_error or timed_out or any(len(slot) != 1 for slot in outputs):
        return code, None, "CAPTURE_OR_TIMEOUT"
    (stdout, out_over), (_, err_over) = outputs[0][0], outputs[1][0]
    if out_over or err_over:
        return code, None, "CAPTURE_LIMIT"
    return code, stdout, None


def parse_frame(raw: bytes) -> int:
    if not isinstance(raw, bytes) or len(raw) > 32 or not raw.startswith(TAG):
        raise ValueError("frame")
    if not raw.endswith(b"\n") or raw.count(TAG) != 1:
        raise ValueError("frame")
    code = raw[len(TAG):-1]
    if not code or len(code) > 3 or not code.isascii() or not code.isdigit():
        raise ValueError("frame")
    value = int(code)
    if value > 255 or raw != TAG + str(value).encode("ascii") + b"\n":
        raise ValueError("frame")
    return value


def ssh_command() -> list[str]:
    return [
        str(SSH_EXE), "-i", str(SSH_KEY), "-o", "BatchMode=yes",
        "-o", "IdentitiesOnly=yes", "-o", "StrictHostKeyChecking=yes",
        "-o", "ConnectTimeout=8", "-o", f"UserKnownHostsFile={KNOWN_HOSTS}",
        "root@101.133.161.203", REMOTE,
    ]


def main() -> None:
    receipt = {
        "preflight": "NOT_CHECKED", "certificate": "NOT_CHECKED",
        "certificate_exit": "NOT_CHECKED", "certificate_bytes": "NOT_CHECKED",
        "certificate_sha256": "NOT_CHECKED", "ssh": "NOT_CHECKED",
        "ssh_exit": "NOT_CHECKED", "x509_fd": "NOT_CHECKED",
        "x509_exit": "NOT_CHECKED", "first_failure": "NONE",
        "cleanup": "NOT_CHECKED", "ssh_budget": "0/1",
    }
    created = False
    try:
        if not safe_temp_parent() or not all(regular_file(path) for path in
                (OPENSSL, CONFIG, SSH_EXE, SSH_KEY, KNOWN_HOSTS)):
            receipt["preflight"] = "FAIL"
            receipt["first_failure"] = "PREFLIGHT"
            return
        receipt["preflight"] = "PASS"
        TEMP.mkdir()
        created = True
        key = TEMP / "synthetic.key.pem"
        cert = TEMP / "synthetic.cert.pem"
        cert_command = [
            str(OPENSSL), "req", "-config", str(CONFIG), "-x509", "-newkey",
            "rsa:2048", "-nodes", "-keyout", str(key), "-out", str(cert),
            "-days", "1", "-subj", "/CN=AUTH60-SYNTHETIC-ONLY",
        ]
        code, _, capture_error = capture(cert_command, None, 35)
        receipt["certificate_exit"] = code if code is not None else "UNKNOWN"
        if code != 0 or capture_error or not regular_file(cert) or not regular_file(key):
            receipt["certificate"] = "FAIL"
            receipt["first_failure"] = "CERTIFICATE"
            return
        size = cert.stat().st_size
        receipt["certificate_bytes"] = size
        if not 500 <= size <= CERT_MAX:
            receipt["certificate"] = "FAIL"
            receipt["first_failure"] = "CERTIFICATE_LENGTH"
            return
        cert_bytes = cert.read_bytes()
        if len(cert_bytes) != size:
            receipt["certificate"] = "FAIL"
            receipt["first_failure"] = "CERTIFICATE_READ"
            return
        receipt["certificate_sha256"] = hashlib.sha256(cert_bytes).hexdigest().upper()
        receipt["certificate"] = "PASS"
        receipt["ssh_budget"] = "1/1"
        code, raw, capture_error = capture(ssh_command(), cert_bytes, 30)
        receipt["ssh_exit"] = code if code is not None else "UNKNOWN"
        if code != 0 or capture_error:
            receipt["ssh"] = "FAIL"
            receipt["first_failure"] = "SSH"
            return
        receipt["ssh"] = "PASS"
        try:
            x509_exit = parse_frame(raw)
        except ValueError:
            receipt["x509_fd"] = "UNKNOWN"
            receipt["first_failure"] = "FRAME"
            return
        receipt["x509_exit"] = x509_exit
        receipt["x509_fd"] = "PASS" if x509_exit == 0 else "FAIL"
        if x509_exit != 0:
            receipt["first_failure"] = "X509_FD"
    except (OSError, ValueError):
        if receipt["first_failure"] == "NONE":
            receipt["first_failure"] = "LOCAL_EXCEPTION"
    finally:
        if created:
            try:
                if (TEMP.parent == PARENT and PARENT.resolve(strict=True) == PARENT
                        and TEMP.is_dir() and not is_reparse(TEMP)
                        and os.path.normcase(os.path.abspath(TEMP)) == os.path.normcase(str(TEMP))):
                    shutil.rmtree(TEMP)
                    receipt["cleanup"] = "PASS" if not os.path.lexists(TEMP) else "FAIL"
                else:
                    receipt["cleanup"] = "UNRESOLVED"
            except OSError:
                receipt["cleanup"] = "UNRESOLVED"
        else:
            receipt["cleanup"] = "NOT_NEEDED"
        print(json.dumps(receipt, ensure_ascii=True, sort_keys=True))


if __name__ == "__main__":
    main()
