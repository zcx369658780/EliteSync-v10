"""One-shot guest OS image/signature inventory; grants no console execution."""
import argparse
import difflib
import hashlib
import json
from pathlib import Path, PureWindowsPath
import re
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_stdio_probe as stdio

dart, base, layout, inventory = stdio.dart, stdio.base, stdio.layout, stdio.inventory
bounded_read, pinned_bytes = stdio.bounded_read, stdio.pinned_bytes
HERE = Path(__file__).resolve().parent
PARENT = Path.home() / 'EliteSyncDev/v1015-console-image-inventory-20261102'
SOURCE = HERE / 'console_image_inventory.cs'
LAUNCHER = dart.LAUNCHER
EXE = r'C:\Probe\ConsoleImageInventory.exe'
FILE_LIMIT, BYTE_LIMIT = 100, 8 * 1024 ** 2
ASSEMBLY = 'System.Management.Automation, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'


def contract():
    environment = dart.environment()
    environment.pop('DART_SUPPRESS_ANALYTICS'); environment['PATH'] = r'C:\Windows\System32'
    return {**dart.contract(), 'kind': 'console-image-inventory-probe', 'mode': 'console-image-inventory',
            'executable': EXE, 'arguments': [EXE], 'command_line': EXE, 'environment': environment,
            'producer_entry_allowed': False, 'console_execution_allowed': False, 'device_allowed': False, 'media_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), SOURCE, Path(stdio.__file__), *stdio.helpers()]))


def owned(root, existing=True):
    root = Path(root)
    if root != PARENT / 'case01' or not root.is_absolute():
        raise ValueError('Only the independent fixed parent/case01 is allowed')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        if not stat.S_ISDIR(inventory._checked_stat(path).st_mode):
            raise ValueError('Real owned directory required')
    if existing:
        dart.common.validate_root(root, PARENT)
        if any((root / 'fixture').iterdir()):
            raise ValueError('Fixture must stay empty and unmapped')
    elif root.exists() or root.is_symlink():
        raise ValueError('Case exists; one-shot cases cannot be reset')
    return root


def config(root, nonce):
    owned(root)
    tree = ET.fromstring(dart.common.configuration(root, nonce, PARENT))
    folders = tree.find('MappedFolders'); folders.remove(folders.findall('MappedFolder')[1])
    tree.find('LogonCommand/Command').text = r'C:\Probe\ConsoleInventoryProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def native_source():
    raw = pinned_bytes(dart.SOURCE, 65536)
    if hashlib.sha256(raw).hexdigest() != stdio.BASE_SHA:
        raise ValueError('Fixed native base SHA mismatch')
    replacements = [(r'const string Self=@"C:\Probe\NativeToolProbe.exe"', r'const string Self=@"C:\Probe\ConsoleInventoryProbe.exe"'),
                    ('(string)m["mode"]!="dart-version"', '(string)m["mode"]!="console-image-inventory"'),
                    (r'(string)m["executable"]!=@"C:\Inputs\DartSdk\bin\dart.exe"', '(string)m["executable"]!=@"' + EXE + '"'),
                    (r'(string)m["command_line"]!=@"C:\Inputs\DartSdk\bin\dart.exe --version"', '(string)m["command_line"]!=@"' + EXE + '"'),
                    ('kind="native-tool-probe"', 'kind="console-image-inventory-probe"')]
    generated = raw
    for old, new in replacements:
        if generated.count(old.encode()) != 1:
            raise ValueError('Every native substitution must match exactly once')
        generated = generated.replace(old.encode(), new.encode(), 1)
    if len(generated) > 256 * 1024: raise ValueError('Generated source cap exceeded')
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-base', tofile='private-console-inventory')).encode()
    report = {'base_sha256': stdio.BASE_SHA, 'generated_sha256': hashlib.sha256(generated).hexdigest(),
              'patch_sha256': hashlib.sha256(patch).hexdigest(), 'replacement_counts': [1] * 5}
    return raw, generated, patch, report


def inputs(root):
    selected = []
    for path, relative in dart.strict_tree_files(root / 'probe'):
        if relative == Path('manifest.json'): continue
        if len(selected) >= FILE_LIMIT: raise ValueError('Probe count cap exceeded before hashing')
        if path.suffix == '.cs' and path.lstat().st_size > 256 * 1024:
            raise ValueError('Native source per-file cap exceeded')
        selected.append((path, relative))
    entries = [(str(PureWindowsPath(r'C:\Probe') / str(relative)), str(path)) for path, relative in sorted(selected, key=lambda row: str(row[1]))]
    captured = inventory.inventory_files(entries, [str(root / 'probe')], FILE_LIMIT, BYTE_LIMIT)
    rows, bindings = [], []
    for pin in captured['files']:
        rows.append({'path': pin['role'], 'sha256': pin['sha256']})
        bindings.append({'host': pin['path'], 'bytes': pin['bytes'], 'sha256': pin['sha256'], 'file_id': [pin['file_id']['device'], pin['file_id']['inode']]})
    return rows, bindings


def prepare(root):
    root = owned(root, False); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
        (root / name).mkdir()
    raw, generated, patch, report = native_source()
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/ConsoleInventoryProbe.cs', generated),
                       ('probe/ConsoleImageInventory.cs', pinned_bytes(SOURCE, 256 * 1024))]:
        base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler:
        raise ValueError('Existing compiler signature/identity mismatch')
    for name in ['ConsoleImageInventory', 'ConsoleInventoryProbe']:
        if dart.compiler_identity() != compiler: raise ValueError('Compiler drift before compile')
        r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll',
                            '/out:' + str(root / 'probe' / (name + '.exe')), str(root / 'probe' / (name + '.cs'))],
                           cwd=root, env=layout.compiler_environment(root), capture_output=True, timeout=60)
        base.write(root / (name + '.stdout'), r.stdout); base.write(root / (name + '.stderr'), r.stderr)
        base.put(root / (name + '-exit.json'), {'exit_code': r.returncode})
        if r.returncode or dart.compiler_identity() != compiler: raise ValueError('Compilation failed/compiler drifted')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'compiler_identity': compiler,
         'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\ConsoleInventoryProbe.exe'),
         'images': [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)}]}
    if base.sha(root / 'probe/ConsoleImageInventory.cs') != m['helper_pins'][str(SOURCE)]['sha256']:
        raise ValueError('Fixture source capture drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'console-inventory.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    for name in ['manifest.json', 'probe/manifest.json', 'console-inventory.wsb']: layout.safe_file(root / name)
    m = json.loads((root / 'manifest.json').read_bytes())
    if type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce']):
        raise ValueError('Invalid frozen inventory nonce')
    if (any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items())
            or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()} or m['compiler_identity'] != dart.compiler_identity()):
        raise ValueError('Fixed command/scope/helper/compiler drift')
    raw, generated, patch, report = native_source()
    if (m['native_report'] != report or json.loads(bounded_read(root / 'native-source-report.json', 65536)) != report
            or any(bounded_read(root / name, 65536 if name == 'base-native-source.cs' else 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/ConsoleInventoryProbe.cs', generated)])
            or bounded_read(root / 'probe/ConsoleImageInventory.cs', 256 * 1024) != pinned_bytes(SOURCE, 256 * 1024)):
        raise ValueError('Base/patch/generated/fixture trace drift')
    rows, bindings = inputs(root)
    if (rows != m['inputs'] or bindings != m['bindings'] or m['images'] != [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)}]
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\ConsoleInventoryProbe.exe')):
        raise ValueError('Complete probe/binary/image identity drift')
    if (root / 'manifest.json').read_bytes() != (root / 'probe/manifest.json').read_bytes() or (root / 'console-inventory.wsb').read_text() != config(root, m['nonce']):
        raise ValueError('Guest manifest/configuration drift')
    return root, m


def claim(m, digest):
    return {**dart.claim(m, digest), 'mode': 'console-image-inventory', 'console_execution_allowed': False,
            'producer_entry_allowed': False, 'device_allowed': False, 'media_allowed': False}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists():
        raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'console-inventory.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('Missing launch identity; claim remains consumed')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def signature(value):
    keys = {'status', 'subject', 'signature_type', 'is_os_binary'}
    if (type(value) is not dict or set(value) != keys or value['status'] != 'Valid' or type(value['subject']) is not str
            or 'CN=Microsoft Windows' not in [part.strip() for part in value['subject'].split(',')]
            or value['signature_type'] not in ['Catalog', 'Authenticode'] or value['is_os_binary'] is not True):
        raise ValueError('Exact valid Microsoft Windows OS signature metadata required')


def validate_inventory(value):
    keys = {'schema', 'path', 'bytes', 'sha256', 'file_id', 'hard_links', 'file_version', 'identity_stable', 'signature', 'automation_assembly'}
    if type(value) is not dict or set(value) != keys: raise ValueError('Unknown console inventory schema')
    if type(value['schema']) is not int or value['schema'] != 1 or value['path'] != r'C:\Windows\System32\conhost.exe':
        raise ValueError('Wrong schema or OS image path')
    if (type(value['bytes']) is not int or not 0 < value['bytes'] <= 16 * 1024**2
            or type(value['hard_links']) is not int or not 1 <= value['hard_links'] <= 0xffffffff
            or type(value['sha256']) is not str or re.fullmatch('[0-9a-fA-F]{64}', value['sha256']) is None
            or type(value['file_version']) is not str or not value['file_version'] or value['identity_stable'] is not True):
        raise ValueError('Missing typed stable OS file identity')
    file_id = value['file_id']
    if (type(file_id) is not dict or set(file_id) != {'volume', 'index'} or type(file_id['volume']) is not int
            or not 0 <= file_id['volume'] <= 0xffffffff or type(file_id['index']) is not str
            or re.fullmatch('[0-9]{1,20}', file_id['index']) is None or not 0 < int(file_id['index']) <= 0xffffffffffffffff):
        raise ValueError('Unknown OS file ID schema')
    signature(value['signature']); assembly = value['automation_assembly']
    if type(assembly) is not dict or set(assembly) != {'full_name', 'under_windows', 'signature'} or assembly['full_name'] != ASSEMBLY or assembly['under_windows'] is not True:
        raise ValueError('Automation assembly identity/location mismatch')
    signature(assembly['signature'])
    return value


def validate_receipt(r, m):
    required = {'schema': 1, 'kind': 'console-image-inventory-probe', 'mode': 'console-image-inventory', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'tool_images_pinned': True}
    if type(r) is not dict or any(k not in r or base.data_sha(r[k]) != base.data_sha(v) for k, v in required.items()):
        raise ValueError('Receipt identity/counters mismatch')
    if 'failure' not in r or (r['failure'] is not None and type(r['failure']) is not str): raise ValueError('Unknown failure schema')
    p = r.get('proof')
    if p is None and r['failure'] is not None: return None
    if (type(p) is not dict or any(type(p.get(key)) is not bool for key in ['job_final_empty', 'all_bound_handles_exited'])
            or type(p.get('bound_members')) is not int or p['bound_members'] < 1 or type(p.get('watchdog_stop')) is not int or p['watchdog_stop'] < 0
            or 'root_exit' not in p or (p['root_exit'] is not None and type(p['root_exit']) is not int)
            or 'stop_reason' not in p or (p['stop_reason'] is not None and type(p['stop_reason']) is not str)):
        raise ValueError('Unknown typed process proof')
    return p


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    for name in ['launch.claim.json', 'launched.json', 'launcher-exit.json', 'launcher.stdout', 'launcher.stderr', 'output/result.json']: layout.safe_file(root / name)
    if base.data_sha(json.loads((root / 'launch.claim.json').read_bytes())) != base.data_sha(claim(m, digest)) or base.data_sha(json.loads((root / 'launcher-exit.json').read_bytes())) != base.data_sha({'exit_code': 0}):
        raise ValueError('Claim/manifest/launcher chain mismatch')
    launched = json.loads((root / 'launched.json').read_bytes()); raw = json.loads((root / 'launcher.stdout').read_bytes().decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc') or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched):
        raise ValueError('Host launch identity mismatch')
    receipt = json.loads((root / 'output/result.json').read_bytes()); proof = validate_receipt(receipt, m)
    clean = {'root_exit': 0, 'stop_reason': None, 'bound_members': 1, 'watchdog_stop': 0, 'job_final_empty': True, 'all_bound_handles_exited': True}
    status, reason, metadata = 'REJECTED', 'NON_CLEAN_PROCESS_OR_FIXTURE_FAILURE', None
    if receipt['failure'] is None and proof is not None and all(base.data_sha(proof.get(k)) == base.data_sha(v) for k, v in clean.items()):
        try:
            metadata = validate_inventory(json.loads(bounded_read(root / 'output/console-image.json', 16384)))
            status, reason = 'CONSOLE_OS_IMAGE_INVENTORY_SUPPORTED', None
        except (ValueError, OSError, UnicodeError) as error:
            reason = type(error).__name__ + ': ' + str(error)
    frozen(root)
    result = {'status': status, 'tool_qualified': status == 'CONSOLE_OS_IMAGE_INVENTORY_SUPPORTED', 'reason': reason, 'inventory': metadata,
              'proof': proof, 'failure': receipt['failure'], 'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'),
              'console_execution_allowed': False, 'producer_entry_allowed': False, 'device_allowed': False, 'media_allowed': False,
              'VM': 'NOT_PROVEN', 'Flutter': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN', 'Gradle': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv); print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__': main()
