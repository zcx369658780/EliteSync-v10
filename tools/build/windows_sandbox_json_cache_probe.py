"""New max1 cache observer profile. Runtime requires its own Owner approval.

Prior rejected observers, scopes and helper identities remain unchanged. JSON
is a preseeded control, and observation never claims generation or lock holding.
"""
import argparse
import difflib
import hashlib
import json
from pathlib import Path
import re
import subprocess
import uuid

import windows_sandbox_where_validation as prior
import current_product_flutter_cache_policy as policy

base, dart, cache, read = prior.base, prior.dart, prior.cache, prior.read
PARENT = Path.home() / 'EliteSyncDev/v1015-flutter-json-cache-observer-20261102'
# Owner continued the previously identified observer-adaptation + independent
# recheck step. This grant applies only to this fixed new case, max1.
RUNTIME_AUTHORIZED = True
SUCCESS = 'FLUTTER_JSON_CACHE_NEGATIVE_OBSERVATION_SUPPORTED'
PREVIOUS = prior.Profile('cache').root
PREVIOUS_SHA = {'manifest.json': '088dc3f3c375b172f7ae246cc685603d8fe57c756aeace051199e46dd7305bd0',
                'output/result.json': 'e562a61767c2a9faffb3d56460b6f43a5f651c66b28657b5cb741fd2e6ffd053',
                'verified-result.json': '5b615932f96198d61cef06e0d80d2624b76755f1d24f007dda8489d5d42f9131'}
VERSION_ROLE = 'bin/cache/flutter.version.json'


def profile():
    p = prior.Profile('cache')
    p.parent, p.root = PARENT, PARENT / 'case01'
    p.mode, p.kind = 'flutter-json-cache-negative', 'flutter-json-cache-negative-probe'
    return p


def contract():
    return {**prior.contract(profile()), 'legacy_policy': 'PINNED_SOURCE_DEFAULT_OMIT',
            'json_source': 'PRESEEDED_CONTROL', 'runtime_authorized': RUNTIME_AUTHORIZED}


def helpers():
    return list(dict.fromkeys([Path(__file__).resolve(), Path(policy.__file__), *prior.helpers()]))


def prerequisites():
    evidence = prior.prerequisites(prior.Profile('cache'))
    records = {}
    for name, digest in PREVIOUS_SHA.items():
        data = prior.pinned(PREVIOUS / name, 8 * 1024 ** 2)
        if hashlib.sha256(data).hexdigest() != digest: raise ValueError('Prior rejection evidence drift')
        records[name] = json.loads(data)
    r = records['verified-result.json']
    if (r.get('status') != 'REJECTED' or r.get('tool_qualified') is not False
            or r.get('cache_state') is not None or r.get('producer_entry_allowed') is not False or r.get('G2') is not False):
        raise ValueError('Prior rejected scope must remain rejected')
    return {**evidence, 'pins': evidence['pins'] + [{'host': str(PREVIOUS / name), 'sha256': digest} for name, digest in PREVIOUS_SHA.items()]}


def metadata_bytes(root, sources):
    expected = next(row['sha256'] for row in sources if row['role'] == VERSION_ROLE)
    data = read(root / 'fixture' / VERSION_ROLE, policy.METADATA_LIMIT)
    # This validates PREPARATION metadata, using a declared schema fixture only.
    # Real guest observations are independently required by classify().
    policy.validate_cache_observation(data, expected, dict(policy.OBSERVATION))
    return data, expected


def check_reused_inputs(rows, sources):
    data = prior.pinned(PREVIOUS / 'manifest.json', 8 * 1024 ** 2)
    if hashlib.sha256(data).hexdigest() != PREVIOUS_SHA['manifest.json']: raise ValueError('Fixed prior input manifest drift')
    original = json.loads(data)
    selected = lambda values: [row for row in values if row['path'].startswith('C:\\Inputs\\DartSdk\\') or row['path'].startswith('C:\\Inputs\\FlutterControls\\')]
    if selected(rows) != selected(original['inputs']) or sources != original['source_pins']:
        raise ValueError('Reused VM SDK/control paths, bytes or source identities drifted')


