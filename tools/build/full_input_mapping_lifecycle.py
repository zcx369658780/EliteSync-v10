"""Prepare a NEW lifecycle recheck; launch stays closed pending a new scope grant.

The consumed base controller and STOP evidence are read-only. Generated copies
change only their scope literal. The new driver adds exact host-session cleanup
after the guest returns; no SDK/Gradle/producer action is introduced.
"""
import hashlib
import builtins
import json
import os
from pathlib import Path
import re
import shutil
import stat
import subprocess
import sys
import time
import types

import sandbox_owned_session_cleanup as cleanup

HERE = Path(__file__).resolve().parent
OLD_SCOPE = 'v1015-full-input-mapping-qualification-20261104'
SCOPE = 'v1015-full-input-mapping-lifecycle-recheck-20261104'
PARENT = Path.home() / 'EliteSyncDev'
ROOT = PARENT / SCOPE
SOURCES = PARENT / 'v1015-full-input-mapping-lifecycle-candidate-20261104'
BASE_PY_SHA = '78485d6550e5c86e6e242ea5480b3df878ac7d0ba227d0c77def43771b40ccdb'
BASE_CS_SHA = 'c0e22cbdf7ee90b57eed7c34d43734116797c170d66655193dda4b2e9dc3359a'
HELPERS = {'current_product_apk_inventory.py': '267d2b1c39b203b519fb38656032bd010c60cc827801728e4cbcf3597c69913d',
    'current_product_build_plan.py': '828b27721fcdfa567b96c5a89554106bfcb13104f95e5d19314fc3ab1805893d',
    'windows_sandbox_launch.ps1': '13e9339767e372a6c0df8622b20f5f5b1a18387233f1ef6e4b1b7f1a37c6bff3'}


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def generate_sources(base_py, base_cs):
    if hashlib.sha256(base_py).hexdigest() != BASE_PY_SHA or hashlib.sha256(base_cs).hexdigest() != BASE_CS_SHA:
        raise ValueError('consumed base source identity differs')
    marker = OLD_SCOPE.encode()
    if base_py.count(marker) != 1 or base_cs.count(marker) != 1:
        raise ValueError('scope substitution must be exact and unique')
    return base_py.replace(marker, SCOPE.encode(), 1), base_cs.replace(marker, SCOPE.encode(), 1)


def _safe_bytes(path, expected=None):
    path = Path(path)
    for parent in (*reversed(path.parents), path):
        info = os.lstat(parent)
        if stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
            raise ValueError('redirected source closure')
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > 2 * 1024**2:
        raise ValueError('source shape/byte bound')
    with path.open('rb') as stream:
        before = os.fstat(stream.fileno())
        raw = stream.read(2 * 1024**2 + 1)
        after = os.fstat(stream.fileno())
    current = os.lstat(path)
    identity = lambda s: (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_nlink)
    if identity(info) != identity(before) or identity(before) != identity(after) or identity(after) != identity(current) or len(raw) != before.st_size:
        raise ValueError('source file drifted while reading')
    if expected is not None and hashlib.sha256(raw).hexdigest() != expected:
        raise ValueError('source closure identity differs')
    return raw


def _checked_sources():
    py, cs = generate_sources(_safe_bytes(HERE / 'full_input_mapping_probe.py', BASE_PY_SHA),
                              _safe_bytes(HERE / 'full_input_mapping_probe.cs', BASE_CS_SHA))
    expected = {'full_input_mapping_probe.py': py, 'full_input_mapping_probe.cs': cs}
    for name, digest in HELPERS.items():
        expected[name] = _safe_bytes(HERE / name, digest)
    for name, raw in expected.items():
        if _safe_bytes(SOURCES / name) != raw:
            raise ValueError('generated source closure changed before execution')
    return expected


def _execute_sources(contents):
    # Compile exactly the bytes already checked above, not a pyc or a module
    # discovered through sys.path/sys.modules. Bare helper imports are bound
    # to these two verified, isolated module objects.
    dependencies = {}
    for name in ['current_product_apk_inventory', 'current_product_build_plan']:
        module = types.ModuleType(name)
        module.__file__ = str(SOURCES / (name + '.py'))
        exec(compile(contents[name + '.py'], module.__file__, 'exec'), module.__dict__)
        dependencies[name] = module
    original_import = builtins.__import__
    def bound_import(name, globals=None, locals=None, fromlist=(), level=0):
        return dependencies[name] if level == 0 and name in dependencies else original_import(name, globals, locals, fromlist, level)
    module = types.ModuleType('_elitesync_mapping_lifecycle_base')
    module.__file__ = str(SOURCES / 'full_input_mapping_probe.py')
    module.__dict__['__builtins__'] = {**vars(builtins), '__import__': bound_import}
    exec(compile(contents['full_input_mapping_probe.py'], module.__file__, 'exec'), module.__dict__)
    return module


