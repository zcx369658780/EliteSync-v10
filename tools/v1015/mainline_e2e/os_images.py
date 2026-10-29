"""Read-only, pinned Windows OS images. Never used for private files or writes."""
import ctypes,hashlib,os,re,stat,ntpath
from pathlib import Path
from contracts import need,local

def norm(path):
    need(isinstance(path,str) and re.fullmatch(r'[A-Za-z]:[\\/].+',path) is not None,'OS_IMAGE_ABSOLUTE_DRIVE_PATH')
    need(not any(p in ('.','..') or p.endswith((' ','.')) for p in path.replace('\\','/').split('/')[1:]),'OS_IMAGE_ALIAS_REJECTED')
    return path.replace('\\','/').rstrip('/').casefold()

def validate_os_fact(fact,policy,system):
    """Pure validation of evidence; synthetic PASS is never live qualification."""
    need(policy.get('schema')==1 and policy.get('purpose')=='READONLY_LOADED_WINDOWS_OS_IMAGES','OS_IMAGE_SOURCE_NOT_QUALIFIED')
    root=system['path'];need(norm(policy['system_root']['path'])==norm(root),'OS_IMAGE_WRONG_SYSTEM_ROOT')
    need(policy['system_root']['file_id']==system['file_id'] and policy['system_root']['volume']==system['volume'],'OS_IMAGE_ROOT_IDENTITY')
    need(system.get('from_system_directory_api') is True and not system.get('reparse'),'OS_IMAGE_ROOT_NOT_SYSTEM_API')
    path=norm(fact['path']);need(norm(ntpath.dirname(fact['path']))==norm(root),'OS_IMAGE_OUTSIDE_SYSTEM32')
    need(fact.get('from_loaded_module_api') is True and fact.get('readonly_handle') is True,'OS_IMAGE_NOT_LOADED_READONLY')
    need(not fact.get('reparse') and norm(fact['canonical_path'])==path,'OS_IMAGE_ALIAS_OR_REPARSE')
    name=ntpath.basename(fact['path']).lower();pin=policy.get('images',{}).get(name)
    need(isinstance(pin,dict) and norm(pin['path'])==path,'OS_IMAGE_UNEXPECTED_MODULE')
    need(pin.get('signature_status')=='Valid' and pin.get('windows_publisher_verified') is True and bool(pin.get('signer_thumbprint')),'OS_IMAGE_SIGNATURE_NOT_QUALIFIED')
    need(pin.get('source_class')=='WINDOWS_SYSTEM_IMAGE','OS_IMAGE_SOURCE_NOT_QUALIFIED')
    for key in ('sha256','file_id','volume','links','bytes'):
        need(fact.get(key)==pin.get(key),'OS_IMAGE_IDENTITY_OR_HASH_CHANGED')
    need(all(type(fact.get(k)) is int and fact[k]>0 for k in ('links','file_id','volume','bytes')) and fact['volume']==system['volume'],'OS_IMAGE_LINK_OR_VOLUME')
    need(re.fullmatch('[0-9a-f]{64}',fact['sha256']) is not None,'OS_IMAGE_HASH_FORMAT')
    return {'state':'QUALIFIED_READONLY_OS_IMAGE','path':fact['path'],'sha256':fact['sha256']}

