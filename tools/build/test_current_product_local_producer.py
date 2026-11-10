import base64
from contextlib import ExitStack
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import types
import unittest
import uuid
from unittest.mock import patch

import current_product_local_producer as local
from current_product_tree_inventory import inventory_trees
import current_product_source_overlay as source_overlay


class LocalProducerTests(unittest.TestCase):
    def test_new_build_policy_is_four_gib_plus_one_with_legacy_policy_preserved(self):
        self.assertEqual(local.aar_memory_policy(),
                         dict(job_memory_bytes=4*1024**3, required_available_mib=5120))
        self.assertEqual(local.build_memory_policy(), local.aar_memory_policy())
        self.assertEqual(local.local_memory_policy(6),
                         dict(job_memory_bytes=6*1024**3, required_available_mib=10240))

    def test_new_aar_policy_rejects_other_limits_before_preparation(self):
        for value in [True, False, None, 0, 5, 6, 8, -1, 4.0, 6.0, '4', '6']:
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError, 'integer 4 GiB'):
                    local.aar_memory_policy(value)
                with self.assertRaisesRegex(ValueError, 'integer 4 GiB'):
                    local.prepare(None, None, None, job_memory_gib=value)

    def test_memory_policy_defaults_and_explicit_six_keep_four_gib_headroom(self):
        self.assertEqual(local.local_memory_policy(),
                         dict(job_memory_bytes=4*1024**3,required_available_mib=8192))
        self.assertEqual(local.local_memory_policy(6),
                         dict(job_memory_bytes=6*1024**3,required_available_mib=10240))
        self.assertEqual(local.LIMITS['required_available_mib'],8192)

    def test_six_gib_boundary_changes_only_selected_memory_limit(self):
        raw=(local.HERE/'producer_process_boundary.cs').read_bytes()
        args=(raw,'work','exe','java','cwd','logs','fixture-user')
        default=local.local_boundary(*args)
        self.assertEqual(default,local.local_boundary(*args,job_memory_gib=4))
        six=local.local_boundary(*args,job_memory_gib=6)
        old=b'JobMemoryLimit=new UIntPtr(4UL*1024*1024*1024)'
        new=b'JobMemoryLimit=new UIntPtr(6UL*1024*1024*1024)'
        self.assertEqual(default.count(old),1)
        self.assertEqual(six,default.replace(old,new,1))
        self.assertEqual((local.HERE/'producer_process_boundary.cs').read_bytes(),raw)

    def test_memory_policy_rejects_other_values_before_source_processing(self):
        for value in [True,False,None,0,5,8,-1,4.0,6.0,'4','6']:
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError,'4 or 6'):
                    local.local_memory_policy(value)
                # None raw input proves policy validation precedes source hashing/decoding.
                with self.assertRaisesRegex(ValueError,'4 or 6'):
                    local.local_boundary(None,'work','exe','java','cwd','logs','user',job_memory_gib=value)
                with self.assertRaisesRegex(ValueError,'integer 4 GiB'):
                    local.prepare(None,None,None,job_memory_gib=value)

    def test_task_specific_boundary_keeps_job_core_and_explicit_identity(self):
        raw=(local.HERE/'producer_process_boundary.cs').read_bytes()
        rendered=local.local_boundary(raw,r'C:\Local Build\work',r'C:\Local Build\control\Local.exe',
            'C:/Program Files/Java/bin/java.exe',r'C:\Local Build\work\Project\.android',r'C:\Local Build\output','fixture-user').decode()
        self.assertNotIn('WDAGUtilityAccount',rendered)
        self.assertNotIn(r'C:\BuildWork',rendered)
        self.assertIn('Environment.UserName!="fixture-user"',rendered)
        self.assertIn('Self=@"C:\\Local Build\\control\\Local.exe"',rendered)
        for unchanged in ['0x2000|0x8|0x200','ActiveProcessLimit=64','4UL*1024*1024*1024',
                          'AssignProcessToJobObject','TerminateAndDrainJob','0x08000000|0x80000|0x400|0x4']:
            self.assertIn(unchanged,rendered)
        with self.assertRaises(ValueError):
            local.local_boundary(raw+b'changed','x','x','x','x','x','x')

    def test_copy_uses_pinned_source_and_preserves_partial_on_change(self):
        with tempfile.TemporaryDirectory() as directory:
            task=Path(directory);source=task/'source';source.mkdir();(source/'file').write_bytes(b'original')
            data=inventory_trees(roots={'fixture':str(source)},file_limit=10,entry_limit=20,byte_limit=100,depth_limit=5)
            local._copy_tree(data,task/'copy')
            self.assertEqual((task/'copy/file').read_bytes(),b'original')
            self.assertEqual((source/'file').read_bytes(),b'original')
            (source/'file').write_bytes(b'altered!')
            with self.assertRaises(ValueError):local._copy_tree(data,task/'changed-copy')
            self.assertTrue((task/'changed-copy/file').exists())

    def case(self,root):
        (root/'control').mkdir();(root/'output').mkdir()
        contract=dict(kind='current-product-local-aar-producer',host_root=str(root.resolve()),nonce='fixture',payload_sha256={},host_helpers={})
        local.shared.put(root/'control/run-contract.json',contract)
        return contract

    def test_missing_grant_or_failed_preflight_never_consumes_local_claim(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root)
            with self.assertRaises(FileNotFoundError):local.launch(root)
            local.shared.put(root/'control/owner-grant.json',dict(authorized=True,max_attempts=1,
                contract_sha256=local.shared.sha(root/'control/run-contract.json'),fixture_only=True))
            with patch.object(local,'preflight',side_effect=RuntimeError('fixture resource block')),\
                 patch.object(local.subprocess,'Popen',side_effect=AssertionError('No process in preclaim test')):
                with self.assertRaisesRegex(RuntimeError,'fixture resource block'):local.launch(root)
            self.assertFalse((root/'launch.claim.json').exists())

    def test_preflight_queries_candidate_volume(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root)
            local.shared.put(root/'control/prepared-work-inventory.json',dict(files=[]))
            local.shared.put(root/'control/external-inputs.json',[])
            contract=dict(required_available_mib=8192,
                work_inventory_sha256=local.shared.sha(root/'control/prepared-work-inventory.json'),
                external_inventory_sha256=local.shared.sha(root/'control/external-inputs.json'))
            response=subprocess.CompletedProcess([],0,b'{"available_mib":12000}',b'')
            for free,allowed in [(9*1024**3,True),(7*1024**3,False)]:
                with self.subTest(free=free),patch.object(local.subprocess,'run',return_value=response),\
                     patch.object(local.shutil,'disk_usage',return_value=type('Disk',(),{'free':free})()) as disk:
                    if allowed:self.assertEqual(local.preflight(root,contract)['free_disk_bytes'],free)
                    else:
                        with self.assertRaisesRegex(RuntimeError,'resources insufficient'):local.preflight(root,contract)
                    disk.assert_called_once_with(root)

    def test_preflight_uses_new_five_gib_gate_and_keeps_frozen_old_gates(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);self.case(root)
            local.shared.put(root/'control/prepared-work-inventory.json',dict(files=[]))
            local.shared.put(root/'control/external-inputs.json',[])
            common=dict(work_inventory_sha256=local.shared.sha(root/'control/prepared-work-inventory.json'),
                        external_inventory_sha256=local.shared.sha(root/'control/external-inputs.json'))
            for gate,available,allowed in [(5120,5119,False),(5120,5120,True),
                                           (7168,5120,False),(10240,5120,False)]:
                response=subprocess.CompletedProcess([],0,json.dumps({'available_mib':available}).encode(),b'')
                with self.subTest(gate=gate,available=available),patch.object(local.subprocess,'run',return_value=response),\
                     patch.object(local.shutil,'disk_usage',return_value=type('Disk',(),{'free':9*1024**3})()):
                    contract=dict(common,required_available_mib=gate)
                    if allowed:self.assertEqual(local.preflight(root,contract)['available_mib'],available)
                    else:
                        with self.assertRaisesRegex(RuntimeError,'resources insufficient'):local.preflight(root,contract)
            self.assertFalse((root/'launch.claim.json').exists())

    def test_busy_serial_build_slot_rejects_before_preflight_or_claim(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);contract=self.case(root);contract['serial_build']=True
            (root/'control/run-contract.json').write_text(json.dumps(contract))
            with patch.object(local,'serial_build_slot',side_effect=RuntimeError('Build slot busy')),\
                 patch.object(local,'preflight') as check,patch.object(local.subprocess,'Popen') as start:
                with self.assertRaisesRegex(RuntimeError,'Build slot busy'):local.launch(root)
            check.assert_not_called();start.assert_not_called()
            self.assertFalse((root/'launch.claim.json').exists())
            self.assertFalse((root/'control/launch.claim.json').exists())

    def test_windows_serial_slot_excludes_another_thread_and_releases_after_error(self):
        name='Local\\EliteSync-build-test-'+uuid.uuid4().hex
        ready=threading.Event();finish=threading.Event();errors=[]
        def hold():
            try:
                with local.serial_build_slot(name):
                    ready.set()
                    if not finish.wait(5):raise TimeoutError('fixture release missing')
                    raise ValueError('fixture build failure')
            except ValueError:pass
            except BaseException as error:errors.append(error);ready.set()
        worker=threading.Thread(target=hold);worker.start()
        try:
            self.assertTrue(ready.wait(5));self.assertEqual(errors,[])
            with self.assertRaisesRegex(RuntimeError,'already running'):
                with local.serial_build_slot(name):self.fail('parallel slot acquired')
        finally:
            finish.set();worker.join(5)
        self.assertFalse(worker.is_alive());self.assertEqual(errors,[])
        with local.serial_build_slot(name):pass

    def test_controller_keeps_serial_slot_after_launcher_handle_closes(self):
        name='Local\\EliteSync-build-test-'+uuid.uuid4().hex
        controller=None
        try:
            with local.serial_build_slot(name) as handle:
                controller=local._start_controller(
                    [sys.executable,'-B','-c','import time; time.sleep(30)'],handle)
            self.assertIsNone(controller.poll())
            with self.assertRaisesRegex(RuntimeError,'already running'):
                with local.serial_build_slot(name):self.fail('live controller lost serial slot')
        finally:
            if controller is not None:
                controller.terminate();controller.wait(timeout=5)
        with local.serial_build_slot(name):pass

    def test_inheritance_reset_failure_stops_already_created_owned_controller(self):
        controller=unittest.mock.Mock()
        error=OSError('fixture inheritance reset failed')
        with patch.object(local.os,'set_handle_inheritable',side_effect=[None,error]),\
             patch.object(local.subprocess,'Popen',return_value=controller):
            with self.assertRaisesRegex(OSError,'inheritance reset failed'):
                local._start_controller(['fixture-controller'],123)
        controller.kill.assert_called_once_with()
        controller.wait.assert_called_once_with(timeout=45)

    def test_kind_selects_controller_and_result_binding_without_cross_acceptance(self):
        for kind,exe,status,key in [
            ('current-product-local-aar-producer','LocalAarProducer.exe','LOCAL_AAR_ROOT_EXIT0_REPOSITORY_UNVERIFIED','repository'),
            ('current-product-local-debug-host','LocalDebugHost.exe','LOCAL_DEBUG_HOST_ROOT_EXIT0_APK_UNVERIFIED','apk_output')]:
            for wrong in (False,True):
                with self.subTest(kind=kind,wrong=wrong),tempfile.TemporaryDirectory() as directory:
                    root=Path(directory);contract=self.case(root)
                    contract.update(kind=kind,output_bytes=100,host_seconds=20,sdk_seconds=10,cleanup_seconds=45)
                    contract[key]=str(root/'artifact')
                    (root/'control/run-contract.json').write_text(json.dumps(contract))
                    local.shared.put(root/'control/owner-grant.json',dict(authorized=True,max_attempts=1,
                        contract_sha256=local.shared.sha(root/'control/run-contract.json')))
                    proof=dict(nonce='fixture',status='WRONG' if wrong else status,root_exit=0,elapsed_ms=1)
                    proof[key]=contract[key]
                    def start(argv,**kwargs):
                        self.assertEqual(argv,[str(root/'control'/exe),'fixture'])
                        local.shared.put(root/'output/result.json',proof)
                        return type('Exited',(),{'pid':123,'returncode':0,'poll':lambda self:0})()
                    with patch.object(local,'preflight'),patch.object(local.subprocess,'Popen',side_effect=start),\
                         patch.object(local.shared,'output_size',return_value=0):
                        if wrong:
                            with self.assertRaisesRegex(ValueError,'result binding'):local.launch(root)
                        else:self.assertEqual(local.launch(root),proof)
                    self.assertTrue((root/'launch.claim.json').exists())

    def test_unknown_kind_rejected_before_grant_or_claim(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);contract=self.case(root);contract['kind']='arbitrary-command'
            (root/'control/run-contract.json').write_text(json.dumps(contract))
            with self.assertRaisesRegex(ValueError,'Unsupported'):local.launch(root)
            self.assertFalse((root/'launch.claim.json').exists())

    def test_interrupt_always_cleans_owned_controller_without_refunding_claim(self):
        class FakeController:
            pid=123
            returncode=None
            kills=0
            def poll(self):return self.returncode
            def wait(self,timeout):
                if self.returncode is None:raise subprocess.TimeoutExpired('fake-controller',timeout)
                return self.returncode
            def kill(self):self.kills+=1;self.returncode=-9
        for location in ['sample','sleep']:
            with self.subTest(location=location),tempfile.TemporaryDirectory() as directory:
                root=Path(directory);contract=self.case(root)
                contract.update(output_bytes=100,repository=str(root/'repo'),host_seconds=20,cleanup_seconds=45)
                (root/'control/run-contract.json').write_text(json.dumps(contract))
                local.shared.put(root/'control/owner-grant.json',dict(authorized=True,max_attempts=1,
                    contract_sha256=local.shared.sha(root/'control/run-contract.json'),fixture_only=True))
                controller=FakeController();interrupt=KeyboardInterrupt('fixture user interrupt')
                with patch.object(local,'preflight'),patch.object(local.subprocess,'Popen',return_value=controller),\
                     patch.object(local.shared,'output_size',side_effect=interrupt if location=='sample' else None,return_value=0),\
                     patch.object(local.time,'sleep',side_effect=interrupt):
                    with self.assertRaises(KeyboardInterrupt) as caught:local.launch(root)
                self.assertIs(caught.exception,interrupt)
                self.assertEqual(controller.kills,1)
                self.assertTrue((root/'launch.claim.json').exists())
                self.assertTrue((root/'output/host-stop.json').exists())
                self.assertTrue(json.loads((root/'STOP.json').read_bytes())['attempt_consumed'])

    def test_stop_receipt_failure_still_cleans_only_held_fake_controller(self):
        class FakeController:
            pid=123
            returncode=None
            kills=0
            def poll(self):return self.returncode
            def wait(self,timeout):
                if self.returncode is None:raise subprocess.TimeoutExpired('fake-controller',timeout)
                return self.returncode
            def kill(self):self.kills+=1;self.returncode=-9
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);contract=self.case(root)
            contract.update(binary_sha256='fixture',output_bytes=100,repository=str(root/'repo'),host_seconds=20,cleanup_seconds=45)
            (root/'control/run-contract.json').write_text(json.dumps(contract))
            local.shared.put(root/'control/owner-grant.json',dict(authorized=True,max_attempts=1,
                contract_sha256=local.shared.sha(root/'control/run-contract.json'),fixture_only=True))
            controller=FakeController();put=local.shared.put
            def fail_receipt(path,value):
                if Path(path)==root/'STOP.json':raise OSError('fixture disk error')
                put(path,value)
            with patch.object(local,'preflight'),patch.object(local.subprocess,'Popen',return_value=controller),\
                 patch.object(local.shared,'output_size',side_effect=RuntimeError('fixture sample failure')),\
                 patch.object(local.shared,'put',side_effect=fail_receipt):
                with self.assertRaises(ExceptionGroup):local.launch(root)
            self.assertEqual(controller.kills,1)
            self.assertTrue((root/'launch.claim.json').exists())
            self.assertTrue((root/'output/host-stop.json').exists())


