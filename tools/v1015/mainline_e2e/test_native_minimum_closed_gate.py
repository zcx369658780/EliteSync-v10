import os,json,tempfile,unittest
from pathlib import Path
from unittest.mock import patch
from contracts import Gate
from current_native_task import validate_declared_os_edges,execution_gate,ROOT_NAME,TASK,PARENT


class MinimumClosureGate(unittest.TestCase):
    def test_missing_os_edge_list_rejected(self):
        with self.assertRaisesRegex(Gate,'EDGES_REQUIRED'):validate_declared_os_edges({},set(),set())
    def test_removed_api_edge_rejected(self):
        policy=dict(ordinary_import_paths=[dict(importer='kernel32.dll',target='ntdll.dll')],required_ordinary_imports=['kernel32.dll','ntdll.dll'])
        actual={('kernel32.dll','ntdll.dll'),('kernel32.dll','api-ms-inert-l1-1-0.dll')}
        with self.assertRaisesRegex(Gate,'EDGES_INCOMPLETE'):validate_declared_os_edges(policy,actual,{'kernel32.dll','ntdll.dll'})
    def test_removed_recursive_host_rejected(self):
        policy=dict(ordinary_import_paths=[dict(importer='kernel32.dll',target='ntdll.dll')],required_ordinary_imports=['kernel32.dll'])
        with self.assertRaisesRegex(Gate,'MODULE_SET_INCOMPLETE'):validate_declared_os_edges(policy,{('kernel32.dll','ntdll.dll')},{'kernel32.dll','ntdll.dll'})
    def test_exact_declared_edges_match_is_static_only(self):
        policy=dict(ordinary_import_paths=[dict(importer='kernel32.dll',target='ntdll.dll')],required_ordinary_imports=['kernel32.dll','ntdll.dll'])
        validate_declared_os_edges(policy,{('kernel32.dll','ntdll.dll')},{'kernel32.dll','ntdll.dll'})
    def test_phase_stop_rejects_before_any_system_read_or_process(self):
        with tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']) as tmp:
            root=Path(tmp)/ROOT_NAME;root.mkdir()
            rows=[dict(task_id='V1015_API_SET_RAW_FIRST_L12_E2E_20261030',task_blob=TASK,sole_parent=PARENT),dict(action='DYNAMIC_PHASE_STOP_AFTER_SCHEMA_BUDGET_EXHAUSTED')]
            (root/'execution_ledger.jsonl').write_text('\n'.join(json.dumps(x) for x in rows))
            with patch('ctypes.WinDLL',side_effect=AssertionError('NO_SYSTEM_API')),patch('central_vc_loader.verify_current',side_effect=AssertionError('NO_SYSTEM_READ')):
                with self.assertRaisesRegex(Gate,'ALREADY_STOPPED'):execution_gate(root,{}, {})

    def test_wrong_schema_system_path_rejected_before_file_read(self):
        from current_native_task import validate_api_set_closure
        from contracts import digest
        with tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']) as tmp:
            root=Path(tmp);(root/'raw').mkdir();raw=b'INERT';(root/'raw/schema.bin').write_bytes(raw)
            system=dict(path='C:/Windows/System32',file_id=1,volume=7)
            evidence=dict(file=dict(sha256=digest(raw),path='C:/INERT_PRIVATE/apisetschema.dll'),system_root=system)
            policy=dict(api_set_schema=dict(archived_relative_path='raw/schema.bin',sha256=digest(raw),signature_evidence=evidence))
            with patch('windows_os_trust.evaluate_file',return_value={}),patch('api_set_schema.parse_schema',return_value={}),patch('os_images.system_root_fact',return_value=system),patch('os_images.readonly_fact',side_effect=AssertionError('NO_FILE_READ')):
                with self.assertRaisesRegex(Gate,'CURRENT_PATH'):validate_api_set_closure(root,policy,dict(ordinary_edges=[]))

    def test_host_success_label_cannot_replace_actual_query_archive(self):
        from current_native_task import load_archived_queries
        with self.assertRaisesRegex(Gate,'QUERY_ARCHIVE_REQUIRED'):
            load_archived_queries(Path('C:/INERT'),dict(api_set_resolutions=[dict(hresult=0,host='kernelbase.dll')]))
    def test_query_archive_hash_swap_rejected(self):
        from current_native_task import load_archived_queries
        with tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']) as tmp:
            root=Path(tmp);(root/'raw').mkdir();p=root/'raw/query.json';p.write_bytes(b'[]');st=p.stat()
            receipt=dict(path='raw/query.json',file_id=st.st_ino,volume=st.st_dev,bytes=2,sha256='0'*64)
            with self.assertRaisesRegex(Gate,'QUERY_ARCHIVE_IDENTITY'):load_archived_queries(root,dict(api_set_query_archive=receipt))

    def test_missing_provider_and_pin_cannot_match_as_none(self):
        from current_native_task import validate_query_provider
        with self.assertRaisesRegex(Gate,'SOURCE_REQUIRED'):validate_query_provider({}, {})
    def test_query_provider_hash_must_match_real_pin(self):
        from current_native_task import validate_query_provider
        provider=dict(file_id=1,volume=7,bytes=100,links=2,sha256='a'*64,readonly_handle=True,path='C:/Windows/System32/kernelbase.dll',canonical_path='C:/Windows/System32/kernelbase.dll')
        pin=dict(provider,trust_schema=2,source_class='WINDOWS_SYSTEM_IMAGE',sha256='b'*64)
        with self.assertRaisesRegex(Gate,'SOURCE_CHANGED'):validate_query_provider(provider,pin)
    def test_private_query_provider_pin_cannot_replace_windows_source(self):
        from current_native_task import validate_query_provider
        with self.assertRaisesRegex(Gate,'SOURCE_REQUIRED'):validate_query_provider({},dict(trust_schema=2,source_class='TASK_PRIVATE_BINARY'))
