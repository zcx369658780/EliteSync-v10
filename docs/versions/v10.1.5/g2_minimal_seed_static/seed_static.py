"""Conservative declaration reachability, NOT Gradle's resolver or variant engine.
No launcher, downloads, binary-cache reconstruction or permission manipulation.
"""
import re
import xml.etree.ElementTree as ET

CAP = 536870912
def text(element, name, default=''):
    if element is None:return default
    child=element.find('{*}'+name)
    return child.text.strip() if child is not None and child.text else default
def expand(value, props):
    for _ in range(20):
        out=re.sub(r'\$\{([^}]+)\}',lambda m:props.get(m[1],m[0]),value or '')
        if out==value:return out
        value=out
    return value
def fixed(version):return bool(version) and not any(x in version for x in ['$', '[',']','(',')',',','+','latest.'])

class PomModels:
    def __init__(self, loader):self.loader=loader;self.memo={};self.issues=[]
    def issue(self, code, node, detail=''):self.issues.append({'code':code,'node':node,'detail':detail})
    def model(self, coord, stack=()):
        if coord in self.memo:return self.memo[coord]
        if coord in stack:self.issue('POM_PARENT_OR_BOM_CYCLE',coord);return None
        raw=self.loader(coord)
        if raw is None:self.issue('POM_MISSING',coord);return None
        if '<!DOCTYPE' in raw or '<!ENTITY' in raw:raise ValueError('XML_EXTERNAL_ENTITY_FORBIDDEN')
        root=ET.fromstring(raw);g,a,v=coord.split(':');parent=root.find('{*}parent');base=None;support=[]
        props={}
        own=root.find('{*}properties')
        if own is not None:props={x.tag.rsplit('}',1)[-1]:(x.text or '').strip() for x in own}
        if parent is not None:
            pc=':'.join(expand(text(parent,k),props) for k in ['groupId','artifactId','version'])
            support.append({'kind':'parent','to':pc})
            if all(pc.split(':')) and '$' not in pc:base=self.model(pc,stack+(coord,))
            else:self.issue('PARENT_VERSION_UNKNOWN',coord,pc)
            self.issue('EFFECTIVE_PARENT_MODEL_NOT_GRADLE_RESOLVED',coord,pc)
        parent_override=bool(base and any(k in base['properties'] and base['properties'][k]!=val for k,val in props.items()))
        inherited=dict(base['properties']) if base else {};inherited.update(props);props=inherited
        props.update({'project.groupId':text(root,'groupId',g),'pom.groupId':g,'project.artifactId':a,'pom.artifactId':a,'project.version':text(root,'version',v),'pom.version':v})
        if parent is not None:
            props.update({'project.parent.groupId':text(parent,'groupId'),'project.parent.version':text(parent,'version')})
        for _ in range(20):
            new={k:expand(val,props) for k,val in props.items()}
            if new==props:break
            props=new
        management=dict(base['management']) if base else {}
        def dep(elem):
            fields={k:expand(text(elem,k),props) for k in ['groupId','artifactId','version','scope','type','classifier','optional']}
            key=(fields['groupId'],fields['artifactId'],fields['type'] or 'jar',fields['classifier'])
            if not fields['version']:fields['version']=management.get(key,'')
            if parent_override and (not text(elem,'version') or '$' in text(elem,'version')):
                fields['version']='';self.issue('PARENT_OVERRIDE_EFFECTIVE_VERSION_UNKNOWN',coord,fields['groupId']+':'+fields['artifactId'])
            fields['scope']=fields['scope'] or 'compile';fields['type']=fields['type'] or 'jar'
            fields['to']=':'.join(fields[k] for k in ['groupId','artifactId','version'])
            fields['exclusions']=[(text(x,'groupId'),text(x,'artifactId')) for x in elem.findall('{*}exclusions/{*}exclusion')]
            return key,fields
        declarations=root.findall('{*}dependencyManagement/{*}dependencies/{*}dependency')
        # Imports are support edges, never runtime dependencies by themselves.
        for e in declarations:
            key,d=dep(e)
            if d['scope']=='import' and d['type']=='pom':
                support.append({'kind':'bom-import','to':d['to']})
                bm=self.model(d['to'],stack+(coord,)) if fixed(d['version']) else None
                if bm:
                    for k,val in bm['management'].items():management.setdefault(k,val)
                else:self.issue('BOM_UNRESOLVED',coord,d['to'])
        for e in declarations:
            key,d=dep(e)
            if d['scope']!='import':management[key]=d['version']
        # Parent declarations are visited through the support node in their own
        # source context. Do not pretend its pre-expanded deps are the child's
        # effective inherited model; child override semantics remain UNKNOWN.
        dependencies={}
        for e in root.findall('{*}dependencies/{*}dependency'):
            key,d=dep(e);dependencies[key]=d
            if not fixed(d['version']):self.issue('DEPENDENCY_VERSION_UNRESOLVED',coord,d['to'])
            if d['exclusions']:self.issue('EXCLUSIONS_NOT_APPLIED_TO_ENVELOPE',coord,d['to'])
            if d['optional']=='true':self.issue('OPTIONAL_EDGE_INCLUDED_CONSERVATIVELY',coord,d['to'])
            if d['classifier']:self.issue('CLASSIFIER_SELECTION_REQUIRED',coord,d['classifier'])
        if root.find('{*}profiles') is not None:self.issue('MAVEN_PROFILE_ACTIVATION_UNKNOWN',coord)
        relocation=root.find('{*}distributionManagement/{*}relocation')
        if relocation is not None:
            target=':'.join(text(relocation,k,z) for k,z in zip(['groupId','artifactId','version'],[g,a,v]));support.append({'kind':'relocation','to':target});self.issue('RELOCATION_SELECTION_UNKNOWN',coord,target)
        result={'properties':props,'management':management,'dependencies':list(dependencies.values()),'support':support,'packaging':text(root,'packaging','jar')}
        self.memo[coord]=result;return result

