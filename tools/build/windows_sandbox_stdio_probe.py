"""Independent one-shot VM/source stdio isolation; STOP sealing is not qualification."""
import argparse
import base64
import difflib
import hashlib
import json
import os
import re
from pathlib import Path, PureWindowsPath
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_dart_probe as dart

base, layout, inventory = dart.base, dart.layout, dart.inventory
HERE = Path(__file__).resolve().parent
PARENT = Path.home() / 'EliteSyncDev/v1015-stdio-vm-source-isolation-20261102'
SDK, LAUNCHER = dart.SDK, dart.LAUNCHER
SCRIPT = HERE / 'stdio_stage_probe.dart'
EXE = r'C:\Inputs\DartSdk\bin\dartvm.exe'
DESTINATION = r'C:\BuildWork\StdioProbe\stdio_stage_probe.dart'
BASE_SHA = '72637d0257fc37aa1ae7dc670ae4d7efb74dc8128a20822625429f97216b0347'
QUERIES = ('stdout_has_terminal', 'stdout_supports_ansi', 'stdout_terminal_columns',
           'stdout_terminal_lines', 'stdin_has_terminal', 'stdin_supports_ansi')
FILE_LIMIT, BYTE_LIMIT = 12000, 2 * 1024 ** 3


def command():
    # VM argument shape: https://github.com/dart-lang/sdk/blob/c70f78e7d682c158c15ca0c26c729b3ccb932284/runtime/bin/dartdev.cc#L493
    # Logical launcher paths do not qualify that launcher chain or prove the earlier STOP root cause.
    return [EXE, '--resolved_executable_name=' + dart.EXE, '--executable_name=' + dart.EXE, DESTINATION]


