"""Fault the actual current executor; only marked test-data journals receive simulated I/O errors."""
import os,sys,json,contextlib
from pathlib import Path
R=Path(os.environ['TASK_RUNTIME_ROOT']).resolve();sys.path.insert(0,str(R))
import owned as o
o.need(o.TASK=='V1015_FINAL_DEVICE_RTC_WS_H264_GATE_20261031','WRONG_EXECUTOR')
o.reserve('PREPARE_REAL_PREPARATION_IO_FAULT_TEST',{'executor_real_io_fault_batches':1},cases=9,scope='test-data journal copies only; authoritative ledger never receives an injected I/O failure')
target='executor/actual-io-revision-target.txt';o.write(target,b'UNCHANGED_OWN_TEST_RECORD');before=(R/target).read_bytes()
original_event=o.event;original_locked=o.locked;original_fsync=o.os.fsync;original_ledger=o.L;original_run=o.subprocess.run
calls=[];results=[]
def forbidden(*args,**kwargs):calls.append(1);raise AssertionError('UNPREPARED_PROCESS_DISPATCH')
for case in ['logger_type_error','actual_flush_error','actual_fsync_error']:
    for operation in ['write','revise','process']:
        # These are explicitly test data, never another task/attempt authority ledger.
        relative='executor/prepare-io-fixtures/'+case+'-'+operation+'.fixture'
        o.write(relative,b'');fixture=R/relative;stat=fixture.stat();seed=dict(o.rows()[0]);seed['ledger_identity']=[stat.st_dev,stat.st_ino];seed['simulated_io_test_data']=True
        o.revise(relative,(json.dumps(seed)+'\n').encode())
        o.reserve('PREPARE_ONE_IO_FAILURE_FIXTURE',case=case,operation=operation,test_data_path=relative,authority_ledger_unchanged_by_fault=True)
        reached=[]
        class FlushFault:
            def __init__(self,file):self.file=file
            def __getattr__(self,name):return getattr(self.file,name)
            def flush(self):reached.append('actual_event_flush');raise OSError('INJECTED_ACTUAL_FLUSH')
        @contextlib.contextmanager
        def flush_locked():
            with original_locked() as file:yield FlushFault(file)
        def fsync_fault(fd):
            if os.fstat(fd).st_ino==stat.st_ino:reached.append('actual_event_fsync');raise OSError('INJECTED_ACTUAL_FSYNC')
            return original_fsync(fd)
        def logger_fault(*args,**kwargs):reached.append('logger_entry');raise TypeError('INJECTED_LOGGER_TYPE_ERROR')
        o.L=fixture;o.subprocess.run=forbidden
        if case=='logger_type_error':o.event=logger_fault
        elif case=='actual_flush_error':o.locked=flush_locked
        else:o.os.fsync=fsync_fault
        try:
            try:
                if operation=='write':o.write('executor/forbidden-io-dir/'+case+'-'+operation+'.txt',b'forbidden')
                elif operation=='revise':o.revise(target,b'forbidden')
                else:o.run('forbidden-process',[sys.executable,'-c','print(1)'])
            except (TypeError,OSError) as error:
                if not str(error).startswith('INJECTED_'):raise
            else:raise AssertionError('PREPARE_FAILURE_DID_NOT_BLOCK_OPERATION')
        finally:
            o.event=original_event;o.locked=original_locked;o.os.fsync=original_fsync;o.L=original_ledger;o.subprocess.run=original_run
        o.need(len(reached)==1 and not calls and (R/target).read_bytes()==before and not(R/'executor/forbidden-io-dir').exists(),'FAIL_CLOSED_SIDE_EFFECT')
        results.append({'case':case,'operation':operation,'actual_fault_site':reached[0],'mutation_blocked':True})
o.jwrite('executor/actual-prepare-io-fail-closed-test.json',{'cases':results,'unprepared_target_writes':0,'unprepared_process_dispatches':0,'authority_ledger_received_simulated_io_failure':False,'test_journals':'marked .fixture data only, not executable task ledgers or budgets','actual_executor_sha256':o.sha((R/'owned.py').read_bytes()),'test_source_sha256':o.sha(Path(__file__).read_bytes()),'old_prepare_gap_retroactively_closed':False})
print(json.dumps({'negative_operations':len(results),'real_flush_cases':3,'real_fsync_cases':3,'unprepared_mutations':0}))