def native_source(evidence, expected_metadata_sha):
    if type(expected_metadata_sha) is not str or not re.fullmatch('[0-9a-f]{64}', expected_metadata_sha): raise ValueError('Exact metadata pin required')
    raw, upstream, _, upstream_report = prior.native_source(profile(), evidence)
    start, end = b'    static object ReadCacheState() {', b'    static string BoundedOSImageHash(string path) {'
    if upstream.count(start) != 1 or upstream.count(end) != 1: raise ValueError('Unique observer replacement boundaries required')
    replacement = r'''    internal static void RequireCacheFileShape(long bytes,uint attributes,uint links,bool empty) {
        if((attributes&0x410)!=0||links!=1||bytes<0||bytes>32768||(empty?bytes!=0:bytes==0))throw new SafetyStop("CACHE_OBSERVATION_FILE_SHAPE");
    }
    static bool SameCacheIdentity(FileIdentityNative a,FileIdentityNative b) {
        return a.volume==b.volume&&FileId(a)==FileId(b)&&a.sizeHigh==b.sizeHigh&&a.sizeLow==b.sizeLow&&a.writeHigh==b.writeHigh&&a.writeLow==b.writeLow&&a.links==b.links;
    }
    internal static void RequireVersionMetadata(Dictionary<string,object> value,string actual,string expected) {
        if(expected==null||!System.Text.RegularExpressions.Regex.IsMatch(expected,"\\A[0-9a-f]{64}\\z")||actual!=expected||value==null||!value.ContainsKey("frameworkVersion")||!value.ContainsKey("frameworkRevision")||!value.ContainsKey("dartSdkVersion")
           ||!(value["frameworkVersion"] is string)||!(value["frameworkRevision"] is string)||!(value["dartSdkVersion"] is string)
           ||(string)value["frameworkVersion"]!="3.41.7"||(string)value["frameworkRevision"]!="cc0734ac716fbb8b90f3f9db8020958b1553afa7"||(string)value["dartSdkVersion"]!="3.11.5")throw new SafetyStop("CACHE_METADATA_IDENTITY_DRIFT");
    }
    static object ReadCacheState() {
        const string lockPath=@"C:\BuildWork\Flutter\bin\cache\lockfile";
        const string metadataPath=@"C:\BuildWork\Flutter\bin\cache\flutter.version.json";
        const string legacyPath=@"C:\BuildWork\Flutter\version";
        Canonical(lockPath);Canonical(metadataPath);
        using(var lockFile=new FileStream(lockPath,FileMode.Open,FileAccess.Read,FileShare.Read))
        using(var metadataFile=new FileStream(metadataPath,FileMode.Open,FileAccess.Read,FileShare.Read)) {
            var lockBefore=FileIdentity(lockFile.SafeFileHandle.DangerousGetHandle());
            var metadataBefore=FileIdentity(metadataFile.SafeFileHandle.DangerousGetHandle());
            RequireCacheFileShape(lockFile.Length,lockBefore.attributes,lockBefore.links,true);
            RequireCacheFileShape(metadataFile.Length,metadataBefore.attributes,metadataBefore.links,false);
            var bytes=new byte[(int)metadataFile.Length];int count=0,read;
            while(count<bytes.Length&&(read=metadataFile.Read(bytes,count,bytes.Length-count))>0)count+=read;
            if(count!=bytes.Length||metadataFile.ReadByte()!=-1)throw new SafetyStop("CACHE_METADATA_READ_DRIFT");
            string digest;using(var sha=SHA256.Create())digest=BitConverter.ToString(sha.ComputeHash(bytes)).Replace("-","").ToLowerInvariant();
            var value=Json.Deserialize<Dictionary<string,object>>(new UTF8Encoding(false,true).GetString(bytes));
            RequireVersionMetadata(value,digest,"EXPECTED_METADATA_SHA");
            bool legacyExists;
            try {File.GetAttributes(legacyPath);legacyExists=true;}catch(FileNotFoundException){legacyExists=false;}
            var lockAfter=FileIdentity(lockFile.SafeFileHandle.DangerousGetHandle());
            var metadataAfter=FileIdentity(metadataFile.SafeFileHandle.DangerousGetHandle());
            if(!SameCacheIdentity(lockBefore,lockAfter)||!SameCacheIdentity(metadataBefore,metadataAfter)||lockFile.Length!=0||metadataFile.Length!=bytes.Length)throw new SafetyStop("CACHE_OBSERVATION_IDENTITY_DRIFT");
            Canonical(lockPath);Canonical(metadataPath);
            return new {lock_exists=true,lock_bytes=lockFile.Length,lock_reparse=false,lock_identity_stable=true,legacy_version_file_exists=legacyExists,
                        version_metadata_sha256=digest,version_metadata_bytes=bytes.Length,metadata_source="PRESEEDED_CONTROL"};
        }
    }
'''.replace('EXPECTED_METADATA_SHA', expected_metadata_sha).encode()
    generated = upstream[:upstream.index(start)] + replacement + upstream[upstream.index(end):]
    patch = ''.join(difflib.unified_diff(raw.decode().splitlines(True), generated.decode().splitlines(True), fromfile='fixed-cache-base', tofile='json-cache-observer')).encode()
    report = {'base_sha256': upstream_report['base_sha256'], 'upstream_report': upstream_report,
              'observer_replacements': 1, 'generated_sha256': hashlib.sha256(generated).hexdigest(),
              'patch_sha256': hashlib.sha256(patch).hexdigest(), 'expected_metadata_sha256': expected_metadata_sha}
    return raw, generated, patch, report