def _api():
    need(os.name=='nt','WINDOWS_READONLY_IMAGE_REQUIRED')
    from ctypes import wintypes as w
    k=ctypes.WinDLL('kernel32',use_last_error=True)
    class Info(ctypes.Structure):
        _fields_=[('attributes',w.DWORD),('creation',w.FILETIME),('access',w.FILETIME),('write',w.FILETIME),('volume',w.DWORD),('sizeHigh',w.DWORD),('sizeLow',w.DWORD),('links',w.DWORD),('indexHigh',w.DWORD),('indexLow',w.DWORD)]
    k.CreateFileW.argtypes=[w.LPCWSTR,w.DWORD,w.DWORD,ctypes.c_void_p,w.DWORD,w.DWORD,w.HANDLE];k.CreateFileW.restype=w.HANDLE
    k.GetFileInformationByHandle.argtypes=[w.HANDLE,ctypes.POINTER(Info)]
    k.GetFinalPathNameByHandleW.argtypes=[w.HANDLE,w.LPWSTR,w.DWORD,w.DWORD]
    k.ReadFile.argtypes=[w.HANDLE,ctypes.c_void_p,w.DWORD,ctypes.POINTER(w.DWORD),ctypes.c_void_p]
    k.CloseHandle.argtypes=[w.HANDLE]
    k.GetSystemDirectoryW.argtypes=[w.LPWSTR,w.UINT]
    return k,Info,w

def readonly_fact(path,directory=False):
    """Hash from one non-writable, non-write-sharing handle; recheck identity."""
    path=str(path);norm(path)
    for p in (Path(path),*Path(path).parents):
        st=p.lstat();need(not stat.S_ISLNK(st.st_mode) and not getattr(st,'st_file_attributes',0)&0x400,'OS_IMAGE_REPARSE')
    k,Info,w=_api();handle=k.CreateFileW(path,0x80 if directory else 0x80000000,1,None,3,0x00200000|(0x02000000 if directory else 0),None)
    need(handle!=ctypes.c_void_p(-1).value,'OS_IMAGE_READONLY_OPEN')
    def info():
        v=Info();need(k.GetFileInformationByHandle(handle,ctypes.byref(v)),'OS_IMAGE_HANDLE_IDENTITY')
        return dict(file_id=(int(v.indexHigh)<<32)|int(v.indexLow),volume=int(v.volume),bytes=(int(v.sizeHigh)<<32)|int(v.sizeLow),links=int(v.links),reparse=bool(v.attributes&0x400))
    try:
        before=info();text=ctypes.create_unicode_buffer(32768);n=k.GetFinalPathNameByHandleW(handle,text,len(text),0)
        need(0<n<len(text),'OS_IMAGE_CANONICAL_PATH');canonical=text.value
        need(canonical.startswith('\\\\?\\') and not canonical.startswith('\\\\?\\UNC\\'),'OS_IMAGE_CANONICAL_DRIVE')
        canonical=canonical[4:];need(norm(canonical)==norm(path),'OS_IMAGE_ALIAS_REJECTED')
        result=dict(path=path,canonical_path=canonical,readonly_handle=True,**before)
        if not directory:
            digest=hashlib.sha256();buf=ctypes.create_string_buffer(1048576);count=w.DWORD()
            while True:
                need(k.ReadFile(handle,buf,len(buf),ctypes.byref(count),None),'OS_IMAGE_HANDLE_READ')
                if not count.value:break
                digest.update(buf.raw[:count.value])
            result['sha256']=digest.hexdigest()
        need(before==info(),'OS_IMAGE_CHANGED_DURING_READ')
        return result
    finally:k.CloseHandle(handle)

def system_root_fact():
    k,_,_=_api();text=ctypes.create_unicode_buffer(32768);need(0<k.GetSystemDirectoryW(text,len(text))<len(text),'OS_SYSTEM_DIRECTORY_API')
    result=readonly_fact(text.value,directory=True);result['from_system_directory_api']=True;return result

def validate_process_identity(actual,expected):
    need(actual.get('pid')==expected.get('pid') and actual.get('creation')==expected.get('creation') and actual.get('running') is True and expected.get('running') is True,'OS_OBSERVER_PROCESS_INSTANCE_CHANGED')

def observed_liveness(wait_result):
    need(wait_result in (0,258),'OS_OBSERVER_WAIT_FAILED')
    return wait_result==258

