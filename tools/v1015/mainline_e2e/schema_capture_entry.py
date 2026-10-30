"""Real task-bound raw-first schema observation. Default inspect is inert.

Raw bytes are exclusively created, fsynced, directory-flushed and read back by
Journal BEFORE parsing. No external persistence callback is accepted here.
"""
import argparse,ctypes,json,sys,traceback
from datetime import datetime,timedelta,timezone
from pathlib import Path
from contracts import need,local,digest,canonical
from durable_evidence import Journal,TASK,PARENT,ROOT_NAME
from os_images import _api,readonly_fact,system_root_fact,norm,validate_os_source
from central_vc_loader import validate_snapshot,verify_current
from windows_os_trust import capture_named,evaluate_file
from windows_vc_trust import file_version
from api_set_schema import parse_schema,resolve
from pe_dependencies import pe_info
from minimal_imports import minimum_private_graph
from api_set_query import BoundQuery
from native_closure import build as build_native_closure

BINDING=dict(commit=PARENT,apps_tree='8cd9b6df8e744c8fc9d4217412edce31795a318d',services_tree='bc44baa6f04ce57a8a6dc331be12c67a79e6e0da')


def context(value):
    c,g=value['config'],value['grant'];j=Journal(c['task_root'])
    need(g.get('owner_authorized') is True and g.get('task_blob')==TASK and g.get('action')=='api_set_raw_first_observation','SCHEMA_OWNER_SCOPE')
    need(c.get('source_binding')==g.get('source_binding')==BINDING,'SCHEMA_SOURCE_BINDING')
    need(digest(canonical(c))==g.get('config_sha256'),'SCHEMA_CONTEXT_CHANGED')
    need(datetime.fromisoformat(g['not_before'])<=datetime.now(timezone.utc)<datetime.fromisoformat(g['expires_at']),'SCHEMA_GRANT_EXPIRED')
    start=datetime.fromisoformat(j.rows()[0]['time']);need(datetime.fromisoformat(g['expires_at'])<=start+timedelta(seconds=7200),'SCHEMA_GRANT_WINDOW')
    required={'schema_capture_entry.py','durable_evidence.py','api_set_schema.py','pe_dependencies.py','windows_os_trust.py','os_images.py','central_vc_loader.py','windows_vc_trust.py','minimal_imports.py','contracts.py','php_runtime.py','migration_contract.py','php_requirements.json','api_set_query.py','pe_symbols.py','native_closure.py'}
    sources=c.get('tool_sources',{});need(required<=set(sources),'SCHEMA_TOOL_CLOSURE')
    for name,h in sources.items():
        need(Path(name).name==name and (name.endswith('.py') or name=='php_requirements.json'),'SCHEMA_TOOL_NAME')
        p=local(Path(__file__).parent/name,j.root);need(digest(p.read_bytes())==h,'SCHEMA_TOOL_BYTES_CHANGED')
    for key in ['prior_os_policy','prior_central','expected_schema']:
        p=local(c[key],j.root);need(digest(p.read_bytes())==g.get(key+'_sha256'),'SCHEMA_PRIOR_RECEIPT_CHANGED')
    return c,g,j


def verified_archive(j,receipt):
    path=local(j.root/receipt['path'],j.root);st=path.stat();raw=path.read_bytes()
    need(st.st_ino==receipt['file_id'] and st.st_dev==receipt['volume'] and st.st_size==receipt['bytes'] and digest(raw)==receipt['sha256'],'RAW_ARCHIVE_IDENTITY_OR_HASH_CHANGED')
    return raw


def read_and_archive(j,path,relative):
    """Read from an original non-write-sharing handle and preserve exact input."""
    j.event('PREPARE_NAMED_FILE_RAW_READ',name=Path(path).name,archive=relative)
    k,_,w=_api();handle=k.CreateFileW(str(path),0x80000000,1,None,3,0x00200000,None)
    need(handle!=ctypes.c_void_p(-1).value,'SCHEMA_SOURCE_READONLY_HOLD')
    try:
        before=readonly_fact(path);need(0<before['bytes']<=16777216,'NAMED_PE_SIZE')
        parts=[];buf=ctypes.create_string_buffer(1048576);count=w.DWORD();total=0
        try:
            while True:
                count.value=0
                ok=k.ReadFile(handle,buf,len(buf),ctypes.byref(count),None)
                need(ok,'SCHEMA_SOURCE_READ')
                if not count.value:break
                total+=count.value;parts.append(buf.raw[:count.value])
                need(total<=before['bytes'],'SCHEMA_SOURCE_GREW')
        except BaseException as exc:
            partial=j.bytes(relative+'.partial',b''.join(parts))
            j.json(relative+'.partial.json',dict(partial=True,complete=False,source_before=before,archive=partial,error=type(exc).__name__+': '+str(exc)))
            exc.partial_receipt=partial
            raise
        raw=b''.join(parts)
        # Always preserve actual bytes before parsing, even if a later source,
        # signature or identity check refuses qualification.
        receipt=j.bytes(relative,raw)
        after=readonly_fact(path)
        need(before==after and len(raw)==before['bytes'] and digest(raw)==before['sha256'],'SCHEMA_SOURCE_CHANGED')
        need(receipt['sha256']==before['sha256'] and receipt['bytes']==before['bytes'],'SCHEMA_ARCHIVE_SOURCE_BINDING')
        return before,receipt
    finally:k.CloseHandle(handle)