def prepare(root):
    p = profile(); root = prior.owned(p, root, False); evidence = prerequisites(); root.mkdir()
    for name in ['probe', 'fixture', 'output', 'host-compile-temp']: (root / name).mkdir()
    sources = cache.capture_controls(root); _, digest = metadata_bytes(root, sources)
    raw, generated, patch, report = native_source(evidence, digest)
    for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/WhereValidationProbe.cs', generated)]: base.write(root / name, data)
    base.put(root / 'native-source-report.json', report)
    compiler = dart.compiler_identity()
    query = "$s=Get-AuthenticodeSignature -LiteralPath '" + str(dart.COMPILER).replace("'", "''") + "';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch 'Microsoft Windows'){exit 1}"
    if subprocess.run(['pwsh', '-NoProfile', '-Command', query], capture_output=True, timeout=30).returncode or dart.compiler_identity() != compiler: raise ValueError('Compiler signature/identity mismatch')
    r = subprocess.run([str(dart.COMPILER), '/nologo', '/target:winexe', '/platform:x64', '/r:System.Web.Extensions.dll', '/out:' + str(root / 'probe/WhereValidationProbe.exe'), str(root / 'probe/WhereValidationProbe.cs')], cwd=root, env=prior.layout.compiler_environment(root), capture_output=True, timeout=60)
    base.write(root / 'csc.stdout', r.stdout); base.write(root / 'csc.stderr', r.stderr); base.put(root / 'csc-exit.json', {'exit_code': r.returncode})
    if r.returncode or dart.compiler_identity() != compiler: raise ValueError('Compile failed/compiler drift')
    rows, bindings = prior.inputs(p, root, evidence)
    check_reused_inputs(rows, sources)
    m = {**contract(), 'nonce': uuid.uuid4().hex, 'inputs': rows, 'bindings': bindings, 'images': prior.images(p, rows, evidence),
         'source_bytes': sum(row['bytes'] for row in bindings), 'prerequisites': evidence, 'source_pins': sources,
         'legacy_version': cache.provenance(root, sources, bindings), 'metadata_sha256': digest,
         'compiler_identity': compiler, 'helper_pins': {str(path): prior.layout.safe_file(path) for path in helpers()}, 'native_report': report,
         'binary_sha256': next(row['sha256'] for row in rows if row['path'] == prior.SELF)}
    base.put(root / 'manifest.json', m); base.put(root / 'probe/manifest.json', m); base.write(root / 'probe.wsb', prior.config(p, root, m['nonce']).encode())
    return m


