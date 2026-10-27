"""Safe-copy runner regression tests, fully mocked."""
import sys
EVENTS=[]
def audit(name,args):
    if name in ('subprocess.Popen','socket.__new__','ctypes.dlopen'):
        EVENTS.append(name);raise AssertionError('REAL_RUNTIME_FORBIDDEN')
sys.addaudithook(audit)
import unittest,tempfile,json,io
from pathlib import Path
from unittest.mock import Mock,patch
import controlled_runner_hardened as c
def event():
    return dict(phase='failure',sampleMonotonic=1,pid=1,parent=0,rootPid=1,
                rootCreationFiletime=None,snapshotSeen=True,imagePathQueried=False,
                creationFiletime=None,creationIdentityAvailable=False,
                apiFailureStage='OpenProcess',apiError=5,failureReason='PROCESS_INSTANCE_PATH_UNREADABLE')
class Tests(unittest.TestCase):
    def test_main_closed_before_reads(self):
        with patch.object(c,'h',side_effect=AssertionError('read')):
            with self.assertRaisesRegex(RuntimeError,'NO_RUNTIME_AUTHORIZATION'):c.main('G')
    def test_claim_no_retry(self):
        with tempfile.TemporaryDirectory() as d:
            rt=Mock();rt.run.side_effect=OSError('mock')
            with self.assertRaises(OSError):c.launch_once('G',d,'i',True,rt)
            self.assertTrue((Path(d)/'G.claim.json').is_file());rt.abort.assert_called_once()
            with self.assertRaises(FileExistsError):c.launch_once('G',d,'i',True,rt)
            self.assertEqual(rt.run.call_count,1)
    def test_diagnostic_sink_bounded_hash_flush(self):
        stream=io.StringIO();sink=c.DiagnosticSink(stream);sink(event())
        row=json.loads(stream.getvalue());self.assertEqual(len(row['eventSha256']),64)
        with self.assertRaisesRegex(OSError,'DIAGNOSTIC_EVENT_TOO_LARGE'):sink(dict(event(),x='x'*20000))
    def test_release_job_even_when_terminal_write_fails(self):
        rt=object.__new__(c.WindowsRuntime);rt.job=4;rt.k=Mock()
        rt.close_job();self.assertIsNone(rt.job);rt.k.CloseHandle.assert_called_once_with(4)
    def test_zero_samples_g_binding_rejected(self):
        g={'taskBlob':c.TASK,'inventorySha256':'i','runnerSha256':'r','commandSha256':c.command_hash([]),'networkSamples':0,'finalJobActiveProcesses':0}
        marker={'taskBlob':c.TASK,'stage':'G','reservedStarts':1,'inventorySha256':'i'}
        with self.assertRaises(ValueError):c.verify_g_binding(g,marker,'i','r',[])
    def test_a_without_g_closed(self):
        with self.assertRaises(ValueError):c.gate('A',True,None)
    def test_missing_fields_and_short_write_stop(self):
        with self.assertRaisesRegex(OSError,'DIAGNOSTIC_FIELDS_MISSING'):c.DiagnosticSink(io.StringIO())({})
        stream=Mock();stream.write.return_value=0
        with self.assertRaisesRegex(OSError,'DIAGNOSTIC_SHORT_WRITE'):c.DiagnosticSink(stream)(event())
    def test_flush_failure_stops(self):
        class Broken(io.StringIO):
            def flush(self):raise OSError('disk')
        with self.assertRaisesRegex(OSError,'disk'):c.DiagnosticSink(Broken())(event())
    def test_job_release_after_constructor_failure(self):
        def fail(rt,*args):
            rt.job=5;rt.k=Mock();raise OSError('setup')
        rt=object.__new__(c.WindowsRuntime)
        with patch.object(c.WindowsRuntime,'_initialize',fail):
            with self.assertRaises(OSError):rt.__init__({},'G',[],diagnostic_sink=Mock())
        rt.k.CloseHandle.assert_called_once_with(5)
    def test_job_release_after_run_exception(self):
        rt=object.__new__(c.WindowsRuntime);rt.job=4;rt.k=Mock();rt._run_claimed=Mock(side_effect=OSError('terminal write'))
        with self.assertRaises(OSError):rt.run('marker')
        rt.k.CloseHandle.assert_called_once_with(4);self.assertIsNone(rt.job)
    def test_job_cleanup_waits_zero_and_times_out(self):
        rt=object.__new__(c.WindowsRuntime);rt.active=Mock(side_effect=[2,1,0])
        with patch.object(c.time,'sleep'):
            self.assertEqual(rt.wait_empty(),0)
        rt.active=lambda:1
        with self.assertRaises(TimeoutError):rt.wait_empty(0)
    def test_abort_unassigned_root(self):
        rt=object.__new__(c.WindowsRuntime);rt.job=1;rt.k=Mock();rt.process=Mock();rt.process.poll.return_value=None;rt.assigned=False
        rt.abort();rt.process.kill.assert_called_once()
    def test_unknown_tool_strong_stop(self):
        rt=object.__new__(c.WindowsRuntime);rt.allowed={};rt.process=Mock(pid=1);rt.observer=Mock(root_identity=100)
        rt.observer._fail.side_effect=OSError('UNKNOWN_OR_DRIFTED_EXTERNAL_TOOL')
        with self.assertRaises(OSError):rt.check_tools([{'pid':2,'parent':1,'imagePath':'unknown.exe','creationFiletime':101}])
        rt.observer._fail.assert_called_once()
    def test_tcp_download_and_udp_semantics_retained(self):
        from offline_debug import observation_stop_reason,policy_stop_reason
        tcp=observation_stop_reason([{'protocol':'TCP','remote':'203.0.113.2'}],'')
        self.assertEqual(policy_stop_reason(tcp,single_attempt_authorized=True),'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED')
        download=observation_stop_reason([],'Downloading https://example.invalid/tool.zip')
        self.assertIsNotNone(policy_stop_reason(download,single_attempt_authorized=True))
        udp=observation_stop_reason([{'protocol':'UDP','remote':None}],'')
        self.assertIsNone(policy_stop_reason(udp,single_attempt_authorized=True))
    def test_complete_graph_and_binding(self):
        words=['assembleAarRelease','bundleReleaseAar','generatePomFileForReleasePublication','generateMetadataFileForReleasePublication','releaseSourcesJar','publishReleasePublicationToMavenRepository']
        log='\n'.join(':flutter:'+word+' SKIPPED' for word in words)+'\nBUILD SUCCESSFUL'
        self.assertTrue(c.graph(log,[])['eligibleForA'])
        self.assertFalse(c.graph(log+'\n:flutter:javadoc SKIPPED',[])['eligibleForA'])
        marker={'taskBlob':c.TASK,'stage':'G','reservedStarts':1,'inventorySha256':'i'}
        g={'taskBlob':c.TASK,'inventorySha256':'i','runnerSha256':'r','commandSha256':c.command_hash([]),'networkSamples':1,'finalJobActiveProcesses':0}
        c.verify_g_binding(g,marker,'i','r',[])
        for key in ['taskBlob','inventorySha256','runnerSha256','commandSha256']:
            with self.assertRaises(ValueError):c.verify_g_binding(dict(g,**{key:'drift'}),marker,'i','r',[])
    def test_missing_sink_rejected_before_initialize_or_native_import(self):
        with patch.object(c.WindowsRuntime,'_initialize',side_effect=AssertionError('native setup reached')):
            for missing in [None,object()]:
                with self.assertRaisesRegex(RuntimeError,'DIAGNOSTIC_SINK_REQUIRED'):
                    c.WindowsRuntime({},'G',[],diagnostic_sink=missing)
    def test_first_observer_sample_has_persistent_sink(self):
        import windows_build_observer as observer_module
        sink=Mock();fake_observer=Mock()
        def make_observer(**kwargs):
            def sample(pid):
                kwargs['event_sink'](event())
                raise OSError('first sample failure')
            fake_observer.sample.side_effect=sample
            return fake_observer
        with patch.dict(sys.modules,{'ctypes':Mock()}), patch.object(observer_module,'Observer',side_effect=make_observer) as constructor, patch.object(sys,'path',list(sys.path)):
            with self.assertRaisesRegex(OSError,'first sample failure'):
                c.WindowsRuntime({'roots':{'project':'.'}},'G',[],diagnostic_sink=sink)
        constructor.assert_called_once_with(event_sink=sink);sink.assert_called_once()
    def test_close_failure_preserves_handle_for_abort(self):
        rt=object.__new__(c.WindowsRuntime);rt.job=9;rt.k=Mock();rt.k.CloseHandle.return_value=False
        rt.process=Mock();rt.process.poll.return_value=None;rt.assigned=True
        with self.assertRaisesRegex(OSError,'JOB_CLOSE_FAILED'):rt.close_job()
        self.assertEqual(rt.job,9)
        rt.abort();rt.k.TerminateJobObject.assert_called_once_with(9,90)
    def test_close_failure_launch_abort_chain_no_retry(self):
        with tempfile.TemporaryDirectory() as d:
            rt=object.__new__(c.WindowsRuntime);rt.job=9;rt.k=Mock();rt.k.CloseHandle.return_value=False
            rt.process=Mock();rt.process.poll.return_value=0;rt.assigned=True
            rt._run_claimed=Mock(return_value={'exit':0})
            with self.assertRaisesRegex(OSError,'JOB_CLOSE_FAILED'):c.launch_once('G',d,'i',True,rt)
            rt.k.TerminateJobObject.assert_called_once_with(9,90)
            with self.assertRaises(FileExistsError):c.launch_once('G',d,'i',True,rt)
            rt._run_claimed.assert_called_once()
            rt.k.CloseHandle.assert_called_once_with(9)
    def test_command_binds_explicit_project_root(self):
        with tempfile.TemporaryDirectory() as d:
            base=Path(d);module=base/'project/apps/flutter_elitesync_module'
            (module/'lib').mkdir(parents=True);(module/'third_party/livekit_client').mkdir(parents=True)
            for name in ['pubspec.yaml','pubspec.lock','lib/main.dart']:(module/name).write_text('mock input')
            manifest={'roots':{name:str(base/name) for name in ['project','gradle','cache','flutter']}}
            for stage in ['G','A']:
                cmd,_=c.command(manifest,stage)
                self.assertEqual(cmd.count('-PelitesyncOwnedAarProjectRoot='+str(base/'project')),1)
    def test_no_runtime(self):self.assertEqual(EVENTS,[])
if __name__=='__main__':unittest.main(verbosity=2)
