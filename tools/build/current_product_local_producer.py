"""Prepare a local private AAR build; launch requires its own explicit grant.

Original Flutter/project/SDK inputs are copied. Shared Pub/JDK/Gradle inputs are
read dependencies; caches and build outputs use the private work directory.
Offline flags are used; this runner does not claim OS network isolation.
"""
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import time
import uuid

from current_product_aar_handoff import _bound_file
from current_product_tree_inventory import inventory_trees
from current_product_local_entry import render_local_entry, remap_json
import current_product_source_overlay as source_overlay
import producer_supervisor as shared

HERE = Path(__file__).resolve().parent
BOUNDARY_SHA = '0a78bdaeb663e8bd6b3eec07d4664bf3d870e55d1ecd389439cbbfe01d90982e'
SOURCE_CONTRACT_SHA = '6f5428edb2e5cc8fd7aea0d0b9808c5661190974fd0e67b3b5c3e83bd359e0bb'
DECLARED_SHA = '0b34a527161803e5b783705c3fc07b7fcf5e1818b064b3e42bd5355ea0b14af9'
LIMITS = dict(sdk_seconds=1800, host_seconds=2100, cleanup_seconds=45,
              output_bytes=2*1024**3, required_available_mib=8192)


def local_memory_policy(job_memory_gib=4):
    """Select only the approved Job limit, retaining 4 GiB host headroom."""
    if type(job_memory_gib) is not int or job_memory_gib not in (4,6):
        raise ValueError('Local Job memory must be integer 4 or 6 GiB')
    return dict(job_memory_bytes=job_memory_gib*1024**3,
                required_available_mib=(job_memory_gib+4)*1024)


def current_user():
    # Desktop tool sessions may deliberately omit USERNAME/USER environment vars.
    import ctypes
    size=ctypes.c_uint32(256);buffer=ctypes.create_unicode_buffer(size.value)
    api=ctypes.WinDLL('advapi32',use_last_error=True).GetUserNameW
    api.argtypes=[ctypes.c_wchar_p,ctypes.POINTER(ctypes.c_uint32)];api.restype=ctypes.c_int
    if not api(buffer,ctypes.byref(size)):raise ctypes.WinError(ctypes.get_last_error())
    return buffer.value


def _replace(text, old, new):
    if text.count(old)!=1:
        raise ValueError('Local boundary source anchor changed')
    return text.replace(old,new,1)


def local_boundary(raw, work, executable, java, cwd, logs, user, *, job_memory_gib=4):
    """Derive task-specific paths/identity; retain all native Job/handle code."""
    local_memory_policy(job_memory_gib)
    if hashlib.sha256(raw).hexdigest()!=BOUNDARY_SHA:
        raise ValueError('Original boundary identity differs')
    text=raw.decode('utf-8')
    def verbatim(value):return '@"'+str(value).replace('"','""')+'"'
    text=_replace(text,r'const string Work=@"C:\BuildWork", Self=@"C:\Probe\ProducerSupervisor.exe";',
                  'const string Work='+verbatim(work)+', Self='+verbatim(executable)+';')
    text=_replace(text,'Environment.UserName!="WDAGUtilityAccount"','Environment.UserName!='+json.dumps(user))
    text=_replace(text,'"C:/Inputs/Jdk/bin/java.exe "',json.dumps(subprocess.list2cmdline([str(java)])+' '))
    text=_replace(text,r'@"C:\BuildWork\Project\apps\flutter_elitesync_module\.android"',verbatim(cwd))
    text=_replace(text,r'string logs=@"C:\ProbeOutput";', 'string logs='+verbatim(logs)+';')
    text=_replace(text,r'@"C:\Inputs\Jdk\bin\java.exe"',verbatim(java))
    text=text.replace('Guest supervisor identity required','Bound local supervisor identity required')
    if job_memory_gib==6:
        text=_replace(text,'JobMemoryLimit=new UIntPtr(4UL*1024*1024*1024)',
                      'JobMemoryLimit=new UIntPtr(6UL*1024*1024*1024)')
    return text.encode('utf-8')


