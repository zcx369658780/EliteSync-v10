"""Independent max1 direct-VM Flutter cache negative-path qualification.

Exact VM + guest console only; normal private cache lock, no build dispatch.
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

import windows_sandbox_vm_console_probe as vm
import windows_sandbox_flutter_cache_probe as cache

dart, base, layout, inventory = vm.dart, vm.base, vm.layout, vm.inventory
read, console = vm.read, vm.console
PARENT = Path.home() / 'EliteSyncDev/v1015-flutter-vm-qualified-console-20261102'
BASELINE = vm.PARENT / 'case01'
BASELINE_SHA = {'manifest.json': '4d0d1adf30430d246507c5e8588c99ffa91d1c01765df6fec7282158d834645d',
                'output/result.json': '3f56bdc5ac6366138107dafccfbda63c3e00e86c71d6c6ff9ef5ecd653babbcf',
                'verified-result.json': '6ca34fbda66322e76ca782d9308799b7cf50a904495392f6a1a18fa2c80dad8a'}
SOURCE_SHA = 'b31fd158cda22f9640059e12a069c25f72edde5a889c60b76f5256d561eb9722'
EXE, PROBE_EXE, LAUNCHER = vm.EXE, r'C:\Probe\FlutterCacheProbe.exe', vm.LAUNCHER
MODE, KIND = 'flutter-vm-qualified-console', 'flutter-vm-qualified-console-probe'
SUCCESS = 'FLUTTER_VM_PRIVATE_CACHE_NEGATIVE_PATH_SUPPORTED'


def baseline():
    evidence = vm.baseline()
    documents = {}
    for name, digest in BASELINE_SHA.items():
        data = vm.stdio.pinned_bytes(BASELINE / name, 8 * 1024 ** 2)
        if hashlib.sha256(data).hexdigest() != digest: raise ValueError('Prior VM evidence drift')
        documents[name] = json.loads(data)
    m, receipt, result = (documents[name] for name in BASELINE_SHA)
    proof = vm.validate_receipt(receipt, m)
    if (result.get('status') != vm.SUCCESS or result.get('tool_qualified') is not True
            or result.get('proof') != proof or not result.get('stages', {}).get('complete')
            or result.get('manifest_sha256') != BASELINE_SHA['manifest.json']
            or result.get('receipt_sha256') != BASELINE_SHA['output/result.json']
            or any(result.get(k) is not False for k in ['producer_entry_allowed', 'flutter_execution_allowed', 'G2'])):
        raise ValueError('Fixed prior VM source qualification required')
    return evidence + [{'host': str(BASELINE / name), 'sha256': digest} for name, digest in BASELINE_SHA.items()]


def contract():
    # Same snapshot negative path as the earlier CLI case; VM launcher identity
    # arguments match the verified dartdev handoff, without executing its CLI.
    args = vm.stdio.command()[:-1] + cache.contract()['arguments'][1:]
    return {**cache.contract(), 'kind': KIND, 'mode': MODE, 'executable': EXE,
            'arguments': args, 'command_line': subprocess.list2cmdline(args),
            'kernel_file_version': vm.KERNEL_VERSION, 'clr_version': vm.CLR_VERSION,
            'console_role_only': True, 'device_allowed': False, 'media_allowed': False}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), *vm.helpers(), *cache.helpers()]))


def owned(root, existing=True):
    root = Path(root)
    if root != PARENT / 'case01' or not root.is_absolute(): raise ValueError('Only independent fixed case01 allowed')
    for path in [PARENT, *PARENT.parents] + ([root] if existing else []):
        if not stat.S_ISDIR(inventory._checked_stat(path).st_mode): raise ValueError('Real owned directory required')
    if existing:
        for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
            if not stat.S_ISDIR(inventory._checked_stat(root / name).st_mode): raise ValueError('Real mapped directory required')
    elif root.exists() or root.is_symlink(): raise ValueError('One-shot case exists; no reset')
    return root


def config(root, nonce):
    owned(root)
    if not re.fullmatch('[0-9a-f]{32}', nonce): raise ValueError('Invalid nonce')
    tree = ET.Element('Configuration')
    for name in ['vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']:
        ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'ProtectedClient').text = 'Enable'; ET.SubElement(tree, 'MemoryInMB').text = '2048'
    folders = ET.SubElement(tree, 'MappedFolders')
    for host, guest, ro in [(cache.SDK, r'C:\Inputs\DartSdk', True), (root / 'probe', r'C:\Probe', True),
                             (root / 'fixture', r'C:\Inputs\FlutterControls', True), (root / 'output', r'C:\ProbeOutput', False)]:
        if not stat.S_ISDIR(inventory._checked_stat(host).st_mode): raise ValueError('Real mapping required')
        folder = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', str(host)), ('SandboxFolder', guest), ('ReadOnly', str(ro).lower())]:
            ET.SubElement(folder, key).text = value
    ET.SubElement(ET.SubElement(tree, 'LogonCommand'), 'Command').text = PROBE_EXE + ' ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def native_source():
    raw = vm.stdio.pinned_bytes(cache.SOURCE, 128 * 1024)
    if hashlib.sha256(raw).hexdigest() != SOURCE_SHA: raise ValueError('Fixed cache supervisor source drift')
    _, reviewed_console, _, _ = console.native_source()
    if hashlib.sha256(reviewed_console).hexdigest() != '5d256972d4cbc1ed36e593ea97f1d64fb903706b7a50de023b2b7bfe6d1b5ce8':
        raise ValueError('Reviewed OS hash helper source drift')
    start, end = b'    static string BoundedOSImageHash(string path) {', b'    static int Main(string[] args) {'
    if reviewed_console.count(start) != 1 or reviewed_console.count(end) != 1: raise ValueError('Unique OS helper boundaries required')
    os_helpers = reviewed_console[reviewed_console.index(start):reviewed_console.index(end)].decode()
    substitutions = [
        ('(string)m["mode"]!="flutter-cache-negative"', '(string)m["mode"]!="' + MODE + '"'),
        ('(string)m["executable"]!=@"' + dart.EXE + '"', '(string)m["executable"]!=@"' + EXE + '"'),
        ('(string)m["command_line"]!=@"' + cache.contract()['command_line'] + '"', '(string)m["command_line"]!=@"' + contract()['command_line'] + '"'),
        ('kind="flutter-cache-negative-probe"', 'kind="' + KIND + '"'),
        ('if(Hash(path)!=(string)row["sha256"])', 'if(QualifiedInputHash(row)!=(string)row["sha256"])'),
        ('if(Hash(actual)!=pin)', r'if((String.Equals(actual,@"C:\Windows\System32\conhost.exe",StringComparison.OrdinalIgnoreCase)?BoundedOSImageHash(actual):Hash(actual))!=pin)'),
        ('    static int Main(string[] args) {', os_helpers + '    static int Main(string[] args) {'),
        ('RequireFreshCache(m);proof=Supervise(m);', 'RequireFreshCache(m);if(FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion!="'
         + vm.KERNEL_VERSION + '"||Environment.Version.ToString()!="' + vm.CLR_VERSION + '")throw new SafetyStop("QUALIFIED_ENVIRONMENT_DRIFT");proof=Supervise(m);'),
    ]
    generated = raw
    for old, new in substitutions:
        if generated.count(old.encode()) != 1: raise ValueError('Every cache native substitution must match once')
        generated = generated.replace(old.encode(), new.encode(), 1)
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-cache-base', tofile='private-flutter-vm-console')).encode()
    report = {'base_sha256': SOURCE_SHA, 'os_helper_source_sha256': hashlib.sha256(reviewed_console).hexdigest(),
              'generated_sha256': hashlib.sha256(generated).hexdigest(), 'patch_sha256': hashlib.sha256(patch).hexdigest(), 'replacement_counts': [1] * len(substitutions)}
    return raw, generated, patch, report


def inputs(root):
    rows, bindings = cache.inputs(root)
    return rows + [console.guest_pin()], bindings


def images(rows):
    return vm.images(rows)


def prepare(root):
    root = owned(root, False); evidence = baseline(); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']: (root / name).mkdir()
    sources = cache.capture_controls(root)
    raw, generated, patch, report = native_source()
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/FlutterCacheProbe.cs', generated)]: base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler: raise ValueError('Compiler signature/identity mismatch')
    r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll',
                        '/out:' + str(root / 'probe/FlutterCacheProbe.exe'), str(root / 'probe/FlutterCacheProbe.cs')], cwd=root, env=layout.compiler_environment(root), capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', r.stdout); base.write(root / 'csc.stderr', r.stderr); base.put(root / 'csc-exit.json', {'exit_code': r.returncode})
    if r.returncode or dart.compiler_identity() != compiler: raise ValueError('Compile failed/compiler drift')
    rows, bindings = inputs(root)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'images': images(rows),
         'source_bytes': sum(row['bytes'] for row in bindings), 'source_pins': sources, 'legacy_version': cache.provenance(root, sources, bindings),
         'baseline_pins': evidence, 'compiler_identity': compiler, 'helper_pins': {str(path): layout.safe_file(path) for path in helpers()},
         'native_report': report, 'binary_sha256': next(row['sha256'] for row in rows if row['path'] == PROBE_EXE),
         'sdk_source': str(cache.SDK), 'dartvm_authenticode_status': 'NotSigned'}
    if baseline() != evidence: raise ValueError('Historical evidence drift')
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m)
    base.write(root / 'flutter-vm-console.wsb', config(root, m['nonce']).encode())
    return m


def frozen(root):
    root = owned(root); m = json.loads(read(root / 'manifest.json', 8 * 1024 ** 2))
    if (type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce'])
            or any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items())
            or m['baseline_pins'] != baseline() or m['compiler_identity'] != dart.compiler_identity()
            or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()}): raise ValueError('Profile/helper/compiler/baseline drift')
    raw, generated, patch, report = native_source()
    if (m['native_report'] != report or json.loads(read(root / 'native-source-report.json', 65536)) != report
            or any(read(root / name, 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/FlutterCacheProbe.cs', generated)])):
        raise ValueError('Base/generated/patch trace drift')
    rows, bindings = inputs(root)
    if (m['inputs'] != rows or m['bindings'] != bindings or m['images'] != images(rows) or m['source_pins'] != cache.sources()
            or type(m.get('source_bytes')) is not int or m['source_bytes'] != sum(row['bytes'] for row in bindings)
            or m['legacy_version'] != cache.provenance(root, m['source_pins'], bindings)
            or m['sdk_source'] != str(cache.SDK) or m['dartvm_authenticode_status'] != 'NotSigned'
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == PROBE_EXE)): raise ValueError('Complete readonly SDK/control/input identity drift')
    if (read(root / 'manifest.json', 8 * 1024 ** 2) != read(root / 'probe/manifest.json', 8 * 1024 ** 2)
            or read(root / 'flutter-vm-console.wsb', 65536).decode() != config(root, m['nonce'])): raise ValueError('Guest manifest/config drift')
    return root, m


def claim(m, digest):
    return {**dart.claim(m, digest), 'mode': MODE, 'producer_entry_allowed': False, 'console_role_only': True}


def launch(root):
    root, m = frozen(root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists(): raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', claim(m, digest))
    try:
        r = subprocess.run(['pwsh', '-NoProfile', '-File', str(LAUNCHER), '-ConfigPath', str(root / 'flutter-vm-console.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'): raise ValueError('Missing host identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_receipt(r, m):
    if type(r) is not dict or r.get('kind') != KIND or r.get('mode') != MODE: raise ValueError('New Flutter VM receipt required')
    return vm.validate_receipt({**r, 'kind': vm.KIND, 'mode': vm.MODE}, m)


def classify(receipt, proof, m, samples, text):
    # VM policy demands root0; this deliberate negative path requires exit2.
    if proof is None or type(proof.get('root_exit')) is not int or proof['root_exit'] != 2: return 'REJECTED'
    if vm.classify(receipt, {**proof, 'root_exit': 0}, {'complete': True}, samples) != vm.SUCCESS: return 'REJECTED'
    state = receipt.get('cache_state')
    expected = {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': m['legacy_version']}
    if (type(state) is not dict or any(base.data_sha(state.get(k)) != base.data_sha(v) for k, v in expected.items())
            or cache.ERROR_TEXT not in text): return 'REJECTED'
    return SUCCESS


def collect(root):
    root, m = frozen(root); dart.absent(); digest = base.sha(root / 'manifest.json')
    record = lambda name: json.loads(read(root / name, 1024 * 1024))
    if (base.data_sha(record('launch.claim.json')) != base.data_sha(claim(m, digest))
            or base.data_sha(record('launcher-exit.json')) != base.data_sha({'exit_code': 0})): raise ValueError('Claim/manifest/launcher chain mismatch')
    launched, raw = record('launched.json'), json.loads(read(root / 'launcher.stdout', 65536).decode('utf-8-sig'))
    read(root / 'launcher.stderr', 65536)
    if (type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc')
            or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched)): raise ValueError('Host identity mismatch')
    receipt = record('output/result.json'); proof = validate_receipt(receipt, m)
    sample_path = root / 'output/samples.jsonl'
    samples = [json.loads(line) for line in read(sample_path, 4 * 1024 ** 2).decode().splitlines()] if sample_path.exists() else []
    text = '\n'.join(read(root / 'output' / name, 16 * 1024 ** 2).decode() for name in ['tool.stdout', 'tool.stderr'] if (root / 'output' / name).exists())
    status = classify(receipt, proof, m, samples, text); frozen(root)
    result = {'status': status, 'tool_qualified': status == SUCCESS, 'proof': proof, 'failure': receipt['failure'],
              'cache_state': receipt.get('cache_state'), 'expected_error_observed': cache.ERROR_TEXT in text,
              'manifest_sha256': digest, 'receipt_sha256': base.sha(root / 'output/result.json'), 'baseline_pins': m['baseline_pins'],
              'producer_entry_allowed': False, 'gradle_allowed': False, 'apk_allowed': False, 'device_allowed': False, 'media_allowed': False,
              'BAT': 'NOT_PROVEN', 'cache_lock_held': 'NOT_DIRECTLY_OBSERVED', 'full_native_tree': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result)
    return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv); print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__': main()
