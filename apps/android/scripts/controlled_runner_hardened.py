"""Source-review-only derivative of historical G runner. NOT runtime authorized.
No historical claims/budgets are renewed by this copy. No DLL loads on import.
"""
from pathlib import Path
import base64,hashlib,json,os,re,subprocess,sys,time
R=Path(__file__).parent
TASK='129efb748bb5a22921e756f2f829a627ceae6880'
DEFINES='ELITESYNC_V1015_LOCAL_BUILD=true,ELITESYNC_V1015_R1_LOCAL_BUILD=true'
class DiagnosticSink:
    """One bounded, hashed JSONL frame per failure; flush failure propagates."""
    def __init__(self, stream):
        self.stream = stream
    def __call__(self, event):
        required={'phase','sampleMonotonic','pid','parent','rootPid','rootCreationFiletime','snapshotSeen','imagePathQueried','creationFiletime','creationIdentityAvailable','apiFailureStage','apiError','failureReason'}
        if not required.issubset(event):
            raise OSError('DIAGNOSTIC_FIELDS_MISSING')
        payload = json.dumps(event, sort_keys=True, separators=(',', ':'))
        if len(payload.encode('utf-8')) > 16384:
            raise OSError('DIAGNOSTIC_EVENT_TOO_LARGE')
        row = dict(event, eventSha256=hashlib.sha256(payload.encode('utf-8')).hexdigest())
        line=json.dumps(row, sort_keys=True) + '\n'
        if self.stream.write(line) != len(line):
            raise OSError('DIAGNOSTIC_SHORT_WRITE')
        self.stream.flush()


def h(p):
    with Path(p).open('rb') as f:return hashlib.file_digest(f,'sha256').hexdigest()
def dump(p,x):
    with Path(p).open('x',encoding='utf-8') as f:json.dump(x,f,indent=2);f.flush();os.fsync(f.fileno())
def command(m,stage):
    assert stage in ['G','A']
    roots={k:Path(v) for k,v in m['roots'].items()};project=roots['project'];module=project/'apps/flutter_elitesync_module'
    digest=hashlib.sha256(DEFINES.encode())
    paths=[p for p in (module/'lib').rglob('*.dart') if p.is_file()]+[module/'pubspec.yaml',module/'pubspec.lock']+[p for p in (module/'third_party/livekit_client').rglob('*') if p.is_file()]
    for p in sorted(paths,key=lambda p:p.relative_to(module).as_posix()):digest.update(p.relative_to(module).as_posix().encode());digest.update(p.read_bytes())
    version='1.0-v1015r1-'+digest.hexdigest()[:12]
    cmd=[str(roots['gradle']/'bin/gradle.bat'),'-I='+str(project/'apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle'),'-I='+str(project/'apps/android/scripts/offline_debug.init.gradle'),'-Pflutter-root='+str(roots['flutter']),'-Poutput-dir='+str(module/'build/host/v1015-r1'),'-Pis-plugin=false','-PbuildNumber='+version,'-Ptarget=lib/main.dart','-Pdart-defines='+','.join(base64.b64encode(x.encode()).decode() for x in DEFINES.split(',')),'-Ptarget-platform=android-x64,android-arm64','assembleAarRelease','--offline','--console=plain','-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime','-PelitesyncOwnedAarProjectRoot='+str(project),'--no-daemon','--max-workers=2','--gradle-user-home',str(roots['cache']),'-Dorg.gradle.java.installations.auto-download=false','-Porg.gradle.java.installations.auto-download=false','-Porg.gradle.java.installations.auto-detect=false']
    return cmd+(['--dry-run'] if stage=='G' else []),version
def graph(log,plugins):
    selected=re.findall(r'(?m)^(:[^\s]+)\s+SKIPPED\s*$',log)
    docs=[t for t in selected if re.search(r'javadoc|dokka',t,re.I)]
    required={name:all(any(t.startswith(':'+name+':') and word.lower() in t.lower() for t in selected) for word in ['assembleAarRelease','bundleReleaseAar','generatePomFileForReleasePublication','generateMetadataFileForReleasePublication','sourcesJar','publishReleasePublicationToMavenRepository']) for name in ['flutter',*plugins]}
    complete=bool(selected) and all(required.values()) and 'BUILD SUCCESSFUL' in log
    return {'selectedTasks':selected,'documentationTasks':docs,'requiredPublicationCoverage':required,'complete':complete,'eligibleForA':complete and not docs,'status':'GRAPH_STILL_SELECTS_DOC_TASK' if docs else 'GRAPH_BOUNDED_SUPPORTED' if complete else 'GRAPH_NOT_PROVEN'}
