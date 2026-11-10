"""Render a source-bound AAR producer entry; never execute or grant a claim.

The full existing Flutter/project inventories are inputs, not ten-file observer
roots. Only a future fresh private copy receives these overlays. Original SDK,
diagnostics, STOP records and the prepared source copies must stay untouched.
"""
import base64
import hashlib
import json

from current_product_apk_plan import SOURCE, APPS, SERVICES
from producer_qualification_plan import gradle_properties


PINS = {
    'flutter':'4b6321517a0abab0a715dfa24b22c8997099360eb28af08d72a7da3f62dc8019',
    'project':'557f07fc2a1888303982b0f145efce34d0f2fdd17558fabc58ff0e8d9e08d487',
    'helper':'81bfe154b078bd6e3603720e6d147396c81f1012c72633b590f04b42265d2730',
    'aar':'b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2',
    'selected':'d260db918b9a7ba77307e3c9823fd29a3f7ab589414a942dd280e99b6dd824c3',
}
HELPER_PATH = 'packages/flutter_tools/gradle/src/main/kotlin/tasks/BaseFlutterTaskHelper.kt'
AAR_PATH = 'packages/flutter_tools/gradle/aar_init_script.gradle'
REQUIRED_FLUTTER = (
    'LICENSE', 'bin/cache/dart-sdk/bin/dart.exe', 'bin/cache/flutter_tools.snapshot',
    'packages/flutter_tools/.dart_tool/package_config.json',
    'packages/flutter_tools/gradle/build.gradle.kts',
    'bin/cache/artifacts/engine/android-arm64-release/windows-x64/gen_snapshot.exe',
    'bin/cache/artifacts/engine/common/flutter_patched_sdk_product/platform_strong.dill',
)
REQUIRED_PROJECT = (
    'apps/flutter_elitesync_module/lib/main.dart',
    'apps/flutter_elitesync_module/.dart_tool/package_config.json',
    'apps/flutter_elitesync_module/.flutter-plugins-dependencies',
    'apps/flutter_elitesync_module/.android/settings.gradle',
    'apps/flutter_elitesync_module/.android/Flutter/build.gradle',
    'apps/flutter_elitesync_module/.android/local.properties',
    'apps/android/app/build.gradle.kts', 'apps/android/settings.gradle.kts',
)


def _pin(raw, kind, cap):
    if type(raw) is not bytes or not 0 < len(raw) <= cap or hashlib.sha256(raw).hexdigest() != PINS[kind]:
        raise ValueError('frozen ' + kind + ' input identity differs')


def _manifest(raw, kind, role, required):
    _pin(raw, kind, 16 * 1024**2)
    data = json.loads(raw)
    if data.get('scope') != 'COMPLETE_DECLARED_TREES_ONLY' or set(data['roots']) != {role}:
        raise ValueError('full declared inventory required')
    files = data['files']
    if type(files) is not list or len(files) > 20000:
        raise ValueError('bounded full-root inventory required')
    rows = {}
    for row in files:
        if row['role'] != role or row['relative_path'] in rows:
            raise ValueError('unique inventory role/path required')
        rows[row['relative_path']] = row
    if not set(required).issubset(rows):
        raise ValueError('full production root missing required members')
    return rows


