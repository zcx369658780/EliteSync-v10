"""Prepare one readonly-input/private-work filesystem rehearsal. No Gradle."""
import argparse
import hashlib
import io
import json
import os
from pathlib import Path, PureWindowsPath
import re
import shutil
import subprocess
import uuid
import xml.etree.ElementTree as ET

import windows_sandbox_probe as common
from windows_sandbox_runtime_probe import identity as program_identity
import windows_sandbox_runtime_probe as runtime_helper
import current_product_build_plan as plan_helper

HERE=Path(__file__).resolve().parent
JDK=Path(r'C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot')
FLUTTER=Path(r'D:\flutter')
SDK=Path.home()/'AppData/Local/Android/sdk'
PRIOR=Path.home()/'EliteSyncDev/v1015-build-routing-20261101-01'
TOOLING=PRIOR/'tooling-input-snapshot/Flutter'
OLD=Path.home()/'.codex/v1015-g2-single-seed-2gib-20261028'
SEED=OLD/'readonly-dependency-cache'
PUBLIC_SOURCE_LIST_SHA='2680fdcec320418c3a5184a007fef691e3987b6035a292a9036c901a8f97bd74'


def sha(path):
    with Path(path).open('rb') as stream:return hashlib.file_digest(stream,'sha256').hexdigest()


