"""One bounded SSH cipher-list observation. Raw output stays in process memory."""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
import threading
from pathlib import Path

sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
PARSER_PATH = HERE.parent / "AUTH-55-OPENSSL-BRACED-ALIAS-PARSER-REPAIR" / "parser.py"
FIELD_LIMIT = 65_536
STREAM_LIMIT = FIELD_LIMIT + 4_096
TAG = "AUTH56_FRAME_20260925"
REMOTE = (
    "command -v openssl >/dev/null 2>&1; p=$?; "
    "printf 'AUTH56_FRAME_20260925:P:%s\\n' \"$p\"; "
    "l=$(openssl list -cipher-algorithms 2>&1); le=$?; "
    "printf 'AUTH56_FRAME_20260925:L:%s\\n%s\\nAUTH56_FRAME_20260925:LE:%s\\n' "
    "\"${#l}\" \"$l\" \"$le\""
)
SSH = [
    "ssh", "-i", r"C:\Users\zcxve\.ssh\CodexKey.pem",
    "-o", "BatchMode=yes", "-o", "IdentitiesOnly=yes",
    "-o", "StrictHostKeyChecking=yes", "-o", "ConnectTimeout=8",
    "root@101.133.161.203", REMOTE,
]


def parser_module():
    spec = importlib.util.spec_from_file_location("auth55_parser_for_auth56", PARSER_PATH)
    if spec is None or spec.loader is None:
        raise ValueError("parser unavailable")
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def read_bounded(pipe, result):
    chunks = []
    size = 0
    overflow = False
    try:
        while True:
            part = pipe.read(4096)
            if not part:
                break
            size += len(part)
            if size <= STREAM_LIMIT:
                chunks.append(part)
            else:
                overflow = True
    except OSError:
        overflow = True
    finally:
        pipe.close()
    result.append((b"".join(chunks), overflow))


def capture_once():
    process = subprocess.Popen(SSH, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    outputs = [[], []]
    threads = [threading.Thread(target=read_bounded, args=(pipe, slot))
               for pipe, slot in zip((process.stdout, process.stderr), outputs)]
    for thread in threads:
        thread.start()
    try:
        code = process.wait(timeout=45)
    except subprocess.TimeoutExpired:
        process.kill()
        process.wait()
        code = None
    for thread in threads:
        thread.join()
    if len(outputs[0]) != 1 or len(outputs[1]) != 1:
        return code, None, "CAPTURE_FAILURE"
    (stdout, out_over), (_, err_over) = outputs[0][0], outputs[1][0]
    if out_over or err_over:
        return code, None, "CAPTURE_LIMIT"
    try:
        return code, stdout.decode("ascii"), None
    except UnicodeDecodeError:
        return code, None, "NON_ASCII"


def decode_frames(raw):
    """Require declared field length, all markers and an exact capture end."""
    if not isinstance(raw, str) or len(raw) > STREAM_LIMIT:
        raise ValueError("frame size")
    pos = 0

    def number(name):
        nonlocal pos
        marker = TAG + ":" + name + ":"
        if not raw.startswith(marker, pos):
            raise ValueError("frame marker")
        end = raw.find("\n", pos)
        if end < 0:
            raise ValueError("frame line")
        value = raw[pos + len(marker):end]
        pos = end + 1
        if not value.isascii() or not value.isdecimal() or len(value) > 8:
            raise ValueError("frame number")
        return int(value)

    presence = number("P")
    length = number("L")
    if length > FIELD_LIMIT or pos + length >= len(raw):
        raise ValueError("field length")
    listing = raw[pos:pos + length]
    pos += length
    if raw[pos:pos + 1] != "\n":
        raise ValueError("field terminator")
    pos += 1
    list_exit = number("LE")
    if pos != len(raw) or presence > 255 or list_exit > 255:
        raise ValueError("frame tail")
    return presence, listing, list_exit


def first_bad_category(module, listing):
    for raw_line in listing.split("\n"):
        line = raw_line.strip()
        if not line or module._SECTION_LINE.fullmatch(line):
            continue
        if module._algorithm_names(line) is None:
            if line.startswith("{"):
                return "BRACED", len(line)
            if "=>" in line:
                return "ALIAS", len(line)
            if "@" in line:
                return "PROVIDER", len(line)
            return "OTHER", len(line)
    return "NONE", 0


def classify(raw):
    presence, listing, list_exit = decode_frames(raw)
    result = {
        "openssl_resolution": "PASS" if presence == 0 else "FAIL",
        "openssl_resolution_exit": presence,
        "cipher_list": "NOT_CHECKED" if presence != 0 else "PASS" if list_exit == 0 else "FAIL",
        "cipher_list_exit": list_exit,
        "captured_chars": len(listing),
        "aes_256_gcm_listing": "UNKNOWN",
        "first_failure_stage": "NONE" if presence == 0 and list_exit == 0 else
                               "OPENSSL_RESOLUTION" if presence != 0 else "CIPHER_LIST_EXIT",
        "first_bad_line_category": "NONE",
        "first_bad_line_length": 0,
    }
    if presence != 0 or list_exit != 0:
        return result
    module = parser_module()
    result["aes_256_gcm_listing"] = module.parse_aes_256_gcm_listing(list_exit, listing).value
    if result["aes_256_gcm_listing"] == "UNKNOWN":
        result["first_failure_stage"] = "CIPHER_LIST_FORMAT"
        category, length = first_bad_category(module, listing)
        result["first_bad_line_category"] = category
        result["first_bad_line_length"] = length
    return result


def main():
    receipt = {
        "ssh_budget": "1/1", "ssh": "FAIL", "ssh_exit": "UNKNOWN",
        "openssl_resolution": "NOT_CHECKED", "openssl_resolution_exit": "UNKNOWN",
        "cipher_list": "NOT_CHECKED", "cipher_list_exit": "UNKNOWN",
        "captured_chars": "UNKNOWN", "aes_256_gcm_listing": "UNKNOWN",
        "first_failure_stage": "SSH", "first_bad_line_category": "NONE",
        "first_bad_line_length": 0,
    }
    try:
        code, raw, capture_error = capture_once()
        receipt["ssh_exit"] = code if code is not None else "UNKNOWN"
        if code == 0 and capture_error is None:
            receipt["ssh"] = "PASS"
            receipt.update(classify(raw))
        elif capture_error:
            receipt["first_failure_stage"] = capture_error
    except OSError:
        receipt["first_failure_stage"] = "SSH_LAUNCH"
    except (ValueError, ImportError):
        receipt["first_failure_stage"] = "FRAME_OR_PARSE"
    print(json.dumps(receipt, ensure_ascii=True, sort_keys=True))


if __name__ == "__main__":
    main()
