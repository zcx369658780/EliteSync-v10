"""One fixed, mapping-only rehearsal of the prepared 273 RO / 2 RW layout.

No SDK/Gradle launch, production budget or old scope is used. Protected readonly
inputs receive read and access-rights-open checks only, never mutation calls.
Private canaries are created/deleted only in the two already owned write roots.
"""
import hashlib
import json
import os
from pathlib import Path, PureWindowsPath
import re
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET

from current_product_apk_inventory import _checked_stat, inventory_files
from current_product_build_plan import _path

HERE = Path(__file__).resolve().parent
SCOPE = 'v1015-full-input-mapping-qualification-20261104'
FIXED_ROOT = Path.home() / 'EliteSyncDev' / SCOPE
PREPARED = Path.home() / 'EliteSyncDev/v1015-producer-inputs-20261103'
READONLY_COUNT = 273
WRITABLE = {'owned_flutter': r'C:\BuildWork\Flutter', 'owned_project': r'C:\BuildWork\Project'}
ACCESS = (0x40000000, 0x2, 0x4, 0x10000, 0x40000, 0x80000)
DIRECTORY_ACCESS = (0x2, 0x4, 0x40)
LIMITS = {'memory_mb': 2048, 'guest_deadline_seconds': 90, 'host_wait_seconds': 180,
          'max_anchor_bytes': 262144, 'total_anchor_bytes': 16 * 1024**2}


