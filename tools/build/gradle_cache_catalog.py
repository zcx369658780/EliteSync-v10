"""Bounded static cache catalogue; never a Gradle resolver or executor.

Keep variant attributes, rich versions, constraints and redirects distinct.
Exact-name/content presence is not selection, provenance or offline action
closure. POM semantics and Gradle's binary metadata are deliberately unparsed.
"""
from collections import defaultdict
import copy
import hashlib
import json
from pathlib import PurePosixPath
import re
import stat

from current_product_apk_inventory import _absolute_path, _checked_stat
from current_product_aar_handoff import _bound_file
from current_product_tree_inventory import _enumerate


ROLE = 'existing_readonly_dependency_seed'
CAPS = dict(file_limit=4000, entry_limit=20000, byte_limit=2 * 1024**3, depth_limit=64)
MODULE_CAP = 1024**2
ALL_MODULE_BYTES = 64 * 1024**2
RELATION_LIMIT = 200000
CANDIDATE_REFERENCE_LIMIT = 100000
HASH_LENGTHS = {'sha512':128, 'sha256':64, 'sha1':40, 'md5':32}
FLAGS = {'variant_selection_performed':False, 'offline_resolution_proven':False,
         'POM_semantics_parsed':False, 'gradle_binary_metadata_parsed':False,
         'execution_allowed':False, 'producer_allowed':False, 'G2':False}


def _token(value):
    if (type(value) is not str or len(value)>300 or not re.fullmatch(r'[A-Za-z0-9_][A-Za-z0-9_.+\-]*',value)
            or '..' in value):
        raise ValueError('bounded literal coordinate/name required')
    return value


def _literal_version(value):
    _token(value)
    if value.endswith('+') or value.startswith('latest.') or value in ('LATEST','RELEASE'):
        raise ValueError('dynamic version is not an exact requested coordinate')
    return value


def parse_cache_path(relative):
    if type(relative) is not str or '\\' in relative or str(PurePosixPath(relative))!=relative:
        raise ValueError('canonical POSIX relative cache path required')
    parts=PurePosixPath(relative).parts
    if (len(parts)!=7 or parts[:2]!=('modules-2','files-2.1')
            or not re.fullmatch('[a-f0-9]{1,40}',parts[5])):
        raise ValueError('exact files-2.1 GAV/SHA1/name layout required')
    group,module,version,name=map(_token,(parts[2],parts[3],parts[4],parts[6]))
    _literal_version(version)
    # Variant file names may omit module/version. Coordinates come only from
    # the containing directory; metadata later binds the exact file name/hash.
    # The declared seed has hex directory spellings without leading zeroes.
    # Compare the complete zero-padded digest with bytes, never a hash prefix.
    return dict(group=group,module=module,version=version,sha1=parts[5].zfill(40),name=name)


def _array(value, cap):
    if type(value) is not list or len(value)>cap:
        raise ValueError('bounded metadata array required')
    return value


def _pairs(items):
    result={}
    for key,value in items:
        if key in result:raise ValueError('duplicate module JSON field')
        result[key]=value
    return result


def _constant(value):
    raise ValueError('non-finite module JSON number')


