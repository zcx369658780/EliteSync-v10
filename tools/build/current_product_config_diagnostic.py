"""Owned offline configuration diagnostics. Never authorizes old G2 or APKs."""
import argparse
import base64
import hashlib
import json
import os
import re
from pathlib import Path, PureWindowsPath
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_probe as common
import windows_sandbox_layout_probe as layout
from current_product_diagnostic_contract import TASK, validate_ledger, next_reservation

HERE=Path(__file__).resolve().parent
PARENT=Path.home()/'EliteSyncDev'
TASK_ROOT=PARENT/TASK
PRIOR=PARENT/'v1015-layout-qualification-20261101-02'
GRADLE=Path(r'D:\GradleHome\wrapper\dists\gradle-8.14-all\5vwl8burbouivoo2kromnbp2p\gradle-8.14')
SOURCE='84a94c9177ce832040146cff9968569762300307'
APPS='ed24852975baebeadc66f007dfb75ff9e31a97d4'
SERVICES='7634b4755a41f08641e00948f684c06efb12d8fe'
WORK=PureWindowsPath(r'C:\BuildWork')
MODULE=WORK/'Project/apps/flutter_elitesync_module/.android'
TOOLING=WORK/'Tooling/packages/flutter_tools/gradle'
JAVA=r'C:\Inputs\Jdk\bin\javaw.exe'

def sha(path):
    with Path(path).open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()

def data_sha(value):return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':')).encode()).hexdigest()

def put(path,value):
    with path.open('x',encoding='utf-8',newline='\n') as stream:
        json.dump(value,stream,ensure_ascii=False,indent=2);stream.write('\n');stream.flush();os.fsync(stream.fileno())

def write(path,data):
    path.parent.mkdir(parents=True,exist_ok=True)
    with path.open('xb') as stream:stream.write(data)

def jvm_options():
    # Gradle 8.14 daemon docs + installed CurrentProcess/DaemonCompatibilitySpec:
    # client managed JVM options must match requested org.gradle.jvmargs exactly.
    flags=['-Xmx768m','-XX:MaxMetaspaceSize=512m','-Djava.io.tmpdir=C:/BuildWork/tmp','-Dfile.encoding=UTF-8','-Duser.language=en','-Duser.country=US','-Duser.variant=']
    flags += ['--add-opens='+name+'=ALL-UNNAMED' for name in ['java.base/java.lang','java.base/java.lang.invoke','java.base/java.util','java.prefs/java.util.prefs','java.base/java.nio.charset','java.base/java.net','java.base/java.util.concurrent.atomic','java.xml/javax.xml.namespace']]
    flags += ['--add-exports='+name+'=ALL-UNNAMED' for name in ['jdk.compiler/com.sun.tools.javac.api','jdk.compiler/com.sun.tools.javac.util']]
    return flags

def adapt_text(name,text):
    replacement='C:/BuildWork/Tooling/packages/flutter_tools/gradle'
    if name.endswith('/settings.gradle') or name.endswith('/include_flutter.groovy'):
        old='$flutterSdkPath/packages/flutter_tools/gradle'
        expected=1 if name.endswith('/settings.gradle') else 2
        if text.count(old)!=expected:raise ValueError('Unexpected tooling reference count')
        return text.replace(old,replacement)
    if name.endswith('/gradle.properties'):
        return ('org.gradle.jvmargs='+' '.join(jvm_options())+'\n'
                'android.useAndroidX=true\norg.gradle.java.installations.auto-detect=false\n'
                'org.gradle.java.installations.auto-download=false\nkotlin.compiler.execution.strategy=in-process\n')
    raise ValueError('Adapter path is outside allowlist')

def properties():
    defines=','.join(base64.b64encode(s.encode()).decode() for s in [
        'ELITESYNC_V1015_LOCAL_BUILD=true','ELITESYNC_V1014_LOCAL_BUILD=true'])
    return {'flutter-root':r'C:\Inputs\Flutter','elitesyncDiagnosticToolingRoot':str(TOOLING),
        'elitesyncDiagnosticProjectRoot':str(WORK/'Project'),'elitesyncDiagnosticScope':TASK,
        'target':'lib/main.dart','target-platform':'android-arm64','is-plugin':'false',
        'buildNumber':'1.0-v1015config-'+SOURCE[:12],'dart-defines':defines,
        'output-dir':str(WORK/'AarOutput')}

def expected_outputs(plugins):
    result={':':str(WORK/'state/project-outputs/android_generated'),':flutter':str(WORK/'state/project-outputs/flutter'),':app':str(WORK/'Project/apps/flutter_elitesync_module/build/host')}
    result.update({':'+name:str(MODULE/'plugins_build_output'/name) for name in plugins})
    return result

