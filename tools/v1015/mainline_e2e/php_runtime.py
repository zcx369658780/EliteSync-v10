"""Static private PHP preconditions. No module loading, Popen or network on import/inspect."""
import json,os,re
from pathlib import Path
from contracts import Gate,need,local,digest,canonical,validate_authority,validate_probe_authority
from pe_dependencies import pe_info
from migration_contract import require_runtime_policy
from central_vc_loader import validate_snapshot, verify_current

POLICY=Path(__file__).with_name("php_requirements.json")
OS_DLLS=frozenset(("kernel32 kernelbase ntdll advapi32 user32 gdi32 ws2_32 ole32 oleaut32 shell32 shlwapi crypt32 bcrypt secur32 dnsapi winmm iphlpapi psapi rpcrt4 version normaliz comdlg32 msvcrt ucrtbase winhttp wldap32 userenv netapi32 mpr").split())
ZERO_TASKS=frozenset(("128fa1f7746ee73ee6d52d2d693715b003a4ec13","1db7fc7eaadcea172cc52016904836bd71a0b90d","a307391e3872ff5367d84ddb7da86e53e531445e","a0eec472b58d53bc25084a395efc0748779d73f8","0854b37fdc9f11c55088ed2d2f93816a27bc2fa9","02018a930428bb6417c9fcdd811a6c1350b03988","48d3670ac26b1959c1b59ffb4871109cef09a4c8","8b6bd9233a08a7f4d0986d6f592eb114dec63e04","1ade4e5a89116eeba329311ed274229823aafd17","5f1c709e31af0d4f2c1c93363c147942db7116c5","d048f7f8fee97a93f8bf8c52293f60762fff0bda"))
def sha_ok(s):return isinstance(s,str) and re.fullmatch("[0-9a-f]{64}",s) is not None
def relative(value):
    need(isinstance(value,str) and value and not value.startswith("/") and "\\" not in value and ":" not in value,"PHP_RELATIVE_PATH")
    need(all(x not in ("",".","..") and not x.endswith(("."," ")) for x in value.split("/")),"PHP_PATH_TRAVERSAL")
    return value
def os_import(name):
    return name[:-4] in OS_DLLS or re.fullmatch("(?:api|ext)-ms-win-[a-z0-9-]+[.]dll",name) is not None
