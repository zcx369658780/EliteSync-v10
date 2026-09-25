"""AUTH-65: one bounded SSH invocation of the hash-locked AUTH-64 probe."""

import hashlib
import json
import subprocess
import threading
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROBE = ROOT / "EVIDENCE/AUTH-64-DB-OBJECT-INVENTORY-PROBE-PREFLIGHT/probe.php"
PROBE_SHA256 = "ED8CB1CC5B3D3C4795595BE3F7E4B3B93589DBE7AAB4D66CDAB1323BB674FD4F"
EXPECTED_FINGERPRINT = "c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29"
COUNT_KEYS = frozenset(("base_tables", "views", "columns", "indexes", "primary_constraints",
                        "unique_constraints", "foreign_constraints", "check_constraints",
                        "triggers", "routines", "events"))
OUTPUT_LIMIT = 16 * 1024
REMOTE_COMMAND = "cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0"
SSH_COMMAND = (
    "ssh", "-i", r"C:\Users\zcxve\.ssh\CodexKey.pem", "-o", "BatchMode=yes",
    "-o", "IdentitiesOnly=yes", "-o", "StrictHostKeyChecking=yes",
    "-o", "ConnectTimeout=8", "-T", "root@101.133.161.203", REMOTE_COMMAND,
)
SAFE_ERRORS = frozenset(("UNSUPPORTED_DRIVER", "OBJECT_LIMIT_EXCEEDED", "INVALID_METADATA",
                         "QUERY_OR_ADAPTER_ERROR", "PROBE_ERROR"))


class InvalidOutput(Exception):
    pass


def _pairs(pairs):
    value = {}
    for key, item in pairs:
        if key in value:
            raise InvalidOutput("DUPLICATE_KEY")
        value[key] = item
    return value


def parse_output(raw):
    if len(raw) > OUTPUT_LIMIT:
        raise InvalidOutput("OUTPUT_LIMIT")
    try:
        line = raw.decode("utf-8", "strict")
        if not line.endswith("\n") or line.count("\n") != 1 or "\r" in line:
            raise InvalidOutput("LINE_SHAPE")
        data = json.loads(line[:-1], object_pairs_hook=_pairs)
    except UnicodeError as exc:
        raise InvalidOutput("UTF8") from None
    except json.JSONDecodeError as exc:
        raise InvalidOutput("JSON") from None
    if not isinstance(data, dict) or type(data.get("ok")) is not bool:
        raise InvalidOutput("SHAPE")
    if data["ok"] is False:
        if set(data) != {"ok", "error"} or type(data["error"]) is not str or data["error"] not in SAFE_ERRORS:
            raise InvalidOutput("ERROR_SHAPE")
        return {"status": "PROBE_ERROR", "error": data["error"]}
    keys = {"ok", "probe_version", "family", "version", "target_fingerprint_sha256",
            "counts", "completeness", "completeness_reason"}
    if set(data) != keys or data["probe_version"] != "AUTH64-1":
        raise InvalidOutput("SHAPE")
    if data["family"] != "MariaDB" or data["version"] != "10.11.14":
        raise InvalidOutput("VERSION_MISMATCH")
    fingerprint = data["target_fingerprint_sha256"]
    if not isinstance(fingerprint, str) or len(fingerprint) != 64 or any(c not in "0123456789abcdef" for c in fingerprint):
        raise InvalidOutput("FINGERPRINT_SHAPE")
    if fingerprint != EXPECTED_FINGERPRINT:
        raise InvalidOutput("TARGET_MISMATCH")
    if data["completeness"] != "UNKNOWN" or data["completeness_reason"] != "PRIVILEGE_VISIBILITY_UNVERIFIED":
        raise InvalidOutput("COMPLETENESS_SHAPE")
    counts = data["counts"]
    if not isinstance(counts, dict) or set(counts) != COUNT_KEYS:
        raise InvalidOutput("COUNT_SHAPE")
    if any(type(v) is not int or not 0 <= v <= 10000 for v in counts.values()):
        raise InvalidOutput("COUNT_VALUE")
    if counts["base_tables"] + counts["views"] != 43:
        raise InvalidOutput("RELATION_COUNT_MISMATCH")
    return {"status": "PASS", "family": "MariaDB", "version": "10.11.14",
            "fingerprint_match": True, "counts": counts, "completeness": "UNKNOWN"}


def _read_capped(pipe, state, key):
    try:
        while True:
            chunk = pipe.read(4096)
            if not chunk:
                break
            remaining = OUTPUT_LIMIT + 1 - len(state[key])
            state[key].extend(chunk[:remaining])
            if len(state[key]) > OUTPUT_LIMIT:
                state["overflow"] = True
                break
    except Exception:
        state["io_error"] = True


def _write_probe(pipe, payload, state):
    try:
        pipe.write(payload)
        pipe.flush()
    except Exception:
        state["io_error"] = True
    finally:
        try:
            pipe.close()
        except Exception:
            pass


def invoke_once(payload):
    state = {"stdout": bytearray(), "stderr": bytearray(), "overflow": False, "io_error": False}
    proc = None
    try:
        proc = subprocess.Popen(SSH_COMMAND, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, shell=False)
        threads = [threading.Thread(target=_read_capped, args=(proc.stdout, state, "stdout"), daemon=True),
                   threading.Thread(target=_read_capped, args=(proc.stderr, state, "stderr"), daemon=True),
                   threading.Thread(target=_write_probe, args=(proc.stdin, payload, state), daemon=True)]
        for thread in threads:
            thread.start()
        deadline = time.monotonic() + 35
        while proc.poll() is None:
            if state["overflow"] or state["io_error"]:
                proc.kill()
                proc.wait()
                return {"status": "STOP", "first_failure": "STREAM_LIMIT_OR_IO"}
            if time.monotonic() >= deadline:
                proc.kill()
                proc.wait()
                return {"status": "STOP", "first_failure": "TIMEOUT"}
            time.sleep(0.02)
        for thread in threads:
            thread.join(timeout=1)
        if any(thread.is_alive() for thread in threads) or state["io_error"]:
            return {"status": "STOP", "first_failure": "STREAM_IO"}
        if state["overflow"]:
            return {"status": "STOP", "first_failure": "STREAM_LIMIT"}
        if proc.returncode != 0:
            return {"status": "STOP", "first_failure": "SSH_NONZERO", "ssh_exit_code": proc.returncode}
        if state["stderr"]:
            return {"status": "STOP", "first_failure": "UNEXPECTED_STDERR"}
        try:
            return parse_output(bytes(state["stdout"]))
        except InvalidOutput as exc:
            return {"status": "STOP", "first_failure": exc.args[0]}
    except Exception:
        if proc is not None and proc.poll() is None:
            proc.kill()
            proc.wait()
        return {"status": "STOP", "first_failure": "SSH_LAUNCH_OR_IO"}


def main():
    result = {"status": "STOP", "first_failure": "PRECHECK", "ssh_attempts": 0}
    try:
        payload = PROBE.read_bytes()
        if hashlib.sha256(payload).hexdigest().upper() != PROBE_SHA256:
            result["first_failure"] = "PROBE_HASH_MISMATCH"
        elif not Path(r"C:\Users\zcxve\.ssh\CodexKey.pem").is_file() or not Path(r"C:\Users\zcxve\.ssh\known_hosts").is_file():
            result["first_failure"] = "SSH_FILE_MISSING"
        else:
            result = invoke_once(payload)
            result["ssh_attempts"] = 1
    except Exception:
        result["first_failure"] = "PRECHECK_ERROR"
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    main()
