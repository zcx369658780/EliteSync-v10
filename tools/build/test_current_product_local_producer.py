import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import current_product_local_producer as local
from current_product_tree_inventory import inventory_trees


class LocalProducerTests(unittest.TestCase):
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
        contract=dict(host_root=str(root.resolve()),nonce='fixture',payload_sha256={},host_helpers={})
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


if __name__=='__main__':unittest.main()