def _copy_tree(inventory, target, role=None):
    rows=[row for row in inventory['files'] if role is None or row['role']==role]
    if not rows:
        raise ValueError('No declared files for materialization')
    for row in rows:
        source=Path(inventory['roots'][row['role']])
        destination=target/row['relative_path']
        if not destination.resolve().is_relative_to(target.resolve()):
            raise ValueError('Materialization escapes task directory')
        destination.parent.mkdir(parents=True,exist_ok=True)
        with _bound_file(source,row) as incoming,destination.open('xb') as output:
            shutil.copyfileobj(incoming,output,1024*1024)


def _json(path):return json.loads(Path(path).read_bytes())


def prepare(root, prepared_inputs, source_case, *, job_memory_gib=4, current_source_root=None):
    """Materialize/compile only. No SDK invocation, grant or claim is created."""
    memory_policy=local_memory_policy(job_memory_gib)
    limits=dict(LIMITS,**memory_policy)
    root,prepared_inputs,source_case=map(lambda p:Path(p).resolve(),(root,prepared_inputs,source_case))
    if root.exists():raise FileExistsError('Preserve the existing local candidate')
    if shared.sha(source_case/'probe/run-contract.json')!=SOURCE_CONTRACT_SHA:
        raise ValueError('Reviewed source input contract differs')
    source_contract=_json(source_case/'probe/run-contract.json')
    for name,expected in source_contract['payload_sha256'].items():
        if shared.sha(source_case/name)!=expected:raise ValueError('Frozen source payload changed')
    declared_file=prepared_inputs/'complete-declared-input-trees-private.json'
    if shared.sha(declared_file)!=DECLARED_SHA:raise ValueError('Declared source inventory differs')
    declared=_json(declared_file)
    boundary=(HERE/'producer_process_boundary.cs').read_bytes()
    if hashlib.sha256(boundary).hexdigest()!=BOUNDARY_SHA:raise ValueError('Original Job boundary differs')
    overlay=None
    if current_source_root is not None:
        baseline=_json(source_case/'probe/producer-entry.json')['source_identity']['source_commit']
        overlay=source_overlay.capture_overlay(current_source_root,baseline)
    mappings=source_contract['readonly_mappings']
    pub=[m for m in mappings if m['guest'].startswith('C:/Inputs/PubPackages/')]
    pub_parent=os.path.commonpath([m['host'] for m in pub])
    if Path(pub_parent).parent==Path(pub_parent):raise ValueError('Explicit shared Pub parent required')
    work=root/'work';control=root/'control';output=root/'output'
    root.mkdir();work.mkdir();control.mkdir();output.mkdir()
    _copy_tree(_json(source_case/'probe/flutter-inventory.json'),work/'Flutter')
    _copy_tree(_json(source_case/'probe/project-inventory.json'),work/'Project')
    if overlay is not None:
        source_overlay.apply_overlay(overlay,work/'Project')
        shared.put(control/'source-overlay.json',overlay)
    sdk=work/'AndroidSdk'
    for role,relative in {'android_build_tools_36':'build-tools/36.0.0',
                          'android_platform_36':'platforms/android-36','android_ndk_28_2':'ndk/28.2.13676358'}.items():
        _copy_tree(declared,sdk/relative,role)
    supplemental=_json(source_case/'probe/supplemental-sdk-inventory.json')
    for role,relative in {'android_build_tools_35':'build-tools/35.0.0','android_platform_34':'platforms/android-34',
                          'android_platform_35':'platforms/android-35','android_licenses':'licenses'}.items():
        _copy_tree(supplemental,sdk/relative,role)
    import cmake_vc_candidate as cmake
    cmake.verify_private_tree()
    cmake_inventory=_json(cmake.MATERIALIZATION)['inventory']
    _copy_tree(cmake_inventory,sdk/'cmake/3.22.1')
    replacements={m['guest']:Path(m['host']).as_posix() for m in mappings}
    replacements.update({'C:/BuildWork':work.as_posix(),'C:/Inputs/AndroidSdk':sdk.as_posix(),
                         'C:/Inputs/PubPackages':Path(pub_parent).as_posix(),
                         'C:/Inputs/PreparedFlutter':(work/'Flutter').as_posix(),
                         'C:/Inputs/PreparedProject':(work/'Project').as_posix()})
    for m in mappings:
        prefix='C:/Inputs/AndroidSdk/'
        if m['guest'].startswith(prefix):replacements[m['guest']]=(sdk/m['guest'][len(prefix):]).as_posix()
    entry=render_local_entry((source_case/'probe/producer-entry.json').read_bytes(),boundary,replacements,
                             (source_case/'probe/producer-output.init.gradle').read_text(encoding='utf-8'))
    if overlay is not None:entry=source_overlay.retarget_entry(entry,overlay)
    for relative,text in entry['overlays'].items():
        target=work/'Flutter'/relative
        if not target.resolve().is_relative_to((work/'Flutter').resolve()):raise ValueError('Overlay escapes Flutter')
        target.write_text(text,encoding='utf-8',newline='\n')
    for relative in ['Flutter/packages/flutter_tools/.dart_tool/package_config.json',
                     'Project/apps/flutter_elitesync_module/.dart_tool/package_config.json',
                     'Project/apps/flutter_elitesync_module/.flutter-plugins-dependencies']:
        path=work/relative;path.write_bytes(remap_json(path.read_bytes(),replacements))
    module=work/'Project/apps/flutter_elitesync_module'
    (module/'.dart_tool/package_graph.json').write_bytes((source_case/'probe/project-package-graph.json').read_bytes())
    def property_path(path):return path.as_posix().replace(':',r'\:')
    (module/'.android/local.properties').write_text('sdk.dir='+property_path(sdk)+'\nflutter.sdk='+property_path(work/'Flutter')+'\n',encoding='utf-8')
    for relative in ['Home','Home/.android','tmp','PubCache','state/project-cache','Control','GradleHome','AarOutput']:
        (work/relative).mkdir(parents=True,exist_ok=True)
    (work/'Control/producer-output.init.gradle').write_text(entry['output_init'],encoding='utf-8')
    (work/'GradleHome/gradle.properties').write_text(entry['gradle_properties']+'android.builder.sdkDownload=false\n',encoding='utf-8')
    request=entry['launch_request']
    request['environment'].update(ANDROID_USER_HOME=(work/'Home/.android').as_posix(),
                                  ANDROID_NDK_HOME=(sdk/'ndk/28.2.13676358').as_posix())
    executable=control/'LocalAarProducer.exe';java=entry['argv'][0];cwd=Path(request['cwd'])
    (control/'local-boundary.cs').write_bytes(local_boundary(boundary,work,executable,java,cwd,output,current_user(),
                                                         job_memory_gib=job_memory_gib))
    shutil.copyfile(HERE/'local_aar_supervisor.cs',control/'local_aar_supervisor.cs')
    shutil.copyfile(HERE/'local_aar_memory_diagnostics.cs',control/'local_aar_memory_diagnostics.cs')
    compiler=Path('C:/Windows/Microsoft.NET/Framework64/v4.0.30319/csc.exe')
    compiled=subprocess.run([str(compiler),'/nologo','/warnaserror','/platform:x64','/r:System.Web.Extensions.dll',
        '/main:LocalAarSupervisor','/out:'+str(executable),str(control/'local-boundary.cs'),str(control/'local_aar_supervisor.cs'),
        str(control/'local_aar_memory_diagnostics.cs')],capture_output=True,timeout=60)
    (root/'compiler.stdout').write_bytes(compiled.stdout);(root/'compiler.stderr').write_bytes(compiled.stderr)
    if compiled.returncode:raise RuntimeError('Local controller compile failed; preserve candidate')
    inventory=inventory_trees(roots={'local_work':str(work)},file_limit=100000,entry_limit=200000,
                              byte_limit=16*1024**3,depth_limit=64)
    shared.put(control/'prepared-work-inventory.json',inventory)
    external_roles={str(Path(m['host']).resolve()).casefold() for m in mappings if not m['guest'].startswith('C:/Inputs/AndroidSdk')
                    and m['guest'] not in ('C:/Inputs/PreparedFlutter','C:/Inputs/PreparedProject')}
    external=[row for row in declared['files'] if str(Path(declared['roots'][row['role']]).resolve()).casefold() in external_roles]
    shared.put(control/'external-inputs.json',external)
    helpers={str(HERE/name):shared.sha(HERE/name) for name in
             ['current_product_local_producer.py','current_product_local_entry.py','local_aar_supervisor.cs','local_aar_memory_diagnostics.cs']}
    if overlay is not None:
        helpers[str(HERE/'current_product_source_overlay.py')]=shared.sha(HERE/'current_product_source_overlay.py')
    payload={p.relative_to(root).as_posix():shared.sha(p) for p in control.iterdir() if p.is_file()}
    contract=dict(kind='current-product-local-aar-producer',scope=root.name,host_root=str(root),work_root=str(work),
        nonce=uuid.uuid4().hex,binary_sha256=shared.sha(executable),launch_request=request,
        publication_version=entry['publication_version'],source_identity=entry['source_identity'],
        source_input_contract_sha256=SOURCE_CONTRACT_SHA,repository=str(work/'AarOutput/outputs/repo'),
        work_inventory_sha256=shared.sha(control/'prepared-work-inventory.json'),external_inventory_sha256=shared.sha(control/'external-inputs.json'),
        payload_sha256=payload,host_helpers=helpers,networking='offline flags; no OS network isolation or system network changes',**limits)
    if overlay is not None:
        contract.update(base_identity=entry['base_identity'],source_overlay_manifest_sha256=overlay['manifest_sha256'])
    shared.put(control/'run-contract.json',contract)
    shared.put(root/'prepared.json',dict(status='LOCAL_PRIVATE_AAR_PREPARED_NOT_AUTHORIZED',contract_sha256=shared.sha(control/'run-contract.json'),
        work_files=len(inventory['files']),work_bytes=inventory['total_bytes'],external_files=len(external),claim_created=False,G2=False,
        **memory_policy))
    return contract


