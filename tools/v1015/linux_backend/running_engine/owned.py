import os,json,time,hashlib,ctypes,subprocess,contextlib
from pathlib import Path
R=Path(__file__).resolve().parent
L=R/'execution_ledger.jsonl'
TASK_ID='V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030'
TASK_BLOB='a1cbc75afe406e3e05712c6c51fb63c86bad928d'
PARENT='debe4a11d19f25179efef1d90d04e346980c2867'
K=ctypes.WinDLL('kernel32',use_last_error=True)
K.CreateFileW.argtypes=[ctypes.c_wchar_p,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_void_p,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_void_p];K.CreateFileW.restype=ctypes.c_void_p
K.CloseHandle.argtypes=[ctypes.c_void_p]
def sha(b):return hashlib.sha256(b).hexdigest()
def blob(b):return hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest()
def need(v,m):
 if not v:raise RuntimeError(m)
def parse(b):
 need(b.endswith(b'\n'),'TORN_LEDGER');rs=[json.loads(x) for x in b.splitlines()]
 need([x['seq'] for x in rs]==list(range(1,len(rs)+1)),'LEDGER_SEQUENCE');return rs
def rows():return parse(L.read_bytes())
def locked():
 import msvcrt
 deadline=time.monotonic()+10
 while True:
  h=K.CreateFileW(str(L),0xC0000000,1,None,3,0,None)
  if h!=ctypes.c_void_p(-1).value:break
  need(time.monotonic()<deadline,'LEDGER_LOCK_TIMEOUT');time.sleep(.02)
 return os.fdopen(msvcrt.open_osfhandle(h,os.O_RDWR|os.O_BINARY),'r+b',buffering=0)
def checked(f,allow_expired=False,allow_stop_intent=False):
 f.seek(0);rs=parse(f.read());s=rs[0];st=R.stat();ls=os.fstat(f.fileno())
 need(s['task_id']==TASK_ID and s['task_blob']==TASK_BLOB and s['sole_parent']==PARENT and s['attempt']=='attempt-0001','TASK_BINDING')
 need([st.st_dev,st.st_ino]==s['root_identity'],'ROOT_IDENTITY')
 need([ls.st_dev,ls.st_ino]==s['ledger_identity'],'LEDGER_IDENTITY')
 need(not any(x['action']=='TERMINAL_STOP' for x in rs),'STOP_SEALED')
 if not allow_stop_intent:need(not (R/'STOP_REQUESTED').exists(),'STOP_REQUESTED')
 if not allow_expired:need(0<=time.monotonic_ns()-s['tick_start_ns']<s['limits']['seconds']*10**9,'TIME_BUDGET')
 return rs
def append(f,rs,action,**kw):
 v=dict(seq=len(rs)+1,utc=time.strftime('%Y-%m-%dT%H:%M:%SZ',time.gmtime()),tick_ns=time.monotonic_ns(),action=action,**kw)
 f.seek(0,2);f.write((json.dumps(v,ensure_ascii=True)+'\n').encode());f.flush();os.fsync(f.fileno());return v
def event(action,**kw):
 if action=='TERMINAL_STOP':
  # Persist intent before waiting, so the next block/request cannot start while
  # an existing network operation unwinds. Evidence already received stays saved.
  with locked() as f:
   rs=checked(f,allow_expired=True,allow_stop_intent=True)
   if not (R/'STOP_REQUESTED').exists():
    prepared=append(f,rs,'PREPARE_TERMINAL_STOP',**kw)
    with (R/'STOP_REQUESTED').open('xb') as marker:marker.write((str(prepared['seq'])+'\n').encode());marker.flush();os.fsync(marker.fileno())
  with activity(terminal=True):
   with locked() as f:return append(f,checked(f,allow_expired=True,allow_stop_intent=True),action,**kw)
 with locked() as f:return append(f,checked(f),action,**kw)
@contextlib.contextmanager
def activity(terminal=False):
 # The STOP writer and all supply I/O use this same native exclusive handle.
 deadline=time.monotonic()+90
 while True:
  if not terminal:need(not (R/'STOP_REQUESTED').exists(),'STOP_REQUESTED')
  h=K.CreateFileW(str(R/'supply-activity.lock'),0xC0000000,0,None,4,0,None)
  if h!=ctypes.c_void_p(-1).value:break
  need(time.monotonic()<deadline,'SUPPLY_ACTIVITY_BUSY');time.sleep(.02)
 try:
  if not terminal:need(not (R/'STOP_REQUESTED').exists(),'STOP_REQUESTED')
  yield
 finally:K.CloseHandle(h)
