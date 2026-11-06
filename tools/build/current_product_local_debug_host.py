"""Prepare a private offline Android Debug host; never invoke Flutter.

Preparation copies bound Android/SDK/AAR inputs and compiles only the owned
controller. Launch uses the existing local one-attempt grant/claim/Job path.
APK bytes, installation and runtime acceptance remain separately unverified.
"""
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import uuid

from current_product_aar_handoff import stage_repository, verify_repository
from current_product_apk_inventory import inventory_files
from current_product_private_host import render_private_host
from current_product_tree_inventory import inventory_trees
from sandbox_owned_session_cleanup import windows_arguments
import current_product_local_producer as local


KIND = 'current-product-local-debug-host'
RESULT_STATUS = 'LOCAL_DEBUG_HOST_ROOT_EXIT0_APK_UNVERIFIED'
SUPERVISOR_SHA256 = '4032ab531eab8bb6d4722ff02aea6f3a34f2b173c85742fa341e47814f66c906'


def _supervisor(raw):
    if hashlib.sha256(raw).hexdigest() != SUPERVISOR_SHA256:
        raise ValueError('Source local controller differs')
    text = raw.decode('utf-8')
    for old, new in [
        ('"current-product-local-aar-producer"', '"' + KIND + '"'),
        ('Independent local AAR authority', 'Independent local Debug host authority'),
        ('Local AAR producer exited ', 'Local Debug host exited '),
        ('LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED', RESULT_STATUS),
        ('repository=(string)contract["repository"]', 'apk_output=(string)contract["apk_output"]'),
    ]:
        text = local._replace(text, old, new)
    return text.encode('utf-8')


def _launch_request(source, work):
    """Reuse only the bound JDK/Gradle launcher and readonly dependency cache."""
    args = windows_arguments(source['command_line'])
    jar = args.index('-jar')
    java, cli = Path(args[0]), Path(args[jar+1])
    agents = [arg for arg in args[1:jar] if arg.startswith('-javaagent:')]
    if len(agents) != 1 or not java.is_absolute() or not cli.is_absolute():
        raise ValueError('Bound Java/Gradle launch inputs required')
    env_source = source['environment']
    jdk = Path(env_source['JAVA_HOME'])
    cache = Path(env_source['GRADLE_RO_DEP_CACHE'])
    if not jdk.is_absolute() or not cache.is_absolute() or not java.is_relative_to(jdk):
        raise ValueError('Explicit JDK and dependency cache required')
    command = [str(java), '-Duser.home=' + (work/'Home').as_posix(),
        '-Djava.io.tmpdir=' + (work/'tmp').as_posix(), '-Xmx2048m',
        '-XX:MaxMetaspaceSize=768m', '-XX:ReservedCodeCacheSize=256m',
        '-Dfile.encoding=UTF-8', agents[0], '-jar', str(cli),
        '-I', str(work/'Control/debug-output.init.gradle'),
        '-PflutterDartDefines=ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1014_LOCAL_BUILD=true',
        '-Dorg.gradle.java.installations.auto-detect=false',
        '-Dorg.gradle.java.installations.auto-download=false',
        '--offline', '--no-daemon', '--max-workers=1', '--console=plain',
        '--gradle-user-home', str(work/'GradleHome'),
        '--project-cache-dir', str(work/'state/project-cache'), ':app:assembleDebug']
    env = {name: env_source[name] for name in ['SystemRoot', 'WINDIR']}
    env.update(OS='Windows_NT', PATH=str(jdk/'bin')+';'+env['SystemRoot']+'/System32',
        PATHEXT='.EXE', JAVA_HOME=str(jdk), GRADLE_RO_DEP_CACHE=str(cache),
        ANDROID_HOME=str(work/'AndroidSdk'), ANDROID_SDK_ROOT=str(work/'AndroidSdk'),
        ANDROID_USER_HOME=str(work/'Home/.android'), GRADLE_USER_HOME=str(work/'GradleHome'),
        USERPROFILE=str(work/'Home'), HOME=str(work/'Home'),
        APPDATA=str(work/'Home/AppData/Roaming'), LOCALAPPDATA=str(work/'Home/AppData/Local'),
        TEMP=str(work/'tmp'), TMP=str(work/'tmp'))
    return dict(command_line=subprocess.list2cmdline(command), cwd=str(work/'AndroidHost'),
                environment=env), java, [jdk, cli.parent, cli.parent.parent/'init.d', cache]


