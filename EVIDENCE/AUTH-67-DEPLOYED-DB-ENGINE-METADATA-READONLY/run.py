"""AUTH-67: one bounded, read-only execution of the hash-locked AUTH-66 probe."""

import hashlib
import json
import subprocess
import threading
import time
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
PROBE = ROOT / "EVIDENCE/AUTH-66-DB-ENGINE-CONSISTENCY-PROBE-PREFLIGHT/probe.php"
PROBE_SHA256 = "5E0BCB9C4AE7EA2A90A23E12759BFE7804C090B5BA0E0B7E9B96D5844DA2DB9D"
KEY = Path(r"C:\Users\zcxve\.ssh\CodexKey.pem")
KNOWN_HOSTS = Path(r"C:\Users\zcxve\.ssh\known_hosts")
EXPECTED_FINGERPRINT = "c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29"
COUNT_KEYS = frozenset(("base_tables", "innodb", "non_innodb", "engine_null", "views"))
OUTPUT_LIMIT = 16 * 1024
REMOTE_COMMAND = "cd /opt/elitesync/services/backend-laravel && php -d display_errors=0 -d log_errors=0"
SSH_COMMAND = (
    "ssh", "-i", str(KEY), "-o", "BatchMode=yes", "-o", "IdentitiesOnly=yes",
    "-o", "StrictHostKeyChecking=yes", "-o", "ConnectTimeout=8", "-T",
    "root@101.133.161.203", REMOTE_COMMAND,
)
SAFE_ERRORS = frozenset(("UNSUPPORTED_DRIVER", "COUNT_LIMIT_EXCEEDED", "INVALID_METADATA",
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
    except UnicodeError:
        raise InvalidOutput("UTF8") from None
    except json.JSONDecodeError:
        raise InvalidOutput("JSON") from None
    if not isinstance(data, dict) or type(data.get("ok")) is not bool:
        raise InvalidOutput("SHAPE")
    if data["ok"] is False:
        if set(data) != {"ok", "error"} or type(data["error"]) is not str or data["error"] not in SAFE_ERRORS:
            raise InvalidOutput("ERROR_SHAPE")
        return {"status": "STOP", "first_failure": data["error"]}
    keys = {"ok", "probe_version", "family", "version", "target_fingerprint_sha256",
            "counts", "scope_completeness", "backup_consistency"}
    if set(data) != keys or data["probe_version"] != "AUTH66-1":
        raise InvalidOutput("SHAPE")
    if type(data["family"]) is not str or type(data["version"]) is not str or data["family"] != "MariaDB" or data["version"] != "10.11.14":
        raise InvalidOutput("VERSION_MISMATCH")
    fingerprint = data["target_fingerprint_sha256"]
    if type(fingerprint) is not str or len(fingerprint) != 64 or any(c not in "0123456789abcdef" for c in fingerprint):
        raise InvalidOutput("FINGERPRINT_SHAPE")
    if fingerprint != EXPECTED_FINGERPRINT:
        raise InvalidOutput("TARGET_MISMATCH")
    if data["scope_completeness"] != "UNKNOWN" or data["backup_consistency"] != "UNKNOWN":
        raise InvalidOutput("UNKNOWN_SHAPE")
    counts = data["counts"]
    if not isinstance(counts, dict) or set(counts) != COUNT_KEYS:
        raise InvalidOutput("COUNT_SHAPE")
    if any(type(v) is not int or not 0 <= v <= 10000 for v in counts.values()):
        raise InvalidOutput("COUNT_VALUE")
    if counts["base_tables"] != 43 or counts["views"] != 0:
        raise InvalidOutput("OBJECT_COUNT_MISMATCH")
    if counts["innodb"] + counts["non_innodb"] + counts["engine_null"] != counts["base_tables"]:
        raise InvalidOutput("ENGINE_COUNT_MISMATCH")
    return {"status": "PASS", "version_match": True, "fingerprint_match": True,
            "object_count_match": True, "counts": counts,
            "scope_completeness": "UNKNOWN", "backup_consistency": "UNKNOWN"}


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
        elif not KEY.is_file() or not KNOWN_HOSTS.is_file():
            result["first_failure"] = "SSH_FILE_MISSING"
        else:
            result = invoke_once(payload)
            result["ssh_attempts"] = 1
    except Exception:
        result["first_failure"] = "PRECHECK_ERROR"
    print(json.dumps(result, sort_keys=True, separators=(",", ":")))


if __name__ == "__main__":
    main()
