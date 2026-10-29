"""Future Windows execution adapter. NOT RUN under the 20261029 tooling task.

No subprocess call occurs on import or before every authority/ledger/input gate.
Requires trusted future operator verification; local JSON is not Owner identity.
"""
from __future__ import annotations

import json
import os
import time
import uuid
from pathlib import Path

from core import Ledger, Rejected, digest, grant_check, private_path, recover, require, space, validate_pins, within


SHELLS = {"cmd.exe", "powershell.exe", "pwsh.exe", "bash.exe", "sh.exe", "wscript.exe", "cscript.exe"}


def path_in_root(value, root, *, output=False):
    p = private_path(value, exists=not output)
    require(within(p, root), "ARGUMENT_OUTSIDE_TASK")
    return str(p)


def hook_arguments(executable, arguments, cwd, root, dart):
    exe = private_path(executable)
    require(exe == private_path(dart) and exe.suffix.lower() == ".exe" and exe.name.lower() not in SHELLS,
            "SHELL_OR_UNKNOWN_EXECUTABLE")
    path_in_root(cwd, root)
    def flag(value, name, output=False):
        require(value.startswith(name + "="), "ARGUMENT_PATTERN_REJECTED")
        return name + "=" + path_in_root(value[len(name) + 1:], root, output=output)
    a = arguments
    if len(a) == 6 and a[:2] == ["compile", "kernel"]:
        return ["compile", "kernel", flag(a[2], "--packages"), flag(a[3], "--output", True),
                flag(a[4], "--depfile", True), path_in_root(a[5], root)]
    if len(a) in (3, 4) and a[0].startswith("--packages="):
        result = [flag(a[0], "--packages"), path_in_root(a[1], root), flag(a[2], "--config")]
        if len(a) == 4:
            result.append(path_in_root(a[3], root))
        return result
    raise Rejected("ARGUMENT_PATTERN_REJECTED")


def private_environment(root, system_root):
    names = {"HOME": "home", "USERPROFILE": "home", "TEMP": "tmp", "TMP": "tmp", "TMPDIR": "tmp",
             "APPDATA": "appdata", "LOCALAPPDATA": "localappdata", "PUB_CACHE": "pub_private", "FLUTTER_ROOT": "flutter_private"}
    env = {key: str(root / value) for key, value in names.items()}
    env.update(SYSTEMROOT=system_root, WINDIR=system_root, CI="true", FLUTTER_SUPPRESS_ANALYTICS="true",
               DART_SUPPRESS_ANALYTICS="true", FLUTTER_SKIP_UPDATE_CHECK="true", GIT_CONFIG_NOSYSTEM="1",
               GIT_CONFIG_GLOBAL=str(root / "home/.gitconfig"), GIT_OPTIONAL_LOCKS="0", GIT_TERMINAL_PROMPT="0",
               ELITESYNC_PRIVATE_TASK_ROOT=str(root))
    env["PATH"] = ";".join(str(root / p) for p in ["flutter_private/bin/cache/dart-sdk/bin", "flutter_private/bin/mingit/cmd", "os_tools"])
    return env


def normalize_environment(environment, root):
    result = {}
    for key, value in environment.items():
        name = key.upper()
        require(name not in result, "DUPLICATE_ENVIRONMENT_KEY")
        result[name] = value
    for key in ["HOME", "USERPROFILE", "TEMP", "TMP", "TMPDIR", "APPDATA", "LOCALAPPDATA", "PUB_CACHE", "FLUTTER_ROOT"]:
        path_in_root(result[key], root)
    for value in result["PATH"].split(";"):
        path_in_root(value, root)
    return result


