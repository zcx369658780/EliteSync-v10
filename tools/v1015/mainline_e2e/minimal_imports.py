"""Pure import graph, ordinary and delay imports never conflated.

No system reads, process launch or module loads. Caller supplies pinned PE bytes.
Delay edges are evidence only, not a permission to accept a loaded image.
"""
from pathlib import PurePosixPath
from contracts import need
from pe_dependencies import pe_info
from php_runtime import os_import


def minimum_private_graph(members, roots):
    by_name={PurePosixPath(p).name.lower():p for p in members}
    need(len(by_name)==len(members),'IMPORT_DUPLICATE_BASENAME')
    work=[(name,[]) for name in roots];seen=set();required={};delay=[];edges=[]
    while work:
        name,chain=work.pop(0)
        need(name in by_name,'IMPORT_PRIVATE_MEMBER_MISSING:'+name)
        if name in seen:continue
        seen.add(name);rel=by_name[name];info=pe_info(members[rel])
        for target in info['ordinary_imports']:
            path=chain+[rel,target];edges.append(dict(importer=rel,target=target,kind='ORDINARY',path=path))
            if target in by_name:work.append((target,chain+[rel]))
            elif target=='vcruntime140.dll':continue
            elif os_import(target):
                if not target.startswith(('api-ms-','ext-ms-')):required.setdefault(target,path)
            else:need(False,'IMPORT_UNQUALIFIED_PRIVATE_DEPENDENCY:'+target)
        for target in info['delay_imports']:
            delay.append(dict(importer=rel,target=target,kind='OPTIONAL_DELAY_NOT_OBSERVED_LOADED'))
    return dict(schema=1,private_members=sorted(by_name[x] for x in seen),
                mandatory_os=required,ordinary_edges=edges,optional_delay=delay,
                actual_loaded_modules='NOT_RUN',classification='STATIC_MINIMUM_IMPORT_GRAPH')
