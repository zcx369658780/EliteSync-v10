"""One existing Java/Python compatibility and synthetic Job probe. Never Gradle."""
import argparse
import json
import os
from pathlib import Path, PureWindowsPath
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_probe as fixture

HERE = Path(__file__).resolve().parent
JDK = Path(r'C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot')
PYTHON = Path.home() / 'AppData/Local/Programs/Python/Python311'
ANCHORS = [(JDK / part, str(PureWindowsPath(r'C:\Tools\Jdk') / part)) for part in
           ['release', 'bin/java.exe', 'bin/server/jvm.dll']]
ANCHORS += [(PYTHON / part, str(PureWindowsPath(r'C:\Tools\Python') / part)) for part in
            ['python.exe', 'python311.dll', 'Lib/os.py', 'DLLs/_ctypes.pyd']]


def identity(path):
    path = Path(path).absolute()
    for current in [path, *path.parents]:
        if current.is_symlink() or getattr(current.lstat(), 'st_file_attributes', 0) & 0x400:
            raise ValueError('Redirected runtime input')
    info = path.stat()
    if not path.is_file() or info.st_nlink != 1:
        raise ValueError('Only single-link runtime files are allowed')
    return {'path': str(path), 'file_id': [info.st_dev, info.st_ino],
            'bytes': info.st_size, 'sha256': fixture.digest(path)}


def configuration(root, nonce, parent):
    tree = ET.fromstring(fixture.configuration(root, nonce, parent))
    folders = tree.find('MappedFolders')
    folders.remove(folders.findall('MappedFolder')[1])  # No fixture mapping in this probe.
    for host, guest in [(JDK, r'C:\Tools\Jdk'), (PYTHON, r'C:\Tools\Python')]:
        # Validate tool root and all ancestors; files are independently bound below.
        identity(host / ('release' if host == JDK else 'python.exe'))
        mapping = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', str(host)), ('SandboxFolder', guest), ('ReadOnly', 'true')]:
            ET.SubElement(mapping, key).text = value
    tree.find('./LogonCommand/Command').text = r'C:\Probe\RuntimeProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def prepare(root, parent):
    root = Path(root).absolute()
    if root.exists() or not root.parent.resolve().is_relative_to(parent.resolve()) or root == parent:
        raise ValueError('A new dedicated task root is required')
    root.mkdir()
    for name in ['probe', 'fixture', 'output']:
        (root / name).mkdir()
    fixture.validate_root(root, parent)
    nonce = uuid.uuid4().hex
    rows = [dict(identity(host), guest=guest) for host, guest in ANCHORS]
    compiler = Path(os.environ.get('SystemRoot', r'C:\Windows')) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    for binary, signer in [(compiler, 'Microsoft Windows'), (JDK / 'bin/java.exe', 'Eclipse'), (PYTHON / 'python.exe', 'Python Software Foundation')]:
        script = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(binary).replace("'", "''") + "'; if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch '" + signer + "'){exit 1}"
        result = subprocess.run(['pwsh', '-NoProfile', '-Command', script], capture_output=True, timeout=30)
        if result.returncode:
            raise RuntimeError('Existing executable signature did not qualify; do not install/replace')
    shutil.copyfile(HERE / 'windows_sandbox_runtime_probe.cs', root / 'probe/RuntimeProbe.cs')
    fixture.event(root, 'COMPILE_PREPARE', source_sha256=fixture.digest(root / 'probe/RuntimeProbe.cs'))
    result = subprocess.run([str(compiler), '/nologo', '/target:exe', '/platform:x64', '/r:System.Web.Extensions.dll',
        '/out:' + str(root / 'probe/RuntimeProbe.exe'), str(root / 'probe/RuntimeProbe.cs')], capture_output=True, timeout=60)
    (root / 'compiler.stdout').write_bytes(result.stdout)
    (root / 'compiler.stderr').write_bytes(result.stderr)
    fixture.event(root, 'COMPILE_RESULT', exit=result.returncode)
    if result.returncode:
        raise RuntimeError('Existing compiler failed; preserve diagnostics')
    manifest = {'schema': 1, 'kind': 'existing-tools-and-owned-job', 'nonce': nonce, 'anchors': rows,
        'guest_inputs': {row['guest']: row['sha256'] for row in rows},
        'binary_sha256': fixture.digest(root / 'probe/RuntimeProbe.exe'),
        'source_sha256': fixture.digest(root / 'probe/RuntimeProbe.cs'),
        'controller_sha256': fixture.digest(__file__), 'helper_sha256': fixture.digest(fixture.__file__),
        'launcher_sha256': fixture.digest(HERE / 'windows_sandbox_launch.ps1'),
        'compiler_sha256': fixture.digest(compiler), 'max_launches': 1, 'gradle_allowed': False, 'G2': False}
    fixture.claim_once(root / 'manifest.json', manifest)
    fixture.claim_once(root / 'probe/manifest.json', manifest)
    (root / 'qualification.wsb').write_text(configuration(root, nonce, parent), encoding='utf-8')
    fixture.event(root, 'PREPARED', binary_sha256=manifest['binary_sha256'], anchor_count=len(rows))