def gate(stage,inventory_ok,g_result=None):
    if not inventory_ok:raise ValueError('INPUT_CLOSURE_NOT_PROVEN')
    if stage not in ['G','A']:raise ValueError('UNKNOWN_STAGE')
    if stage=='A' and not (g_result and g_result.get('exit')==0 and g_result.get('stopReason') is None and g_result.get('eligibleForA') is True):raise ValueError('G_GATE_CLOSED')
def command_hash(cmd):return hashlib.sha256(json.dumps(cmd,separators=(',',':')).encode()).hexdigest()
def verify_g_binding(g,marker,inventory_hash,runner_hash,cmd):
    expected={'taskBlob':TASK,'inventorySha256':inventory_hash,'runnerSha256':runner_hash,'commandSha256':command_hash(cmd)}
    if not all(g.get(k)==v for k,v in expected.items()):raise ValueError('G_RECEIPT_INPUT_IDENTITY_MISMATCH')
    if marker.get('taskBlob')!=TASK or marker.get('stage')!='G' or marker.get('reservedStarts')!=1 or marker.get('inventorySha256')!=inventory_hash:raise ValueError('G_CLAIM_IDENTITY_MISMATCH')
    if not g.get('networkSamples') or g.get('finalJobActiveProcesses')!=0:raise ValueError('G_OBSERVATION_OR_CLEANUP_INCOMPLETE')
def claim(stage,folder,inventory_hash):
    p=Path(folder)/(stage+'.claim.json')
    dump(p,{'taskBlob':TASK,'stage':stage,'reservedStarts':1,'inventorySha256':inventory_hash,'parentPid':os.getpid(),'oldApkBudgetRestored':False})
    return p
def launch_once(stage,folder,inventory_hash,approved,runtime,g_result=None):
    gate(stage,approved,g_result)
    marker=claim(stage,folder,inventory_hash)
    # Reservation survives every start/monitor failure; no retry path exists.
    try:return runtime.run(marker)
    except BaseException as e:
        runtime.abort()
        raise

