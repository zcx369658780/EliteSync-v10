"""Generate a version-only guest execution core; no launch, grant or claim API.

Derived from an immutable historical supervisor. Job/process observations remain
sampled, not complete process/DLL closure. This never grants producer authority.
"""
import hashlib
import json
from pathlib import PurePosixPath, PureWindowsPath
import subprocess


BASE_SHA256 = '72637d0257fc37aa1ae7dc670ae4d7efb74dc8128a20822625429f97216b0347'
CONHOST_SHA256 = 'c86146188b78e484f32cc29e2331689659943b47689a85570342044f499938ac'
ROOTS = {
    'private_flutter': r'C:\Inputs\PrivateFlutter',
    'android_build_tools_36': r'C:\Inputs\AndroidSdk\build-tools\36.0.0',
    'android_cmake_3_22_1': r'C:\Inputs\AndroidSdk\cmake\3.22.1',
    'android_ndk_28_2': r'C:\Inputs\AndroidSdk\ndk\28.2.13676358',
    'jdk_17_0_18': r'C:\Inputs\Jdk',
}
_LLVM = 'toolchains/llvm/prebuilt/windows-x86_64/bin/'
ROLES = {
    'git-shim': ('private_flutter', 'bin/mingit/cmd/git.exe', '--version'),
    'git-real': ('private_flutter', 'bin/mingit/mingw64/bin/git.exe', '--version'),
    'dart': ('private_flutter', 'bin/cache/dart-sdk/bin/dart.exe', '--version'),
    'dartvm': ('private_flutter', 'bin/cache/dart-sdk/bin/dartvm.exe', '--version'),
    'dartaotruntime': ('private_flutter', 'bin/cache/dart-sdk/bin/dartaotruntime.exe', '--version'),
    **{f'gen-snapshot-{abi}': ('private_flutter', f'bin/cache/artifacts/engine/android-{abi}-release/windows-x64/gen_snapshot.exe', '--version') for abi in ('arm', 'arm64', 'x64')},
    'aapt2-sdk': ('android_build_tools_36', 'aapt2.exe', 'version'),
    'cmake': ('android_cmake_3_22_1', 'bin/cmake.exe', '--version'),
    'ninja': ('android_cmake_3_22_1', 'bin/ninja.exe', '--version'),
    **{name: ('android_ndk_28_2', _LLVM + executable, '--version') for name, executable in [('clang', 'clang.exe'), ('clang++', 'clang++.exe'), ('lld', 'ld.lld.exe')]},
    'java': ('jdk_17_0_18', 'bin/java.exe', '-version'),
    'javac': ('jdk_17_0_18', 'bin/javac.exe', '-version'),
}
CWD = r'C:\BuildWork\Home'
DIRECTORIES = [CWD, r'C:\BuildWork\Temp']
CONHOST = r'C:\Windows\System32\conhost.exe'


def _guest(role, relative):
    from current_product_build_plan import _path
    if role not in ROOTS or type(relative) is not str or not relative:
        raise ValueError('known role and canonical relative path required')
    rel = PurePosixPath(relative)
    if (rel.is_absolute() or '..' in rel.parts or '\\' in relative or ':' in relative
            or str(rel) != relative):
        raise ValueError('canonical readset relative path required')
    path = str(PureWindowsPath(ROOTS[role]).joinpath(*relative.split('/')))
    _path(path)
    if not PureWindowsPath(path).is_relative_to(PureWindowsPath(ROOTS[role])):
        raise ValueError('readset escapes fixed role root')
    return path


def input_pins(graph):
    """Bind the caller's readset content; it is data, not runtime authority."""
    import re
    pins, seen = {}, set()
    for row in graph['images']:
        if row['role'] == 'AGP_aapt2_archive_entry':
            continue  # no qualified extracted executable path exists
        path = _guest(row['role'], row['relative_path'])
        if (path.casefold() in seen or type(row['sha256']) is not str
                or not re.fullmatch('[a-f0-9]{64}', row['sha256'])):
            raise ValueError('unique fixed input hash required')
        seen.add(path.casefold())
        pins[path] = row['sha256']
    for role, relative, _ in ROLES.values():
        if _guest(role, relative) not in pins:
            raise ValueError('a declared native role is missing from the readset')
    return pins


def role_plan(role, pins):
    root, relative, argument = ROLES[role]
    executable = _guest(root, relative)
    images = {executable: pins[executable], CONHOST: CONHOST_SHA256}
    if role == 'git-shim':
        real = _guest(*ROLES['git-real'][:2])
        images[real] = pins[real]
    environment = {
        'SystemRoot': r'C:\Windows', 'WINDIR': r'C:\Windows',
        'PATH': r'C:\Windows\System32;' + str(PureWindowsPath(executable).parent),
        'TEMP': DIRECTORIES[1], 'TMP': DIRECTORIES[1], 'HOME': CWD, 'USERPROFILE': CWD,
        'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': CWD + r'\absent-gitconfig',
    }
    return {'mode': 'native-role-version', 'role': role, 'executable': executable,
            'command_line': subprocess.list2cmdline([executable, argument]), 'cwd': CWD,
            'images': [{'path': path, 'sha256': digest} for path, digest in sorted(images.items())],
            'inputs': [{'path': path, 'sha256': digest} for path, digest in sorted(pins.items())],
            'private_directories': list(DIRECTORIES), 'environment': environment,
            'runtime_authorized': False, 'producer_allowed': False, 'G2': False}