def safe_file(path):
    path=Path(path).absolute()
    for ancestor in [path,*path.parents]:
        if ancestor.is_symlink() or getattr(ancestor.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected input')
    info=path.stat()
    if not path.is_file() or info.st_nlink!=1:raise ValueError('Not a single-link regular input')
    return {'bytes':info.st_size,'file_id':[info.st_dev,info.st_ino],'sha256':sha(path)}


def relative(root,name):
    path=PureWindowsPath(name)
    if path.drive or path.root or '..' in path.parts or any(':' in part or part.rstrip(' .')!=part for part in path.parts):
        raise ValueError('Unsafe input relative path')
    result=Path(root).joinpath(*path.parts)
    if not result.absolute().is_relative_to(Path(root).absolute()):raise ValueError('Input escape')
    return result


def copy_new(source,dest,expected):
    if safe_file(source)['sha256']!=expected:raise ValueError('Source snapshot drift')
    dest.parent.mkdir(parents=True,exist_ok=True)
    with Path(source).open('rb') as src,dest.open('xb') as dst:
        shutil.copyfileobj(src,dst);dst.flush();os.fsync(dst.fileno())
    if sha(dest)!=expected:raise ValueError('Snapshot copy mismatch')


def compiler_environment(root):
    env=dict(os.environ)
    blocked={'JAVA_TOOL_OPTIONS','_JAVA_OPTIONS','JDK_JAVA_OPTIONS','JDK_JAVAC_OPTIONS','CLASSPATH','LIB',
             'DOTNET_STARTUP_HOOKS','DOTNET_ADDITIONAL_DEPS','DOTNET_SHARED_STORE'}
    for key in list(env):
        if key.upper() in blocked or key.upper().startswith(('COR_','CORECLR_','COMPLUS_')):env.pop(key)
    env['TEMP']=env['TMP']=str(root/'host-compile-temp')
    return env


def compile_programs(root,compiler):
    for name in ['empty-classpath','host-compile-temp','host-compile-home']:(root/name).mkdir(exist_ok=False)
    env=compiler_environment(root)
    commands=[('javac',[str(JDK/'bin/javac.exe'),'-proc:none','-classpath',str(root/'empty-classpath'),
        '-sourcepath',str(root/'empty-classpath'),'-J-Djava.io.tmpdir='+str(root/'host-compile-temp'),
        '-J-Duser.home='+str(root/'host-compile-home'),'-encoding','UTF-8','-d',str(root/'probe'),str(root/'probe/SandboxLayoutProbe.java')]),
        ('csc',[str(compiler),'/nologo','/target:winexe','/platform:x64','/r:System.Web.Extensions.dll',
         '/out:'+str(root/'probe/LayoutBootstrap.exe'),str(root/'probe/windows_sandbox_layout_probe.cs')])]
    for name,args in commands:
        common.event(root,'COMPILE_PREPARE',compiler=name)
        result=subprocess.run(args,capture_output=True,timeout=60,cwd=root,env=env)
        (root/(name+'.stdout')).write_bytes(result.stdout);(root/(name+'.stderr')).write_bytes(result.stderr)
        common.event(root,'COMPILE_RESULT',compiler=name,exit=result.returncode)
        if result.returncode:raise RuntimeError('Compilation failed; preserve diagnostics')


def mappings(root):
    return [('flutter',FLUTTER,r'C:\Inputs\Flutter'),('jdk',JDK,r'C:\Inputs\Jdk'),
        ('sdk',SDK,r'C:\Inputs\AndroidSdk'),('tooling',TOOLING,r'C:\Inputs\ToolingSnapshot'),
        ('seed',SEED,r'C:\Inputs\DependencyCache'),('native',root/'inputs/native',r'C:\Inputs\Pub'),
        ('product',root/'inputs/product',r'C:\Inputs\Product')]


def configuration(root,nonce,parent):
    tree=ET.fromstring(common.configuration(root,nonce,parent))
    folders=tree.find('MappedFolders');folders.remove(folders.findall('MappedFolder')[1])
    for role,host,guest in mappings(root):
        if not host.is_dir():raise ValueError('Missing readonly input root: '+role)
        for ancestor in [host,*host.parents]:
            if ancestor.is_symlink() or getattr(ancestor.lstat(),'st_file_attributes',0)&0x400:raise ValueError('Redirected input root')
        folder=ET.SubElement(folders,'MappedFolder')
        for key,value in [('HostFolder',str(host)),('SandboxFolder',guest),('ReadOnly','true')]:ET.SubElement(folder,key).text=value
    tree.find('./LogonCommand/Command').text=r'C:\Probe\LayoutBootstrap.exe '+nonce
    return ET.tostring(tree,encoding='unicode')+'\n'


def product_identity(product):
    source=subprocess.check_output(['git','rev-parse','HEAD'],cwd=product,text=True).strip()
    trees=subprocess.check_output(['git','rev-parse',source+':apps',source+':services'],cwd=product,text=True).splitlines()
    if subprocess.check_output(['git','diff',source,'--name-only','--','apps/android','apps/flutter_elitesync_module'],cwd=product).strip():raise ValueError('Dirty product inputs')
    listing=subprocess.check_output(['git','ls-tree','-rz','-l',source,'--','apps/android','apps/flutter_elitesync_module'],cwd=product)
    return source,trees,listing


def prepare(root,parent,product):
    root=Path(root).absolute();product=Path(product).resolve()
    if root.exists() or root==parent or not root.parent.resolve().is_relative_to(parent.resolve()):raise ValueError('New task root required')
    root.mkdir()
    for name in ['probe','fixture','output','inputs/product','inputs/native']:(root/name).mkdir(parents=True)
    common.validate_root(root,parent)
    source,trees,listing=product_identity(product)
    expected={}
    for entry in listing.split(b'\0'):
        if not entry:continue
        meta,name=entry.split(b'\t',1);mode,kind,blob,size=meta.split()
        if mode not in [b'100644',b'100755'] or kind!=b'blob':raise ValueError('Non-regular tracked source')
        expected[name.decode()]={'blob':blob.decode(),'bytes':int(size)}
    if len(expected)!=718 or sum(r['bytes'] for r in expected.values())>128*1024*1024:raise ValueError('Product snapshot scope drift')
    groups={key:[] for key in ['product','native','tooling','seed']}
    request=('\n'.join(row['blob'] for row in expected.values())+'\n').encode()
    result=subprocess.run(['git','cat-file','--batch'],input=request,capture_output=True,cwd=product,check=True,timeout=60)
    objects=io.BytesIO(result.stdout)
    for name,row in expected.items():
        header=objects.readline().split()
        if header!=[row['blob'].encode(),b'blob',str(row['bytes']).encode()]:raise ValueError('Git object header mismatch')
        data=objects.read(row['bytes'])
        if objects.read(1)!=bytes([10]) or hashlib.sha1(b'blob '+str(len(data)).encode()+bytes([0])+data).hexdigest()!=row['blob']:raise ValueError('Git blob mismatch')
        dest=relative(root/'inputs/product',name);dest.parent.mkdir(parents=True,exist_ok=True)
        with dest.open('xb') as stream:stream.write(data)
        groups['product'].append({'relative':name,**safe_file(dest)})
    if objects.read():raise ValueError('Unexpected trailing Git object data')
    if sha(PRIOR/'selected-source-files-private.json')!=PUBLIC_SOURCE_LIST_SHA:raise ValueError('Prior selected source identity drift')
    selected=json.loads((PRIOR/'selected-source-files-private.json').read_bytes())
    for row in selected:
        if row['role'].startswith('plugin/'):
            plugin=row['role'].split('/',1)[1]
            if not re.fullmatch('[a-z0-9_]+',plugin):raise ValueError('Invalid plugin name')
            name=plugin+'/'+row['relative'];dest=relative(root/'inputs/native',name)
            copy_new(Path(row['path']),dest,row['sha256']);groups['native'].append({'relative':name,**safe_file(dest)})
        else:
            path=relative(TOOLING,row['relative']);pin=safe_file(path)
            if pin['sha256']!=row['sha256']:raise ValueError('Tooling snapshot drift')
            groups['tooling'].append({'relative':row['relative'],**pin})
    seed_rows=json.loads((OLD/'settled-seed-private.json').read_bytes())
    for row in seed_rows:
        name=row['targetRelative'].removeprefix('readonly-dependency-cache/')
        path=relative(SEED,name);pin=safe_file(path)
        if pin['sha256']!=row['sha256'] or pin['file_id']!=row['settledIdentity']['fileId']:raise ValueError('Old seed drift')
        groups['seed'].append({'relative':name,**pin})
    plugins=sorted({r['relative'].split('/')[0] for r in groups['native']})
    if [len(groups[k]) for k in ['product','native','tooling','seed']]!=[718,2145,50,3183] or len(plugins)!=14:raise ValueError('Snapshot count mismatch')
    nonce=uuid.uuid4().hex
    properties={'nonce':nonce,'plugins.count':str(len(plugins))}
    properties.update({'plugins.'+str(i):name for i,name in enumerate(plugins)})
    for group,rows in groups.items():
        properties[group+'.count']=str(len(rows))
        for i,row in enumerate(rows):
            properties[f'{group}.{i}.relative']=row['relative'];properties[f'{group}.{i}.sha256']=row['sha256']
    def escaped(value):return str(value).replace('\\','\\\\').replace('\n','\\n').replace('\r','\\r')
    (root/'probe/layout.properties').write_text(''.join(key+'='+escaped(value)+'\n' for key,value in properties.items()),encoding='utf-8')
    for name in ['SandboxLayoutProbe.java','windows_sandbox_layout_probe.cs']:shutil.copyfile(HERE/name,root/'probe'/name)
    compiler=Path(os.environ.get('SystemRoot',r'C:\Windows'))/'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
    for binary,signer in [(compiler,'Microsoft Windows'),(JDK/'bin/javac.exe','Eclipse'),(JDK/'bin/java.exe','Eclipse')]:
        command="$s=Get-AuthenticodeSignature -LiteralPath '"+str(binary).replace("'","''")+"';if($s.Status -ne 'Valid' -or $s.SignerCertificate.Subject -notmatch '"+signer+"'){exit 1}"
        result=subprocess.run(['pwsh','-NoProfile','-Command',command],capture_output=True,timeout=30)
        if result.returncode:raise RuntimeError('Existing tool signature failed')
    compile_programs(root,compiler)
    readonly_files=[r'C:\Inputs\Flutter\LICENSE',r'C:\Inputs\Jdk\release',r'C:\Inputs\AndroidSdk\platforms\android-36\source.properties',
        r'C:\Inputs\ToolingSnapshot\LICENSE',r'C:\Inputs\DependencyCache\modules-2\metadata-2.107\module-metadata.bin',
        r'C:\Inputs\Pub\jni\android\build.gradle',r'C:\Inputs\Product\apps\flutter_elitesync_module\pubspec.yaml']
    source_pins={str(path.relative_to(root/'probe')):sha(path) for path in (root/'probe').iterdir()}
    guest_pins={str(PureWindowsPath(r'C:\Probe')/name):digest for name,digest in source_pins.items() if name!='windows_sandbox_layout_probe.cs'}
    tool_pins=[]
    for host,guest in [(JDK/'bin/java.exe',r'C:\Inputs\Jdk\bin\java.exe'),(JDK/'bin/server/jvm.dll',r'C:\Inputs\Jdk\bin\server\jvm.dll'),
                       (FLUTTER/'LICENSE',r'C:\Inputs\Flutter\LICENSE'),(SDK/'platforms/android-36/source.properties',r'C:\Inputs\AndroidSdk\platforms\android-36\source.properties')]:
        pin=safe_file(host);tool_pins.append({'host':str(host),'guest':guest,**pin});guest_pins[guest]=pin['sha256']
    manifest={'schema':1,'kind':'readonly-input-layout','nonce':nonce,'source_commit':source,'apps_tree':trees[0],'services_tree':trees[1],
        'binary_sha256':sha(root/'probe/LayoutBootstrap.exe'),'source_pins':source_pins,'guest_pins':guest_pins,
        'input_sets':groups,'tool_pins':tool_pins,'readonly_files':readonly_files,'readonly_roots':[guest for _,_,guest in mappings(root)],
        'controller_sha256':sha(Path(__file__)),'common_sha256':sha(Path(common.__file__)),'runtime_sha256':sha(Path(runtime_helper.__file__)),
        'plan_helper_sha256':sha(Path(plan_helper.__file__)),'launcher_sha256':sha(HERE/'windows_sandbox_launch.ps1'),
        'max_launches':1,'gradle_allowed':False,'G2':False}
    plan=plan_helper.make_plan(source_commit=source,apps_tree=trees[0],services_tree=trees[1],stock_flutter=str(FLUTTER),
        source_pub=str(root/'inputs/native'),tooling_snapshot=str(TOOLING),old_seed=str(SEED))
    common.claim_once(root/'current-product-plan-private.json',plan)
    common.claim_once(root/'manifest.json',manifest);common.claim_once(root/'probe/manifest.json',manifest)
    (root/'qualification.wsb').write_text(configuration(root,nonce,parent),encoding='utf-8')
    common.event(root,'PREPARED',source_commit=source,input_files=sum(len(r) for r in groups.values()))


def frozen(root,parent):
    root=common.validate_root(root,parent);m=json.loads((root/'manifest.json').read_bytes())
    for path,key in [(Path(__file__),'controller_sha256'),(Path(common.__file__),'common_sha256'),(Path(runtime_helper.__file__),'runtime_sha256'),
                     (Path(plan_helper.__file__),'plan_helper_sha256'),(HERE/'windows_sandbox_launch.ps1','launcher_sha256')]:
        if sha(path)!=m[key]:raise ValueError('Controller/helper drift')
    for name,digest in m['source_pins'].items():
        if sha(relative(root/'probe',name))!=digest:raise ValueError('Program input drift')
    roots={role:host for role,host,_ in mappings(root)}
    for group,rows in m['input_sets'].items():
        for row in rows:
            if safe_file(relative(roots[group],row['relative']))!={key:row[key] for key in ['bytes','file_id','sha256']}:raise ValueError('Filesystem input drift')
    for pin in m['tool_pins']:
        if safe_file(pin['host'])!={key:pin[key] for key in ['bytes','file_id','sha256']}:raise ValueError('Tool identity drift')
    if (root/'probe/manifest.json').read_bytes()!=(root/'manifest.json').read_bytes():raise ValueError('Guest manifest drift')
    if (root/'qualification.wsb').read_text()!=configuration(root,m['nonce'],parent):raise ValueError('Mapping drift')
    return root,m


def launch(root,parent):
    root,m=frozen(root,parent)
    if any((root/'output').iterdir()):raise ValueError('Output must be empty')
    common.claim_once(root/'launch.claim.json',{'nonce':m['nonce'],'scope':m['kind'],'max_launches':1,'refundable':False,'gradle_allowed':False,'G2':False})
    result=subprocess.run(['pwsh','-NoProfile','-File',str(HERE/'windows_sandbox_launch.ps1'),'-ConfigPath',str(root/'qualification.wsb')],capture_output=True,timeout=30)
    (root/'launcher.stdout').write_bytes(result.stdout);(root/'launcher.stderr').write_bytes(result.stderr)
    common.event(root,'LAUNCH_RESULT',exit=result.returncode)
    if result.returncode:raise RuntimeError('Layout launch failed; no retry under this input')
    row=json.loads(result.stdout.decode('utf-8-sig'))
    if type(row.get('pid')) is not int or not row.get('creationUtc'):raise RuntimeError('Missing launch identity')
    common.claim_once(root/'launched.json',row);print(json.dumps(row))


def validate_receipts(receipt,layout,m):
    if type(receipt.get('schema')) is not int or receipt['schema']!=1:raise ValueError('Unknown bootstrap schema')
    if receipt.get('kind')!='readonly-input-layout' or receipt.get('nonce')!=m['nonce'] or receipt.get('username')!='WDAGUtilityAccount' or receipt.get('binary_sha256')!=m['binary_sha256']:raise ValueError('Guest identity mismatch')
    if receipt.get('failure') is not None or type(receipt.get('java_exit')) is not int or receipt['java_exit']!=0:raise ValueError('Guest layout probe failed')
    checks=receipt.get('readonly_checks') or []
    expected={(path,access,False) for path in m['readonly_files'] for access in [0x40000000,0x40000,0x80000]}
    expected|={(path,0x40,True) for path in m['readonly_roots']}
    actual={(r.get('path'),r.get('access'),r.get('directory')) for r in checks}
    if len(checks)!=28 or actual!=expected or any(type(r.get('directory')) is not bool or type(r.get('access')) is not int or r.get('succeeded') is not False or type(r.get('native_error')) is not int or r['native_error']!=5 for r in checks):raise ValueError('Readonly mapping evidence incomplete')
    if layout.get('nonce')!=m['nonce'] or layout.get('username')!='WDAGUtilityAccount' or layout.get('failure') is not None:raise ValueError('Java layout identity/failure')
    for key,value in [('product_files',718),('tooling_files',50),('native_files',2145),('seed_files',3183),('native_plugins',14),('private_writes',19)]:
        if type(layout.get(key)) is not int or layout[key]!=value:raise ValueError('Incomplete private layout: '+key)
    if layout.get('old_jni_generated_cache_visible') is not False or layout.get('original_guard_tooling_path_equal') is not False:raise ValueError('Unexpected source/guard layout')
    paths=layout.get('path_traits') or []
    expected_paths=[r'C:\Inputs\Flutter',r'C:\Inputs\Flutter\packages\flutter_tools\gradle',r'C:\Inputs\DependencyCache\modules-2',
        r'C:\Inputs\Pub\jni\android',r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android',
        r'C:\BuildWork\Tooling\packages\flutter_tools\gradle',r'C:\BuildWork\state\cmake\jni',r'C:\BuildWork\GradleHome']
    if len(paths)!=8 or [r.get('path') for r in paths]!=expected_paths:raise ValueError('Missing or mislabelled actual path traits')
    for row in paths:
        if not isinstance(row.get('real'),str) or any(type(row.get(key)) is not bool for key in ['canonical_equal','ancestors_clean','symbolic_link','other','directory']):raise ValueError('Unknown path traits')
    for row in paths[-4:]:
        if row.get('canonical_equal') is not True or row.get('ancestors_clean') is not True or row.get('symbolic_link') is not False or row.get('other') is not False or row.get('directory') is not True or row['real'].casefold()!=row['path'].casefold():raise ValueError('Private work is not canonical local storage')
    for row,keys in [(receipt,['clr_version','kernel_file_version']),(layout,['java_version','os_version','os_name'])]:
        if any(not isinstance(row.get(key),str) or not row[key] for key in keys):raise ValueError('Missing environment identity')
    for row in [receipt,layout]:
        for key in ['gradle_starts']+(['apk_builds'] if row is receipt else []):
            if type(row.get(key)) is not int or row[key]!=0:raise ValueError('Unexpected/unknown build execution')
        if row.get('G2') is not False:raise ValueError('Unexpected/unknown G2 result')
    if layout.get('gradle_index_parse') is not False or layout.get('agp_override_consumed') is not False:raise ValueError('Cannot promote filesystem evidence')


def collect(root,parent):
    root,m=frozen(root,parent)
    claim=json.loads((root/'launch.claim.json').read_bytes());launched=json.loads((root/'launched.json').read_bytes())
    if claim.get('nonce')!=m['nonce'] or type(launched.get('pid')) is not int:raise ValueError('Missing claimed launch')
    receipt=json.loads((root/'output/result.json').read_bytes());layout=json.loads((root/'output/layout-result.json').read_bytes())
    validate_receipts(receipt,layout,m)
    command="$o=Get-Content -LiteralPath '"+str(root/'launched.json').replace("'","''")+"' -Raw|ConvertFrom-Json;$p=Get-Process -Id ([int]$o.pid) -ErrorAction SilentlyContinue;if($p -and $p.StartTime.ToUniversalTime() -eq ([datetime]$o.creationUtc).ToUniversalTime()){exit 1};if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){exit 1}"
    result=subprocess.run(['pwsh','-NoProfile','-Command',command],capture_output=True,timeout=30)
    if result.returncode:raise ValueError('Sandbox exit not verified')
    summary={'status':'READONLY_INPUTS_PRIVATE_LAYOUT_BOUNDED_SUPPORTED','receipt_sha256':sha(root/'output/result.json'),
        'layout_sha256':sha(root/'output/layout-result.json'),'readonly_checks':28,'private_writes':19,'input_files_read':6096,
        'original_guard_conflict_preserved':True,'all_bound_host_inputs_unchanged':True,'sandbox_processes_absent':True,
        'background_vm_teardown':'UNKNOWN','gradle_index_parse':False,'agp_override_consumed':False,'full_build_qualified':False,
        'gradle_starts':0,'apk_builds':0,'G2':False}
    common.claim_once(root/'verified-result.json',summary);print(json.dumps(summary))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('command',choices=['prepare','launch','collect'])
    parser.add_argument('--root',type=Path,required=True);parser.add_argument('--product',type=Path,default=HERE.parent.parent)
    args=parser.parse_args();parent=Path.home()/'EliteSyncDev'
    if args.command=='prepare':prepare(args.root,parent,args.product)
    else:{'launch':launch,'collect':collect}[args.command](args.root,parent)