class SourceOverlayWiringTests(unittest.TestCase):
    """Tiny materialization fixture; all SDK, compiler and inventory calls are fake."""
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.base=Path(self.temp.name);self.root=self.base/'candidate'
        self.inputs=self.base/'inputs';self.inputs.mkdir()
        self.source=self.base/'source';probe=self.source/'probe';probe.mkdir(parents=True)
        def write(path,value):path.write_text(json.dumps(value),encoding='utf-8')
        write(probe/'run-contract.json',dict(payload_sha256={},readonly_mappings=[
            dict(guest='C:/Inputs/PubPackages/fixture',host=str(self.base/'pub/fixture'))]))
        write(probe/'producer-entry.json',dict(source_identity={'source_commit':'a'*40}))
        write(self.inputs/'complete-declared-input-trees-private.json',dict(roots={},files=[]))
        for name in ['flutter-inventory.json','project-inventory.json','supplemental-sdk-inventory.json','project-package-graph.json']:
            write(probe/name,{})
        (probe/'producer-output.init.gradle').write_text('// fixture',encoding='utf-8')
        self.cmake=self.base/'cmake.json';write(self.cmake,dict(inventory={}))
        row=dict(path='apps/flutter_elitesync_module/lib/main.dart',status='M',
            content_b64=base64.b64encode(b'new\n').decode(),sha256=hashlib.sha256(b'new\n').hexdigest(),bytes=4,
            baseline_b64=base64.b64encode(b'old\n').decode(),baseline_sha256=hashlib.sha256(b'old\n').hexdigest(),baseline_bytes=4)
        manifest=dict(baseline_commit='a'*40,source_identity=dict(source_commit='b'*40,apps_tree='c'*40,services_tree='d'*40),files=[row])
        self.overlay=dict(manifest=manifest,manifest_sha256=hashlib.sha256(source_overlay._canonical(manifest)).hexdigest())
        args=['C:/fixture/java.exe','-PbuildNumber=old','--offline','assembleAarRelease']
        self.entry=dict(argv=args,launch_request=dict(command_line=subprocess.list2cmdline(args),
            cwd=str(self.root/'work/Project/apps/flutter_elitesync_module/.android'),environment={}),
            publication_version='old',source_identity={'source_commit':'a'*40},overlays={},
            output_init='// fixture',gradle_properties='org.gradle.jvmargs=-Xmx2048m\n')

    def copy_fixture(self,inventory,target,role=None):
        targets=[]
        if target.name=='Flutter':targets=['packages/flutter_tools/.dart_tool/package_config.json']
        if target.name=='Project':targets=['apps/flutter_elitesync_module/.dart_tool/package_config.json',
            'apps/flutter_elitesync_module/.flutter-plugins-dependencies','apps/flutter_elitesync_module/lib/main.dart']
        for name in targets:
            path=target/name;path.parent.mkdir(parents=True,exist_ok=True)
            path.write_bytes(b'old\n' if path.suffix=='.dart' else b'{}')
        if target.name=='Project':(target/'apps/flutter_elitesync_module/.android').mkdir()

    def patches(self):
        stack=ExitStack();self.addCleanup(stack.close)
        stack.enter_context(patch.object(local,'SOURCE_CONTRACT_SHA',local.shared.sha(self.source/'probe/run-contract.json')))
        stack.enter_context(patch.object(local,'DECLARED_SHA',local.shared.sha(self.inputs/'complete-declared-input-trees-private.json')))
        stack.enter_context(patch.object(local,'_copy_tree',side_effect=self.copy_fixture))
        stack.enter_context(patch.object(local,'render_local_entry',return_value=copy.deepcopy(self.entry)))
        stack.enter_context(patch.object(local,'current_user',return_value='fixture-user'))
        stack.enter_context(patch.dict('sys.modules',{'cmake_vc_candidate':types.SimpleNamespace(
            MATERIALIZATION=self.cmake,verify_private_tree=lambda:None)}))
        def compile_fixture(argv,**kwargs):
            Path(next(arg[5:] for arg in argv if arg.startswith('/out:'))).write_bytes(b'fixture exe, never executed')
            return subprocess.CompletedProcess(argv,0,b'',b'')
        stack.enter_context(patch.object(local.subprocess,'run',side_effect=compile_fixture))
        return stack

    def test_capture_failure_precedes_root_creation_and_any_copy(self):
        stack=self.patches()
        with patch.object(source_overlay,'capture_overlay',side_effect=ValueError('fixture dirty source')) as capture:
            with self.assertRaisesRegex(ValueError,'fixture dirty source'):
                local.prepare(self.root,self.inputs,self.source,current_source_root=self.base/'product')
        capture.assert_called_once_with(self.base/'product','a'*40)
        self.assertFalse(self.root.exists())

    def test_overlay_is_applied_retargeted_and_frozen_before_inventory(self):
        self.patches()
        def capture(root,baseline):
            self.assertFalse(self.root.exists());self.assertEqual(baseline,'a'*40)
            return self.overlay
        def inventory(**kwargs):
            self.assertEqual((self.root/'work/Project/apps/flutter_elitesync_module/lib/main.dart').read_bytes(),b'new\n')
            self.assertEqual(local._json(self.root/'control/source-overlay.json'),self.overlay)
            return dict(files=[],total_bytes=0)
        with patch.object(source_overlay,'capture_overlay',side_effect=capture),patch.object(local,'inventory_trees',side_effect=inventory):
            contract=local.prepare(self.root,self.inputs,self.source,current_source_root=self.base/'product')
        self.assertEqual(contract['source_identity'],self.overlay['manifest']['source_identity'])
        self.assertEqual(contract['base_identity'],self.entry['source_identity'])
        self.assertEqual(contract['source_overlay_manifest_sha256'],self.overlay['manifest_sha256'])
        self.assertEqual(contract['payload_sha256']['control/source-overlay.json'],local.shared.sha(self.root/'control/source-overlay.json'))
        self.assertIn(str(local.HERE/'current_product_source_overlay.py'),contract['host_helpers'])
        self.assertIn('-PbuildNumber='+contract['publication_version'],contract['launch_request']['command_line'])
        self.assertFalse((self.root/'control/owner-grant.json').exists())

    def test_default_prepare_has_no_source_overlay_fields_or_capture(self):
        self.patches()
        with patch.object(source_overlay,'capture_overlay',side_effect=AssertionError('default must not capture')) as capture,\
             patch.object(local,'inventory_trees',return_value=dict(files=[],total_bytes=0)):
            contract=local.prepare(self.root,self.inputs,self.source)
        capture.assert_not_called()
        self.assertEqual(contract['publication_version'],'old')
        self.assertEqual(contract['job_memory_bytes'],4*1024**3)
        self.assertEqual(contract['required_available_mib'],5120)
        self.assertIs(contract['serial_build'],True)
        self.assertIn(b'JobMemoryLimit=new UIntPtr(4UL*1024*1024*1024)',
                      (self.root/'control/local-boundary.cs').read_bytes())
        self.assertNotIn('base_identity',contract)
        self.assertNotIn('source_overlay_manifest_sha256',contract)
        self.assertFalse((self.root/'control/source-overlay.json').exists())
        self.assertNotIn(str(local.HERE/'current_product_source_overlay.py'),contract['host_helpers'])


if __name__=='__main__':unittest.main()