def prepare(root, aar_case, android_inventory, *, file_limit=100000, byte_limit=16*1024**3):
    """Fresh materialization/controller compilation only; no SDK, grant or claim."""
    root, aar_case, android_inventory = (Path(value).resolve()
                                         for value in (root, aar_case, android_inventory))
    if root.exists():
        raise FileExistsError('Preserve the existing Debug host candidate')
    source_path = aar_case/'control/run-contract.json'
    proof_path = aar_case/'output/result.json'
    source, proof = local._json(source_path), local._json(proof_path)
    grant_path, claim_path = aar_case/'control/owner-grant.json', aar_case/'launch.claim.json'
    control_claim_path = aar_case/'control/launch.claim.json'
    grant, claim = local._json(grant_path), local._json(claim_path)
    source_sha, grant_sha = local.shared.sha(source_path), local.shared.sha(grant_path)
    if (grant.get('authorized') is not True or type(grant.get('max_attempts')) is not int
            or grant['max_attempts'] != 1 or grant.get('contract_sha256') != source_sha
            or claim.get('contract_sha256') != source_sha or claim.get('grant_sha256') != grant_sha
            or type(claim.get('attempt')) is not int or claim['attempt'] != 1
            or local._json(control_claim_path) != claim):
        raise ValueError('Bound AAR source grant and consumed claim required')
    if (source['kind'] != 'current-product-local-aar-producer'
            or source['host_root'] != str(aar_case) or proof.get('nonce') != source['nonce']
            or proof.get('status') != 'LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED'
            or type(proof.get('root_exit')) is not int or proof['root_exit'] != 0
            or proof.get('repository') != source['repository']):
        raise ValueError('Bound successful AAR source result required')
    for name, key in [('prepared-work-inventory.json', 'work_inventory_sha256'),
                      ('external-inputs.json', 'external_inventory_sha256')]:
        if local.shared.sha(aar_case/'control'/name) != source[key]:
            raise ValueError('Frozen AAR source inventory changed')
    verified = verify_repository(source['repository'], source['publication_version'],
                                  file_limit=file_limit, byte_limit=byte_limit)
    android = local._json(android_inventory)
    if set(android['roots']) != {'android'}:
        raise ValueError('Tracked Android inventory requires one explicit android root')
    source_work = local._json(aar_case/'control/prepared-work-inventory.json')
    sdk_prefixes = tuple('AndroidSdk/'+name+'/' for name in [
        'build-tools/35.0.0', 'platforms/android-36', 'licenses', 'ndk/28.2.13676358'])
    sdk_rows = [dict(row, relative_path=row['relative_path'][len('AndroidSdk/'):], role='sdk')
                for row in source_work['files'] if row['relative_path'].startswith(sdk_prefixes)]
    sdk = dict(roots={'sdk': str(Path(source['work_root'])/'AndroidSdk')}, files=sdk_rows)
    work, control, output = root/'work', root/'control', root/'output'
    request, java, external_roots = _launch_request(source['launch_request'], work)
    external = [row for row in local._json(aar_case/'control/external-inputs.json')
                if any(Path(row['path']).is_relative_to(path) for path in external_roots)]
    required = [java, Path(windows_arguments(request['command_line'])[
        windows_arguments(request['command_line']).index('-jar')+1]),
        Path(next(arg[len('-javaagent:'):] for arg in windows_arguments(request['command_line'])
                  if arg.startswith('-javaagent:')))]
    if not sdk_rows or any(str(path) not in {row['path'] for row in external} for path in required):
        raise ValueError('SDK and all Java/Gradle launch files must be inventoried')
    for path in [aar_case, Path(android['roots']['android']), *external_roots]:
        if path.is_relative_to(root) or root.is_relative_to(path):
            raise ValueError('Debug candidate must be disjoint from source inputs')
    local._check_rows(external)
    boundary = (local.HERE/'producer_process_boundary.cs').read_bytes()
    controller = _supervisor((local.HERE/'local_aar_supervisor.cs').read_bytes())
    # Save selected source evidence too: preflight must see its original identity.
    evidence = inventory_files([('source', str(path)) for path in
        [source_path, proof_path, grant_path, claim_path, control_claim_path, android_inventory]],
        [str(aar_case), str(android_inventory.parent)],
        10, 32*1024**2)['files']
    root.mkdir(); work.mkdir(); control.mkdir(); output.mkdir()
    staged = stage_repository(source['repository'], str(root/'VerifiedAarRepository'), str(root),
        source['publication_version'], file_limit=file_limit, byte_limit=byte_limit)
    local._copy_tree(android, work/'AndroidHost')
    local._copy_tree(sdk, work/'AndroidSdk')
    host = work/'AndroidHost'
    rendered = render_private_host((host/'app/build.gradle.kts').read_text(encoding='utf-8'),
        (host/'settings.gradle.kts').read_text(encoding='utf-8'), staged['repository'],
        source['publication_version'], file_limit=file_limit, byte_limit=byte_limit, local_repository=True)
    app = local._replace(rendered['app_gradle'], 'android {',
                         'android {\n    ndkVersion = "28.2.13676358"')
    (host/'app/build.gradle.kts').write_text(app, encoding='utf-8', newline='\n')
    (host/'settings.gradle.kts').write_text(rendered['settings_gradle'], encoding='utf-8', newline='\n')
    (host/'local.properties').write_text('sdk.dir='+(work/'AndroidSdk').as_posix().replace(':', r'\:')+'\n',
                                       encoding='utf-8')
    for relative in ['Home/.android', 'tmp', 'state/project-cache', 'Control', 'GradleHome', 'ApkOutput']:
        (work/relative).mkdir(parents=True, exist_ok=True)
    properties = ('org.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=768m '
                  '-XX:ReservedCodeCacheSize=256m -Dfile.encoding=UTF-8\n'
                  'org.gradle.daemon=false\norg.gradle.parallel=false\norg.gradle.workers.max=1\n'
                  'org.gradle.java.installations.auto-detect=false\n'
                  'org.gradle.java.installations.auto-download=false\nandroid.builder.sdkDownload=false\n')
    (work/'GradleHome/gradle.properties').write_text(properties, encoding='utf-8')
    path_literal = json.dumps((work/'ApkOutput').as_posix()).replace('$', '\\$')
    (work/'Control/debug-output.init.gradle').write_text(
        'gradle.projectsLoaded {\n    rootProject.allprojects { p ->\n'
        '        p.layout.buildDirectory.set(new File('+path_literal+', '
        'p == rootProject ? "root" : p.path.substring(1).replace(\':\', \'/\')))\n    }\n}\n',
        encoding='utf-8', newline='\n')
    executable = control/'LocalDebugHost.exe'
    (control/'local-boundary.cs').write_bytes(local.local_boundary(boundary, work, executable, java,
        host, output, local.current_user(), job_memory_gib=6))
    (control/'local_debug_host_supervisor.cs').write_bytes(controller)
    shutil.copyfile(local.HERE/'local_aar_memory_diagnostics.cs', control/'local_aar_memory_diagnostics.cs')
    compiled = subprocess.run(['C:/Windows/Microsoft.NET/Framework64/v4.0.30319/csc.exe',
        '/nologo', '/warnaserror', '/platform:x64', '/r:System.Web.Extensions.dll',
        '/main:LocalAarSupervisor', '/out:'+str(executable), str(control/'local-boundary.cs'),
        str(control/'local_debug_host_supervisor.cs'), str(control/'local_aar_memory_diagnostics.cs')],
        capture_output=True, timeout=60)
    (root/'compiler.stdout').write_bytes(compiled.stdout); (root/'compiler.stderr').write_bytes(compiled.stderr)
    if compiled.returncode:
        raise RuntimeError('Debug host controller compile failed; preserve candidate')
    inventory = inventory_trees(roots={'local_work': str(work), 'verified_aar': staged['repository']},
        file_limit=file_limit, entry_limit=file_limit*8, byte_limit=byte_limit, depth_limit=64)
    put = local.shared.put
    put(control/'prepared-work-inventory.json', inventory)
    put(control/'external-inputs.json', external+evidence)
    put(control/'source-aar-receipt.json', verified)
    put(control/'tracked-android-inventory.json', android)
    helpers = {str(local.HERE/name): local.shared.sha(local.HERE/name) for name in [
        'current_product_local_debug_host.py', 'current_product_local_producer.py',
        'current_product_local_entry.py', 'current_product_private_host.py',
        'current_product_aar_handoff.py', 'current_product_tree_inventory.py',
        'current_product_apk_inventory.py', 'producer_supervisor.py',
        'producer_process_boundary.cs', 'local_aar_supervisor.cs', 'local_aar_memory_diagnostics.cs',
        'sandbox_owned_session_cleanup.py', 'producer_boundary_binding.py',
        'current_product_producer_entry.py', 'producer_qualification_plan.py', 'sandbox_host_observation.py']}
    contract = dict(kind=KIND, scope=root.name, host_root=str(root), work_root=str(work),
        nonce=uuid.uuid4().hex, binary_sha256=local.shared.sha(executable), launch_request=request,
        apk_output=str(work/'ApkOutput'), publication_version=source['publication_version'],
        source_identity=source['source_identity'], source_aar_contract_sha256=local.shared.sha(source_path),
        source_aar_manifest_sha256=staged['content_manifest_sha256'],
        android_inventory_sha256=local.shared.sha(android_inventory),
        private_host_differences=['verified local AAR repository; no Flutter Exec',
                                 'ndkVersion=28.2.13676358', 'private ApkOutput build directories'],
        work_inventory_sha256=local.shared.sha(control/'prepared-work-inventory.json'),
        external_inventory_sha256=local.shared.sha(control/'external-inputs.json'),
        payload_sha256={p.relative_to(root).as_posix(): local.shared.sha(p)
                        for p in control.iterdir() if p.is_file()}, host_helpers=helpers,
        networking='offline flags; no OS network isolation or system network changes',
        sdk_seconds=1800, host_seconds=2100, cleanup_seconds=45, output_bytes=2*1024**3,
        **local.local_memory_policy(6))
    put(control/'run-contract.json', contract)
    put(root/'prepared.json', dict(status='LOCAL_PRIVATE_DEBUG_HOST_PREPARED_NOT_AUTHORIZED',
        contract_sha256=local.shared.sha(control/'run-contract.json'), claim_created=False,
        runtime_consumption='NOT_RUN', G2=False))
    return contract


def launch(root):
    """Use the shared controller's strict Debug-host kind mapping and claim path."""
    return local.launch(root)
