"""One-shot private Flutter cache negative path; no BAT or build qualification."""
import argparse
import json
import os
from pathlib import Path, PureWindowsPath
import re
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_dart_probe as dart

base, layout, inventory = dart.base, dart.layout, dart.inventory
HERE = Path(__file__).resolve().parent
PARENT, SDK, LAUNCHER = dart.PARENT, dart.SDK, dart.LAUNCHER
FLUTTER = Path(r'D:\flutter')
SOURCE = HERE / 'windows_sandbox_flutter_cache_probe.cs'
WORK = PureWindowsPath(r'C:\BuildWork\Flutter')
CONTROLS = ('LICENSE', 'bin/cache/flutter_tools.snapshot', 'bin/cache/flutter.version.json',
            'bin/cache/engine.stamp', 'bin/cache/engine.realm', 'bin/cache/engine_stamp.json',
            'bin/cache/engine_stamp.stamp', 'bin/internal/engine.version',
            'packages/flutter_tools/.dart_tool/package_config.json', 'bin/cache/dart-sdk/version')
FILE_LIMIT, BYTE_LIMIT = 12000, 2 * 1024 ** 3
ERROR_TEXT = 'The "--machine" flag is only valid with the "--version" flag or the "analyze --suggestions" command.'


def owned(root, existing=True):
    root = Path(root)
    if not root.is_absolute() or root != root.absolute() or root.parent != PARENT:
        raise ValueError('New case must be a direct absolute child of the fixed parent')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        info = inventory._checked_stat(path)
        if not stat.S_ISDIR(info.st_mode):
            raise ValueError('Owned directory required')
    if not existing:
        if root.exists() or root.is_symlink():
            raise ValueError('New case must not exist')
    else:
        for name in ['probe', 'fixture', 'output']:
            if not stat.S_ISDIR(inventory._checked_stat(root / name).st_mode):
                raise ValueError('Real mapped directory required')
    return root


def contract():
    args = [dart.EXE, '--packages=' + str(WORK / 'packages/flutter_tools/.dart_tool/package_config.json'),
            str(WORK / 'bin/cache/flutter_tools.snapshot'), '--suppress-analytics', '--no-version-check', '--machine', 'assemble']
    return {**dart.contract(), 'kind': 'flutter-cache-negative-probe', 'mode': 'flutter-cache-negative',
            'arguments': args, 'command_line': subprocess.list2cmdline(args),
            'environment': {**dart.environment(), 'FLUTTER_ROOT': str(WORK)},
            'producer_entry_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), SOURCE, Path(dart.__file__), *dart.helpers()]))


def config(root, nonce):
    owned(root)
    if not re.fullmatch('[0-9a-f]{32}', nonce):
        raise ValueError('Invalid nonce')
    tree = ET.Element('Configuration')
    for name in ['vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']:
        ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'ProtectedClient').text = 'Enable'
    ET.SubElement(tree, 'MemoryInMB').text = '2048'
    folders = ET.SubElement(tree, 'MappedFolders')
    for host, guest, readonly in [(SDK, r'C:\Inputs\DartSdk', True), (root / 'probe', r'C:\Probe', True),
                                  (root / 'fixture', r'C:\Inputs\FlutterControls', True), (root / 'output', r'C:\ProbeOutput', False)]:
        if not stat.S_ISDIR(inventory._checked_stat(host).st_mode):
            raise ValueError('Real mapped directory required')
        folder = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', str(host)), ('SandboxFolder', guest), ('ReadOnly', str(readonly).lower())]:
            ET.SubElement(folder, key).text = value
    ET.SubElement(ET.SubElement(tree, 'LogonCommand'), 'Command').text = r'C:\Probe\FlutterCacheProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def sources():
    entries = [(name, str(FLUTTER / name)) for name in CONTROLS]
    mtimes = {name: (FLUTTER / name).lstat().st_mtime_ns for name in CONTROLS}
    captured = inventory.inventory_files(entries, [str(FLUTTER)], FILE_LIMIT, BYTE_LIMIT)
    result = []
    for pin in captured['files']:
        if Path(pin['path']).lstat().st_mtime_ns != mtimes[pin['role']]:
            raise ValueError('Control source timestamp drift')
        result.append({**pin, 'mtime_ns': mtimes[pin['role']]})
    return result


