"""Pre-observation synthetic trust and real-loader branch tests. No OS capture."""
import copy
import unittest
from pathlib import Path
from unittest.mock import patch
from contracts import Gate, canonical, digest
from windows_vc_trust import evaluate_trust, CODE_SIGNING, CHAIN_FLAGS, WVT_FLAGS, MICROSOFT_APPLICATION_ROOT
from central_vc_loader import validate_snapshot, verify_current, check_loaded_receipt


def trust_fixture():
    return dict(schema=1,identity_stable=True,online_retrieval=False,
                winverifytrust=dict(status=0,provider_flags=WVT_FLAGS),
                chain=dict(api_ok=True,error_status=0,flags=CHAIN_FLAGS,certificate_count=3),
                leaf_eku_api_ok=True,leaf_eku=[CODE_SIGNING],
                policies={k:dict(api_ok=True,error=0,flags=f,policy_oid=o) for k,o,f in [('authenticode',2,0),('microsoft_root',7,MICROSOFT_APPLICATION_ROOT)]})


def snapshot_fixture():
    trust=trust_fixture();root=dict(path='C:/Windows/System32',file_id=10,volume=7,from_system_directory_api=True,reparse=False)
    file=dict(path=root['path']+'/vcruntime140.dll',canonical_path=root['path']+'/vcruntime140.dll',
              readonly_handle=True,links=1,reparse=False,architecture='x64',file_id=20,volume=7,bytes=178616,
              sha256='d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7',file_version='14.51.36247.0')
    return dict(schema=1,source_class='MICROSOFT_CENTRAL_V14_RUNTIME',module='vcruntime140.dll',
                system_root=root,file=file,trust=trust,trust_evidence_sha256=digest(canonical(trust)),
                qualification=evaluate_trust(trust))


class WindowsChainContracts(unittest.TestCase):
    def setUp(self):self.value=trust_fixture()
    def test_different_display_names_and_ca_rotation_are_metadata_only(self):
        for label in ['Microsoft Corporation','Microsoft Windows Software Compatibility Publisher','New Publisher Display']:
            self.value['display_name']=label;self.value['issuer']='ROTATED_CA'
            self.assertEqual('CENTRAL_VC_EVIDENCE_QUALIFIED',evaluate_trust(self.value)['state'])
    def test_fake_microsoft_name_does_not_override_failed_authenticode(self):
        self.value['display_name']='Microsoft Corporation';self.value['winverifytrust']['status']=0x800b0100
        with self.assertRaisesRegex(Gate,'AUTHENTICODE'):evaluate_trust(self.value)
    def test_api_true_with_policy_error_is_not_pass(self):
        self.value['policies']['microsoft_root']['error']=0x800b0109
        with self.assertRaisesRegex(Gate,'MICROSOFT_ROOT'):evaluate_trust(self.value)
    def test_unsupported_policy_is_not_pass(self):
        self.value['policies']['microsoft_root']['api_ok']=False
        with self.assertRaisesRegex(Gate,'MICROSOFT_ROOT'):evaluate_trust(self.value)
    def test_wrong_root_policy_or_test_root_flags_rejected(self):
        for flags in [0,0x10000,0x30000,0x20010]:
            self.value['policies']['microsoft_root']['flags']=flags
            with self.assertRaisesRegex(Gate,'MICROSOFT_ROOT'):evaluate_trust(self.value)
    def test_wrong_policy_oid_rejected(self):
        self.value['policies']['microsoft_root']['policy_oid']=1
        with self.assertRaisesRegex(Gate,'MICROSOFT_ROOT'):evaluate_trust(self.value)
    def test_wrong_eku_rejected(self):
        self.value['leaf_eku']=['1.3.6.1.5.5.7.3.1']
        with self.assertRaisesRegex(Gate,'EKU'):evaluate_trust(self.value)
    def test_cached_revocation_unknown_rejected(self):
        self.value['chain']['error_status']=0x01000040
        with self.assertRaisesRegex(Gate,'REVOCATION_UNKNOWN'):evaluate_trust(self.value)
    def test_revocation_checks_cannot_be_disabled_to_pass(self):
        self.value['winverifytrust']['provider_flags']=0x1010
        with self.assertRaisesRegex(Gate,'POLICY_CHANGED'):evaluate_trust(self.value)
    def test_missing_chain_and_identity_change_rejected(self):
        self.value['identity_stable']=False
        with self.assertRaisesRegex(Gate,'FILE_BINDING'):evaluate_trust(self.value)
        self.value['identity_stable']=True;self.value['chain']['certificate_count']=0
        with self.assertRaisesRegex(Gate,'INCOMPLETE'):evaluate_trust(self.value)
    def test_authenticode_policy_error_rejected(self):
        self.value['policies']['authenticode']['error']=1
        with self.assertRaisesRegex(Gate,'AUTHENTICODE'):evaluate_trust(self.value)