def command(mode):
    prefix=[JAVA,'-Duser.home='+str(WORK/'Home'),'-Djava.io.tmpdir='+str(WORK/'tmp')]
    if mode=='qualify':return prefix+['-cp',r'C:\Probe','DiagnosticMonitorFixture']
    if mode!='gradle':raise ValueError('Unknown mode')
    prefix=[JAVA,'-Duser.home='+str(WORK/'Home')]+jvm_options()+[r'-javaagent:C:\Inputs\Gradle\lib\agents\gradle-instrumentation-agent-8.14.jar']
    return prefix+['-jar',r'C:\Inputs\Gradle\lib\gradle-gradle-cli-main-8.14.jar',
        '-I',str(WORK/'Adapters/current-product-config-guard.init.gradle'),
        '-I',str(WORK/'Adapters/aar-registration.init.gradle')]+[
        '-P'+k+'='+v for k,v in properties().items()]+[
        '-Dorg.gradle.java.installations.auto-detect=false','-Dorg.gradle.java.installations.auto-download=false',
        '--offline','--console=plain','--no-daemon','--max-workers=2',
        '--gradle-user-home',str(WORK/'GradleHome'),'--project-cache-dir',str(WORK/'state/project-cache'),
        '--dry-run','assembleAarRelease']

def environment():
    return {'SystemRoot':r'C:\Windows','WINDIR':r'C:\Windows','OS':'Windows_NT',
        'PATH':r'C:\Inputs\Jdk\bin;C:\Windows\System32','JAVA_HOME':r'C:\Inputs\Jdk',
        'USERPROFILE':str(WORK/'Home'),'HOME':str(WORK/'Home'),'APPDATA':str(WORK/'Home/AppData/Roaming'),
        'LOCALAPPDATA':str(WORK/'Home/AppData/Local'),'TEMP':str(WORK/'tmp'),'TMP':str(WORK/'tmp'),
        'GRADLE_USER_HOME':str(WORK/'GradleHome'),'GRADLE_RO_DEP_CACHE':r'C:\Inputs\DependencyCache',
        'ANDROID_HOME':r'C:\Inputs\AndroidSdk','ANDROID_SDK_ROOT':r'C:\Inputs\AndroidSdk',
        'FLUTTER_ROOT':r'C:\Inputs\Flutter','PUB_CACHE':r'C:\Inputs\Pub'}

def mappings(root,mode):
    result=[(root/'probe',r'C:\Probe',True),(root/'output',r'C:\ProbeOutput',False),
        (layout.JDK,r'C:\Inputs\Jdk',True)]
    if mode=='gradle':
        result +=[(layout.FLUTTER,r'C:\Inputs\Flutter',True),(layout.SDK,r'C:\Inputs\AndroidSdk',True),
            (GRADLE,r'C:\Inputs\Gradle',True),(layout.SEED,r'C:\Inputs\DependencyCache',True),
            (PRIOR/'inputs/native',r'C:\Inputs\Pub',True),(root/'inputs/product',r'C:\Inputs\Product',True),
            (layout.TOOLING,r'C:\Inputs\ToolingSnapshot',True),(root/'inputs/adapters',r'C:\Inputs\Adapters',True)]
    return result