def validate_manifest(manifest,root,policy):
    """Internal pure/static validator; execution callers cannot inject a test policy."""
    need(sha_ok(policy.get("reference_executable_sha256")),"PHP_TARGET_EXECUTABLE_HASH_PENDING")
    root=local(root)
    need(manifest.get("schema")==1 and manifest.get("platform")=="windows-x64" and manifest.get("php_version")==policy["php_version"],"PHP_VERSION_ARCH")
    need(manifest.get("thread_safe") is policy["thread_safe"],"PHP_ABI_MISMATCH")
    need(manifest.get("requirements_sha256")==digest(canonical(policy)),"PHP_POLICY_MISMATCH")
    need(sha_ok(manifest.get("php_distribution_inventory_sha256")),"PHP_DISTRIBUTION_IDENTITY_REQUIRED")
    need(manifest.get("candidate_parent")==policy["candidate_parent"] and manifest.get("source_binding",{}).get("apps_tree")==policy["apps_tree"],"PHP_CANDIDATE_LINEAGE")
    files=manifest.get("files",[]);need(isinstance(files,list) and files,"PHP_FILES_REQUIRED")
    central=manifest.get("central_runtime")
    if central is not None:verify_current(central)
    by_path={};by_name={}
    for item in files:
        rel=relative(item["path"]);name=Path(rel).name.lower()
        need(name!="vcruntime140.dll","CENTRAL_RUNTIME_PRIVATE_COPY_FORBIDDEN")
        need(rel.casefold() not in by_path and name not in by_name,"PHP_DUPLICATE_BINARY")
        need(sha_ok(item.get("sha256")) and item.get("source_sha256")==item["sha256"] and sha_ok(item.get("source_inventory_sha256")),"PHP_SOURCE_PROVENANCE_REQUIRED")
        need(item.get("origin") in ("TRUSTED_EXISTING_PHP_DISTRIBUTION","TRUSTED_EXISTING_REDISTRIBUTABLE"),"PHP_SOURCE_UNAPPROVED")
        if item.get("origin")=="TRUSTED_EXISTING_PHP_DISTRIBUTION": need(item["source_inventory_sha256"]==manifest["php_distribution_inventory_sha256"],"PHP_DISTRIBUTION_MIXED")
        p=local(root/rel,root);need(p.is_file() and digest(p.read_bytes())==item["sha256"],"PHP_FILE_HASH")
        info=pe_info(p.read_bytes());by_path[rel.casefold()]=(item,p,info);by_name[name]=(item,p,info)
    actual=set();pending=[root]
    while pending:
        for child in pending.pop().iterdir():
            p=local(child,root)
            if p.is_dir():pending.append(p)
            elif p.is_file() and p.suffix.lower() in (".dll",".exe"):actual.add(p.relative_to(root).as_posix().casefold())
    need(actual==set(by_path),"PHP_UNDECLARED_BINARY")
    exe_rel=relative(manifest["executable"]);need(exe_rel.casefold() in by_path,"PHP_EXE_MISSING")
    exe=by_path[exe_rel.casefold()]
    need(exe[1].name.lower()=="php.exe" and exe[0]["sha256"]==policy["reference_executable_sha256"],"PHP_EXE_IDENTITY")
    ext_dir=local(root/relative(manifest["extension_directory"]),root);need(ext_dir.is_dir(),"PHP_EXTENSION_DIRECTORY")
    modules=manifest.get("shared_modules",{});builtins=manifest.get("builtin_modules",[])
    need(isinstance(modules,dict) and isinstance(builtins,list) and all(isinstance(x,str) and x==x.lower() for x in builtins),"PHP_MODULE_DECLARATION")
    need(len(set(builtins))==len(builtins) and not set(builtins)&set(modules),"PHP_MODULE_DUPLICATE")
    need(set(policy["required_modules"])<=set(builtins)|set(modules),"PHP_REQUIRED_MODULE_MISSING")
    need(set(policy["required_shared_modules"])<=set(modules),"PHP_SHARED_MODULE_MISSING")
    ext_paths=[]
    for module,rel in sorted(modules.items()):
        need(module==module.lower() and re.fullmatch("[a-z0-9_]+",module),"PHP_MODULE_NAME")
        rel=relative(rel);need(rel.casefold() in by_path,"PHP_EXTENSION_UNDECLARED")
        item,p,info=by_path[rel.casefold()]
        need(p.parent==ext_dir and p.name.lower()=="php_"+module+".dll" and item.get("origin")=="TRUSTED_EXISTING_PHP_DISTRIBUTION","PHP_EXTENSION_LOCATION")
        ext_paths.append(str(p))
    for item,p,info in by_name.values():
        for name in info["imports"]:
            if name=="vcruntime140.dll":
                need(central is not None,"CENTRAL_RUNTIME_QUALIFICATION_REQUIRED");validate_snapshot(central);continue
            if os_import(name):continue
            need(name in by_name,"PHP_NATIVE_DEPENDENCY_MISSING")
            need(by_name[name][1].parent==exe[1].parent,"PHP_NATIVE_LOADER_LOCATION")
    return dict(state="STATIC_PRECONDITION_OK",live="LIVE_MODULE_LOAD_NOT_RUN",executable=str(exe[1]),extension_directory=str(ext_dir),extension_paths=ext_paths,expected_modules=sorted(set(builtins)|set(modules)),manifest=manifest,root=str(root))
def qualify_config(config,grant):
    """Always uses the tracked policy and new Owner authority; never returns runtime PASS."""
    return _qualify_config(config,grant,validate_authority)

def qualify_probe_config(config,grant):
    """Same private manifest/source checks, separate explicit DB-free authority."""
    if grant.get('task_blob')=='960a738505054ac97a8cb85df660bf4f0b6decc9':
        from current_native_task import qualify
        return qualify(config,grant)
    return _qualify_config(config,grant,validate_probe_authority)