def _load_base():
    return _execute_sources(_checked_sources())


def required_pins():
    old = PARENT / OLD_SCOPE
    return {str(path) for path in [Path(__file__), Path(cleanup.__file__), old / 'launch.claim.json',
        old / 'manifest.json', old / 'engineering-outcome-private.json', old / 'owned-host-cleanup-after-stop-private.json',
        *(SOURCES / name for name in ['full_input_mapping_probe.py', 'full_input_mapping_probe.cs', *HELPERS])]}


def validate_contract(contract):
    expected = {'scope': SCOPE, 'status': 'PROPOSED_NOT_AUTHORIZED', 'max_launches': 1,
        'owner_scope_grant_pending': True, 'old_scope': OLD_SCOPE, 'old_remaining': 0,
        'readonly_roots': 273, 'read_anchors': 275, 'readonly_access_checks': 2457, 'owned_write_roots': 2,
        'host_lifecycle_change': 'EXACT_CONFIG_PARENT_BIRTH_AND_HELD_HANDLE_PAIR_CLEANUP',
        'SDK_allowed': False, 'producer_allowed': False, 'device_media_allowed': False, 'G2': False}
    if type(contract) is not dict or set(contract) != set(expected) | {'source_pins'}:
        raise ValueError('exact lifecycle contract fields required')
    if any(type(contract[k]) is not type(v) or contract[k] != v for k, v in expected.items()):
        raise ValueError('lifecycle contract drift')
    if type(contract['source_pins']) is not dict or set(contract['source_pins']) != required_pins():
        raise ValueError('complete independent driver/source/evidence pins required')
    if any(type(value) is not str or not re.fullmatch('[0-9a-f]{64}', value) for value in contract['source_pins'].values()):
        raise ValueError('exact source/evidence digests required')


def prepare():
    old = PARENT / OLD_SCOPE
    original = json.loads((old / 'manifest.json').read_bytes())
    outcome = json.loads((old / 'engineering-outcome-private.json').read_bytes())
    cleaned = json.loads((old / 'owned-host-cleanup-after-stop-private.json').read_bytes())
    if (outcome.get('status') != 'MAPPING_QUALIFICATION_REJECTED_OR_STOPPED'
            or outcome.get('claim_consumed') != 1 or outcome.get('remaining') != 0
            or cleaned.get('sandbox_processes_absent') is not True):
        raise ValueError('old STOP, spent claim and separate cleanup must be preserved')
    base_py = (HERE / 'full_input_mapping_probe.py').read_bytes()
    base_cs = (HERE / 'full_input_mapping_probe.cs').read_bytes()
    generated_py, generated_cs = generate_sources(base_py, base_cs)
    SOURCES.mkdir()
    for name, data in [('full_input_mapping_probe.py', generated_py), ('full_input_mapping_probe.cs', generated_cs)]:
        with (SOURCES / name).open('xb') as stream:
            stream.write(data)
    for name in ['current_product_apk_inventory.py', 'current_product_build_plan.py', 'windows_sandbox_launch.ps1']:
        source = HERE / name
        if sha(source) != original['source_pins'][str(source)]:
            raise ValueError('base helper identity changed')
        shutil.copyfile(source, SOURCES / name)
    base = _load_base()
    manifest = base.prepare(ROOT, original['mappings'])
    contract = {'scope': SCOPE, 'status': 'PROPOSED_NOT_AUTHORIZED', 'max_launches': 1,
        'owner_scope_grant_pending': True, 'old_scope': OLD_SCOPE, 'old_remaining': 0,
        'source_pins': {path: sha(path) for path in sorted(required_pins())},
        'readonly_roots': 273, 'read_anchors': 275, 'readonly_access_checks': 2457,
        'owned_write_roots': 2, 'host_lifecycle_change': 'EXACT_CONFIG_PARENT_BIRTH_AND_HELD_HANDLE_PAIR_CLEANUP',
        'SDK_allowed': False, 'producer_allowed': False, 'device_media_allowed': False, 'G2': False}
    base._write_once(ROOT / 'lifecycle-contract-private.json', contract)
    return {'scope': SCOPE, 'status': contract['status'], 'manifest_sha256': sha(ROOT / 'manifest.json'),
            'binary_sha256': manifest['binary_sha256'], 'claim_created': False}


