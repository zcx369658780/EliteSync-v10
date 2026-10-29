"""Nonproduction, offline preparation. Import/inspect never starts a process.

This enforces a trusted operator's frozen inputs, not hostile-code OS isolation.
No private vendor patch is embedded. A byte-exact LOCAL_ONLY diff is required.
"""
from __future__ import annotations

import hashlib
import json
import os
import re
import stat
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath


class Rejected(Exception):
    def __init__(self, code: str):
        self.code = code
        super().__init__(code)


def require(ok, code):
    if not ok:
        raise Rejected(code)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def canonical_json(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode()


def sha_ok(value):
    return isinstance(value, str) and re.fullmatch(r"[0-9a-f]{64}", value) is not None


def validate_pins(pins):
    require(sha_ok(pins.get("hook_original_sha256")), "CONTRACT_SOURCE_HASH_MALFORMED")
    for key in ("hook_target_sha256", "patch_diff_sha256", "dart_executable_sha256", "flutter_entry_sha256"):
        require(sha_ok(pins.get(key)), "PIN_HASH_INVALID")
    require(pins.get("flutter") == "3.41.7" and pins.get("dart") == "3.11.5"
            and pins.get("hooks_runner") == "1.0.1", "VERSION_MISMATCH")


def private_path(path, *, exists=True):
    # Reject network/device namespaces before any exists/lstat/resolve operation.
    text = os.fspath(path)
    require(isinstance(text, str) and not text.replace("\\", "/").startswith("//"),
            "NETWORK_OR_DEVICE_PATH_REJECTED")
    p = Path(path)
    require(p.is_absolute() and ".." not in p.parts, "ABSOLUTE_CANONICAL_PATH_REQUIRED")
    if os.name == "nt":
        import ctypes
        api = ctypes.WinDLL("kernel32", use_last_error=True)
        api.GetDriveTypeW.argtypes = [ctypes.c_wchar_p]
        api.GetDriveTypeW.restype = ctypes.c_uint
        require(api.GetDriveTypeW(p.anchor) == 3, "FIXED_LOCAL_VOLUME_REQUIRED")
    for part in (p, *p.parents):
        if part.exists() or part.is_symlink():
            info = part.lstat()
            require(not stat.S_ISLNK(info.st_mode) and not getattr(info, "st_file_attributes", 0) & 0x400,
                    "LINK_OR_REPARSE_REJECTED")
            if part.is_file():
                require(info.st_nlink == 1, "HARDLINK_REJECTED")
    if exists:
        require(p.exists(), "INPUT_MISSING")
    return p.resolve(strict=exists)


def within(path, root):
    return path == root or root in path.parents


def relative_path(value):
    require(isinstance(value, str) and value and "\\" not in value and ":" not in value,
            "UNSAFE_RELATIVE_PATH")
    p = PurePosixPath(value)
    require(not p.is_absolute() and all(x not in ("", ".", "..") for x in value.split("/")),
            "UNSAFE_RELATIVE_PATH")
    reserved = {"CON", "PRN", "AUX", "NUL", *("COM" + str(i) for i in range(1, 10)), *("LPT" + str(i) for i in range(1, 10))}
    require(all(not x.endswith((".", " ")) and "\x00" not in x and x.split(".")[0].upper() not in reserved for x in p.parts), "WINDOWS_NAME_REJECTED")
    return value


def read_verified(path, expected, roots):
    require(sha_ok(expected), "PIN_HASH_INVALID")
    p = private_path(path)
    require(any(within(p, root) for root in roots), "INPUT_ROOT_REJECTED")
    require(p.is_file(), "INPUT_FILE_REQUIRED")
    data = p.read_bytes()
    require(digest(data) == expected, "SOURCE_HASH_MISMATCH")
    return data


def apply_unified(original: bytes, patch: bytes) -> bytes:
    """Strict one-file LF unified diff; no fuzzy matching, file names never used as paths."""
    require(b"\r" not in patch and b"\x00" not in patch, "PATCH_BYTES_NOT_CANONICAL_LF")
    try:
        old = original.decode("utf-8").splitlines(keepends=True)
        lines = patch.decode("utf-8").splitlines(keepends=True)
    except UnicodeError as error:
        raise Rejected("PATCH_UTF8_REQUIRED") from error
    require(len(lines) >= 3 and lines[0].startswith("--- ") and lines[1].startswith("+++ "),
            "PATCH_FORMAT_REJECTED")
    result, cursor, pos, hunks = [], 0, 2, 0
    while pos < len(lines):
        require(not lines[pos].startswith(("--- ", "+++ ")), "PATCH_EXTRA_FILE_OR_MARKER")
        match = re.fullmatch(r"@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@[^\n]*\n?", lines[pos])
        require(match is not None, "PATCH_HUNK_REJECTED")
        start, count = int(match[1]), int(match[2] or 1)
        new_start, new_count = int(match[3]), int(match[4] or 1)
        index = start if count == 0 else start - 1
        require(cursor <= index <= len(old), "PATCH_OVERLAP_OR_RANGE")
        result.extend(old[cursor:index]); cursor = index
        require(len(result) == (new_start if new_count == 0 else new_start - 1), "PATCH_NEW_RANGE")
        pos += 1; removed = added = 0
        while pos < len(lines) and not lines[pos].startswith("@@ "):
            if removed == count and added == new_count:
                break
            line = lines[pos]; pos += 1
            require(line[:1] in (" ", "+", "-"), "PATCH_EXTRA_FILE_OR_MARKER")
            text = line[1:]
            if line[0] in " -":
                require(cursor < len(old) and old[cursor] == text, "PATCH_CONTEXT_MISMATCH")
                cursor += 1; removed += 1
            if line[0] in " +":
                result.append(text); added += 1
        require((removed, added) == (count, new_count), "PATCH_COUNT_MISMATCH")
        hunks += 1
    require(hunks > 0, "PATCH_HOOK_MISSING")
    return "".join(result + old[cursor:]).encode("utf-8")


def reproduce(original, diff, pins):
    validate_pins(pins)
    require(digest(original) == pins["hook_original_sha256"], "SOURCE_HASH_MISMATCH")
    require(digest(diff) == pins["patch_diff_sha256"], "PATCH_DIFF_HASH_MISMATCH")
    target = apply_unified(original, diff)
    require(digest(target) == pins["hook_target_sha256"], "PATCH_TARGET_HASH_MISMATCH")
    return target


def check_resolver(data, destination, target, destination_files):
    try:
        config = json.loads(data)
    except (ValueError, UnicodeError) as error:
        raise Rejected("RESOLVER_JSON_INVALID") from error
    packages = config.get("packages")
    require(isinstance(packages, list) and packages, "DEPENDENCY_CLOSURE_MISSING")
    for package in packages:
        uri = urllib.parse.urljoin(destination.as_uri(), package["rootUri"])
        parsed = urllib.parse.urlparse(uri)
        require(parsed.scheme == "file" and parsed.netloc in ("", "localhost"), "RESOLVER_SCHEME_REJECTED")
        from urllib.request import url2pathname
        root = Path(url2pathname(parsed.path)).resolve()
        require(within(root, target), "DEPENDENCY_PATH_OUTSIDE_TARGET")
        require(any(within(p, root) for p in destination_files), "DEPENDENCY_FILES_MISSING")


def grant_check(grant, plan_hash, action, pins, now=None):
    """Local receipt consistency, NOT independent proof of Owner identity.

    A future operator must first fresh-verify the new task on GitHub externally.
    """
    now = now or datetime.now(timezone.utc)
    require(isinstance(grant, dict) and grant.get("owner_authorized") is True, "OWNER_AUTHORIZATION_REQUIRED")
    require(grant.get("task_id") not in pins.get("closed_task_ids", []) and grant.get("task_id"), "CLOSED_TASK_BUDGET")
    blob = grant.get("task_blob", "")
    require(re.fullmatch(r"[0-9a-f]{40}", blob) and blob not in pins.get("closed_task_blobs", []), "NEW_TASK_AUTHORITY_REQUIRED")
    require(grant.get("source_parent") == pins["source_parent"], "PARENT_MISMATCH")
    require(grant.get("plan_sha256") == plan_hash and action in grant.get("actions", []), "GRANT_SCOPE_MISMATCH")
    try:
        start = datetime.fromisoformat(grant["not_before"])
        end = datetime.fromisoformat(grant["expires_at"])
        require(start.tzinfo is not None and end.tzinfo is not None and start <= now < end, "GRANT_EXPIRED")
    except (KeyError, ValueError, TypeError) as error:
        raise Rejected("GRANT_TIME_INVALID") from error
    if action == "execute":
        budget = grant.get("runtime_batches")
        require(type(budget) is int and 0 < budget <= pins["maximum_future_batches"], "EXECUTE_DISABLED")


class Ledger:
    """Append/flush, hash chained, exclusive caller lock, no refund or retry of uncertain operations."""
    def __init__(self, root):
        self.root = private_path(root)
        self.path = self.root / "execution_ledger.jsonl"

    def read(self):
        require(self.path.is_file(), "LEDGER_MISSING")
        raw = self.path.read_bytes()
        require(not raw or raw.endswith(b"\n"), "LEDGER_TRUNCATED")
        entries, previous = [], "0" * 64
        for line in raw.splitlines():
            try:
                entry = json.loads(line)
            except ValueError as error:
                raise Rejected("LEDGER_INVALID") from error
            require(isinstance(entry, dict), "LEDGER_INVALID")
            hashed = dict(entry); actual = hashed.pop("hash", None)
            require(entry.get("seq") == len(entries) and entry.get("prev") == previous
                    and digest(canonical_json(hashed)) == actual, "LEDGER_CHAIN_BROKEN")
            previous = actual; entries.append(entry)
        return entries

    def append(self, event, **values):
        entries = self.read()
        value = dict(seq=len(entries), prev=entries[-1]["hash"] if entries else "0" * 64,
                     event=event, utc=datetime.now(timezone.utc).isoformat(), **values)
        value["hash"] = digest(canonical_json(value))
        with self.path.open("ab", buffering=0) as stream:
            stream.write(canonical_json(value) + b"\n"); os.fsync(stream.fileno())
        return value

    def __enter__(self):
        self.lock = self.root / ".entry.lock"
        try:
            handle = os.open(self.lock, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
            os.close(handle)
        except FileExistsError as error:
            raise Rejected("CONCURRENT_OR_STALE_LOCK") from error
        return self

    def __exit__(self, *_):
        self.lock.unlink()


def inspect_plan(config, pins):
    validate_pins(pins)
    target = private_path(config["target"], exists=False)
    owned = private_path(config["owned_parent"])
    require(target != owned and within(target, owned), "TARGET_NOT_TASK_OWNED")
    roots = [private_path(p) for p in config["approved_input_roots"]]
    require(roots and all(not within(target, r) and not within(r, target) for r in roots), "OLD_PATH_CROSSOVER")
    require(not target.exists(), "TARGET_EXISTS_RECOVER_LEDGER")
    artifacts = config.get("artifacts", [])
    require(isinstance(artifacts, list) and artifacts, "ARTIFACT_MANIFEST_REQUIRED")
    seen, roles, output, total, app_rows = set(), {}, [], 0, []
    for item in artifacts:
        rel = relative_path(item["relative"])
        require(rel.casefold() not in seen, "DUPLICATE_OUTPUT_PATH")
        seen.add(rel.casefold())
        data = read_verified(item["source"], item["sha256"], roots)
        if rel.startswith("source/apps/") and item.get("tracked") is True:
            mode = item.get("mode", "100644")
            require(mode in ("100644", "100755"), "SOURCE_MODE_REJECTED")
            blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
            app_rows.append((rel[len("source/apps/"):], mode, blob))
        role = item.get("role", "support")
        if role != "support":
            require(role not in roles, "DUPLICATE_ROLE")
            roles[role] = (item, data)
        output.append(dict(relative=rel, sha256=digest(data), bytes=len(data)))
        total += len(data)
    for role in ["dart", "dart_vm", "engine", "git", "where", "flutter_entry", "flutter_version", "hook_original", "tools_resolver", "app_resolver"]:
        require(role in roles, "REQUIRED_ROLE_MISSING_" + role)
    require(digest(roles["dart"][1]) == pins["dart_executable_sha256"], "DART_HASH_MISMATCH")
    require(digest(roles["flutter_entry"][1]) == pins["flutter_entry_sha256"], "FLUTTER_ENTRY_HASH_MISMATCH")
    for role in ("dart_vm", "engine", "git", "where"):
        require(digest(roles[role][1]) == pins[role + "_sha256"], "PROGRAM_HASH_MISMATCH")
    layout = {
        "dart": "flutter_private/bin/cache/dart-sdk/bin/dart.exe",
        "dart_vm": "flutter_private/bin/cache/dart-sdk/bin/dartvm.exe",
        "engine": "flutter_private/bin/cache/artifacts/engine/windows-x64/flutter_tester.exe",
        "git": "flutter_private/bin/mingit/cmd/git.exe", "where": "os_tools/where.exe",
        "flutter_entry": "flutter_private/packages/flutter_tools/bin/flutter_tools.dart",
        "tools_resolver": "flutter_private/packages/flutter_tools/.dart_tool/package_config.json",
        "app_resolver": "source/apps/flutter_elitesync_module/.dart_tool/package_config.json",
    }
    require(all(roles[k][0]["relative"] == v for k, v in layout.items()), "ROLE_LAYOUT_MISMATCH")
    require(len(app_rows) == pins["source_app_blob_count"] and git_tree(app_rows) == pins["source_apps_tree"], "SOURCE_APP_TREE_MISMATCH")
    version = json.loads(roles["flutter_version"][1])
    require(version.get("frameworkVersion") == pins["flutter"] and version.get("frameworkRevision") == pins["framework_revision"]
            and version.get("dartSdkVersion") == pins["dart"], "VERSION_MISMATCH")
    diff = read_verified(config["patch_diff"], pins["patch_diff_sha256"], roots)
    patched = reproduce(roles["hook_original"][1], diff, pins)
    hook_path = roles["hook_original"][0]["relative"]
    for item in output:
        if item["relative"] == hook_path:
            item.update(sha256=digest(patched), bytes=len(patched)); total += len(patched) - len(roles["hook_original"][1])
    files = [target / x["relative"] for x in output]
    for role in ("tools_resolver", "app_resolver"):
        item, data = roles[role]
        check_resolver(data, target / item["relative"], target, files)
    # Caller must supply a complete fixed, hashed offline file manifest; no pub get fallback.
    require(config.get("complete_offline_manifest") is True, "DEPENDENCY_CLOSURE_NOT_ATTESTED")
    metadata_reserve = 1048576 + sum(2 * (len(canonical_json(row)) + 1024) for row in output)
    allocation_upper = sum(((row["bytes"] + 65535) // 65536) * 65536 for row in output)
    require(type(config.get("max_logical")) is int and type(config.get("max_allocated")) is int
            and total + metadata_reserve <= config["max_logical"]
            and allocation_upper + metadata_reserve <= config["max_allocated"], "SPACE_BUDGET_EXPIRED")
    plan = dict(schema=1, task_id=config["task_id"], source_parent=pins["source_parent"],
                target=str(target), outputs=output, estimated_logical=total,
                max_logical=config["max_logical"], max_allocated=config["max_allocated"], metadata_reserve=metadata_reserve,
                roles={k: v[0]["relative"] for k, v in roles.items()}, execute_default="EXECUTE_DISABLED")
    plan["sha256"] = digest(canonical_json(plan))
    return plan, patched


def git_tree(rows):
    directories, leaves = {}, {}
    for path, mode, value in rows:
        if "/" in path:
            head, tail = path.split("/", 1)
            directories.setdefault(head, []).append((tail, mode, value))
        else:
            leaves[path] = (mode, value)
    for name, children in directories.items():
        leaves[name] = ("40000", git_tree(children))
    content = b"".join(mode.lstrip("0").encode() + b" " + name.encode() + b"\0" + bytes.fromhex(value)
                       for name, (mode, value) in sorted(leaves.items(), key=lambda x: (x[0] + ("/" if x[1][0] == "40000" else "")).encode()))
    return hashlib.sha1(b"tree " + str(len(content)).encode() + b"\0" + content).hexdigest()


def allocated_bytes(path):
    # stat.st_blocks is real allocation on POSIX; Windows uses the native compressed-size API.
    if os.name != "nt":
        return path.stat().st_blocks * 512
    import ctypes
    from ctypes import wintypes
    api = ctypes.WinDLL("kernel32", use_last_error=True)
    api.GetCompressedFileSizeW.argtypes = [wintypes.LPCWSTR, ctypes.POINTER(wintypes.DWORD)]
    api.GetCompressedFileSizeW.restype = wintypes.DWORD
    high = wintypes.DWORD(); low = api.GetCompressedFileSizeW(str(path), ctypes.byref(high))
    require(low != 0xFFFFFFFF or ctypes.get_last_error() == 0, "ALLOCATION_QUERY_FAILED")
    return (high.value << 32) | low


def space(root, logical, allocated):
    size = used = 0
    for p in root.rglob("*"):
        private_path(p)
        if p.is_file():
            size += p.stat().st_size; used += allocated_bytes(p)
    require(size <= logical and used <= allocated, "SPACE_BUDGET_EXPIRED")
    return dict(logical=size, allocated=used)


def prepare(config, grant, pins):
    plan, patched = inspect_plan(config, pins)
    grant_check(grant, plan["sha256"], "prepare", pins)
    target = Path(plan["target"])
    require(plan["task_id"] == grant["task_id"], "TASK_ID_MISMATCH")
    target.mkdir()  # Exclusive new destination. No existing worktree is ever absorbed.
    (target / "execution_ledger.jsonl").touch(exist_ok=False)
    ledger = Ledger(target)
    with ledger:
        ledger.append("INITIALIZED", task_id=plan["task_id"], plan_sha256=plan["sha256"], task_blob=grant["task_blob"])
        for artifact in config["artifacts"]:
            rel = artifact["relative"]; dst = target / rel
            ledger.append("PREPARE_COPY", relative=rel, input_sha256=artifact["sha256"])
            roots = [private_path(p) for p in config["approved_input_roots"]]
            data = read_verified(artifact["source"], artifact["sha256"], roots)
            if artifact.get("role") == "hook_original":
                require(digest(data) == pins["hook_original_sha256"], "SOURCE_HASH_MISMATCH")
                data = patched
            dst.parent.mkdir(parents=True, exist_ok=True)
            private_path(dst.parent)
            with dst.open("xb") as stream:
                stream.write(data); stream.flush(); os.fsync(stream.fileno())
            require(digest(dst.read_bytes()) == digest(data), "COPY_READBACK_MISMATCH")
            ledger.append("COPIED", relative=rel, sha256=digest(data), bytes=len(data))
            space(target, plan["max_logical"], plan["max_allocated"])
        ledger.append("PREPARE_MANIFEST", sha256=plan["sha256"])
        with (target / "prepared.json").open("xb") as stream:
            stream.write(canonical_json(plan)); stream.flush(); os.fsync(stream.fileno())
        ledger.append("PREPARED", plan_sha256=plan["sha256"])
    return dict(state="PREPARED_EXECUTE_DISABLED", plan_sha256=plan["sha256"], space=space(target, plan["max_logical"], plan["max_allocated"]))


def recover(root):
    ledger = Ledger(root); entries = ledger.read()
    require(entries and any(x["event"] == "PREPARED" for x in entries), "INTERRUPTED_PREPARE_RECONCILIATION_REQUIRED")
    plan = json.loads((ledger.root / "prepared.json").read_bytes())
    original = dict(plan); expected = original.pop("sha256")
    require(digest(canonical_json(original)) == expected and entries[0].get("plan_sha256") == expected, "PREPARED_MANIFEST_CHANGED")
    require(private_path(plan["target"]) == ledger.root, "PREPARED_ROOT_MOVED_OR_COPIED")
    require(entries[0].get("event") == "INITIALIZED" and entries[0].get("task_id") == plan["task_id"],
            "LEDGER_TASK_ID_MISMATCH")
    for row in plan["outputs"]:
        p = private_path(ledger.root / relative_path(row["relative"]))
        require(digest(p.read_bytes()) == row["sha256"], "PREPARED_ARTIFACT_CHANGED")
    require(not any(e["event"] == "RUNTIME_PREPARE" and not any(v.get("operation") == e.get("operation") and v["event"] == "RUNTIME_ENDED" for v in entries) for e in entries), "UNCERTAIN_RUNTIME_CONSUMED_NO_RETRY")
    return plan, entries
