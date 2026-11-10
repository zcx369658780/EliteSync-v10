"""One-shot existing Dart --version compatibility probe; no producer qualification."""
import argparse
import hashlib
import json
import os
from pathlib import Path, PureWindowsPath
import re
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import current_product_aar_recheck_diagnostic as base
import current_product_apk_inventory as inventory
import windows_sandbox_layout_probe as layout
import windows_sandbox_probe as common

HERE = Path(__file__).resolve().parent
PARENT = Path.home() / 'EliteSyncDev/v1015-flutter-cache-20261102-01'
SDK = Path(r'D:\flutter\bin\cache\dart-sdk')
SOURCE = HERE / 'windows_sandbox_native_tool_probe.cs'
LAUNCHER = HERE / 'windows_sandbox_launch.ps1'
COMPILER = Path(r'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe')
EXE = r'C:\Inputs\DartSdk\bin\dart.exe'
HOME = r'C:\BuildWork\Home'
DIRECTORIES = [HOME, r'C:\BuildWork\tmp', HOME + r'\AppData\Roaming', HOME + r'\AppData\Local']
PROCESSES = 'WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer'
INPUT_FILE_LIMIT = 12000
INPUT_BYTE_LIMIT = 2 * 1024 ** 3
COMPILER_BYTE_LIMIT = 16 * 1024 ** 2


def compiler_identity():
    """Fixed system compiler only; OS-serviced hard links are recorded, not rejected."""
    def identity(info):
        return (info.st_dev, info.st_ino, info.st_size, info.st_mtime_ns, info.st_nlink)
    expected = inventory._checked_stat(COMPILER)
    if not stat.S_ISREG(expected.st_mode) or expected.st_nlink < 1 or not 0 < expected.st_size <= COMPILER_BYTE_LIMIT:
        raise ValueError('Compiler must be a regular file within the 16 MiB cap')
    fd = os.open(COMPILER, os.O_RDONLY | getattr(os, 'O_BINARY', 0) | getattr(os, 'O_NOFOLLOW', 0))
    try:
        before = os.fstat(fd)
        if not stat.S_ISREG(before.st_mode) or identity(before) != identity(expected):
            raise ValueError('Compiler identity changed before reading')
        digest, count = hashlib.sha256(), 0
        while True:
            chunk = os.read(fd, min(1024 ** 2, COMPILER_BYTE_LIMIT - count + 1))
            if not chunk:
                break
            count += len(chunk)
            if count > COMPILER_BYTE_LIMIT or count > expected.st_size:
                raise ValueError('Compiler read exceeded size/cap')
            digest.update(chunk)
        after, current = os.fstat(fd), inventory._checked_stat(COMPILER)
        if count != expected.st_size or identity(after) != identity(expected) or identity(current) != identity(expected):
            raise ValueError('Compiler changed while reading')
        return {'bytes': count, 'file_id': [before.st_dev, before.st_ino],
                'sha256': digest.hexdigest(), 'link_count': before.st_nlink}
    finally:
        os.close(fd)


def environment():
    return {'SystemRoot': r'C:\Windows', 'WINDIR': r'C:\Windows', 'OS': 'Windows_NT',
            'PATH': r'C:\Inputs\DartSdk\bin;C:\Windows\System32', 'USERPROFILE': HOME,
            'HOME': HOME, 'TMP': DIRECTORIES[1], 'TEMP': DIRECTORIES[1],
            'APPDATA': DIRECTORIES[2], 'LOCALAPPDATA': DIRECTORIES[3], 'DART_SUPPRESS_ANALYTICS': 'true'}


def owned(root, existing=True):
    root = Path(root)
    if not root.is_absolute() or root != root.absolute() or root.parent != PARENT:
        raise ValueError('Case must be a direct absolute child of the fixed owned parent')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        if not path.is_dir() or path.is_symlink() or getattr(path.lstat(), 'st_file_attributes', 0) & 0x400:
            raise ValueError('Missing or redirected owned directory')
    if existing:
        common.validate_root(root, PARENT)
    elif root.exists() or root.is_symlink():
        raise ValueError('New case root must not exist')
    return root


def config(root, nonce):
    tree = ET.fromstring(common.configuration(root, nonce, PARENT))
    folders = tree.find('MappedFolders')
    folders.remove(folders.findall('MappedFolder')[1])
    for path in [SDK, *SDK.parents]:
        if not path.is_dir() or path.is_symlink() or getattr(path.lstat(), 'st_file_attributes', 0) & 0x400:
            raise ValueError('Missing or redirected SDK directory')
    mapping = ET.SubElement(folders, 'MappedFolder')
    for key, value in [('HostFolder', str(SDK)), ('SandboxFolder', r'C:\Inputs\DartSdk'), ('ReadOnly', 'true')]:
        ET.SubElement(mapping, key).text = value
    tree.find('LogonCommand/Command').text = r'C:\Probe\NativeToolProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def helpers():
    return [Path(__file__).resolve(), SOURCE, Path(base.__file__), Path(layout.__file__), Path(common.__file__), LAUNCHER,
            HERE / 'current_product_aar_recheck_contract.py', Path(layout.plan_helper.__file__),
            Path(layout.runtime_helper.__file__), Path(inventory.__file__)]


