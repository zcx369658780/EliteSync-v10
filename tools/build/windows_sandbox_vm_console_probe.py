"""One independent VM/source run with one exactly pinned guest console image.

Historical console qualification is a prerequisite, not fresh VM/Flutter proof.
No stock SDK writes, Flutter, Gradle, producer, device, or media entry is allowed.
"""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_stdio_probe as stdio
import windows_sandbox_console_qualification as console

dart, base, layout, inventory = stdio.dart, stdio.base, stdio.layout, stdio.inventory
PARENT = Path.home() / 'EliteSyncDev/v1015-vm-source-qualified-console-20261102'
BASELINE = console.PARENT / 'case01'
BASELINE_SHA = {
    'manifest.json': '582273e3c978a03e4ce1de2d7ac2346a8c1e9d7c58d627185acf1533ab8a7e1a',
    'output/result.json': '5d29b0868ca85a268025536bf6a0c3fd6ca822e9ab5cfb689c0bf1592d27fd18',
    'verified-result.json': '5b8bd015e9d3d15ad45d7bedfa4f4038b23020fb4140adf5b9559d32ec8c4545',
}
EXE, SCRIPT, LAUNCHER = stdio.EXE, stdio.SCRIPT, stdio.LAUNCHER
PROBE_EXE = r'C:\Probe\StdioProbe.exe'
MODE, KIND = 'vm-source-qualified-console', 'vm-source-qualified-console-probe'
SUCCESS = 'VM_SOURCE_WITH_PINNED_CONSOLE_SUPPORTED'
KERNEL_VERSION = '10.0.26100.6713 (WinBuild.160101.0800)'
CLR_VERSION = '4.0.30319.42000'
read = stdio.bounded_read


def baseline():
    records = {}
    for name, expected in BASELINE_SHA.items():
        data = stdio.pinned_bytes(BASELINE / name, 1024 * 1024)
        if hashlib.sha256(data).hexdigest() != expected:
            raise ValueError('Historical console qualification evidence drift')
        records[name] = json.loads(data)
    m, receipt, result = (records[n] for n in BASELINE_SHA)
    proof = console.validate_receipt(receipt, m)
    clean = {'root_exit': 0, 'stop_reason': None, 'bound_members': 2, 'watchdog_stop': 0,
             'job_final_empty': True, 'all_bound_handles_exited': True}
    if (receipt['failure'] is not None or proof is None
            or receipt.get('kernel_file_version') != KERNEL_VERSION or receipt.get('clr_version') != CLR_VERSION
            or any(base.data_sha(proof.get(k)) != base.data_sha(v) for k, v in clean.items())
            or result.get('status') != 'CONSOLE_JOB_SYNTHETIC_QUALIFICATION_SUPPORTED'
            or result.get('tool_qualified') is not True
            or result.get('manifest_sha256') != BASELINE_SHA['manifest.json']
            or result.get('receipt_sha256') != BASELINE_SHA['output/result.json']
            or result.get('proof') != proof
            or any(result.get(k) is not False for k in ['producer_entry_allowed', 'console_execution_allowed',
                       'vm_execution_allowed', 'flutter_execution_allowed', 'G2'])
            or [row for row in m['inputs'] if row.get('kind')] != [console.guest_pin()]):
        raise ValueError('Historical console role qualification not supported')
    metadata = console.prior.validate_inventory(result['inventory'])
    if metadata['sha256'] != console.OS_SHA:
        raise ValueError('Historical guest OS image mismatch')
    console.validate_synthetic(result['synthetic'], proof)
    return [{'host': str(BASELINE / name), 'sha256': digest} for name, digest in BASELINE_SHA.items()]