def contract():
    return {**dart.contract(), 'kind': 'stdio-stage-probe', 'mode': 'stdio-stage', 'executable': EXE,
            'arguments': command(), 'command_line': subprocess.list2cmdline(command()), 'producer_entry_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), SCRIPT, Path(dart.__file__), *dart.helpers()]))


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
            raise ValueError('Fixture must remain empty and unmapped')
    elif root.exists() or root.is_symlink():
        raise ValueError('Case already exists; no reset or retry')
    return root


def config(root, nonce):
    owned(root)
    tree = ET.fromstring(dart.common.configuration(root, nonce, PARENT))
    folders = tree.find('MappedFolders'); folders.remove(folders.findall('MappedFolder')[1])
    if not stat.S_ISDIR(inventory._checked_stat(SDK).st_mode):
        raise ValueError('Existing real SDK required')
    folder = ET.SubElement(folders, 'MappedFolder')
    for key, value in [('HostFolder', str(SDK)), ('SandboxFolder', r'C:\Inputs\DartSdk'), ('ReadOnly', 'true')]:
        ET.SubElement(folder, key).text = value
    tree.find('LogonCommand/Command').text = r'C:\Probe\StdioProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def pinned_bytes(path, cap):
    entries = [('source', str(path))]
    before = inventory.inventory_files(entries, [str(path.parent)], 1, cap)
    data = bounded_read(path, cap)
    if inventory.inventory_files(entries, [str(path.parent)], 1, cap) != before or hashlib.sha256(data).hexdigest() != before['files'][0]['sha256']:
        raise ValueError('Bounded source identity/hash drift')
    return data


def native_source():
    raw = pinned_bytes(dart.SOURCE, 65536)
    if hashlib.sha256(raw).hexdigest() != BASE_SHA:
        raise ValueError('Fixed base native source SHA mismatch')
    replacements = [(r'const string Self=@"C:\Probe\NativeToolProbe.exe"', r'const string Self=@"C:\Probe\StdioProbe.exe"'),
                    ('(string)m["mode"]!="dart-version"', '(string)m["mode"]!="stdio-stage"'),
                    (r'(string)m["executable"]!=@"C:\Inputs\DartSdk\bin\dart.exe"', '(string)m["executable"]!=@"' + EXE + '"'),
                    (r'(string)m["command_line"]!=@"C:\Inputs\DartSdk\bin\dart.exe --version"', '(string)m["command_line"]!=@"' + subprocess.list2cmdline(command()) + '"'),
                    ('kind="native-tool-probe"', 'kind="stdio-stage-probe"')]
    generated = raw
    for old, new in replacements:
        if generated.count(old.encode()) != 1:
            raise ValueError('Native substitution must have exactly one match')
        generated = generated.replace(old.encode(), new.encode(), 1)
    if len(generated) > 256 * 1024:
        raise ValueError('Generated native source exceeds 256 KiB')
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-base', tofile='private-stdio')).encode()
    report = {'base_sha256': BASE_SHA, 'generated_sha256': hashlib.sha256(generated).hexdigest(),
              'patch_sha256': hashlib.sha256(patch).hexdigest(), 'replacement_counts': [1] * len(replacements)}
    return raw, generated, patch, report


def inputs(root):
    entries = []
    for host, guest in [(SDK, PureWindowsPath(r'C:\Inputs\DartSdk')), (root / 'probe', PureWindowsPath(r'C:\Probe'))]:
        selected = []
        for path, relative in dart.strict_tree_files(host):
            if path == root / 'probe/manifest.json':
                continue
            if len(entries) + len(selected) >= FILE_LIMIT:
                raise ValueError('Input count cap exceeded before hashing')
            if host == root / 'probe' and path.name in ['StdioProbe.cs', 'stdio_stage_probe.dart'] and path.lstat().st_size > (256 * 1024 if path.suffix == '.cs' else 16384):
                raise ValueError('Generated source/script per-file cap exceeded')
            selected.append((path, relative))
        entries.extend((str(guest / str(relative)), str(path)) for path, relative in sorted(selected, key=lambda r: str(r[1])))
    captured = inventory.inventory_files(entries, [str(SDK), str(root / 'probe')], FILE_LIMIT, BYTE_LIMIT)
    rows, bindings = [], []
    for pin in captured['files']:
        row = {'path': pin['role'], 'sha256': pin['sha256']}
        if pin['role'] == r'C:\Probe\stdio_stage_probe.dart':
            row['destination'] = DESTINATION
        rows.append(row)
        bindings.append({'host': pin['path'], 'bytes': pin['bytes'], 'sha256': pin['sha256'], 'file_id': [pin['file_id']['device'], pin['file_id']['inode']]})
    return rows, bindings


def prepare(root):
    root = owned(root, False); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
        (root / name).mkdir()
    raw, generated, patch, report = native_source()
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/StdioProbe.cs', generated), ('probe/stdio_stage_probe.dart', pinned_bytes(SCRIPT, 16384))]:
        base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    pin = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != pin:
        raise ValueError('Existing compiler signature/identity mismatch')
    r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe/StdioProbe.exe'), str(root / 'probe/StdioProbe.cs')], env=layout.compiler_environment(root), cwd=root, capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', r.stdout); base.write(root / 'csc.stderr', r.stderr); base.put(root / 'csc-exit.json', {'exit_code': r.returncode})
    if r.returncode or dart.compiler_identity() != pin:
        raise ValueError('Compilation failed/compiler drifted')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'compiler_identity': pin,
         'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\StdioProbe.exe'),
         'images': [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)}], 'dartvm_authenticode_status': 'NotSigned'}
    if base.sha(root / 'probe/stdio_stage_probe.dart') != m['helper_pins'][str(SCRIPT)]['sha256']:
        raise ValueError('Script copy drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'stdio.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    for name in ['manifest.json', 'probe/manifest.json', 'stdio.wsb']:
        layout.safe_file(root / name)
    m = json.loads((root / 'manifest.json').read_bytes())
    if (type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce'])
            or m.get('dartvm_authenticode_status') != 'NotSigned'):
        raise ValueError('Nonce or observed existing VM signature status drift')
    if any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items()) or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()} or m['compiler_identity'] != dart.compiler_identity():
        raise ValueError('Fixed command/environment/helper/compiler drift')
    raw, generated, patch, report = native_source()
    if (m['native_report'] != report or json.loads(bounded_read(root / 'native-source-report.json', 65536)) != report
            or any(bounded_read(root / name, 65536 if name == 'base-native-source.cs' else 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/StdioProbe.cs', generated)])
            or bounded_read(root / 'probe/stdio_stage_probe.dart', 16384) != pinned_bytes(SCRIPT, 16384)):
        raise ValueError('Base/patch/generated source/script trace drift')
    rows, bindings = inputs(root)
    if rows != m['inputs'] or bindings != m['bindings'] or m['images'] != [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)}] or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\StdioProbe.exe'):
        raise ValueError('Complete SDK/probe/VM/binary identity drift')
    if (root / 'manifest.json').read_bytes() != (root / 'probe/manifest.json').read_bytes() or (root / 'stdio.wsb').read_text() != config(root, m['nonce']):
        raise ValueError('Guest manifest/configuration drift')
    return root, m


