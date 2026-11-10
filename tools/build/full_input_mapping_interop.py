"""Corrected source candidate only; a fresh explicit scope grant is required.

Consumed controllers, contracts and STOP records remain untouched. The guest
fixture changes only its scope literal; host observation/cleanup uses the tested
primitive JSON projection and corrected, SHA-bound template.
"""
import builtins
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
import types

import full_input_mapping_lifecycle as consumed
import sandbox_host_observation as observation


HERE = Path(__file__).resolve().parent
PARENT = Path.home() / 'EliteSyncDev'
PREDECESSOR = PARENT / consumed.SCOPE
SCOPE = 'v1015-full-input-mapping-interop-recheck-20261104'
ROOT = PARENT / SCOPE
SOURCES = PARENT / 'v1015-full-input-mapping-interop-sources-20261104'


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def expected_sources():
    py = consumed._safe_bytes(HERE / 'full_input_mapping_probe.py', consumed.BASE_PY_SHA)
    cs = consumed._safe_bytes(HERE / 'full_input_mapping_probe.cs', consumed.BASE_CS_SHA)
    marker = consumed.OLD_SCOPE.encode()
    if py.count(marker) != 1 or cs.count(marker) != 1:
        raise ValueError('unique immutable baseline scope required')
    files = {'full_input_mapping_probe.py': py.replace(marker, SCOPE.encode(), 1),
             'full_input_mapping_probe.cs': cs.replace(marker, SCOPE.encode(), 1)}
    files.update({name: consumed._safe_bytes(HERE / name, digest) for name, digest in consumed.HELPERS.items()})
    return files


def checked_sources():
    files = expected_sources()
    for name, expected in files.items():
        if consumed._safe_bytes(SOURCES / name) != expected:
            raise ValueError('generated source closure differs before execution')
    return files


def load_base():
    files = checked_sources()  # no generated code is executed before this check
    helpers = {}
    for name in ['current_product_apk_inventory', 'current_product_build_plan']:
        module = types.ModuleType(name)
        module.__file__ = str(SOURCES / (name + '.py'))
        exec(compile(files[name + '.py'], module.__file__, 'exec'), module.__dict__)
        helpers[name] = module
    original_import = builtins.__import__
    def bound_import(name, globals=None, locals=None, fromlist=(), level=0):
        return helpers[name] if level == 0 and name in helpers else original_import(name, globals, locals, fromlist, level)
    base = types.ModuleType('_elitesync_mapping_interop_base')
    base.__file__ = str(SOURCES / 'full_input_mapping_probe.py')
    base.__dict__['__builtins__'] = {**vars(builtins), '__import__': bound_import}
    exec(compile(files['full_input_mapping_probe.py'], base.__file__, 'exec'), base.__dict__)
    return base


def pin_paths():
    return {str(path) for path in [Path(__file__), Path(observation.__file__), Path(consumed.__file__),
        Path(observation.original_cleanup.__file__),
        *(HERE / name for name in ['full_input_mapping_probe.py', 'full_input_mapping_probe.cs', *consumed.HELPERS]),
        *(SOURCES / name for name in ['full_input_mapping_probe.py', 'full_input_mapping_probe.cs', *consumed.HELPERS]),
        *(PREDECESSOR / name for name in ['manifest.json', 'launch.claim.json', 'engineering-outcome-private.json', 'post-stop-evidence-recovery-private.json'])]}


def prepare():
    old = json.loads((PREDECESSOR / 'engineering-outcome-private.json').read_bytes())
    recovered = json.loads((PREDECESSOR / 'post-stop-evidence-recovery-private.json').read_bytes())
    if (old.get('status') != 'LIFECYCLE_RECHECK_REJECTED_OR_STOPPED' or old.get('claim_consumed') != 1
            or old.get('remaining') != 0 or recovered.get('scope_STOP_unchanged') is not True
            or recovered.get('additional_VM_launches') != 0 or recovered.get('original_frozen_lifecycle_driver_qualified') is not False):
        raise ValueError('predecessor STOP/spent/recovery evidence must remain explicit')
    if ROOT.exists() or SOURCES.exists():
        raise FileExistsError('fixed candidate already exists; no automatic directory successor')
    files = expected_sources()
    SOURCES.mkdir()
    for name, raw in files.items():
        with (SOURCES / name).open('xb') as stream:
            stream.write(raw)
    base = load_base()
    mappings = json.loads((PREDECESSOR / 'manifest.json').read_bytes())['mappings']
    manifest = base.prepare(ROOT, mappings)
    contract = {'schema': 1, 'scope': SCOPE, 'status': 'SOURCE_READY_NOT_AUTHORIZED',
        'max_launches_proposed': 1, 'old_remaining': 0, 'predecessor': consumed.SCOPE,
        'readonly_roots': 273, 'anchor_reads': 275, 'access_denials': 2457, 'owned_write_roots': 2,
        'SDK_allowed': False, 'producer_allowed': False, 'device_media_allowed': False, 'G2': False,
        'source_pins': {path: sha(path) for path in sorted(pin_paths())}}
    base._write_once(ROOT / 'interop-contract-private.json', contract)
    return {'scope': SCOPE, 'status': contract['status'], 'manifest_sha256': sha(ROOT / 'manifest.json'),
            'binary_sha256': manifest['binary_sha256'], 'claim_created': False}


