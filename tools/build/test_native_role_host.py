import copy
from datetime import datetime, timezone, timedelta
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import native_role_host as host
import test_native_role_executor as executor_fixtures
import test_sandbox_owned_session_cleanup as cleanup_fixtures


class NativeRoleHostTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.root_patch = patch.object(host, 'ROOT', self.root); self.root_patch.start(); self.addCleanup(self.root_patch.stop)
        for name in ('output', 'probe'):
            (self.root / name).mkdir()

    def fixture(self):
        receipt, active, pins = executor_fixtures.NativeRoleExecutorTests(methodName='test_good_synthetic_receipt_retains_sampling_boundary').receipt_fixture()
        receipt['proof']['root_birth'] = 100
        contract = {'manifest': {**active, 'runtime_authorized': False}}
        host.write_once(self.root / 'case-contract-private.json', contract)
        grant = {**host.authority_fields(), 'owner_reply': 'SYNTHETIC_TEST_NO_AUTHORITY'}
        host.write_once(self.root / 'owner-explicit-grant-private.json', grant)
        claim = {**host.authority_fields(), 'nonce': active['nonce'], 'refundable': False,
                 'launch_origin': {'monotonic': 1000.0, 'utc': '2026-11-05T00:00:00Z'},
                 'owner_grant_sha256': host.sha((self.root / 'owner-explicit-grant-private.json').read_bytes())}
        host.write_once(self.root / 'launch.claim.json', claim)
        host.write_once(self.root / 'probe/manifest.json', active)
        launched = {'pid': 100, 'creationUtc': '2026-11-05T00:00:00Z',
                    'executable': str(Path(os.environ['SystemRoot']) / 'System32/WindowsSandbox.exe')}
        host.write_once(self.root / 'launched.json', launched)
        host.write_once(self.root / 'launch-binding-private.json', {'scope': host.SCOPE, 'nonce': active['nonce'],
            'claim_sha256': host.sha((self.root / 'launch.claim.json').read_bytes()),
            'launched_sha256': host.sha((self.root / 'launched.json').read_bytes())})
        exe = active['executable']
        rows = [{'operation': 'root_create_attempt', 'utc': '2026-11-05T00:00:00Z'},
                {'operation': 'process_image_check', 'pid': 10, 'birth': 100, 'observed_image': exe}]
        for exited in (False, True):
            rows.append({'utc': '2026-11-05T00:00:01Z', 'members': [{'pid': 10, 'birth': 100, 'image': exe, 'exited': exited}],
                         'endpoints': [], 'udp_destination': 'UNKNOWN', 'sampling_non_atomic': True})
        host.write_once(self.root / 'output/result.json', receipt)
        (self.root / 'output/samples.jsonl').write_bytes(('\n'.join(map(json.dumps, rows)) + '\n').encode())
        (self.root / 'output/tool.stdout').write_bytes(b'cmake version 3.22.1\n')
        (self.root / 'output/tool.stderr').write_bytes(b'')
        host.write_once(self.root / 'output/guest-preflight.json', {
            'kind': 'native-cmake-preflight', 'nonce': active['nonce'], 'username': 'WDAGUtilityAccount',
            'file_denials': 252, 'directory_denials': 15, 'output_canary_write_read_delete': True,
            'network_no_active_adapter': True, 'SDK_starts': 0, 'G2': False})
        return contract, pins, receipt

    def partial_fixture(self):
        binary = b'original synthetic compiled artifact, never executed'
        original = {
            'probe/NativeRoleProbe.cs': ('nonce=' + host.PARTIAL_NONCE).encode(),
            'probe/NativeRoleProbe.exe': binary,
            'probe/manifest.locked.json': json.dumps({'nonce': host.PARTIAL_NONCE, 'binary_sha256': host.sha(binary)}).encode(),
            'qualification.wsb': ('nonce=' + host.PARTIAL_NONCE).encode(),
            'compiler.stdout': b'', 'compiler.stderr': b''}
        for name, raw in original.items():
            (self.root / name).write_bytes(raw)
        record = {'status': 'PREPARATION_METADATA_PIN_FAILED_NO_RUNTIME_ATTEMPT', 'VM_launches': 0,
                  'SDK_starts': 0, 'claim_created': False, 'same_fixed_directory_required': True,
                  'files': {name: {'bytes': len(raw), 'sha256': host.sha(raw)} for name, raw in original.items()}}
        host.write_once(self.root / 'preparation-partial-private.json', record)
        return host.sha((self.root / 'preparation-partial-private.json').read_bytes())

    def collect(self, contract, pins):
        with patch.object(host, 'frozen', return_value=(contract, pins)), patch.object(host.observation, 'observe', return_value={'rows': []}):
            return host.collect()

    def test_default_launch_rejects_before_any_environment_or_process_call(self):
        with patch.object(host, 'frozen', side_effect=AssertionError('must not enter preflight')):
            for value in (False, None, 1, 'true'):
                with self.assertRaises(ValueError):
                    host.launch(new_scope_authorized=value, owner_reference='anything')

    def test_system_compiler_hardlinks_do_not_relax_single_link_SDK_inputs(self):
        compiler = self.root / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
        compiler.parent.mkdir(parents=True)
        compiler.write_bytes(b'synthetic signed-system-compiler metadata fixture')
        os.link(compiler, self.root / 'servicing-hardlink')
        with self.assertRaises(ValueError):
            host.safe_bytes(compiler, 1024)
        with patch.dict(os.environ, {'SystemRoot': str(self.root)}), \
             patch.object(host.subprocess, 'run', return_value=SimpleNamespace(returncode=0)):
            path, digest = host.compiler_pin()
        self.assertEqual(path, compiler)
        self.assertEqual(digest, host.sha(compiler.read_bytes()))

    def test_partial_resume_rejects_binary_and_manifest_joint_replacement(self):
        digest = self.partial_fixture()
        with patch.object(host, 'PARTIAL_RECEIPT_SHA', digest):
            host.preserved_partial()
            binary = b'replacement synthetic artifact'
            (self.root / 'probe/NativeRoleProbe.exe').write_bytes(binary)
            m = json.loads((self.root / 'probe/manifest.locked.json').read_bytes());m['binary_sha256'] = host.sha(binary)
            (self.root / 'probe/manifest.locked.json').write_text(json.dumps(m))
            with self.assertRaises(ValueError):
                host.preserved_partial()

    def test_partial_resume_rejects_joint_nonce_source_and_config_replacement(self):
        digest = self.partial_fixture()
        m = json.loads((self.root / 'probe/manifest.locked.json').read_bytes());m['nonce'] = 'b' * 32
        (self.root / 'probe/manifest.locked.json').write_text(json.dumps(m))
        (self.root / 'probe/NativeRoleProbe.cs').write_text('nonce=' + 'b' * 32)
        (self.root / 'qualification.wsb').write_text('nonce=' + 'b' * 32)
        with patch.object(host, 'PARTIAL_RECEIPT_SHA', digest), self.assertRaises(ValueError):
            host.preserved_partial()

    def test_partial_resume_refuses_launched_or_terminal_residue_before_rechecking_inputs(self):
        for name in ('launched.json', 'verified-result.json', 'driver-stop-private.json'):
            path = self.root / name;path.write_text('{}')
            with patch.object(host, 'readset', side_effect=AssertionError('do not touch SDK inputs')), self.assertRaises(ValueError):
                host.finish_preparation()
            path.unlink()

    def test_launch_window_cannot_reset_on_delayed_or_repeated_collection(self):
        origin = {'monotonic': 1000.0, 'utc': '2026-11-05T00:00:00Z'}
        start = datetime(2026, 11, 5, tzinfo=timezone.utc)
        self.assertEqual(host.remaining_window(origin, 1100.0, start + timedelta(seconds=100)), 80)
        self.assertEqual(host.remaining_window(origin, 1179.0, start + timedelta(seconds=120)), 1)
        with self.assertRaises(TimeoutError):
            host.remaining_window(origin, 1180.0, start + timedelta(seconds=180))
        with self.assertRaises(ValueError):
            host.remaining_window(origin, 10.0, start + timedelta(seconds=1))

    def test_expired_wait_records_STOP_once_without_renewing_or_launching(self):
        contract, pins, _ = self.fixture()
        with patch.object(host, 'frozen', return_value=(contract, pins)), \
             patch.object(host, 'remaining_window', side_effect=TimeoutError('spent')), \
             patch.object(host, 'stop_cleanup', return_value={'status': 'SYNTHETIC_NO_ACTION'}) as close, \
             patch.object(host.subprocess, 'run', side_effect=AssertionError('no SDK or PS launch')):
            with self.assertRaises(TimeoutError):
                host.wait_and_collect()
            close.assert_called_once()
            with self.assertRaises(ValueError):
                host.wait_and_collect()
        self.assertTrue((self.root / 'driver-stop-private.json').exists())

    def test_STOP_safety_cleanup_refuses_frontend_or_other_instances(self):
        contract, pins, _ = self.fixture()
        launched = host.launch_chain(contract)
        with patch.object(host, 'frozen', return_value=(contract, pins)), \
             patch.object(host.observation, 'observe', return_value={'rows': [{'Name': 'WindowsSandboxClient.exe'}]}), \
             patch.object(host.subprocess, 'run', side_effect=AssertionError('must not terminate frontend')):
            result = host.stop_cleanup(launched)
        self.assertEqual(result['status'], 'NOT_CLEANED_UNBOUND_FRONTEND_OR_OTHER_INSTANCE')
        self.assertIs(result['qualification_stays_STOP'], True)

    def test_configuration_has_five_readonly_roots_and_one_owned_output(self):
        mappings = {role: {'host': 'D:\\NativeInputs\\' + role, 'guest': guest, 'readonly': True}
                    for role, guest in host.core.ROOTS.items()}
        xml = ET.fromstring(host.configuration(mappings, 'a' * 32))
        folders = xml.findall('MappedFolders/MappedFolder')
        self.assertEqual(len(folders), 7)
        self.assertEqual([f.findtext('SandboxFolder') for f in folders if f.findtext('ReadOnly') == 'false'], [r'C:\ProbeOutput'])
        self.assertEqual(xml.findtext('Networking'), 'Disable')
        mappings['private_flutter']['readonly'] = False
        with self.assertRaises(ValueError):
            host.configuration(mappings, 'a' * 32)

    def test_strict_collector_binds_all_raw_outputs_without_writing_acceptance(self):
        contract, pins, _ = self.fixture()
        summary = self.collect(contract, pins)
        self.assertEqual(summary['scope'], host.SCOPE)
        self.assertEqual(len(summary['raw_sha256']), 5)
        self.assertIs(summary['native_DLL_closure_proven'], False)
        self.assertFalse((self.root / 'verified-result.json').exists())

    def test_good_outer_result_cannot_hide_STOP_or_extra_failure_marker(self):
        contract, pins, receipt = self.fixture()
        bad = copy.deepcopy(receipt); bad['proof']['stop_reason'] = 'UNKNOWN_PROCESS_IMAGE'
        (self.root / 'output/result.json').write_text(json.dumps(bad))
        with self.assertRaises(ValueError):
            self.collect(contract, pins)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        (self.root / 'output/guest-watchdog.json').write_text('{}')
        with self.assertRaises(ValueError):
            self.collect(contract, pins)

    def test_bad_grant_claim_launcher_or_active_flag_rejected(self):
        contract, pins, _ = self.fixture()
        paths = ['owner-explicit-grant-private.json', 'launch.claim.json', 'launched.json', 'probe/manifest.json']
        fields = [('max_sdk_roots', 2), ('refundable', True), ('pid', True), ('runtime_authorized', 1)]
        for name, (field, value) in zip(paths, fields):
            path = self.root / name; original = path.read_bytes(); data = json.loads(original); data[field] = value
            path.write_text(json.dumps(data))
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.collect(contract, pins)
            path.write_bytes(original)

    def test_wrong_version_stderr_duplicate_JSON_and_host_leftover_rejected(self):
        contract, pins, _ = self.fixture()
        for name, value in [('tool.stdout', b'cmake version 0\n'), ('tool.stderr', b'warning'),
                            ('result.json', b'{"failure":"STOP","failure":null}')]:
            path = self.root / 'output' / name; original = path.read_bytes(); path.write_bytes(value)
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.collect(contract, pins)
            path.write_bytes(original)
        with patch.object(host, 'frozen', return_value=(contract, pins)), patch.object(host.observation, 'observe', return_value={'rows': [{'Name': 'unrelated'}]}):
            with self.assertRaises(ValueError):
                host.collect()

    def test_readonly_preflight_cannot_be_missing_or_promoted(self):
        contract, pins, _ = self.fixture()
        path = self.root / 'output/guest-preflight.json'; original = path.read_bytes()
        for key, value in [('file_denials', 251), ('network_no_active_adapter', False),
                           ('output_canary_write_read_delete', 1), ('SDK_starts', 1)]:
            bad = json.loads(original);bad[key] = value;path.write_text(json.dumps(bad))
            with self.subTest(key=key), self.assertRaises(ValueError):
                self.collect(contract, pins)
        path.unlink()
        with self.assertRaises(ValueError):
            self.collect(contract, pins)

    def test_failure_marker_still_drives_exact_owned_stub_cleanup_before_rejection(self):
        fixture = cleanup_fixtures.OwnedSessionTests(methodName='test_exact_owned_pair_only_renders_held_handle_termination');fixture.setUp()
        launched, rows = fixture.launch, fixture.rows
        rows[0]['CommandLine'] = 'session.exe "' + str(self.root / 'qualification.wsb') + '"'
        (self.root / 'output/guest-wrapper-failure.json').write_text('{"reason":"CORE_EARLY_EXIT_24"}')
        observations = iter([rows, []]); closed = []
        def observer(**kwargs):
            value = next(observations)
            return {'rows': value, 'stdout': json.dumps(value).encode(), 'stderr': b''}
        def closer(script, timeout):
            closed.append(script.read_text());return SimpleNamespace(returncode=0, stdout=b'', stderr=b'')
        def reject(deadline):
            raise ValueError('expected strict missing result rejection')
        writer = SimpleNamespace(_write_once=host.write_once)
        with self.assertRaisesRegex(ValueError, 'expected strict'):
            host.lifecycle()(writer, {}, launched, root=self.root, observer=observer, closer=closer,
                             collector=reject, deadline=time.monotonic() + 5)
        self.assertEqual(len(closed), 1)
        self.assertNotIn('$session.Cim.CreationDate', closed[0])
        self.assertEqual(json.loads((self.root / 'host-processes-after-cleanup-private.json').read_bytes()), [])

    def test_guest_wrapper_compiles_but_is_never_executed(self):
        source = self.root / 'Guest.cs'; source.write_bytes(host.guest_source(executor_fixtures.fixture_pins(), 'a' * 32))
        compiler = Path(os.environ['SystemRoot']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
        result = subprocess.run([str(compiler), '/nologo', '/noconfig', '/platform:x64', '/target:winexe',
             '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll',
             '/main:NativeRoleGuestWrapper', '/out:' + str(self.root / 'Guest.exe'), str(source)],
             capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout.decode(errors='replace') + result.stderr.decode(errors='replace'))
        self.assertNotIn(b'Process.Start(', source.read_bytes())

    def test_real_CSharp_lifecycle_guard_with_stubbed_failure_and_cleanup_only(self):
        source = self.root / 'Guest.cs';source.write_bytes(host.guest_source(executor_fixtures.fixture_pins(), 'a' * 32))
        wrapper = source.read_text()[source.read_text().index('class NativeRoleGuestWrapper'):]
        self.assertLess(wrapper.index('using(var watchdog'), wrapper.index('File.ReadAllText'))
        test = self.root / 'GuardTests.cs'
        test.write_text(r'''
using System;
using System.IO;
class GuardTests {
 static int checks;static void Check(bool value){if(!value)throw new Exception("Guard mismatch");checks++;}
 static int Main(string[] args){
  string nonce=new string('a',32),self=@"C:\Probe\NativeRoleProbe.exe";
  Check(NativeRoleGuestWrapper.BindingMatches("WDAGUtilityAccount",self,new[]{nonce}));
  Check(!NativeRoleGuestWrapper.BindingMatches("WDAGUtilityAccount",self,new[]{new string('b',32)}));
  Check(!NativeRoleGuestWrapper.BindingMatches("Owner",self,new[]{nonce}));
  Check(!NativeRoleGuestWrapper.BindingMatches("WDAGUtilityAccount",@"C:\Other.exe",new[]{nonce}));
  Check(!NativeRoleGuestWrapper.BindingMatches("WDAGUtilityAccount",self,new string[0]));
  foreach(Exception error in new Exception[]{new FileNotFoundException("manifest"),new ArgumentException("bad JSON"),new InvalidDataException("false authorization"),new InvalidDataException("policy drift")}){
   int sdk=0,failed=0,cleanup=0;
   int code=NativeRoleGuestWrapper.Guarded(delegate{throw error;},delegate(Exception e){failed++;},delegate{cleanup++;});
   Check(code==32&&sdk==0&&failed==1&&cleanup==1);
  }
  int called=0,closed=0;
  Check(NativeRoleGuestWrapper.Guarded(delegate{called++;return 0;},delegate(Exception e){throw new Exception("unexpected");},delegate{closed++;})==0&&called==1&&closed==1);
  int last=0;try{NativeRoleGuestWrapper.Guarded(delegate{throw new IOException("source");},delegate(Exception e){throw new IOException("marker");},delegate{last++;});}catch(IOException){}
  Check(last==1);
  string published=Path.Combine(args[0],"atomic.json");int before=0;
  NativeRoleGuestWrapper.Publish(published,new byte[]{123,125},delegate{Check(!File.Exists(published)&&File.Exists(published+".pending"));before++;});
  Check(before==1&&File.Exists(published)&&!File.Exists(published+".pending"));
  string canary=Path.Combine(args[0],"existing-canary");File.WriteAllText(canary,"original");
  try{NativeRoleGuestWrapper.OwnedCanary(canary,new byte[]{1});}catch(IOException){}
  Check(File.ReadAllText(canary)=="original");
  string fresh=Path.Combine(args[0],"fresh-canary");NativeRoleGuestWrapper.OwnedCanary(fresh,new byte[]{1});Check(!File.Exists(fresh));
  Console.WriteLine("PURE_LIFECYCLE_GUARD_CHECKS="+checks);return 0;
 }
}''', encoding='utf-8')
        compiler = Path(os.environ['SystemRoot']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
        binary = self.root / 'GuardTests.exe'
        result = subprocess.run([str(compiler), '/nologo', '/noconfig', '/platform:x64',
            '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll',
            '/main:GuardTests', '/out:' + str(binary), str(source), str(test)], capture_output=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stdout.decode(errors='replace'))
        ran = subprocess.run([str(binary), str(self.root)], capture_output=True, timeout=15)
        self.assertEqual(ran.returncode, 0, ran.stderr.decode(errors='replace'))
        self.assertEqual(ran.stdout.strip(), b'PURE_LIFECYCLE_GUARD_CHECKS=15')


if __name__ == '__main__':
    unittest.main()
