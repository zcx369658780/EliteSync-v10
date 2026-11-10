"""One-shot synthetic console Job qualification for an exact guest OS image."""
import argparse
import difflib
import hashlib
import json
import re
from pathlib import Path
import stat
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_console_inventory as prior

dart, base, layout, inventory = prior.dart, prior.base, prior.layout, prior.inventory
bounded_read, pinned_bytes = prior.bounded_read, prior.pinned_bytes
HERE = Path(__file__).resolve().parent
PARENT = Path.home() / 'EliteSyncDev/v1015-console-execution-qualification-20261102'
BASELINE = Path.home() / 'EliteSyncDev/v1015-console-image-inventory-20261102/case01'
SOURCE, LAUNCHER, EXE = prior.SOURCE, prior.LAUNCHER, prior.EXE
OS_IMAGE = r'C:\Windows\System32\conhost.exe'
OS_SHA = 'c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac'
BASELINE_SHA = {'output/console-image.json': 'a57728385b19a5e5f471986faa581eb6c6d9f2e8b5f82bf20e25d233b669e2cf',
                'verified-result.json': 'eae0c4d320f4e88185f98c0a92fbe737fee8b6a521b24a793c6aee2fe64fceb5'}


def baseline():
    documents = {}
    for name, expected in BASELINE_SHA.items():
        data = pinned_bytes(BASELINE / name, 65536)
        if hashlib.sha256(data).hexdigest() != expected: raise ValueError('Fixed baseline evidence SHA mismatch')
        documents[name] = json.loads(data)
    metadata = prior.validate_inventory(documents['output/console-image.json'])
    if metadata['sha256'] != OS_SHA: raise ValueError('Baseline OS image SHA mismatch')
    record = documents['verified-result.json']
    if (type(record) is not dict or record.get('status') != 'CONSOLE_OS_IMAGE_INVENTORY_SUPPORTED'
            or record.get('console_execution_allowed') is not False or record.get('producer_entry_allowed') is not False or record.get('G2') is not False):
        raise ValueError('Baseline must be read-only inventory evidence')
    return [{'host': str(BASELINE / name), 'sha256': expected} for name, expected in BASELINE_SHA.items()]