def observe(value):
    c,g,j=context(value);number=j.reserve_observation();prefix='raw/schema-'+str(number)
    archives=[];query=None
    try:
        system=system_root_fact();path=Path(system['path'])/'apisetschema.dll'
        expected=json.loads(local(c['expected_schema'],j.root).read_bytes())
        need(norm(expected['file']['path'])==norm(str(path)),'SCHEMA_FIXED_SOURCE_PATH')
        need(all(system[k]==expected['system_root'][k] for k in ['file_id','volume']),'SCHEMA_SYSTEM_ROOT_CHANGED')
        if number==2:
            need(c.get('resume_observation')==1,'SCHEMA_SECOND_ATTEMPT_REPLAY_REQUIRED')
            first=json.loads(local(j.root/'raw/schema-1-result-LOCAL_ONLY.json',j.root).read_bytes());need(first.get('exit')==1,'SCHEMA_ALREADY_QUALIFIED_NO_REPEAT')
            original=json.loads(local(j.root/'raw/schema-1-input-receipt-LOCAL_ONLY.json',j.root).read_bytes())
            archive=original['archive'];fact=original['source'];archived=verified_archive(j,archive)
            need(all(readonly_fact(path)[k]==fact[k] for k in ['sha256','file_id','volume','bytes','links']),'SCHEMA_REPLAY_SOURCE_CHANGED')
            signature=json.loads(local(j.root/'raw/schema-1-signature-LOCAL_ONLY.json',j.root).read_bytes());evaluate_file(signature)
            j.event('REUSED_FIRST_DURABLE_SCHEMA_AND_SIGNATURE',archive=archive['path'],sha256=archive['sha256'])
        else:
            fact,archive=read_and_archive(j,path,prefix+'-input-LOCAL_ONLY.bin');archives.append(archive)
            j.json(prefix+'-input-receipt-LOCAL_ONLY.json',dict(source=fact,archive=archive,system_root=system,workspace=j.workspace))
            signature=capture_named(path,system)
            j.json(prefix+'-signature-LOCAL_ONLY.json',signature);evaluate_file(signature)
        need(all(fact[k]==expected['file'][k] for k in ['sha256','file_id','volume','bytes','links']),'SCHEMA_FIXED_IDENTITY_CHANGED')
        need(all(signature['file'][k]==fact[k] for k in ['sha256','file_id','volume','bytes','links']),'SCHEMA_SIGNATURE_BYTE_BINDING')
        j.event('PREPARE_ARCHIVED_SCHEMA_PARSE',archive=archive)
        archived=verified_archive(j,archive);schema=parse_schema(archived)
        prior=json.loads(local(c['prior_os_policy'],j.root).read_bytes())
        central=json.loads(local(c['prior_central'],j.root).read_bytes());validate_snapshot(central);verify_current(central)
        need(all(system[k]==prior['system_root'][k] for k in ['file_id','volume']),'PRIOR_OS_ROOT_CHANGED')
        private=local(c['php_runtime_root'],j.root)
        requirements=json.loads((Path(__file__).parent/'php_requirements.json').read_bytes())
        members={row['path']:local(private/row['path'],private).read_bytes() for row in requirements['verified_archive_members']}
        for row in requirements['verified_archive_members']:need(digest(members[row['path']])==row['sha256'],'PRIVATE_PHP_MEMBER_CHANGED')
        pins={};module_archives={};source_reasons={}
        def load_os(name,reason):
            target=Path(system['path'])/name;source_reasons[name]=reason
            cached='raw/schema-1-'+name+'-input-LOCAL_ONLY.bin'
            receipt=next((x for x in j.rows() if x.get('action')=='RAW_DURABLY_ARCHIVED' and x.get('path')==cached),None) if number==2 else None
            if receipt:
                data=verified_archive(j,receipt);source=readonly_fact(target);need(digest(data)==source['sha256'],'CACHED_HOST_CURRENT_HASH')
                stored={k:receipt[k] for k in ['path','sha256','bytes','file_id','volume','directory_id','directory_volume','file_fsync','directory_flush','exclusive_create','readback_verified']}
                j.event('REUSED_DURABLE_PE_INPUT',module=name,archive=stored['path'],sha256=stored['sha256'])
            else:
                source,stored=read_and_archive(j,target,prefix+'-'+name+'-input-LOCAL_ONLY.bin');archives.append(stored);data=verified_archive(j,stored)
            module_archives[name]=stored
            old=prior['images'].get(name)
            if old:
                need(all(source[k]==old[k] for k in ['sha256','file_id','volume','bytes','links']),'PRIOR_OS_FILE_CHANGED:'+name)
                validate_os_source(source,prior,system);pin=dict(old)
            else:
                prior_trust=j.root/('raw/schema-1-'+name+'-trust-LOCAL_ONLY.json')
                if number==2 and prior_trust.exists():
                    fresh=json.loads(local(prior_trust,j.root).read_bytes());evaluate_file(fresh);j.event('REUSED_THIS_TASK_HOST_SIGNATURE',module=name)
                else:
                    fresh=capture_named(target,system);j.json(prefix+'-'+name+'-trust-LOCAL_ONLY.json',fresh);evaluate_file(fresh)
                need(all(fresh['file'][k]==source[k] for k in ['sha256','file_id','volume','bytes','links']),'NEW_HOST_SIGNATURE_FILE_CHANGED')
                pin=dict(source,signature_status='Valid',windows_publisher_verified=True,signer_thumbprint='BOUND_SUPPORTED_CHAIN_RECEIPT',source_class='WINDOWS_SYSTEM_IMAGE',trust_schema=2,signature_evidence=fresh,signature_evidence_sha256=digest(canonical(fresh)),file_version=file_version(target))
            pin['architecture']=pe_info(data,system_image=True)['machine'];pins[name]=pin
            j.json(prefix+'-'+name+'-source-pin-LOCAL_ONLY.json',pin)
            return data
        def load_central():
            j.event('PREPARE_FIXED_CENTRAL_EXPORT_BYTES_READ',new_signature_observation=False,binary_copy=False)
            target=central['file']['path'];before=readonly_fact(target);data=Path(target).read_bytes()
            need(digest(data)==central['file']['sha256'] and readonly_fact(target)==before,'CENTRAL_EXPORT_SOURCE_CHANGED')
            return data
        with BoundQuery(system,prior) as query:
            j.json(prefix+'-query-provider-LOCAL_ONLY.json',query.receipt)
            closure=build_native_closure(members,schema,query,load_os,load_central)
        query_archive=j.json(prefix+'-query-results-LOCAL_ONLY.json',query.receipts)
        j.json(prefix+'-closure-symbols-LOCAL_ONLY.json',closure)
        policy=dict(schema=1,purpose='READONLY_LOADED_WINDOWS_OS_IMAGES',system_root=system,images=pins,required_ordinary_imports=closure['required_ordinary_imports'],ordinary_import_paths=closure['ordinary_import_paths'],optional_delay=closure['optional_delay'],api_set_schema=dict(archived_relative_path=archive['path'],sha256=fact['sha256'],archive_receipt=archive,signature_evidence=signature),api_set_resolutions=closure['api_set_resolutions'],api_set_query_archive=query_archive,module_archives=module_archives,required_symbol_proofs=closure['required_symbol_proofs'],source_reasons=source_reasons,task_blob=TASK,source_binding=BINDING)
        j.json(prefix+'-os-policy-LOCAL_ONLY.json',policy)
        result=dict(state='API_SET_SIGNED_RAW_ARCHIVED_AND_HOSTS_QUALIFIED',observation=number,schema_sha256=fact['sha256'],archive_receipt=archive,required_modules=len(pins),new_hosts=sorted(set(pins)-set(prior['images'])),resolved_contracts=len(closure['api_set_resolutions']),delay_edges=len(closure['optional_delay']),required_symbols=len(closure['required_symbol_proofs']),php_native='NOT_RUN',exit=0)
        j.json(prefix+'-result-LOCAL_ONLY.json',result);j.event('SCHEMA_OBSERVATION_ENDED',number=number,state=result['state'],exit=0)
        return result
    except BaseException as exc:
        if query is not None:j.json(prefix+'-query-results-failure-LOCAL_ONLY.json',query.receipts)
        if getattr(exc,'partial_receipt',None):archives.append(exc.partial_receipt)
        failure=traceback.format_exc();j.bytes(prefix+'-failure-LOCAL_ONLY.txt',failure.encode())
        result=dict(state='SCHEMA_OR_HOST_QUALIFICATION_FAILED',observation=number,error=type(exc).__name__+': '+str(exc),raw_archives_retained=archives,exit=1)
        j.json(prefix+'-result-LOCAL_ONLY.json',result);j.event('SCHEMA_OBSERVATION_ENDED',number=number,state=result['state'],exit=1,error=result['error'])
        return result


def main(argv=None):
    parser=argparse.ArgumentParser();parser.add_argument('action',nargs='?',choices=['inspect','observe'],default='inspect');parser.add_argument('--context');args=parser.parse_args(argv)
    if args.action=='inspect':print(json.dumps(dict(state='SOURCE_ONLY_RAW_FIRST_ENTRY',observe='EXACT_NEW_TASK_CONTEXT_AND_LEDGER_REQUIRED')));return 0
    need(args.context is not None,'SCHEMA_CONTEXT_REQUIRED')
    result=observe(json.loads(Path(args.context).read_bytes()));print(json.dumps({k:v for k,v in result.items() if k!='archive_receipt'}));return result['exit']


if __name__=='__main__':sys.exit(main())