def capture_controls(root):
    before = sources()
    for pin in before:
        source, destination = Path(pin['path']), root / 'fixture' / pin['role']
        destination.parent.mkdir(parents=True, exist_ok=True)
        fd = os.open(source, os.O_RDONLY | getattr(os, 'O_BINARY', 0) | getattr(os, 'O_NOFOLLOW', 0))
        try:
            info = os.fstat(fd)
            if ([info.st_dev, info.st_ino] != [pin['file_id']['device'], pin['file_id']['inode']]
                    or info.st_size != pin['bytes'] or info.st_mtime_ns != pin['mtime_ns'] or info.st_nlink != 1):
                raise ValueError('Control identity changed before copy')
            count = 0
            with destination.open('xb') as output:
                while True:
                    chunk = os.read(fd, min(1024 ** 2, pin['bytes'] - count + 1))
                    if not chunk:
                        break
                    count += len(chunk)
                    if count > pin['bytes']:
                        raise ValueError('Control grew during bounded copy')
                    output.write(chunk)
            after = os.fstat(fd)
            if count != pin['bytes'] or inventory._identity(after) != inventory._identity(info) or after.st_nlink != 1:
                raise ValueError('Control changed during copy')
        finally:
            os.close(fd)
        os.utime(destination, ns=(pin['mtime_ns'], pin['mtime_ns']))
    if sources() != before:
        raise ValueError('Control source set drifted during capture')
    return before


def inputs(root):
    entries, destinations = [], {}
    for host, guest in [(SDK, PureWindowsPath(r'C:\Inputs\DartSdk')), (root / 'probe', PureWindowsPath(r'C:\Probe')),
                         (root / 'fixture', PureWindowsPath(r'C:\Inputs\FlutterControls'))]:
        selected = []
        for path, relative in dart.strict_tree_files(host):
            if path == root / 'probe/manifest.json':
                continue
            if len(entries) + len(selected) >= FILE_LIMIT:
                raise ValueError('Input file cap exceeded before hashing')
            if host == root / 'fixture':
                name = relative.as_posix()
                if name not in CONTROLS:
                    raise ValueError('Undeclared control/lock/stamp repair input')
                destinations[str(guest / str(relative))] = str(WORK / str(relative))
            selected.append((path, relative))
        entries.extend((str(guest / str(relative)), str(path)) for path, relative in sorted(selected, key=lambda r: str(r[1])))
    if len(destinations) != len(CONTROLS):
        raise ValueError('Missing fixed control input')
    captured = inventory.inventory_files(entries, [str(SDK), str(root / 'probe'), str(root / 'fixture')], FILE_LIMIT, BYTE_LIMIT)
    rows, bindings = [], []
    for pin in captured['files']:
        row = {'path': pin['role'], 'sha256': pin['sha256']}
        if pin['role'] in destinations:
            row['destination'] = destinations[pin['role']]
        rows.append(row)
        bindings.append({'host': pin['path'], 'bytes': pin['bytes'], 'file_id': [pin['file_id']['device'], pin['file_id']['inode']], 'sha256': pin['sha256']})
    return rows, bindings


def bounded_text(path):
    with path.open('rb') as stream:
        data = stream.read(65537)
    if len(data) > 65536:
        raise ValueError('Version control exceeds text cap')
    return data.decode('utf-8').strip()


def provenance(root, pins, bindings):
    for source in pins:
        path = root / 'fixture' / source['role']
        target = next(row for row in bindings if row['host'] == str(path))
        if target['bytes'] != source['bytes'] or target['sha256'] != source['sha256'] or path.lstat().st_mtime_ns != source['mtime_ns']:
            raise ValueError('Source/private control identity mismatch')
    version = json.loads(bounded_text(root / 'fixture/bin/cache/flutter.version.json'))['frameworkVersion']
    if version != '3.41.7' or bounded_text(root / 'fixture/bin/cache/dart-sdk/version') != bounded_text(SDK / 'version'):
        raise ValueError('Fixed Flutter legacy version or current SDK mismatch')
    return version