def contract():
    args = [EXE, '--synthetic-console']
    return {**prior.contract(), 'kind': 'console-execution-qualification-probe', 'mode': 'console-execution-qualification',
            'arguments': args, 'command_line': subprocess.list2cmdline(args), 'console_synthetic_qualification_only': True,
            'console_synthetic_execution_allowed': True, 'vm_execution_allowed': False, 'flutter_execution_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), Path(prior.__file__), SOURCE, *prior.helpers()]))


def owned(root, existing=True):
    root = Path(root)
    if root != PARENT / 'case01' or not root.is_absolute(): raise ValueError('Only the new fixed parent/case01 is allowed')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        if not stat.S_ISDIR(inventory._checked_stat(path).st_mode): raise ValueError('Real owned directory required')
    if existing:
        dart.common.validate_root(root, PARENT)
        if any((root / 'fixture').iterdir()): raise ValueError('Fixture stays empty and unmapped')
    elif root.exists() or root.is_symlink(): raise ValueError('Existing one-shot case cannot be reset')
    return root


def config(root, nonce):
    owned(root)
    tree = ET.fromstring(dart.common.configuration(root, nonce, PARENT))
    folders = tree.find('MappedFolders'); folders.remove(folders.findall('MappedFolder')[1])
    tree.find('LogonCommand/Command').text = r'C:\Probe\ConsoleQualificationProbe.exe ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def native_source():
    raw = pinned_bytes(dart.SOURCE, 65536)
    if hashlib.sha256(raw).hexdigest() != prior.stdio.BASE_SHA: raise ValueError('Fixed base native SHA mismatch')
    os_helpers = r'''    static string BoundedOSImageHash(string path) {
        if(!String.Equals(path,@"C:\Windows\System32\conhost.exe",StringComparison.OrdinalIgnoreCase))throw new SafetyStop("UNKNOWN_OS_IMAGE_PATH");
        Canonical(path);
        using(var file=new FileStream(path,FileMode.Open,FileAccess.Read,FileShare.Read)) {
            var before=FileIdentity(file.SafeFileHandle.DangerousGetHandle());
            if(file.Length!=1003520||(before.attributes&0x410)!=0||before.links<1)throw new SafetyStop("OS_IMAGE_SIZE_OR_TYPE_DRIFT");
            string digest;
            using(var sha=SHA256.Create())digest=BitConverter.ToString(sha.ComputeHash(file)).Replace("-","").ToLowerInvariant();
            var after=FileIdentity(file.SafeFileHandle.DangerousGetHandle());
            if(file.Length!=1003520||before.volume!=after.volume||FileId(before)!=FileId(after)||before.sizeHigh!=after.sizeHigh||before.sizeLow!=after.sizeLow||before.writeHigh!=after.writeHigh||before.writeLow!=after.writeLow||before.links!=after.links)throw new SafetyStop("OS_IMAGE_IDENTITY_DRIFT");
            Canonical(path);return digest;
        }
    }
    static string QualifiedInputHash(Dictionary<string,object> row) {
        if(!row.ContainsKey("kind"))return Hash((string)row["path"]);
        if((string)row["kind"]!="guest_os_pin")throw new SafetyStop("UNKNOWN_INPUT_KIND");
        return BoundedOSImageHash((string)row["path"]);
    }
'''
    replacements = [(r'const string Self=@"C:\Probe\NativeToolProbe.exe"', r'const string Self=@"C:\Probe\ConsoleQualificationProbe.exe"'),
                    ('(string)m["mode"]!="dart-version"', '(string)m["mode"]!="console-execution-qualification"'),
                    (r'(string)m["executable"]!=@"C:\Inputs\DartSdk\bin\dart.exe"', '(string)m["executable"]!=@"' + EXE + '"'),
                    (r'(string)m["command_line"]!=@"C:\Inputs\DartSdk\bin\dart.exe --version"', '(string)m["command_line"]!=@"' + contract()['command_line'] + '"'),
                    ('kind="native-tool-probe"', 'kind="console-execution-qualification-probe"'),
                    ('if(Hash(path)!=(string)row["sha256"])', 'if(QualifiedInputHash(row)!=(string)row["sha256"])'),
                    ('if(Hash(actual)!=pin)', r'if((String.Equals(actual,@"C:\Windows\System32\conhost.exe",StringComparison.OrdinalIgnoreCase)?BoundedOSImageHash(actual):Hash(actual))!=pin)'),
                    ('    static int Main(string[] args) {', os_helpers + '    static int Main(string[] args) {')]
    generated = raw
    for old, new in replacements:
        if generated.count(old.encode()) != 1: raise ValueError('Every native substitution must match exactly once')
        generated = generated.replace(old.encode(), new.encode(), 1)
    if len(generated) > 256 * 1024: raise ValueError('Generated source cap exceeded')
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-base', tofile='private-console-qualification')).encode()
    report = {'base_sha256': prior.stdio.BASE_SHA, 'generated_sha256': hashlib.sha256(generated).hexdigest(),
              'patch_sha256': hashlib.sha256(patch).hexdigest(), 'replacement_counts': [1] * len(replacements)}
    return raw, generated, patch, report


def guest_pin():
    return {'path': OS_IMAGE, 'sha256': OS_SHA, 'kind': 'guest_os_pin'}


def inputs(root):
    rows, bindings = prior.inputs(root)
    return rows + [guest_pin()], bindings


def images(rows):
    return [{'path': EXE, 'sha256': next(row['sha256'] for row in rows if row['path'] == EXE)}, {'path': OS_IMAGE, 'sha256': OS_SHA}]


def prepare(root):
    root = owned(root, False); evidence = baseline(); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']: (root / name).mkdir()
    raw, generated, patch, report = native_source()
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/ConsoleQualificationProbe.cs', generated),
                       ('probe/ConsoleImageInventory.cs', pinned_bytes(SOURCE, 256 * 1024))]:
        base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler:
        raise ValueError('Existing compiler signature/identity mismatch')
    for name in ['ConsoleImageInventory', 'ConsoleQualificationProbe']:
        if dart.compiler_identity() != compiler: raise ValueError('Compiler drift before compile')
        r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe' / (name + '.exe')), str(root / 'probe' / (name + '.cs'))], cwd=root, env=layout.compiler_environment(root), capture_output=True, timeout=60)
        base.write(root / (name + '.stdout'), r.stdout); base.write(root / (name + '.stderr'), r.stderr); base.put(root / (name + '-exit.json'), {'exit_code': r.returncode})
        if r.returncode or dart.compiler_identity() != compiler: raise ValueError('Compilation failed/compiler drifted')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'images': images(rows),
         'source_bytes': sum(row['bytes'] for row in bindings), 'baseline_pins': evidence, 'compiler_identity': compiler,
         'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\ConsoleQualificationProbe.exe')}
    if base.sha(root / 'probe/ConsoleImageInventory.cs') != m['helper_pins'][str(SOURCE)]['sha256'] or baseline() != evidence:
        raise ValueError('Fixture source or baseline drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'console-qualification.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root)
    for name in ['manifest.json', 'probe/manifest.json', 'console-qualification.wsb']: layout.safe_file(root / name)
    m = json.loads((root / 'manifest.json').read_bytes())
    if type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce']):
        raise ValueError('Invalid frozen qualification nonce')
    if (any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items())
            or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()} or m['compiler_identity'] != dart.compiler_identity()
            or m['baseline_pins'] != baseline()): raise ValueError('Fixed command/scope/helper/compiler/baseline drift')
    raw, generated, patch, report = native_source()
    if (m['native_report'] != report or json.loads(bounded_read(root / 'native-source-report.json', 65536)) != report
            or any(bounded_read(root / name, 65536 if name == 'base-native-source.cs' else 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/ConsoleQualificationProbe.cs', generated)])
            or bounded_read(root / 'probe/ConsoleImageInventory.cs', 256 * 1024) != pinned_bytes(SOURCE, 256 * 1024)):
        raise ValueError('Base/patch/generated/fixture source drift')
    rows, bindings = inputs(root)
    if (rows != m['inputs'] or bindings != m['bindings'] or m['images'] != images(rows)
            or type(m.get('source_bytes')) is not int or m['source_bytes'] != sum(row['bytes'] for row in bindings)
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == r'C:\Probe\ConsoleQualificationProbe.exe')):
        raise ValueError('Complete host inputs/unique guest OS pin/two images drift')
    if (root / 'manifest.json').read_bytes() != (root / 'probe/manifest.json').read_bytes() or (root / 'console-qualification.wsb').read_text() != config(root, m['nonce']):
        raise ValueError('Guest manifest/configuration drift')
    return root, m


def claim(m, digest):
    return {**prior.claim(m, digest), 'mode': 'console-execution-qualification', 'console_synthetic_qualification_only': True}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists(): raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'console-qualification.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'): raise ValueError('Missing launch identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_receipt(r, m):
    expected = {'schema': 1, 'kind': 'console-execution-qualification-probe', 'mode': 'console-execution-qualification', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'gradle_root_attempts': 0,
                'apk_builds': 0, 'G2': False, 'tool_images_pinned': True}
    if type(r) is not dict or any(k not in r or base.data_sha(r[k]) != base.data_sha(v) for k, v in expected.items()): raise ValueError('Receipt identity/counters mismatch')
    if 'failure' not in r or (r['failure'] is not None and type(r['failure']) is not str): raise ValueError('Unknown failure schema')
    proof = r.get('proof')
    attempts = r.get('native_tool_root_attempts')
    if type(attempts) is not int or attempts not in [0, 1]:
        raise ValueError('Unknown root attempts or invalid pre-spawn failure')
    if type(r.get('input_files')) is not int or r['input_files'] != (0 if proof is None else len(m['inputs'])):
        raise ValueError('Input count inconsistent with completed preparation/root attempt')
    if proof is None:
        if attempts == 0 and r['failure']: return None
        raise ValueError('Unknown bootstrap failure shape')
    if (type(proof) is not dict or any(type(proof.get(k)) is not bool for k in ['job_final_empty', 'all_bound_handles_exited'])
            or type(proof.get('bound_members')) is not int or not 0 <= proof['bound_members'] <= 64 or type(proof.get('watchdog_stop')) is not int or proof['watchdog_stop'] < 0
            or 'root_exit' not in proof or (proof['root_exit'] is not None and type(proof['root_exit']) is not int)
            or 'stop_reason' not in proof or (proof['stop_reason'] is not None and type(proof['stop_reason']) is not str)):
        raise ValueError('Unknown typed process proof')
    if (attempts == 0 or proof['bound_members'] == 0) and not (proof['root_exit'] is None and proof['stop_reason']):
        raise ValueError('Zero-member/no-root proof must explicitly report failure')
    return proof


def validate_synthetic(value, proof):
    expected = {'schema': 1, 'allocated': True, 'released': True, 'pre_execution_identity_verified': True,
                'expected_image_sha256': OS_SHA, 'hold_ms': 2000, 'root_pid': proof.get('root_pid')}
    if (type(proof.get('root_pid')) is not int or proof['root_pid'] <= 0 or type(value) is not dict or set(value) != set(expected)
            or any(base.data_sha(value[k]) != base.data_sha(v) for k, v in expected.items())):
        raise ValueError('Exact synthetic allocation/release/identity/duration/root PID proof required')
    return value


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    for name in ['launch.claim.json', 'launched.json', 'launcher-exit.json', 'launcher.stdout', 'launcher.stderr', 'output/result.json']: layout.safe_file(root / name)
    if base.data_sha(json.loads((root / 'launch.claim.json').read_bytes())) != base.data_sha(claim(m, digest)) or base.data_sha(json.loads((root / 'launcher-exit.json').read_bytes())) != base.data_sha({'exit_code': 0}): raise ValueError('Claim/manifest/launcher chain mismatch')
    launched = json.loads((root / 'launched.json').read_bytes()); raw = json.loads((root / 'launcher.stdout').read_bytes().decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc') or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched): raise ValueError('Host launch identity mismatch')
    receipt = json.loads((root / 'output/result.json').read_bytes()); proof = validate_receipt(receipt, m)
    clean = {'root_exit': 0, 'stop_reason': None, 'bound_members': 2, 'watchdog_stop': 0, 'job_final_empty': True, 'all_bound_handles_exited': True}
    status, reason, metadata, synthetic = 'REJECTED', 'NON_CLEAN_PROCESS_OR_FIXTURE_FAILURE', None, None
    if receipt['failure'] is None and proof is not None and all(base.data_sha(proof.get(k)) == base.data_sha(v) for k, v in clean.items()):
        try:
            metadata = prior.validate_inventory(json.loads(bounded_read(root / 'output/console-image.json', 16384)))
            if metadata['sha256'] != OS_SHA: raise ValueError('Fresh guest OS image hash drift')
            synthetic = validate_synthetic(json.loads(bounded_read(root / 'output/console-synthetic.json', 16384)), proof)
            samples = [json.loads(line) for line in bounded_read(root / 'output/samples.jsonl', 4 * 1024 ** 2).decode('utf-8').splitlines()]
            if not all(type(row) is dict for row in samples): raise ValueError('Unknown sample schema')
            if not any(row.get('operation') == 'process_image_check' and type(row.get('observed_image')) is str and row['observed_image'].casefold() == OS_IMAGE.casefold()
                       and type(row.get('pid')) is int and row['pid'] > 0 and row['pid'] != proof['root_pid'] for row in samples): raise ValueError('No distinct bound conhost image check observed')
            status, reason = 'CONSOLE_JOB_SYNTHETIC_QUALIFICATION_SUPPORTED', None
        except (ValueError, OSError, UnicodeError) as error: reason = type(error).__name__ + ': ' + str(error)
    frozen(root)
    result = {'status': status, 'tool_qualified': status == 'CONSOLE_JOB_SYNTHETIC_QUALIFICATION_SUPPORTED', 'reason': reason,
              'proof': proof, 'inventory': metadata, 'synthetic': synthetic, 'failure': receipt['failure'], 'baseline_pins': m['baseline_pins'],
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'), 'producer_entry_allowed': False, 'console_execution_allowed': False,
              'vm_execution_allowed': False, 'flutter_execution_allowed': False, 'gradle_allowed': False, 'apk_allowed': False, 'device_allowed': False, 'media_allowed': False,
              'VM': 'NOT_PROVEN', 'Flutter': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN', 'Gradle': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv); print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__': main()
