"""One bounded, local synthetic CMS capacity and failure-consumer drill."""

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

SIZE = 1_048_576
PLAIN_SHA256 = "631B84027D6B9E52B539C4E8373622D23032DFADC64D60AF87339C9037E4F769"
PARENT = Path(r"C:\Users\zcxve\AppData\Local\Temp")
TEMP = PARENT / "elitesync-auth71-bounded-cms-drill"
OPENSSL = Path(r"C:\Program Files\Git\usr\bin\openssl.exe")
CONFIG = Path(r"C:\Program Files\Git\usr\ssl\openssl.cnf")
STDOUT_LIMIT = SIZE + 65_536
STDERR_LIMIT = 16_384
CERT_LIMIT = 8192


def digest(data: bytes | bytearray) -> str:
    return hashlib.sha256(data).hexdigest().upper()


def clear(data: bytearray | None) -> bool:
    if data is None:
        return True
    data[:] = b"\0" * len(data)
    return not any(data)


def is_reparse(path: Path) -> bool:
    return bool(getattr(path.stat(follow_symlinks=False), "st_file_attributes", 0) & 0x400)


def safe_parent() -> bool:
    if os.path.lexists(TEMP) or TEMP.parent != PARENT:
        return False
    if os.path.normcase(os.path.abspath(TEMP)) != os.path.normcase(str(TEMP)):
        return False
    current = PARENT
    while True:
        if not current.is_dir() or is_reparse(current) or current.resolve(strict=True) != current:
            return False
        if current.parent == current:
            return True
        current = current.parent


def read_pipe(pipe, limit: int, slot: list) -> None:
    data = bytearray()
    overflow = False
    try:
        while True:
            part = pipe.read(65536)
            if not part:
                break
            if len(data) + len(part) > limit:
                overflow = True
                data.extend(part[:max(0, limit - len(data))])
            elif not overflow:
                data.extend(part)
    except OSError:
        overflow = True
    finally:
        pipe.close()
    slot.append((data, overflow))


