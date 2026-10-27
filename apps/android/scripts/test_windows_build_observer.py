"""Fully mocked tests. Audit forbids process/socket/DLL runtime."""
import sys
EVENTS=[]
def audit(name,args):
    if name in ('subprocess.Popen','socket.__new__','ctypes.dlopen'):
        EVENTS.append(name)
        raise AssertionError('REAL_RUNTIME_FORBIDDEN')
sys.addaudithook(audit)
import unittest
import windows_build_observer as o

class Value:
    def __init__(self,value=0):self.value=value;self.dwHighDateTime=0;self.dwLowDateTime=0
    def __len__(self):return 32768
class Native:
    @staticmethod
    def create_unicode_buffer(size):return Value('')
    @staticmethod
    def byref(value):
        class Ref:pass
        ref=Ref();ref._obj=value;return ref
class Types:
    DWORD=Value
    FILETIME=Value
class Kernel:
    def __init__(self,stage=None,path='tool.exe',creation=100):
        self.stage=stage;self.path=path;self.creation=creation;self.calls=[]
    def OpenProcess(self,*args):self.calls.append('open');return 0 if self.stage=='OpenProcess' else 1
    def QueryFullProcessImageNameW(self,h,f,b,s):
        self.calls.append('query');b.value=self.path;return self.stage!='QueryFullProcessImageNameW'
    def GetProcessTimes(self,h,created,*rest):
        self.calls.append('times');created._obj.dwLowDateTime=self.creation;return self.stage!='GetProcessTimes'
    def CloseHandle(self,h):self.calls.append('close')