def frozen(root):
    p = profile(); root = prior.owned(p, root); m = json.loads(read(root / 'manifest.json', 8 * 1024 ** 2)); evidence = prerequisites()
    if (type(m.get('nonce')) is not str or not re.fullmatch('[0-9a-f]{32}', m['nonce'])
            or any(base.data_sha(m.get(k)) != base.data_sha(v) for k, v in contract().items())
            or m['prerequisites'] != evidence or m['compiler_identity'] != dart.compiler_identity()
            or m['helper_pins'] != {str(path): prior.layout.safe_file(path) for path in helpers()}): raise ValueError('Profile/helper/compiler/prerequisite drift')
    rows, bindings = prior.inputs(p, root, evidence)
    check_reused_inputs(rows, m['source_pins'])
    _, digest = metadata_bytes(root, m['source_pins']); raw, generated, patch, report = native_source(evidence, digest)
    if (m['source_pins'] != cache.sources() or m['legacy_version'] != cache.provenance(root, m['source_pins'], bindings)
            or m['metadata_sha256'] != digest or m['native_report'] != report or json.loads(read(root / 'native-source-report.json', 65536)) != report
            or any(read(root / name, 256 * 1024) != data for name, data in [('base-native-source.cs', raw), ('native-source.patch', patch), ('probe/WhereValidationProbe.cs', generated)])):
        raise ValueError('Control provenance/native source/patch drift')
    if (m['inputs'] != rows or m['bindings'] != bindings or m['images'] != prior.images(p, rows, evidence)
            or type(m.get('source_bytes')) is not int or m['source_bytes'] != sum(row['bytes'] for row in bindings)
            or m['binary_sha256'] != next(row['sha256'] for row in rows if row['path'] == prior.SELF)): raise ValueError('Complete inputs/images/binary drift')
    if (read(root / 'manifest.json', 8 * 1024 ** 2) != read(root / 'probe/manifest.json', 8 * 1024 ** 2)
            or read(root / 'probe.wsb', 65536).decode() != prior.config(p, root, m['nonce'])): raise ValueError('Guest manifest/config drift')
    return root, m


def launch(root):
    if RUNTIME_AUTHORIZED is not True: raise ValueError('Independent max1 runtime approval is not recorded; no claim created')
    root, m = frozen(root); p = profile()
    if any((root / 'output').iterdir()) or (root / 'launch.claim.json').exists() or (root / 'launched.json').exists(): raise ValueError('Fresh unconsumed case required')
    dart.absent(); digest = base.sha(root / 'manifest.json'); base.put(root / 'launch.claim.json', prior.claim(p, m, digest))
    try: r = subprocess.run(['pwsh', '-NoProfile', '-File', str(dart.LAUNCHER), '-ConfigPath', str(root / 'probe.wsb')], capture_output=True, timeout=30)
    except subprocess.TimeoutExpired as error:
        base.write(root / 'launcher.stdout', error.stdout or b''); base.write(root / 'launcher.stderr', error.stderr or b'')
        base.put(root / 'launcher-exit.json', {'exit_code': None, 'status': 'TIMEOUT_CLAIM_CONSUMED'}); raise
    base.write(root / 'launcher.stdout', r.stdout); base.write(root / 'launcher.stderr', r.stderr); base.put(root / 'launcher-exit.json', {'exit_code': r.returncode})
    if r.returncode: raise ValueError('Launch failed; permanent claim consumed')
    launched = json.loads(r.stdout.decode('utf-8-sig'))
    if type(launched.get('pid')) is not int or launched['pid'] <= 0 or not launched.get('creationUtc'): raise ValueError('Missing host identity; no retry')
    base.put(root / 'launched.json', {**launched, 'manifest_sha256': digest})


