"""Read-only identities for caller-declared files; no build qualification."""
import hashlib
import os
from pathlib import Path
import stat


def _absolute_path(value):
    if not isinstance(value, str) or not value or "\x00" in value:
        raise ValueError("paths must be nonempty absolute normalized strings")
    if not os.path.isabs(value) or os.path.abspath(value) != value:
        raise ValueError("paths must be absolute and normalized")
    # Windows alternate streams and device namespaces are not ordinary files.
    drive, tail = os.path.splitdrive(value)
    if os.name == "nt" and (":" in tail or value.startswith(("\\\\?\\", "\\\\.\\"))):
        raise ValueError("alternate streams and device paths are not allowed")
    return Path(value)


def _checked_stat(path):
    result = None
    for ancestor in (*reversed(path.parents), path):
        current = os.lstat(ancestor)
        if stat.S_ISLNK(current.st_mode) or getattr(current, "st_file_attributes", 0) & 0x400:
            raise ValueError("symlink/reparse paths are not allowed")
        if ancestor != path and not stat.S_ISDIR(current.st_mode):
            raise ValueError("ancestors must be directories")
        result = current
    return result


def _identity(info):
    return (info.st_dev, info.st_ino, info.st_size, info.st_mtime_ns)


def _regular(info):
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size < 0:
        raise ValueError("inputs must be regular files with one hard link")


def inventory_files(entries, allowed_roots, file_limit, byte_limit):
    """Return identities or raise ValueError/OSError; never discover input files.

    Roots and entries must be nonempty lists/tuples, paths normalized absolute
    strings, and caps positive integers (not bool). All limits are aggregate.
    The result covers only selected files and grants no execution permission.
    """
    for cap in (file_limit, byte_limit):
        if type(cap) is not int or cap <= 0:
            raise ValueError("limits must be positive integers, excluding bool")
    if not isinstance(entries, (list, tuple)) or not entries:
        raise ValueError("entries must be a nonempty list/tuple")
    if len(entries) > file_limit:
        raise ValueError("file limit exceeded")
    if not isinstance(allowed_roots, (list, tuple)) or not allowed_roots:
        raise ValueError("allowed_roots must be a nonempty list/tuple")
    roots = [_absolute_path(root) for root in allowed_roots]
    for root in roots:
        if not stat.S_ISDIR(_checked_stat(root).st_mode):
            raise ValueError("allowed roots must be directories")
    seen, selected = set(), []
    # Detect duplicates before touching a possibly differently-cased path.
    for entry in entries:
        if not isinstance(entry, (list, tuple)) or len(entry) != 2:
            raise ValueError("each entry must contain role and absolute path")
        role, raw = entry
        if not isinstance(role, str) or not role.strip():
            raise ValueError("role must be a nonempty string")
        path = _absolute_path(raw)
        key = str(path).casefold()
        if key in seen:
            raise ValueError("duplicate casefold path")
        seen.add(key)
        if not any(path.is_relative_to(root) for root in roots):
            raise ValueError("file is outside allowed roots")
        selected.append((role, path))
    prepared, total = [], 0
    for role, path in selected:
        info = _checked_stat(path)
        _regular(info)
        total += info.st_size
        if total > byte_limit:
            raise ValueError("byte limit exceeded")
        prepared.append((role, path, info))
    rows, bytes_read = [], 0
    for role, path, expected in prepared:
        if _identity(_checked_stat(path)) != _identity(expected):
            raise ValueError("path changed before open")
        flags = os.O_RDONLY | getattr(os, "O_BINARY", 0) | getattr(os, "O_NOFOLLOW", 0)
        fd = os.open(path, flags)
        try:
            before = os.fstat(fd)
            _regular(before)
            if _identity(before) != _identity(expected):
                raise ValueError("opened file identity changed")
            digest, count = hashlib.sha256(), 0
            while True:
                chunk = os.read(fd, min(1024 * 1024, byte_limit - bytes_read + 1))
                if not chunk:
                    break
                count += len(chunk)
                bytes_read += len(chunk)
                if bytes_read > byte_limit or count > expected.st_size:
                    raise ValueError("read exceeded declared size or byte limit")
                digest.update(chunk)
            after = os.fstat(fd)
            current = _checked_stat(path)
            _regular(after)
            _regular(current)
            if (count != expected.st_size or _identity(after) != _identity(before)
                    or _identity(current) != _identity(before)):
                raise ValueError("file changed while reading")
            rows.append({"role": role, "path": str(path), "bytes": count,
                         "file_id": {"device": before.st_dev, "inode": before.st_ino},
                         "sha256": digest.hexdigest()})
        finally:
            os.close(fd)
    return {"files": rows, "total_count": len(rows), "total_bytes": bytes_read,
            "scope": "SELECTED_DECLARED_FILES_ONLY", "execution_allowed": False,
            "G2": False}
