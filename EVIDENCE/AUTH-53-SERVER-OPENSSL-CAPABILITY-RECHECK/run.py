"""One bounded, read-only SSH observation for AUTH-53. No raw output is persisted."""

from __future__ import annotations

import importlib.util
import json
import subprocess
import sys
import threading
from pathlib import Path

sys.dont_write_bytecode = True

HERE = Path(__file__).resolve().parent
PARSER_PATH = HERE.parent / "AUTH-52-OPENSSL-CAPABILITY-PARSER-PREFLIGHT" / "parser.py"
FIELD_LIMIT = 65_536
STREAM_LIMIT = 4 * FIELD_LIMIT + 4_096
TAG = "AUTH53_FRAME_20260925"
REMOTE = (
    "command -v openssl >/dev/null 2>&1; p=$?; "
    "printf 'AUTH53_FRAME_20260925:P:%s\\n' \"$p\"; "
    "v=$(openssl version 2>&1); ve=$?; "
    "printf 'AUTH53_FRAME_20260925:V:%s\\n%s\\nAUTH53_FRAME_20260925:VE:%s\\n' \"${#v}\" \"$v\" \"$ve\"; "
    "openssl cms -help >/dev/null 2>&1; ce=$?; "
    "printf 'AUTH53_FRAME_20260925:C:%s\\n' \"$ce\"; "
    "l=$(openssl list -cipher-algorithms 2>&1); le=$?; "
    "printf 'AUTH53_FRAME_20260925:L:%s\\n%s\\nAUTH53_FRAME_20260925:LE:%s\\n' \"${#l}\" \"$l\" \"$le\""
)
SSH = [
    "ssh", "-i", r"C:\Users\zcxve\.ssh\CodexKey.pem",
    "-o", "BatchMode=yes", "-o", "IdentitiesOnly=yes",
    "-o", "StrictHostKeyChecking=yes", "-o", "ConnectTimeout=8",
    "root@101.133.161.203", REMOTE,
]


def parser_module():
    spec = importlib.util.spec_from_file_location("auth52_parser", PARSER_PATH)
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
        return code, None, "CAPTURE_FORMAT"


def decode_frames(raw):
    """Require all markers, declared lengths, and an exact end of capture."""
    if not isinstance(raw, str) or len(raw) > STREAM_LIMIT:
        raise ValueError("frame size")
    pos = 0

    def line(prefix):
        nonlocal pos
        marker = TAG + ":" + prefix + ":"
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

    def field(name):
        nonlocal pos
        length = line(name)
        if length > FIELD_LIMIT or pos + length >= len(raw):
            raise ValueError("field limit")
        value = raw[pos:pos + length]
        pos += length
        if raw[pos:pos + 1] != "\n":
            raise ValueError("field terminator")
        pos += 1
        return value

    presence = line("P")
    version = field("V")
    version_exit = line("VE")
    cms_exit = line("C")
    listing = field("L")
    list_exit = line("LE")
    if pos != len(raw) or any(code > 255 for code in (presence, version_exit, cms_exit, list_exit)):
        raise ValueError("frame tail")
    return presence, version, version_exit, cms_exit, listing, list_exit


def classify(raw):
    presence, version, ve, ce, listing, le = decode_frames(raw)
    parser = parser_module()
    token = parser.parse_openssl_version(ve, version) if presence == 0 else "UNKNOWN"
    listed = parser.parse_aes_256_gcm_listing(le, listing).value
    first = "NONE"
    if presence != 0:
        first = "OPENSSL_RESOLUTION"
    elif ve != 0 or token == "UNKNOWN":
        first = "VERSION"
    elif ce != 0:
        first = "CMS_HELP"
    elif le != 0 or listed == "UNKNOWN":
        first = "CIPHER_LIST"
    if first in ("OPENSSL_RESOLUTION", "VERSION", "CMS_HELP"):
        listed = "UNKNOWN"
    return {
        "openssl_resolution": "PASS" if presence == 0 else "FAIL",
        "openssl_resolution_exit": presence,
        "version": token,
        "version_exit": ve,
        "cms_help": "PASS" if ce == 0 else "FAIL",
        "cms_help_exit": ce,
        "aes_256_gcm_listing": listed,
        "cipher_list_exit": le,
        "first_failure_stage": first,
    }


def main():
    receipt = {
        "ssh_budget": "1/1", "ssh": "FAIL", "ssh_exit": "UNKNOWN",
        "openssl_resolution": "NOT_CHECKED", "openssl_resolution_exit": "UNKNOWN",
        "version": "UNKNOWN", "version_exit": "UNKNOWN",
        "cms_help": "NOT_CHECKED", "cms_help_exit": "UNKNOWN",
        "aes_256_gcm_listing": "UNKNOWN", "cipher_list_exit": "UNKNOWN",
        "first_failure_stage": "SSH",
    }
    try:
        code, raw, capture_error = capture_once()
        receipt["ssh_exit"] = code if code is not None else "UNKNOWN"
        if code == 0 and capture_error is None:
            receipt["ssh"] = "PASS"
            receipt.update(classify(raw))
        elif capture_error:
            receipt["first_failure_stage"] = capture_error
        elif code == 0:
            receipt["first_failure_stage"] = "FRAME"
    except (OSError, ValueError, ImportError):
        receipt["first_failure_stage"] = "LAUNCH_OR_PARSE"
    print(json.dumps(receipt, ensure_ascii=True, sort_keys=True))


if __name__ == "__main__":
    main()