def capture(command: list[str], source: bytearray | None, timeout: int,
            stdout_limit: int = STDOUT_LIMIT) -> tuple[int | None, bytearray | None, str | None]:
    process = subprocess.Popen(
        command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    slots: list[list] = [[], []]
    readers = [threading.Thread(target=read_pipe, args=(pipe, limit, slot))
               for pipe, limit, slot in zip(
                   (process.stdout, process.stderr), (stdout_limit, STDERR_LIMIT), slots)]
    for reader in readers:
        reader.start()
    write_failed = [False]
    timed_out = False
    def write_input() -> None:
        try:
            if source:
                for offset in range(0, len(source), 65536):
                    process.stdin.write(source[offset:offset + 65536])
        except OSError:
            write_failed[0] = True
        finally:
            process.stdin.close()

    writer = threading.Thread(target=write_input)
    writer.start()
    try:
        code = process.wait(timeout=timeout)
    except subprocess.TimeoutExpired:
        timed_out = True
        process.kill()
        code = process.wait()
    writer.join()
    for reader in readers:
        reader.join()
    if any(len(slot) != 1 for slot in slots):
        return code, None, "CAPTURE_EXCEPTION"
    (output, out_over), (error, err_over) = slots[0][0], slots[1][0]
    clear(error)
    if timed_out or write_failed[0] or out_over or err_over:
        clear(output)
        reason = "TIMEOUT" if timed_out else "CAPTURE_EXCEPTION" if write_failed[0] else "CAPTURE_LIMIT"
        return code, None, reason
    return code, output, None


def gate(label: str, actual_cipher: bytearray, expected_length: int, expected_digest: str,
         exit_code: int | None, isolated: bytearray | None, capture_error: str | None,
         should_release: bool) -> dict:
    calls = 0
    consumed = 0
    identity = len(actual_cipher) == expected_length and digest(actual_cipher) == expected_digest
    valid = (identity and capture_error is None and exit_code == 0 and
             isolated is not None and len(isolated) == SIZE and digest(isolated) == PLAIN_SHA256)
    # The sole consumer call site. It receives only the exact validated length.
    def consume_validated(value: bytearray) -> None:
        nonlocal calls, consumed
        calls += 1
        consumed += len(value)

    try:
        if valid:
            consume_validated(isolated)
    finally:
        cleared = clear(isolated)
    passed = (calls, consumed) == ((1, SIZE) if should_release else (0, 0))
    return {"case": label, "identity_match": identity, "exit_code": exit_code,
            "capture": capture_error or "COMPLETE", "captured_bytes": len(isolated) if isolated is not None else 0,
            "consumer_calls": calls, "consumer_bytes": consumed,
            "buffer_cleared": cleared, "status": "PASS" if passed and cleared else "FAIL"}


def decrypt_case(label: str, actual_cipher: bytearray, cert: Path, key: Path,
                 expected_length: int, expected_digest: str, should_release: bool) -> dict:
    code, output, error = capture(
        [str(OPENSSL), "cms", "-decrypt", "-binary", "-inform", "DER",
         "-recip", str(cert), "-inkey", str(key)], actual_cipher, 30)
    return gate(label, actual_cipher, expected_length, expected_digest,
                code, output, error, should_release)


def main() -> None:
    receipt = {"preflight": "NOT_CHECKED", "certificate": "NOT_CHECKED",
               "encrypt": "NOT_CHECKED", "cipher_bytes": "NOT_CHECKED",
               "cipher_sha256": "NOT_CHECKED", "cases": [],
               "first_failure": "NONE", "cleanup": "NOT_CHECKED", "matrix": "FAIL"}
    created = False
    plain = None
    cipher = None
    try:
        if not safe_parent() or not OPENSSL.is_file() or is_reparse(OPENSSL) or not CONFIG.is_file() or is_reparse(CONFIG):
            receipt["first_failure"] = "PREFLIGHT"
            return
        plain = bytearray(i % 251 for i in range(SIZE))
        if len(plain) != SIZE or digest(plain) != PLAIN_SHA256:
            receipt["first_failure"] = "FIXED_INPUT"
            return
        receipt["preflight"] = "PASS"
        TEMP.mkdir()
        created = True
        cert, key = TEMP / "synthetic.cert.pem", TEMP / "synthetic.key.pem"
        wrong_cert, wrong_key = TEMP / "wrong.cert.pem", TEMP / "wrong.key.pem"
        for label, out_cert, out_key in (("primary", cert, key), ("wrong", wrong_cert, wrong_key)):
            code, output, error = capture(
                [str(OPENSSL), "req", "-config", str(CONFIG), "-x509", "-newkey",
                 "rsa:2048", "-nodes", "-keyout", str(out_key), "-out", str(out_cert),
                 "-days", "1", "-subj", f"/CN=AUTH71-{label}-SYNTHETIC"], None, 35, STDERR_LIMIT)
            clear(output)
            if code != 0 or error or not out_cert.is_file() or not out_key.is_file() or out_cert.stat().st_size > CERT_LIMIT:
                receipt["first_failure"] = "CERTIFICATE_" + label.upper()
                return
        receipt["certificate"] = "PASS"
        code, cipher, error = capture(
            [str(OPENSSL), "cms", "-encrypt", "-binary", "-aes-256-gcm",
             "-outform", "DER", "-recip", str(cert)], plain, 30)
        if code != 0 or error or cipher is None or not SIZE < len(cipher) <= STDOUT_LIMIT:
            receipt["first_failure"] = "ENCRYPT"
            return
        receipt["encrypt"] = "PASS"
        receipt["cipher_bytes"] = len(cipher)
        receipt["cipher_sha256"] = digest(cipher)
        expected_length, expected_digest = len(cipher), digest(cipher)
        cases = receipt["cases"]

        def append_case(case: dict) -> bool:
            cases.append(case)
            if case["status"] != "PASS":
                receipt["first_failure"] = case["case"].upper()
                return False
            return True

        if not append_case(decrypt_case("normal", cipher, cert, key, expected_length, expected_digest, True)):
            return
        tampered = bytearray(cipher)
        tampered[-1] ^= 1
        try:
            if not append_case(decrypt_case("tamper", tampered, cert, key, expected_length, expected_digest, False)):
                return
        finally:
            clear(tampered)
        truncated = bytearray(cipher[:-1])
        try:
            if not append_case(decrypt_case("truncate", truncated, cert, key, expected_length, expected_digest, False)):
                return
        finally:
            clear(truncated)
        if not append_case(decrypt_case("wrong_key", cipher, wrong_cert, wrong_key, expected_length, expected_digest, False)):
            return
        # Controlled capture failures enter the same consumer gate with staged bytes.
        for label, reason in (("over_limit_simulated", "CAPTURE_LIMIT"),
                              ("interrupted_simulated", "TIMEOUT")):
            staged = bytearray(plain)
            if not append_case(gate(label, cipher, expected_length, expected_digest,
                                    None, staged, reason, False)):
                return
    except (OSError, ValueError, subprocess.SubprocessError):
        if receipt["first_failure"] == "NONE":
            receipt["first_failure"] = "LOCAL_EXCEPTION"
    finally:
        clear(plain)
        clear(cipher)
        if created:
            try:
                if (TEMP.parent == PARENT and PARENT.resolve(strict=True) == PARENT and
                        TEMP.is_dir() and not is_reparse(TEMP) and
                        os.path.normcase(os.path.abspath(TEMP)) == os.path.normcase(str(TEMP))):
                    shutil.rmtree(TEMP)
                    receipt["cleanup"] = "PASS" if not os.path.lexists(TEMP) else "FAIL"
                else:
                    receipt["cleanup"] = "UNRESOLVED"
            except OSError:
                receipt["cleanup"] = "UNRESOLVED"
        else:
            receipt["cleanup"] = "NOT_NEEDED"
        receipt["matrix"] = ("PASS" if receipt["first_failure"] == "NONE" and
                             receipt["cleanup"] == "PASS" and len(receipt["cases"]) == 6 and
                             all(case["status"] == "PASS" for case in receipt["cases"]) else "FAIL")
        print(json.dumps(receipt, ensure_ascii=True, sort_keys=True))


if __name__ == "__main__":
    main()
