"""Pure synthetic bytes; this test launches no child process."""

import copy
import inspect
import json

from single_exit_parser import OPTIONS, parse_single_exit


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


def parse(stdout=None, stderr=b"", ssh_exit=0,
          stdout_complete=True, stderr_complete=True):
    return parse_single_exit(
        frame() if stdout is None else stdout, stderr, ssh_exit,
        stdout_complete=stdout_complete, stderr_complete=stderr_complete,
    )


def main() -> None:
    checks = 0
    assert "remote_exit" not in inspect.signature(parse_single_exit).parameters
    result = parse()
    assert result["status"] == "PROTOCOL_CONSISTENT_TEXT_CANDIDATE"
    assert result["version_candidate"] == "10.11.14"
    assert result["ssh_exit_source"] == "SSH_EXIT_OBSERVED_CANDIDATE"
    assert result["remote_program_state"] == "UNVERIFIED_PROTOCOL_DECLARATION"
    assert result["tool_exit_state"] == "UNVERIFIED_PROTOCOL_DECLARATION"
    assert set(result["option_states"].values()) == {"UNKNOWN"}
    checks += 1

    for exit_value, status in ((255, "SSH_255_AMBIGUOUS"), (1, "SSH_NONZERO_EXIT"),
                               (-1, "SSH_NONZERO_EXIT"), (None, "SSH_EXIT_UNKNOWN"),
                               (True, "SSH_EXIT_UNKNOWN"), (2**40, "SSH_EXIT_UNKNOWN")):
        result = parse(ssh_exit=exit_value)
        assert result["status"] == status and result["version_candidate"] == "UNKNOWN"
        checks += 1

    for kwargs, status in (
        ({"stdout_complete": False}, "TRANSPORT_INCOMPLETE"),
        ({"stderr_complete": False}, "TRANSPORT_INCOMPLETE"),
        ({"stderr": b"SECRET_MARKER_113"}, "SSH_STDERR_PRESENT"),
        ({"stdout": b"X" * 2049}, "TRANSPORT_LIMIT"),
        ({"stderr": b"X" * 2049}, "TRANSPORT_LIMIT"),
    ):
        result = parse(**kwargs)
        assert result["status"] == status
        assert "SECRET_MARKER_113" not in repr(result)
        checks += 1

    # Even a valid success JSON cannot override an observed nonzero SSH exit.
    assert parse(ssh_exit=255)["status"] == "SSH_255_AMBIGUOUS"
    checks += 1
    assert parse(ssh_exit=7)["status"] == "SSH_NONZERO_EXIT"
    checks += 1

    for change, status in (
        (lambda p: p.update(error_class="TIMEOUT", version_candidate="UNKNOWN",
                            help_text_state="UNKNOWN"), "REMOTE_REPORTED_FAILURE"),
        (lambda p: p.update(exit_codes=[0, 2]), "SCHEMA_INVALID"),
        (lambda p: p.update(exit_codes=[0, None]), "SCHEMA_INVALID"),
        (lambda p: p.update(version_candidate="UNKNOWN"), "SCHEMA_INVALID"),
        (lambda p: p.update(help_text_state="UNKNOWN"), "SCHEMA_INVALID"),
        (lambda p: p.update(version_bytes=0), "SCHEMA_INVALID"),
        (lambda p: p.update(error_class="SECRET_MARKER_113"), "SCHEMA_INVALID"),
        (lambda p: p["option_states"].update({"--quick": "PRESENT_IN_TEXT"}), "SCHEMA_INVALID"),
        (lambda p: p.update(extra="SECRET_MARKER_113"), "SCHEMA_INVALID"),
        (lambda p: p.pop("help_bytes"), "SCHEMA_INVALID"),
        (lambda p: p.update(identity_state="VERIFIED"), "SCHEMA_INVALID"),
        (lambda p: p.update(version_candidate={"secret": "SECRET_MARKER_113"}), "SCHEMA_INVALID"),
    ):
        payload = copy.deepcopy(BASE)
        change(payload)
        result = parse(stdout=frame(payload))
        assert result["status"] == status
        assert result["version_candidate"] == "UNKNOWN"
        assert "SECRET_MARKER_113" not in repr(result)
        checks += 1

    for raw, status in (
        (frame() + frame(), "FRAME_INVALID"),
        (frame().rstrip(b"\n"), "FRAME_INVALID"),
        (b"\xef\xbb\xbf" + frame(), "JSON_INVALID"),
        (b"\x1b[31m" + frame(), "FRAME_INVALID"),
        (frame().replace(b"\n", b"\r\n"), "FRAME_INVALID"),
        (b"\xff\n", "JSON_INVALID"),
    ):
        assert parse(stdout=raw)["status"] == status
        checks += 1

    duplicate = frame().replace(b'"protocol_version":1,', b'"protocol_version":1,"protocol_version":1,')
    assert parse(stdout=duplicate)["status"] == "JSON_INVALID"
    checks += 1
    assert parse(stdout=b'{"x":NaN}\n')["status"] == "JSON_INVALID"
    checks += 1

    print(f"SYNTHETIC_CHECKS_PASS={checks}")


if __name__ == "__main__":
    main()
