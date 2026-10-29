"""Future Windows module-image qualification. No observation or Popen on import."""
import ctypes,json,os,time,uuid,subprocess
from pathlib import Path
from contracts import Gate,need,local,digest,canonical
from php_runtime import os_import
from os_images import image_map,readonly_fact,system_root_fact,validate_os_fact,norm

def validate_handshake(value,pid,nonce,manifest_sha256):
    need(type(pid) is int and pid>0 and value.get('pid')==pid and value.get('nonce')==nonce and value.get('manifest_sha256')==manifest_sha256,'PHP_HANDSHAKE_IDENTITY')
def validate_images(images,profile,system_directory):
    root=Path(profile["root"]);manifest=profile["manifest"]
    private={str(local(root/x["path"],root)).casefold():x["sha256"] for x in manifest["files"]}
    system=local(system_directory);seen=set()
    need(isinstance(images,list) and images,"PHP_NATIVE_IMAGE_MAP_MISSING")
    for image in images:
        raw=image['path']
        if norm(str(Path(raw).parent))==norm(str(system)):
            policy=manifest.get('windows_os_image_policy');need(isinstance(policy,dict),'OS_IMAGE_SOURCE_NOT_QUALIFIED')
            live_system=system_root_fact();need(norm(live_system['path'])==norm(str(system)),'OS_IMAGE_WRONG_SYSTEM_ROOT')
            fact=readonly_fact(raw);fact['from_loaded_module_api']=True
            validate_os_fact(fact,policy,live_system);p=Path(raw);actual=fact['sha256']
        else:
            try:p=local(raw)
            except Gate as error:
                if str(error)=='HARDLINK_REJECTED':raise Gate('HARDLINK_REJECTED_PRIVATE') from error
                raise
            actual=digest(p.read_bytes())
        key=str(p).casefold();need(key not in seen,"PHP_NATIVE_DUPLICATE_IMAGE");seen.add(key)
        need(actual==image["sha256"],"PHP_NATIVE_IMAGE_CHANGED")
        if key in private:need(actual==private[key],"PHP_NATIVE_PRIVATE_HASH")
        else:
            need(norm(str(p.parent))==norm(str(system)),"PHP_NATIVE_IMAGE_OUTSIDE_CLOSURE")
            need(manifest.get("windows_system_modules",{}).get(p.name.lower())==actual,"PHP_NATIVE_OS_HASH_NOT_QUALIFIED")
    required={str(Path(profile["executable"])).casefold(),*(str(Path(p)).casefold() for p in profile["extension_paths"])}
    need(required<=seen,"PHP_NATIVE_REQUIRED_IMAGE_NOT_LOADED")
    return dict(state="NATIVE_IMAGE_MAP_INPUT_MATCHED",images=images)
def captured_path_set(images):
    # image_map already applied OS-specific or strict-private qualification.
    return {norm(image['path']) for image in images}

def capture_images(pid,expected_pid=None,os_policy=None,source_handle=None):
    need(expected_pid==pid,'OS_OBSERVER_UNKNOWN_PROCESS')
    return image_map(pid,expected_pid,os_policy,source_handle)

def native_paths(root,nonce,kind="driver"):
    need(kind in ("driver","api"),"PHP_RAW_NAMESPACE")
    raw=local(root/"raw"/kind,root);need(raw.is_dir(),"PHP_NATIVE_RECEIPT_DIRECTORY")
    return raw/("php-"+nonce+".ready.json"),raw/("php-"+nonce+".images.json")
def write_receipt(path,data):
    with path.open("xb") as f:f.write(canonical(data));f.flush();os.fsync(f.fileno())
def environment(profile,root,base,kind="driver"):
    env=dict(base);nonce=uuid.uuid4().hex;ready,receipt=native_paths(root,nonce,kind)
    env.update(ELITESYNC_PHP_START_NONCE=nonce,ELITESYNC_PHP_NATIVE_READY=str(ready),ELITESYNC_PHP_NATIVE_RECEIPT=str(receipt))
    return env,nonce,ready,receipt
def cli(profile,command,data,env,root,timeout=30):
    need(os.name=="nt","WINDOWS_NATIVE_RUNTIME_REQUIRED")
    env,nonce,ready,receipt=environment(profile,root,env)
    process=None;started=time.monotonic()
    try:
        process=subprocess.Popen(command,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,cwd=Path(profile["executable"]).parent,env=env,shell=False,creationflags=0x08000000)
        process.stdin.write(data);process.stdin.close();process.stdin=None
        deadline=time.monotonic()+min(timeout,10)
        while not ready.exists():
            need(process.poll() is None,"PHP_EXIT_BEFORE_CAPABILITY_HANDSHAKE");need(time.monotonic()<deadline,"PHP_HANDSHAKE_TIMEOUT");time.sleep(.02)
        value=json.loads(ready.read_bytes());validate_handshake(value,process.pid,nonce,profile['manifest_sha256'])
        images,system=capture_images(process.pid,process.pid,profile['manifest'].get('windows_os_image_policy'),int(process._handle));validate_images(images,profile,system)
        write_receipt(receipt,dict(pid=process.pid,nonce=nonce,manifest_sha256=profile["manifest_sha256"],system_directory=system,images=images))
        out,err=process.communicate(timeout=max(1,timeout-(time.monotonic()-started)))
        return subprocess.CompletedProcess(command,process.returncode,out,err)
    finally:
        if process is not None and process.poll() is None:process.kill();process.wait()
def api(profile,command,env,root,ledger):
    """Explicit future launch only; caller owns the <=2 server budget and final wait/stop."""
    need(os.name=="nt","WINDOWS_NATIVE_RUNTIME_REQUIRED")
    env,nonce,ready,receipt=environment(profile,root,env,"api")
    failure=root/"raw/api"/("php-"+nonce+".failure.json");env["ELITESYNC_PHP_FAILURE_RECEIPT"]=str(failure)
    out=root/"raw/api"/("api-"+nonce+".stdout");err=root/"raw/api"/("api-"+nonce+".stderr")
    with out.open("xb") as a,err.open("xb") as b:
        process=subprocess.Popen(command,stdin=subprocess.DEVNULL,stdout=a,stderr=b,cwd=Path(profile["executable"]).parent,env=env,shell=False,creationflags=0x08000000)
    try:
        deadline=time.monotonic()+10
        while True:
            need(process.poll() is None,"API_EXIT_BEFORE_MODULE_LOAD")
            images,system=capture_images(process.pid,process.pid,profile['manifest'].get('windows_os_image_policy'),int(process._handle))
            loaded=captured_path_set(images)
            required={norm(profile['executable']),*(norm(p) for p in profile['extension_paths'])}
            if required<=loaded:break
            need(time.monotonic()<deadline,"API_MODULE_LOAD_TIMEOUT");time.sleep(.02)
        validate_images(images,profile,system)
        write_receipt(receipt,dict(pid=process.pid,nonce=nonce,manifest_sha256=profile["manifest_sha256"],system_directory=system,images=images))
        process.qualification_failure_file=failure
        ledger("API_STARTED",pid=process.pid,nonce=nonce)
        return process
    except BaseException:
        if process.poll() is None:process.kill();process.wait()
        raise
