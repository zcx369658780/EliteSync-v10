"""Pure synthetic facts, inert files and grants; no PID observation or PHP launch."""
import copy,io,json,os,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from contextlib import redirect_stdout
from datetime import datetime,timedelta,timezone
from contracts import *
from os_images import validate_os_fact,image_map
import php_probe_entry
from php_native import validate_handshake,captured_path_set
from os_images import validate_process_identity,observed_liveness

class HandshakeContracts(unittest.TestCase):
    def test_exited_with_real_exit_code_259_is_not_running(self):
        actual=dict(pid=7,creation=1,exit_code=259,running=observed_liveness(0))
        with self.assertRaisesRegex(Gate,'INSTANCE'):validate_process_identity(actual,dict(pid=7,creation=1,running=True))
    def test_qualified_os_path_set_does_not_reenter_private_validator(self):
        with patch('php_native.local',side_effect=AssertionError('OS_MUST_NOT_REENTER_PRIVATE')):
            self.assertEqual({'c:/windows/system32/kernel32.dll'},captured_path_set([dict(path='C:/Windows/System32/kernel32.dll')]))
    def test_process_creation_time_replacement_rejected(self):
        with self.assertRaisesRegex(Gate,'INSTANCE'):validate_process_identity(dict(pid=7,creation=2,running=True),dict(pid=7,creation=1,running=True))
    def test_exited_original_process_rejected(self):
        with self.assertRaisesRegex(Gate,'INSTANCE'):validate_process_identity(dict(pid=7,creation=1,running=False),dict(pid=7,creation=1,running=True))
    def test_other_process_requires_original_handle_before_enumeration(self):
        with patch('os_images.loaded_module_paths',side_effect=AssertionError('MUST_NOT_OBSERVE')):
            with self.assertRaisesRegex(Gate,'SOURCE_HANDLE'):image_map(7,7)
    def test_bound_synthetic_pid_nonce_profile(self):validate_handshake(dict(pid=7,nonce='a'*32,manifest_sha256='b'*64),7,'a'*32,'b'*64)
    def test_wrong_nonce_rejected(self):
        with self.assertRaisesRegex(Gate,'HANDSHAKE'):validate_handshake(dict(pid=7,nonce='c'*32,manifest_sha256='b'*64),7,'a'*32,'b'*64)
    def test_wrong_pid_rejected(self):
        with self.assertRaisesRegex(Gate,'HANDSHAKE'):validate_handshake(dict(pid=8,nonce='a'*32,manifest_sha256='b'*64),7,'a'*32,'b'*64)
    def test_wrong_profile_rejected(self):
        with self.assertRaisesRegex(Gate,'HANDSHAKE'):validate_handshake(dict(pid=7,nonce='a'*32,manifest_sha256='c'*64),7,'a'*32,'b'*64)

class OsImageContracts(unittest.TestCase):
    def setUp(self):
        self.system=dict(path='C:/Windows/System32',file_id=100,volume=7,from_system_directory_api=True,reparse=False)
        self.fact=dict(path='C:/Windows/System32/kernel32.dll',canonical_path='C:/Windows/System32/kernel32.dll',readonly_handle=True,from_loaded_module_api=True,sha256='a'*64,file_id=101,volume=7,links=2,bytes=4096,reparse=False)
        self.pin=dict(self.fact,signature_status='Valid',windows_publisher_verified=True,signer_thumbprint='b'*40,source_class='WINDOWS_SYSTEM_IMAGE')
        self.policy=dict(schema=1,purpose='READONLY_LOADED_WINDOWS_OS_IMAGES',system_root=copy.deepcopy(self.system),images={'kernel32.dll':self.pin})
    def check(self):return validate_os_fact(self.fact,self.policy,self.system)
    def reject(self):
        with self.assertRaises(Gate):self.check()
    def test_signed_pinned_os_two_links_readonly_is_input_match_only(self):self.assertEqual('QUALIFIED_READONLY_OS_IMAGE',self.check()['state'])
    def test_unknown_module_rejected(self):self.policy['images']={};self.reject()
    def test_fake_os_directory_rejected(self):self.fact['path']='C:/fake/System32/kernel32.dll';self.reject()
    def test_winsxs_alias_rejected(self):self.fact['path']='C:/Windows/WinSxS/kernel32.dll';self.reject()
    def test_invalid_signature_rejected(self):self.pin['signature_status']='NotSigned';self.reject()
    def test_non_windows_publisher_rejected(self):self.pin['windows_publisher_verified']=False;self.reject()
    def test_missing_certificate_identity_rejected(self):self.pin['signer_thumbprint']='';self.reject()
    def test_hash_changed_rejected(self):self.fact['sha256']='c'*64;self.reject()
    def test_file_id_changed_rejected(self):self.fact['file_id']=102;self.reject()
    def test_wrong_system_root_rejected(self):self.policy['system_root']['path']='D:/Windows/System32';self.reject()
    def test_system_root_identity_changed_rejected(self):self.system['file_id']=999;self.reject()
    def test_system_root_not_from_api_rejected(self):self.system['from_system_directory_api']=False;self.reject()
    def test_cross_volume_even_with_matching_file_pin_rejected(self):self.fact['volume']=self.pin['volume']=8;self.reject()
    def test_zero_links_even_if_pinned_rejected(self):self.fact['links']=self.pin['links']=0;self.reject()
    def test_link_count_changed_rejected(self):self.fact['links']=3;self.reject()
    def test_reparse_escape_rejected(self):self.fact['reparse']=True;self.reject()
    def test_canonical_alias_rejected(self):self.fact['canonical_path']='C:/Windows/System32/other.dll';self.reject()
    def test_not_an_api_loaded_module_rejected(self):self.fact['from_loaded_module_api']=False;self.reject()
    def test_write_capable_fact_rejected(self):self.fact['readonly_handle']=False;self.reject()
    def test_unknown_process_refused_before_os_enumeration(self):
        with patch('os_images.loaded_module_paths',side_effect=AssertionError('MUST_NOT_OBSERVE')):
            with self.assertRaisesRegex(Gate,'UNKNOWN_PROCESS'):image_map(7,8,self.policy)
    def test_private_dll_hardlink_still_rejected(self):
        with tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']) as tmp:
            p=Path(tmp)/'private.dll';p.write_bytes(b'INERT');q=Path(tmp)/'alias.dll';os.link(p,q)
            with self.assertRaisesRegex(Gate,'HARDLINK_REJECTED'):local(p,Path(tmp))

