"""Qualify a synthetic owned process tree and socket observer, never a build."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET
import windows_sandbox_probe as common
from windows_sandbox_runtime_probe import identity
import windows_sandbox_runtime_probe as runtime_helper

HERE = Path(__file__).resolve().parent


def configuration(root, nonce, parent):
    tree = ET.fromstring(common.configuration(root, nonce, parent))
    mappings = tree.find('MappedFolders')
    mappings.remove(mappings.findall('MappedFolder')[1])
    tree.find('./LogonCommand/Command').text = r'C:\Probe\ObserverProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def prepare(root, parent):
    root = Path(root).absolute()
    if root.exists() or not root.parent.resolve().is_relative_to(parent.resolve()) or root == parent:
        raise ValueError('A new dedicated task root is required')
    root.mkdir()
    for name in ['probe', 'fixture', 'output']:
        (root / name).mkdir()
    common.validate_root(root, parent)
    nonce = uuid.uuid4().hex
    compiler = Path(os.environ.get('SystemRoot', r'C:\Windows')) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    script = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(compiler).replace("'", "''") + "'; if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    signed = subprocess.run(['pwsh', '-NoProfile', '-Command', script], capture_output=True, timeout=30)
    if signed.returncode:
        raise RuntimeError('Existing compiler signature did not qualify')
    shutil.copyfile(HERE / 'windows_sandbox_observer_probe.cs', root / 'probe/ObserverProbe.cs')
    common.event(root, 'COMPILE_PREPARE', source_sha256=common.digest(root / 'probe/ObserverProbe.cs'))
    result = subprocess.run([str(compiler), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll',
        '/out:' + str(root / 'probe/ObserverProbe.exe'), str(root / 'probe/ObserverProbe.cs')], capture_output=True, timeout=60)
    (root / 'compiler.stdout').write_bytes(result.stdout)
    (root / 'compiler.stderr').write_bytes(result.stderr)
    common.event(root, 'COMPILE_RESULT', exit=result.returncode)
    if result.returncode:
        raise RuntimeError('Existing compiler failed; diagnostics retained')
    manifest = {'schema': 1, 'kind': 'owned-tree-and-network-observer', 'nonce': nonce, 'compiler_target': 'winexe',
        'binary_sha256': common.digest(root / 'probe/ObserverProbe.exe'),
        'source_identity': identity(root / 'probe/ObserverProbe.cs'), 'binary_identity': identity(root / 'probe/ObserverProbe.exe'),
        'source_sha256': common.digest(root / 'probe/ObserverProbe.cs'), 'controller_sha256': common.digest(__file__),
        'helper_sha256': common.digest(common.__file__), 'runtime_helper_sha256': common.digest(runtime_helper.__file__),
        'launcher_sha256': common.digest(HERE / 'windows_sandbox_launch.ps1'), 'compiler_sha256': common.digest(compiler),
        'max_launches': 1, 'gradle_allowed': False, 'G2': False}
    common.claim_once(root / 'manifest.json', manifest)
    common.claim_once(root / 'probe/manifest.json', manifest)
    (root / 'qualification.wsb').write_text(configuration(root, nonce, parent), encoding='utf-8')


def frozen(root, parent):
    root = common.validate_root(root, parent)
    manifest = json.loads((root / 'manifest.json').read_bytes())
    for path, key in [(Path(__file__), 'controller_sha256'), (Path(common.__file__), 'helper_sha256'),
                      (Path(runtime_helper.__file__), 'runtime_helper_sha256'),
                      (HERE / 'windows_sandbox_launch.ps1', 'launcher_sha256'),
                      (root / 'probe/ObserverProbe.cs', 'source_sha256'), (root / 'probe/ObserverProbe.exe', 'binary_sha256')]:
        if common.digest(path) != manifest[key]:
            raise ValueError('Observer probe code drift')
    for name, key in [('ObserverProbe.cs', 'source_identity'), ('ObserverProbe.exe', 'binary_identity')]:
        if identity(root / 'probe' / name) != manifest[key]:
            raise ValueError('Observer probe file identity drift')
    if (root / 'probe/manifest.json').read_bytes() != (root / 'manifest.json').read_bytes():
        raise ValueError('Guest manifest drift')
    if (root / 'qualification.wsb').read_text() != configuration(root, manifest['nonce'], parent):
        raise ValueError('Observer configuration drift')
    return root, manifest


def launch(root, parent):
    root, manifest = frozen(root, parent)
    if any((root / 'output').iterdir()):
        raise ValueError('Output must be empty before launch')
    common.claim_once(root / 'launch.claim.json', {'nonce': manifest['nonce'], 'scope': manifest['kind'],
        'max_launches': 1, 'refundable': False, 'gradle_allowed': False, 'G2': False})
    common.event(root, 'LAUNCH_PREPARE', gradle_starts=0)
    result = subprocess.run(['pwsh', '-NoProfile', '-File', str(HERE / 'windows_sandbox_launch.ps1'),
        '-ConfigPath', str(root / 'qualification.wsb')], capture_output=True, timeout=30)
    (root / 'launcher.stdout').write_bytes(result.stdout)
    (root / 'launcher.stderr').write_bytes(result.stderr)
    common.event(root, 'LAUNCH_RESULT', exit=result.returncode)
    if result.returncode:
        raise RuntimeError('Observer launch failed; no retry/refund')
    receipt = json.loads(result.stdout.decode('utf-8-sig'))
    if type(receipt.get('pid')) is not int or not receipt.get('creationUtc'):
        raise RuntimeError('Missing host launch identity; no retry')
    common.claim_once(root / 'launched.json', receipt)
    print(json.dumps(receipt))


def validate_receipt(receipt, manifest):
    if type(receipt.get('schema')) is not int or receipt['schema'] != 1:
        raise ValueError('Unknown observer schema')
    for key, value in [('kind', 'owned-tree-and-network-observer'), ('username', 'WDAGUtilityAccount'),
                       ('nonce', manifest['nonce']), ('binary_sha256', manifest['binary_sha256'])]:
        if receipt.get(key) != value:
            raise ValueError('Observer guest identity mismatch')
    if receipt.get('failure') is not None:
        raise ValueError('Observer guest reported failure')
    proof = receipt.get('proof') or {}
    for key, value in [('bound_members', 2), ('positive_endpoint_kinds', 4), ('positive_samples', 3)]:
        if type(proof.get(key)) is not int or proof[key] != value:
            raise ValueError('Observer positive coverage incomplete')
    if type(proof.get('successful_samples')) is not int or proof['successful_samples'] < 5:
        raise ValueError('Observer sampling incomplete')
    for key in ['descendants_bound_before_resume', 'owned_job_stopped', 'all_bound_handles_exited',
                'job_final_empty', 'tcp_udp_v4_v6_api_observed', 'sampling_non_atomic']:
        if proof.get(key) is not True:
            raise ValueError('Observer proof missing or unknown: ' + key)
    if proof.get('negative_reason') != 'NON_LOOPBACK_TCP' or proof.get('udp_destination') != 'UNKNOWN' or proof.get('full_builder_qualified') is not False:
        raise ValueError('Observer stop reason or evidence boundary mismatch')
    for counter in ['gradle_starts', 'apk_builds']:
        if type(receipt.get(counter)) is not int or receipt[counter] != 0:
            raise ValueError('Unexpected or unknown build execution')
    if receipt.get('G2') is not False:
        raise ValueError('Unexpected or unknown G2 result')


def collect(root, parent):
    root, manifest = frozen(root, parent)
    claim = json.loads((root / 'launch.claim.json').read_bytes())
    launched = json.loads((root / 'launched.json').read_bytes())
    if claim.get('nonce') != manifest['nonce'] or type(launched.get('pid')) is not int:
        raise ValueError('Missing launch identity')
    validate_receipt(json.loads((root / 'output/result.json').read_bytes()), manifest)
    script = "$o=Get-Content -LiteralPath '" + str(root / 'launched.json').replace("'", "''") + "' -Raw|ConvertFrom-Json; $p=Get-Process -Id ([int]$o.pid) -ErrorAction SilentlyContinue; if($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$o.creationUtc).ToUniversalTime()){exit 1}; if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}"
    result = subprocess.run(['pwsh', '-NoProfile', '-Command', script], capture_output=True, timeout=30)
    if result.returncode:
        raise ValueError('Sandbox exit not verified')
    summary = {'status': 'SYNTHETIC_TREE_NETWORK_OBSERVER_BOUNDED_SUPPORTED',
        'receipt_sha256': common.digest(root / 'output/result.json'),
        'source_identity_unchanged': True, 'owned_launch_exited': True, 'sandbox_processes_absent': True,
        'background_vm_teardown': 'UNKNOWN', 'full_builder_qualified': False,
        'gradle_starts': 0, 'apk_builds': 0, 'G2': False}
    common.claim_once(root / 'verified-result.json', summary)
    common.event(root, 'VERIFIED_RESULT', **summary)
    print(json.dumps(summary))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['prepare', 'launch', 'collect'])
    parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args()
    {'prepare': prepare, 'launch': launch, 'collect': collect}[args.command](args.root, Path.home() / 'EliteSyncDev')