def analyze_modules(entries, module_bytes):
    """Describe all supplied variants; never pick a variant or resolve versions."""
    if type(entries) is not list or len(entries)>CAPS['file_limit'] or type(module_bytes) is not dict:
        raise ValueError('bounded cache entries and module bytes required')
    by_name,by_coordinate,descriptors=defaultdict(list),defaultdict(list),{}
    for entry in entries:
        coordinate=tuple(entry[k] for k in ('group','module','version'))
        by_coordinate[coordinate].append(entry)
        by_name[(*coordinate,entry['name'])].append(entry)
        if entry['name'].endswith('.module'):
            if entry['relative_path'] in descriptors:raise ValueError('duplicate descriptor path')
            descriptors[entry['relative_path']]=entry
    if set(module_bytes)-set(descriptors):raise ValueError('unknown descriptor payload')
    files,edges,variants_out,unsupported,origins=[],[],[],[],[]
    total_bytes=candidate_references=0
    def append(target, item):
        if len(files)+len(edges)+len(variants_out)>=RELATION_LIMIT:
            raise ValueError('aggregate metadata relation bound')
        target.append(item)
    def edge(descriptor,owner,variant,relation,item):
        if type(item) is not dict:raise ValueError('dependency object required')
        group,module=_token(item.get('group')),_token(item.get('module'))
        version=item.get('version');selected=None
        if relation=='available-at':
            try:selected=_literal_version(version)
            except ValueError:pass
        elif type(version) is dict and set(version)=={'requires'}:
            try:selected=_literal_version(version['requires'])
            except ValueError:pass
        targets=by_coordinate.get((group,module,selected),[]) if selected is not None else []
        append(edges,{'descriptor':descriptor,'owner':owner,'variant':variant,'relation':relation,
            'group':group,'module':module,'version':copy.deepcopy(version),'declaration':copy.deepcopy(item),
            'status':'UNRESOLVED_VERSION_POLICY' if selected is None else
                ('DECLARED_COORDINATE_PRESENT' if targets else 'NOT_IN_DECLARED_SEED'),
            'candidate_files':len(targets),'binary_candidates':sum(e['name'].endswith(('.jar','.aar')) for e in targets)})
    for path,raw in module_bytes.items():
        total_bytes+=len(raw)
        if type(raw) is not bytes or len(raw)>MODULE_CAP or total_bytes>ALL_MODULE_BYTES:
            raise ValueError('module payload bound')
        source=descriptors[path]
        if hashlib.sha256(raw).hexdigest()!=source['digests']['sha256']:
            raise ValueError('descriptor content differs from hashed catalogue')
        try:doc=json.loads(raw,object_pairs_hook=_pairs,parse_constant=_constant)
        except (RecursionError,UnicodeError) as error:raise ValueError('bounded module JSON required') from error
        if type(doc) is not dict:raise ValueError('module object required')
        if doc.get('formatVersion')!='1.1':
            unsupported.append(path);continue
        component=doc.get('component')
        if type(component) is not dict:
            raise ValueError('module component differs from cache coordinate')
        if any(component.get(k)!=source[k] for k in ('group','module','version')):
            if type(component.get('url')) is not str or not 0<len(component['url'])<=4096:
                raise ValueError('module component differs without a bounded origin link')
            _token(component.get('group'));_token(component.get('module'));_literal_version(component.get('version'))
            origins.append({'descriptor':path,'cached_coordinate':[source[k] for k in ('group','module','version')],
                'declared_component':copy.deepcopy(component),'status':'UNRESOLVED_COMPONENT_ORIGIN'})
            continue  # Do not silently relabel the owner or attach these variants.
        owner=':'.join(source[k] for k in ('group','module','version'));seen=set()
        for variant in _array(doc.get('variants'),256):
            if type(variant) is not dict:raise ValueError('variant object required')
            name=_token(variant.get('name'))
            if name in seen:raise ValueError('duplicate variant name')
            seen.add(name);attrs=variant.get('attributes',{})
            if type(attrs) is not dict:raise ValueError('variant attributes object required')
            append(variants_out,{'descriptor':path,'owner':owner,'variant':name,'attributes':copy.deepcopy(attrs),
                'capabilities':copy.deepcopy(variant.get('capabilities',[]))})
            for f in _array(variant.get('files',[]),128):
                if type(f) is not dict:raise ValueError('variant file object required')
                filename=_token(f.get('name'));candidates=by_name.get((source['group'],source['module'],source['version'],filename),[])
                candidate_references+=len(candidates)
                if candidate_references>CANDIDATE_REFERENCE_LIMIT:
                    raise ValueError('aggregate candidate reference bound')
                for algorithm,length in HASH_LENGTHS.items():
                    if algorithm in f and (type(f[algorithm]) is not str or not re.fullmatch('[a-f0-9]{'+str(length)+'}',f[algorithm])):
                        raise ValueError('canonical advertised checksum required')
                if 'size' in f and (type(f['size']) is not int or f['size']<0):raise ValueError('file size integer required')
                if f.get('url')!=filename:status='UNRESOLVED_FILE_URL'
                elif not candidates:status='NOT_IN_DECLARED_SEED'
                elif len(candidates)!=1:status='AMBIGUOUS_DECLARED_FILES'
                elif not any(k in f for k in HASH_LENGTHS):status='PRESENT_WITHOUT_DECLARED_HASH'
                elif (any(f[k]!=candidates[0]['digests'][k] for k in HASH_LENGTHS if k in f)
                      or ('size' in f and f['size']!=candidates[0]['bytes'])):status='DECLARED_HASH_MISMATCH'
                else:status='MATCHED_DECLARED_HASHES'
                append(files,{'descriptor':path,'owner':owner,'variant':name,
                    'declaration':copy.deepcopy(f),'status':status,'candidates':len(candidates),
                    'candidate_paths':[e['relative_path'] for e in candidates]})
            for relation,key in [('dependency','dependencies'),('constraint','dependencyConstraints')]:
                for item in _array(variant.get(key,[]),4096):edge(path,owner,name,relation,item)
            if 'available-at' in variant:edge(path,owner,name,'available-at',variant['available-at'])
    return {'status':'STATIC_VARIANT_DECLARATIONS_ONLY','files':files,'edges':edges,'variants':variants_out,
        'parsed_module_files':len(module_bytes)-len(unsupported)-len(origins),'unsupported_module_formats':unsupported,
        'unresolved_component_origins':origins,
        'unparsed_module_files':len(descriptors)-len(module_bytes),**FLAGS}