def process_identity(handle):
    k,_,w=_api();k.GetProcessId.argtypes=[w.HANDLE];k.GetProcessId.restype=w.DWORD
    k.GetProcessTimes.argtypes=[w.HANDLE,ctypes.POINTER(w.FILETIME),ctypes.POINTER(w.FILETIME),ctypes.POINTER(w.FILETIME),ctypes.POINTER(w.FILETIME)]
    k.GetExitCodeProcess.argtypes=[w.HANDLE,ctypes.POINTER(w.DWORD)]
    k.WaitForSingleObject.argtypes=[w.HANDLE,w.DWORD];k.WaitForSingleObject.restype=w.DWORD
    created,exited,kernel,user=w.FILETIME(),w.FILETIME(),w.FILETIME(),w.FILETIME();code=w.DWORD()
    pid=k.GetProcessId(handle);need(pid>0 and k.GetProcessTimes(handle,ctypes.byref(created),ctypes.byref(exited),ctypes.byref(kernel),ctypes.byref(user)) and k.GetExitCodeProcess(handle,ctypes.byref(code)),'OS_OBSERVER_SOURCE_HANDLE')
    return dict(pid=pid,creation=(int(created.dwHighDateTime)<<32)|int(created.dwLowDateTime),running=observed_liveness(k.WaitForSingleObject(handle,0)))

def loaded_module_paths(pid,expected_identity=None):
    """OS enumeration only. Callers must bind PID to self or their live PHP child."""
    from ctypes import wintypes as w
    k,_,_=_api();p=ctypes.WinDLL('psapi',use_last_error=True)
    k.OpenProcess.argtypes=[w.DWORD,w.BOOL,w.DWORD];k.OpenProcess.restype=w.HANDLE
    p.EnumProcessModulesEx.argtypes=[w.HANDLE,ctypes.POINTER(ctypes.c_void_p),w.DWORD,ctypes.POINTER(w.DWORD),w.DWORD]
    p.GetModuleFileNameExW.argtypes=[w.HANDLE,ctypes.c_void_p,w.LPWSTR,w.DWORD]
    handle=k.OpenProcess(0x100410,False,pid);need(bool(handle),'OS_OBSERVER_PROCESS_UNREADABLE')
    try:
        if expected_identity is not None:validate_process_identity(process_identity(handle),expected_identity)
        modules=(ctypes.c_void_p*2048)();size=w.DWORD()
        need(p.EnumProcessModulesEx(handle,modules,ctypes.sizeof(modules),ctypes.byref(size),3) and size.value<=ctypes.sizeof(modules),'OS_OBSERVER_ENUMERATION')
        paths=[]
        for module in modules[:size.value//ctypes.sizeof(ctypes.c_void_p)]:
            text=ctypes.create_unicode_buffer(32768);need(p.GetModuleFileNameExW(handle,module,text,len(text))>0,'OS_OBSERVER_MODULE_PATH');paths.append(text.value)
        if expected_identity is not None:validate_process_identity(process_identity(handle),expected_identity)
        return paths
    finally:k.CloseHandle(handle)

def image_map(pid,expected_pid,os_policy=None,source_handle=None):
    need(pid==expected_pid and isinstance(pid,int) and pid>0,'OS_OBSERVER_UNKNOWN_PROCESS')
    need(pid==os.getpid() or source_handle is not None,'OS_OBSERVER_SOURCE_HANDLE_REQUIRED')
    identity=process_identity(source_handle) if source_handle is not None else None
    if identity is not None:validate_process_identity(identity,dict(identity,pid=pid,running=True))
    system=system_root_fact();rows=[]
    for path in loaded_module_paths(pid,identity):
        if norm(ntpath.dirname(path))==norm(system['path']):
            fact=readonly_fact(path);fact['from_loaded_module_api']=True
            need(os_policy is not None,'OS_IMAGE_SOURCE_NOT_QUALIFIED')
            validate_os_fact(fact,os_policy,system);rows.append(dict(path=path,sha256=fact['sha256']))
        else:
            p=local(path) # All non-system/private rules remain strict.
            rows.append(dict(path=str(p),sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
    if identity is not None:validate_process_identity(process_identity(source_handle),identity)
    return rows,system['path']