class NoDbProbeContracts(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']);self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)/'v1015-native-three-issues-20261029';self.root.mkdir();source=self.root/'backend';source.mkdir()
        paths=['tests/E2E/php_runtime_probe.php','tests/E2E/MainlineEnvironment.php','tests/E2E/PhpRuntimeQualification.php','composer.json','composer.lock'];files={}
        for rel in paths:
            p=source/rel;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(b'INERT_SOURCE');files[rel]=digest(p.read_bytes())
        now=datetime.now(timezone.utc)
        self.config=dict(task_root=str(self.root),source_root=str(source),source_files=files,max_bytes=1048576,source_binding=dict(commit=NO_DB_PARENT,apps_tree='8cd9b6df8e744c8fc9d4217412edce31795a318d',services_tree='eb47fe58d1167b1795224d4c748fb046042b9c92'))
        self.grant=dict(owner_authorized=True,task_blob=NO_DB_TASK,action='php_native_no_db_probe',not_before=(now-timedelta(minutes=1)).isoformat(),expires_at=(now+timedelta(minutes=1)).isoformat(),probe_operations=1,probe_seconds=30,new_instance_qualified=False,db_operations=0,network_operations=0,laravel_bootstrap_allowed=False,source_binding=self.config['source_binding'],max_bytes=1048576)
        self.rehash()
    def rehash(self):self.grant['config_sha256']=digest(canonical(self.config))
    def valid(self):return validate_probe_authority(self.config,self.grant)
    def reject(self):
        with self.assertRaises((Gate,ValueError,KeyError)):self.valid()
    def test_db_not_qualified_can_pass_explicit_static_probe_authority(self):self.assertEqual(self.root,self.valid())
    def test_probe_grant_cannot_authorize_db_entry(self):
        with self.assertRaises(Gate):validate_authority(self.config,self.grant)
    def test_no_db_task_cannot_be_relabelled_as_api(self):
        self.grant['action']='mainline_api_db_e2e';self.grant['new_instance_qualified']=True
        with self.assertRaisesRegex(Gate,'NO_DB_TASK'):validate_authority(self.config,self.grant)
    def test_wrong_probe_action_rejected(self):self.grant['action']='mainline_api_db_e2e';self.reject()
    def test_old_task_rejected(self):self.grant['task_blob']='128fa1f7746ee73ee6d52d2d693715b003a4ec13';self.reject()
    def test_expired_rejected(self):self.grant['expires_at']='2000-01-01T00:00:00+00:00';self.reject()
    def test_source_lineage_rejected(self):self.config['source_binding']['commit']='a'*40;self.rehash();self.reject()
    def test_source_bytes_changed_rejected(self):(Path(self.config['source_root'])/'composer.json').write_bytes(b'changed');self.reject()
    def test_missing_probe_source_closure_rejected(self):self.config['source_files'].pop('tests/E2E/php_runtime_probe.php');self.rehash();self.reject()
    def test_db_config_is_not_read_by_probe(self):self.config['db_password']='SYNTHETIC';self.rehash();self.reject()
    def test_db_operations_forbidden(self):self.grant['db_operations']=1;self.reject()
    def test_network_operations_forbidden(self):self.grant['network_operations']=1;self.reject()
    def test_laravel_bootstrap_forbidden(self):self.grant['laravel_bootstrap_allowed']=True;self.reject()
    def test_forged_instance_qualification_forbidden(self):self.grant['new_instance_qualified']=True;self.reject()
    def test_more_than_one_probe_forbidden(self):self.grant['probe_operations']=2;self.reject()
    def test_more_than_thirty_seconds_forbidden(self):self.grant['probe_seconds']=31;self.reject()
    def test_config_change_rejected(self):self.config['max_bytes']=2097152;self.reject()
    def test_inspect_has_no_process_or_file_effect(self):
        before=list(self.root.rglob('*'));out=io.StringIO()
        with patch('php_probe_entry.cli',side_effect=AssertionError('MUST_NOT_RUN')),redirect_stdout(out):self.assertEqual(php_probe_entry.main([]),0)
        self.assertEqual(before,list(self.root.rglob('*')));self.assertIn('PHP_PROBE_NOT_RUN',out.getvalue())
