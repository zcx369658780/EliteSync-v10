"""One proposed CMake-version case; preparation is not SDK/VM authorization."""
import ast
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path, PureWindowsPath
import re
import subprocess
import time
import uuid
import xml.etree.ElementTree as ET

import current_product_apk_inventory as inventory
import current_product_build_plan as paths
import native_role_executor as core
import sandbox_host_observation as observation


HERE = Path(__file__).resolve().parent
SCOPE = 'v1015-native-cmake-version-qualification-20261105'
ROOT = Path.home() / 'EliteSyncDev' / SCOPE
READSET = Path.home() / 'EliteSyncDev/v1015-native-static-imports-20261104/candidate-native-readset-private.json'
READSET_SHA = 'b243c9d7b46fe7753b09b85e04d4c10b40e78e34fe6f03bd62a7ff7ce04b94e2'
INTEROP_SHA = 'd4af38893301dfb2a9c5a7a13c88d744a6ec0e9a90932cf53eaad33c4c8c48fb'
ROLE = 'cmake'
LIMITS = {'memory_mb': 2048, 'guest_seconds': 90, 'host_seconds': 180, 'stop_cleanup_seconds': 45,
          'input_files': 42, 'input_bytes': 512 * 1024**2, 'output_bytes': 64 * 1024**2}


def safe_bytes(path, cap):
    path = Path(path)
    before = inventory._checked_stat(path); inventory._regular(before)
    if before.st_size > cap:
        raise ValueError('file exceeds fixed read cap')
    with path.open('rb') as stream:
        opened = os.fstat(stream.fileno())
        raw = stream.read(cap + 1)
        after = os.fstat(stream.fileno())
    current = inventory._checked_stat(path)
    for info in (opened, after, current):
        inventory._regular(info)
    if (len(raw) != before.st_size or len(raw) > cap
            or any(inventory._identity(s) != inventory._identity(before) for s in (opened, after, current))):
        raise ValueError('read identity changed')
    return raw


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode_json(raw):
    def pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError('duplicate JSON key')
            result[key] = value
        return result
    def constant(value):
        raise ValueError('non-finite JSON value')
    return json.loads(raw, object_pairs_hook=pairs, parse_constant=constant)


def write_once(path, value):
    with Path(path).open('x', encoding='utf-8', newline='\n') as stream:
        json.dump(value, stream, sort_keys=True, indent=2)
        stream.flush(); os.fsync(stream.fileno())


def sources():
    names = ['native_role_host.py', 'native_role_executor.py', 'native_role_logs.py',
             'native_role_guest_lifecycle.cs', 'windows_sandbox_native_tool_probe.cs',
             'current_product_apk_inventory.py', 'current_product_build_plan.py',
             'sandbox_host_observation.py', 'sandbox_owned_session_cleanup.py',
             'full_input_mapping_interop.py', 'windows_sandbox_launch.ps1']
    return {str(HERE / name): sha(safe_bytes(HERE / name, 2 * 1024**2)) for name in names}


def readset():
    raw = safe_bytes(READSET, 16 * 1024**2)
    if sha(raw) != READSET_SHA:
        raise ValueError('fixed native readset differs')
    graph = decode_json(raw)
    pins = core.input_pins(graph)
    rows = [r for r in graph['images'] if r['role'] != 'AGP_aapt2_archive_entry']
    if len(rows) != LIMITS['input_files']:
        raise ValueError('complete 42 PE inputs required')
    mappings = {}
    for row in rows:
        host = Path(row['path'])
        relative = row['relative_path'].split('/')
        root = host
        for _ in relative:
            root = root.parent
        if root.joinpath(*relative) != host:
            raise ValueError('input host path differs from relative root')
        mapping = {'host': str(root), 'guest': core.ROOTS[row['role']], 'readonly': True}
        if row['role'] in mappings and mappings[row['role']] != mapping:
            raise ValueError('ambiguous input root')
        mappings[row['role']] = mapping
    hosts = [paths._path(m['host']) for m in mappings.values()]
    if any(a.is_relative_to(b) or b.is_relative_to(a) for i, a in enumerate(hosts) for b in hosts[:i]):
        raise ValueError('overlapping readonly input roots')
    found = inventory.inventory_files([(r['role'], r['path']) for r in rows],
        [m['host'] for m in mappings.values()], LIMITS['input_files'], LIMITS['input_bytes'])
    for expected, actual in zip(rows, found['files']):
        if any(expected[k] != actual[k] for k in ('role', 'path', 'bytes', 'sha256', 'file_id')):
            raise ValueError('bound native input changed')
    return graph, pins, mappings