def execute(root, grant, pins, action="widget", launcher=None):
    validate_pins(pins)
    plan, entries = recover(root)
    grant_check(grant, plan["sha256"], "execute", pins)
    require(grant["task_id"] == plan["task_id"], "TASK_ID_MISMATCH")
    require(action in ("widget", "analyze"), "EXECUTION_ACTION_REJECTED")
    require(grant.get("runtime_qualification_sha256") and grant.get("runtime_qualification_file"), "RUNTIME_QUALIFICATION_REQUIRED")
    target = private_path(root)
    proof_file = private_path(grant["runtime_qualification_file"])
    require(within(proof_file, target), "RUNTIME_PROOF_OUTSIDE_TASK")
    proof_bytes = proof_file.read_bytes()
    require(digest(proof_bytes) == grant["runtime_qualification_sha256"], "RUNTIME_PROOF_CHANGED")
    proof = json.loads(proof_bytes)
    require(proof.get("plan_sha256") == plan["sha256"] and proof.get("write_closure_qualified") is True
            and proof.get("process_guard_qualified") is True and proof.get("new_owner_scope_verified") is True,
            "RUNTIME_QUALIFICATION_REJECTED")
    require(launcher is not None or os.name == "nt", "WINDOWS_RUNTIME_REQUIRED")
    with Ledger(target) as ledger:
        # Re-read under exclusive lock. A failed/uncertain Popen consumes its reservation.
        plan, entries = recover(target)
        used = sum(e["event"] == "RUNTIME_PREPARE" for e in entries)
        require(used < grant["runtime_batches"], "RUNTIME_BUDGET_EXHAUSTED")
        space(target, plan["max_logical"], plan["max_allocated"])
        roles = plan["roles"]
        cfg = target / roles["tools_resolver"]
        app = target / "source/apps/flutter_elitesync_module"
        command = [str(target / roles["dart"]), "--packages=" + str(cfg), str(target / roles["flutter_entry"]),
                   "--suppress-analytics", "--no-version-check"]
        command += (["test", "--no-pub", "--reporter", "json", "--concurrency", "1", *pins["tests"]] if action == "widget"
                    else ["analyze", "--no-pub", "--no-suggestions", *pins["tests"]])
        for name in ("home", "tmp", "appdata", "localappdata", "logs"):
            (target / name).mkdir(exist_ok=True)
        op = uuid.uuid4().hex
        env = normalize_environment(private_environment(target, os.environ.get("SystemRoot", "")), target)
        ledger.append("RUNTIME_PREPARE", operation=op, batch=used + 1, limit=grant["runtime_batches"], action=action,
                      command_sha256=digest(json.dumps(command).encode()))
        try:
            result = (launcher or windows_launch)(command, app, env, target, plan, proof, op, ledger)
        except BaseException:
            # No retry/reallocation when exit or process state is uncertain.
            ledger.append("RUNTIME_UNCERTAIN", operation=op)
            raise
        ledger.append("RUNTIME_ENDED", operation=op, exit=result["exit"], **{k: v for k, v in result.items() if k != "exit"})
        return dict(state="RUNTIME_RECEIPT_NOT_ACCEPTANCE", remaining=grant["runtime_batches"] - used - 1, **result)