class Tests(unittest.TestCase):
    def make(self,k,sink=None,error=5):
        def get_error():k.calls.append('error');return error
        return o.Observer(kernel=k,ip=object(),get_error=get_error,clock=lambda:7,event_sink=sink,native_api=Native,types_api=Types)
    def test_failures_capture_before_close_and_emit(self):
        for stage in ['OpenProcess','QueryFullProcessImageNameW','GetProcessTimes']:
            with self.subTest(stage=stage):
                k=Kernel(stage);events=[];obs=self.make(k,events.append)
                with self.assertRaisesRegex(OSError,'PROCESS_INSTANCE_PATH_UNREADABLE'):obs.process_identity(12,3,'child',1)
                self.assertEqual(k.calls[k.calls.index('error')-1],{'OpenProcess':'open','QueryFullProcessImageNameW':'query','GetProcessTimes':'times'}[stage])
                e=events[0];self.assertEqual(e['apiFailureStage'],stage);self.assertEqual(e['apiError'],5)
                self.assertEqual(e['pid'],12);self.assertEqual(e['parent'],3);self.assertEqual(e['rootPid'],1)
                self.assertTrue(e['snapshotSeen']);self.assertEqual(e['sampleMonotonic'],7)
                self.assertEqual(e['creationFiletime'],100 if stage=='QueryFullProcessImageNameW' else None)
                self.assertEqual(e['imagePathQueried'],stage!='OpenProcess')
    def test_empty_path(self):
        events=[];obs=self.make(Kernel(path=''),events.append)
        with self.assertRaises(OSError):obs.process_identity(1,0,'root',1)
        self.assertEqual(events[0]['apiFailureStage'],'IMAGE_PATH_EMPTY');self.assertIsNone(events[0]['apiError'])
    def test_direct_image_lookup_does_not_claim_a_snapshot(self):
        events=[];obs=self.make(Kernel('OpenProcess'),events.append)
        with self.assertRaises(OSError):obs.image_path(12)
        self.assertFalse(events[0]['snapshotSeen'])
    def test_unavailable_error(self):
        events=[];obs=self.make(Kernel('OpenProcess'),events.append);obs.get_error=lambda:(_ for _ in ()).throw(ValueError())
        with self.assertRaises(OSError):obs.process_identity(1,0,'root',1)
        self.assertEqual(events[0]['apiError'],'API_ERROR_UNKNOWN')
    def test_normal_path_and_pid_reuse(self):
        k=Kernel();events=[];obs=self.make(k,events.append)
        p=obs.process_identity(2,1,'child',1);self.assertEqual(p['creationFiletime'],100)
        k.creation=101
        with self.assertRaises(OSError):obs.process_identity(2,1,'child',1)
        self.assertEqual(events[-1]['apiFailureStage'],'PID_INSTANCE_CHANGED')
    def test_unknown_child_creation(self):
        events=[];obs=self.make(Kernel(creation=0),events.append)
        with self.assertRaises(OSError):obs.process_identity(2,1,'child',1)
        self.assertEqual(events[0]['apiFailureStage'],'CREATION_IDENTITY_UNKNOWN')
    def test_write_failure_stops(self):
        def broken(e):raise OSError('disk')
        obs=self.make(Kernel('OpenProcess'),broken)
        with self.assertRaisesRegex(OSError,'DIAGNOSTIC_WRITE_FAILED'):obs.process_identity(2,1,'child',1)
    def test_exit_race_is_failure(self):
        events=[];obs=self.make(Kernel('OpenProcess'),events.append,error=87)
        with self.assertRaises(OSError):obs.process_identity(2,1,'gone',1)
        self.assertEqual(events[0]['apiError'],87)
    def test_error_zero_is_unknown(self):
        events=[];obs=self.make(Kernel('OpenProcess'),events.append,error=0)
        with self.assertRaises(OSError):obs.process_identity(2,1,'child',1)
        self.assertEqual(events[0]['apiError'],'API_ERROR_UNKNOWN')
    def test_event_written_before_handle_close(self):
        k=Kernel('QueryFullProcessImageNameW')
        obs=self.make(k,lambda event:k.calls.append('event'))
        with self.assertRaises(OSError):obs.process_identity(2,1,'child',1)
        self.assertLess(k.calls.index('error'),k.calls.index('times'))
        self.assertLess(k.calls.index('event'),k.calls.index('close'))
    def test_sample_tuple_and_snapshot_failure(self):
        obs=self.make(Kernel());obs._snapshot_rows=lambda:[(1,0,'root'),(2,1,'child')]
        obs._socket_rows=lambda:[{'pid':2,'protocol':'UDP','remote':None,'state':None}]
        result=obs.sample(1)
        self.assertIsInstance(result,tuple);self.assertEqual(len(result),2)
        self.assertEqual(len(result[0]),2);self.assertIsNone(result[1][0]['remote'])
        events=[];obs.event_sink=events.append;obs._snapshot_rows=lambda:[]
        with self.assertRaises(OSError):obs.sample(1)
        self.assertFalse(events[0]['snapshotSeen'])
    def test_snapshot_exception_records_failure(self):
        obs=self.make(Kernel());events=[];obs.event_sink=events.append
        def failed():raise OSError('PROCESS_SNAPSHOT_FAILED')
        obs._snapshot_rows=failed
        with self.assertRaises(OSError):obs.sample(1)
        self.assertEqual(events[0]['apiFailureStage'],'PROCESS_SNAPSHOT_OR_ENUMERATION')
    def test_creation_failure_retains_bounded_image_evidence(self):
        import hashlib
        path='mock/'+'x'*20000+'.exe';events=[]
        obs=self.make(Kernel('GetProcessTimes',path=path),events.append)
        with self.assertRaises(OSError):obs.process_identity(2,1,'snapshot-tool.exe',1)
        e=events[0]
        self.assertEqual(e['snapshotImage'],'snapshot-tool.exe')
        self.assertEqual(e['imagePathPrefix'],path[:1024])
        self.assertEqual(e['imagePathLength'],len(path))
        self.assertEqual(e['imagePathSha256'],hashlib.sha256(path.encode('utf-8')).hexdigest())
        self.assertEqual(e['apiFailureStage'],'GetProcessTimes')
        import json
        self.assertLess(len(json.dumps(e).encode('utf-8')),16384)
    def test_query_error_saved_before_query_clock_and_close(self):
        k=Kernel('QueryFullProcessImageNameW');events=[];obs=self.make(k,events.append)
        times=iter([10,20,30]);obs.snapshot_monotonic=5
        def clock():k.calls.append('clock');return next(times)
        obs.clock=clock
        with self.assertRaises(OSError):obs.process_identity(2,1,'snapshot.exe',1)
        e=events[0];self.assertEqual(e['snapshotSampleMonotonic'],5)
        self.assertEqual(e['imageQueryStartedMonotonic'],20)
        self.assertEqual(e['imageQueryMonotonic'],30)
        self.assertEqual(e['apiError'],5)
        query=k.calls.index('query')
        self.assertEqual(k.calls[query+1:query+3],['error','clock'])
        self.assertLess(k.calls.index('error'),k.calls.index('close'))
    def test_no_runtime(self):self.assertEqual(EVENTS,[])
if __name__=='__main__':unittest.main(verbosity=2)