def config(root,m):
    tree=ET.Element('Configuration')
    for name in ['vGPU','Networking','AudioInput','VideoInput','PrinterRedirection','ClipboardRedirection']:
        ET.SubElement(tree,name).text='Disable'
    ET.SubElement(tree,'ProtectedClient').text='Enable';ET.SubElement(tree,'MemoryInMB').text='4096'
    folders=ET.SubElement(tree,'MappedFolders')
    for host,guest,readonly in mappings(root,m['mode']):
        if not host.is_dir():raise ValueError('Missing mapped input')
        for ancestor in [host,*host.parents]:
            if ancestor.is_symlink() or getattr(ancestor.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected mapped input')
        folder=ET.SubElement(folders,'MappedFolder')
        for key,value in [('HostFolder',str(host)),('SandboxFolder',guest),('ReadOnly',str(readonly).lower())]:ET.SubElement(folder,key).text=value
    ET.SubElement(ET.SubElement(tree,'LogonCommand'),'Command').text=r'C:\Probe\GradleDiagnostic.exe '+m['nonce']
    return ET.tostring(tree,encoding='unicode')+'\n'

def tree_files(root):
    rows=[]
    for directory,dirs,files in os.walk(root,followlinks=False):
        for name in dirs+files:
            p=Path(directory)/name
            if p.is_symlink() or getattr(p.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected distribution input')
        for name in files:
            p=Path(directory)/name;rows.append((p,p.relative_to(root)))
    return sorted(rows,key=lambda r:str(r[1]))

def add_input(inputs,bindings,host,guest,destination=None):
    pin=layout.safe_file(host);bindings.append({'host':str(host),**pin})
    row={'path':str(PureWindowsPath(guest)),'sha256':pin['sha256']}
    if destination is not None:row['destination']=str(PureWindowsPath(destination))
    inputs.append(row)

def product_inputs(root,inputs,bindings):
    _,prior=layout.frozen(PRIOR,PARENT)
    if (prior['source_commit'],prior['apps_tree'],prior['services_tree'])!=(SOURCE,APPS,SERVICES):raise ValueError('Fixed product identity mismatch')
    for row in prior['input_sets']['product']:
        source=layout.relative(PRIOR/'inputs/product',row['relative']);dest=layout.relative(root/'inputs/product',row['relative'])
        layout.copy_new(source,dest,row['sha256'])
    module=root/'inputs/product/apps/flutter_elitesync_module/.android'
    generated=HERE.parent.parent/'apps/flutter_elitesync_module/.android'
    generated_files=[generated/name for name in ['settings.gradle','include_flutter.groovy','gradle.properties','build.gradle','Flutter/build.gradle','app/build.gradle']]
    for relative in ['src','Flutter/src','app/src']:
        directory=generated/relative
        if directory.exists():generated_files.extend(path for path,_ in tree_files(directory))
    for source in generated_files:
        pin=layout.safe_file(source);bindings.append({'host':str(source),**pin})
        layout.copy_new(source,module/source.relative_to(generated),pin['sha256'])
    put(root/'generated-source-pins-private.json',[{'relative':str(path.relative_to(generated)),'sha256':sha(path)} for path in generated_files])
    adaptations=[]
    for name in ['settings.gradle','include_flutter.groovy','gradle.properties']:
        path=module/name;original=path.read_bytes();changed=adapt_text('/'+name,original.decode())
        path.write_text(changed,encoding='utf-8',newline='\n')
        adaptations.append({'relative':str(path.relative_to(root/'inputs/product')),'before_sha256':hashlib.sha256(original).hexdigest(),'after_sha256':sha(path)})
    write(module/'local.properties',b'flutter.sdk=C:/Inputs/Flutter\nsdk.dir=C:/Inputs/AndroidSdk\nflutter.versionCode=1010501\nflutter.versionName=10.1.5-dev\n')
    metadata_source=HERE.parent.parent/'apps/flutter_elitesync_module/.flutter-plugins-dependencies'
    metadata_pin=layout.safe_file(metadata_source);bindings.append({'host':str(metadata_source),**metadata_pin})
    raw_metadata=metadata_source.read_bytes()
    if hashlib.sha256(raw_metadata).hexdigest()!=metadata_pin['sha256']:raise ValueError('Generated plugin metadata drift')
    metadata=json.loads(raw_metadata)
    names={r['relative'].split('/')[0] for r in prior['input_sets']['native']}
    android=metadata['plugins']['android'];native={r['name'] for r in android if r.get('native_build',True)}
    if names!=native:raise ValueError('Actual native plugin set drift')
    for r in android:r['path']='C:/Inputs/Pub/'+r['name']+'/'
    # Non-Android entries are outside this diagnostic's platform. Preserve Android dependency metadata.
    metadata['plugins']={'android':android}
    write(module.parent/'.flutter-plugins-dependencies',(json.dumps(metadata)+'\n').encode())
    for path,relative in tree_files(root/'inputs/product'):
        add_input(inputs,bindings,path,PureWindowsPath(r'C:\Inputs\Product')/str(relative),WORK/'Project'/str(relative))
    for group,host,guest in [('native',PRIOR/'inputs/native',r'C:\Inputs\Pub'),('tooling',layout.TOOLING,r'C:\Inputs\ToolingSnapshot'),('seed',layout.SEED,r'C:\Inputs\DependencyCache')]:
        for r in prior['input_sets'][group]:
            add_input(inputs,bindings,layout.relative(host,r['relative']),PureWindowsPath(guest)/r['relative'],WORK/'Tooling'/r['relative'] if group=='tooling' else None)
    for name,source in [('current-product-config-guard.init.gradle',HERE/'current_product_config_guard.init.gradle'),('aar-registration.init.gradle',layout.FLUTTER/'packages/flutter_tools/gradle/aar_init_script.gradle')]:
        path=root/'inputs/adapters'/name;write(path,source.read_bytes())
        add_input(inputs,bindings,path,PureWindowsPath(r'C:\Inputs\Adapters')/name,WORK/'Adapters'/name)
    pins={r['destination']:r['sha256'] for r in inputs if 'destination' in r}
    put(root/'probe/guard-contract.json',{'project_properties':properties(),'source_pins':pins,'native_plugins':sorted(names),'output_roots':expected_outputs(names)})
    put(root/'adaptations-private.json',adaptations)
    return prior

def monitor_qualification_path(native_sha256,controller_sha256):
    for value in [native_sha256,controller_sha256]:
        if type(value) is not str or re.fullmatch('[0-9a-f]{64}',value) is None:raise ValueError('Exact source identities required')
    # Prefix collisions fail full-identity validation/open-x rather than replacing another record.
    return TASK_ROOT/('monitor-qualification-'+native_sha256[:20]+'-'+controller_sha256[:20]+'.json')

def validate_monitor_record(record,*,native_sha256,controller_sha256,binary_identity,manifest_sha256,receipt_sha256):
    keys={'schema','kind','qualified','native_source_sha256','controller_sha256','binary_identity','receipt_sha256','manifest_sha256','root','disk_churn_operations','gradle_starts','G2'}
    if type(record) is not dict or set(record)!=keys or type(record['schema']) is not int or record['schema']!=2:raise ValueError('Unknown monitor qualification schema')
    identity=record['binary_identity']
    if type(identity) is not dict or set(identity)!={'bytes','file_id','sha256'} or type(identity['bytes']) is not int or identity['bytes']<=0 or type(identity['file_id']) is not list or len(identity['file_id'])!=2 or any(type(value) is not int for value in identity['file_id']):raise ValueError('Unknown qualified binary identity')
    if type(record['root']) is not str or not Path(record['root']).is_absolute() or Path(record['root']).parent!=TASK_ROOT:raise ValueError('Qualification root outside task')
    for digest in [identity['sha256'],record['native_source_sha256'],record['controller_sha256'],record['manifest_sha256'],record['receipt_sha256']]:
        if type(digest) is not str or re.fullmatch('[0-9a-f]{64}',digest) is None:raise ValueError('Exact qualification digest required')
    if record['kind']!='java-tree-and-disk-churn' or record['qualified'] is not True or record['G2'] is not False or type(record['gradle_starts']) is not int or record['gradle_starts']!=0:raise ValueError('No runtime authority inherited from qualification')
    for key,value in [('native_source_sha256',native_sha256),('controller_sha256',controller_sha256),('binary_identity',binary_identity),('manifest_sha256',manifest_sha256),('receipt_sha256',receipt_sha256)]:
        if record[key]!=value:raise ValueError('Qualification evidence identity drift: '+key)
    if type(record['disk_churn_operations']) is not int or record['disk_churn_operations']<1:raise ValueError('Real disk churn not demonstrated')

def qualified_monitor():
    native=sha(HERE/'windows_sandbox_gradle_diagnostic.cs');controller=sha(Path(__file__))
    path=monitor_qualification_path(native,controller)
    layout.safe_file(path);record=json.loads(path.read_bytes())
    root=Path(record['root']).absolute()
    if root.parent!=TASK_ROOT:raise ValueError('Qualification must belong to this owned task')
    for ancestor in [root,*root.parents]:
        if ancestor.is_symlink() or getattr(ancestor.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected qualification root')
    manifest=root/'manifest.json';receipt=root/'output/result.json';binary=root/'probe/GradleDiagnostic.exe'
    layout.safe_file(manifest);layout.safe_file(receipt)
    validate_monitor_record(record,native_sha256=native,controller_sha256=controller,binary_identity=layout.safe_file(binary),manifest_sha256=sha(manifest),receipt_sha256=sha(receipt))
    m=json.loads(manifest.read_bytes());r=json.loads(receipt.read_bytes())
    if m['mode']!='qualify' or m['native_source_sha256']!=native or m['controller_sha256']!=controller:raise ValueError('Qualification manifest source/mode drift')
    if r['binary_sha256']!=record['binary_identity']['sha256']:raise ValueError('Qualified binary/receipt mismatch')
    validate_launch_chain(root,m);validate_result(r,m)
    current_images=[{'path':str(PureWindowsPath(r'C:\Inputs\Jdk\bin')/name),'sha256':sha(layout.JDK/'bin'/name)} for name in ['java.exe','javaw.exe']]
    if m['images']!=current_images or m['environment']!=environment():raise ValueError('Qualification Java/environment drift')
    return path,record,binary

def prepare(root,mode):
    root=Path(root).absolute()
    if root.parent!=TASK_ROOT or root.exists():raise ValueError('One new direct attempt directory required')
    authorization=json.loads((TASK_ROOT/'owner-authorization.json').read_bytes())
    if authorization.get('owner_answer')!='授权上述独立3次诊断范围' or authorization.get('max_attempts')!=3:raise ValueError('Missing explicit new authorization')
    qualification=qualified_monitor() if mode=='gradle' else None
    root.mkdir()
    for name in ['probe','output','inputs/product','inputs/adapters']:(root/name).mkdir(parents=True)
    inputs=[];bindings=[]
    if mode=='gradle':product_inputs(root,inputs,bindings)
    elif mode!='qualify':raise ValueError('Unknown mode')
    if mode=='gradle':
        for relative in ['LICENSE','bin/cache/engine.stamp','bin/cache/engine.realm','bin/internal/engine.version']:
            add_input(inputs,bindings,layout.FLUTTER/relative,PureWindowsPath(r'C:\Inputs\Flutter')/relative)
        for category in ['platforms','build-tools','ndk','cmake']:
            base=layout.SDK/category
            if not base.is_dir():continue
            for version in sorted(base.iterdir()):
                if not version.is_dir():continue
                for name in ['source.properties','package.xml','android.jar','core-for-system-modules.jar']:
                    anchor=version/name
                    if anchor.is_file():add_input(inputs,bindings,anchor,PureWindowsPath(r'C:\Inputs\AndroidSdk')/str(anchor.relative_to(layout.SDK)))
    for tool_root,guest in [(layout.JDK,r'C:\Inputs\Jdk')]+([(GRADLE,r'C:\Inputs\Gradle')] if mode=='gradle' else []):
        for path,relative in (tree_files(tool_root) if tool_root!=GRADLE else [(p,Path('lib')/rel) for p,rel in tree_files(GRADLE/'lib')]+[(GRADLE/name,Path(name)) for name in ['LICENSE','NOTICE']]):add_input(inputs,bindings,path,PureWindowsPath(guest)/str(relative))
    shutil.copyfile(HERE/'windows_sandbox_gradle_diagnostic.cs',root/'probe/GradleDiagnostic.cs')
    compiler=Path(os.environ.get('SystemRoot',r'C:\Windows'))/'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    for binary,signer in [(compiler,'Microsoft Windows'),(layout.JDK/'bin/java.exe','Eclipse')]:
        script="$s=Get-AuthenticodeSignature -LiteralPath '"+str(binary).replace("'","''")+"';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch '"+signer+"'){exit 1}"
        if subprocess.run(['pwsh','-NoProfile','-Command',script],capture_output=True,timeout=30).returncode:raise ValueError('Existing tool signature not qualified')
    for name in ['host-compile-temp','empty-classpath','host-compile-home']:(root/name).mkdir()
    env=layout.compiler_environment(root)
    commands=[]
    if mode=='qualify':commands=[('csc',[str(compiler),'/nologo','/target:winexe','/platform:x64','/r:System.Web.Extensions.dll','/out:'+str(root/'probe/GradleDiagnostic.exe'),str(root/'probe/GradleDiagnostic.cs')])]
    else:layout.copy_new(qualification[2],root/'probe/GradleDiagnostic.exe',qualification[1]['binary_identity']['sha256'])
    if mode=='qualify':
        shutil.copyfile(HERE/'DiagnosticMonitorFixture.java',root/'probe/DiagnosticMonitorFixture.java')
        commands.append(('javac',[str(layout.JDK/'bin/javac.exe'),'-proc:none','-classpath',str(root/'empty-classpath'),'-sourcepath',str(root/'empty-classpath'),'-J-Duser.home='+str(root/'host-compile-home'),'-J-Djava.io.tmpdir='+str(root/'host-compile-temp'),'-d',str(root/'probe'),str(root/'probe/DiagnosticMonitorFixture.java')]))
    for name,args in commands:
        r=subprocess.run(args,env=env,cwd=root,capture_output=True,timeout=60)
        (root/(name+'.stdout')).write_bytes(r.stdout);(root/(name+'.stderr')).write_bytes(r.stderr)
        if r.returncode:raise ValueError('Compilation failed; preserve diagnostics')
    for path in (root/'probe').iterdir():
        if path.name=='manifest.json':continue
        add_input(inputs,bindings,path,PureWindowsPath(r'C:\Probe')/path.name)
    args=command(mode);dirs=[WORK/'Home',WORK/'tmp',WORK/'GradleHome',WORK/'state/project-cache',WORK/'state/cmake/jni',WORK/'AarOutput']
    if mode=='qualify':dirs.append(MODULE)
    m={'schema':1,'kind':'current-product-offline-config','mode':mode,'nonce':uuid.uuid4().hex,
        'source_commit':SOURCE,'apps_tree':APPS,'services_tree':SERVICES,'binary_sha256':sha(root/'probe/GradleDiagnostic.exe'),
        'inputs':inputs,'images':[{'path':str(PureWindowsPath(r'C:\Inputs\Jdk\bin')/name),'sha256':sha(layout.JDK/'bin'/name)} for name in ['java.exe','javaw.exe']],
        'private_directories':[str(p) for p in dirs],'executable':JAVA,'arguments':args,'command_line':subprocess.list2cmdline(args),
        'cwd':str(MODULE),'environment':environment(),'bindings':bindings,
        'controller_sha256':sha(Path(__file__)),'native_source_sha256':sha(HERE/'windows_sandbox_gradle_diagnostic.cs'),
        'authorization_sha256':sha(TASK_ROOT/'owner-authorization.json'),'G2':False,'apk_allowed':False}
    if qualification:
        m['qualification_record_path']=str(qualification[0]);m['qualification_record_sha256']=sha(qualification[0])
    m['helper_pins']={str(path):sha(path) for path in [Path(layout.__file__),Path(common.__file__),HERE/'current_product_diagnostic_contract.py',HERE/'windows_sandbox_launch.ps1']}
    m['semantic_sha256']=data_sha({'mode':mode,'command':args,'native_source':m['native_source_sha256'],'inputs':[r for r in inputs if r['path']!=r'C:\Probe\GradleDiagnostic.exe']})
    put(root/'manifest.json',m);put(root/'probe/manifest.json',m)
    (root/'diagnostic.wsb').write_text(config(root,m),encoding='utf-8')
    if SizeHost(root)>512*1024*1024:raise ValueError('Host new input/output budget exceeded')
    print(json.dumps({'prepared':mode,'input_files':len(inputs),'manifest_sha256':sha(root/'manifest.json'),'gradle_starts':0}))

def SizeHost(root):return sum(p.stat().st_size for p in root.rglob('*') if p.is_file())

def frozen(root):
    root=Path(root).absolute()
    if root.parent!=TASK_ROOT:raise ValueError('Task root mismatch')
    for ancestor in [root,*root.parents]:
        if ancestor.is_symlink() or getattr(ancestor.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected task root')
    m=json.loads((root/'manifest.json').read_bytes())
    if any(sha(path)!=digest for path,digest in m['helper_pins'].items()):raise ValueError('Controller dependency drift')
    if m['controller_sha256']!=sha(Path(__file__)) or m['native_source_sha256']!=sha(HERE/'windows_sandbox_gradle_diagnostic.cs'):raise ValueError('Diagnostic source drift')
    if m['authorization_sha256']!=sha(TASK_ROOT/'owner-authorization.json'):raise ValueError('Authorization drift')
    if m['arguments']!=command(m['mode']) or m['command_line']!=subprocess.list2cmdline(command(m['mode'])) or m['environment']!=environment():raise ValueError('Command/environment drift')
    for r in m['bindings']:
        if layout.safe_file(r['host'])!={k:r[k] for k in ['bytes','file_id','sha256']}:raise ValueError('Bound input drift')
    if (root/'manifest.json').read_bytes()!=(root/'probe/manifest.json').read_bytes():raise ValueError('Guest manifest drift')
    if (root/'diagnostic.wsb').read_text()!=config(root,m):raise ValueError('Mapping drift')
    return root,m

def ledger():
    x={'schema':1,'task':TASK,'owner_authorized':True,'max_attempts':3,'legacy_claims_reused':False,'G2':False,'reservations':[]}
    seen=False
    for n in range(1,4):
        path=TASK_ROOT/('reservation-'+str(n)+'.json')
        if not path.exists():seen=True;continue
        if seen:raise ValueError('Gap in permanent reservations')
        prior=json.loads(path.read_bytes());validate_ledger(prior)
        if len(prior['reservations'])!=n or prior['reservations'][:-1]!=x['reservations']:raise ValueError('Permanent reservation history drift')
        x=prior
    return x

def launch(root):
    root,m=frozen(root)
    if any((root/'output').iterdir()) or (root/'launch.claim.json').exists():raise ValueError('Fresh unlaunched output required')
    # Launcher also checks ownership; perform this before consuming a diagnostic reservation.
    ps=subprocess.run(['pwsh','-NoProfile','-Command','if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}'],capture_output=True,timeout=30)
    if ps.returncode:raise ValueError('Existing Sandbox is not owned by this launch')
    if m['mode']=='gradle':
        previous_ledger=ledger()
        for reservation in previous_ledger['reservations']:
            outcome=json.loads((TASK_ROOT/('outcome-'+str(reservation['attempt'])+'.json')).read_bytes())
            validate_prior_outcome(outcome,reservation)
            if outcome.get('status')=='CONFIG_DIAGNOSTIC_SAFETY_STOP':
                decision=json.loads((root/('continuation-of-'+str(reservation['attempt'])+'.json')).read_bytes())
                validate_continuation(decision,outcome,m)
        qualification_path,proof,_=qualified_monitor()
        if str(qualification_path)!=m.get('qualification_record_path') or sha(qualification_path)!=m.get('qualification_record_sha256') or proof['binary_identity']['sha256']!=m['binary_sha256']:raise ValueError('Native monitor qualification/binary changed after preparation')
        for path in TASK_ROOT.glob('*/launch.claim.json'):
            old=json.loads(path.read_bytes())
            if old.get('mode')=='gradle' and old.get('semantic_sha256')==m['semantic_sha256']:raise ValueError('Unchanged semantic input cannot be retried in another directory')
        new=next_reservation(previous_ledger,manifest_sha256=sha(root/'manifest.json'),command_sha256=data_sha(m['arguments']))
        put(TASK_ROOT/('reservation-'+str(len(new['reservations']))+'.json'),new)
    put(root/'launch.claim.json',{'attempt':len(new['reservations']) if m['mode']=='gradle' else 0,'mode':m['mode'],'manifest_sha256':sha(root/'manifest.json'),'semantic_sha256':m['semantic_sha256'],'refundable':False,'G2':False})
    r=subprocess.run(['pwsh','-NoProfile','-File',str(HERE/'windows_sandbox_launch.ps1'),'-ConfigPath',str(root/'diagnostic.wsb')],capture_output=True,timeout=30)
    (root/'launcher.stdout').write_bytes(r.stdout);(root/'launcher.stderr').write_bytes(r.stderr)
    if r.returncode:raise ValueError('Launch failed; claim and any reserved diagnostic remain consumed')
    put(root/'launched.json',json.loads(r.stdout.decode('utf-8-sig')));print('Launched '+m['mode'])

def validate_prior_outcome(outcome,reservation):
    allowed={'CONFIG_DIAGNOSTIC_SAFETY_STOP','OFFLINE_INPUT_MISSING','CONFIGURATION_FAILED','CONFIG_GRAPH_NOT_PROVEN','CONFIG_GRAPH_ROUTING_NOT_PROVEN','CONFIG_GRAPH_SELECTS_DOCUMENTATION_TASK','CONFIG_GRAPH_BOUNDED_SUPPORTED'}
    if type(outcome) is not dict or outcome.get('mode')!='gradle' or outcome.get('status') not in allowed:raise ValueError('Prior diagnostic outcome unknown')
    if outcome.get('manifest_sha256')!=reservation['manifest_sha256'] or type(outcome.get('receipt_sha256')) is not str or re.fullmatch('[0-9a-f]{64}',outcome['receipt_sha256']) is None:raise ValueError('Prior outcome evidence identity mismatch')
    if outcome.get('G2') is not False or type(outcome.get('apk_builds')) is not int or outcome['apk_builds']!=0:raise ValueError('Prior protected build state unknown')
    proof=outcome.get('proof') or {}
    if proof.get('job_final_empty') is not True or proof.get('all_bound_handles_exited') is not True:raise ValueError('Prior job exit not proven')

def validate_continuation(note,prior,m):
    required={'decision_by','prior_manifest_sha256','prior_receipt_sha256','new_semantic_sha256','cause','static_fix_evidence_sha256','new_controller_sha256','scope_unchanged','preconditions_revalidated','owner_new_permission_required'}
    if type(note) is not dict or set(note)!=required:raise ValueError('Explicit bounded continuation decision required')
    if note['decision_by']!='Codex' or note['scope_unchanged'] is not True or note['preconditions_revalidated'] is not True or note['owner_new_permission_required'] is not False:raise ValueError('New permissions or unresolved conditions block continuation')
    for key,value in [('prior_manifest_sha256',prior['manifest_sha256']),('prior_receipt_sha256',prior['receipt_sha256']),('new_semantic_sha256',m['semantic_sha256']),('new_controller_sha256',m['controller_sha256'])]:
        if note[key]!=value:raise ValueError('Continuation evidence identity mismatch')
    if type(note['cause']) is not str or not note['cause'].strip() or re.fullmatch('[0-9a-f]{64}',note['static_fix_evidence_sha256']) is None:raise ValueError('Cause and concrete check evidence required')

def validate_launch_chain(root,m):
    digest=sha(root/'manifest.json');claim=json.loads((root/'launch.claim.json').read_bytes())
    required={'attempt','mode','manifest_sha256','semantic_sha256','refundable','G2'}
    if type(claim) is not dict or set(claim)!=required or type(claim['attempt']) is not int:raise ValueError('Invalid launch claim')
    if claim['mode']!=m['mode'] or claim['manifest_sha256']!=digest or claim['semantic_sha256']!=m['semantic_sha256'] or claim['refundable'] is not False or claim['G2'] is not False:raise ValueError('Launch claim binding drift')
    if m['mode']=='gradle':
        matches=[r for r in ledger()['reservations'] if r['attempt']==claim['attempt'] and r['manifest_sha256']==digest and r['command_sha256']==data_sha(m['arguments'])]
        if len(matches)!=1:raise ValueError('No exact permanent reservation binding')
    elif claim['attempt']!=0:raise ValueError('Fixture cannot consume a Gradle reservation')
    launched=json.loads((root/'launched.json').read_bytes())
    if type(launched.get('pid')) is not int or launched['pid']<=0 or not launched.get('creationUtc'):raise ValueError('Missing actual host launch identity')
    return claim

def validate_result(r,m):
    if type(r.get('schema')) is not int or r['schema']!=1 or r.get('nonce')!=m['nonce'] or r.get('binary_sha256')!=m['binary_sha256'] or r.get('mode')!=m['mode']:raise ValueError('Guest identity mismatch')
    if r.get('failure') is not None or r.get('G2') is not False or type(r.get('apk_builds')) is not int or r['apk_builds']!=0:raise ValueError('Guest failure or unknown build count')
    if type(r.get('input_files')) is not int or r['input_files']!=len(m['inputs']):raise ValueError('Incomplete bound input verification')
    p=r.get('proof') or {}
    if p.get('job_final_empty') is not True or p.get('all_bound_handles_exited') is not True:raise ValueError('Owned process exit not proven')
    if type(p.get('watchdog_stop')) is not int:raise ValueError('Watchdog state unknown')
    if type(r.get('gradle_root_attempts')) is not int or r['gradle_root_attempts']!=(1 if m['mode']=='gradle' else 0):raise ValueError('Actual Gradle root attempt unknown')
    if m['mode']=='qualify':
        if type(p.get('disk_scans_completed')) is not int or p['disk_scans_completed']<4 or type(p.get('disk_scan_retries')) is not int or p['disk_scan_retries']<0:raise ValueError('Disk scan workload not observed')
        if type(p.get('bound_members')) is not int or p['bound_members']<2 or type(p.get('successful_samples')) is not int or p['successful_samples']<5 or 'NON_LOOPBACK_TCP' not in str(p.get('stop_reason')) or p['watchdog_stop']!=0:raise ValueError('Java monitor qualification not demonstrated')
    elif p.get('stop_reason') is None and type(p.get('root_exit')) is not int:raise ValueError('Root exit unknown')
    return p

def classify(p,text,plugins,routing):
    if p.get('stop_reason'):return 'CONFIG_DIAGNOSTIC_SAFETY_STOP'
    if 'No cached version' in text or 'offline mode' in text:return 'OFFLINE_INPUT_MISSING'
    if p['root_exit']!=0:return 'CONFIGURATION_FAILED'
    selected=set(re.findall(r'^(:[^\s]+) SKIPPED$',text,re.M))
    required={':flutter:assembleAarRelease'}|{':'+name+':assembleAarRelease' for name in plugins}
    if not required<=selected:return 'CONFIG_GRAPH_NOT_PROVEN'
    expected=expected_outputs(plugins)
    actual=[r for r in routing if r.get('event')=='project_output']
    if len(actual)!=len(expected) or {r.get('project'):str(r.get('path')).casefold() for r in actual}!={key:value.casefold() for key,value in expected.items()}:return 'CONFIG_GRAPH_ROUTING_NOT_PROVEN'
    if not any(r.get('event')=='jni_cmake_finalized' and str(r.get('path')).casefold()==str(WORK/'state/cmake/jni').casefold() for r in routing):return 'CONFIG_GRAPH_ROUTING_NOT_PROVEN'
    if any('javadoc' in name.lower() or 'dokka' in name.lower() for name in selected):return 'CONFIG_GRAPH_SELECTS_DOCUMENTATION_TASK'
    return 'CONFIG_GRAPH_BOUNDED_SUPPORTED'

def collect(root):
    root,m=frozen(root);claim=validate_launch_chain(root,m);r=json.loads((root/'output/result.json').read_bytes())
    p=validate_result(r,m)
    query="$o=Get-Content -LiteralPath '"+str(root/'launched.json').replace("'","''")+"' -Raw|ConvertFrom-Json;$p=Get-Process -Id ([int]$o.pid) -ErrorAction SilentlyContinue;if($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$o.creationUtc).ToUniversalTime()){exit 1};if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}"
    if subprocess.run(['pwsh','-NoProfile','-Command',query],capture_output=True,timeout=30).returncode:raise ValueError('Sandbox process absence not proven')
    if m['mode']=='qualify':
        positive=int((root/'output/fixture-positive.txt').read_text())
        rows=[json.loads(line) for line in (root/'output/samples.jsonl').read_text().splitlines()]
        if not any(e.get('local_port')==positive and e.get('local') in ['127.0.0.1','::1'] for row in rows for e in row.get('endpoints',[])):raise ValueError('Positive Java endpoint not observed')
        operations=int((root/'output/fixture-churn-operations.txt').read_text())
        record={'schema':2,'kind':'java-tree-and-disk-churn','qualified':True,'native_source_sha256':m['native_source_sha256'],'controller_sha256':m['controller_sha256'],'binary_identity':layout.safe_file(root/'probe/GradleDiagnostic.exe'),'receipt_sha256':sha(root/'output/result.json'),'manifest_sha256':sha(root/'manifest.json'),'root':str(root),'disk_churn_operations':operations,'gradle_starts':0,'G2':False}
        validate_monitor_record(record,native_sha256=m['native_source_sha256'],controller_sha256=m['controller_sha256'],binary_identity=layout.safe_file(root/'probe/GradleDiagnostic.exe'),manifest_sha256=sha(root/'manifest.json'),receipt_sha256=sha(root/'output/result.json'))
        put(monitor_qualification_path(m['native_source_sha256'],m['controller_sha256']),record)
        status='JAVA_TREE_MONITOR_BOUNDED_SUPPORTED'
    else:
        text=(root/'output/gradle.stdout').read_text(errors='replace')+(root/'output/gradle.stderr').read_text(errors='replace')
        contract=json.loads((root/'probe/guard-contract.json').read_bytes())
        route=root/'output/guard-routing.jsonl'
        routing=[json.loads(line) for line in route.read_text().splitlines()] if route.exists() else []
        status=classify(p,text,contract['native_plugins'],routing)
    result={'status':status,'mode':m['mode'],'proof':p,'input_files':r.get('input_files'),'receipt_sha256':sha(root/'output/result.json'),'reserved_attempts':len(ledger()['reservations']),'manifest_sha256':sha(root/'manifest.json'),'G2':False,'apk_builds':0,'background_vm_teardown':'UNKNOWN'}
    put(root/'verified-result.json',result)
    if m['mode']=='gradle':put(TASK_ROOT/('outcome-'+str(claim['attempt'])+'.json'),result)
    print(json.dumps(result))

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('action',choices=['prepare','launch','collect']);parser.add_argument('--root',type=Path,required=True);parser.add_argument('--mode',choices=['qualify','gradle'],default='gradle')
    a=parser.parse_args()
    if a.action=='prepare':prepare(a.root,a.mode)
    else:{'launch':launch,'collect':collect}[a.action](a.root)