def _check_rows(rows):
    for row in rows:
        path=Path(row['path']);info=shared._checked_stat(path)
        if (info.st_size!=row['bytes'] or {'device':info.st_dev,'inode':info.st_ino}!=row['file_id'] or shared.sha(path)!=row['sha256']):
            raise ValueError('Prepared input identity changed: '+str(path))


def preflight(root,contract):
    root=Path(root)
    for file,key in [('prepared-work-inventory.json','work_inventory_sha256'),('external-inputs.json','external_inventory_sha256')]:
        if shared.sha(root/'control'/file)!=contract[key]:raise ValueError('Frozen input manifest changed')
    _check_rows(_json(root/'control/prepared-work-inventory.json')['files'])
    _check_rows(_json(root/'control/external-inputs.json'))
    result=subprocess.run(['pwsh','-NoProfile','-NonInteractive','-Command',
        '[ordered]@{available_mib=[int]((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory/1024)}|ConvertTo-Json -Compress'],capture_output=True,timeout=20)
    if result.returncode:raise RuntimeError('Local resource query failed')
    resource=json.loads(result.stdout.decode('utf-8-sig'))
    resource['free_disk_bytes']=shutil.disk_usage(root).free
    shared.put(root/('resource-'+uuid.uuid4().hex+'.json'),resource)
    if resource['available_mib']<contract['required_available_mib'] or resource['free_disk_bytes']<8*1024**3:
        raise RuntimeError('Local resources insufficient; no claim consumed')
    return resource


