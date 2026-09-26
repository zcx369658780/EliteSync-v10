"""Temporary synthetic files only; no child processes or real tools."""

import hashlib
import os
import pathlib
import tempfile
from unittest import mock

import file_identity


def main() -> None:
    checks = 0
    link_state = "NOT_TESTED"
    with tempfile.TemporaryDirectory(prefix="auth114-synthetic-") as temporary:
        root = pathlib.Path(temporary)
        target = root / "synthetic-tool.bin"
        data = b"SECRET_MARKER_114!"
        target.write_bytes(data)
        digest = hashlib.sha256(data).hexdigest()

        def inspect(path=target, expected=digest, name="synthetic-tool.bin", maximum=len(data)):
            return file_identity.inspect_file_identity(str(path), expected, name, maximum)

        result = inspect()
        assert result == {
            "category": "FILE_BYTES_MATCH", "size_bytes": len(data),
            "sha256_equal": True, "identity_state": "FILE_BYTES_CANDIDATE_ONLY",
        }
        assert "SECRET_MARKER_114" not in repr(result) and str(target) not in repr(result)
        checks += 1

        assert inspect(expected="0" * 64)["category"] == "HASH_MISMATCH"
        checks += 1
        assert inspect(maximum=len(data) - 1)["category"] == "SIZE_LIMIT"
        checks += 1
        assert inspect(maximum=len(data))["category"] == "FILE_BYTES_MATCH"
        checks += 1

        empty = root / "empty.bin"
        empty.write_bytes(b"")
        assert inspect(path=empty, name="empty.bin")["category"] == "EMPTY_FILE"
        checks += 1
        assert inspect(path=root, name=root.name)["category"] == "NOT_REGULAR"
        checks += 1
        assert inspect(path=root / "missing.bin", name="missing.bin")["category"] == "READ_FAILED"
        checks += 1

        assert inspect(name="WRONG.bin")["category"] == "NAME_MISMATCH"
        checks += 1
        assert inspect(path="relative.bin")["category"] == "INVALID_INPUT"
        checks += 1
        assert inspect(expected="bad")["category"] == "INVALID_INPUT"
        checks += 1
        assert inspect(maximum=0)["category"] == "INVALID_INPUT"
        checks += 1
        assert inspect(maximum=file_identity.MAX_ALLOWED_BYTES + 1)["category"] == "INVALID_INPUT"
        checks += 1

        with mock.patch.object(file_identity.os, "read", side_effect=OSError("SECRET_MARKER_114")):
            result = inspect()
        assert result["category"] == "READ_FAILED"
        assert "SECRET_MARKER_114" not in repr(result) and str(target) not in repr(result)
        checks += 1

        link = root / "alias.bin"
        try:
            os.symlink(target, link)
        except (OSError, NotImplementedError):
            pass
        else:
            assert inspect(path=link, name="alias.bin")["category"] == "REPARSE_POINT"
            checks += 1
            link_state = "PASS"

    print(f"SYNTHETIC_CHECKS_PASS={checks};SYMLINK_TEST={link_state}")


if __name__ == "__main__":
    main()