def classify(r, m, samples, text, root):
    proof = prior.validate_receipt(profile(), r, m)
    clean = {'root_exit': 2, 'stop_reason': None, 'watchdog_stop': 0, 'job_final_empty': True, 'all_bound_handles_exited': True}
    if (r['failure'] is not None or r['native_tool_root_attempts'] != 1 or proof is None
            or r.get('kernel_file_version') != prior.vm.KERNEL_VERSION or r.get('clr_version') != prior.vm.CLR_VERSION
            or any(base.data_sha(proof.get(k)) != base.data_sha(v) for k, v in clean.items())
            or type(proof.get('root_pid')) is not int or proof['root_pid'] <= 0
            or cache.ERROR_TEXT not in text or any(not (root / 'output' / name).is_file() for name in ['tool.stdout', 'tool.stderr'])): return 'REJECTED', None
    if not all(type(row) is dict for row in samples): raise ValueError('Unknown sample schema')
    observed, allowed = {}, {row['path'].casefold() for row in m['images']}
    for row in samples:
        if row.get('operation') != 'process_image_check': continue
        pid, image = row.get('pid'), str(row.get('observed_image', '')).casefold()
        if (type(pid) is not int or pid <= 0 or image not in allowed or (pid in observed and observed[pid] != image)): return 'REJECTED', None
        observed[pid] = image
    if (len(observed) != proof['bound_members'] or observed.get(proof['root_pid']) != m['executable'].casefold()
            or prior.console.OS_IMAGE.casefold() not in observed.values()): return 'REJECTED', None
    state = r.get('cache_state'); extra = {'version_metadata_sha256', 'version_metadata_bytes', 'metadata_source'}
    if type(state) is not dict or set(state) != set(policy.OBSERVATION) | extra: return 'REJECTED', None
    data, digest = metadata_bytes(root, m['source_pins'])
    if (state['version_metadata_sha256'] != digest or type(state['version_metadata_bytes']) is not int
            or state['version_metadata_bytes'] != len(data) or state['metadata_source'] != 'PRESEEDED_CONTROL'): return 'REJECTED', None
    try: checked = policy.validate_cache_observation(data, digest, {key: state[key] for key in policy.OBSERVATION})
    except ValueError: return 'REJECTED', None
    # The pure policy's historic model status is not a runtime result. All real
    # process, source and guest-state gates above determine this profile status.
    return SUCCESS, {key: value for key, value in checked.items() if key != 'future_profile_status'}


def collect(root):
    root, m = frozen(root); dart.absent()
    r, samples, text = prior.read_run(profile(), root, m); status, checked = classify(r, m, samples, text, root); frozen(root)
    result = {'status': status, 'tool_qualified': status == SUCCESS, 'proof': r['proof'], 'failure': r['failure'], 'cache_state': r.get('cache_state'),
              'observation_policy': checked, 'metadata_source': 'PRESEEDED_CONTROL', 'metadata_generation': 'NOT_PROVEN', 'tool_metadata_consumption': 'NOT_DIRECTLY_OBSERVED',
              'legacy_feature_flag': 'NOT_DIRECTLY_OBSERVED', 'cache_lock_held': 'NOT_DIRECTLY_OBSERVED',
              'expected_error_observed': cache.ERROR_TEXT in text, 'where_image_observed': any(row.get('operation') == 'process_image_check' and str(row.get('observed_image', '')).casefold() == prior.WHERE.casefold() for row in samples),
              'manifest_sha256': base.sha(root / 'manifest.json'), 'receipt_sha256': base.sha(root / 'output/result.json'),
              'producer_entry_allowed': False, 'gradle_allowed': False, 'apk_allowed': False, 'device_allowed': False, 'media_allowed': False,
              'BAT': 'NOT_PROVEN', 'full_native_tree': 'NOT_PROVEN', 'APK': 'NOT_PROVEN', 'G2': False, 'apk_builds': 0}
    base.put(root / 'verified-result.json', result); return result


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('action', choices=['prepare', 'launch', 'collect']); parser.add_argument('--root', type=Path, required=True)
    args = parser.parse_args(argv); print(json.dumps({'prepare': prepare, 'launch': launch, 'collect': collect}[args.action](args.root)))


if __name__ == '__main__': main()