def _qualify_config(config,grant,authority):
    task_root=authority(config,grant)
    need(grant["task_blob"] not in ZERO_TASKS,"CLOSED_TASK_RUNTIME_ZERO")
    policy=json.loads(POLICY.read_bytes())
    require_runtime_policy(policy)
    need(set(policy["closed_runtime_task_blobs"])==ZERO_TASKS,"PHP_CLOSED_TASK_POLICY_CHANGED")
    source=manifest_path=local(config["php_runtime_manifest"],task_root)
    raw=source.read_bytes();value=digest(raw)
    need(value==config.get("php_runtime_manifest_sha256")==grant.get("php_cli_manifest_sha256")==grant.get("php_api_manifest_sha256"),"PHP_CLI_API_CLOSURE_MISMATCH")
    manifest=json.loads(raw)
    need(manifest.get("source_binding")==config["source_binding"] and manifest.get("source_binding")==grant["source_binding"],"PHP_CANDIDATE_MISMATCH")
    for rel,expected in policy["source_documents"].items():
        p=local(Path(config["source_root"])/rel,task_root)
        need(digest(p.read_bytes())==expected,"PHP_COMPOSER_SOURCE_CHANGED")
    root=local(config["php_runtime_root"],task_root)
    need(root!=task_root and manifest.get("requirements_sha256")==digest(canonical(policy)),"PHP_POLICY_OR_ROOT_MISMATCH")
    result=validate_manifest(manifest,root,policy)
    need(local(config["php"],task_root)==Path(result["executable"]) and grant["php_sha256"]==policy["reference_executable_sha256"],"PHP_CONFIG_EXE_MISMATCH")
    need(local(config["php_extension_dir"],task_root)==Path(result["extension_directory"]),"PHP_CONFIG_EXTENSION_DIR")
    requirements=local(config["php_requirements"],task_root)
    need(json.loads(requirements.read_bytes())==policy and digest(requirements.read_bytes())==grant["php_requirements_file_sha256"],"PHP_REQUIREMENTS_COPY_CHANGED")
    for name in ("home","tmp","appdata","localappdata","empty-ini"):
        p=local(task_root/name,task_root);need(p.is_dir(),"PHP_PRIVATE_WRITE_DIRECTORY_MISSING")
    need(not any((task_root/"empty-ini").iterdir()),"PHP_INI_SCAN_DIRECTORY_NOT_EMPTY")
    result.update(manifest_sha256=value,requirements_file=str(requirements));return result
def launch_arguments(profile,task_root):
    # Absolute extensions and -n are identical for CLI, probe and cli-server.
    args=[profile["executable"],"-n","-d","extension_dir="+profile["extension_directory"],"-d","open_basedir="+str(task_root),"-d","enable_dl=0","-d","allow_url_fopen=0","-d","display_errors=stderr","-d","include_path="+str(Path(profile["executable"]).parent),"-d","auto_prepend_file=","-d","auto_append_file=","-d","user_ini.filename="]
    for p in profile["extension_paths"]:args+=["-d","extension="+p]
    return args
def private_environment(profile,task_root,systemroot):
    root=Path(task_root)
    env=dict(SystemRoot=systemroot,WINDIR=systemroot,HOME=str(root/"home"),USERPROFILE=str(root/"home"),TEMP=str(root/"tmp"),TMP=str(root/"tmp"),TMPDIR=str(root/"tmp"),APPDATA=str(root/"appdata"),LOCALAPPDATA=str(root/"localappdata"),APP_ENV="testing",PHP_INI_SCAN_DIR=str(root/"empty-ini"),PHPRC=str(root/"empty-ini"),PATH=str(Path(profile["executable"]).parent),ELITESYNC_PHP_RUNTIME_MANIFEST_SHA256=profile["manifest_sha256"])
    return env

def api_arguments(profile,task_root,router):
    router=local(router,task_root)
    return launch_arguments(profile,task_root)+["-S","127.0.0.1:43359",str(router)]