class WindowsRuntime:
    def __init__(self,m,stage,cmd,*,diagnostic_sink=None):
        if not callable(diagnostic_sink):
            raise RuntimeError('DIAGNOSTIC_SINK_REQUIRED')
        self.diagnostic_sink=diagnostic_sink
        self.job=None
        try:
            self._initialize(m,stage,cmd)
        except BaseException:
            self.close_job()
            raise

    def _initialize(self,m,stage,cmd):
        # Instantiated only after isolated tests and inventory audit pass.
        import ctypes as c
        from ctypes import wintypes as w
        self.c=c;self.w=w;self.m=m;self.stage=stage;self.cmd=cmd;self.process=None;self.job=None;self.assigned=False
        sys.path.insert(0,str(Path(m['roots']['project'])/'apps/android/scripts'))
        from windows_build_observer import Observer
        from offline_debug import observation_stop_reason,policy_stop_reason
        self.observer=Observer(event_sink=self.diagnostic_sink);self.classify=observation_stop_reason;self.policy=policy_stop_reason
        self.observer.sample(os.getpid());self.observer.known.clear()
        k=c.WinDLL('kernel32',use_last_error=True);self.k=k
        k.CreateJobObjectW.argtypes=[c.c_void_p,w.LPCWSTR];k.CreateJobObjectW.restype=w.HANDLE
        k.AssignProcessToJobObject.argtypes=[w.HANDLE,w.HANDLE];k.AssignProcessToJobObject.restype=w.BOOL
        k.TerminateJobObject.argtypes=[w.HANDLE,w.UINT];k.TerminateJobObject.restype=w.BOOL
        k.QueryInformationJobObject.argtypes=[w.HANDLE,c.c_int,c.c_void_p,w.DWORD,c.c_void_p];k.QueryInformationJobObject.restype=w.BOOL
        k.SetInformationJobObject.argtypes=[w.HANDLE,c.c_int,c.c_void_p,w.DWORD];k.SetInformationJobObject.restype=w.BOOL
        k.CloseHandle.argtypes=[w.HANDLE];k.CloseHandle.restype=w.BOOL
        k.GetProcessTimes.argtypes=[w.HANDLE,*([c.POINTER(w.FILETIME)]*4)];k.GetProcessTimes.restype=w.BOOL
        self.job=k.CreateJobObjectW(None,None)
        if not self.job:raise OSError('JOB_CREATE_FAILED')
        class BasicLimit(c.Structure):
            _fields_=[('processTime',c.c_longlong),('jobTime',c.c_longlong),('flags',w.DWORD),('minWs',c.c_size_t),('maxWs',c.c_size_t),('activeLimit',w.DWORD),('affinity',c.c_size_t),('priority',w.DWORD),('scheduling',w.DWORD)]
        class Io(c.Structure):_fields_=[(n,c.c_ulonglong) for n in ['readOps','writeOps','otherOps','readBytes','writeBytes','otherBytes']]
        class Limits(c.Structure):_fields_=[('basic',BasicLimit),('io',Io),('processMemory',c.c_size_t),('jobMemory',c.c_size_t),('peakProcess',c.c_size_t),('peakJob',c.c_size_t)]
        limits=Limits();limits.basic.flags=0x2000  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE.
        if not k.SetInformationJobObject(self.job,9,c.byref(limits),c.sizeof(limits)):
            k.CloseHandle(self.job);self.job=None;raise OSError('JOB_KILL_ON_CLOSE_CONFIGURATION_FAILED')
        self.allowed={os.path.normcase(str(Path(x['sourcePath']).resolve())):x['sha256'] for x in m['inventory'] if x['sourcePath'] and x['root'] in ['java','android'] and x['path'].lower().endswith('.exe')}
        for x in m['inventory']:
            if x['path'].lower().endswith('.exe'):self.allowed[os.path.normcase(str((Path(m['roots'][x['root']])/x['path']).resolve()))]=x['sha256']
        for x in json.loads((R/'host-tools-v2-private.json').read_bytes()):self.allowed[os.path.normcase(x['path'])]=x['sha256']
    def check_tools(self, processes):
        for process in processes:
            path=process.get('imagePath')
            canonical=os.path.normcase(str(Path(path).resolve())) if path else None
            if not canonical or canonical not in self.allowed or h(canonical)!=self.allowed[canonical]:
                self.observer._fail(dict(phase='TOOL_IDENTITY_FAILURE',sampleMonotonic=time.monotonic(),
                    pid=process['pid'],parent=process.get('parent'),rootPid=self.process.pid,
                    rootCreationFiletime=self.observer.root_identity,snapshotSeen=True,
                    imagePathQueried=True,creationFiletime=process.get('creationFiletime'),
                    creationIdentityAvailable=bool(process.get('creationFiletime'))),
                    'UNKNOWN_OR_DRIFTED_EXTERNAL_TOOL')

    def close_job(self):
        if self.job is not None:
            handle = self.job
            if not self.k.CloseHandle(handle):
                raise OSError('JOB_CLOSE_FAILED')
            self.job = None

    def identity(self):
        c=self.c;w=self.w;ts=[w.FILETIME() for _ in range(4)]
        if not self.k.GetProcessTimes(int(self.process._handle),*[c.byref(x) for x in ts]):
            error=self.observer._error()
            self.observer._fail(dict(phase='ROOT_IDENTITY_FAILURE',sampleMonotonic=time.monotonic(),pid=self.process.pid,parent=os.getpid(),rootPid=self.process.pid,rootCreationFiletime=None,snapshotSeen=False,imagePathQueried=False,creationFiletime=None,creationIdentityAvailable=False),'GetProcessTimes',error)
        return ts[0].dwHighDateTime<<32|ts[0].dwLowDateTime
    def active(self):
        # JOBOBJECT_BASIC_ACCOUNTING_INFORMATION, ActiveProcesses at offset 40.
        buf=self.c.create_string_buffer(48)
        if not self.k.QueryInformationJobObject(self.job,1,buf,48,None):raise OSError('JOB_ACCOUNTING_FAILED')
        return int.from_bytes(buf.raw[40:44],'little')
    def abort(self):
        stopped=bool(self.job and self.k.TerminateJobObject(self.job,90))
        if self.process and self.process.poll() is None and (not self.assigned or not stopped):self.process.kill()
    def wait_empty(self,seconds=10):
        deadline=time.monotonic()+seconds
        while self.active():
            if time.monotonic()>=deadline:raise TimeoutError('JOB_NOT_EMPTY_AFTER_STOP')
            time.sleep(.05)
        return 0
    def run(self,marker):
        try:
            return self._run_claimed(marker)
        finally:
            self.close_job()

    def _run_claimed(self,marker):
        roots={k:Path(v) for k,v in self.m['roots'].items()};work=Path(self.m['workRoot']);out=R/self.stage;out.mkdir()
        env=os.environ.copy()
        for key in list(env):
            if key.startswith(('ORG_GRADLE_PROJECT_','GIT_')) or key in ['JAVA_TOOL_OPTIONS','_JAVA_OPTIONS','JDK_JAVA_OPTIONS','JAVA_OPTS','GRADLE_OPTS','GRADLE_RO_DEP_CACHE','ANDROID_PREFS_ROOT','ANDROID_SDK_HOME','FLUTTER_TOOL_ARGS','FLUTTER_PREBUILT_ENGINE_VERSION','FLUTTER_REALM']:env.pop(key,None)
        env.update({'JAVA_HOME':str(roots['java']),'GRADLE_USER_HOME':str(roots['cache']),'FLUTTER_ROOT':str(roots['flutter']),'FLUTTER_HOME':str(roots['flutter']),'PUB_CACHE':str(roots['pub']),'ANDROID_HOME':str(roots['android']),'ANDROID_SDK_ROOT':str(roots['android']),'ANDROID_USER_HOME':str(work/'android-user'),'TEMP':str(work/'tmp'),'TMP':str(work/'tmp'),'FLUTTER_SUPPRESS_ANALYTICS':'true','DART_SUPPRESS_ANALYTICS':'true','CI':'true','GIT_OPTIONAL_LOCKS':'0','GIT_CONFIG_NOSYSTEM':'1','GIT_CONFIG_GLOBAL':str(work/'empty-gitconfig')})
        (work/'tmp').mkdir(exist_ok=True)
        assert (work/'empty-gitconfig').read_bytes()==b''
        log=lambda:(out/'stdout.txt').read_text(errors='replace')+'\n'+(out/'stderr.txt').read_text(errors='replace')
        reason=None;samples=0;start=time.monotonic();root_id=None
        dump(out/'invocation-private.json',{'command':self.cmd,'cwd':str(roots['project']/'apps/flutter_elitesync_module/.android'),'reservation':str(marker),'udpPolicy':'OBSERVE_ONLY_DESTINATION_UNKNOWN','taskBlob':TASK})
        with (out/'stdout.txt').open('xb') as stdout,(out/'stderr.txt').open('xb') as stderr,(out/'process-network-private.jsonl').open('x') as obs:
            self.observer.event_sink=DiagnosticSink(obs)
            try:
                self.process=subprocess.Popen(self.cmd,cwd=roots['project']/'apps/flutter_elitesync_module/.android',env=env,stdout=stdout,stderr=stderr,stdin=subprocess.DEVNULL,creationflags=subprocess.CREATE_NO_WINDOW|4)
                root_id=self.identity()
                if not self.k.AssignProcessToJobObject(self.job,int(self.process._handle)):raise OSError('JOB_ASSIGN_FAILED')
                self.assigned=True
                self.observer.root_job_associated=True
                self.observer.root_identity=root_id
                # Establish root-instance and observer baseline before resume.
                baseline_processes,baseline_sockets=self.observer.sample(self.process.pid)
                self.check_tools(baseline_processes)
                baseline_signal=self.classify(baseline_sockets,'')
                if self.policy(baseline_signal,single_attempt_authorized=True):raise OSError('SUSPENDED_ROOT_OBSERVATION_REJECTED')
                obs.write(json.dumps({'phase':'SUSPENDED_ROOT_BASELINE','rootCreationFiletime':root_id,'processes':baseline_processes,'sockets':baseline_sockets})+'\n');obs.flush()
                n=self.c.WinDLL('ntdll');n.NtResumeProcess.argtypes=[self.w.HANDLE];n.NtResumeProcess.restype=self.c.c_long
                if n.NtResumeProcess(int(self.process._handle))!=0:raise OSError('ROOT_RESUME_FAILED')
                while self.process.poll() is None:
                    if self.identity()!=root_id:raise OSError('ROOT_INSTANCE_CHANGED')
                    before=time.monotonic();processes,sockets=self.observer.sample(self.process.pid)
                    signal=self.classify(sockets,log());reason=self.policy(signal,single_attempt_authorized=True)
                    for x in self.m['definitions']:
                        if h(roots['project']/x['path'])!=x['sha256']:reason=reason or 'SOURCE_DEFINITION_DRIFT'
                    self.check_tools(processes)
                    if re.search(r'(?im)^\s*Running pub upgrade\b',log()):reason=reason or 'AUTOMATIC_PUB_UPGRADE_FALLBACK_OBSERVED'
                    obs.write(json.dumps({'hostMonotonic':before,'rootCreationFiletime':root_id,'processes':processes,'sockets':sockets,'signal':signal,'stopReason':reason})+'\n');obs.flush();samples+=1
                    if time.monotonic()-start>1200:reason=reason or 'TIMEOUT'
                    if reason:break
                    time.sleep(.1)
            except BaseException as e:reason=reason or 'OBSERVER_OR_LAUNCH_FAILURE:'+type(e).__name__+':'+str(e)
            finally:
                if reason:self.abort()
                if self.process:
                    try:code=self.process.wait(timeout=30)
                    except subprocess.TimeoutExpired:self.abort();code=self.process.wait(timeout=30);reason=reason or 'EXIT_TIMEOUT'
                else:code=None
                try:
                    if self.active():reason=reason or 'TASK_DESCENDANTS_STILL_ACTIVE';self.abort()
                    final_active=self.wait_empty()
                except Exception as e:reason=reason or 'JOB_TERMINAL_UNVERIFIED';final_active=None
        final_log=log()
        reason=reason or self.policy(self.classify([],final_log),single_attempt_authorized=True)
        if samples==0:reason=reason or 'NO_RUNTIME_NETWORK_SAMPLE'
        result={'stage':self.stage,'taskBlob':TASK,'inventorySha256':h(R/'trusted-input-inventory-v2-private.json'),'runnerSha256':h(Path(__file__)),'commandSha256':command_hash(self.cmd),'claimSha256':h(marker),'reservedStarts':1,'popenCreated':self.process is not None,'exit':code,'stopReason':reason,'networkSamples':samples,'elapsedSeconds':time.monotonic()-start,'rootCreationFiletime':root_id,'finalJobActiveProcesses':final_active,'stdoutSha256':h(out/'stdout.txt'),'stderrSha256':h(out/'stderr.txt'),'observationsSha256':h(out/'process-network-private.jsonl'),'monitorLimitations':'Sampled non-atomic process/socket tables; creation-time changes stop; initial sampled ancestry is not proof of initial ownership; root retained handle and JobObject isolate termination, no packet/payload proof; active descendants after root exit trigger stop and bounded Job cleanup'}
        if self.stage=='G':
            plugins=json.loads((roots['project']/'apps/flutter_elitesync_module/.flutter-plugins-dependencies').read_bytes())['plugins']['android']
            result.update(graph(final_log,[x['name'] for x in plugins if x.get('native_build')]))
            result['eligibleForA']=bool(result['eligibleForA'] and code==0 and reason is None and final_active==0)
        dump(R/(self.stage+'.result.json'),result)
        print(json.dumps(result));return result