def guest_source(pins, nonce):
    if type(nonce) is not str or not re.fullmatch('[a-f0-9]{32}', nonce):
        raise ValueError('compile-bound candidate nonce required')
    source = core.generate_source(safe_bytes(HERE / 'windows_sandbox_native_tool_probe.cs', 1024**2), pins)
    old = b'    static int Main(string[] args) {'
    if source.count(old) != 1:
        raise ValueError('unique core Main required')
    wrapper = safe_bytes(HERE / 'native_role_guest_lifecycle.cs', 1024**2)
    if wrapper.count(b'__EXPECTED_NONCE__') != 1:
        raise ValueError('unique guest binding nonce anchor required')
    replacements = {
        old: b'    internal static int RunNativeRole(string[] args) {',
        b'Child root=new Child();var known=': b'Child root=new Child();long rootBirth=0;var known=',
        b'known.Add(root.pid,new Bound{pid=root.pid,handle=root.process,birth=Birth(root.process)});':
            b'rootBirth=Birth(root.process);known.Add(root.pid,new Bound{pid=root.pid,handle=root.process,birth=rootBirth});',
        b'return new {root_pid=root.pid,root_exit=exit,': b'return new {root_pid=root.pid,root_birth=rootBirth,root_exit=exit,'}
    for before, after in replacements.items():
        if source.count(before) != 1:
            raise ValueError('unique held-root identity derivation anchor required')
        source = source.replace(before, after, 1)
    return source + b'\n' + wrapper.replace(b'__EXPECTED_NONCE__', nonce.encode())


def configuration(mappings, nonce):
    if set(mappings) != set(core.ROOTS) or not re.fullmatch('[a-f0-9]{32}', nonce):
        raise ValueError('exact input roles and nonce required')
    host_roots, guest_roots = [], []
    for role, mapping in mappings.items():
        if set(mapping) != {'host', 'guest', 'readonly'} or mapping['readonly'] is not True or mapping['guest'] != core.ROOTS[role]:
            raise ValueError('exact readonly guest role mapping required')
        host, guest = paths._path(mapping['host']), paths._path(mapping['guest'])
        case = PureWindowsPath(ROOT)
        if host.is_relative_to(case) or case.is_relative_to(host):
            raise ValueError('input overlaps independent case')
        if any(host.is_relative_to(other) or other.is_relative_to(host) for other in host_roots):
            raise ValueError('overlapping host mappings')
        if any(guest.is_relative_to(other) or other.is_relative_to(guest) for other in guest_roots):
            raise ValueError('overlapping guest mappings')
        host_roots.append(host); guest_roots.append(guest)
    root = ET.Element('Configuration')
    for key, value in [('VGpu', 'Disable'), ('Networking', 'Disable'), ('AudioInput', 'Disable'),
                       ('VideoInput', 'Disable'), ('ClipboardRedirection', 'Disable'),
                       ('PrinterRedirection', 'Disable'), ('MemoryInMB', '2048')]:
        ET.SubElement(root, key).text = value
    folders = ET.SubElement(root, 'MappedFolders')
    entries = list(mappings.values()) + [
        {'host': str(ROOT / 'probe'), 'guest': r'C:\Probe', 'readonly': True},
        {'host': str(ROOT / 'output'), 'guest': r'C:\ProbeOutput', 'readonly': False}]
    for row in entries:
        folder = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', row['host']), ('SandboxFolder', row['guest']),
                           ('ReadOnly', str(row['readonly']).lower())]:
            ET.SubElement(folder, key).text = value
    ET.SubElement(ET.SubElement(root, 'LogonCommand'), 'Command').text = r'C:\Probe\NativeRoleProbe.exe ' + nonce
    return ET.tostring(root, encoding='unicode') + '\n'