def _replace(text, old, new):
    if text.count(old) != 1:
        raise ValueError('historical source transformation anchor is not unique')
    return text.replace(old, new, 1)


def validate_receipt(receipt, manifest, pins):
    """Reject partial/stopped proof. Caller must bind raw files and host grant.

    This pure checker does not attest a launch, grant, sampled log, cleanup or
    complete process/DLL closure and does not write an acceptance receipt.
    """
    import re
    if type(manifest) is not dict or manifest.get('role') not in ROLES:
        raise ValueError('fixed role manifest required')
    for key, length in [('nonce', 32), ('binary_sha256', 64)]:
        if type(manifest.get(key)) is not str or not re.fullmatch('[a-f0-9]{' + str(length) + '}', manifest[key]):
            raise ValueError('exact manifest identity required')
    expected = {**role_plan(manifest['role'], pins), 'runtime_authorized': True,
                'nonce': manifest['nonce'], 'binary_sha256': manifest['binary_sha256']}
    if json.dumps(manifest, sort_keys=True) != json.dumps(expected, sort_keys=True):
        raise ValueError('role manifest policy drift or runtime not authorized')
    fixed = {'schema': 1, 'kind': 'native-role-version', 'nonce': manifest['nonce'],
             'binary_sha256': manifest['binary_sha256'], 'role': manifest['role'],
             'failure': None, 'input_files': len(pins), 'native_tool_root_attempts': 1,
             'gradle_root_attempts': 0, 'apk_builds': 0, 'producer_allowed': False,
             'G2': False, 'full_process_or_DLL_closure_proven': False}
    if type(receipt) is not dict or set(receipt) != set(fixed) | {'proof'}:
        raise ValueError('exact role receipt fields required')
    if any(type(receipt[k]) is not type(v) or receipt[k] != v for k, v in fixed.items()):
        raise ValueError('role receipt identity, failure or scope mismatch')
    proof = receipt['proof']
    strict = {'root_exit': 0, 'stop_reason': None, 'job_final_empty': True,
              'all_bound_handles_exited': True, 'sampling_non_atomic': True,
              'udp_destination': 'UNKNOWN', 'disk_limit_sampled': True,
              'transient_disk_overshoot_possible': True, 'watchdog_stop': 0}
    counters = {'root_pid', 'successful_samples', 'bound_members', 'disk_scan_retries',
                'disk_scans_completed', 'disk_deleted_directory_ids',
                'disk_directory_open_retries', 'disk_directory_name_retries'}
    if type(proof) is not dict or set(proof) != set(strict) | counters:
        raise ValueError('complete bounded supervisor proof required')
    if any(type(proof[k]) is not type(v) or proof[k] != v for k, v in strict.items()):
        raise ValueError('root exit, STOP/watchdog or cleanup not supported')
    if any(type(proof[k]) is not int or proof[k] < 0 for k in counters):
        raise ValueError('integer observation counters required')
    if (proof['root_pid'] <= 0 or proof['successful_samples'] < 2 or proof['disk_scans_completed'] < 1
            or not 1 <= proof['bound_members'] <= len(expected['images'])):
        raise ValueError('incomplete or unexpected sampled member evidence')
    return {'status': 'NATIVE_ROLE_VERSION_PROCESS_SAMPLED_SUPPORTED', 'role': manifest['role'],
            'complete_process_or_DLL_closure_proven': False, 'producer_allowed': False, 'G2': False}