def validate_contract(contract):
    exact = {'schema': 1, 'scope': SCOPE, 'status': 'SOURCE_READY_NOT_AUTHORIZED',
        'max_launches_proposed': 1, 'old_remaining': 0, 'predecessor': consumed.SCOPE,
        'readonly_roots': 273, 'anchor_reads': 275, 'access_denials': 2457, 'owned_write_roots': 2,
        'SDK_allowed': False, 'producer_allowed': False, 'device_media_allowed': False, 'G2': False}
    if type(contract) is not dict or set(contract) != set(exact) | {'source_pins'}:
        raise ValueError('exact source-only candidate fields required')
    if any(type(contract[k]) is not type(v) or contract[k] != v for k, v in exact.items()):
        raise ValueError('source candidate policy drift')
    if type(contract['source_pins']) is not dict or set(contract['source_pins']) != pin_paths():
        raise ValueError('complete fixed source/evidence pin set required')


def frozen():
    contract = json.loads((ROOT / 'interop-contract-private.json').read_bytes())
    validate_contract(contract)
    if any(sha(path) != digest for path, digest in contract['source_pins'].items()):
        raise ValueError('candidate source or old evidence drift')
    base = load_base()
    return base, base.frozen(ROOT)


def launch(*, new_scope_authorized=False, owner_reference=''):
    if new_scope_authorized is not True or type(owner_reference) is not str or not owner_reference.strip():
        raise ValueError('a fresh explicit scope authorization is required; ordinary continue is not a budget')
    base, manifest = frozen()
    base._write_once(ROOT / 'interop-authorization-private.json', {'scope': SCOPE,
        'authorized': True, 'owner_reference': owner_reference, 'max_launches': 1,
        'SDK_allowed': False, 'producer_allowed': False, 'old_remaining': 0})
    return base.launch(ROOT, mapping_runtime_authorized=True)


def remaining(deadline):
    seconds = deadline - time.monotonic()
    if seconds <= 0:
        raise TimeoutError('host observation/cleanup/collection window exhausted')
    return seconds


def collect_before(deadline):
    code = 'import sys,json;sys.path.insert(0,sys.argv[1]);import full_input_mapping_interop as p;b,_=p.frozen();print(json.dumps(b.collect(p.ROOT)))'
    result = subprocess.run([sys.executable, '-B', '-c', code, str(HERE)], capture_output=True, timeout=remaining(deadline))
    if result.returncode:
        raise ValueError('bounded collector failed; keep diagnostics and spent claim')
    return json.loads(result.stdout.decode('utf-8-sig'))


def collect_lifecycle(base, manifest, launched, *, root, observer, closer, collector, deadline):
    """Exercise the whole host path; injections support no-VM interoperability tests."""
    root = Path(root)
    traces = root / 'host-observations'
    traces.mkdir()
    sequence = 0
    while remaining(deadline) > 0:
        result = root / 'output/result.json'
        if result.exists():
            if result.stat().st_size > 4 * 1024**2:
                raise ValueError('guest output exceeds fixed bound')
            json.loads(result.read_bytes())  # never promote failure/partial output here
            observed = observer(timeout_seconds=min(15, remaining(deadline)))
            base._write_once(traces / ('snapshot-%04d.json' % sequence), observed['rows'])
            (traces / ('snapshot-%04d.stdout' % sequence)).write_bytes(observed['stdout'])
            (traces / ('snapshot-%04d.stderr' % sequence)).write_bytes(observed['stderr'])
            sequence += 1
            rows = observed['rows']
            if not rows:
                return collector(deadline)
            if len(rows) == 2 and {row['Name'] for row in rows} == {'WindowsSandboxRemoteSession.exe', 'WindowsSandboxServer.exe'}:
                command = observation.render_corrected_cleanup(launched, rows, rows, str(root / 'qualification.wsb'))
                script = root / 'close-owned-host-session-corrected.ps1'
                with script.open('x', encoding='utf-8') as stream:
                    stream.write(command)
                closed = closer(script, min(30, remaining(deadline)))
                (root / 'cleanup.stdout').write_bytes(closed.stdout)
                (root / 'cleanup.stderr').write_bytes(closed.stderr)
                if closed.returncode:
                    raise ValueError('owned cleanup failed; no retry or broad process termination')
                after = observer(timeout_seconds=min(15, remaining(deadline)))
                base._write_once(root / 'host-processes-after-cleanup-private.json', after['rows'])
                if after['rows']:
                    raise ValueError('host process exit is not proven')
                return collector(deadline)
        time.sleep(min(2, remaining(deadline)))


def wait_and_collect():
    authorization = json.loads((ROOT / 'interop-authorization-private.json').read_bytes())
    if authorization.get('scope') != SCOPE or authorization.get('authorized') is not True:
        raise ValueError('this candidate has no new scope authorization')
    base, manifest = frozen()
    claim = json.loads((ROOT / 'launch.claim.json').read_bytes())
    launched = json.loads((ROOT / 'launched.json').read_bytes())
    if claim.get('scope') != SCOPE or claim.get('nonce') != manifest['nonce']:
        raise ValueError('fresh claim/manifest launch chain missing')
    def closer(script, timeout):
        return subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-File', str(script)],
                              capture_output=True, timeout=timeout)
    return collect_lifecycle(base, manifest, launched, root=ROOT, observer=observation.observe,
        closer=closer, collector=collect_before, deadline=time.monotonic() + base.LIMITS['host_wait_seconds'])