def contract():
    return {**stdio.contract(), 'kind': KIND, 'mode': MODE,
            'kernel_file_version': KERNEL_VERSION, 'clr_version': CLR_VERSION,
            'console_role_only': True, 'flutter_execution_allowed': False,
            'device_allowed': False, 'media_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), *stdio.helpers(), *console.helpers()]))


def owned(root, existing=True):
    root = Path(root)
    if root != PARENT / 'case01' or not root.is_absolute():
        raise ValueError('Only the new independent fixed case01 is allowed')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        if not stat.S_ISDIR(inventory._checked_stat(path).st_mode):
            raise ValueError('Real owned directory required')
    if existing:
        dart.common.validate_root(root, PARENT)
        if any((root / 'fixture').iterdir()):
            raise ValueError('Unmapped fixture must remain empty')
    elif root.exists() or root.is_symlink():
        raise ValueError('Independent one-shot case already exists; no reset')
    return root


def config(root, nonce):
    owned(root)
    tree = ET.fromstring(dart.common.configuration(root, nonce, PARENT))
    folders = tree.find('MappedFolders'); folders.remove(folders.findall('MappedFolder')[1])
    if not stat.S_ISDIR(inventory._checked_stat(stdio.SDK).st_mode):
        raise ValueError('Real existing SDK required')
    folder = ET.SubElement(folders, 'MappedFolder')
    for key, value in [('HostFolder', str(stdio.SDK)), ('SandboxFolder', r'C:\Inputs\DartSdk'), ('ReadOnly', 'true')]:
        ET.SubElement(folder, key).text = value
    tree.find('LogonCommand/Command').text = PROBE_EXE + ' ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def native_source():
    raw, qualified, _, prior_report = console.native_source()
    if hashlib.sha256(qualified).hexdigest() != '5d256972d4cbc1ed36e593ea97f1d64fb903706b7a50de023b2b7bfe6d1b5ce8':
        raise ValueError('Reviewed console supervisor source drift')
    substitutions = [
        (r'const string Self=@"C:\Probe\ConsoleQualificationProbe.exe"', r'const string Self=@"' + PROBE_EXE + '"'),
        ('(string)m["mode"]!="console-execution-qualification"', '(string)m["mode"]!="' + MODE + '"'),
        ('(string)m["executable"]!=@"' + console.EXE + '"', '(string)m["executable"]!=@"' + EXE + '"'),
        ('(string)m["command_line"]!=@"' + console.contract()['command_line'] + '"',
         '(string)m["command_line"]!=@"' + contract()['command_line'] + '"'),
        ('kind="console-execution-qualification-probe"', 'kind="' + KIND + '"'),
        ('SourcePins(m);proof=Supervise(m);',
         'SourcePins(m);if(FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion!="' + KERNEL_VERSION
         + '"||Environment.Version.ToString()!="' + CLR_VERSION + '")throw new SafetyStop("QUALIFIED_ENVIRONMENT_DRIFT");proof=Supervise(m);'),
    ]
    generated = qualified
    for old, new in substitutions:
        if generated.count(old.encode()) != 1:
            raise ValueError('Every new native substitution must match once')
        generated = generated.replace(old.encode(), new.encode(), 1)
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True),
                    fromfile='fixed-base', tofile='private-vm-console')).encode()
    report = {'base_sha256': stdio.BASE_SHA, 'console_source_sha256': prior_report['generated_sha256'],
              'generated_sha256': hashlib.sha256(generated).hexdigest(), 'patch_sha256': hashlib.sha256(patch).hexdigest(),
              'console_replacement_counts': prior_report['replacement_counts'], 'replacement_counts': [1] * len(substitutions)}
    return raw, generated, patch, report


def inputs(root):
    rows, bindings = stdio.inputs(root)
    return rows + [console.guest_pin()], bindings


def images(rows):
    return [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)},
            {'path': console.OS_IMAGE, 'sha256': console.OS_SHA}]


def prepare(root):
    root = owned(root, False); evidence = baseline(); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']: (root / name).mkdir()
    raw, generated, patch, report = native_source()
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/StdioProbe.cs', generated),
                       ('probe/stdio_stage_probe.dart', stdio.pinned_bytes(SCRIPT, 16384))]:
        base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler:
        raise ValueError('Existing compiler signature/identity mismatch')
    r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll',
                        '/out:' + str(root / 'probe/StdioProbe.exe'), str(root / 'probe/StdioProbe.cs')],
                       env=layout.compiler_environment(root), cwd=root, capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', r.stdout); base.write(root / 'csc.stderr', r.stderr)
    base.put(root / 'csc-exit.json', {'exit_code': r.returncode})
    if r.returncode or dart.compiler_identity() != compiler:
        raise ValueError('Compile failed/compiler drift')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'images': images(rows),
         'source_bytes': sum(row['bytes'] for row in bindings), 'baseline_pins': evidence, 'compiler_identity': compiler,
         'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == PROBE_EXE), 'dartvm_authenticode_status': 'NotSigned'}
    if base.sha(root / 'probe/stdio_stage_probe.dart') != m['helper_pins'][str(SCRIPT)]['sha256'] or baseline() != evidence:
        raise ValueError('Script/baseline drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'vm-console.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    m = json.loads(read(root / 'manifest.json', 8 * 1024 ** 2))
    if (type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce'])
            or m.get('dartvm_authenticode_status') != 'NotSigned'
            or any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items())
            or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()}
            or m['compiler_identity'] != dart.compiler_identity() or m['baseline_pins'] != baseline()):
        raise ValueError('Fixed profile/helper/compiler/baseline drift')
    raw, generated, patch, report = native_source()
    if (m['native_report'] != report or json.loads(read(root / 'native-source-report.json', 65536)) != report
            or any(read(root / name, 256 * 1024) != data for name, data in [('base-native-source.cs', raw),
                         ('native-source.patch', patch), ('probe/StdioProbe.cs', generated)])
            or read(root / 'probe/stdio_stage_probe.dart', 16384) != stdio.pinned_bytes(SCRIPT, 16384)):
        raise ValueError('Base/generated/source/patch trace drift')
    rows, bindings = inputs(root)
    if (m['inputs'] != rows or m['bindings'] != bindings or m['images'] != images(rows)
            or type(m.get('source_bytes')) is not int or m['source_bytes'] != sum(row['bytes'] for row in bindings)
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == PROBE_EXE)):
        raise ValueError('Complete SDK/unique guest OS pin/images/source bytes drift')
    if (read(root / 'manifest.json', 8 * 1024 ** 2) != read(root / 'probe/manifest.json', 8 * 1024 ** 2)
            or read(root / 'vm-console.wsb', 65536).decode() != config(root, m['nonce'])):
        raise ValueError('Guest manifest/config drift')
    return root, m