def prepare_entry(flutter_manifest, project_manifest, task_helper, aar_init):
    """Return candidate command, source overlays and handoff; all runtime gates stay closed."""
    flutter = _manifest(flutter_manifest, 'flutter', 'private_flutter',
                        (*REQUIRED_FLUTTER, HELPER_PATH, AAR_PATH))
    _manifest(project_manifest, 'project', 'private_project', REQUIRED_PROJECT)
    for kind, path, raw in [('helper', HELPER_PATH, task_helper), ('aar', AAR_PATH, aar_init)]:
        _pin(raw, kind, 1024**2)
        if flutter[path]['sha256'] != PINS[kind] or flutter[path]['bytes'] != len(raw):
            raise ValueError('source overlay differs from full-root inventory')
    helper = task_helper.decode('utf-8')
    anchor = '            executable(baseFlutterTask.flutterExecutable!!.absolutePath)'
    if helper.count(anchor) != 1:
        raise ValueError('unique pinned Flutter execution anchor required')
    # Prefix only: all upstream working directory, assemble options and rules
    # remain byte-for-byte after the original executable selection.
    replacement = '''            val privateRoot = baseFlutterTask.flutterRoot!!.canonicalFile
            require(privateRoot.path.replace('\\\\', '/') == "C:/BuildWork/Flutter")
            require(baseFlutterTask.buildMode == "release")
            require(baseFlutterTask.localEngine == null && baseFlutterTask.localEngineHost == null)
            require(System.getenv("FLUTTER_ALREADY_LOCKED") == null)
            val dart = java.io.File(privateRoot, "bin/cache/dart-sdk/bin/dart.exe")
            val packages = java.io.File(privateRoot, "packages/flutter_tools/.dart_tool/package_config.json")
            val snapshot = java.io.File(privateRoot, "bin/cache/flutter_tools.snapshot")
            require(dart.isFile && packages.isFile && snapshot.isFile)
            executable(dart.absolutePath)
            args("--packages=${packages.absolutePath}")
            args(snapshot.absolutePath)
            args("--suppress-analytics", "--no-version-check")'''
    helper = helper.replace(anchor, replacement)
    lines = aar_init.decode('utf-8').splitlines(keepends=True)
    removed = [i for i,line in enumerate(lines,1) if line.strip() == 'withJavadocJar()']
    if len(removed) != 2:
        raise ValueError('exact two upstream Javadoc publication declarations required')
    aar = ''.join(line for i,line in enumerate(lines,1) if i not in removed)
    version = '1.0-v1015-' + SOURCE[:12] + '-' + PINS['selected'][:12]
    defines = ','.join(base64.b64encode(s.encode()).decode() for s in
        ('ELITESYNC_V1015_LOCAL_BUILD=true','ELITESYNC_V1014_LOCAL_BUILD=true'))
    properties = gradle_properties()
    jvm_args = properties.splitlines()[0].split('=',1)[1].split()
    command = ['C:/Inputs/Jdk/bin/java.exe', '-Duser.home=C:/BuildWork/Home',
        '-Djava.io.tmpdir=C:/BuildWork/tmp', *jvm_args,
        '-javaagent:C:/Inputs/Gradle/lib/agents/gradle-instrumentation-agent-8.14.jar',
        '-jar','C:/Inputs/Gradle/lib/gradle-gradle-cli-main-8.14.jar',
        '-I','C:/BuildWork/Flutter/' + AAR_PATH,
        '-Pflutter-root=C:/BuildWork/Flutter', '-Poutput-dir=C:/BuildWork/AarOutput',
        '-Pis-plugin=false', '-PbuildNumber=' + version, '-Ptarget=lib/main.dart',
        '-Ptarget-platform=android-arm64', '-Pdart-defines=' + defines,
        '-Dorg.gradle.java.installations.auto-detect=false',
        '-Dorg.gradle.java.installations.auto-download=false',
        '--offline','--no-daemon','--max-workers=1','--console=plain',
        '--gradle-user-home','C:/BuildWork/GradleHome',
        '--project-cache-dir','C:/BuildWork/state/project-cache', 'assembleAarRelease']
    env = {'SystemRoot':'C:/Windows', 'WINDIR':'C:/Windows', 'OS':'Windows_NT',
        'PATH':'C:/Inputs/Jdk/bin;C:/Windows/System32', 'PATHEXT':'.EXE',
        'JAVA_HOME':'C:/Inputs/Jdk', 'ANDROID_HOME':'C:/Inputs/AndroidSdk',
        'ANDROID_SDK_ROOT':'C:/Inputs/AndroidSdk', 'FLUTTER_ROOT':'C:/BuildWork/Flutter',
        'USERPROFILE':'C:/BuildWork/Home', 'HOME':'C:/BuildWork/Home',
        'APPDATA':'C:/BuildWork/Home/AppData/Roaming', 'LOCALAPPDATA':'C:/BuildWork/Home/AppData/Local',
        'TEMP':'C:/BuildWork/tmp', 'TMP':'C:/BuildWork/tmp', 'PUB_CACHE':'C:/BuildWork/PubCache',
        'GRADLE_USER_HOME':'C:/BuildWork/GradleHome', 'GRADLE_RO_DEP_CACHE':'C:/Inputs/DependencyCache'}
    return {
        'status':'FULL_ROOT_PRODUCER_SOURCE_WIRED_NOT_EXECUTABLE',
        'source_identity':{'source_commit':SOURCE,'apps_tree':APPS,'services_tree':SERVICES},
        'input_inventory_sha256':{key:PINS[key] for key in ('flutter','project','selected')},
        'publication_version':version,
        'overlays':{HELPER_PATH:helper,AAR_PATH:aar}, 'removed_javadoc_source_lines':removed,
        'overlay_application':'FRESH_PRIVATE_COPY_ONLY_ORIGINALS_AND_PRIOR_CASES_UNCHANGED',
        'stage1':{'argv':command,'working_directory':'C:/BuildWork/Project/apps/flutter_elitesync_module/.android'},
        'environment':env, 'inherit_environment':False, 'gradle_properties':properties,
        'handoff':{'producer_repository':'C:/BuildWork/AarOutput/outputs/repo',
            'expected_coordinate':'com.elitesync.flutter_elitesync_module:flutter_release:' + version,
            'verifier':'current_product_aar_handoff.stage_repository',
            'host_renderer':'current_product_private_host.render_private_host',
            'host_task':':app:assembleDebug', 'requires_real_repository':True,
            'empty_directory_eligible':False, 'stage2_pre_rendered':False},
        'remaining_gates':{
            'overlay_materialization_and_compilation':'NOT_RUN',
            'producer_os_write_and_process_enforcement':'NOT_IMPLEMENTED_FOR_THIS_ENTRY',
            'native_tool_input_and_process_qualification':'NOT_PROVEN',
            'offline_action_dependency_closure':'NOT_PROVEN',
            'current_resource_qualification':'UNKNOWN',
            'independent_budget_and_claim':'UNKNOWN_NOT_CREATED',
            'real_AAR_and_host_runtime_consumption':'NOT_RUN'},
        'cache_lock_held':'NOT_PROVEN', 'bootstrap_equivalence':'NOT_PROVEN',
        'source_wiring_only':True, 'execution_allowed':False, 'claim_created':False,
        'producer_budget':'UNKNOWN_NOT_CREATED', 'old_claims_reused':False, 'G2':False,
    }
