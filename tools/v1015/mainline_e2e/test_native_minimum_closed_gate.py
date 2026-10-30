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
            rows=[dict(task_id='V1015_OS_CATALOG_MINIMAL_IMPORT_L12_E2E_20261030',task_blob=TASK,sole_parent=PARENT),dict(action='DYNAMIC_PHASE_STOP_AFTER_OS_BUDGET_EXHAUSTED')]
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