class CentralLoaderContracts(unittest.TestCase):
    def setUp(self):self.s=snapshot_fixture()
    def test_frozen_synthetic_snapshot_is_not_abi_proof(self):
        validate_snapshot(self.s)
        self.assertEqual('NOT_PROVEN_UNTIL_CONTROLLED_LOAD',self.s['qualification']['php_abi'])
    def test_wrong_source_hash_or_version_rejected(self):
        for key,value in [('sha256','0'*64),('file_version','14.38.33126.1')]:
            s=copy.deepcopy(self.s);s['file'][key]=value
            with self.assertRaisesRegex(Gate,'FROZEN_SOURCE'):validate_snapshot(s)
    def test_private_and_os_source_classes_rejected(self):
        for value in ['TASK_PRIVATE_BINARY','WINDOWS_SYSTEM_IMAGE']:
            self.s['source_class']=value
            with self.assertRaisesRegex(Gate,'CLASS'):validate_snapshot(self.s)
    def test_hardlink_and_alias_rejected(self):
        self.s['file']['links']=2
        with self.assertRaisesRegex(Gate,'FILE'):validate_snapshot(self.s)
        self.s['file']['links']=1;self.s['file']['canonical_path']='C:/INERT_PRIVATE/vcruntime140.dll'
        with self.assertRaisesRegex(Gate,'PATH'):validate_snapshot(self.s)
    def test_chain_receipt_tamper_rejected(self):
        self.s['trust_evidence_sha256']='0'*64
        with self.assertRaisesRegex(Gate,'RECEIPT_HASH'):validate_snapshot(self.s)
    def test_real_file_verifier_rejects_replacement(self):
        fact=dict(self.s['file']);fact['file_id']=21
        with patch('central_vc_loader.system_root_fact',return_value=self.s['system_root']),patch('central_vc_loader.readonly_fact',return_value=fact):
            with self.assertRaisesRegex(Gate,'REPLACED'):verify_current(self.s)
    def test_root_replacement_rejected_before_file_read(self):
        with patch('central_vc_loader.system_root_fact',return_value=dict(self.s['system_root'],file_id=12)),patch('central_vc_loader.readonly_fact',side_effect=AssertionError('NO_READ')):
            with self.assertRaisesRegex(Gate,'ROOT_REPLACED'):verify_current(self.s)
    def test_wrong_loaded_path_rejected_before_private_file_read(self):
        with patch('central_vc_loader.system_root_fact',return_value=self.s['system_root']),patch('central_vc_loader.readonly_fact',side_effect=AssertionError('NO_READ')):
            with self.assertRaisesRegex(Gate,'WRONG_PATH'):verify_current(self.s,'C:/INERT_PRIVATE/vcruntime140.dll')
    def test_loaded_receipt_identity_or_class_changed_rejected(self):
        image=dict(self.s['file'],source_class='TASK_PRIVATE_BINARY',trust_evidence_sha256=self.s['trust_evidence_sha256'])
        with self.assertRaisesRegex(Gate,'SOURCE_CLASS'):check_loaded_receipt(image,self.s)
        image['source_class']='MICROSOFT_CENTRAL_V14_RUNTIME';image['file_id']=25
        with self.assertRaisesRegex(Gate,'MISMATCH'):check_loaded_receipt(image,self.s)
    def test_import_branch_uses_central_pin_not_generic_os_import(self):
        import test_php_runtime
        f=test_php_runtime.PhpRuntimeContracts('test_valid_frozen_inert_manifest_is_static_only');f.setUp()
        try:
            data=test_php_runtime.inert_pe(['php8.dll','vcruntime140.dll']);(f.runtime/'bin/php.exe').write_bytes(data)
            f.manifest['files'][0].update(sha256=digest(data),source_sha256=digest(data));f.policy['reference_executable_sha256']=digest(data)
            f.manifest['requirements_sha256']=digest(canonical(f.policy))
            with self.assertRaisesRegex(Gate,'CENTRAL_RUNTIME_QUALIFICATION'):f.validate()
            f.manifest['central_runtime']=self.s
            with patch('php_runtime.verify_current',return_value={}):self.assertEqual('STATIC_PRECONDITION_OK',f.validate()['state'])
            from php_runtime import os_import
            self.assertFalse(os_import('vcruntime140.dll'))
        finally:f.doCleanups()
    def test_module_capture_routes_central_before_generic_os(self):
        import os_images
        identity=dict(pid=7,creation=10,running=True)
        image=dict(self.s['file'],source_class='MICROSOFT_CENTRAL_V14_RUNTIME')
        with patch('os_images.process_identity',return_value=identity),patch('os_images.system_root_fact',return_value=self.s['system_root']),patch('os_images.loaded_module_paths',return_value=[self.s['file']['path']]),patch('central_vc_loader.verify_current',return_value=image) as verify,patch('os_images.validate_os_fact',side_effect=AssertionError('WRONG_CLASS')):
            found,_=os_images.image_map(7,7,None,1,self.s)
        self.assertEqual([image],found);verify.assert_called_once_with(self.s,self.s['file']['path'])


if __name__=='__main__':unittest.main()
