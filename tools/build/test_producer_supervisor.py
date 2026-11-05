import hashlib
import json
import re
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import producer_supervisor as supervisor


class SupervisorTests(unittest.TestCase):
    def test_prepare_packages_guest_control_inputs_under_consumer_names(self):
        import cmake_vc_candidate as cmake
        with tempfile.TemporaryDirectory() as directory:
            task=Path(directory);inputs=task/'inputs';inputs.mkdir()
            flutter=task/'flutter';flutter.mkdir();project=task/'project';project.mkdir()
            tools36=task/'sdk/build-tools/36.0.0';tools36.mkdir(parents=True)
            tools35=tools36.parent/'35.0.0';tools35.mkdir()
            (tools35/'source.properties').write_text('Pkg.Revision=35.0.0\n')
            (tools35/'aapt2.exe').write_bytes(b'fixture-not-executable')
            for version in ('34','35'):
                platform=task/('sdk/platforms/android-'+version);platform.mkdir(parents=True)
                (platform/'android.jar').write_bytes(b'fixture-not-a-real-platform')
            inventory=inputs/'private-flutter-complete-inventory-private.json';inventory.write_text('{}')
            project_inventory=inputs/'private-project-inventory-private.json';project_inventory.write_text('{}')
            layout=dict(readonly_mappings={'android_cmake_3_22_1':dict(host=str(task),guest='C:/Inputs/CMake',readonly=True),
                                          'android_build_tools_36':dict(host=str(tools36),guest='C:/Inputs/AndroidSdk/build-tools/36.0.0',readonly=True)},
                        owned_flutter=dict(host=str(flutter)),owned_project=dict(host=str(project)))
            (inputs/'production-layout-private.json').write_text(json.dumps(layout))
            declared=inputs/'complete-declared-input-trees-private.json';declared.write_text('{"files":[]}')
            cmake_inventory=task/'cmake.json';cmake_inventory.write_text('{"inventory":{"files":[]}}')
            entry=task/'entry.json';entry.write_text('{}');root=task/'candidate'
            graph=task/'package_graph.json';graph_bytes=b'{"configVersion":1,"packages":[]}'
            graph.write_bytes(graph_bytes)
            original_sha=supervisor.sha
            def fixture_sha(path):
                return '0b34a527161803e5b783705c3fc07b7fcf5e1818b064b3e42bd5355ea0b14af9' if Path(path)==declared else original_sha(path)
            def compile_fixture(command,**kwargs):
                target=next(item[5:] for item in command if item.startswith('/out:'))
                Path(target).write_bytes(b'fixture-not-executable')
                return subprocess.CompletedProcess(command,0,b'',b'')
            with patch.object(supervisor,'PINS',dict(flutter=original_sha(inventory),project=original_sha(project_inventory))),\
                 patch.object(supervisor,'PROJECT_PACKAGE_GRAPH',graph),\
                 patch.object(supervisor,'PROJECT_PACKAGE_GRAPH_SHA256',original_sha(graph)),\
                 patch.object(supervisor,'sha',side_effect=fixture_sha),\
                 patch.object(supervisor,'bind_entry',return_value={'launch_request':{}}),\
                 patch.object(cmake,'verify_private_tree'),patch.object(cmake,'PRIVATE_CMAKE',task),\
                 patch.object(cmake,'MATERIALIZATION',cmake_inventory),\
                 patch.object(supervisor.subprocess,'run',side_effect=compile_fixture):
                contract=supervisor.prepare(root,inputs,entry)
                graph.write_bytes(b'changed')
                with self.assertRaisesRegex(ValueError,'package graph identity differs'):
                    supervisor.prepare(task/'changed-graph-candidate',inputs,entry)
                self.assertFalse((task/'changed-graph-candidate').exists())
            guest=(root/'probe/producer_supervisor.cs').read_text()
            consumed=re.findall(r'File\.Copy\(Probe\+@"\\([^"]+)"',guest)
            self.assertTrue(consumed,'Fixture must exercise actual guest file consumers')
            for name in consumed:
                self.assertTrue((root/'probe'/name).is_file(),name)
                self.assertEqual(contract['payload_sha256']['probe/'+name],original_sha(root/'probe'/name))
            self.assertEqual((root/'probe/producer-output.init.gradle').read_bytes(),(supervisor.HERE/'producer_output.init.gradle').read_bytes())
            self.assertEqual((root/'probe/project-package-graph.json').read_bytes(),graph_bytes)
            self.assertIn(dict(host=str(tools35),guest='C:/Inputs/AndroidSdk/build-tools/35.0.0',readonly=True),contract['readonly_mappings'])
            added=[row for row in contract['native_inputs'] if row['role']=='android_build_tools_35']
            self.assertEqual({row['relative_path'] for row in added},{'source.properties','aapt2.exe'})
            for version in ('34','35'):
                self.assertIn(dict(host=str(task/('sdk/platforms/android-'+version)),guest='C:/Inputs/AndroidSdk/platforms/android-'+version,readonly=True),contract['readonly_mappings'])
                self.assertEqual([row['relative_path'] for row in contract['native_inputs'] if row['role']=='android_platform_'+version],['android.jar'])
            self.assertTrue((root/'probe/supplemental-sdk-inventory.json').is_file())
            (tools35/'aapt2.exe').write_bytes(b'fixture-not-executablX')
            with self.assertRaisesRegex(ValueError,'Native input identity changed'):
                supervisor.preflight(root,contract)
            self.assertFalse((root/'launch.claim.json').exists())

    def case(self, root):
        (root/'probe').mkdir();(root/'output').mkdir()
        config=root/'qualification.wsb';config.write_text('frozen configuration')
        contract=dict(host_root=str(root.resolve()),nonce='fixture-nonce',guest_seconds=100,
            host_seconds=200,cleanup_seconds=45,output_bytes=1024**2,
            payload_sha256={'qualification.wsb':supervisor.sha(config)},host_helpers={})
        supervisor.put(root/'probe'/'run-contract.json',contract)
        supervisor.put(root/'probe'/'owner-grant.json',dict(authorized=True,max_attempts=1,
            contract_sha256=supervisor.sha(root/'probe'/'run-contract.json')))
        return contract

    def test_configuration_exposes_one_fresh_write_surface(self):
        tree=ET.fromstring(supervisor.configuration(Path('C:/candidate'),[
            dict(host='D:/prepared',guest='C:/Inputs/PreparedFlutter',readonly=True)],'nonce'))
        self.assertEqual(tree.findtext('Networking'),'Disable')
        folders=tree.findall('MappedFolders/MappedFolder')
        self.assertEqual([f.findtext('SandboxFolder') for f in folders if f.findtext('ReadOnly')=='false'],[r'C:\ProbeOutput'])
        self.assertNotIn(r'C:\BuildWork',[f.findtext('SandboxFolder') for f in folders])
        self.assertTrue(all('/' not in f.findtext(field) for f in folders for field in ('HostFolder','SandboxFolder')))

    def owned_pair(self):
        base=dict(CreationDate='2026-11-05T13:05:34.8202130Z',
                  ExecutablePath=r'C:\Apps\WindowsSandboxRemoteSession.exe',
                  CommandLine=r'"C:\Apps\WindowsSandboxRemoteSession.exe" "C:\case\qualification.wsb"')
        session=dict(base,ProcessId=123,ParentProcessId=100,Name='WindowsSandboxRemoteSession.exe')
        server=dict(ProcessId=124,ParentProcessId=123,Name='WindowsSandboxServer.exe',
                    CreationDate='2026-11-05T13:05:35.0000000Z',
                    ExecutablePath=r'C:\Apps\WindowsSandboxServer.exe',CommandLine='server')
        return [session,server]

    def test_recorded_server_exit_stops_without_waiting_for_host_deadline(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root);pair=self.owned_pair()
            observations=iter(({'rows':[]},{'rows':pair},{'rows':pair[:1]}))
            with patch.object(supervisor,'preflight'),patch.object(supervisor.observation,'observe',side_effect=lambda **k:next(observations)),\
                 patch.object(supervisor.subprocess,'run',return_value=subprocess.CompletedProcess([],0,b'{"pid":100,"creationUtc":"2026-11-05T13:05:34Z"}',b'')),\
                 patch.object(supervisor.time,'sleep'),patch.object(supervisor,'_finish_host') as finish:
                with self.assertRaisesRegex(RuntimeError,'server exited'):
                    supervisor.launch(root)
            self.assertEqual(finish.call_count,1)
            self.assertTrue((root/'launch.claim.json').exists())

    def test_remaining_session_cleanup_binds_history_and_refuses_pid_reuse(self):
        pair=self.owned_pair();launch=dict(pid=100,creationUtc='2026-11-05T13:05:34Z')
        script=supervisor.remaining_session_cleanup(launch,pair,pair[:1],r'C:\case\qualification.wsb')
        self.assertIn('.CloseMainWindow()',script)
        self.assertIn('.Handle',script)
        self.assertIn('.Kill()',script)
        self.assertIn('2026-11-05T13:05:34.8202130Z',script)
        for changed in (dict(pair[0],CreationDate='2026-11-06T13:05:34Z'),dict(pair[0],CommandLine='other')):
            with self.assertRaises(ValueError):
                supervisor.remaining_session_cleanup(launch,pair,[changed],r'C:\case\qualification.wsb')
        with self.assertRaises(ValueError):
            supervisor.remaining_session_cleanup(launch,[],pair[:1],r'C:\case\qualification.wsb')
        with self.assertRaises(ValueError):
            supervisor.remaining_session_cleanup(launch,pair,pair[1:],r'C:\case\qualification.wsb')

    def test_finish_host_routes_surviving_session_and_verifies_empty_snapshot(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);pair=self.owned_pair()
            pair[0]['CommandLine']='"'+pair[0]['ExecutablePath']+'" "'+str(root/'qualification.wsb')+'"'
            launch=dict(pid=100,creationUtc='2026-11-05T13:05:34Z')
            with patch.object(supervisor.observation,'observe',side_effect=({'rows':pair[:1]},{'rows':[]})),\
                 patch.object(supervisor.subprocess,'run',return_value=subprocess.CompletedProcess([],0,b'',b'')) as run:
                supervisor._finish_host(root,launch,pair,supervisor.time.monotonic()+45)
            self.assertEqual(run.call_count,1)
            self.assertIn('.CloseMainWindow()',(root/'close-owned.ps1').read_text())
            self.assertEqual(json.loads((root/'host-after-cleanup.json').read_bytes()),[])

    def test_cleanup_script_execution_uses_only_simulated_processes(self):
        pair=self.owned_pair();launch=dict(pid=100,creationUtc='2026-11-05T13:05:34Z')
        script=supervisor.remaining_session_cleanup(launch,pair,pair[:1],r'C:\case\qualification.wsb')
        harness=r'''
$ErrorActionPreference='Stop'
Add-Type @'
public class FakeOwnedSession {
    public int Handle { get { return 123; } }
    public System.DateTime StartTime;
    public bool Gentle;
    public bool HasExited;
    public bool CloseMainWindow() { System.Console.WriteLine("CLOSE"); return true; }
    public bool WaitForExit(int timeout) { if(Gentle) HasExited=true; return HasExited; }
    public void Kill() { System.Console.WriteLine("KILL"); HasExited=true; }
}
'@
$fake=[FakeOwnedSession]::new()
$fake.Gentle=$mode -eq 'gentle'
$birth=[datetime]::Parse('2026-11-05T13:05:34.8202130Z')
$fake.StartTime=$birth
$cim=[pscustomobject]@{CreationDate=$birth;ExecutablePath='C:\Apps\WindowsSandboxRemoteSession.exe';CommandLine='"C:\Apps\WindowsSandboxRemoteSession.exe" "C:\case\qualification.wsb"'}
switch($mode){
 'birth' {$cim.CreationDate=$birth.AddSeconds(1)}
 'path' {$cim.ExecutablePath='C:\other.exe'}
 'command' {$cim.CommandLine='other'}
 'held' {$fake.StartTime=$birth.AddSeconds(1)}
}
function Get-Process { param($Id,$ErrorAction) if($mode -ne 'absent'){$fake} }
function Get-CimInstance { param($ClassName,$Filter) if($mode -ne 'gone'){$cim} }
'''
        for mode in ('gentle','kill','absent','gone','birth','path','command','held'):
            with self.subTest(mode=mode):
                result=subprocess.run(['pwsh','-NoProfile','-NonInteractive','-Command',"$mode='"+mode+"'\n"+harness+'\n'+script],capture_output=True,timeout=20)
                lines=result.stdout.decode('utf-8-sig').splitlines()
                if mode in ('birth','path','command','held'):
                    self.assertNotEqual(result.returncode,0)
                    self.assertEqual(lines,[])
                    self.assertIn(b'identity',result.stderr)
                else:
                    self.assertEqual(result.returncode,0,result.stderr)
                    self.assertEqual(lines,['CLOSE'] if mode=='gentle' else ['CLOSE','KILL'] if mode=='kill' else [])

    def launch_fake(self, root, terminal, change=None, cleanup_error=False):
        c=self.case(root)
        def start(*args,**kwargs):
            proof=dict(nonce=c['nonce'],status='AAR_PRODUCER_EXIT0_OUTPUT_EXPORTED',root_exit=0,elapsed_ms=1200)
            if change:proof.update(change)
            supervisor.put(root/'output'/terminal,proof)
            return subprocess.CompletedProcess([],0,b'{"pid":123,"creationUtc":"fixture"}',b'')
        finish=RuntimeError('cleanup failed') if cleanup_error else None
        with patch.object(supervisor,'preflight'),patch.object(supervisor.observation,'observe',return_value={'rows':[]}),\
             patch.object(supervisor.subprocess,'run',side_effect=start),\
             patch.object(supervisor,'_finish_host',side_effect=finish) as close:
            try:result=supervisor.launch(root)
            except Exception as error:result=error
        return result,close.call_count

    def test_success_and_guest_failure_cleanup_once_without_refunding_claim(self):
        for terminal in ('result.json','failure.json','watchdog.json'):
            with self.subTest(terminal=terminal),tempfile.TemporaryDirectory() as directory:
                root=Path(directory);result,count=self.launch_fake(root,terminal)
                self.assertEqual(count,1)
                self.assertTrue((root/'launch.claim.json').exists())
                self.assertEqual(isinstance(result,dict),terminal=='result.json')
                if terminal!='result.json':self.assertTrue((root/'STOP.json').exists())

    def test_bad_nonce_deadline_and_cleanup_failure_cannot_be_success(self):
        for change,cleanup in (({'nonce':'other'},False),({'elapsed_ms':100000},False),({},True)):
            with tempfile.TemporaryDirectory() as directory:
                root=Path(directory);result,count=self.launch_fake(root,'result.json',change,cleanup)
                self.assertIsInstance(result,Exception);self.assertEqual(count,1)
                self.assertTrue((root/'STOP.json').exists())

    def test_observation_crossing_host_deadline_cannot_accept_a_result(self):
        with tempfile.TemporaryDirectory() as directory:
            ticks=iter((0,199,199,201))
            with patch.object(supervisor.time,'monotonic',side_effect=lambda:next(ticks,201)):
                result,count=self.launch_fake(Path(directory),'result.json')
            self.assertIsInstance(result,TimeoutError);self.assertEqual(count,1)
            self.assertTrue((Path(directory)/'STOP.json').exists())

    def test_cleanup_time_is_part_of_success_deadline(self):
        with tempfile.TemporaryDirectory() as directory:
            ticks=iter((0,1,1,1,1,201))
            with patch.object(supervisor.time,'monotonic',side_effect=lambda:next(ticks,201)):
                result,count=self.launch_fake(Path(directory),'result.json')
            self.assertIsInstance(result,TimeoutError);self.assertEqual(count,1)

    def test_frozen_payload_is_bound_to_grant_contract_not_mutable_receipt(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root)
            (root/'qualification.wsb').write_text('changed to writable')
            supervisor.put(root/'prepared.json',dict(frozen={'qualification.wsb':supervisor.sha(root/'qualification.wsb')}))
            with self.assertRaises(ValueError):supervisor.launch(root)
            self.assertFalse((root/'launch.claim.json').exists())

    def test_missing_grant_cannot_consume_a_claim(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root)
            (root/'probe'/'owner-grant.json').unlink()
            with self.assertRaises(FileNotFoundError):supervisor.launch(root)
            self.assertFalse((root/'launch.claim.json').exists())

    def test_output_sample_counts_nested_files_and_stops_on_overflow(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);(root/'nested').mkdir()
            (root/'one').write_bytes(b'123');(root/'nested'/'two').write_bytes(b'456')
            self.assertEqual(supervisor.output_size(root,6),6)
            with self.assertRaises(RuntimeError):supervisor.output_size(root,5)

    def test_atomic_publication_disappearance_is_a_sample_gap_not_STOP(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);pending=root/'result.json.pending';pending.write_bytes(b'123')
            original=supervisor._checked_stat
            def moved(path):
                if path==pending:
                    pending.rename(root/'result.json');raise FileNotFoundError(str(path))
                return original(path)
            with patch.object(supervisor,'_checked_stat',side_effect=moved):
                self.assertLessEqual(supervisor.output_size(root,10),3)
            self.assertTrue((root/'result.json').exists())
            with self.assertRaises(RuntimeError):supervisor.output_size(root,2)


if __name__=='__main__':unittest.main()
