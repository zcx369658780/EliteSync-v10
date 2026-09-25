"""One positive synthetic CMS transfer with bounded, isolated local decryption."""

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
TEMP = PARENT / "elitesync-auth61-synthetic-cms-positive"
OPENSSL = Path(r"C:\Program Files\Git\usr\bin\openssl.exe")
CONFIG = Path(r"C:\Program Files\Git\usr\ssl\openssl.cnf")
SSH_EXE = Path(r"C:\Windows\System32\OpenSSH\ssh.exe")
SSH_KEY = Path(r"C:\Users\zcxve\.ssh\CodexKey.pem")
KNOWN_HOSTS = Path(r"C:\Users\zcxve\.ssh\known_hosts")
TAG = b"AUTH61_CMS:"
END = b"\nAUTH61_END\n"
FIXED = b"AUTH57-SYNTHETIC-001\n"
FIXED_SHA256 = "9377120FCEF0E6143F500E7FDF934B1AC1F9F01BFDC873004BA80B162ACFFA97"
REMOTE = (
    "exec 3<&0; payload=$(printf 'AUTH57-SYNTHETIC-001\\n' | "
    "openssl cms -encrypt -binary -stream -aes-256-gcm -outform PEM "
    "-recip /dev/fd/3 2>/dev/null); rc=$?; "
    "printf 'AUTH61_CMS:%s:%s\\n%s\\nAUTH61_END\\n' "
    "\"$rc\" \"${#payload}\" \"$payload\""
)
CERT_MAX = 8192
STREAM_MAX = 16384
CMS_MAX = 8192


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
    buffer = bytearray()
    length = 0
    overflow = False
    try:
        while True:
            part = pipe.read(4096)
            if not part:
                break
            length += len(part)
            if length <= STREAM_MAX:
                buffer.extend(part)
            else:
                overflow = True
    except OSError:
        overflow = True
    finally:
        pipe.close()
    slot.append((buffer, overflow))


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
        for slot in outputs:
            if slot:
                slot[0][0][:] = b"\x00" * len(slot[0][0])
        return code, None, "CAPTURE_OR_TIMEOUT"
    (stdout, out_over), (stderr, err_over) = outputs[0][0], outputs[1][0]
    stderr[:] = b"\x00" * len(stderr)
    if out_over or err_over:
        stdout[:] = b"\x00" * len(stdout)
        return code, None, "CAPTURE_LIMIT"
    return code, stdout, None


def parse_frame(raw: bytes | bytearray) -> tuple[int, bytearray]:
    if not isinstance(raw, (bytes, bytearray)) or len(raw) > STREAM_MAX or not raw.startswith(TAG):
        raise ValueError("frame")
    if not raw.endswith(END) or raw.count(TAG) != 1 or raw.count(END) != 1:
        raise ValueError("frame")
    newline = raw.find(b"\n")
    header = raw[len(TAG):newline]
    fields = header.split(b":")
    if len(fields) != 2:
        raise ValueError("frame")
    code, length = fields
    if not code or len(code) > 3 or not code.isascii() or not code.isdigit():
        raise ValueError("frame")
    if not length or len(length) > 5 or not length.isascii() or not length.isdigit():
        raise ValueError("frame")
    value, size = int(code), int(length)
    if value > 255 or size > CMS_MAX:
        raise ValueError("frame")
    payload = bytearray(raw[newline + 1:-len(END)])
    try:
        if size != len(payload) or raw != (TAG + str(value).encode("ascii") + b":"
                                         + str(size).encode("ascii") + b"\n" + payload + END):
            raise ValueError("frame")
        if value == 0:
            if not payload.isascii() or not payload.startswith(b"-----BEGIN CMS-----\n"):
                raise ValueError("pem")
            if not payload.endswith(b"\n-----END CMS-----"):
                raise ValueError("pem")
            if payload.count(b"-----BEGIN CMS-----") != 1 or payload.count(b"-----END CMS-----") != 1:
                raise ValueError("pem")
        elif size != 0:
            raise ValueError("failed cms with payload")
    except ValueError:
        payload[:] = b"\x00" * len(payload)
        raise
    return value, payload


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
        "ssh_exit": "NOT_CHECKED", "cms_encrypt": "NOT_CHECKED",
        "cms_exit": "NOT_CHECKED", "ciphertext_bytes": "NOT_CHECKED",
        "ciphertext_sha256": "NOT_CHECKED", "decrypt": "NOT_CHECKED",
        "decrypt_exit": "NOT_CHECKED", "decrypted_bytes": "NOT_CHECKED",
        "fixed_match": "NOT_CHECKED", "first_failure": "NONE",
        "cleanup": "NOT_CHECKED", "ssh_budget": "0/1",
    }
    created = False
    try:
        if len(FIXED) != 21 or hashlib.sha256(FIXED).hexdigest().upper() != FIXED_SHA256:
            receipt["preflight"] = "FAIL"
            receipt["first_failure"] = "FIXED_INPUT"
            return
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
            "-days", "1", "-subj", "/CN=AUTH61-SYNTHETIC-ONLY",
        ]
        code, cert_output, capture_error = capture(cert_command, None, 35)
        if cert_output is not None:
            cert_output[:] = b"\x00" * len(cert_output)
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
        code, raw, capture_error = capture(ssh_command(), cert_bytes, 35)
        receipt["ssh_exit"] = code if code is not None else "UNKNOWN"
        if code != 0 or capture_error:
            if raw is not None:
                raw[:] = b"\x00" * len(raw)
            receipt["ssh"] = "FAIL"
            receipt["first_failure"] = "SSH"
            return
        receipt["ssh"] = "PASS"
        try:
            try:
                cms_exit, payload = parse_frame(raw)
            except ValueError:
                receipt["cms_encrypt"] = "UNKNOWN"
                receipt["first_failure"] = "FRAME"
                return
        finally:
            raw[:] = b"\x00" * len(raw)
        receipt["cms_exit"] = cms_exit
        receipt["cms_encrypt"] = "PASS" if cms_exit == 0 else "FAIL"
        try:
            if cms_exit != 0:
                receipt["first_failure"] = "CMS_ENCRYPT"
                return
            receipt["ciphertext_bytes"] = len(payload)
            receipt["ciphertext_sha256"] = hashlib.sha256(payload).hexdigest().upper()
            decrypt_command = [
                str(OPENSSL), "cms", "-decrypt", "-binary", "-inform", "PEM",
                "-recip", str(cert), "-inkey", str(key),
            ]
            decrypt_input = payload + b"\n"
            try:
                code, isolated, capture_error = capture(decrypt_command, decrypt_input, 20)
            finally:
                decrypt_input[:] = b"\x00" * len(decrypt_input)
            receipt["decrypt_exit"] = code if code is not None else "UNKNOWN"
            if capture_error or isolated is None:
                receipt["decrypt"] = "FAIL"
                receipt["first_failure"] = "DECRYPT_CAPTURE"
                return
            try:
                receipt["decrypted_bytes"] = len(isolated)
                matched = (code == 0 and len(isolated) == 21 and isolated == FIXED
                           and hashlib.sha256(isolated).hexdigest().upper() == FIXED_SHA256)
                receipt["fixed_match"] = bool(matched)
                receipt["decrypt"] = "PASS" if matched else "FAIL"
                if not matched:
                    receipt["first_failure"] = "DECRYPT_OR_CONTENT"
            finally:
                isolated[:] = b"\x00" * len(isolated)
        finally:
            payload[:] = b"\x00" * len(payload)
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