def policy():
    return {'schema': 1, 'scope': SCOPE, 'role': ROLE, 'status': 'SOURCE_READY_NOT_AUTHORIZED',
            'max_vm_launches_proposed': 1, 'max_sdk_roots_proposed': 1, 'limits': LIMITS,
            'readonly_preflight_file_denials': 252, 'readonly_preflight_directory_denials': 15,
            'producer_allowed': False, 'gradle_allowed': False, 'device_media_allowed': False, 'G2': False}


def same(left, right):
    return json.dumps(left, sort_keys=True) == json.dumps(right, sort_keys=True)


def authority_fields():
    return {'scope': SCOPE, 'role': ROLE, 'max_vm_launches': 1, 'max_sdk_roots': 1,
            'contract_sha256': sha(safe_bytes(ROOT / 'case-contract-private.json', 4 * 1024**2)),
            'limits': LIMITS, 'producer_allowed': False, 'gradle_allowed': False, 'G2': False}


def grant_record():
    grant = decode_json(safe_bytes(ROOT / 'owner-explicit-grant-private.json', 128 * 1024))
    expected = authority_fields()
    if (type(grant) is not dict or any(k not in grant or not same(grant[k], v) for k, v in expected.items())
            or type(grant.get('owner_reply')) is not str or not grant['owner_reply'].strip()):
        raise ValueError('grant does not bind this exact one-shot scope')
    return grant


def launch_chain(contract):
    grant_record()
    expected = {**authority_fields(), 'nonce': contract['manifest']['nonce'], 'refundable': False,
                'owner_grant_sha256': sha(safe_bytes(ROOT / 'owner-explicit-grant-private.json', 128 * 1024))}
    claim = decode_json(safe_bytes(ROOT / 'launch.claim.json', 128 * 1024))
    origin = claim.get('launch_origin') if type(claim) is dict else None
    validate_origin(origin)
    if not same(claim, {**expected, 'launch_origin': origin}):
        raise ValueError('exact nonrefundable one-shot claim required')
    active = decode_json(safe_bytes(ROOT / 'probe/manifest.json', 1024**2))
    if not same(active, {**contract['manifest'], 'runtime_authorized': True}):
        raise ValueError('authorized active manifest missing or changed')
    launched = decode_json(safe_bytes(ROOT / 'launched.json', 128 * 1024))
    if (type(launched) is not dict or set(launched) != {'pid', 'creationUtc', 'executable'}
            or type(launched['pid']) is not int or launched['pid'] <= 0
            or type(launched['executable']) is not str
            or launched['executable'].casefold() != str(Path(os.environ['SystemRoot']) / 'System32/WindowsSandbox.exe').casefold()):
        raise ValueError('exact launcher instance identity required')
    observation.original_cleanup._time(launched['creationUtc'])
    binding = {'scope': SCOPE, 'nonce': contract['manifest']['nonce'],
        'claim_sha256': sha(safe_bytes(ROOT / 'launch.claim.json', 128 * 1024)),
        'launched_sha256': sha(safe_bytes(ROOT / 'launched.json', 128 * 1024))}
    if not same(decode_json(safe_bytes(ROOT / 'launch-binding-private.json', 128 * 1024)), binding):
        raise ValueError('launch/immutable-origin binding differs')
    return launched


def validate_origin(origin):
    if (type(origin) is not dict or set(origin) != {'monotonic', 'utc'}
            or type(origin['monotonic']) is not float or not math.isfinite(origin['monotonic']) or origin['monotonic'] <= 0):
        raise ValueError('fixed launch clock origin required')
    observation.original_cleanup._time(origin['utc'])


