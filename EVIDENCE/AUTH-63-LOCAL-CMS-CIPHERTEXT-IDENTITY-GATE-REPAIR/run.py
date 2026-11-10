"""Bounded local CMS matrix with a live ciphertext identity consumer gate."""

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
TEMP = PARENT / "elitesync-auth63-cms-identity-gate"
OPENSSL = Path(r"C:\Program Files\Git\usr\bin\openssl.exe")
CONFIG = Path(r"C:\Program Files\Git\usr\ssl\openssl.cnf")
FIXED = b"AUTH57-SYNTHETIC-001\n"
FIXED_SHA256 = "9377120FCEF0E6143F500E7FDF934B1AC1F9F01BFDC873004BA80B162ACFFA97"
STREAM_LIMIT = 65536
ERR_LIMIT = 16384
NAMES = ("normal", "tamper", "truncate", "wrong_key", "over_limit", "interrupted")


def is_reparse(path: Path) -> bool:
    attributes = getattr(path.stat(follow_symlinks=False), "st_file_attributes", 0)
    return bool(attributes & 0x400)


def regular_file(path: Path) -> bool:
    return path.is_file() and not is_reparse(path)


def safe_parent() -> bool:
    return (PARENT.is_dir() and not is_reparse(PARENT) and not os.path.lexists(TEMP)
            and PARENT.resolve(strict=True) == PARENT and TEMP.parent == PARENT
            and os.path.normcase(os.path.abspath(TEMP)) == os.path.normcase(str(TEMP)))


def read_stream(pipe, slot: list, limit: int) -> None:
    buffer = bytearray()
    size = 0
    overflow = False
    try:
        while True:
            part = pipe.read(4096)
            if not part:
                break
            size += len(part)
            if size <= limit:
                buffer.extend(part)
            else:
                overflow = True
    except OSError:
        overflow = True
    finally:
        pipe.close()
    slot.append((buffer, overflow))


def capture(command: list[str], input_bytes: bytes | bytearray | None, timeout: int):
    process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    outputs: list[list] = [[], []]
    threads = [
        threading.Thread(target=read_stream, args=(process.stdout, outputs[0], STREAM_LIMIT)),
        threading.Thread(target=read_stream, args=(process.stderr, outputs[1], ERR_LIMIT)),
    ]
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
    if any(len(slot) != 1 for slot in outputs):
        return code, None, "CAPTURE_FAILURE"
    (stdout, out_over), (stderr, err_over) = outputs[0][0], outputs[1][0]
    stderr[:] = b"\x00" * len(stderr)
    if write_error or timed_out or out_over or err_over:
        stdout[:] = b"\x00" * len(stdout)
        return code, None, "TIMEOUT_OR_LIMIT" if timed_out or out_over or err_over else "WRITE_ERROR"
    return code, stdout, None


def synthetic_consumer(verified_bytes: bytearray) -> int:
    """In-memory sink with no file, process, or network side effect."""
    return len(verified_bytes)


def ciphertext_matches(actual_cipher: bytes | bytearray, expected_length: int,
                       expected_digest: str) -> bool:
    """Compute identity from the very bytes passed as the decrypt input."""
    return (len(actual_cipher) == expected_length and
            hashlib.sha256(actual_cipher).hexdigest().upper() == expected_digest)


def consume_only_verified(buffer: bytearray, code, actual_cipher: bytes | bytearray,
                          expected_length: int, expected_digest: str,
                          is_normal: bool, capture_ok: bool) -> dict:
    """The sole consumer call site is below, after every normal-path gate."""
    observed = len(buffer) > 0
    calls = 0
    consumed = 0
    try:
        identity_match = ciphertext_matches(actual_cipher, expected_length, expected_digest)
        allowed = (is_normal and capture_ok and identity_match and code == 0
                   and len(buffer) == 21 and buffer == FIXED
                   and hashlib.sha256(buffer).hexdigest().upper() == FIXED_SHA256)
        if allowed:
            calls = 1
            consumed = synthetic_consumer(buffer)
        return {"observed_bytes": observed, "consumer_calls": calls,
                "consumer_bytes": consumed, "identity_match": identity_match,
                "allowed": bool(allowed)}
    finally:
        buffer[:] = b"\x00" * len(buffer)


