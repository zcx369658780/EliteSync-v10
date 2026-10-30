"""Synthetic trust/import contracts only; never reads Windows files or calls APIs."""
import copy,unittest
from unittest.mock import patch
from contracts import Gate
from windows_os_trust import evaluate_file,evaluate_signature,CHAIN_FLAGS,WVT_FLAGS,CODE_SIGNING,TIME_STAMPING
from minimal_imports import minimum_private_graph


def signed():
    policies={k:dict(api_ok=True,error=0,oid=o,flags=f) for k,o,f in [('authenticode',2,0),('microsoft_application',7,0x20000),('microsoft_product',7,0)]}
    signer=dict(provider_error=0,provider_chain_error=0,chain_api_ok=True,chain_error=0,chain_flags=CHAIN_FLAGS,eku=[CODE_SIGNING],eku_api_ok=True,verify_as_of=130000000000000000,verify_time_from_wintrust_provider=True,policies=policies)
    stamp=dict(signer_type=0x10,provider_error=0,provider_chain_error=0,chain_api_ok=True,chain_error=0,chain_flags=CHAIN_FLAGS,eku_api_ok=True,eku=[TIME_STAMPING],verify_as_of=130000000000000000,verify_time_from_wintrust_provider=True,policies=dict(timestamp=dict(api_ok=True,error=0,oid=3,flags=0,registry_policy_flags=0)))
    return dict(provider_flags=WVT_FLAGS,online_retrieval=False,status=0,signer=signer,counter_signers=1,timestamps=[stamp])


def catalog_fixture():
    file=dict(path='C:/Windows/System32/normaliz.dll',canonical_path='C:/Windows/System32/normaliz.dll',readonly_handle=True,reparse=False,sha256='a'*64,file_id=11,volume=7,bytes=100,links=2)
    catfile=dict(file,path='C:/Windows/System32/CatRoot/INERT/catalog.cat',canonical_path='C:/Windows/System32/CatRoot/INERT/catalog.cat',file_id=12,sha256='b'*64)
    cat=dict(file=catfile,catalog_identity_stable=True,member_identity_stable=True,member_identity={k:file[k] for k in ['sha256','file_id','volume','bytes']},hash_algorithm='SHA256',member_hash='c'*64,member_tag='C'*64,calculated_hash_matches_query=True,wintrust_member_hash='c'*64,wintrust_member_tag='C'*64,signature=signed())
    return dict(file=file,source_class='WINDOWS_SYSTEM_IMAGE',system_root=dict(path='C:/Windows/System32',volume=7,from_system_directory_api=True),identity_stable=True,embedded=dict(status=0x800b0100),catalogs=[cat])


class CatalogTrustContracts(unittest.TestCase):
    def setUp(self):self.v=catalog_fixture();self.c=self.v['catalogs'][0]
    def reject(self):
        with self.assertRaises(Gate):evaluate_file(self.v)
    def test_catalog_member_and_timestamp_input_matches_only(self):self.assertEqual('CATALOG_MEMBER_AUTHENTICODE',evaluate_file(self.v)['method'])
    def test_embedded_signature_is_independent_of_catalog(self):
        self.v['embedded']=signed();self.v['catalogs']=[]
        self.assertEqual('EMBEDDED_AUTHENTICODE',evaluate_file(self.v)['method'])
    def test_no_signature_not_pass(self):self.v['catalogs']=[];self.reject()
    def test_wrong_catalog_member_hash(self):self.c['member_hash']='d'*64;self.reject()
    def test_wrong_member_tag(self):self.c['member_tag']='D'*64;self.reject()
    def test_missing_calculated_member_relationship(self):self.c['calculated_hash_matches_query']=False;self.reject()
    def test_catalog_swap(self):self.c['catalog_identity_stable']=False;self.reject()
    def test_member_swap(self):self.c['member_identity_stable']=False;self.reject()
    def test_file_swap(self):self.v['identity_stable']=False;self.reject()
    def test_member_file_id_swap(self):self.c['member_identity']['file_id']=13;self.reject()
    def test_wrong_system_path(self):self.v['file']['path']='C:/INERT_PRIVATE/normaliz.dll';self.reject()
    def test_catalog_outside_system_store(self):self.c['file'].update(path='C:/INERT_PRIVATE/catalog.cat',canonical_path='C:/INERT_PRIVATE/catalog.cat');self.reject()
    def test_private_same_name(self):self.v['source_class']='TASK_PRIVATE_BINARY';self.reject()
    def test_reparse_catalog(self):self.c['file']['reparse']=True;self.reject()
    def test_chain_failure(self):self.c['signature']['signer']['chain_error']=1;self.reject()
    def test_revocation_unknown(self):self.c['signature']['signer']['chain_error']=0x1000040;self.reject()
    def test_wrong_code_signing_eku(self):self.c['signature']['signer']['eku']=[TIME_STAMPING];self.reject()
    def test_wrong_code_policy(self):self.c['signature']['signer']['policies']['authenticode']['oid']=1;self.reject()
    def test_fake_microsoft_display_name(self):self.c['signature']['display_name']='Microsoft Corporation';self.c['signature']['status']=0x800b0109;self.reject()
    def test_missing_trusted_time(self):self.c['signature']['signer']['verify_time_from_wintrust_provider']=False;self.reject()
    def test_expired_without_valid_timestamp(self):self.c['signature']['counter_signers']=0;self.c['signature']['timestamps']=[];self.c['signature']['signer']['chain_error']=1;self.reject()
    def test_timestamp_chain_expired(self):self.c['signature']['timestamps'][0]['chain_error']=1;self.reject()
    def test_timestamp_wrong_eku(self):self.c['signature']['timestamps'][0]['eku']=[CODE_SIGNING];self.reject()
    def test_timestamp_policy_ignore_flags(self):self.c['signature']['timestamps'][0]['policies']['timestamp']['registry_policy_flags']=1;self.reject()
    def test_timestamp_error(self):self.c['signature']['timestamps'][0]['policies']['timestamp']['error']=1;self.reject()
    def test_timestamp_missing(self):self.c['signature']['timestamps']=[];self.reject()
    def test_disabled_revocation(self):self.c['signature']['signer']['chain_flags']=0;self.reject()
    def test_unsupported_catalog_is_not_pass(self):self.c['signature']['status']='VERIFY_CATALOG_UNSUPPORTED';self.reject()


class MinimalImports(unittest.TestCase):
    def test_optional_delay_not_a_mandatory_prestart_dependency(self):
        with patch('minimal_imports.pe_info',return_value=dict(ordinary_imports=['kernel32.dll'],delay_imports=['iphlpapi.dll'])):
            graph=minimum_private_graph({'php.exe':b'INERT'},['php.exe'])
        self.assertEqual({'kernel32.dll':['php.exe','kernel32.dll']},graph['mandatory_os'])
        self.assertEqual('OPTIONAL_DELAY_NOT_OBSERVED_LOADED',graph['optional_delay'][0]['kind'])
        self.assertEqual('NOT_RUN',graph['actual_loaded_modules'])
    def test_unknown_private_import_refused(self):
        with patch('minimal_imports.pe_info',return_value=dict(ordinary_imports=['unknown.dll'],delay_imports=[])):
            with self.assertRaisesRegex(Gate,'PRIVATE_DEPENDENCY'):minimum_private_graph({'php.exe':b'INERT'},['php.exe'])
    def test_actual_unknown_loaded_module_still_rejected(self):
        from test_native_unblock import OsImageContracts
        case=OsImageContracts('test_unknown_module_rejected');case.setUp()
        case.policy['images']={}
        with self.assertRaises(Gate):case.check()