def remaining_window(origin, monotonic_now, utc_now):
    validate_origin(origin)
    elapsed = [monotonic_now - origin['monotonic'],
               (utc_now - observation.original_cleanup._time(origin['utc'])).total_seconds()]
    if any(value < 0 or not math.isfinite(value) for value in elapsed):
        raise ValueError('clock rollback/reboot cannot renew scope')
    remaining = LIMITS['host_seconds'] - max(elapsed)
    if remaining <= 0:
        raise TimeoutError('original launch observation window is spent')
    return remaining


def prepare():
    if ROOT.exists():
        raise FileExistsError('fixed candidate exists; no reset or directory successor')
    _, pins, mappings = readset()
    nonce = uuid.uuid4().hex
    source = guest_source(pins, nonce)
    ROOT.mkdir()
    for child in ('probe', 'output', 'compile-temp'):
        (ROOT / child).mkdir()
    (ROOT / 'probe/NativeRoleProbe.cs').write_bytes(source)
    compiler = Path(os.environ['SystemRoot']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    check = subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-Command',
        "$s=Get-AuthenticodeSignature -LiteralPath '" + str(compiler).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"], capture_output=True, timeout=15)
    if check.returncode:
        raise ValueError('existing compiler signature rejected')
    env = {k: v for k, v in os.environ.items() if not k.upper().startswith(('COR_', 'CORECLR_', 'COMPLUS_'))
           and k.upper() not in {'LIB', 'DOTNET_STARTUP_HOOKS', 'DOTNET_ADDITIONAL_DEPS', 'DOTNET_SHARED_STORE'}}
    env['TEMP'] = env['TMP'] = str(ROOT / 'compile-temp')
    compiled = subprocess.run([str(compiler), '/nologo', '/noconfig', '/target:winexe', '/platform:x64',
        '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll', '/main:NativeRoleGuestWrapper',
        '/out:' + str(ROOT / 'probe/NativeRoleProbe.exe'), str(ROOT / 'probe/NativeRoleProbe.cs')],
        capture_output=True, timeout=30, cwd=ROOT, env=env)
    (ROOT / 'compiler.stdout').write_bytes(compiled.stdout); (ROOT / 'compiler.stderr').write_bytes(compiled.stderr)
    if compiled.returncode:
        raise ValueError('candidate compile failed, no runtime claim created')
    manifest = {**core.role_plan(ROLE, pins), 'nonce': nonce,
                'binary_sha256': sha(safe_bytes(ROOT / 'probe/NativeRoleProbe.exe', 4 * 1024**2))}
    write_once(ROOT / 'probe/manifest.locked.json', manifest)
    (ROOT / 'qualification.wsb').write_text(configuration(mappings, manifest['nonce']), encoding='utf-8', newline='\n')
    contract = {**policy(), 'source_pins': sources(), 'readset_sha256': READSET_SHA,
                'manifest': manifest, 'mappings': mappings,
                'source_sha256': sha(source), 'compiler_sha256': sha(safe_bytes(compiler, 8 * 1024**2))}
    write_once(ROOT / 'case-contract-private.json', contract)
    return {'status': contract['status'], 'scope': SCOPE, 'binary_sha256': manifest['binary_sha256'], 'claim_created': False}


def frozen():
    for path in (ROOT, ROOT / 'probe', ROOT / 'output', ROOT / 'compile-temp'):
        if not os.path.isdir(path):
            raise ValueError('fixed ordinary case directories required')
        inventory._checked_stat(path)
    contract = decode_json(safe_bytes(ROOT / 'case-contract-private.json', 4 * 1024**2))
    fields = set(policy()) | {'source_pins', 'readset_sha256', 'manifest', 'mappings', 'source_sha256', 'compiler_sha256'}
    if set(contract) != fields or any(not same(contract[k], v) for k, v in policy().items()):
        raise ValueError('exact frozen case policy required')
    if contract['source_pins'] != sources() or contract['readset_sha256'] != READSET_SHA:
        raise ValueError('source or readset identity drift')
    _, pins, mappings = readset()
    m = contract['manifest']
    if type(m.get('nonce')) is not str or not re.fullmatch('[a-f0-9]{32}', m['nonce']):
        raise ValueError('frozen nonce missing')
    expected = {**core.role_plan(ROLE, pins), 'nonce': m['nonce'],
                'binary_sha256': sha(safe_bytes(ROOT / 'probe/NativeRoleProbe.exe', 4 * 1024**2))}
    if json.dumps(m, sort_keys=True) != json.dumps(expected, sort_keys=True) or not same(mappings, contract['mappings']):
        raise ValueError('manifest or mapping drift')
    source = guest_source(pins, m['nonce'])
    if (safe_bytes(ROOT / 'probe/NativeRoleProbe.cs', 4 * 1024**2) != source
            or sha(source) != contract['source_sha256']
            or not same(decode_json(safe_bytes(ROOT / 'probe/manifest.locked.json', 1024**2)), m)
            or safe_bytes(ROOT / 'qualification.wsb', 1024**2).decode() != configuration(mappings, m['nonce'])):
        raise ValueError('generated closure differs')
    active = ROOT / 'probe/manifest.json'
    if active.exists():
        if not (ROOT / 'launch.claim.json').exists():
            raise ValueError('active manifest without one-shot claim')
        if not same(decode_json(safe_bytes(active, 1024**2)), {**m, 'runtime_authorized': True}):
            raise ValueError('active manifest differs from predeclared policy')
    return contract, pins


def launch(*, new_scope_authorized=False, owner_reference=''):
    if new_scope_authorized is not True or not owner_reference:
        raise ValueError('fresh explicit single CMake SDK/VM scope grant required')
    contract, _ = frozen()
    grant_record()
    expected = authority_fields()
    if owner_reference != str(ROOT / 'owner-explicit-grant-private.json'):
        raise ValueError('grant does not bind this exact one-shot scope')
    if any((ROOT / name).exists() for name in ('launch.claim.json', 'launched.json', 'probe/manifest.json')) or any((ROOT / 'output').iterdir()):
        raise ValueError('case is already spent or output is not empty')
    if observation.observe(timeout_seconds=15)['rows']:
        raise ValueError('pre-existing Sandbox; do not launch or terminate it')
    origin = {'monotonic': time.monotonic(), 'utc': datetime.now(timezone.utc).isoformat()}
    write_once(ROOT / 'launch.claim.json', {**expected, 'nonce': contract['manifest']['nonce'], 'refundable': False, 'launch_origin': origin,
                'owner_grant_sha256': sha(safe_bytes(ROOT / 'owner-explicit-grant-private.json', 128 * 1024))})
    write_once(ROOT / 'probe/manifest.json', {**contract['manifest'], 'runtime_authorized': True})
    result = subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-File', str(HERE / 'windows_sandbox_launch.ps1'),
                             '-ConfigPath', str(ROOT / 'qualification.wsb')], capture_output=True, timeout=30)
    (ROOT / 'launcher.stdout').write_bytes(result.stdout); (ROOT / 'launcher.stderr').write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError('single launch failed; claim spent, no retry')
    launched = decode_json(result.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or not launched.get('creationUtc'):
        raise ValueError('launcher identity missing; claim spent')
    write_once(ROOT / 'launched.json', launched)
    write_once(ROOT / 'launch-binding-private.json', {'scope': SCOPE, 'nonce': contract['manifest']['nonce'],
        'claim_sha256': sha(safe_bytes(ROOT / 'launch.claim.json', 128 * 1024)),
        'launched_sha256': sha(safe_bytes(ROOT / 'launched.json', 128 * 1024))})
    return launched


def lifecycle():
    # Reuse only two SHA-bound pure functions; never import/execute an old case.
    raw = safe_bytes(HERE / 'full_input_mapping_interop.py', 1024**2)
    if sha(raw) != INTEROP_SHA:
        raise ValueError('reviewed host lifecycle source differs')
    tree = ast.parse(raw)
    nodes = [n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in ('remaining', 'collect_lifecycle')]
    if len(nodes) != 2 or any(n.decorator_list for n in nodes):
        raise ValueError('exact pure lifecycle functions required')
    segments = '\n\n'.join(ast.get_source_segment(raw.decode(), node) for node in nodes)
    replacements = {
        "result = root / 'output/result.json'": "result = next((root / 'output' / name for name in ('result.json', 'guest-wrapper-failure.json', 'guest-watchdog.json') if (root / 'output' / name).exists()), root / 'output/result.json')",
        'if result.stat().st_size > 4 * 1024**2:': 'if len(safe_bytes(result, 4 * 1024**2)) > 4 * 1024**2:',
        'json.loads(result.read_bytes())': 'json.loads(safe_bytes(result, 4 * 1024**2))'}
    for old, new in replacements.items():
        if segments.count(old) != 1:
            raise ValueError('unique lifecycle adaptation anchor required')
        segments = segments.replace(old, new, 1)
    namespace = {'Path': Path, 'json': json, 'time': time, 'observation': observation, 'safe_bytes': safe_bytes}
    exec(compile(segments, str(HERE / 'full_input_mapping_interop.py'), 'exec'), namespace)
    return namespace['collect_lifecycle']


def collect():
    import native_role_logs
    contract, pins = frozen()
    launch_chain(contract)
    active = {**contract['manifest'], 'runtime_authorized': True}
    names = {'result.json', 'samples.jsonl', 'tool.stdout', 'tool.stderr', 'guest-preflight.json'}
    if {p.name for p in (ROOT / 'output').iterdir()} != names:
        raise ValueError('exact bounded output set required, including no watchdog marker')
    raw = {name: safe_bytes(ROOT / 'output' / name, 16 * 1024**2) for name in names}
    if sum(map(len, raw.values())) > LIMITS['output_bytes']:
        raise ValueError('aggregate output bound exceeded')
    receipt = decode_json(raw['result.json'])
    expected_preflight = {'kind': 'native-cmake-preflight', 'nonce': active['nonce'],
        'username': 'WDAGUtilityAccount', 'file_denials': 252, 'directory_denials': 15,
        'output_canary_write_read_delete': True, 'network_no_active_adapter': True, 'SDK_starts': 0, 'G2': False}
    if not same(decode_json(raw['guest-preflight.json']), expected_preflight):
        raise ValueError('guest readonly/network/owned-output preflight incomplete')
    root_birth = receipt.get('proof', {}).get('root_birth')
    if type(root_birth) is not int or root_birth <= 0:
        raise ValueError('held root process birth required')
    reduced = {**receipt, 'proof': {k: v for k, v in receipt['proof'].items() if k != 'root_birth'}}
    proof = core.validate_receipt(reduced, active, pins)
    logs = native_role_logs.validate_samples(raw['samples.jsonl'], receipt, active)
    lines = raw['tool.stdout'].decode('utf-8-sig').splitlines()
    if raw['tool.stderr'].strip() or not lines or lines[0] != 'cmake version 3.22.1':
        raise ValueError('expected CMake version output required')
    if observation.observe(timeout_seconds=15)['rows']:
        raise ValueError('Sandbox host processes remain; no acceptance')
    return {'status': 'CMAKE_VERSION_SAMPLED_LIFECYCLE_SUPPORTED', 'scope': SCOPE,
            'proof': proof, 'sample_log': logs, 'guest_preflight': expected_preflight,
            'raw_sha256': {name: sha(value) for name, value in raw.items()},
            'native_DLL_closure_proven': False, 'full_process_closure_proven': False,
            'background_vm_teardown': 'UNKNOWN', 'producer_allowed': False, 'G2': False}


def stop_cleanup(launched):
    """Separate bounded safety cleanup after STOP; never changes the verdict."""
    end = time.monotonic() + LIMITS['stop_cleanup_seconds']
    def left(cap):
        seconds = end - time.monotonic()
        if seconds <= 0:
            raise TimeoutError('STOP cleanup safety window spent')
        return min(cap, seconds)
    receipt = {'scope': SCOPE, 'qualification_stays_STOP': True, 'new_VM_or_SDK_starts': 0,
               'background_vm_teardown': 'UNKNOWN'}
    try:
        contract, _ = frozen()
        if not same(launch_chain(contract), launched):
            raise ValueError('STOP cleanup launch instance differs')
        before = observation.observe(timeout_seconds=left(15))
        write_once(ROOT / 'stop-cleanup-before-private.json', before['rows'])
        if not before['rows']:
            receipt['status'] = 'HOST_PROCESSES_ALREADY_ABSENT'
        elif (len(before['rows']) == 2 and {r['Name'] for r in before['rows']} ==
              {'WindowsSandboxRemoteSession.exe', 'WindowsSandboxServer.exe'}):
            command = observation.render_corrected_cleanup(launched, before['rows'], before['rows'], str(ROOT / 'qualification.wsb'))
            script = ROOT / 'stop-close-owned-host-session.ps1'
            with script.open('x', encoding='utf-8') as stream:
                stream.write(command)
            closed = subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-File', str(script)],
                                    capture_output=True, timeout=left(25))
            (ROOT / 'stop-cleanup.stdout').write_bytes(closed.stdout); (ROOT / 'stop-cleanup.stderr').write_bytes(closed.stderr)
            if closed.returncode:
                raise ValueError('STOP owned cleanup failed; no retry')
            after = observation.observe(timeout_seconds=left(10))
            write_once(ROOT / 'stop-cleanup-after-private.json', after['rows'])
            if after['rows']:
                raise ValueError('STOP host absence not proved')
            receipt['status'] = 'OWNED_PAIR_CLEANED_AFTER_STOP'
        else:
            receipt['status'] = 'NOT_CLEANED_UNBOUND_FRONTEND_OR_OTHER_INSTANCE'
    except Exception as error:
        receipt.update(status='STOP_CLEANUP_REJECTED', error=type(error).__name__ + ': ' + str(error))
    write_once(ROOT / 'stop-cleanup-private.json', receipt)
    return receipt