def strict_tree_files(root):
    def fail(error):
        raise error
    for ancestor in [root, *root.parents]:
        info = ancestor.lstat()
        if not stat.S_ISDIR(info.st_mode) or stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
            raise ValueError('Missing or redirected inventory root')
    for directory, dirs, files in os.walk(root, followlinks=False, onerror=fail):
        for name in dirs + files:
            path = Path(directory) / name
            info = path.lstat()
            if stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
                raise ValueError('Redirected inventory entry')
        for name in files:
            path = Path(directory) / name
            yield path, path.relative_to(root)


def inputs(root):
    rows, bindings, entries = [], [], []
    for host_root, guest_root in [(SDK, PureWindowsPath(r'C:\Inputs\DartSdk')), (root / 'probe', PureWindowsPath(r'C:\Probe'))]:
        selected = []
        for path, relative in strict_tree_files(host_root):
            if path == root / 'probe/manifest.json':
                continue
            if len(entries) + len(selected) >= INPUT_FILE_LIMIT:
                raise ValueError('File cap exceeded during enumeration before hashing')
            selected.append((path, relative))
        for path, relative in sorted(selected, key=lambda row: str(row[1])):
            entries.append((str(guest_root / str(relative)), str(path)))
    captured = inventory.inventory_files(entries, [str(SDK), str(root / 'probe')], INPUT_FILE_LIMIT, INPUT_BYTE_LIMIT)
    for pin in captured['files']:
        bindings.append({'host': pin['path'], 'bytes': pin['bytes'], 'sha256': pin['sha256'],
                         'file_id': [pin['file_id']['device'], pin['file_id']['inode']]})
        rows.append({'path': pin['role'], 'sha256': pin['sha256']})
    return rows, bindings


def contract():
    args = [EXE, '--version']
    return {'schema': 1, 'kind': 'native-tool-probe', 'mode': 'dart-version',
            'executable': EXE, 'arguments': args, 'command_line': subprocess.list2cmdline(args),
            'cwd': HOME, 'environment': environment(), 'private_directories': DIRECTORIES,
            'max_launches': 1, 'gradle_allowed': False, 'apk_allowed': False, 'G2': False}