def claim(m, digest):
    return {**dart.claim(m, digest), 'mode': 'stdio-stage', 'producer_entry_allowed': False}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists():
        raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'stdio.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode:
        raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('Missing host identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def bounded_read(path, cap):
    info = inventory._checked_stat(path)
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or not 0 <= info.st_size <= cap:
        raise ValueError('Evidence must be a bounded single-link regular file')
    fd = os.open(path, os.O_RDONLY | getattr(os, 'O_BINARY', 0) | getattr(os, 'O_NOFOLLOW', 0))
    try:
        before = os.fstat(fd)
        if inventory._identity(before) != inventory._identity(info) or before.st_nlink != 1:
            raise ValueError('Evidence changed before read')
        chunks, count = [], 0
        while True:
            chunk = os.read(fd, min(65536, cap - count + 1))
            if not chunk: break
            count += len(chunk)
            if count > cap: raise ValueError('Evidence read cap exceeded')
            chunks.append(chunk)
        after, current = os.fstat(fd), inventory._checked_stat(path)
        if count != info.st_size or inventory._identity(after) != inventory._identity(info) or inventory._identity(current) != inventory._identity(info) or after.st_nlink != 1 or current.st_nlink != 1:
            raise ValueError('Evidence drifted during read')
        return b''.join(chunks)
    finally:
        os.close(fd)


def markers(path):
    if not path.exists() and not path.is_symlink():
        return {'status': 'NO_STAGE_RECORDED', 'events': [], 'complete': False, 'incomplete_tail': None}
    data = bounded_read(path, 16384); lines = data.split(b'\n'); tail = lines.pop()
    events = [json.loads(line.decode('utf-8')) for line in lines]
    expected = [('main', 'entered')] + [(query, event) for query in QUERIES for event in ['before', 'result']] + [('main', 'completed')]
    if len(events) > len(expected): raise ValueError('Too many marker events')
    for sequence, event in enumerate(events):
        query, phase = expected[sequence]
        if type(event) is not dict or type(event.get('sequence')) is not int or event['sequence'] != sequence or event.get('query') != query:
            raise ValueError('Marker identity/order/sequence mismatch')
        actual = event.get('event')
        keys = {'sequence', 'query', 'event'}
        if phase == 'result':
            if actual == 'after':
                keys.add('value'); wanted = int if query in QUERIES[2:4] else bool
                if type(event.get('value')) is not wanted: raise ValueError('Marker getter value type mismatch')
            elif actual == 'error':
                keys.add('kind')
                if type(event.get('kind')) is not str or not event['kind']: raise ValueError('Missing RuntimeType')
            else: raise ValueError('Getter must produce after/error')
        elif actual != phase: raise ValueError('Marker phase mismatch')
        if set(event) != keys: raise ValueError('Unknown marker schema')
    return {'status': 'RECORDED' if events else 'NO_STAGE_RECORDED', 'events': events,
            'complete': len(events) == 14 and not tail, 'incomplete_tail': tail.decode('utf-8', errors='replace') if tail else None,
            'incomplete_tail_base64': base64.b64encode(tail).decode() if tail else None, 'raw_sha256': hashlib.sha256(data).hexdigest()}


def validate_result(r, m):
    required = {'schema': 1, 'kind': 'stdio-stage-probe', 'mode': 'stdio-stage', 'nonce': m['nonce'], 'binary_sha256': m['binary_sha256'],
                'input_files': len(m['inputs']), 'native_tool_root_attempts': 1, 'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True}
    if type(r) is not dict or any(k not in r or base.data_sha(r[k]) != base.data_sha(v) for k, v in required.items()):
        raise ValueError('Receipt identity/counters/failure mismatch')
    p = r.get('proof')
    if (type(p) is not dict or p.get('job_final_empty') is not True or p.get('all_bound_handles_exited') is not True
            or type(p.get('bound_members')) is not int or p['bound_members'] < 1 or type(p.get('watchdog_stop')) is not int
            or (p.get('root_exit') is not None and type(p['root_exit']) is not int) or 'root_exit' not in p
            or 'stop_reason' not in p or (p['stop_reason'] is not None and type(p['stop_reason']) is not str)):
        raise ValueError('Owned clean teardown/typed proof required')
    return p


def classify(proof, stages, samples):
    if proof['root_exit'] == 0 and proof['stop_reason'] is None and proof['bound_members'] == 1 and proof['watchdog_stop'] == 0 and stages['complete']:
        return 'STDIO_VM_SINGLE_PROCESS_SOURCE_SUPPORTED'
    conhost = any(row.get('operation') == 'process_image_check' and str(row.get('observed_image', '')).casefold() == r'C:\Windows\System32\conhost.exe'.casefold() for row in samples)
    if (proof['root_exit'] is None and proof['stop_reason'] == 'GradleDiagnostic+SafetyStop: UNKNOWN_PROCESS_IMAGE'
            and proof['bound_members'] == 2 and proof['watchdog_stop'] == 0 and conhost):
        return 'STDIO_VM_REPRODUCED_UNQUALIFIED_CONSOLE'
    return 'REJECTED'


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    for name in ['launch.claim.json', 'launched.json', 'launcher-exit.json', 'launcher.stdout', 'launcher.stderr', 'output/result.json']:
        layout.safe_file(root / name)
    if base.data_sha(json.loads((root / 'launch.claim.json').read_bytes())) != base.data_sha(claim(m, digest)) or base.data_sha(json.loads((root / 'launcher-exit.json').read_bytes())) != base.data_sha({'exit_code': 0}):
        raise ValueError('Launch claim/manifest/exit chain mismatch')
    launched = json.loads((root / 'launched.json').read_bytes()); raw = json.loads((root / 'launcher.stdout').read_bytes().decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc') or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched):
        raise ValueError('Host launch identity chain mismatch')
    r = json.loads((root / 'output/result.json').read_bytes()); proof = validate_result(r, m)
    stages = markers(root / 'output/stdio-stages.jsonl')
    sample_path = root / 'output/samples.jsonl'
    samples = [json.loads(line) for line in bounded_read(sample_path, 4 * 1024 ** 2).decode('utf-8').splitlines()] if sample_path.exists() else []
    status = classify(proof, stages, samples); frozen(root)
    result = {'status': status, 'tool_qualified': status == 'STDIO_VM_SINGLE_PROCESS_SOURCE_SUPPORTED', 'stages': stages, 'proof': proof,
              'getter_errors': [row for row in stages['events'] if row['event'] == 'error'],
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'), 'producer_entry_allowed': False,
              'wrapper': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN', 'Gradle': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv); print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__':
    main()
