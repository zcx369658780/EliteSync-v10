"""Real private persistence + mocked system reads; no actual OS-source query."""
import ctypes,hashlib,json,os,tempfile,unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import Mock,patch
from contracts import Gate,digest
from durable_evidence import Journal,TASK,PARENT,TASK_ID,ROOT_NAME,tick
import schema_capture_entry


class DurableSchemaEntry(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(dir=os.environ['ELITESYNC_SELFTEST_ROOT']);self.addCleanup(self.tmp.cleanup)
        self.root=Path(self.tmp.name)/ROOT_NAME;self.root.mkdir();(self.root/'raw').mkdir();(self.root/'prior').mkdir()
        st=self.root.stat();first=dict(seq=1,task_id=TASK_ID,task_blob=TASK,sole_parent=PARENT,attempt_id='attempt-0001',tick_start=tick(),workspace=dict(file_id=st.st_ino,volume=st.st_dev))
        (self.root/'execution_ledger.jsonl').write_text(json.dumps(first)+'\n');self.j=Journal(self.root)
    def test_exclusive_fsync_directory_flush_and_readback(self):
        receipt=self.j.bytes('raw/inert.bin',b'INERT_RAW')
        self.assertTrue(receipt['file_fsync'] and receipt['directory_flush'] and receipt['readback_verified'])
        self.assertEqual(digest(b'INERT_RAW'),receipt['sha256'])
    def test_existing_input_cannot_be_overwritten(self):
        self.j.bytes('raw/inert.bin',b'ORIGINAL')
        with self.assertRaises(FileExistsError):self.j.bytes('raw/inert.bin',b'REPLACEMENT')
        self.assertEqual(b'ORIGINAL',(self.root/'raw/inert.bin').read_bytes())
    def test_directory_flush_failure_retains_first_bytes(self):
        with patch('durable_evidence.flush_directory',side_effect=OSError('FSYNC_DIRECTORY_FAILED')):
            with self.assertRaises(OSError):self.j.bytes('raw/inert.bin',b'ORIGINAL')
        self.assertEqual(b'ORIGINAL',(self.root/'raw/inert.bin').read_bytes())
    def test_workspace_swap_rejected_before_write(self):
        self.j.workspace=dict(file_id=0,volume=0)
        with self.assertRaisesRegex(Gate,'WORKSPACE_REPLACED'):self.j.bytes('raw/inert.bin',b'INERT')
        self.assertFalse((self.root/'raw/inert.bin').exists())
    def test_readback_mismatch_not_reported_as_archived(self):
        original=Path.read_bytes
        def read(path):return b'WRONG' if path.name=='inert.bin' else original(path)
        with patch.object(Path,'read_bytes',read):
            with self.assertRaisesRegex(Gate,'READBACK_MISMATCH'):self.j.bytes('raw/inert.bin',b'ORIGINAL')
        self.assertEqual(b'ORIGINAL',(self.root/'raw/inert.bin').read_bytes())
    def test_raw_namespace_escape_rejected(self):
        with self.assertRaises(Gate):self.j.bytes('../outside.bin',b'INERT')
    def test_observation_attempts_cannot_restart_budget(self):
        self.assertEqual(1,self.j.reserve_observation());self.assertEqual(2,self.j.reserve_observation())
        with self.assertRaisesRegex(Gate,'BUDGET'):Journal(self.root).reserve_observation()
    def run_failed_entry(self,mode):
        from ctypes import wintypes as w
        raw=b'EXACT_INVALID_SCHEMA_FROM_MOCK_SOURCE';system=dict(path='C:/Windows/System32',file_id=1,volume=7)
        fact=dict(path=system['path']+'/apisetschema.dll',canonical_path=system['path']+'/apisetschema.dll',sha256=digest(raw),bytes=len(raw),file_id=2,volume=7,links=1,readonly_handle=True,reparse=False)
        expected=dict(file=fact,system_root=system);p=self.root/'prior/schema.json';p.write_text(json.dumps(expected));c=dict(task_root=str(self.root),expected_schema=str(p))
        kernel=SimpleNamespace(CreateFileW=Mock(return_value=11),CloseHandle=Mock())
        reads=[raw,b'']
        def read(handle,buf,size,count,overlapped):
            data=reads.pop(0);ctypes.memmove(buf,data,len(data));count._obj.value=len(data);return True
        kernel.ReadFile=read
        signature=dict(file=fact,system_root=system)
        with patch('schema_capture_entry.context',return_value=(c,{},self.j)),patch('schema_capture_entry.system_root_fact',return_value=system),patch('schema_capture_entry._api',return_value=(kernel,None,w)),patch('schema_capture_entry.readonly_fact',return_value=fact),patch('schema_capture_entry.capture_named',side_effect=Gate('SIGNATURE_DENIED') if mode=='signature' else None,return_value=signature),patch('schema_capture_entry.evaluate_file',return_value={}):
            result=schema_capture_entry.observe({})
        self.assertEqual(1,result['exit']);self.assertEqual(raw,(self.root/'raw/schema-1-input-LOCAL_ONLY.bin').read_bytes())
        self.assertTrue((self.root/'raw/schema-1-failure-LOCAL_ONLY.txt').is_file())
        rows=self.j.rows();archived=next(i for i,x in enumerate(rows) if x.get('action')=='RAW_DURABLY_ARCHIVED')
        if mode=='parse':self.assertLess(archived,next(i for i,x in enumerate(rows) if x.get('action')=='PREPARE_ARCHIVED_SCHEMA_PARSE'))
        kernel.CloseHandle.assert_called_once_with(11)
    def test_real_entry_parser_failure_preserves_raw_and_stack(self):self.run_failed_entry('parse')
    def test_real_entry_signature_failure_preserves_raw_and_stack(self):self.run_failed_entry('signature')
    def test_default_inspect_has_no_journal_or_observation(self):
        with patch('schema_capture_entry.Journal',side_effect=AssertionError('NO_ROOT_READ')),patch('schema_capture_entry.capture_named',side_effect=AssertionError('NO_SYSTEM_OBSERVATION')):
            self.assertEqual(0,schema_capture_entry.main([]))

    def test_partial_source_read_failure_archives_prefix_before_refusal(self):
        from ctypes import wintypes as w
        prefix=b'ACTUAL_PREFIX';calls=[True,False]
        fact=dict(bytes=100,sha256='a'*64)
        k=SimpleNamespace(CreateFileW=Mock(return_value=11),CloseHandle=Mock())
        def read(handle,buf,size,count,overlapped):
            ok=calls.pop(0)
            if ok:ctypes.memmove(buf,prefix,len(prefix));count._obj.value=len(prefix)
            return ok
        k.ReadFile=read
        with patch('schema_capture_entry._api',return_value=(k,None,w)),patch('schema_capture_entry.readonly_fact',return_value=fact):
            with self.assertRaisesRegex(Gate,'SOURCE_READ'):
                schema_capture_entry.read_and_archive(self.j,Path('C:/Windows/System32/apisetschema.dll'),'raw/input.bin')
        self.assertEqual(prefix,(self.root/'raw/input.bin.partial').read_bytes())
        self.assertFalse((self.root/'raw/input.bin').exists())
        meta=json.loads((self.root/'raw/input.bin.partial.json').read_bytes())
        self.assertTrue(meta['partial']);self.assertFalse(meta['complete'])
    def test_critical_enforcement_and_requirements_cannot_be_omitted(self):
        from datetime import datetime,timedelta,timezone
        from contracts import canonical
        now=datetime.now(timezone.utc)
        names={'schema_capture_entry.py','durable_evidence.py','api_set_schema.py','pe_dependencies.py','windows_os_trust.py','os_images.py','central_vc_loader.py','windows_vc_trust.py','minimal_imports.py','contracts.py','php_runtime.py','migration_contract.py','php_requirements.json'}
        j=SimpleNamespace(root=self.root,rows=lambda:[dict(time=(now-timedelta(minutes=1)).isoformat())])
        for omitted in ['contracts.py','php_requirements.json']:
            c=dict(task_root=str(self.root),source_binding=schema_capture_entry.BINDING,tool_sources={x:'0'*64 for x in names-{omitted}})
            g=dict(owner_authorized=True,task_blob=TASK,action='api_set_raw_first_observation',source_binding=schema_capture_entry.BINDING,config_sha256=digest(canonical(c)),not_before=(now-timedelta(minutes=1)).isoformat(),expires_at=(now+timedelta(minutes=1)).isoformat())
            with patch('schema_capture_entry.Journal',return_value=j):
                with self.assertRaisesRegex(Gate,'TOOL_CLOSURE'):schema_capture_entry.context(dict(config=c,grant=g))

    def test_growth_beyond_source_limit_still_archives_entire_read_prefix(self):
        from ctypes import wintypes as w
        block=b'Z'*1048576;fact=dict(bytes=16*1048576,sha256='a'*64)
        k=SimpleNamespace(CreateFileW=Mock(return_value=11),CloseHandle=Mock())
        def read(handle,buf,size,count,overlapped):ctypes.memmove(buf,block,len(block));count._obj.value=len(block);return True
        k.ReadFile=read
        with patch('schema_capture_entry._api',return_value=(k,None,w)),patch('schema_capture_entry.readonly_fact',return_value=fact):
            with self.assertRaisesRegex(Gate,'SOURCE_GREW'):
                schema_capture_entry.read_and_archive(self.j,Path('C:/Windows/System32/apisetschema.dll'),'raw/growing.bin')
        self.assertEqual(17*1048576,(self.root/'raw/growing.bin.partial').stat().st_size)
        self.assertEqual(digest(block*17),digest((self.root/'raw/growing.bin.partial').read_bytes()))