def receipt_case(code, buffer: bytearray, actual_cipher: bytes | bytearray,
                 expected_length: int, expected_digest: str,
                 is_normal: bool, capture_ok: bool, simulated: bool = False) -> dict:
    result = consume_only_verified(buffer, code, actual_cipher, expected_length,
                                   expected_digest, is_normal, capture_ok)
    cleared = all(value == 0 for value in buffer)
    result.update({"exit_code": code if code is not None else "NOT_APPLICABLE",
                   "buffer_cleared": cleared, "simulated": simulated})
    result["status"] = "PASS" if (cleared and ((result["consumer_calls"] == 1 and
        result["consumer_bytes"] == 21) if is_normal else
        (result["consumer_calls"] == 0 and result["consumer_bytes"] == 0))) else "FAIL"
    return result


def cert_command(key: Path, cert: Path, name: str) -> list[str]:
    return [str(OPENSSL), "req", "-config", str(CONFIG), "-x509", "-newkey",
            "rsa:2048", "-nodes", "-keyout", str(key), "-out", str(cert),
            "-days", "1", "-subj", f"/CN=AUTH63-{name}-SYNTHETIC"]


def decrypt_command(cert: Path, key: Path) -> list[str]:
    return [str(OPENSSL), "cms", "-decrypt", "-binary", "-inform", "DER",
            "-recip", str(cert), "-inkey", str(key)]


def run_decrypt(name: str, cipher: bytearray, cert: Path, key: Path,
                expected_length: int, expected_digest: str, normal: bool) -> dict:
    code, buffer, error = capture(decrypt_command(cert, key), cipher, 20)
    if buffer is None:
        buffer = bytearray()
    result = receipt_case(code, buffer, cipher, expected_length, expected_digest,
                          normal, error is None)
    if error is not None:
        result["status"] = "FAIL" if normal else result["status"]
    if not normal and code == 0:
        result["status"] = "FAIL"
    return result