def prepare(root):
    root = owned(root, False); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
        (root / name).mkdir()
    source_pins = capture_controls(root)
    base.write(root / 'probe/FlutterCacheProbe.cs', SOURCE.read_bytes())
    compiler_pin = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler_pin:
        raise ValueError('Existing signed compiler identity mismatch')
    result = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll',
                             '/out:' + str(root / 'probe/FlutterCacheProbe.exe'), str(root / 'probe/FlutterCacheProbe.cs')],
                            cwd=root, env=layout.compiler_environment(root), capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', result.stdout); base.write(root / 'csc.stderr', result.stderr)
    base.put(root / 'csc-exit.json', {'exit_code': result.returncode})
    if result.returncode or dart.compiler_identity() != compiler_pin:
        raise ValueError('Compilation failed or compiler drifted')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'source_pins': source_pins,
         'compiler_identity': compiler_pin, 'helper_pins': {str(path): layout.safe_file(path) for path in helpers()},
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\FlutterCacheProbe.exe'),
         'images': [{'path': dart.EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == dart.EXE)}],
         'legacy_version': provenance(root, source_pins, bindings), 'dart_authenticode_status': 'NotSigned', 'sdk_source': str(SDK)}
    if base.sha(root / 'probe/FlutterCacheProbe.cs') != m['helper_pins'][str(SOURCE)]['sha256']:
        raise ValueError('Native source capture drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'flutter-cache.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    for path in [root / 'manifest.json', root / 'probe/manifest.json', root / 'flutter-cache.wsb']:
        layout.safe_file(path)
    m = json.loads((root / 'manifest.json').read_bytes())
    if any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items()) or not re.fullmatch('[0-9a-f]{32}', m['nonce']):
        raise ValueError('Fixed command/environment/scope/nonce drift')
    if m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()} or m['compiler_identity'] != dart.compiler_identity():
        raise ValueError('Controller/helper/native/compiler drift')
    rows, bindings = inputs(root)
    if rows != m['inputs'] or bindings != m['bindings'] or sources() != m['source_pins']:
        raise ValueError('SDK/probe/control source identity set drift')
    if m['legacy_version'] != provenance(root, m['source_pins'], bindings) or m['sdk_source'] != str(SDK) or m['dart_authenticode_status'] != 'NotSigned':
        raise ValueError('Version/provenance drift')
    if (m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\FlutterCacheProbe.exe')
            or m['images'] != [{'path': dart.EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == dart.EXE)}]
            or base.sha(root / 'probe/FlutterCacheProbe.cs') != base.sha(SOURCE)):
        raise ValueError('Executable/source drift')
    if (root / 'manifest.json').read_bytes() != (root / 'probe/manifest.json').read_bytes() or (root / 'flutter-cache.wsb').read_text() != config(root, m['nonce']):
        raise ValueError('Guest manifest/configuration drift')
    return root, m


def claim(m, digest):
    return {**dart.claim(m, digest), 'mode': 'flutter-cache-negative', 'producer_entry_allowed': False}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists():
        raise ValueError('Fresh output and unconsumed one-shot case required')
    dart.absent(); digest = base.sha(root / 'manifest.json')
    base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'flutter-cache.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'})
        raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr)
    base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode:
        raise ValueError('Launch failed; permanent claim remains consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('Missing host launch identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_result(r, m):
    if type(r) is not dict:
        raise ValueError('Receipt object required')
    expected = {'schema': 1, 'kind': 'flutter-cache-negative-probe', 'mode': 'flutter-cache-negative', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True}
    proof = {'root_exit': 2, 'stop_reason': None, 'job_final_empty': True, 'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 1}
    cache = {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': m['legacy_version']}
    for actual, required in [(r, expected), (r.get('proof'), proof), (r.get('cache_state'), cache)]:
        if type(actual) is not dict or any(k not in actual or base.data_sha(actual[k]) != base.data_sha(v) for k, v in required.items()):
            raise ValueError('Receipt identity/counters/single-process/cache negative proof mismatch')
    return r['proof']


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    for name in ['launch.claim.json', 'launched.json', 'launcher-exit.json', 'launcher.stdout', 'launcher.stderr', 'output/result.json', 'output/tool.stdout', 'output/tool.stderr']:
        layout.safe_file(root / name)
    if (base.data_sha(json.loads((root / 'launch.claim.json').read_bytes())) != base.data_sha(claim(m, digest))
            or base.data_sha(json.loads((root / 'launcher-exit.json').read_bytes())) != base.data_sha({'exit_code': 0})):
        raise ValueError('Manifest/claim/launcher chain mismatch')
    launched = json.loads((root / 'launched.json').read_bytes())
    raw = json.loads((root / 'launcher.stdout').read_bytes().decode('utf-8-sig'))
    if (type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc')
            or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched)):
        raise ValueError('Host launch identity mismatch')
    proof = validate_result(json.loads((root / 'output/result.json').read_bytes()), m)
    text = '\n'.join((root / 'output' / name).read_text(encoding='utf-8', errors='strict') for name in ['tool.stdout', 'tool.stderr'])
    if ERROR_TEXT not in text:
        raise ValueError('Exact expected --machine negative-path error not observed')
    frozen(root)  # Source SDK/control pins must still match after receipt checks.
    result = {'status': 'FLUTTER_PRIVATE_CACHE_NEGATIVE_PATH_SUPPORTED', 'proof': proof,
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'),
              'BAT': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN', 'Gradle': 'NOT_PROVEN', 'APK': 'NOT_PROVEN',
              'producer_entry_allowed': False, 'gradle_allowed': False, 'apk_allowed': False, 'apk_builds': 0, 'G2': False}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv)
    print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__':
    main()
