"""Static closure construction from supplied signed/pinned bytes and API receipts.

No system action here. The real entry supplies mandatory durable/signature-backed
loaders and supported read-only queries. Synthetic use is not native execution.
"""
from pathlib import Path
from contracts import need
from api_set_schema import resolve
from api_set_query import validate_query
from pe_symbols import inspect_symbols,split_forwarder
from pe_dependencies import pe_info


def build(members,schema,query,load_os,load_central):
    data={Path(p).name.lower():b for p,b in members.items()};private=set(data)
    pending=list(data);parsed={};required=set();ordinary=[];resolutions=[];requests=[];delay=[];api_cache={};memo={};proofs=[]
    def host(module,importer):
        if not module.startswith(('api-ms-','ext-ms-')):return module
        candidate=resolve(schema,module,importer)
        if module not in api_cache:api_cache[module]=query.host(module)
        receipt=api_cache[module];validate_query(candidate,receipt)
        resolutions.append(dict(contract=module,importer=importer,host=candidate,query=receipt,raw_entry=getattr(schema,'selected_entries',{}).get(module.removesuffix('.dll'))))
        return candidate
    def ensure(module,reason):
        if module in data:return
        need(Path(module).name==module and module.endswith('.dll'),'NATIVE_SYMBOL_MODULE_NAME')
        if module=='vcruntime140.dll':data[module]=load_central()
        else:
            need(module=='msvcp_win.dll' or not module.startswith(('vcruntime','msvcp','concrt')),'NATIVE_EXTRA_VC_FORBIDDEN')
            need(len(required)<64,'NATIVE_ORDINARY_MODULE_BOUND');data[module]=load_os(module,reason);required.add(module)
        pending.append(module)
    def symbol(module,name,stack):
        key=(module,name)
        if key in memo:return memo[key]
        need(key not in stack and len(stack)<32,'NATIVE_EXPORT_FORWARDER_CYCLE')
        if module not in parsed:parsed[module]=inspect_symbols(data[module])
        entry=parsed[module]['exports'].get(name);need(entry is not None,'NATIVE_REQUIRED_EXPORT_MISSING:'+module+':'+name)
        if entry['forwarder']:
            other,target=split_forwarder(entry['forwarder']);other=host(other,module);ensure(other,dict(importer=module,forwarded_symbol=name,target=other))
            endpoint=symbol(other,target,stack+[key])
        else:
            need(entry.get('rva_valid') is True,'NATIVE_REQUIRED_EXPORT_RVA_INVALID:'+module+':'+name)
            endpoint=dict(module=module,symbol=name,rva=entry['rva'])
        memo[key]=endpoint;return endpoint
    while pending or requests:
        if pending:
            module=pending.pop(0);info=parsed.setdefault(module,inspect_symbols(data[module]));pe=pe_info(data[module],system_image=module not in private)
            delay.extend(dict(importer=module,target=x,classification='OPTIONAL_DELAY_NOT_PRESTART_REQUIRED') for x in pe['delay_imports'])
            for library,names in info['imports'].items():
                target=host(library,module);ensure(target,dict(importer=module,target=library,resolved_host=target))
                if module not in private and module!='vcruntime140.dll':ordinary.append(dict(importer=module,target=library))
                requests.extend((module,target,name) for name in names)
        else:
            importer,target,name=requests.pop(0);need(len(proofs)<100000,'NATIVE_IMPORT_SYMBOL_BOUND')
            proofs.append(dict(importer=importer,target=target,symbol=name,endpoint=symbol(target,name,[])))
    return dict(required_ordinary_imports=sorted(required),ordinary_import_paths=ordinary,api_set_resolutions=resolutions,optional_delay=delay,required_symbol_proofs=proofs,unique_export_resolutions=len(memo),static_only=True,php_loaded=False)