def main() -> None:
    cases = {name: {"status": "NOT_CHECKED", "exit_code": "NOT_APPLICABLE",
                    "observed_bytes": False, "consumer_calls": 0, "consumer_bytes": 0,
                    "buffer_cleared": "NOT_CHECKED", "identity_match": "NOT_CHECKED",
                    "simulated": False} for name in NAMES}
    result = {"preflight": "NOT_CHECKED", "certificates": "NOT_CHECKED",
              "cert_exit": "NOT_CHECKED", "wrong_cert_exit": "NOT_CHECKED",
              "encrypt": "NOT_CHECKED", "encrypt_exit": "NOT_CHECKED",
              "cipher_bytes": "NOT_CHECKED", "cipher_sha256": "NOT_CHECKED",
              "cases": cases, "first_failure": "NONE", "cleanup": "NOT_CHECKED"}
    created = False
    cipher = None
    try:
        if (len(FIXED) != 21 or hashlib.sha256(FIXED).hexdigest().upper() != FIXED_SHA256
                or not safe_parent() or not all(regular_file(p) for p in (OPENSSL, CONFIG))):
            result["preflight"] = "FAIL"
            result["first_failure"] = "PREFLIGHT"
            return
        result["preflight"] = "PASS"
        TEMP.mkdir()
        created = True
        key, cert = TEMP / "synthetic.key.pem", TEMP / "synthetic.cert.pem"
        wrong_key, wrong_cert = TEMP / "wrong.key.pem", TEMP / "wrong.cert.pem"
        for label, k, c, field in (("PAIR", key, cert, "cert_exit"),
                                    ("WRONG", wrong_key, wrong_cert, "wrong_cert_exit")):
            code, output, error = capture(cert_command(k, c, label), None, 35)
            result[field] = code if code is not None else "UNKNOWN"
            if output is not None:
                output[:] = b"\x00" * len(output)
            if code != 0 or error or not regular_file(k) or not regular_file(c):
                result["certificates"] = "FAIL"
                result["first_failure"] = "CERTIFICATES"
                return
        result["certificates"] = "PASS"
        command = [str(OPENSSL), "cms", "-encrypt", "-binary", "-stream",
                   "-outform", "DER", "-aes-256-gcm", "-recip", str(cert)]
        code, cipher, error = capture(command, FIXED, 20)
        result["encrypt_exit"] = code if code is not None else "UNKNOWN"
        if code != 0 or error or cipher is None or not 64 < len(cipher) <= STREAM_LIMIT:
            result["encrypt"] = "FAIL"
            result["first_failure"] = "ENCRYPT"
            return
        result["cipher_bytes"] = len(cipher)
        digest = hashlib.sha256(cipher).hexdigest().upper()
        expected_length, expected_digest = len(cipher), digest
        result["cipher_sha256"] = digest
        result["encrypt"] = "PASS"

        cases["normal"] = run_decrypt("normal", cipher, cert, key,
                                       expected_length, expected_digest, True)
        if cases["normal"]["status"] != "PASS":
            result["first_failure"] = "NORMAL"
            return

        tampered = bytearray(cipher)
        tampered[-1] ^= 1
        try:
            cases["tamper"] = run_decrypt("tamper", tampered, cert, key,
                                           expected_length, expected_digest, False)
        finally:
            tampered[:] = b"\x00" * len(tampered)
        if cases["tamper"]["status"] != "PASS":
            result["first_failure"] = "TAMPER"
            return
        if cases["tamper"]["identity_match"]:
            cases["tamper"]["status"] = "FAIL"
            result["first_failure"] = "TAMPER_IDENTITY"
            return

        truncated = bytearray(cipher[:len(cipher) // 2])
        try:
            cases["truncate"] = run_decrypt("truncate", truncated, cert, key,
                                             expected_length, expected_digest, False)
        finally:
            truncated[:] = b"\x00" * len(truncated)
        if cases["truncate"]["status"] != "PASS":
            result["first_failure"] = "TRUNCATE"
            return
        if cases["truncate"]["identity_match"]:
            cases["truncate"]["status"] = "FAIL"
            result["first_failure"] = "TRUNCATE_IDENTITY"
            return

        cases["wrong_key"] = run_decrypt("wrong_key", cipher, cert, wrong_key,
                                          expected_length, expected_digest, False)
        if cases["wrong_key"]["status"] != "PASS":
            result["first_failure"] = "WRONG_KEY"
            return

        cases["over_limit"] = receipt_case(None, bytearray(FIXED), cipher,
                                             expected_length, expected_digest, False, False, True)
        if cases["over_limit"]["status"] != "PASS":
            result["first_failure"] = "OVER_LIMIT"
            return
        cases["interrupted"] = receipt_case(None, bytearray(FIXED), cipher,
                                              expected_length, expected_digest, False, False, True)
        if cases["interrupted"]["status"] != "PASS":
            result["first_failure"] = "INTERRUPTED"
    except (OSError, ValueError):
        if result["first_failure"] == "NONE":
            result["first_failure"] = "LOCAL_EXCEPTION"
    finally:
        if cipher is not None:
            cipher[:] = b"\x00" * len(cipher)
        if created:
            try:
                if (TEMP.parent == PARENT and PARENT.resolve(strict=True) == PARENT
                        and TEMP.is_dir() and not is_reparse(TEMP)
                        and os.path.normcase(os.path.abspath(TEMP)) == os.path.normcase(str(TEMP))):
                    shutil.rmtree(TEMP)
                    result["cleanup"] = "PASS" if not os.path.lexists(TEMP) else "FAIL"
                else:
                    result["cleanup"] = "UNRESOLVED"
            except OSError:
                result["cleanup"] = "UNRESOLVED"
        else:
            result["cleanup"] = "NOT_NEEDED"
        result["matrix"] = ("PASS" if result["first_failure"] == "NONE" and
                            result["cleanup"] == "PASS" and
                            all(c["status"] == "PASS" for c in cases.values()) else "FAIL")
        print(json.dumps(result, ensure_ascii=True, sort_keys=True))


if __name__ == "__main__":
    main()