def inspect_seed(root, rows):
    """Hash a declared complete seed, with before/after membership checks."""
    root=_absolute_path(root)
    if root.parent==root or not stat.S_ISDIR(_checked_stat(root).st_mode):raise ValueError('explicit non-root cache directory required')
    if type(rows) is not list or not rows or len(rows)>CAPS['file_limit']:raise ValueError('bounded declared seed rows required')
    selected=copy.deepcopy(rows);seen=set();total=0
    for row in selected:
        if type(row) is not dict or set(row)!={'role','path','relative_path','bytes','sha256','file_id'}:
            raise ValueError('exact inventoried seed row required')
        relative=row['relative_path'];rel=PurePosixPath(relative)
        if (row['role']!=ROLE or str(rel)!=relative or rel.is_absolute() or '..' in rel.parts or '\\' in relative
                or ':' in relative or relative.casefold() in seen or _absolute_path(row['path'])!=root.joinpath(*rel.parts)
                or type(row['bytes']) is not int or not 0<=row['bytes']<=512*1024**2
                or type(row['sha256']) is not str or not re.fullmatch('[a-f0-9]{64}',row['sha256'])):
            raise ValueError('canonical unique bounded seed identity required')
        if relative.startswith('modules-2/files-2.1/'):parse_cache_path(relative)
        elif not relative.startswith('modules-2/metadata-2.107/'):raise ValueError('unknown seed area')
        seen.add(relative.casefold());total+=row['bytes']
    if total>CAPS['byte_limit']:raise ValueError('seed aggregate byte cap')
    before,names,_=_enumerate({ROLE:root},**CAPS)
    if {path for _,path in names}!={r['path'] for r in selected}:raise ValueError('declared seed membership differs')
    entries,payloads,opaque=[],{},0;module_total=0
    for row in selected:
        is_file=row['relative_path'].startswith('modules-2/files-2.1/')
        algorithms=HASH_LENGTHS if is_file else {'sha256':64}
        digests={name:hashlib.new(name) for name in algorithms};count=0
        capture=is_file and row['relative_path'].endswith('.module') and row['bytes']<=MODULE_CAP
        content=bytearray()
        with _bound_file(root,row) as stream:
            while chunk:=stream.read(min(1024**2,row['bytes']-count+1)):
                count+=len(chunk)
                if count>row['bytes']:raise ValueError('inventoried file grew')
                for digest in digests.values():digest.update(chunk)
                if capture:content.extend(chunk)
        hashes={name:d.hexdigest() for name,d in digests.items()}
        if count!=row['bytes'] or hashes['sha256']!=row['sha256']:raise ValueError('inventoried byte identity differs')
        if is_file:
            parsed=parse_cache_path(row['relative_path'])
            if parsed.pop('sha1')!=hashes['sha1']:raise ValueError('cache SHA1 directory differs from actual file')
            entries.append({**parsed,'bytes':count,'digests':hashes,'relative_path':row['relative_path'],
                            'file_id':row['file_id']})
            if capture:
                module_total+=len(content)
                if module_total>ALL_MODULE_BYTES:raise ValueError('aggregate module bytes cap')
                payloads[row['relative_path']]=bytes(content)
        else:opaque+=1
    analysis=analyze_modules(entries,payloads)
    after,final_names,_=_enumerate({ROLE:root},**CAPS)
    if before!=after or names!=final_names:raise ValueError('seed membership or metadata changed during scan')
    return {'status':'HASHED_SEED_AND_STATIC_MODULE_CATALOG_ONLY','freshly_hashed_files':len(selected),
        'freshly_hashed_bytes':total,'files_2_1_records':len(entries),'opaque_binary_metadata_files':opaque,
        'POM_files_unparsed':sum(e['name'].endswith('.pom') for e in entries),'catalog':entries,'analysis':analysis,
        'sampling_non_atomic':True,'source_writes':0,'network_requests':0,'SDK_or_Gradle_starts':0,**FLAGS}
