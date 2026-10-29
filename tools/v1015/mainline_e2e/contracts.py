"""Pure contracts. Reference validation never grants execution authority."""
import hashlib, json, os, re
from pathlib import Path
from datetime import datetime, timezone

CURRENT_TASK = "1db7fc7eaadcea172cc52016904836bd71a0b90d"
DATABASE = "elitesync_v1015_mainline_e2e_20261029"
API = "http://127.0.0.1:43359/api/v1"
class Gate(Exception): pass
def need(value, reason):
    if not value: raise Gate(reason)
def digest(data): return hashlib.sha256(data).hexdigest()
def canonical(value): return json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
def local(path, root=None):
    value=os.fspath(path)
    need(isinstance(value,str) and not value.replace("\\","/").startswith("//"),"LOCAL_PATH_REQUIRED")
    p=Path(value)
    need(p.is_absolute() and ".." not in p.parts, "ABSOLUTE_PATH_REQUIRED")
    for q in (p,*p.parents):
        if q.exists():
            s=q.lstat()
            need(not q.is_symlink() and not getattr(s,"st_file_attributes",0)&0x400,"LINK_REJECTED")
            if q.is_file(): need(s.st_nlink==1,"HARDLINK_REJECTED")
    p=p.resolve()
    if root is not None: need(p.is_relative_to(root),"PATH_OUTSIDE_NEW_TASK")
    return p
def validate_authority(config, grant, now=None):
    now=now or datetime.now(timezone.utc)
    need(isinstance(grant,dict) and grant.get("owner_authorized") is True,"OWNER_NEW_RUNTIME_AUTHORIZATION_REQUIRED")
    need(re.fullmatch("[0-9a-f]{40}",grant.get("task_blob","")) and grant["task_blob"] != CURRENT_TASK,"CURRENT_TASK_RUNTIME_ZERO")
    need(grant.get("action")=="mainline_api_db_e2e" and grant.get("new_instance_qualified") is True,"SCOPE_OR_INSTANCE_NOT_QUALIFIED")
    need(datetime.fromisoformat(grant["not_before"])<=now<datetime.fromisoformat(grant["expires_at"]),"GRANT_EXPIRED")
    need(config["api"]==API and config["database"]==DATABASE and config["db_port"]==43349,"WRONG_ENDPOINT")
    root=local(config["task_root"]);need(root.is_dir(),"TASK_ROOT_MISSING")
    need(root.name.startswith("v1015-mainline-live-") and "20261029" in root.name,"NEW_RUNTIME_ROOT_REQUIRED")
    need(config.get("source_binding")==grant.get("source_binding"),"SOURCE_BINDING_MISMATCH")
    b=config["source_binding"]
    need(all(re.fullmatch("[0-9a-f]{40}",b.get(k,"")) for k in ("commit","apps_tree","services_tree")),"SOURCE_BINDING_REQUIRED")
    need(digest(canonical(config))==grant.get("config_sha256"),"CONFIG_CHANGED")
    need(1<=grant.get("http_operations",0)<=160 and 1<=grant.get("php_operations",0)<=48,"BUDGET_REQUIRED")
    need(0<config.get("max_bytes",0)<=8589934592 and config["max_bytes"]==grant.get("max_bytes"),"SPACE_BUDGET_REQUIRED")
    return root
def check_login(receipt, user_id, device_id):
    need(receipt["user_id"]==user_id and receipt["device_id"]==device_id,"LOGIN_IDENTITY")
    dates={k:datetime.fromisoformat(receipt[k].replace("Z","+00:00")) for k in ("login_at","server_now","online_expires_at","purge_at")}
    need(all(v.tzinfo is not None for v in dates.values()),"LOGIN_TIME_UNTRUSTED")
    need((dates["online_expires_at"]-dates["login_at"]).total_seconds()==15*86400,"LOGIN_15D_CONTRACT")
    need((dates["purge_at"]-dates["login_at"]).total_seconds()==30*86400,"LOGIN_30D_CONTRACT")
def check_counts(row, attachment_count):
    need(row["message_count"]==1 and row["attachment_count"]==attachment_count and row["notification_count"]==1,"PERSISTENCE_NOT_UNIQUE")
def check_projection(result):
    need(result["status"]=="TEST_ONLY" and result["provider_status"]=="REAL_PUSH_PROVIDER_PENDING","NOT_TEST_ONLY")
    p=result["payload"]
    need(set(p)=={"notification_id","title","body"} and p["title"]=="EliteSync" and p["body"]=="请打开应用查看当前有权通知。","EXTERNAL_DISCLOSURE")
def check_app_receipts(rows, binding, required, root):
    by_id={}
    if rows: need(re.fullmatch("[0-9a-f]{64}",binding.get("apk_sha256") or "") is not None,"APP_BUILD_IDENTITY_REQUIRED")
    for row in rows:
        need(row.get("source_binding")==binding,"APP_SOURCE_MISMATCH")
        need(row.get("origin")=="ACTUAL_APP_OBSERVATION","MOCK_IS_NOT_APP")
        need(row["scenario"] not in by_id,"DUPLICATE_APP_RECEIPT")
        artifact=local(row["artifact"],root)
        need(artifact.is_file() and digest(artifact.read_bytes())==row["artifact_sha256"],"APP_ARTIFACT_MISMATCH")
        by_id[row["scenario"]]=row
    return {k:by_id.get(k,{"status":"NOT_RUN_GATE_CLOSED"}) for k in required}

def measured_space(root):
    logical=allocated=0
    for p in root.rglob("*"):
        local(p,root)
        if not p.is_file():continue
        logical+=p.stat().st_size
        if os.name!="nt": allocated+=p.stat().st_blocks*512;continue
        import ctypes
        from ctypes import wintypes
        class Info(ctypes.Structure):
            _fields_=[("allocation",ctypes.c_int64),("eof",ctypes.c_int64),("links",wintypes.DWORD),("pending",ctypes.c_ubyte),("directory",ctypes.c_ubyte)]
        k=ctypes.WinDLL("kernel32",use_last_error=True)
        k.CreateFileW.argtypes=[wintypes.LPCWSTR,wintypes.DWORD,wintypes.DWORD,ctypes.c_void_p,wintypes.DWORD,wintypes.DWORD,ctypes.c_void_p];k.CreateFileW.restype=ctypes.c_void_p
        k.GetFileInformationByHandleEx.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p,wintypes.DWORD];k.CloseHandle.argtypes=[ctypes.c_void_p]
        h=k.CreateFileW(str(p),0x80,7,None,3,0,None);need(h!=ctypes.c_void_p(-1).value,"SPACE_IDENTITY")
        try:
            i=Info();need(bool(k.GetFileInformationByHandleEx(h,1,ctypes.byref(i),ctypes.sizeof(i))) and i.links==1,"SPACE_QUERY");allocated+=i.allocation
        finally:k.CloseHandle(h)
    return logical,allocated
