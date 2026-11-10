"""Pure parser for synthetic known_hosts bytes for one fixed, port-unknown host.

No file, process, environment, or network access belongs in this module.
"""

import base64
import binascii
import hashlib
import hmac
import re


TARGET = "101.133.161.203"
MAX_BYTES = 65536
MAX_LINES = 256
MAX_LINE_BYTES = 2048
MAX_BLOB_BYTES = 1024
ALGORITHMS = frozenset({"ssh-ed25519", "ecdsa-sha2-nistp256", "ssh-rsa"})
PLAIN_HOST = re.compile(r"[A-Za-z0-9._-]+\Z", re.ASCII)


class _Reject(ValueError):
    def __init__(self, category):
        self.category = category


def _result(status, reason, algorithm="UNKNOWN", fingerprint=None, match_kind="UNKNOWN"):
    return {
        "status": status,
        "reason": reason,
        "algorithm": algorithm,
        "fingerprint_candidate": fingerprint,
        "match_kind": match_kind,
        "trust": "LOCAL_RECORD_CANDIDATE_ONLY",
        "port": "UNKNOWN",
    }


def _base64_canonical(token, max_bytes):
    try:
        raw = base64.b64decode(token, validate=True)
        if base64.b64encode(raw).decode("ascii") != token or len(raw) > max_bytes:
            raise _Reject("FORMAT_INVALID")
        return raw
    except (ValueError, binascii.Error):
        raise _Reject("FORMAT_INVALID") from None


def _ssh_string(blob, offset):
    if offset + 4 > len(blob):
        raise _Reject("KEY_FORMAT_INVALID")
    length = int.from_bytes(blob[offset : offset + 4], "big")
    offset += 4
    if length > len(blob) - offset:
        raise _Reject("KEY_FORMAT_INVALID")
    return blob[offset : offset + length], offset + length


def _validate_key_blob(algorithm, blob):
    encoded_type, offset = _ssh_string(blob, 0)
    if encoded_type != algorithm.encode("ascii"):
        raise _Reject("KEY_FORMAT_INVALID")
    if algorithm == "ssh-ed25519":
        public, offset = _ssh_string(blob, offset)
        if len(public) != 32:
            raise _Reject("KEY_FORMAT_INVALID")
    elif algorithm == "ecdsa-sha2-nistp256":
        curve, offset = _ssh_string(blob, offset)
        point, offset = _ssh_string(blob, offset)
        if curve != b"nistp256" or len(point) != 65 or point[:1] != b"\x04":
            raise _Reject("KEY_FORMAT_INVALID")
    elif algorithm == "ssh-rsa":
        exponent, offset = _ssh_string(blob, offset)
        modulus, offset = _ssh_string(blob, offset)
        if not exponent or not modulus or exponent[0] & 0x80 or modulus[0] & 0x80:
            raise _Reject("KEY_FORMAT_INVALID")
    if offset != len(blob):
        raise _Reject("KEY_FORMAT_INVALID")


def _host_match(field):
    if field.startswith("|1|"):
        parts = field.split("|")
        if len(parts) != 4 or parts[:2] != ["", "1"]:
            raise _Reject("HOST_FORMAT_INVALID")
        salt = _base64_canonical(parts[2], 32)
        digest = _base64_canonical(parts[3], 32)
        if len(salt) != 20 or len(digest) != 20:
            raise _Reject("HOST_FORMAT_INVALID")
        candidate = hmac.new(salt, TARGET.encode("ascii"), hashlib.sha1).digest()
        return hmac.compare_digest(candidate, digest), "HASHED"
    if field.startswith("|"):
        raise _Reject("HOST_FORMAT_INVALID")
    hosts = field.split(",")
    if any(not host or not PLAIN_HOST.fullmatch(host) for host in hosts):
        raise _Reject("PORT_OR_PATTERN_UNSUPPORTED")
    if hosts.count(TARGET) > 1:
        raise _Reject("AMBIGUOUS_TARGET")
    return TARGET in hosts, "PLAIN"


def extract_known_host_candidate(data):
    """Return fixed categories and one SHA-256 key-blob fingerprint candidate."""

    try:
        if type(data) is not bytes:
            raise _Reject("INVALID_INPUT")
        if len(data) > MAX_BYTES:
            raise _Reject("INPUT_LIMIT")
        if b"\x00" in data or b"\r" in data:
            raise _Reject("FORMAT_INVALID")
        lines = data.split(b"\n")
        line_count = len(lines) - (1 if data.endswith(b"\n") else 0)
        if line_count > MAX_LINES:
            raise _Reject("INPUT_LIMIT")
        matched = None
        for raw in lines:
            if len(raw) > MAX_LINE_BYTES:
                raise _Reject("INPUT_LIMIT")
            if not raw or raw.startswith(b"#"):
                continue
            try:
                line = raw.decode("ascii", errors="strict")
            except UnicodeError:
                raise _Reject("FORMAT_INVALID") from None
            if line[:1].isspace() or line[-1:].isspace():
                raise _Reject("FORMAT_INVALID")
            if line.startswith("@"):
                raise _Reject("MARKER_UNSUPPORTED")
            fields = re.split(r"[ \t]+", line)
            if len(fields) != 3:
                raise _Reject("FORMAT_INVALID")
            host_field, algorithm, key_token = fields
            applies, match_kind = _host_match(host_field)
            if algorithm not in ALGORITHMS:
                raise _Reject("ALGORITHM_UNSUPPORTED")
            blob = _base64_canonical(key_token, MAX_BLOB_BYTES)
            _validate_key_blob(algorithm, blob)
            if not applies:
                continue
            if matched is not None:
                raise _Reject("AMBIGUOUS_TARGET")
            fingerprint = base64.b64encode(hashlib.sha256(blob).digest()).decode("ascii").rstrip("=")
            matched = (algorithm, "SHA256:" + fingerprint, match_kind)
        if matched is None:
            return _result("NO_MATCH", "TARGET_NOT_FOUND")
        return _result("FINGERPRINT_CANDIDATE", "NONE", *matched)
    except _Reject as error:
        return _result("REJECTED", error.category)
