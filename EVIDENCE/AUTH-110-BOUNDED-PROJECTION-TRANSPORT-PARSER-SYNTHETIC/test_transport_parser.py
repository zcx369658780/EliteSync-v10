"""Pure synthetic byte tests. This file starts no child processes."""

import copy
import json

from transport_parser import OPTIONS, parse_transport


BASE = {
    "protocol_version": 1,
    "error_class": "NONE",
    "version_candidate": "10.11.14",
    "help_text_state": "BOUNDED_UNPARSED",
    "version_bytes": 34,
    "help_bytes": 80,
    "exit_codes": [0, 0],
    "option_states": {name: "UNKNOWN" for name in OPTIONS},
    "identity_state": "CALLER_CANDIDATE_UNVERIFIED",
}


def frame(payload=BASE) -> bytes:
    return (json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n").encode("utf-8")


def parse(stdout=None, stderr=b"", ssh_exit=0, remote_exit=0,
          stdout_complete=True, stderr_complete=True):
    return parse_transport(
        frame() if stdout is None else stdout, stderr, ssh_exit, remote_exit,
        stdout_complete=stdout_complete, stderr_complete=stderr_complete,
    )


def main() -> None:
    checks = 0

    result = parse()
    assert result["status"] == "TEXT_CANDIDATE_ONLY"
    assert result["version_candidate"] == "10.11.14"
    assert result["help_text_state"] == "BOUNDED_UNPARSED"
    assert set(result["option_states"].values()) == {"UNKNOWN"}
    assert result["identity_state"] == "UNVERIFIED"
    checks += 1

    for kwargs, status in (
        ({"ssh_exit": None}, "EXIT_UNKNOWN"),
        ({"remote_exit": None}, "EXIT_UNKNOWN"),
        ({"ssh_exit": 7}, "SSH_NONZERO_EXIT"),
        ({"remote_exit": 9}, "REMOTE_NONZERO_EXIT"),
        ({"stdout_complete": False}, "TRANSPORT_INCOMPLETE"),
        ({"stderr_complete": False}, "TRANSPORT_INCOMPLETE"),
        ({"stderr": b"SECRET_MARKER_84"}, "SSH_STDERR_PRESENT"),
        ({"stdout": b"X" * 2049}, "TRANSPORT_LIMIT"),
        ({"stderr": b"X" * 2049}, "TRANSPORT_LIMIT"),
    ):
        result = parse(**kwargs)
        assert result["status"] == status
        assert result["version_candidate"] == "UNKNOWN"
        assert "SECRET_MARKER_84" not in repr(result)
        checks += 1

    for raw in (
        frame() + frame(), frame().rstrip(b"\n"), b"\xef\xbb\xbf" + frame(),
        b"\x1b[31m" + frame(), frame().replace(b"\n", b"\r\n"),
        frame().replace(b"\n", b"\x00\n"), b"\xff\n", b"{}\n\n",
    ):
        assert parse(stdout=raw)["status"] in ("FRAME_INVALID", "JSON_INVALID")
        checks += 1

    duplicate = frame().replace(b'"protocol_version":1,', b'"protocol_version":1,"protocol_version":1,')
    assert parse(stdout=duplicate)["status"] == "JSON_INVALID"
    checks += 1

    for change in (
        lambda p: p.update(extra="SECRET_MARKER_84"),
        lambda p: p.pop("help_bytes"),
        lambda p: p.update(protocol_version=True),
        lambda p: p.update(protocol_version=2),
        lambda p: p.update(error_class="SECRET_MARKER_84"),
        lambda p: p.update(version_candidate="SECRET_MARKER_84"),
        lambda p: p.update(help_text_state="PRESENT_IN_TEXT"),
        lambda p: p.update(version_bytes=True),
        lambda p: p.update(help_bytes=24577),
        lambda p: p.update(exit_codes=[0]),
        lambda p: p.update(exit_codes=[0, "0"]),
        lambda p: p.update(identity_state="VERIFIED"),
        lambda p: p["option_states"].update({"--quick": "PRESENT_IN_TEXT"}),
        lambda p: p["option_states"].update({"extra": "UNKNOWN"}),
        lambda p: p.update(version_candidate={"nested": "SECRET_MARKER_84"}),
    ):
        payload = copy.deepcopy(BASE)
        change(payload)
        result = parse(stdout=frame(payload))
        assert result["status"] == "SCHEMA_INVALID"
        assert "SECRET_MARKER_84" not in repr(result)
        checks += 1

    for change in (
        lambda p: p.update(exit_codes=[0, None]),
        lambda p: p.update(version_candidate="UNKNOWN"),
        lambda p: p.update(help_text_state="UNKNOWN"),
        lambda p: p.update(version_bytes=0),
    ):
        payload = copy.deepcopy(BASE)
        change(payload)
        assert parse(stdout=frame(payload))["status"] == "SCHEMA_INVALID"
        checks += 1

    payload = copy.deepcopy(BASE)
    payload.update(error_class="TIMEOUT", version_candidate="UNKNOWN", help_text_state="UNKNOWN")
    result = parse(stdout=frame(payload))
    assert result["status"] == "REMOTE_REPORTED_FAILURE"
    assert result["version_candidate"] == "UNKNOWN"
    checks += 1

    payload["version_candidate"] = "10.11.14"
    assert parse(stdout=frame(payload))["status"] == "SCHEMA_INVALID"
    checks += 1

    assert parse(stdout=b'{"x":NaN}\n')["status"] == "JSON_INVALID"
    checks += 1
    assert parse(stdout=frame(), ssh_exit=True)["status"] == "EXIT_UNKNOWN"
    checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