def module_edges(coord, meta):
    edges=[];issues=[];variants=meta.get('variants',[])
    if not variants:issues.append({'code':'MODULE_HAS_NO_VARIANTS','node':coord})
    if len(variants)>1:issues.append({'code':'GRADLE_VARIANT_SELECTION_NOT_EMULATED','node':coord,'detail':','.join(v.get('name','') for v in variants)})
    for variant in variants:
        name=variant.get('name','');attributes=variant.get('attributes',{});capabilities=variant.get('capabilities',[])
        available=variant.get('available-at')
        ds=[('dependency',d) for d in variant.get('dependencies',[])]+[('constraint',d) for d in variant.get('dependencyConstraints',[])]+([('available-at',available)] if available else [])
        for kind,d in ds:
            ver=d.get('version',{});ver={'requires':ver} if isinstance(ver,str) else ver
            versions={v for k,v in ver.items() if k in ('requires','strictly','prefers') and isinstance(v,str)}
            if len(versions)!=1:issues.append({'code':'GRADLE_RICH_VERSION_UNKNOWN','node':coord,'detail':str(ver)})
            for value in sorted(versions) or ['']:
                target=':'.join([d.get('group',''),d.get('module',''),value]);edges.append({'kind':kind,'to':target,'variant':name,'attributes':attributes,'capabilities':capabilities,'requestedVersion':ver,'excludes':d.get('excludes',[])})
                if not fixed(value):issues.append({'code':'MODULE_DEPENDENCY_VERSION_UNKNOWN','node':coord,'detail':target})
    return edges,issues

def envelope(roots, poms, modules, known_nodes):
    todo=list(dict.fromkeys(roots));seen=set();edges=[];issues=[];models=PomModels(poms.get)
    while todo:
        node=todo.pop(0)
        if node in seen:continue
        seen.add(node)
        if node not in known_nodes:
            issues.append({'code':'PLUGIN_MARKER_MISSING' if node.split(':')[1].endswith('.gradle.plugin') else 'COMPONENT_CONTENT_NOT_CACHED','node':node});continue
        model=models.model(node)
        if model:
            ds=[{'kind':'pom-'+d['scope'],'to':d['to'],'optional':d['optional'],'classifier':d['classifier'],'exclusions':d['exclusions']} for d in model['dependencies'] if d['scope'] not in ('test','system')]+model['support']
            for d in ds:
                d=dict(d,fromNode=node,evidence='LIMITED_STATIC_POM_MODEL_EDGE_NOT_SELECTED_EDGE');edges.append(d)
                if len(d['to'].split(':'))==3 and fixed(d['to'].split(':')[2]):todo.append(d['to'])
        if node in modules:
            ds,problems=module_edges(node,modules[node]);issues+=problems
            for d in ds:
                edges.append(dict(d,fromNode=node,evidence='PROVEN_STATIC_DECLARATION_NOT_SELECTED_EDGE'))
                # Constraints affect selection, but do not introduce dependencies.
                if d['kind']!='constraint' and fixed(d['to'].split(':')[-1]):todo.append(d['to'])
    versions={}
    for n in seen:
        g,a,v=n.split(':');versions.setdefault(g+':'+a,set()).add(v)
    for key,vs in versions.items():
        if len(vs)>1:issues.append({'code':'MULTI_VERSION_WINNER_NOT_PROVEN','node':key,'detail':','.join(sorted(vs))})
    return {'nodes':sorted(seen),'edges':edges,'issues':issues+models.issues,'model':'OBSERVED_DECLARATION_REACHABILITY_NOT_GRADLE_EFFECTIVE_MODEL_OR_COMPLETE_UPPER_BOUND'}

def unique_module(catalog, coordinate, metadata):
    if coordinate in catalog and catalog[coordinate]!=metadata:
        raise ValueError('AMBIGUOUS_DUPLICATE_MODULE_METADATA:'+coordinate)
    catalog[coordinate]=metadata

def decision(issues, *, indexes_complete, logical_bytes, peak_bytes, ro_layout, hashes_match=True, redirected=False):
    reasons=list(issues)
    for flag,code in [(not indexes_complete,'CACHE_INDEX_CLOSURE_UNKNOWN'),(not ro_layout,'RO_LAYER_FALLBACK_FORBIDDEN'),(not hashes_match,'SHA_DRIFT'),(redirected,'PATH_REDIRECTION'),(logical_bytes>CAP,'LOGICAL_CAP_EXCEEDED'),(peak_bytes>CAP,'PEAK_CAP_EXCEEDED')]:
        if flag:reasons.append(code)
    return {'status':'MINIMAL_SEED_CLOSURE_NOT_PROVEN' if reasons else 'MINIMAL_SEED_STATIC_CLOSURE_CANDIDATE','issues':reasons,'G2_READY_FOR_POPEN':False,'GRADLE_RESOLUTION_RUNTIME_NOT_PROVEN':True}