def generate_source(baseline, pins):
    if type(baseline) is not bytes or hashlib.sha256(baseline).hexdigest() != BASE_SHA256:
        raise ValueError('historical supervisor bytes differ; preserve consumed source')
    # Closed role templates are embedded in the compiled core, not taken from
    # the execution manifest. Only runtime_authorized may change false -> true.
    templates = {role: role_plan(role, pins) for role in ROLES}
    encoded = json.dumps(templates, sort_keys=True, separators=(',', ':'))
    embedded = '"' + encoded.replace('\\', '\\\\').replace('"', '\\"') + '"'
    policy = r'''
internal static class NativeRolePolicy {
    static readonly JavaScriptSerializer Serializer=new JavaScriptSerializer();
    static readonly Dictionary<string,object> Templates=Serializer.Deserialize<Dictionary<string,object>>(__TEMPLATES__);
    static bool Equal(object left,object right) {
        if(left==null||right==null)return left==null&&right==null;
        var a=left as Dictionary<string,object>;var b=right as Dictionary<string,object>;
        if(a!=null||b!=null)return a!=null&&b!=null&&a.Count==b.Count&&a.All(p=>b.ContainsKey(p.Key)&&Equal(p.Value,b[p.Key]));
        if(left is System.Collections.IEnumerable&&!(left is string)) {
            if(!(right is System.Collections.IEnumerable)||right is string)return false;
            var x=((System.Collections.IEnumerable)left).Cast<object>().ToArray();var y=((System.Collections.IEnumerable)right).Cast<object>().ToArray();
            return x.Length==y.Length&&x.Select((v,i)=>Equal(v,y[i])).All(v=>v);
        }
        return left.GetType()==right.GetType()&&left.Equals(right);
    }
    internal static void Validate(Dictionary<string,object> manifest) {
        object role;if(!manifest.TryGetValue("role",out role)||!(role is string)||!Templates.ContainsKey((string)role))throw new InvalidDataException("Unknown native role");
        var expected=(Dictionary<string,object>)Templates[(string)role];
        if(manifest.Count!=expected.Count+2||!manifest.ContainsKey("nonce")||!manifest.ContainsKey("binary_sha256"))throw new InvalidDataException("Exact native manifest fields required");
        foreach(var pair in expected) {
            if(pair.Key=="runtime_authorized") {
                object allowed;if(!manifest.TryGetValue(pair.Key,out allowed)||!(allowed is bool)||!(bool)allowed)throw new InvalidDataException("No runtime authorization");
            } else if(!manifest.ContainsKey(pair.Key)||!Equal(pair.Value,manifest[pair.Key]))throw new InvalidDataException("Native role policy drift: "+pair.Key);
        }
    }
}
'''.replace('__TEMPLATES__', embedded)
    text = baseline.decode('utf-8').replace('\r\n', '\n')
    text = _replace(text, r'C:\Probe\NativeToolProbe.exe', r'C:\Probe\NativeRoleProbe.exe')
    text = _replace(text,
        '        foreach(var row in Rows(m["inputs"]).Where(r=>r.ContainsKey("destination")))\n'
        '            if(Hash((string)row["destination"])!=(string)row["sha256"])throw new SafetyStop("WORK_SOURCE_DRIFT");',
        '        foreach(var row in Rows(m["inputs"]))\n'
        '            if(Hash((string)row["path"])!=(string)row["sha256"])throw new SafetyStop("INPUT_HASH_DRIFT");')
    start = text.index('    static int Main(string[] args) {')
    old_main = text[start:]
    if not old_main.endswith('    }\n}\n'):
        raise ValueError('historical Main/class closure differs')
    main = r'''    static int Main(string[] args) {
        Json.MaxJsonLength=64*1024*1024;
        if(Environment.UserName!="WDAGUtilityAccount"||args.Length!=1||!System.Text.RegularExpressions.Regex.IsMatch(args[0],"\\A[0-9a-f]{32}\\z"))return 20;
        if(!String.Equals(Process.GetCurrentProcess().MainModule.FileName,Self,StringComparison.OrdinalIgnoreCase))return 21;
        var m=Json.Deserialize<Dictionary<string,object>>(File.ReadAllText(@"C:\Probe\manifest.json"));
        if((string)m["nonce"]!=args[0]||Hash(Self)!=(string)m["binary_sha256"])return 22;
        NativeRolePolicy.Validate(m);
        if(Environment.Version.ToString()!="4.0.30319.42000"||FileVersionInfo.GetVersionInfo(Path.Combine(Environment.SystemDirectory,"kernel32.dll")).FileVersion!="10.0.26100.6713 (WinBuild.160101.0800)")return 24;
        foreach(var row in Rows(m["images"]))Images.Add((string)row["path"],(string)row["sha256"]);
        object proof=null;string failure=null;int inputs=0;
        using(Sink=new StreamWriter(new FileStream(Output+@"\samples.jsonl",FileMode.CreateNew,FileAccess.Write),new UTF8Encoding(false))) {
            try {inputs=PrepareInputs(m);SourcePins(m);proof=Supervise(m);}catch(Exception error){failure=error.GetType().FullName+": "+error.Message;Log(new{operation="bootstrap_failure",failure=failure});}
            Write("result",new{schema=1,kind="native-role-version",nonce=args[0],binary_sha256=Hash(Self),role=m["role"],proof=proof,failure=failure,input_files=inputs,native_tool_root_attempts=RootCreateAttempted?1:0,gradle_root_attempts=0,apk_builds=0,producer_allowed=false,G2=false,full_process_or_DLL_closure_proven=false});
        }
        return failure==null?0:1;
    }
}
'''
    # Host-owned lifecycle adapter will close the guest after the result; no
    # unobserved shutdown.exe process is added to this version-only command.
    return (text[:start] + main + policy).encode('utf-8')
