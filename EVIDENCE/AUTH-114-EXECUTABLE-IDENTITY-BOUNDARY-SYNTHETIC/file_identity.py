"""Bounded file-byte identity candidate; never executes the target."""

from __future__ import annotations

import hashlib
import os
import re
import stat


MAX_ALLOWED_BYTES = 16 * 1024 * 1024
CHUNK_BYTES = 64 * 1024
REPARSE_POINT = 0x400
SHA256 = re.compile(r"[0-9a-f]{64}")


def inspect_file_identity(
    path: str,
    expected_sha256: str,
    allowed_filename: str,
    max_bytes: int,
) -> dict:
    """Return fixed metadata only; success does not bind a future process."""
    def safe(category: str, size: int = 0, equal: bool = False) -> dict:
        return {
            "category": category,
            "size_bytes": size,
            "sha256_equal": equal,
            "identity_state": "FILE_BYTES_CANDIDATE_ONLY" if equal else "UNKNOWN",
        }

    if (
        type(path) is not str or not os.path.isabs(path) or "\x00" in path
        or os.path.normpath(path) != path
        or type(expected_sha256) is not str or not SHA256.fullmatch(expected_sha256)
        or type(allowed_filename) is not str
        or allowed_filename in ("", ".", "..")
        or os.path.basename(allowed_filename) != allowed_filename
        or "\x00" in allowed_filename
        or type(max_bytes) is not int or not 0 < max_bytes <= MAX_ALLOWED_BYTES
    ):
        return safe("INVALID_INPUT")
    if os.path.basename(path) != allowed_filename:
        return safe("NAME_MISMATCH")

    def is_reparse(metadata) -> bool:
        return stat.S_ISLNK(metadata.st_mode) or bool(
            getattr(metadata, "st_file_attributes", 0) & REPARSE_POINT
        )

    # Check every parent, not just the final file, without resolving links.
    parent = os.path.dirname(path)
    try:
        while True:
            parent_meta = os.lstat(parent)
            if is_reparse(parent_meta):
                return safe("REPARSE_POINT")
            if not stat.S_ISDIR(parent_meta.st_mode):
                return safe("NOT_REGULAR")
            next_parent = os.path.dirname(parent)
            if next_parent == parent:
                break
            parent = next_parent
        before = os.lstat(path)
    except (OSError, ValueError):
        return safe("READ_FAILED")

    if is_reparse(before):
        return safe("REPARSE_POINT")
    if not stat.S_ISREG(before.st_mode):
        return safe("NOT_REGULAR")
    if before.st_size == 0:
        return safe("EMPTY_FILE")
    if before.st_size < 0 or before.st_size > max_bytes:
        return safe("SIZE_LIMIT")

    flags = os.O_RDONLY | getattr(os, "O_BINARY", 0) | getattr(os, "O_CLOEXEC", 0)
    flags |= getattr(os, "O_NOFOLLOW", 0)
    try:
        descriptor = os.open(path, flags)
    except (OSError, ValueError):
        return safe("READ_FAILED")

    total = 0
    digest = hashlib.sha256()
    category = None
    try:
        opened = os.fstat(descriptor)
        if not stat.S_ISREG(opened.st_mode) or (
            opened.st_dev, opened.st_ino, opened.st_size
        ) != (before.st_dev, before.st_ino, before.st_size):
            category = "FILE_CHANGED"
        else:
            while True:
                chunk = os.read(descriptor, min(CHUNK_BYTES, max_bytes - total + 1))
                if not chunk:
                    break
                total += len(chunk)
                if total > max_bytes:
                    category = "SIZE_LIMIT"
                    break
                digest.update(chunk)
    except (OSError, ValueError):
        category = "READ_FAILED"
    finally:
        try:
            os.close(descriptor)
        except OSError:
            category = "READ_FAILED"

    if category:
        return safe(category)
    try:
        after = os.lstat(path)
    except (OSError, ValueError):
        return safe("FILE_CHANGED")
    if is_reparse(after) or (
        after.st_dev, after.st_ino, after.st_size
    ) != (before.st_dev, before.st_ino, before.st_size) or total != before.st_size:
        return safe("FILE_CHANGED")
    if digest.hexdigest() != expected_sha256:
        return safe("HASH_MISMATCH", total)
    return safe("FILE_BYTES_MATCH", total, True)
