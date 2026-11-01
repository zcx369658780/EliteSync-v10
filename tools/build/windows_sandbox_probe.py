"""Prepare/launch one disposable, fixture-only Windows Sandbox qualification.

This is never a Gradle/APK runner and never reserves a G2 claim. The settings
follow https://learn.microsoft.com/en-us/windows/security/application-security/
application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
import uuid
import xml.etree.ElementTree as ET

REQUIRED_CHECKS = (
    'read_ok', 'output_write_ok', 'open_write_denied', 'write_content_denied',
    'file_delete_denied', 'file_rename_denied', 'directory_create_denied',
    'parent_rename_denied', 'write_dac_denied', 'write_owner_denied',
    'delete_child_denied', 'alias_write_denied', 'network_no_active_adapter',
)
HERE = Path(__file__).resolve().parent


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def validate_root(root, parent):
    root, parent = Path(root).absolute(), Path(parent).resolve()
    try:
        relative = root.relative_to(parent)
    except ValueError as error:
        raise ValueError('Probe must be inside the explicit owned parent') from error
    if not relative.parts or '..' in relative.parts or not root.is_dir():
        raise ValueError('A dedicated existing task directory is required')
    current = root
    while True:
        if current.is_symlink() or getattr(current.lstat(), 'st_file_attributes', 0) & 0x400:
            raise ValueError('Reparse points are not allowed in task ancestors')
        if current == parent:
            break
        current = current.parent
    if root.resolve() != root:
        raise ValueError('Task root must be canonical')
    for name in ['probe', 'fixture', 'output']:
        child = root / name
        if not child.is_dir() or child.is_symlink() or getattr(child.lstat(), 'st_file_attributes', 0) & 0x400:
            raise ValueError('Only real owned mapping directories are allowed')
        for item in child.iterdir():
            if item.is_dir() or item.is_symlink() or getattr(item.lstat(), 'st_file_attributes', 0) & 0x400:
                raise ValueError('Probe mappings may contain only real direct files')
    return root


def configuration(root, nonce, parent):
    root = validate_root(root, parent)
    if not re.fullmatch('[0-9a-f]{32}', nonce):
        raise ValueError('Invalid attempt nonce')
    tree = ET.Element('Configuration')
    for name in ['vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']:
        ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'ProtectedClient').text = 'Enable'
    ET.SubElement(tree, 'MemoryInMB').text = '2048'
    folders = ET.SubElement(tree, 'MappedFolders')
    for name, guest, readonly in [('probe', r'C:\Probe', True), ('fixture', r'C:\InputFixture', True), ('output', r'C:\ProbeOutput', False)]:
        mapping = ET.SubElement(folders, 'MappedFolder')
        ET.SubElement(mapping, 'HostFolder').text = str(root / name)
        ET.SubElement(mapping, 'SandboxFolder').text = guest
        ET.SubElement(mapping, 'ReadOnly').text = str(readonly).lower()
    command = ET.SubElement(tree, 'LogonCommand')
    ET.SubElement(command, 'Command').text = r'C:\Probe\Probe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def claim_once(path, value):
    with Path(path).open('x', encoding='utf-8') as stream:
        stream.write(json.dumps(value, indent=2) + '\n')
        stream.flush()
        os.fsync(stream.fileno())


def event(root, kind, **fields):
    with (root / 'events.jsonl').open('a', encoding='utf-8') as stream:
        stream.write(json.dumps({'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()), 'kind': kind, **fields}) + '\n')
        stream.flush()
        os.fsync(stream.fileno())


def validate_receipt(receipt, nonce, input_sha, binary_sha=None):
    if receipt.get('schema') != 1 or receipt.get('nonce') != nonce or receipt.get('username') != 'WDAGUtilityAccount' or receipt.get('input_sha256') != input_sha:
        raise ValueError('Guest identity or input binding is missing')
    if receipt.get('failure') is not None:
        raise ValueError('Guest reported an execution failure')
    if binary_sha is not None and (receipt.get('binary_sha256') != binary_sha or
            type(receipt.get('pid')) is not int or receipt['pid'] <= 0 or
            not isinstance(receipt.get('creation_utc'), str) or not receipt['creation_utc']):
        raise ValueError('Guest executable or process identity is missing')
    checks = receipt.get('checks', {})
    if any(checks.get(name) is not True for name in REQUIRED_CHECKS):
        raise ValueError('A failed, missing or unknown check cannot qualify isolation')
    networks = receipt.get('network', [])
    if len(networks) != 2 or {row.get('family') for row in networks} != {2, 23}:
        raise ValueError('Both literal address families must be observed')
    if any(row.get('native_error') not in [10050, 10051, 10065] for row in networks):
        raise ValueError('Timeout/refusal is not evidence of a disabled local network')


def validate_fixture(root, manifest):
    source = root / 'fixture/source.txt'
    stat = source.stat()
    if (stat.st_nlink != 1 or [stat.st_dev, stat.st_ino] != manifest['input_file_id']
            or digest(source) != manifest['input_sha256']
            or set(x.name for x in (root / 'fixture').iterdir()) != {'source.txt'}):
        raise ValueError('Host fixture identity, link count or content changed')


def prepare(root, parent):
    root = Path(root).absolute()
    if not root.parent.resolve().is_relative_to(parent.resolve()) or root == parent:
        raise ValueError('New task path must be under the owned parent')
    root.mkdir(exist_ok=False)
    for name in ['probe', 'fixture', 'output']:
        (root / name).mkdir()
    validate_root(root, parent)
    nonce = uuid.uuid4().hex
    data = ('owned readonly fixture ' + nonce + '\n').encode()
    source = root / 'fixture/source.txt'
    with source.open('xb') as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    shutil.copyfile(HERE / 'windows_sandbox_probe.cs', root / 'probe/Probe.cs')
    compiler = Path(os.environ.get('SystemRoot', r'C:\Windows')) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    if not compiler.is_file():
        raise RuntimeError('Existing system compiler is unavailable; do not install')
    signature = subprocess.run(['pwsh', '-NoProfile', '-Command',
        "$s=Get-AuthenticodeSignature -LiteralPath '" + str(compiler).replace("'", "''") + "'; if ($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows') { exit 1 }"], capture_output=True, timeout=30)
    if signature.returncode:
        raise RuntimeError('Existing compiler signature did not qualify')
    event(root, 'PREPARE_COMPILE', compiler=str(compiler), source_sha256=digest(root / 'probe/Probe.cs'))
    result = subprocess.run([str(compiler), '/nologo', '/target:exe', '/platform:x64', '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe/Probe.exe'), str(root / 'probe/Probe.cs')], capture_output=True, timeout=60)
    (root / 'compiler.stdout').write_bytes(result.stdout)
    (root / 'compiler.stderr').write_bytes(result.stderr)
    event(root, 'COMPILE_RESULT', exit=result.returncode, stdout_sha256=hashlib.sha256(result.stdout).hexdigest())
    if result.returncode:
        raise RuntimeError('Existing compiler failed; diagnostics retained')
    stat = source.stat()
    manifest = {'schema': 1, 'nonce': nonce, 'input_sha256': digest(source), 'input_file_id': [stat.st_dev, stat.st_ino],
        'source_sha256': digest(root / 'probe/Probe.cs'), 'binary_sha256': digest(root / 'probe/Probe.exe'),
        'host_controller_sha256': digest(__file__), 'launcher_sha256': digest(HERE / 'windows_sandbox_launch.ps1'),
        'compiler_sha256': digest(compiler), 'launch_max': 1, 'gradle_or_g2_allowed': False}
    claim_once(root / 'probe/manifest.json', manifest)
    claim_once(root / 'manifest.json', manifest)
    (root / 'qualification.wsb').write_text(configuration(root, nonce, parent), encoding='utf-8')
    event(root, 'PREPARED', **manifest)
    return manifest


def launch(root, parent):
    root = validate_root(root, parent)
    manifest = json.loads((root / 'manifest.json').read_bytes())
    if digest(__file__) != manifest['host_controller_sha256'] or digest(HERE / 'windows_sandbox_launch.ps1') != manifest['launcher_sha256']:
        raise ValueError('Host controller or launcher drift')
    if (root / 'probe/manifest.json').read_bytes() != (root / 'manifest.json').read_bytes():
        raise ValueError('Guest manifest drift')
    if any((root / 'output').iterdir()):
        raise ValueError('Output must be empty before the single launch')
    if (root / 'qualification.wsb').read_text() != configuration(root, manifest['nonce'], parent):
        raise ValueError('Configuration drift')
    for name, key in [('Probe.cs', 'source_sha256'), ('Probe.exe', 'binary_sha256')]:
        if digest(root / 'probe' / name) != manifest[key]:
            raise ValueError('Probe input drift')
    validate_fixture(root, manifest)
    event(root, 'PREPARE_LAUNCH', configuration_sha256=digest(root / 'qualification.wsb'), g2_starts=0)
    claim_once(root / 'launch.claim.json', {'nonce': manifest['nonce'], 'scope': 'fixture-only sandbox probe', 'max_starts': 1, 'refundable': False, 'g2_allowed': False})
    result = subprocess.run(['pwsh', '-NoProfile', '-File', str(HERE / 'windows_sandbox_launch.ps1'), '-ConfigPath', str(root / 'qualification.wsb')], capture_output=True, timeout=30)
    (root / 'launcher.stdout').write_bytes(result.stdout)
    (root / 'launcher.stderr').write_bytes(result.stderr)
    event(root, 'LAUNCH_RESULT', exit=result.returncode, stdout_sha256=hashlib.sha256(result.stdout).hexdigest())
    if result.returncode:
        raise RuntimeError('Sandbox launch failed; no retry or budget refund')
    launched = json.loads(result.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or not launched.get('creationUtc'):
        raise RuntimeError('Missing host launch identity; no retry')
    claim_once(root / 'launched.json', launched)
    print(result.stdout.decode('utf-8', errors='replace').strip())


def collect(root, parent):
    root = validate_root(root, parent)
    manifest = json.loads((root / 'manifest.json').read_bytes())
    claim = json.loads((root / 'launch.claim.json').read_bytes())
    launched = json.loads((root / 'launched.json').read_bytes())
    if claim.get('nonce') != manifest['nonce'] or type(launched.get('pid')) is not int:
        raise ValueError('Missing claimed launch identity')
    receipt = json.loads((root / 'output/result.json').read_text(encoding='utf-8-sig'))
    validate_fixture(root, manifest)
    validate_receipt(receipt, manifest['nonce'], manifest['input_sha256'], manifest['binary_sha256'])
    owned_path = str(root / 'launched.json').replace("'", "''")
    stopped = subprocess.run(['pwsh', '-NoProfile', '-Command',
        "$owned=Get-Content -LiteralPath '" + owned_path + "' -Raw | ConvertFrom-Json; "
        "$p=Get-Process -Id ([int]$owned.pid) -ErrorAction SilentlyContinue; "
        "if ($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$owned.creationUtc).ToUniversalTime()) { exit 1 }; "
        "if (Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue) { exit 1 }"], capture_output=True, timeout=30)
    if stopped.returncode:
        raise ValueError('Sandbox exit is not verified; do not claim completion or close unrelated processes')
    result = {'status': 'MAPPED_FIXTURE_ISOLATION_BOUNDED_SUPPORTED', 'native_checks': len(REQUIRED_CHECKS), 'network_targets': 2, 'host_fixture_unchanged': True,
        'guest_result_sha256': digest(root / 'output/result.json'), 'owned_launch_identity_exited': True,
        'sandbox_client_processes_absent': True, 'background_vm_teardown': 'UNKNOWN',
        'gradle_starts': 0, 'G2': False, 'not_full_sdk_or_build_qualification': True}
    claim_once(root / 'verified-result.json', result)
    event(root, 'VERIFIED_RESULT', **result)
    print(json.dumps(result))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'launch', 'collect'])
    parser.add_argument('--root', required=True, type=Path)
    args = parser.parse_args()
    parent = Path.home() / 'EliteSyncDev'
    {'prepare': prepare, 'launch': launch, 'collect': collect}[args.command](args.root, parent)


if __name__ == '__main__':
    main()