def sha(path):
    with Path(path).open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def _write_once(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        json.dump(value, stream, indent=2)
        stream.flush()
        os.fsync(stream.fileno())


def _windows(value):
    if type(value) is not str:
        raise ValueError('Windows path string required')
    return str(_path(value.replace('/', '\\')))


def _overlap(a, b):
    a, b = PureWindowsPath(a), PureWindowsPath(b)
    return a.is_relative_to(b) or b.is_relative_to(a)


def validate_mappings(rows, *, readonly_count=READONLY_COUNT):
    if type(readonly_count) is not int or readonly_count <= 0:
        raise ValueError('a positive exact readonly count is required')
    if type(rows) is not list or len(rows) != readonly_count + 2:
        raise ValueError('the complete fixed mapping count is required')
    roles, hosts, guests, total, readonly, writable = set(), [], [], 0, 0, set()
    for row in rows:
        if type(row) is not dict or set(row) != {'role', 'host', 'guest', 'readonly', 'relative', 'guest_file', 'bytes', 'sha256', 'file_id'}:
            raise ValueError('unexpected mapping fields')
        role = row['role']
        if type(role) is not str or not re.fullmatch('[A-Za-z0-9_]+', role) or role.casefold() in roles:
            raise ValueError('unique role required')
        roles.add(role.casefold())
        host, guest = _windows(row['host']), _windows(row['guest'])
        if host != row['host'] or guest != row['guest'] or any(_overlap(host, p) for p in hosts) or any(_overlap(guest, p) for p in guests):
            raise ValueError('canonical disjoint host and guest roots required')
        if any(_overlap(guest, p) for p in (r'C:\Probe', r'C:\ProbeOutput')):
            raise ValueError('probe/output guest overlap')
        hosts.append(host); guests.append(guest)
        if type(row['readonly']) is not bool:
            raise ValueError('explicit mapping permission required')
        if row['readonly']:
            readonly += 1
            if not PureWindowsPath(guest).is_relative_to(r'C:\Inputs'):
                raise ValueError('readonly inputs must be under the input namespace')
        else:
            if role not in WRITABLE or guest != WRITABLE[role]:
                raise ValueError('only the fixed two owned roots may be writable')
            writable.add(role)
        relative = row['relative']
        if type(relative) is not str or not relative or '\\' in relative:
            raise ValueError('canonical relative anchor required')
        parts = relative.split('/')
        if any(part in ('', '.', '..') for part in parts):
            raise ValueError('anchor must not escape its root')
        expected = _windows(guest + '\\' + '\\'.join(parts))
        if row['guest_file'] != expected:
            raise ValueError('anchor guest path mismatch')
        if type(row['bytes']) is not int or not 0 <= row['bytes'] <= LIMITS['max_anchor_bytes']:
            raise ValueError('anchor size bound')
        total += row['bytes']
        if type(row['sha256']) is not str or not re.fullmatch('[0-9a-f]{64}', row['sha256']):
            raise ValueError('anchor content identity required')
        identity = row['file_id']
        if type(identity) is not dict or set(identity) != {'device', 'inode'} or any(type(v) is not int or v < 0 for v in identity.values()):
            raise ValueError('anchor host file identity required')
    if readonly != readonly_count or writable != set(WRITABLE) or total > LIMITS['total_anchor_bytes']:
        raise ValueError('mapping permissions/count or total anchor bound')


def configuration(root, manifest):
    validate_mappings(manifest['mappings'])
    if type(manifest.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', manifest['nonce']):
        raise ValueError('exact nonce required')
    tree = ET.Element('Configuration')
    for name in ['vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']:
        ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'ProtectedClient').text = 'Enable'
    ET.SubElement(tree, 'MemoryInMB').text = str(LIMITS['memory_mb'])
    folders = ET.SubElement(tree, 'MappedFolders')
    rows = [{'host': str(root / 'probe'), 'guest': r'C:\Probe', 'readonly': True},
            {'host': str(root / 'output'), 'guest': r'C:\ProbeOutput', 'readonly': False}] + manifest['mappings']
    for row in rows:
        folder = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', row['host']), ('SandboxFolder', row['guest']), ('ReadOnly', str(row['readonly']).lower())]:
            ET.SubElement(folder, key).text = value
    command = ET.SubElement(tree, 'LogonCommand')
    ET.SubElement(command, 'Command').text = r'C:\Probe\MappingProbe.exe ' + manifest['nonce']
    return ET.tostring(tree, encoding='unicode') + '\n'


def _fixed_root(root):
    if Path(root).absolute() != FIXED_ROOT:
        raise ValueError('only this independent fixed scope path is eligible')
    _checked_stat(FIXED_ROOT.parent)
    return FIXED_ROOT


def _pins():
    paths = [Path(__file__), HERE / 'full_input_mapping_probe.cs',
             HERE / 'current_product_apk_inventory.py', HERE / 'current_product_build_plan.py',
             HERE / 'windows_sandbox_launch.ps1']
    return {str(path): sha(path) for path in paths}


def _check_anchors(rows):
    entries = [(row['role'], str(Path(row['host']).joinpath(*row['relative'].split('/')))) for row in rows]
    actual = inventory_files(entries, [row['host'] for row in rows], len(rows), LIMITS['total_anchor_bytes'])
    for expected, found in zip(rows, actual['files']):
        if any(expected[key] != found[key] for key in ('role', 'bytes', 'sha256', 'file_id')):
            raise ValueError('bound host anchor changed')


def _preparation_pins(rows):
    paths = [PREPARED / name for name in ['production-layout-private.json',
        'complete-declared-input-trees-private.json', 'private-flutter-complete-inventory-private.json',
        'private-project-inventory-private.json', 'guest-package-routes-private.json']]
    layout = json.loads(paths[0].read_bytes())
    expected = {role: (row['host'], _windows(row['guest']), True)
                for role, row in layout['readonly_mappings'].items()}
    for role in WRITABLE:
        expected[role] = (layout[role]['host'], _windows(layout[role]['guest']), False)
    actual = {row['role']: (row['host'], row['guest'], row['readonly']) for row in rows}
    if expected != actual or layout.get('execution_allowed') is not False or layout.get('G2') is not False:
        raise ValueError('mapping list differs from the prepared production layout')
    return {str(path): sha(path) for path in paths}


def prepare(root, mappings):
    root = _fixed_root(root)
    validate_mappings(mappings)
    preparation_pins = _preparation_pins(mappings)
    # Broad roots could otherwise map the probe, outputs or unrelated private data.
    for row in mappings:
        if _overlap(row['host'], str(root)):
            raise ValueError('input mapping overlaps the independent probe scope')
    _check_anchors(mappings)
    root.mkdir()
    for child in ['probe', 'output', 'compile-temp']:
        (root / child).mkdir()
    compiler = Path(os.environ.get('SystemRoot', r'C:\Windows')) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    signature = subprocess.run(['pwsh', '-NoProfile', '-Command',
        "$s=Get-AuthenticodeSignature -LiteralPath '" + str(compiler).replace("'", "''") + "'; if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"],
        capture_output=True, timeout=30)
    if signature.returncode:
        raise ValueError('existing system compiler signature failed; no installation')
    shutil.copyfile(HERE / 'full_input_mapping_probe.cs', root / 'probe/MappingProbe.cs')
    env = {key: value for key, value in os.environ.items() if not key.upper().startswith(('COR_', 'CORECLR_', 'COMPLUS_'))
           and key.upper() not in {'LIB', 'DOTNET_STARTUP_HOOKS', 'DOTNET_ADDITIONAL_DEPS', 'DOTNET_SHARED_STORE'}}
    env['TEMP'] = env['TMP'] = str(root / 'compile-temp')
    command = [str(compiler), '/nologo', '/noconfig', '/target:winexe', '/platform:x64',
               '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll',
               '/out:' + str(root / 'probe/MappingProbe.exe'), str(root / 'probe/MappingProbe.cs')]
    compiled = subprocess.run(command, capture_output=True, timeout=60, cwd=root, env=env)
    (root / 'compiler.stdout').write_bytes(compiled.stdout)
    (root / 'compiler.stderr').write_bytes(compiled.stderr)
    if compiled.returncode:
        raise ValueError('mapping fixture compile failed; no runtime claim created')
    manifest = {'schema': 1, 'scope': SCOPE, 'nonce': uuid.uuid4().hex, 'mappings': mappings,
        'mapping_fixture_only': True, 'sdk_execution_allowed': False, 'gradle_allowed': False,
        'producer_allowed': False, 'G2': False, 'max_launches': 1,
        'limits': dict(LIMITS), 'source_pins': _pins(), 'preparation_pins': preparation_pins,
        'compiler_sha256': sha(compiler),
        'binary_sha256': sha(root / 'probe/MappingProbe.exe')}
    _write_once(root / 'manifest.json', manifest)
    shutil.copyfile(root / 'manifest.json', root / 'probe/manifest.json')
    (root / 'qualification.wsb').write_text(configuration(root, manifest), encoding='utf-8')
    return manifest


def frozen(root):
    root = _fixed_root(root)
    for child in ['probe', 'output', 'compile-temp']:
        _checked_stat(root / child)
    manifest = json.loads((root / 'manifest.json').read_bytes())
    if (type(manifest.get('schema')) is not int or manifest['schema'] != 1 or manifest.get('scope') != SCOPE
            or manifest.get('source_pins') != _pins() or manifest.get('limits') != LIMITS
            or type(manifest.get('max_launches')) is not int or manifest['max_launches'] != 1
            or manifest.get('mapping_fixture_only') is not True
            or any(manifest.get(key) is not False for key in ['sdk_execution_allowed', 'gradle_allowed', 'producer_allowed', 'G2'])):
        raise ValueError('frozen scope, source or permission drift')
    if not re.fullmatch('[0-9a-f]{32}', manifest.get('nonce', '')):
        raise ValueError('nonce missing')
    validate_mappings(manifest['mappings'])
    if manifest.get('preparation_pins') != _preparation_pins(manifest['mappings']):
        raise ValueError('prepared production inputs drifted')
    _check_anchors(manifest['mappings'])
    if ((root / 'probe/manifest.json').read_bytes() != (root / 'manifest.json').read_bytes()
            or sha(root / 'probe/MappingProbe.exe') != manifest['binary_sha256']
            or sha(root / 'probe/MappingProbe.cs') != sha(HERE / 'full_input_mapping_probe.cs')
            or (root / 'qualification.wsb').read_text(encoding='utf-8') != configuration(root, manifest)):
        raise ValueError('prepared inputs or configuration drift')
    return manifest


def launch(root, *, mapping_runtime_authorized=False):
    if mapping_runtime_authorized is not True:
        raise ValueError('only the authorized mapping fixture may launch')
    manifest = frozen(root)
    if any((Path(root) / 'output').iterdir()):
        raise ValueError('output must be empty before the single launch')
    _write_once(Path(root) / 'launch.claim.json', {'scope': SCOPE, 'nonce': manifest['nonce'],
        'max_launches': 1, 'refundable': False, 'authorization': 'OWNER_CONTINUE_V1015_MAPPING_ONLY_Codex_CAP_1',
        'sdk_allowed': False, 'producer_allowed': False, 'G2': False})
    result = subprocess.run(['pwsh', '-NoProfile', '-File', str(HERE / 'windows_sandbox_launch.ps1'),
                             '-ConfigPath', str(Path(root) / 'qualification.wsb')], capture_output=True, timeout=30)
    (Path(root) / 'launcher.stdout').write_bytes(result.stdout)
    (Path(root) / 'launcher.stderr').write_bytes(result.stderr)
    if result.returncode:
        raise RuntimeError('mapping launch failed; claim spent, no automatic retry')
    launched = json.loads(result.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or not launched.get('creationUtc'):
        raise ValueError('host launch identity missing; claim spent')
    _write_once(Path(root) / 'launched.json', launched)
    return launched


def validate_receipt(receipt, manifest):
    mappings = manifest['mappings']
    validate_mappings(mappings)
    for key, value in [('schema', 1), ('scope', SCOPE), ('nonce', manifest['nonce']),
                       ('binary_sha256', manifest['binary_sha256']), ('username', 'WDAGUtilityAccount')]:
        if type(receipt.get(key)) is not type(value) or receipt[key] != value:
            raise ValueError('guest identity mismatch: ' + key)
    if 'failure' not in receipt or receipt['failure'] is not None or receipt.get('network_no_active_adapter') is not True:
        raise ValueError('mapping/network check failed')
    if type(receipt.get('pid')) is not int or receipt['pid'] <= 0:
        raise ValueError('guest PID missing')
    if any(type(receipt.get(k)) is not str or not receipt[k] for k in ['creation_utc', 'kernel_file_version', 'clr_version']):
        raise ValueError('guest environment identity missing')
    for key in ['sdk_starts', 'gradle_starts', 'apk_builds']:
        if type(receipt.get(key)) is not int or receipt[key] != 0:
            raise ValueError('unexpected/unknown tool execution')
    if receipt.get('G2') is not False:
        raise ValueError('mapping proof is not G2')
    reads = receipt.get('reads')
    if type(reads) is not list or len(reads) != len(mappings):
        raise ValueError('incomplete anchor read matrix')
    for row, expected in zip(reads, mappings):
        if (type(row) is not dict or row.get('role') != expected['role'] or row.get('path') != expected['guest_file']
                or type(row.get('bytes')) is not int or row['bytes'] != expected['bytes']
                or row.get('sha256') != expected['sha256'] or row.get('identity_stable') is not True):
            raise ValueError('anchor evidence mismatch')
    expected_checks = {(r['role'], r['guest_file'], access, False) for r in mappings if r['readonly'] for access in ACCESS}
    expected_checks |= {(r['role'], r['guest'], access, True) for r in mappings if r['readonly'] for access in DIRECTORY_ACCESS}
    checks = receipt.get('readonly_checks')
    if type(checks) is not list or len(checks) != len(expected_checks):
        raise ValueError('incomplete access-rights denial matrix')
    actual = set()
    for row in checks:
        if (type(row) is not dict or type(row.get('access')) is not int or type(row.get('directory')) is not bool
                or row.get('succeeded') is not False or type(row.get('native_error')) is not int or row['native_error'] != 5):
            raise ValueError('access failure is not proved denial')
        actual.add((row.get('role'), row.get('path'), row['access'], row['directory']))
    if actual != expected_checks:
        raise ValueError('duplicate or misbound access checks')
    writes = receipt.get('private_writes')
    if (type(writes) is not list or len(writes) != 2 or any(type(r) is not dict or type(r.get('role')) is not str for r in writes)
            or {r['role'] for r in writes} != set(WRITABLE)):
        raise ValueError('missing private canaries')
    for row in writes:
        expected = WRITABLE[row['role']] + '\\.elitesync-mapping-' + manifest['nonce'] + '.tmp'
        if row.get('path') != expected or row.get('write_read_delete_ok') is not True:
            raise ValueError('private canary not bound/cleaned')


def collect(root):
    root = Path(root)
    manifest = frozen(root)
    claim = json.loads((root / 'launch.claim.json').read_bytes())
    launched = json.loads((root / 'launched.json').read_bytes())
    if (claim.get('nonce') != manifest['nonce'] or claim.get('scope') != SCOPE or type(launched.get('pid')) is not int
            or type(claim.get('max_launches')) is not int or claim['max_launches'] != 1
            or claim.get('refundable') is not False or any(claim.get(k) is not False for k in ['sdk_allowed', 'producer_allowed', 'G2'])):
        raise ValueError('launch chain is missing')
    result = root / 'output/result.json'
    _checked_stat(result)
    if result.stat().st_size > 4 * 1024**2 or {p.name for p in (root / 'output').iterdir()} != {'result.json'}:
        raise ValueError('output shape or byte bound')
    receipt = json.loads(result.read_bytes())
    validate_receipt(receipt, manifest)
    owned = str(root / 'launched.json').replace("'", "''")
    command = "$o=Get-Content -LiteralPath '" + owned + "' -Raw|ConvertFrom-Json;$p=Get-Process -Id ([int]$o.pid) -ErrorAction SilentlyContinue;if($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$o.creationUtc).ToUniversalTime()){exit 1};if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}"
    exited = subprocess.run(['pwsh', '-NoProfile', '-Command', command], capture_output=True, timeout=30)
    if exited.returncode:
        raise ValueError('Sandbox exit not verified; do not close unrelated processes')
    summary = {'status': 'FULL_LAYOUT_MAPPING_ANCHORS_BOUNDED_SUPPORTED', 'scope': SCOPE,
        'guest_receipt_sha256': sha(result), 'readonly_roots': READONLY_COUNT, 'read_anchors': len(manifest['mappings']),
        'readonly_access_denials': READONLY_COUNT * (len(ACCESS) + len(DIRECTORY_ACCESS)), 'owned_write_roots': 2,
        'all_bound_host_anchors_unchanged': True, 'sandbox_processes_absent': True,
        'background_vm_teardown': 'UNKNOWN', 'full_file_consumption_proven': False,
        'native_tools_qualified': False, 'offline_resolution_proven': False, 'SDK_starts': 0,
        'actual_builds': 0, 'producer_budget': 'UNKNOWN_NOT_CREATED', 'G2': False}
    _write_once(root / 'verified-result.json', summary)
    return summary