def prepare(root):
    root = owned(root, False)
    root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
        (root / name).mkdir()
    base.write(root / 'probe/NativeToolProbe.cs', SOURCE.read_bytes())
    compiler_pin = compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(COMPILER) + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode:
        raise ValueError('Existing compiler signature is not qualified')
    if compiler_identity() != compiler_pin:
        raise ValueError('Compiler identity changed after signature validation')
    result = subprocess.run([str(COMPILER), '/nologo', '/target:winexe', '/platform:x64',
                             '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe/NativeToolProbe.exe'),
                             str(root / 'probe/NativeToolProbe.cs')], env=layout.compiler_environment(root),
                            cwd=root, capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', result.stdout); base.write(root / 'csc.stderr', result.stderr)
    base.put(root / 'csc-exit.json', {'exit_code': result.returncode})
    if result.returncode or compiler_identity() != compiler_pin:
        raise ValueError('Compilation failed or compiler drifted; preserve evidence')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings,
         'binary_sha256': base.sha(root / 'probe/NativeToolProbe.exe'),
         'images': [{'path': EXE, 'sha256': base.sha(SDK / 'bin/dart.exe')}],
         'sdk_version': (SDK / 'version').read_text().strip(), 'sdk_source': str(SDK),
         'dart_authenticode_status': 'NotSigned', 'compiler_identity': compiler_pin,
         'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}}
    if not m['sdk_version'] or m['helper_pins'][str(SOURCE)]['sha256'] != base.sha(root / 'probe/NativeToolProbe.cs'):
        raise ValueError('Source or SDK version drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'dart.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    for path in [root / 'manifest.json', root / 'probe/manifest.json', root / 'dart.wsb']:
        layout.safe_file(path)
    m = json.loads((root / 'manifest.json').read_bytes())
    if any(type(m.get(k)) is not type(v) or m.get(k) != v for k, v in contract().items()):
        raise ValueError('CLI, environment or scope drift')
    if not isinstance(m.get('nonce'), str) or not re.fullmatch('[0-9a-f]{32}', m['nonce']):
        raise ValueError('Invalid nonce')
    if m.get('helper_pins') != {str(path): layout.safe_file(path) for path in helpers()} or m.get('compiler_identity') != compiler_identity():
        raise ValueError('Controller, helper, source, launcher or compiler drift')
    rows, bindings = inputs(root)
    if rows != m['inputs'] or bindings != m['bindings'] or base.sha(root / 'probe/NativeToolProbe.cs') != base.sha(SOURCE):
        raise ValueError('Complete declared SDK/probe identity set drift')
    if m['binary_sha256'] != base.sha(root / 'probe/NativeToolProbe.exe') or m['images'] != [{'path': EXE, 'sha256': base.sha(SDK / 'bin/dart.exe')}]:
        raise ValueError('Executable identity drift')
    if m['sdk_version'] != (SDK / 'version').read_text().strip() or m['sdk_source'] != str(SDK) or m['dart_authenticode_status'] != 'NotSigned':
        raise ValueError('SDK provenance drift')
    if (root / 'manifest.json').read_bytes() != (root / 'probe/manifest.json').read_bytes() or (root / 'dart.wsb').read_text() != config(root, m['nonce']):
        raise ValueError('Guest manifest/configuration drift')
    return root, m


def absent():
    query = 'if(Get-Process -Name ' + PROCESSES + ' -ErrorAction SilentlyContinue){exit 1}'
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode:
        raise ValueError('All four Sandbox host processes must be absent')


def claim(m, digest):
    return {'nonce': m['nonce'], 'manifest_sha256': digest, 'mode': 'dart-version',
            'max_launches': 1, 'refundable': False, 'gradle_allowed': False, 'apk_allowed': False, 'G2': False}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists():
        raise ValueError('Fresh output and unused one-shot case required')
    absent()
    digest = base.sha(root / 'manifest.json')
    base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        result = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'dart.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'})
        raise
    base.write(root / 'launcher.stdout', result.stdout); base.write(root / 'launcher.stderr', result.stderr)
    base.put(root / 'launcher-exit.json', {'exit_code': result.returncode})
    if result.returncode:
        raise ValueError('Launch failed; permanent one-shot claim remains consumed')
    launched = json.loads(result.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('Missing host launch identity; claim remains consumed')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_result(r, m):
    expected = {'schema': 1, 'kind': 'native-tool-probe', 'mode': 'dart-version', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']),
                'native_tool_root_attempts': 1, 'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False,
                'failure': None, 'tool_images_pinned': True}
    if type(r) is not dict or any(k not in r or type(r[k]) is not type(v) or r[k] != v for k, v in expected.items()):
        raise ValueError('Guest receipt identity/counters/failure mismatch')
    p = r.get('proof')
    proof = {'root_exit': 0, 'stop_reason': None, 'job_final_empty': True, 'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 1}
    if type(p) is not dict or any(k not in p or type(p[k]) is not type(v) or p[k] != v for k, v in proof.items()):
        raise ValueError('Single-process clean exit not proven')
    return p


def collect(root):
    root, m = frozen(root); absent()
    digest = base.sha(root / 'manifest.json')
    for name in ['launch.claim.json', 'launched.json', 'launcher-exit.json', 'launcher.stdout', 'launcher.stderr', 'output/result.json', 'output/tool.stdout', 'output/tool.stderr']:
        layout.safe_file(root / name)
    if base.data_sha(json.loads((root / 'launch.claim.json').read_bytes())) != base.data_sha(claim(m, digest)) or base.data_sha(json.loads((root / 'launcher-exit.json').read_bytes())) != base.data_sha({'exit_code': 0}):
        raise ValueError('Launch claim or launcher exit mismatch')
    launched = json.loads((root / 'launched.json').read_bytes())
    if launched.get('manifest_sha256') != digest or type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('Missing bound launch identity')
    raw = json.loads((root / 'launcher.stdout').read_bytes().decode('utf-8-sig'))
    if {**raw, 'manifest_sha256': digest} != launched:
        raise ValueError('Launcher identity chain drift')
    r = json.loads((root / 'output/result.json').read_bytes()); proof = validate_result(r, m)
    text = '\n'.join((root / 'output' / name).read_text(errors='strict') for name in ['tool.stdout', 'tool.stderr'])
    if not re.search(r'Dart SDK version: ' + re.escape(m['sdk_version']) + r'(?=\s|$)', text):
        raise ValueError('Exact SDK version output not observed')
    result = {'status': 'DART_SINGLE_PROCESS_COMPATIBILITY_SUPPORTED', 'proof': proof,
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'),
              'Flutter': 'NOT_PROVEN', 'cache': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN',
              'Gradle': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'producer_entry_allowed': False,
              'gradle_allowed': False, 'apk_allowed': False, 'apk_builds': 0, 'G2': False}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'launch', 'collect'])
    parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv)
    print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__':
    main()
