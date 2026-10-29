"""Future Windows module-image qualification. No observation or Popen on import."""
import ctypes,json,os,time,uuid,subprocess
from pathlib import Path
from contracts import Gate,need,local,digest,canonical
from php_runtime import os_import
def validate_images(images,profile,system_directory):
    root=Path(profile["root"]);manifest=profile["manifest"]
    private={str(local(root/x["path"],root)).casefold():x["sha256"] for x in manifest["files"]}
    system=local(system_directory);seen=set()
    need(isinstance(images,list) and images,"PHP_NATIVE_IMAGE_MAP_MISSING")
    for image in images:
        p=local(image["path"]);key=str(p).casefold();need(key not in seen,"PHP_NATIVE_DUPLICATE_IMAGE");seen.add(key)
        actual=digest(p.read_bytes());need(actual==image["sha256"],"PHP_NATIVE_IMAGE_CHANGED")
        if key in private:need(actual==private[key],"PHP_NATIVE_PRIVATE_HASH")
        else:
            need(p.parent==system and os_import(p.name.lower()),"PHP_NATIVE_IMAGE_OUTSIDE_CLOSURE")
            need(manifest.get("windows_system_modules",{}).get(p.name.lower())==actual,"PHP_NATIVE_OS_HASH_NOT_QUALIFIED")
    required={str(Path(profile["executable"])).casefold(),*(str(Path(p)).casefold() for p in profile["extension_paths"])}
    need(required<=seen,"PHP_NATIVE_REQUIRED_IMAGE_NOT_LOADED")
    return dict(state="NATIVE_IMAGE_MAP_INPUT_MATCHED",images=images)
def capture_images(pid):
    need(os.name=="nt","WINDOWS_NATIVE_OBSERVATION_REQUIRED")
    from ctypes import wintypes
    k=ctypes.WinDLL("kernel32",use_last_error=True);p=ctypes.WinDLL("psapi",use_last_error=True)
    k.OpenProcess.argtypes=[wintypes.DWORD,wintypes.BOOL,wintypes.DWORD];k.OpenProcess.restype=wintypes.HANDLE;k.CloseHandle.argtypes=[wintypes.HANDLE]
    p.EnumProcessModulesEx.argtypes=[wintypes.HANDLE,ctypes.POINTER(ctypes.c_void_p),wintypes.DWORD,ctypes.POINTER(wintypes.DWORD),wintypes.DWORD]
    p.GetModuleFileNameExW.argtypes=[wintypes.HANDLE,ctypes.c_void_p,wintypes.LPWSTR,wintypes.DWORD]
    k.GetSystemDirectoryW.argtypes=[wintypes.LPWSTR,wintypes.UINT]
    handle=k.OpenProcess(0x410,False,pid);need(bool(handle),"PHP_NATIVE_PROCESS_UNREADABLE")
    try:
        modules=(ctypes.c_void_p*2048)();needed=wintypes.DWORD()
        need(bool(p.EnumProcessModulesEx(handle,modules,ctypes.sizeof(modules),ctypes.byref(needed),3)) and needed.value<=ctypes.sizeof(modules),"PHP_NATIVE_ENUMERATION")
        rows=[]
        for module in modules[:needed.value//ctypes.sizeof(ctypes.c_void_p)]:
            text=ctypes.create_unicode_buffer(32768);need(p.GetModuleFileNameExW(handle,module,text,len(text))>0,"PHP_NATIVE_IMAGE_PATH")
            path=local(text.value);rows.append(dict(path=str(path),sha256=digest(path.read_bytes())))
        text=ctypes.create_unicode_buffer(32768);need(k.GetSystemDirectoryW(text,len(text))>0,"PHP_NATIVE_SYSTEM_DIRECTORY")
        return rows,str(local(text.value))
    finally:k.CloseHandle(handle)
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
        value=json.loads(ready.read_bytes());need(value.get("pid")==process.pid and value.get("nonce")==nonce and value.get("manifest_sha256")==profile["manifest_sha256"],"PHP_HANDSHAKE_IDENTITY")
        images,system=capture_images(process.pid);validate_images(images,profile,system)
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
            images,system=capture_images(process.pid)
            loaded={str(local(x["path"])).casefold() for x in images}
            required={str(Path(profile["executable"])).casefold(),*(str(Path(p)).casefold() for p in profile["extension_paths"])}
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
