"""Synthetic central-runtime facts only. No Windows observation or process start."""
import copy
import io
import json
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import patch
from contracts import Gate
from central_runtime_preconditions import check_central_file_facts, check_central_loaded_facts, CENTRAL_CLASS


class CentralRuntimeFacts(unittest.TestCase):
    def setUp(self):
        self.system = dict(path='C:/Windows/System32', volume=7,
                           from_system_directory_api=True, reparse=False)
        self.fact = dict(path='C:/Windows/System32/vcruntime140.dll',
                         canonical_path='C:/Windows/System32/vcruntime140.dll',
                         readonly_handle=True, reparse=False, links=1, volume=7,
                         file_id=11, bytes=4096, sha256='a'*64, architecture='x64',
                         file_version='14.51.36247.0')
        self.pin = dict(self.fact, source_class=CENTRAL_CLASS, module='vcruntime140.dll',
                        minimum_runtime_version='14.44.0.0',
                        minimum_compatibility_evidence_sha256='b'*64,
                        signature=dict(valid_offline_trust=True, microsoft_publisher_verified=True,
                                       certificate_sha256='c'*64, publisher_chain_evidence_sha256='d'*64))

    def check(self):
        return check_central_file_facts(self.fact, self.system, self.pin)

    def test_synthetic_static_match_is_not_php_abi_or_authority(self):
        result=self.check()
        self.assertFalse(result['runtime_authorized'])
        self.assertFalse(result['php_abi_observed'])

    def test_windows_os_or_private_class_is_not_central(self):
        for source in ('WINDOWS_SYSTEM_IMAGE', 'TASK_PRIVATE_BINARY'):
            self.pin['source_class']=source
            with self.assertRaisesRegex(Gate, 'SOURCE_CLASS'): self.check()

    def test_hardlink_even_inside_system_directory_rejected(self):
        self.fact['links']=self.pin['links']=2
        with self.assertRaisesRegex(Gate, 'LINK_OR_WRITE'): self.check()

    def test_reparse_or_write_handle_rejected(self):
        self.fact['reparse']=True
        with self.assertRaisesRegex(Gate, 'LINK_OR_WRITE'): self.check()
        self.fact['reparse']=False;self.fact['readonly_handle']=False
        with self.assertRaisesRegex(Gate, 'LINK_OR_WRITE'): self.check()

    def test_same_name_private_path_rejected(self):
        self.fact['path']=self.fact['canonical_path']=self.pin['path']='C:/INERT_PRIVATE/vcruntime140.dll'
        with self.assertRaisesRegex(Gate, 'SYSTEM_PATH'): self.check()

    def test_unknown_system_dll_rejected(self):
        self.fact['path']=self.fact['canonical_path']=self.pin['path']='C:/Windows/System32/unknown.dll'
        self.pin['module']='unknown.dll'
        with self.assertRaisesRegex(Gate, 'NAMED_MODULE'): self.check()

    def test_non_api_root_rejected(self):
        self.system['from_system_directory_api']=False
        with self.assertRaisesRegex(Gate, 'DIRECTORY_API'): self.check()

    def test_changed_hash_or_identity_rejected(self):
        self.fact['sha256']='e'*64
        with self.assertRaisesRegex(Gate, 'PIN_CHANGED'): self.check()
        self.fact['sha256']='a'*64;self.fact['file_id']=12
        with self.assertRaisesRegex(Gate, 'PIN_CHANGED'): self.check()

    def test_zero_size_or_boolean_file_identity_rejected(self):
        self.fact['bytes']=self.pin['bytes']=0
        with self.assertRaisesRegex(Gate, 'IDENTITY_REQUIRED'): self.check()
        self.fact['bytes']=self.pin['bytes']=4096;self.fact['file_id']=self.pin['file_id']=True
        with self.assertRaisesRegex(Gate, 'IDENTITY_REQUIRED'): self.check()

    def test_signature_display_name_alone_is_not_proof(self):
        self.pin['signature']=dict(valid_offline_trust=True, publisher='Microsoft Corporation')
        with self.assertRaisesRegex(Gate, 'SIGNATURE_CHAIN'): self.check()

    def test_missing_minimum_evidence_is_not_inferred_from_linker(self):
        self.pin['minimum_compatibility_evidence_sha256']=None
        with self.assertRaisesRegex(Gate, 'COMPILER_COMPATIBILITY'): self.check()

    def test_old_runtime_version_rejected(self):
        self.fact['file_version']=self.pin['file_version']='14.38.33126.1'
        with self.assertRaisesRegex(Gate, 'BELOW_PINNED'): self.check()

    def test_current_python_private_runtime_is_not_future_php_proof(self):
        process=dict(pid=7,creation=100,nonce='a'*32)
        loaded=dict(process=process,from_loaded_module_api=True,path='C:/INERT_PYTHON/vcruntime140.dll',sha256='a'*64,file_id=11,volume=7)
        with self.assertRaisesRegex(Gate, 'IMAGE_CHANGED'):check_central_loaded_facts(loaded,self.pin,process)

    def test_wrong_process_generation_rejected(self):
        expected=dict(pid=7,creation=100,nonce='a'*32)
        loaded=dict(process=dict(expected,creation=101),from_loaded_module_api=True,path=self.pin['path'],sha256='a'*64,file_id=11,volume=7)
        with self.assertRaisesRegex(Gate, 'PROCESS_GENERATION'):check_central_loaded_facts(loaded,self.pin,expected)

    def test_vcruntime_is_not_a_generic_os_import_exception(self):
        from php_runtime import os_import
        self.assertFalse(os_import('vcruntime140.dll'))

    def test_generic_os_fact_cannot_bypass_central_qualification(self):
        from os_images import validate_os_fact
        with self.assertRaisesRegex(Gate, 'CENTRAL_RUNTIME_REQUIRES_SEPARATE'):
            validate_os_fact(self.fact, {}, self.system)

    def test_default_inspect_cannot_observe_or_start_anything(self):
        import central_runtime_preconditions
        output=io.StringIO()
        with patch('subprocess.Popen',side_effect=AssertionError('NO_PROCESS')), patch('os_images.system_root_fact',side_effect=AssertionError('NO_OBSERVATION')), patch.object(Path,'write_bytes',side_effect=AssertionError('NO_WRITE')), redirect_stdout(output):
            central_runtime_preconditions.main()
        self.assertEqual('SOURCE_POLICY_REFERENCE_ONLY',json.loads(output.getvalue())['state'])
        self.assertEqual('NOT_RUN_GATE_CLOSED',json.loads(output.getvalue())['php'])


if __name__ == '__main__':
    unittest.main()