def launch(root):
    """One independent local grant, one irreversible claim, one SDK root."""
    root=Path(root).resolve();control=root/'control';raw=(control/'run-contract.json').read_bytes();contract=json.loads(raw)
    adapters={
        'current-product-local-aar-producer':('LocalAarProducer.exe','LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED','repository'),
        'current-product-local-debug-host':('LocalDebugHost.exe','LOCAL_DEBUG_HOST_ROOT_EXIT0_APK_UNVERIFIED','apk_output'),
    }
    if contract.get('kind') not in adapters:raise ValueError('Unsupported local build kind')
    executable_name,result_status,output_key=adapters[contract['kind']]
    if str(root)!=contract['host_root']:raise ValueError('Local candidate cannot move')
    if (root/'launch.claim.json').exists() or (control/'launch.claim.json').exists():raise RuntimeError('Local attempt already consumed')
    grant=_json(control/'owner-grant.json');digest=hashlib.sha256(raw).hexdigest()
    if grant.get('authorized') is not True or type(grant.get('max_attempts')) is not int or grant['max_attempts']!=1 or grant.get('contract_sha256')!=digest:
        raise ValueError('Independent local one-attempt grant required')
    for name,expected in contract['payload_sha256'].items():
        if shared.sha(root/name)!=expected:raise ValueError('Local frozen payload changed')
    expected={Path(name).name for name in contract['payload_sha256']};expected.update(('run-contract.json','owner-grant.json'))
    if {p.name for p in control.iterdir()}!=expected:raise ValueError('Unexpected local control input')
    for path,expected_sha in contract['host_helpers'].items():
        if shared.sha(path)!=expected_sha:raise ValueError('Local helper changed')
    preflight(root,contract)
    if any((root/'output').iterdir()):raise ValueError('Fresh local output required')
    claim=dict(contract_sha256=digest,grant_sha256=shared.sha(control/'owner-grant.json'),attempt=1,refundable=False,utc=datetime.now(timezone.utc).isoformat())
    shared.put(root/'launch.claim.json',claim);shared.put(control/'launch.claim.json',claim)
    start=time.monotonic();process=None
    try:
        process=subprocess.Popen([str(control/executable_name),contract['nonce']],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        shared.put(root/'launched.json',dict(pid=process.pid,utc=datetime.now(timezone.utc).isoformat()))
        while process.poll() is None:
            total=shared.output_size(root/'output',contract['output_bytes'])
            repo=Path(contract[output_key])
            if repo.exists():shared.output_size(repo,contract['output_bytes']-total)
            if time.monotonic()-start>=contract['host_seconds']:raise TimeoutError('Local host deadline')
            time.sleep(1)
        shared.put(root/'controller-exit.json',dict(exit_code=process.returncode))
        if process.returncode or (root/'output/failure.json').exists() or (root/'output/watchdog.json').exists():
            raise RuntimeError('Local producer STOP/failure; attempt consumed')
        proof=_json(root/'output/result.json')
        if (proof.get('nonce')!=contract['nonce'] or proof.get('status')!=result_status
                or type(proof.get('root_exit')) is not int or proof['root_exit']!=0
                or type(proof.get('elapsed_ms')) is not int or not 0<=proof['elapsed_ms']<contract['sdk_seconds']*1000
                or proof.get(output_key)!=contract[output_key]):raise ValueError('Local result binding failed')
        total=shared.output_size(root/'output',contract['output_bytes'])
        shared.output_size(Path(contract[output_key]),contract['output_bytes']-total)
        if time.monotonic()-start>=contract['host_seconds']:raise TimeoutError('Local collection deadline')
        return proof
    except BaseException as error:
        failures=[error]
        try:shared.put(root/'STOP.json',dict(reason=str(error),attempt_consumed=True))
        except Exception as evidence_error:failures.append(evidence_error)
        if process is not None and process.poll() is None:
            cleanup_deadline=time.monotonic()+contract['cleanup_seconds']
            try:
                shared.put(root/'output/host-stop.json',dict(origin='local_host',reason=str(error)))
                try:process.wait(timeout=min(10,max(0.1,cleanup_deadline-time.monotonic())))
                except subprocess.TimeoutExpired:pass
            except Exception as stop_error:failures.append(stop_error)
            finally:
                if process.poll() is None:
                    try:
                        process.kill() # Held controller handle; its Job closes with the process.
                        process.wait(timeout=max(0.1,cleanup_deadline-time.monotonic()))
                    except Exception as cleanup_error:failures.append(cleanup_error)
        if len(failures)>1:raise BaseExceptionGroup('Local build failure with evidence/cleanup errors',failures)
        raise