def frozen():
    contract = json.loads((ROOT / 'lifecycle-contract-private.json').read_bytes())
    validate_contract(contract)
    if any(sha(path) != digest for path, digest in contract['source_pins'].items()):
        raise ValueError('driver/cleanup/old evidence drift')
    base = _load_base()
    return base, base.frozen(ROOT)


def launch(*, new_scope_authorized=False, owner_reference=''):
    if new_scope_authorized is not True or type(owner_reference) is not str or not owner_reference.strip():
        raise ValueError('a NEW explicit scope grant is required; the consumed case is not reusable')
    base, manifest = frozen()
    base._write_once(ROOT / 'new-scope-authorization-private.json', {
        'scope': SCOPE, 'owner_reference': owner_reference, 'new_scope_authorized': True,
        'old_scope_remaining': 0, 'max_launches': 1, 'SDK_allowed': False, 'producer_allowed': False})
    return base.launch(ROOT, mapping_runtime_authorized=True)


def _remaining(deadline):
    remaining = deadline - time.monotonic()
    if remaining <= 0:
        raise TimeoutError('lifecycle host collection deadline reached')
    return remaining


def _collect_before(deadline):
    # Keep the synchronous legacy collector inside a separately bounded,
    # read-only Python collector process. A timeout never kills a Sandbox by name.
    code = 'import sys,json;sys.path.insert(0,sys.argv[1]);import full_input_mapping_lifecycle as p;b,_=p.frozen();print(json.dumps(b.collect(p.ROOT)))'
    result = subprocess.run([sys.executable, '-B', '-c', code, str(HERE)], capture_output=True,
                            timeout=_remaining(deadline))
    if result.returncode:
        raise ValueError('bounded collector failed; retain its STOP and claim')
    return json.loads(result.stdout.decode('utf-8-sig'))


def wait_and_collect():
    authorization = json.loads((ROOT / 'new-scope-authorization-private.json').read_bytes())
    if authorization.get('new_scope_authorized') is not True or authorization.get('scope') != SCOPE:
        raise ValueError('new authorization chain missing')
    base, manifest = frozen()
    launched = json.loads((ROOT / 'launched.json').read_bytes())
    deadline = time.monotonic() + base.LIMITS['host_wait_seconds']
    while time.monotonic() < deadline:
        result = ROOT / 'output/result.json'
        if result.exists() and result.stat().st_size <= 4 * 1024**2:
            # A failed fixture also needs its owned host pair closed. Receipt
            # policy is checked by collect AFTER cleanup, never upgraded here.
            json.loads(result.read_bytes())
            observed = subprocess.run(['pwsh', '-NoProfile', '-Command',
                "$p=@(Get-CimInstance Win32_Process -Filter \"Name='WindowsSandbox.exe' OR Name='WindowsSandboxClient.exe' OR Name='WindowsSandboxRemoteSession.exe' OR Name='WindowsSandboxServer.exe'\"); ConvertTo-Json -InputObject $p -Depth 4 -Compress"],
                capture_output=True, timeout=min(15, _remaining(deadline)))
            if observed.returncode:
                raise ValueError('cannot observe host ownership; no termination')
            snapshot = json.loads(observed.stdout.decode('utf-8-sig'))
            if snapshot is None:
                snapshot = []
            if not snapshot:
                return _collect_before(deadline)
            if len(snapshot) == 2 and {row['Name'] for row in snapshot} == {'WindowsSandboxRemoteSession.exe', 'WindowsSandboxServer.exe'}:
                # A current, exact two-process snapshot becomes the immutable
                # recorded input; the rendered command takes a second snapshot.
                command = cleanup.render_cleanup(launched, snapshot, snapshot, str(ROOT / 'qualification.wsb'))
                base._write_once(ROOT / 'owned-host-pair-before-cleanup-private.json', snapshot)
                script = ROOT / 'close-owned-host-session.ps1'
                with script.open('x', encoding='utf-8') as stream:
                    stream.write(command)
                closed = subprocess.run(['pwsh', '-NoProfile', '-File', str(script)], capture_output=True, timeout=min(30, _remaining(deadline)))
                (ROOT / 'cleanup.stdout').write_bytes(closed.stdout)
                (ROOT / 'cleanup.stderr').write_bytes(closed.stderr)
                if closed.returncode:
                    raise ValueError('owned host cleanup failed; no retry or unrelated process termination')
                return _collect_before(deadline)
        time.sleep(min(2, _remaining(deadline)))
    raise TimeoutError('new lifecycle case stopped; claim spent, no automatic successor')