def claim(m, digest):
    return {**dart.claim(m, digest), 'mode': MODE, 'producer_entry_allowed': False, 'console_role_only': True}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists():
        raise ValueError('Fresh unconsumed independent case required')
    dart.absent(); digest = base.sha(root / 'manifest.json')
    base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'vm-console.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr)
    base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; claim permanently consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'):
        raise ValueError('No bound host launch identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_receipt(r, m):
    if type(r) is not dict or r.get('kind') != KIND or r.get('mode') != MODE:
        raise ValueError('New VM receipt identity required')
    # PrepareInputs may finish before SourcePins/environment validation fails.
    # Preserve that full-input bootstrap failure; it can only seal REJECTED.
    adapted = {**r, 'kind': 'console-execution-qualification-probe', 'mode': 'console-execution-qualification'}
    if (r.get('proof') is None and type(r.get('native_tool_root_attempts')) is int
            and r['native_tool_root_attempts'] == 0 and type(r.get('failure')) is str and r['failure']
            and type(r.get('input_files')) is int and r['input_files'] == len(m['inputs'])):
        adapted['input_files'] = 0
    return console.validate_receipt(adapted, m)


def classify(r, proof, stages, samples):
    clean = {'root_exit': 0, 'stop_reason': None, 'bound_members': 2, 'watchdog_stop': 0,
             'job_final_empty': True, 'all_bound_handles_exited': True}
    if (r['failure'] is not None or r['native_tool_root_attempts'] != 1 or proof is None or not stages['complete']
            or r.get('kernel_file_version') != KERNEL_VERSION or r.get('clr_version') != CLR_VERSION
            or any(base.data_sha(proof.get(k)) != base.data_sha(v) for k, v in clean.items())
            or type(proof.get('root_pid')) is not int or proof['root_pid'] <= 0):
        return 'REJECTED'
    if not all(type(row) is dict for row in samples): raise ValueError('Unknown sample schema')
    expected = {EXE.casefold(), console.OS_IMAGE.casefold()}
    checked = [row for row in samples if row.get('operation') == 'process_image_check']
    if any(str(row.get('observed_image', '')).casefold() not in expected for row in checked): return 'REJECTED'
    if not any(type(row.get('pid')) is int and row['pid'] > 0 and row['pid'] != proof['root_pid']
               and str(row.get('observed_image', '')).casefold() == console.OS_IMAGE.casefold() for row in checked): return 'REJECTED'
    if not any(type(row.get('pid')) is int and row['pid'] == proof['root_pid']
               and str(row.get('observed_image', '')).casefold() == EXE.casefold() for row in checked): return 'REJECTED'
    return SUCCESS


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    record = lambda name: json.loads(read(root / name, 1024 * 1024))
    if (base.data_sha(record('launch.claim.json')) != base.data_sha(claim(m, digest))
            or base.data_sha(record('launcher-exit.json')) != base.data_sha({'exit_code': 0})):
        raise ValueError('Claim/manifest/launcher exit mismatch')
    launched, raw = record('launched.json'), json.loads(read(root / 'launcher.stdout', 65536).decode('utf-8-sig'))
    read(root / 'launcher.stderr', 65536)
    if (type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc')
            or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched)):
        raise ValueError('Host identity chain mismatch')
    receipt = record('output/result.json'); proof = validate_receipt(receipt, m)
    stages = stdio.markers(root / 'output/stdio-stages.jsonl')
    sample_path = root / 'output/samples.jsonl'
    samples = [json.loads(line) for line in read(sample_path, 4 * 1024 ** 2).decode().splitlines()] if sample_path.exists() else []
    status = classify(receipt, proof, stages, samples); frozen(root)
    result = {'status': status, 'tool_qualified': status == SUCCESS, 'proof': proof, 'stages': stages,
              'getter_errors': [row for row in stages['events'] if row['event'] == 'error'], 'failure': receipt['failure'],
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'), 'baseline_pins': m['baseline_pins'],
              'producer_entry_allowed': False, 'flutter_execution_allowed': False, 'gradle_allowed': False, 'apk_allowed': False,
              'device_allowed': False, 'media_allowed': False, 'wrapper': 'NOT_PROVEN', 'Flutter': 'NOT_PROVEN',
              'full_native_tree': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv)
    print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__': main()