def cost(category,amount=1,**kw):
 with locked() as f:
  rs=checked(f);used=sum(x.get('amount',0) for x in rs if x['action']=='PREPARE_COST' and x.get('category')==category)
  need(used+amount<=rs[0]['limits'][category],'BUDGET_'+category)
  return append(f,rs,'PREPARE_COST',category=category,amount=amount,used_after=used+amount,**kw)
def body_prepare(max_bytes,request_id):
 with locked() as f:
  rs=checked(f);done={x['reservation']:x['actual'] for x in rs if x['action']=='SUPPLY_BODY_BYTES'}
  charged=sum(done.get(x['seq'],x['maximum']) for x in rs if x['action']=='PREPARE_BODY_READ')
  need(charged+max_bytes<=rs[0]['limits']['supply_bytes'],'SUPPLY_BYTES_BUDGET')
  return append(f,rs,'PREPARE_BODY_READ',maximum=max_bytes,request_id=request_id)['seq']
def body_commit(reservation,actual):
 with locked() as f:
  rs=checked(f);x=next(x for x in rs if x['seq']==reservation)
  need(x['action']=='PREPARE_BODY_READ' and 0<=actual<=x['maximum'],'BODY_RESERVATION')
  need(not any(y['action']=='SUPPLY_BODY_BYTES' and y['reservation']==reservation for y in rs),'BODY_ALREADY_COMMITTED')
  append(f,rs,'SUPPLY_BODY_BYTES',reservation=reservation,actual=actual)
def write(rel,b,replace=False):
 p=R/rel;need(p.resolve().is_relative_to(R),'OWNED_PATH')
 for q in [p,*p.parents]:
  if q==R.parent:break
  if q.exists():need(not q.lstat().st_file_attributes&0x400,'REPARSE')
 event('PREPARE_WRITE',path=rel,bytes=len(b),sha256=sha(b));p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('wb' if replace else 'xb') as f:f.write(b);f.flush();os.fsync(f.fileno())
def jwrite(rel,v,replace=False):write(rel,(json.dumps(v,ensure_ascii=True,indent=2)+'\n').encode(),replace)
def run(name,cmd,timeout=60,env=None,categories=()):
 for c in categories:cost(c,name=name)
 prepared=event('PREPARE_PROCESS',name=name,argv=cmd,timeout=timeout)
 log_name=name+'-'+str(prepared['seq'])
 try:
  p=subprocess.run(cmd,cwd=R,env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=timeout);out,err=p.stdout,p.stderr;rc=p.returncode
 except subprocess.TimeoutExpired as e:out,err=e.stdout or b'',e.stderr or b'';rc='TIMEOUT'
 write('logs/'+log_name+'.stdout',out);write('logs/'+log_name+'.stderr',err)
 result=dict(name=name,log_base=log_name,exit=rc,stdout_sha256=sha(out),stderr_sha256=sha(err));jwrite('logs/'+log_name+'.json',result);event('PROCESS_RESULT',**result);return result,out,err
def space():
 class Std(ctypes.Structure):_fields_=[('allocation',ctypes.c_longlong),('end',ctypes.c_longlong),('links',ctypes.c_uint32),('delete',ctypes.c_ubyte),('directory',ctypes.c_ubyte)]
 K.GetFileInformationByHandleEx.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p,ctypes.c_uint32]
 logical=allocated=0
 for p in R.rglob('*'):
  st=p.lstat();need(not st.st_file_attributes&0x400,'TASK_REPARSE')
  if not p.is_file():continue
  logical+=st.st_size;h=K.CreateFileW(str(p),0x80,7,None,3,0x00200000,None);need(h!=ctypes.c_void_p(-1).value,'ALLOC_OPEN')
  try:
   info=Std();need(K.GetFileInformationByHandleEx(h,1,ctypes.byref(info),ctypes.sizeof(info)),'ALLOC_QUERY');allocated+=info.allocation
  finally:K.CloseHandle(h)
 # Conservative additive budget for task-owned OCI image layers stored by the daemon.
 extra=R/'daemon-space.json'
 if extra.is_file():
  n=json.loads(extra.read_text())['upper_bound_bytes'];logical+=n;allocated+=n
 need(max(logical,allocated)<17179869184-67108864,'DISK_BUDGET');return dict(logical=logical,allocated=allocated,reserve=67108864)
