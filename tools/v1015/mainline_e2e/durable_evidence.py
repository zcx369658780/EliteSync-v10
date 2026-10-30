"""Task-bound durable evidence storage. No injectable no-op persistence path."""
import ctypes,json,os,re,time
from pathlib import Path
from contracts import need,local,digest,canonical

TASK='8faa3733369f714fb331e43c1da56762c589aa6b'
PARENT='d33845e62f1aa5eb82e0a4bf443b0396f2eb8b1a'
TASK_ID='V1015_API_SET_RAW_FIRST_L12_E2E_20261030'
ROOT_NAME='v1015-api-set-raw-first-l12-20261030'


def tick():
    need(os.name=='nt','WINDOWS_REQUIRED')
    k=ctypes.WinDLL('kernel32',use_last_error=True);k.GetTickCount64.restype=ctypes.c_uint64
    return k.GetTickCount64()


def flush_directory(path):
    """Flush the actual task-owned directory handle; failure closes the gate."""
    if os.name!='nt':
        fd=os.open(path,os.O_RDONLY)
        try:os.fsync(fd)
        finally:os.close(fd)
        return
    k=ctypes.WinDLL('kernel32',use_last_error=True)
    k.CreateFileW.argtypes=[ctypes.c_wchar_p,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_void_p,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_void_p];k.CreateFileW.restype=ctypes.c_void_p
    k.FlushFileBuffers.argtypes=[ctypes.c_void_p];k.CloseHandle.argtypes=[ctypes.c_void_p]
    handle=k.CreateFileW(str(path),0x40000000,7,None,3,0x02200000,None)
    need(handle!=ctypes.c_void_p(-1).value,'RAW_DIRECTORY_FLUSH_OPEN')
    try:need(bool(k.FlushFileBuffers(handle)),'RAW_DIRECTORY_FLUSH_FAILED')
    finally:k.CloseHandle(handle)


class Journal:
    def __init__(self,root):
        self.root=local(root);need(self.root.name==ROOT_NAME,'RAW_TASK_ROOT')
        self.path=local(self.root/'execution_ledger.jsonl',self.root)
        first=self.rows()[0]
        need(first.get('task_id')==TASK_ID and first.get('task_blob')==TASK and first.get('sole_parent')==PARENT and first.get('attempt_id')=='attempt-0001','RAW_LEDGER_AUTHORITY')
        self.workspace=first['workspace'];self.check_workspace()
    def rows(self):
        raw=self.path.read_bytes();need(raw.endswith(b'\n'),'RAW_LEDGER_TORN_TAIL')
        return [json.loads(x) for x in raw.splitlines()]
    def check_workspace(self):
        root=local(self.root);st=root.stat()
        need(dict(file_id=st.st_ino,volume=st.st_dev)==self.workspace,'RAW_WORKSPACE_REPLACED')
    def event(self,action,**values):
        self.check_workspace();rows=self.rows()
        need(not any(x.get('action')=='TERMINAL_STOP' for x in rows),'RAW_TASK_STOPPED')
        now=tick();need(0<=now-rows[0]['tick_start']<7200000,'RAW_TASK_WINDOW')
        row=dict(seq=len(rows)+1,action=action,tick=now,**values)
        with self.path.open('ab') as f:f.write(canonical(row)+b'\n');f.flush();os.fsync(f.fileno())
    def reserve_observation(self):
        count=sum(x.get('action')=='PREPARE_SCHEMA_OBSERVATION' for x in self.rows())
        need(count<2,'SCHEMA_OBSERVATION_BUDGET')
        self.event('PREPARE_SCHEMA_OBSERVATION',number=count+1,limit=2,raw_before_parse=True)
        return count+1
    def bytes(self,relative,data):
        need(isinstance(data,bytes) and len(data)<=33554432,'RAW_BLOB_SIZE')
        need(re.fullmatch(r'raw/[a-zA-Z0-9_.-]+',relative) is not None,'RAW_NAMESPACE')
        path=local(self.root/relative,self.root);directory=local(path.parent,self.root)
        need(directory.is_dir(),'RAW_DIRECTORY_MISSING')
        before=directory.stat();self.event('PREPARE_RAW_EXCLUSIVE_WRITE',path=relative,bytes=len(data),sha256=digest(data))
        fd=os.open(path,os.O_WRONLY|os.O_CREAT|os.O_EXCL|getattr(os,'O_BINARY',0),0o600)
        try:
            with os.fdopen(fd,'wb') as f:f.write(data);f.flush();os.fsync(f.fileno())
        except BaseException:
            # Never delete/replace failed writes: preserve the first failure.
            raise
        flush_directory(directory)
        st=path.stat();after=directory.stat();self.check_workspace()
        need((before.st_ino,before.st_dev)==(after.st_ino,after.st_dev),'RAW_DIRECTORY_REPLACED')
        reread=local(path,self.root).read_bytes()
        need(len(reread)==len(data)==st.st_size and digest(reread)==digest(data) and st.st_nlink==1,'RAW_WRITE_READBACK_MISMATCH')
        receipt=dict(path=relative,sha256=digest(reread),bytes=st.st_size,file_id=st.st_ino,volume=st.st_dev,directory_id=after.st_ino,directory_volume=after.st_dev,file_fsync=True,directory_flush=True,exclusive_create=True,readback_verified=True)
        self.event('RAW_DURABLY_ARCHIVED',**receipt)
        return receipt
    def json(self,name,value):return self.bytes(name,canonical(value))