def main(stage):
    raise RuntimeError('NO_RUNTIME_AUTHORIZATION')


def _historical_main_reference_only(stage):
    raise RuntimeError('NO_RUNTIME_AUTHORIZATION')
    m=json.loads((R/'trusted-input-inventory-v2-private.json').read_bytes());audit=json.loads((R/'independent-inventory-audit-v2.json').read_bytes())
    ih=h(R/'trusted-input-inventory-v2-private.json');assert audit['status']=='VERIFIED' and audit['inventorySha256']==ih
    tested=json.loads((R/'runner-isolation-v2.json').read_bytes())
    assert tested['exit']==0 and tested['runnerSha256']==h(Path(__file__))
    assert m['verificationAuthorization']['taskBlob']==TASK
    assert h(Path(m['workRoot'])/'empty-gitconfig')==hashlib.sha256(b'').hexdigest()
    for x in m['auxiliaryInputs']:assert h(x['path'])==x['sha256'],'AUXILIARY_INPUT_DRIFT'
    for x in m['hostTools']:assert h(x['path'])==x['sha256'],'HOST_TOOL_DRIFT'
    # Immutable input drift is a gate failure. No new snapshot can erase it.
    for x in m['inventory']:assert h(Path(m['roots'][x['root']])/x['path'])==x['sha256'],'INPUT_DRIFT'
    g=json.loads((R/'G.result.json').read_bytes()) if stage=='A' else None
    gate(stage,True,g)
    if stage=='A':
        verify_g_binding(g,json.loads((R/'G.claim.json').read_bytes()),ih,h(Path(__file__)),command(m,'G')[0])
        assert g['claimSha256']==h(R/'G.claim.json')
    cmd,version=command(m,stage);dump(R/(stage+'.command-private.json'),{'command':cmd,'version':version,'sourceKotlinSha256':h(Path(m['roots']['project'])/'apps/android/app/build.gradle.kts')})
    rt=WindowsRuntime(m,stage,cmd)
    result=launch_once(stage,R,ih,True,rt,g)
    return 0 if result['exit']==0 and result['stopReason'] is None else 90
if __name__=='__main__':raise SystemExit(main(sys.argv[1]))
