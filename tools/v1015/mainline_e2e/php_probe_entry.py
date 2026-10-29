"""Default inspect only. One specifically authorized DB-free PHP capability probe."""
import argparse,json,os,sys,ctypes
from pathlib import Path
from contracts import Gate,need,local,canonical,digest,NO_DB_TASK
from php_runtime import qualify_probe_config,launch_arguments,private_environment
from php_native import cli

def execution_gate(root,profile,grant):
    ledger=local(root/'execution_ledger.jsonl',root)
    rows=[json.loads(line) for line in ledger.read_bytes().splitlines()]
    need(rows and rows[0].get('task_id')=='V1015_NATIVE_UNBLOCK_THREE_ISSUES_20261029' and rows[0].get('task_blob')==NO_DB_TASK,'PROBE_LEDGER_TASK')
    need(not any('TERMINAL_STOP' in str(x.get('event','')) for x in rows),'PROBE_TASK_ALREADY_STOPPED')
    need(sum(x.get('event')=='PREPARE_PHP_DB_FREE_PROBE' for x in rows)<1,'PROBE_BUDGET_EXHAUSTED')
    need(os.name=='nt','WINDOWS_NATIVE_RUNTIME_REQUIRED')
    clock=ctypes.WinDLL('kernel32');clock.GetTickCount64.restype=ctypes.c_uint64
    need(0<=clock.GetTickCount64()-rows[0]['window_start_tick']<2700000,'PROBE_WINDOW_EXHAUSTED')
    proof=local(grant['legal_source_receipt'],root);raw=proof.read_bytes()
    need(digest(raw)==grant.get('legal_source_receipt_sha256'),'PROBE_LEGAL_SOURCE_RECEIPT')
    legal=json.loads(raw)
    need(legal.get('task_blob')==NO_DB_TASK and legal.get('status')=='LEGAL_SOURCE_AND_STATIC_ABI_QUALIFIED' and legal.get('owner_license_verified') is True,'PROBE_LEGAL_SOURCE_NOT_QUALIFIED')
    redist=[x for x in profile['manifest']['files'] if x['origin']=='TRUSTED_EXISTING_REDISTRIBUTABLE']
    need(redist and {x['sha256'] for x in redist}<=set(legal.get('qualified_binary_sha256',[])),'PROBE_REDISTRIBUTABLE_IDENTITY')
    need(sum(x.get('event')=='PREPARE_REDIST_COPY' for x in rows)==1,'PROBE_LEGAL_PRIVATE_COPY_REQUIRED')
    policy=profile['manifest'].get('windows_os_image_policy');need(isinstance(policy,dict),'OS_IMAGE_SOURCE_NOT_QUALIFIED')
    need(any(x.get('event')=='OS_BOUNDARY_OBSERVED' and x.get('policy_sha256')==digest(canonical(policy)) for x in rows),'PROBE_OS_BOUNDARY_NOT_OBSERVED')
    return ledger

def record(path,event,**values):
    with path.open('ab',buffering=0) as f:f.write(canonical(dict(event=event,**values))+b'\n');os.fsync(f.fileno())

def main(argv=None):
    parser=argparse.ArgumentParser();parser.add_argument('action',choices=['inspect','plan','execute'],nargs='?',default='inspect');parser.add_argument('--context');a=parser.parse_args(argv)
    if a.action=='inspect':
        print(json.dumps(dict(state='DB_FREE_PROBE_ENTRY_SOURCE_ONLY',runtime='PHP_PROBE_NOT_RUN',execute='NEW_EXPLICIT_TASK_GRANT_LEGAL_SOURCE_AND_NATIVE_BOUNDARY_REQUIRED')));return 0
    need(a.context is not None,'PROBE_CONTEXT_REQUIRED')
    ctx=json.loads(Path(a.context).read_bytes());c,g=ctx['config'],ctx['grant'];profile=qualify_probe_config(c,g);root=local(c['task_root'])
    if a.action=='plan':
        print(json.dumps(dict(state='STATIC_PRECONDITION_OK',live='PHP_PROBE_NOT_RUN',database='NOT_AUTHORIZED')));return 0
    ledger=execution_gate(root,profile,g)
    script=local(Path(c['source_root'])/'tests/E2E/php_runtime_probe.php',root)
    need(digest(script.read_bytes())==c['source_files']['tests/E2E/php_runtime_probe.php'],'PROBE_SOURCE_CHANGED')
    command=launch_arguments(profile,root)+[str(script)];env=private_environment(profile,root,os.environ['SystemRoot'])
    record(ledger,'PREPARE_PROBE_RAW_DIRECTORY',flushed_before_action=True);(root/'raw/driver').mkdir(parents=True,exist_ok=False)
    record(ledger,'PREPARE_PHP_DB_FREE_PROBE',number=1,limit=1,command_sha256=digest(canonical(command)),php_sha256=digest(Path(profile['executable']).read_bytes()),source_sha256=digest(script.read_bytes()),timeout=min(g['probe_seconds'],30),flushed_before_action=True)
    result=cli(profile,command,canonical(ctx),env,root,timeout=min(g['probe_seconds'],30))
    record(ledger,'PREPARE_PROBE_RESULT_FILES',flushed_before_action=True)
    (root/'raw/driver/probe.stdout').write_bytes(result.stdout);(root/'raw/driver/probe.stderr').write_bytes(result.stderr)
    record(ledger,'PHP_DB_FREE_PROBE_ENDED',exit=result.returncode,stdout_sha256=digest(result.stdout),stderr_sha256=digest(result.stderr))
    need(result.returncode==0,'PHP_DB_FREE_PROBE_FAILED')
    value=json.loads(result.stdout);need(value.get('state')=='CAPABILITIES_MATCHED_WITHOUT_LARAVEL' and value.get('laravel_bootstrap') is False and value.get('pdo_connection') is False,'PHP_PROBE_RESULT_SCOPE')
    print(json.dumps(dict(state='PHP_DB_FREE_PROBE_OBSERVED_UNDER_NEW_BOUNDARY',api_db='NOT_RUN',result=value)));return 0

if __name__=='__main__':
    try:sys.exit(main())
    except (Gate,KeyError,ValueError,OSError) as e:print(str(e),file=sys.stderr);sys.exit(1)
