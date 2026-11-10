"""Owner-authorized inventory -> fixed where role -> Flutter cache, max1 each.

Only this new three-stage chain is managed here. Prior controllers and ledgers
are immutable. Later stages require supported, pinned predecessor evidence.
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

import windows_sandbox_flutter_console_probe as flutter
from current_product_flutter_windows_environment import with_executable_extensions
import current_product_flutter_windows_environment as environment_policy

vm, console, cache = flutter.vm, flutter.console, flutter.cache
dart, base, layout, inventory = vm.dart, vm.base, vm.layout, vm.inventory
read, pinned = vm.read, vm.stdio.pinned_bytes
HERE = Path(__file__).resolve().parent
WHERE = r'C:\Windows\System32\where.exe'
SELF = r'C:\Probe\WhereValidationProbe.exe'
FIXTURE = r'C:\Probe\WhereInventoryFixture.exe'
PARENTS = {name: Path.home() / ('EliteSyncDev/' + task) for name, task in [
    ('inventory', 'v1015-where-image-inventory-20261102'),
    ('qualification', 'v1015-where-execution-qualification-20261102'),
    ('cache', 'v1015-flutter-pathext-cache-recheck-20261102')]}
STATUSES = {'inventory': 'WHERE_OS_IMAGE_INVENTORY_SUPPORTED',
            'qualification': 'WHERE_FIXED_NEGATIVE_LOOKUP_SUPPORTED',
            'cache': 'FLUTTER_PATHEXT_PRIVATE_CACHE_NEGATIVE_PATH_SUPPORTED'}
FIXTURE_SHA = 'bdfa51c13a99efa3a4207282e3f2ffadc8804f4088b56acdc95c0d78afeeb37f'


class Profile:
    def __init__(self, phase):
        if phase not in PARENTS: raise ValueError('Unknown authorized phase')
        self.phase, self.parent = phase, PARENTS[phase]
        self.root = self.parent / 'case01'
        self.mode = 'where-chain-' + phase
        self.kind = self.mode + '-probe'


def owned(p, root, existing=True):
    root = Path(root)
    if root != p.root or not root.is_absolute(): raise ValueError('Only the independent fixed case01 is allowed')
    for path in [p.parent, *p.parent.parents] + ([root] if existing else []):
        if not stat.S_ISDIR(inventory._checked_stat(path).st_mode): raise ValueError('Real owned directory required')
    if existing:
        for name in ['probe', 'fixture', 'output', 'host-compile-temp']:
            if not stat.S_ISDIR(inventory._checked_stat(root / name).st_mode): raise ValueError('Real owned mapping required')
        if p.phase != 'cache' and any((root / 'fixture').iterdir()): raise ValueError('Unused fixture must remain empty')
    elif root.exists() or root.is_symlink(): raise ValueError('One-shot case already exists; no reset')
    return root


def contract(p):
    env = with_executable_extensions(cache.contract()['environment'] if p.phase == 'cache' else console.prior.contract()['environment'])
    if p.phase == 'inventory': args = [FIXTURE]
    elif p.phase == 'qualification': args = [WHERE, '/Q', '__ELITESYNC_V1015_NEGATIVE_LOOKUP__']
    else: args = flutter.contract()['arguments']
    return {**dart.contract(), 'kind': p.kind, 'mode': p.mode, 'executable': args[0], 'arguments': args,
            'command_line': subprocess.list2cmdline(args), 'environment': env,
            'kernel_file_version': vm.KERNEL_VERSION, 'clr_version': vm.CLR_VERSION,
            'producer_entry_allowed': False, 'device_allowed': False, 'media_allowed': False,
            'scope': p.parent.name, 'where_execution_allowed': p.phase != 'inventory'}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), Path(environment_policy.__file__), *flutter.helpers()]))


def validate_metadata(value):
    if type(value) is not dict or value.get('path') != WHERE: raise ValueError('Exact where inventory path required')
    console.prior.validate_inventory({**value, 'path': console.OS_IMAGE})
    return value


def prerequisites(p):
    pins = flutter.baseline()
    metadata = None
    for phase in (['inventory'] if p.phase == 'qualification' else ['inventory', 'qualification'] if p.phase == 'cache' else []):
        previous = Profile(phase)
        root, m = frozen(previous, previous.root)
        result = json.loads(read(root / 'verified-result.json', 1024 * 1024))
        receipt, samples, text = read_run(previous, root, m)
        status, current = classify(previous, receipt, m, samples, text, root)
        if (status != STATUSES[phase] or result.get('status') != status or result.get('tool_qualified') is not True
                or result.get('manifest_sha256') != base.sha(root / 'manifest.json')
                or result.get('receipt_sha256') != base.sha(root / 'output/result.json')
                or result.get('producer_entry_allowed') is not False or result.get('G2') is not False):
            raise ValueError('Predecessor phase not supported; no next-stage entry')
        if phase == 'inventory':
            metadata = validate_metadata(result['inventory'])
            if metadata != current: raise ValueError('Predecessor inventory mismatch')
        for name in ['manifest.json', 'output/result.json', 'verified-result.json']:
            pins.append({'host': str(root / name), 'sha256': base.sha(root / name)})
    return {'pins': pins, 'where': metadata}


def fixture_source():
    raw = pinned(console.prior.SOURCE, 256 * 1024)
    if hashlib.sha256(raw).hexdigest() != FIXTURE_SHA: raise ValueError('Fixed inventory fixture source drift')
    generated = raw.decode().replace('\r\n', '\n')
    substitutions = [(r'const string Target=@"C:\Windows\System32\conhost.exe";', 'const string Target=@"' + WHERE + '";'),
                     (r'@"C:\Probe\ConsoleImageInventory.exe"', '@"' + FIXTURE + '"'),
                     ('bool synthetic=args.Length==1&&args[0]=="--synthetic-console";\n            if(args.Length>1||(args.Length==1&&!synthetic))return 22;', 'if(args.Length!=0)return 22;')]
    start, end = '                if(synthetic) {', '            }\n            return 0;'
    if generated.count(start) != 1 or generated.count(end) != 1: raise ValueError('Unique synthetic block boundaries required')
    generated = generated[:generated.index(start)] + generated[generated.index(end):]
    for old, new in substitutions:
        if generated.count(old) != 1: raise ValueError('Fixture substitution must match once')
        generated = generated.replace(old, new, 1)
    return generated.encode()


def os_helpers(metadata):
    return r'''    static string BoundedOSImageHash(string path) {
        long size;
        if(String.Equals(path,@"C:\Windows\System32\conhost.exe",StringComparison.OrdinalIgnoreCase))size=1003520;
        else if(String.Equals(path,@"C:\Windows\System32\where.exe",StringComparison.OrdinalIgnoreCase))size=WHERE_SIZE;
        else throw new SafetyStop("UNKNOWN_OS_IMAGE_PATH");
        Canonical(path);
        using(var file=new FileStream(path,FileMode.Open,FileAccess.Read,FileShare.Read)) {
            var before=FileIdentity(file.SafeFileHandle.DangerousGetHandle());
            if(file.Length!=size||(before.attributes&0x410)!=0||before.links<1)throw new SafetyStop("OS_IMAGE_SIZE_OR_TYPE_DRIFT");
            string digest;using(var sha=SHA256.Create())digest=BitConverter.ToString(sha.ComputeHash(file)).Replace("-","").ToLowerInvariant();
            var after=FileIdentity(file.SafeFileHandle.DangerousGetHandle());
            if(file.Length!=size||before.volume!=after.volume||FileId(before)!=FileId(after)||before.sizeHigh!=after.sizeHigh||before.sizeLow!=after.sizeLow||before.writeHigh!=after.writeHigh||before.writeLow!=after.writeLow||before.links!=after.links)throw new SafetyStop("OS_IMAGE_IDENTITY_DRIFT");
            Canonical(path);return digest;
        }
    }
    static string QualifiedInputHash(Dictionary<string,object> row) {
        if(!row.ContainsKey("kind"))return Hash((string)row["path"]);
        if((string)row["kind"]!="guest_os_pin")throw new SafetyStop("UNKNOWN_INPUT_KIND");
        return BoundedOSImageHash((string)row["path"]);
    }
'''.replace('WHERE_SIZE', str(validate_metadata(metadata)['bytes']))


def native_source(p, evidence):
    source = cache.SOURCE if p.phase == 'cache' else dart.SOURCE
    expected = flutter.SOURCE_SHA if p.phase == 'cache' else vm.stdio.BASE_SHA
    raw = pinned(source, 128 * 1024)
    if hashlib.sha256(raw).hexdigest() != expected: raise ValueError('Fixed native base drift')
    original = cache.contract() if p.phase == 'cache' else dart.contract()
    old_self = r'C:\Probe\FlutterCacheProbe.exe' if p.phase == 'cache' else r'C:\Probe\NativeToolProbe.exe'
    c = contract(p)
    subs = [('const string Self=@"' + old_self + '"', 'const string Self=@"' + SELF + '"'),
            ('(string)m["mode"]!="' + original['mode'] + '"', '(string)m["mode"]!="' + p.mode + '"'),
            ('(string)m["executable"]!=@"' + original['executable'] + '"', '(string)m["executable"]!=@"' + c['executable'] + '"'),
            ('(string)m["command_line"]!=@"' + original['command_line'] + '"', '(string)m["command_line"]!=@"' + c['command_line'] + '"'),
            ('kind="' + original['kind'] + '"', 'kind="' + p.kind + '"'),
            ('proof=Supervise(m);', 'if(FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion!="' + vm.KERNEL_VERSION
             + '"||Environment.Version.ToString()!="' + vm.CLR_VERSION + '")throw new SafetyStop("QUALIFIED_ENVIRONMENT_DRIFT");proof=Supervise(m);')]
    if p.phase != 'inventory':
        subs += [('if(Hash(path)!=(string)row["sha256"])', 'if(QualifiedInputHash(row)!=(string)row["sha256"])'),
                 ('if(Hash(actual)!=pin)', r'if((String.Equals(actual,@"C:\Windows\System32\conhost.exe",StringComparison.OrdinalIgnoreCase)||String.Equals(actual,@"C:\Windows\System32\where.exe",StringComparison.OrdinalIgnoreCase)?BoundedOSImageHash(actual):Hash(actual))!=pin)'),
                 ('    static int Main(string[] args) {', os_helpers(evidence['where']) + '    static int Main(string[] args) {')]
    generated = raw
    for old, new in subs:
        if generated.count(old.encode()) != 1: raise ValueError('Native substitution must match once')
        generated = generated.replace(old.encode(), new.encode(), 1)
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-base', tofile=p.mode)).encode()
    return raw, generated, patch, {'base_sha256': expected, 'generated_sha256': hashlib.sha256(generated).hexdigest(),
                                 'patch_sha256': hashlib.sha256(patch).hexdigest(), 'replacement_counts': [1] * len(subs)}


def guest_pins(p, evidence):
    if p.phase == 'inventory': return []
    metadata = validate_metadata(evidence['where'])
    return [console.guest_pin(), {'path': WHERE, 'sha256': metadata['sha256'], 'kind': 'guest_os_pin'}]


def inputs(p, root, evidence):
    rows, bindings = cache.inputs(root) if p.phase == 'cache' else console.prior.inputs(root)
    return rows + guest_pins(p, evidence), bindings


def images(p, rows, evidence):
    exe = contract(p)['executable']
    values = [{'path': exe, 'sha256': next(row['sha256'] for row in rows if row['path'] == exe)}]
    for row in guest_pins(p, evidence):
        if row['path'] != exe: values.append({'path': row['path'], 'sha256': row['sha256']})
    return values


def config(p, root, nonce):
    owned(p, root)
    if not re.fullmatch('[0-9a-f]{32}', nonce): raise ValueError('Invalid nonce')
    tree = ET.Element('Configuration')
    for name in ['vGPU', 'Networking', 'AudioInput', 'VideoInput', 'PrinterRedirection', 'ClipboardRedirection']: ET.SubElement(tree, name).text = 'Disable'
    ET.SubElement(tree, 'ProtectedClient').text = 'Enable'; ET.SubElement(tree, 'MemoryInMB').text = '2048'
    folders = ET.SubElement(tree, 'MappedFolders')
    mappings = [(root / 'probe', r'C:\Probe', True), (root / 'output', r'C:\ProbeOutput', False)]
    if p.phase == 'cache': mappings += [(cache.SDK, r'C:\Inputs\DartSdk', True), (root / 'fixture', r'C:\Inputs\FlutterControls', True)]
    for host, guest, ro in mappings:
        if not stat.S_ISDIR(inventory._checked_stat(host).st_mode): raise ValueError('Real mapping required')
        folder = ET.SubElement(folders, 'MappedFolder')
        for key, value in [('HostFolder', str(host)), ('SandboxFolder', guest), ('ReadOnly', str(ro).lower())]: ET.SubElement(folder, key).text = value
    ET.SubElement(ET.SubElement(tree, 'LogonCommand'), 'Command').text = SELF + ' ' + nonce
    return ET.tostring(tree, encoding='unicode') + '\n'


def prepare(p, root):
    root = owned(p, root, False); evidence = prerequisites(p); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']: (root / name).mkdir()
    sources = cache.capture_controls(root) if p.phase == 'cache' else []
    raw, generated, patch, report = native_source(p, evidence)
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/WhereValidationProbe.cs', generated)]: base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    if p.phase == 'inventory': base.write(root / 'probe/WhereInventoryFixture.cs', fixture_source())
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler: raise ValueError('Compiler signature/identity mismatch')
    for name in ['WhereValidationProbe'] + (['WhereInventoryFixture'] if p.phase == 'inventory' else []):
        if dart.compiler_identity() != compiler: raise ValueError('Compiler drift')
        r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe' / (name + '.exe')), str(root / 'probe' / (name + '.cs'))], cwd=root, env=layout.compiler_environment(root), capture_output=True, timeout=60)
        base.write(root / (name + '.stdout'), r.stdout); base.write(root / (name + '.stderr'), r.stderr); base.put(root / (name + '-exit.json'), {'exit_code': r.returncode})
        if r.returncode or dart.compiler_identity() != compiler: raise ValueError('Compile failed/compiler drift')
    rows, bindings = inputs(p, root, evidence)
    m = {**contract(p), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'images': images(p, rows, evidence),
         'source_bytes': sum(row['bytes'] for row in bindings), 'prerequisites': evidence, 'source_pins': sources,
         'legacy_version': cache.provenance(root, sources, bindings) if p.phase == 'cache' else None,
         'compiler_identity': compiler, 'helper_pins': {str(path): layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == SELF)}
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m); base.write(root / 'probe.wsb', config(p, root, m['nonce']).encode())
    return m


def frozen(p, root):
    root = owned(p, root); m = json.loads(read(root / 'manifest.json', 8 * 1024 ** 2))
    evidence = prerequisites(p)
    if (type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce'])
            or any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract(p).items())
            or m['prerequisites'] != evidence or m['compiler_identity'] != dart.compiler_identity()
            or m['helper_pins'] != {str(path): layout.safe_file(path) for path in helpers()}): raise ValueError('Profile/helper/prerequisite/compiler drift')
    raw, generated, patch, report = native_source(p, evidence)
    if (m['native_report'] != report or json.loads(read(root / 'native-source-report.json', 65536)) != report
            or any(read(root / name, 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/WhereValidationProbe.cs', generated)])):
        raise ValueError('Generated/source/patch trace drift')
    if p.phase == 'inventory' and read(root / 'probe/WhereInventoryFixture.cs', 256 * 1024) != fixture_source(): raise ValueError('Read-only fixture drift')
    rows, bindings = inputs(p, root, evidence)
    if (m['inputs'] != rows or m['bindings'] != bindings or m['images'] != images(p, rows, evidence)
            or type(m.get('source_bytes')) is not int or m['source_bytes'] != sum(row['bytes'] for row in bindings)
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == SELF)): raise ValueError('Complete inputs/images/binary drift')
    if p.phase == 'cache':
        if m['source_pins'] != cache.sources() or m['legacy_version'] != cache.provenance(root, m['source_pins'], bindings): raise ValueError('Readonly source provenance drift')
    elif m['source_pins'] != [] or m['legacy_version'] is not None: raise ValueError('No SDK controls in tool-only phase')
    if (read(root / 'manifest.json', 8 * 1024 ** 2) != read(root / 'probe/manifest.json', 8 * 1024 ** 2)
            or read(root / 'probe.wsb', 65536).decode() != config(p, root, m['nonce'])): raise ValueError('Guest manifest/config drift')
    return root, m


def claim(p, m, digest):
    return {**dart.claim(m, digest), 'mode': p.mode, 'scope': p.parent.name, 'producer_entry_allowed': False}


def launch(p, root):
    root, m = frozen(p, root)
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists(): raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', claim(p, m, digest))
    try: r = subprocess.run(['pwsh', '-NoProfile', '-File', str(dart.LAUNCHER), '-ConfigPath', str(root / 'probe.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'): raise ValueError('Missing host identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def validate_receipt(p, r, m):
    if type(r) is not dict or r.get('kind') != p.kind or r.get('mode') != p.mode: raise ValueError('Phase receipt identity mismatch')
    return vm.validate_receipt({**r, 'kind': vm.KIND, 'mode': vm.MODE}, m)


def read_run(p, root, m):
    record = lambda name: json.loads(read(root / name, 1024 * 1024))
    digest = base.sha(root / 'manifest.json')
    if (base.data_sha(record('launch.claim.json')) != base.data_sha(claim(p, m, digest)) or base.data_sha(record('launcher-exit.json')) != base.data_sha({'exit_code': 0})): raise ValueError('Launch/claim chain drift')
    launched = record('launched.json'); raw = json.loads(read(root / 'launcher.stdout', 65536).decode('utf-8-sig'))
    read(root / 'launcher.stderr', 65536)
    if (type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc') or base.data_sha({**raw, 'manifest_sha256': digest}) != base.data_sha(launched)): raise ValueError('Host identity drift')
    r = record('output/result.json'); validate_receipt(p, r, m)
    path = root / 'output/samples.jsonl'
    samples = [json.loads(line) for line in read(path, 4 * 1024 ** 2).decode().splitlines()] if path.exists() else []
    text = '\n'.join(read(root / 'output' / name, 16 * 1024 ** 2).decode() for name in ['tool.stdout', 'tool.stderr'] if (root / 'output' / name).exists())
    return r, samples, text


def classify(p, r, m, samples, text, root):
    proof = validate_receipt(p, r, m)
    expected = {'root_exit': {'inventory': 0, 'qualification': 1, 'cache': 2}[p.phase], 'stop_reason': None,
                'watchdog_stop': 0, 'job_final_empty': True, 'all_bound_handles_exited': True}
    if (r['failure'] is not None or r['native_tool_root_attempts'] != 1 or proof is None
            or r.get('kernel_file_version') != vm.KERNEL_VERSION or r.get('clr_version') != vm.CLR_VERSION
            or any(base.data_sha(proof.get(k)) != base.data_sha(v) for k, v in expected.items())
            or type(proof.get('root_pid')) is not int or proof['root_pid'] <= 0): return 'REJECTED', None
    if any(not (root / 'output' / name).is_file() for name in ['tool.stdout', 'tool.stderr']): return 'REJECTED', None
    if not all(type(row) is dict for row in samples): raise ValueError('Unknown sample schema')
    allowed = {row['path'].casefold() for row in m['images']}; checked = [row for row in samples if row.get('operation') == 'process_image_check']
    if any(str(row.get('observed_image', '')).casefold() not in allowed or type(row.get('pid')) is not int or row['pid'] <= 0 for row in checked): return 'REJECTED', None
    observed = {}
    for row in checked:
        image = row['observed_image'].casefold()
        if row['pid'] in observed and observed[row['pid']] != image: return 'REJECTED', None
        observed[row['pid']] = image
    if (len(observed) != proof['bound_members'] or observed.get(proof['root_pid']) != m['executable'].casefold()): return 'REJECTED', None
    if p.phase == 'inventory':
        if proof['bound_members'] != 1: return 'REJECTED', None
        try: metadata = validate_metadata(json.loads(read(root / 'output/console-image.json', 16384)))
        except (ValueError, OSError, UnicodeError): return 'REJECTED', None
        return STATUSES[p.phase], metadata
    if p.phase == 'qualification':
        # /Q emits no matching paths; exit1 is the intended absent-name result.
        if (not 1 <= proof['bound_members'] <= 2 or text.strip()
                or any(image != console.OS_IMAGE.casefold() for pid, image in observed.items() if pid != proof['root_pid'])
                or any(read(root / 'output' / name, 16 * 1024 ** 2) != b'' for name in ['tool.stdout', 'tool.stderr'])): return 'REJECTED', None
        return STATUSES[p.phase], None
    state = r.get('cache_state'); wanted = {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': m['legacy_version']}
    if (type(state) is not dict or any(base.data_sha(state.get(k)) != base.data_sha(v) for k, v in wanted.items())
            or cache.ERROR_TEXT not in text or console.OS_IMAGE.casefold() not in observed.values()): return 'REJECTED', None
    return STATUSES[p.phase], None


def collect(p, root):
    root, m = frozen(p, root); dart.absent()
    r, samples, text = read_run(p, root, m); status, metadata = classify(p, r, m, samples, text, root); frozen(p, root)
    result = {'status': status, 'tool_qualified': status == STATUSES[p.phase], 'inventory': metadata,
              'proof': r['proof'], 'failure': r['failure'], 'cache_state': r.get('cache_state'),
              'expected_error_observed': cache.ERROR_TEXT in text, 'manifest_sha256': base.sha(root / 'manifest.json'),
              'where_image_observed': any(row.get('operation') == 'process_image_check' and str(row.get('observed_image', '')).casefold() == WHERE.casefold() for row in samples),
              'receipt_sha256': base.sha(root / 'output/result.json'), 'prerequisites': m['prerequisites'],
              'producer_entry_allowed': False, 'gradle_allowed': False, 'apk_allowed': False, 'device_allowed': False, 'media_allowed': False,
              'BAT': 'NOT_PROVEN', 'cache_lock_held': 'NOT_DIRECTLY_OBSERVED', 'full_native_tree': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result); return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('phase', choices=list(PARENTS)); parser.add_argument('action', choices=['prepare', 'launch', 'collect'])
    parser.add_argument('--root', type=Path, required=True); args = parser.parse_args(argv)
    print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](Profile(args.phase), args.root)))


if __name__ == '__main__': main()