def wait_and_collect():
    if any((ROOT / name).exists() for name in ('verified-result.json', 'driver-stop-private.json')):
        raise ValueError('case is already terminal; no second collection/observation window')
    contract, _ = frozen()
    launched = launch_chain(contract)
    origin = decode_json(safe_bytes(ROOT / 'launch.claim.json', 128 * 1024))['launch_origin']
    def closer(script, timeout):
        return subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-File', str(script)], capture_output=True, timeout=timeout)
    def collector(deadline):
        # Independent bounded process includes final freeze/read/log checks.
        code = 'import sys,json;sys.path.insert(0,sys.argv[1]);import native_role_host as h;print(json.dumps(h.collect()))'
        result = subprocess.run([os.sys.executable, '-I', '-S', '-B', '-c', code, str(HERE)], capture_output=True,
                                timeout=max(0.001, deadline - time.monotonic()))
        (ROOT / 'collector.stdout').write_bytes(result.stdout); (ROOT / 'collector.stderr').write_bytes(result.stderr)
        if result.returncode:
            raise ValueError('strict collector rejected; preserve raw diagnostics and spent claim')
        summary = decode_json(result.stdout)
        if (time.monotonic() >= deadline or summary.get('scope') != SCOPE
                or summary.get('status') != 'CMAKE_VERSION_SAMPLED_LIFECYCLE_SUPPORTED'
                or summary.get('G2') is not False or summary.get('producer_allowed') is not False):
            raise ValueError('collector identity, scope or remaining deadline rejected')
        write_once(ROOT / 'verified-result.json', summary)
        return summary
    try:
        deadline = time.monotonic() + remaining_window(origin, time.monotonic(), datetime.now(timezone.utc))
        return lifecycle()(type('Writer', (), {'_write_once': staticmethod(write_once)}), contract['manifest'], launched,
            root=ROOT, observer=observation.observe, closer=closer, collector=collector, deadline=deadline)
    except Exception as error:
        write_once(ROOT / 'driver-stop-private.json', {'scope': SCOPE, 'status': 'REJECTED_OR_STOPPED',
            'claim_consumed': 1, 'remaining': 0, 'error': type(error).__name__ + ': ' + str(error), 'G2': False})
        stop_cleanup(launched)
        raise