def frozen(root, parent):
    root = fixture.validate_root(root, parent)
    manifest = json.loads((root / 'manifest.json').read_bytes())
    expected = [(str(host), guest) for host, guest in ANCHORS]
    if [(row['path'], row['guest']) for row in manifest['anchors']] != expected:
        raise ValueError('Runtime input allowlist drift')
    for row in manifest['anchors']:
        if identity(row['path']) != {key: row[key] for key in ['path', 'file_id', 'bytes', 'sha256']}:
            raise ValueError('Runtime anchor identity drift')
    for path, key in [(Path(__file__), 'controller_sha256'), (Path(fixture.__file__), 'helper_sha256'),
                      (HERE / 'windows_sandbox_launch.ps1', 'launcher_sha256'),
                      (root / 'probe/RuntimeProbe.cs', 'source_sha256'), (root / 'probe/RuntimeProbe.exe', 'binary_sha256')]:
        if fixture.digest(path) != manifest[key]:
            raise ValueError('Probe code drift')
    if (root / 'probe/manifest.json').read_bytes() != (root / 'manifest.json').read_bytes():
        raise ValueError('Guest manifest drift')
    if manifest['guest_inputs'] != {row['guest']: row['sha256'] for row in manifest['anchors']}:
        raise ValueError('Guest anchor drift')
    if (root / 'qualification.wsb').read_text() != configuration(root, manifest['nonce'], parent):
        raise ValueError('Runtime configuration drift')
    return root, manifest


def launch(root, parent):
    root, manifest = frozen(root, parent)
    if any((root / 'output').iterdir()):
        raise ValueError('Owned output must be empty before launch')
    fixture.claim_once(root / 'launch.claim.json', {'nonce': manifest['nonce'], 'scope': manifest['kind'],
        'max_launches': 1, 'refundable': False, 'gradle_allowed': False, 'G2': False})
    fixture.event(root, 'LAUNCH_PREPARE', gradle_starts=0)
    result = subprocess.run(['pwsh', '-NoProfile', '-File', str(HERE / 'windows_sandbox_launch.ps1'),
        '-ConfigPath', str(root / 'qualification.wsb')], capture_output=True, timeout=30)
    (root / 'launcher.stdout').write_bytes(result.stdout)
    (root / 'launcher.stderr').write_bytes(result.stderr)
    fixture.event(root, 'LAUNCH_RESULT', exit=result.returncode)
    if result.returncode:
        raise RuntimeError('Runtime probe launch failed; do not retry/refund')
    receipt = json.loads(result.stdout.decode('utf-8-sig'))
    if type(receipt.get('pid')) is not int or not receipt.get('creationUtc'):
        raise RuntimeError('Missing launch identity; do not retry')
    fixture.claim_once(root / 'launched.json', receipt)
    print(json.dumps(receipt))


