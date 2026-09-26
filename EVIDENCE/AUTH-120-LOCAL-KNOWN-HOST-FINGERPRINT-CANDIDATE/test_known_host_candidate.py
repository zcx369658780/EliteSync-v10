"""Only synthetic known_hosts bytes; no file, process, or network operations."""

import base64
import hashlib
import hmac

from known_host_candidate import TARGET, extract_known_host_candidate


SECRET = b"SYNTHETIC_SECRET_OTHER_HOST"


def ssh_string(value):
    return len(value).to_bytes(4, "big") + value


KEY = ssh_string(b"ssh-ed25519") + ssh_string(bytes(range(32)))
KEY64 = base64.b64encode(KEY)
EXPECTED = "SHA256:" + base64.b64encode(hashlib.sha256(KEY).digest()).decode().rstrip("=")
PLAIN = TARGET.encode() + b" ssh-ed25519 " + KEY64 + b"\n"
SALT = bytes(range(20))
HASH = hmac.new(SALT, TARGET.encode(), hashlib.sha1).digest()
HASHED = b"|1|" + base64.b64encode(SALT) + b"|" + base64.b64encode(HASH) + b" ssh-ed25519 " + KEY64 + b"\n"


checks = 0


def check(data, status, reason, kind="UNKNOWN", algorithm="ssh-ed25519", fingerprint=EXPECTED):
    global checks
    got = extract_known_host_candidate(data)
    assert got["status"] == status, got
    assert got["reason"] == reason, got
    assert got["match_kind"] == kind, got
    assert got["port"] == "UNKNOWN"
    assert got["trust"] == "LOCAL_RECORD_CANDIDATE_ONLY"
    assert SECRET.decode() not in repr(got)
    if status == "FINGERPRINT_CANDIDATE":
        assert got["algorithm"] == algorithm
        assert got["fingerprint_candidate"] == fingerprint
    else:
        assert got["algorithm"] == "UNKNOWN"
        assert got["fingerprint_candidate"] is None
    checks += 1


check(PLAIN, "FINGERPRINT_CANDIDATE", "NONE", "PLAIN")
check(HASHED, "FINGERPRINT_CANDIDATE", "NONE", "HASHED")
check(b"other.example ssh-ed25519 " + KEY64 + b"\n" + PLAIN, "FINGERPRINT_CANDIDATE", "NONE", "PLAIN")
check(b"other.example," + TARGET.encode() + b" ssh-ed25519 " + KEY64 + b"\n", "FINGERPRINT_CANDIDATE", "NONE", "PLAIN")
check(b"# synthetic comment\n\n" + PLAIN, "FINGERPRINT_CANDIDATE", "NONE", "PLAIN")
check(b"other.example ssh-ed25519 " + KEY64 + b"\n", "NO_MATCH", "TARGET_NOT_FOUND")
check(b"other.example ssh-ed25519 invalid*\n", "REJECTED", "FORMAT_INVALID")
check(b"", "NO_MATCH", "TARGET_NOT_FOUND")
check(PLAIN + PLAIN, "REJECTED", "AMBIGUOUS_TARGET")
check(PLAIN + HASHED, "REJECTED", "AMBIGUOUS_TARGET")
check(TARGET.encode() + b"," + TARGET.encode() + b" ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "AMBIGUOUS_TARGET")
check(b"[" + TARGET.encode() + b"]:22 ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "PORT_OR_PATTERN_UNSUPPORTED")
check(b"[" + TARGET.encode() + b"]:2222 ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "PORT_OR_PATTERN_UNSUPPORTED")
check(b"*.example ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "PORT_OR_PATTERN_UNSUPPORTED")
check(b"!" + TARGET.encode() + b" ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "PORT_OR_PATTERN_UNSUPPORTED")
check(b"@cert-authority " + PLAIN, "REJECTED", "MARKER_UNSUPPORTED")
check(b"@unknown " + PLAIN, "REJECTED", "MARKER_UNSUPPORTED")
check(TARGET.encode() + b" unknown-key " + KEY64 + b"\n", "REJECTED", "ALGORITHM_UNSUPPORTED")
check(TARGET.encode() + b" ssh-rsa " + KEY64 + b"\n", "REJECTED", "KEY_FORMAT_INVALID")
check(TARGET.encode() + b" ssh-ed25519 invalid*\n", "REJECTED", "FORMAT_INVALID")
check(TARGET.encode() + b" ssh-ed25519 " + KEY64[:-2] + b"\n", "REJECTED", "FORMAT_INVALID")
check(TARGET.encode() + b" ssh-ed25519 " + base64.b64encode(KEY + b"x") + b"\n", "REJECTED", "KEY_FORMAT_INVALID")
check(TARGET.encode() + b" ssh-ed25519 " + base64.b64encode(ssh_string(b"ssh-ed25519") + ssh_string(b"x")) + b"\n", "REJECTED", "KEY_FORMAT_INVALID")
check(TARGET.encode() + b" ssh-ed25519\n", "REJECTED", "FORMAT_INVALID")
check(b" " + PLAIN, "REJECTED", "FORMAT_INVALID")
check(PLAIN.replace(b"\n", b"\r\n"), "REJECTED", "FORMAT_INVALID")
check(PLAIN + SECRET + b"\n", "REJECTED", "FORMAT_INVALID")
check(b"x" * 65537, "REJECTED", "INPUT_LIMIT")
check(b"x" * 2049 + b"\n", "REJECTED", "INPUT_LIMIT")
check(b"\n" * 257, "REJECTED", "INPUT_LIMIT")
check((b"#x\n" * 256) + b"#x", "REJECTED", "INPUT_LIMIT")
check(None, "REJECTED", "INVALID_INPUT")
check(HASHED.replace(base64.b64encode(HASH), base64.b64encode(bytes(20))), "NO_MATCH", "TARGET_NOT_FOUND")
check(b"|2|" + base64.b64encode(SALT) + b"|" + base64.b64encode(HASH) + b" ssh-ed25519 " + KEY64 + b"\n", "REJECTED", "HOST_FORMAT_INVALID")
ecdsa = ssh_string(b"ecdsa-sha2-nistp256") + ssh_string(b"nistp256") + ssh_string(b"\x04" + bytes(range(64)))
ecdsa_fp = "SHA256:" + base64.b64encode(hashlib.sha256(ecdsa).digest()).decode().rstrip("=")
check(TARGET.encode() + b" ecdsa-sha2-nistp256 " + base64.b64encode(ecdsa) + b"\n", "FINGERPRINT_CANDIDATE", "NONE", "PLAIN", "ecdsa-sha2-nistp256", ecdsa_fp)
rsa = ssh_string(b"ssh-rsa") + ssh_string(b"\x01\x00\x01") + ssh_string(b"\x01" * 32)
rsa_fp = "SHA256:" + base64.b64encode(hashlib.sha256(rsa).digest()).decode().rstrip("=")
check(TARGET.encode() + b" ssh-rsa " + base64.b64encode(rsa) + b"\n", "FINGERPRINT_CANDIDATE", "NONE", "PLAIN", "ssh-rsa", rsa_fp)

print(f"SYNTHETIC_CHECKS_PASS={checks}")