def windows_launch(command, cwd, env, root, plan, proof, operation, ledger):
    """Windows only; fixed argv, suspended initial process, kill-on-close Job.

    Deliberately untested in the zero-runtime tooling task. Sampling is not an OS sandbox.
    """
    import ctypes
    import subprocess
    require(os.name == "nt", "WINDOWS_RUNTIME_REQUIRED")
    require(Path(command[0]).name.lower() == "dart.exe", "SHELL_OR_UNKNOWN_EXECUTABLE")
    allowed = {private_path(root / plan["roles"][r]) for r in ("dart", "dart_vm", "engine", "git", "where")}
    host = private_path(Path(env["SYSTEMROOT"]) / "System32/conhost.exe")
    require(digest(host.read_bytes()) == proof.get("os_conhost_sha256"), "OS_HOST_HASH_MISSING_OR_CHANGED")
    k = ctypes.WinDLL("kernel32", use_last_error=True)
    class Basic(ctypes.Structure):
        _fields_ = [("a", ctypes.c_int64), ("b", ctypes.c_int64), ("flags", ctypes.c_uint32),
                    ("min", ctypes.c_size_t), ("max", ctypes.c_size_t), ("count", ctypes.c_uint32),
                    ("affinity", ctypes.c_size_t), ("priority", ctypes.c_uint32), ("schedule", ctypes.c_uint32)]
    class Extended(ctypes.Structure):
        _fields_ = [("basic", Basic), ("io", ctypes.c_uint64 * 6), ("memory", ctypes.c_size_t * 4)]
    k.CreateJobObjectW.argtypes = [ctypes.c_void_p, ctypes.c_wchar_p]; k.CreateJobObjectW.restype = ctypes.c_void_p
    k.SetInformationJobObject.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint32]
    k.AssignProcessToJobObject.argtypes = [ctypes.c_void_p, ctypes.c_void_p]
    k.QueryInformationJobObject.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint32, ctypes.c_void_p]
    k.OpenProcess.argtypes = [ctypes.c_uint32, ctypes.c_int, ctypes.c_uint32]; k.OpenProcess.restype = ctypes.c_void_p
    k.QueryFullProcessImageNameW.argtypes = [ctypes.c_void_p, ctypes.c_uint32, ctypes.c_wchar_p, ctypes.POINTER(ctypes.c_uint32)]
    k.CloseHandle.argtypes = [ctypes.c_void_p]
    job = k.CreateJobObjectW(None, None); require(bool(job), "JOB_CREATE_FAILED")
    process = None
    out, err = root / ("logs/" + operation + ".stdout"), root / ("logs/" + operation + ".stderr")
    try:
        limit = Extended(); limit.basic.flags = 0x2000
        require(k.SetInformationJobObject(job, 9, ctypes.byref(limit), ctypes.sizeof(limit)), "JOB_LIMIT_FAILED")
        with out.open("xb") as a, err.open("xb") as b:
            process = subprocess.Popen(command, shell=False, cwd=cwd, env=env, stdin=subprocess.DEVNULL,
                                       stdout=a, stderr=b, creationflags=0x08000004)
            require(k.AssignProcessToJobObject(job, ctypes.c_void_p(int(process._handle))), "JOB_ASSIGN_FAILED")
            nt = ctypes.WinDLL("ntdll"); nt.NtResumeProcess.argtypes = [ctypes.c_void_p]
            require(nt.NtResumeProcess(ctypes.c_void_p(int(process._handle))) == 0, "PROCESS_RESUME_FAILED")
            ledger.append("RUNTIME_STARTED", operation=operation, pid=process.pid)
            deadline, next_space = time.monotonic() + 600, 0
            seen = set()
            while process.poll() is None:
                buffer = ctypes.create_string_buffer(32768)
                require(k.QueryInformationJobObject(job, 3, buffer, len(buffer), None), "JOB_QUERY_FAILED")
                count = ctypes.c_uint32.from_buffer(buffer, 4).value
                for pid in (ctypes.c_size_t * count).from_buffer(buffer, 8):
                    if pid in seen:
                        continue
                    handle = k.OpenProcess(0x1000, False, pid)
                    require(bool(handle), "CHILD_IDENTITY_UNAVAILABLE")
                    try:
                        image = ctypes.create_unicode_buffer(32768); size = ctypes.c_uint32(len(image))
                        require(k.QueryFullProcessImageNameW(handle, 0, image, ctypes.byref(size)), "CHILD_IMAGE_UNAVAILABLE")
                        p = private_path(image.value)
                        require(p.name.lower() not in SHELLS and p in allowed | {host}, "FORBIDDEN_CHILD")
                        ledger.append("CHILD_OBSERVED", operation=operation, pid=pid, image_sha256=digest(p.read_bytes()))
                        seen.add(pid)
                    finally:
                        k.CloseHandle(handle)
                require(time.monotonic() < deadline, "RUNTIME_TIMEOUT_NO_REFUND")
                if time.monotonic() >= next_space:
                    space(root, plan["max_logical"], plan["max_allocated"]); next_space = time.monotonic() + 5
                time.sleep(0.01)
            code = process.returncode
    finally:
        if process is not None and process.poll() is None:
            process.kill(); process.wait()
        k.CloseHandle(job)
    return dict(exit=code, stdout_sha256=digest(out.read_bytes()), stderr_sha256=digest(err.read_bytes()),
                classification="PROCESS_EXIT_ZERO_TEST_RESULTS_UNVERIFIED" if code == 0 else "RUNTIME_FAILED")