def validate_receipt(receipt, manifest):
    for key, value in [('schema', 1), ('kind', 'existing-tools-and-owned-job'), ('nonce', manifest['nonce']),
                       ('username', 'WDAGUtilityAccount'), ('binary_sha256', manifest['binary_sha256'])]:
        if receipt.get(key) != value:
            raise ValueError('Guest receipt identity missing or incorrect: ' + key)
    if receipt.get('failure') is not None or receipt.get('readonly_tool_anchors') is not True:
        raise ValueError('Runtime probe reported failure or did not verify readonly anchors')
    for tool, version in [('java', '17.0.18'), ('python', '3.11.')]:
        row = receipt.get(tool) or {}
        if type(row.get('exit')) is not int or row['exit'] != 0 or row.get('version') != version or type(row.get('pid')) is not int or row['pid'] <= 0 or not row.get('creation_utc'):
            raise ValueError('Existing tool compatibility unproven: ' + tool)
    job = receipt.get('job') or {}
    if any(job.get(key) is not True for key in ['assigned_before_resume', 'startup_frame', 'kill_on_close_observed']):
        raise ValueError('Owned Job child proof missing')
    if type(job.get('pid')) is not int or job['pid'] <= 0 or type(job.get('birth')) is not int or job['birth'] <= 0 or job.get('image') != r'C:\Probe\RuntimeProbe.exe' or type(job.get('exit_code')) is not int or job['exit_code'] == 259:
        raise ValueError('Owned child identity/exit missing')
    for counter in ['gradle_starts', 'apk_builds']:
        if type(receipt.get(counter)) is not int or receipt[counter] != 0:
            raise ValueError('Unexpected or unknown build execution: ' + counter)
    if receipt.get('G2') is not False:
        raise ValueError('Unexpected or unknown G2 result')


def collect(root, parent):
    root, manifest = frozen(root, parent)
    claim = json.loads((root / 'launch.claim.json').read_bytes())
    launched = json.loads((root / 'launched.json').read_bytes())
    if claim.get('nonce') != manifest['nonce'] or type(launched.get('pid')) is not int:
        raise ValueError('Claimed launch identity missing')
    receipt = json.loads((root / 'output/result.json').read_bytes())
    validate_receipt(receipt, manifest)
    script = "$o=Get-Content -LiteralPath '" + str(root / 'launched.json').replace("'", "''") + "' -Raw|ConvertFrom-Json; $p=Get-Process -Id ([int]$o.pid) -ErrorAction SilentlyContinue; if($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$o.creationUtc).ToUniversalTime()){exit 1}; if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}"
    result = subprocess.run(['pwsh', '-NoProfile', '-Command', script], capture_output=True, timeout=30)
    if result.returncode:
        raise ValueError('Sandbox client exit unverified; do not close unrelated processes')
    summary = {'status': 'EXISTING_TOOLS_AND_SYNTHETIC_JOB_BOUNDED_SUPPORTED',
        'receipt_sha256': fixture.digest(root / 'output/result.json'), 'tool_anchors_unchanged': True,
        'owned_launch_exited': True, 'sandbox_processes_absent': True, 'background_vm_teardown': 'UNKNOWN',
        'full_build_observer_qualified': False, 'gradle_starts': 0, 'apk_builds': 0, 'G2': False}
    fixture.claim_once(root / 'verified-result.json', summary)
    fixture.event(root, 'VERIFIED_RESULT', **summary)
    print(json.dumps(summary))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'launch', 'collect'])
    parser.add_argument('--root', required=True, type=Path)
    args = parser.parse_args()
    {'prepare': prepare, 'launch': launch, 'collect': collect}[args.command](args.root, Path.home() / 'EliteSyncDev')
