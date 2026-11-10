"""Static POM declarations and exact local module-origin links, never a resolver.

No URL, parent relativePath, profile, plugin, repository or build is executed.
POM inheritance/interpolation/BOM precedence and Gradle selection stay unresolved.
"""
from collections import defaultdict
import hashlib
import json
import posixpath
import re
import xml.etree.ElementTree as ET

from gradle_cache_catalog import _constant, _literal_version, _pairs, _token, parse_cache_path


FILE_LIMIT = 1600
FILE_BYTES = 2 * 1024**2
TOTAL_BYTES = 64 * 1024**2
RELATION_LIMIT = 100000
CANDIDATE_LIMIT = 100000
FLAGS = dict(effective_model_computed=False, variant_selection_performed=False,
             offline_resolution_proven=False, execution_allowed=False,
             producer_allowed=False, G2=False)
POM_NAMESPACE = 'http://maven.apache.org/POM/4.0.0'


def _exact_coordinate(values):
    try:
        group, module, version = values
        _token(group)
        _token(module)
        _literal_version(version)
        return (group, module, version)
    except (ValueError, TypeError):
        return None


def _logical_path(coordinate):
    group, module, version = coordinate
    return '/'.join((*group.split('.'), module, version, f'{module}-{version}.module'))


def _origin_url_status(cached, declared, url):
    # Work only in a logical Maven namespace. Never open the supplied URL/path.
    if (type(url) is not str or not 0 < len(url) <= 4096 or url.startswith('/')
            or not re.fullmatch(r'[A-Za-z0-9_.+/-]+', url)):
        return 'UNSUPPORTED_ORIGIN_URL'
    target = posixpath.normpath(posixpath.join(posixpath.dirname(_logical_path(cached)), url))
    if target == '..' or target.startswith('../'):
        return 'UNSUPPORTED_ORIGIN_URL'
    return None if target == _logical_path(declared) else 'URL_COORDINATE_MISMATCH'


def _xml(raw):
    try:
        text = raw.decode('utf-8-sig')
    except UnicodeError as error:
        raise ValueError('UTF-8 POM required') from error
    if '\x00' in text or '<!DOCTYPE' in text.upper() or '<!ENTITY' in text.upper():
        raise ValueError('POM DTD/entities and NUL forbidden')
    try:
        root = ET.fromstring(text)
    except ET.ParseError as error:
        raise ValueError('POM XML required') from error
    namespace = '{' + POM_NAMESPACE + '}' if root.tag == '{' + POM_NAMESPACE + '}project' else ''
    if root.tag != namespace + 'project':
        raise ValueError('POM project namespace required')
    stack = [(root, 0)]
    count = 0
    while stack:
        node, depth = stack.pop()
        count += 1
        if (count > 20000 or depth > 64 or len(node.text or '') > 65536
                or not isinstance(node.tag, str) or not node.tag.startswith(namespace)
                or '}' in node.tag[len(namespace):]):
            raise ValueError('bounded uniform-namespace POM required')
        stack.extend((child, depth + 1) for child in node)
    return root, namespace


def _child(node, namespace, name):
    matches = node.findall(namespace + name)
    if len(matches) > 1:
        raise ValueError('duplicate direct POM field: ' + name)
    return matches[0] if matches else None


def _fields(node, namespace, names):
    result = {}
    for name in names:
        field = _child(node, namespace, name)
        if field is not None:
            if len(field):
                raise ValueError('scalar POM field required: ' + name)
            result[name] = (field.text or '').strip()
    return result


def analyze_declarations(entries, payloads):
    """Consume hash-bound metadata only; return declarations with explicit gaps."""
    if (type(entries) is not list or len(entries) > FILE_LIMIT or type(payloads) is not dict
            or len(payloads) != len(entries)):
        raise ValueError('bounded unique metadata payloads required')
    index, documents = defaultdict(list), {}
    total = 0
    for entry in entries:
        path = entry['relative_path']
        parsed = parse_cache_path(path)
        if path in documents or any(parsed[k] != entry[k] for k in ('group','module','version','name')):
            raise ValueError('unique path-bound metadata coordinates required')
        raw = payloads.get(path)
        if type(raw) is not bytes or len(raw) > FILE_BYTES or len(raw) != entry['bytes']:
            raise ValueError('bounded metadata bytes required')
        total += len(raw)
        if total > TOTAL_BYTES or hashlib.sha256(raw).hexdigest() != entry['digests']['sha256']:
            raise ValueError('metadata SHA256 or aggregate bound differs')
        kind = 'module' if entry['name'].endswith('.module') else 'pom' if entry['name'].endswith('.pom') else None
        if kind is None:
            raise ValueError('only POM and module descriptors allowed')
        coordinate = tuple(entry[k] for k in ('group','module','version'))
        index[(coordinate, kind)].append(path)
        if kind == 'module':
            try:
                doc = json.loads(raw, object_pairs_hook=_pairs, parse_constant=_constant)
            except (RecursionError, UnicodeError) as error:
                raise ValueError('bounded module JSON required') from error
            if type(doc) is not dict or type(doc.get('component')) is not dict:
                raise ValueError('module component required')
        else:
            doc = _xml(raw)
        documents[path] = (coordinate, kind, doc)

    origins, poms, unsupported = [], [], []
    relations = candidates = 0

    def candidate_paths(coordinate, kind, filename=None):
        nonlocal candidates
        paths = index.get((coordinate, kind), []) if coordinate else []
        if filename is not None:
            paths = [p for p in paths if p.rsplit('/', 1)[-1] == filename]
        candidates += len(paths)
        if candidates > CANDIDATE_LIMIT:
            raise ValueError('aggregate candidate reference bound')
        return list(paths)

    def relation(kind, declaration, exclusions=None):
        nonlocal relations
        relations += 1
        if relations > RELATION_LIMIT:
            raise ValueError('aggregate POM relation bound')
        coordinate = _exact_coordinate([declaration.get(k) for k in ('groupId','artifactId','version')])
        paths = candidate_paths(coordinate, 'pom')
        return dict(kind=kind, declaration=declaration, exclusions=exclusions or [],
            status=('NEEDS_EFFECTIVE_MODEL' if coordinate is None else
                    'DECLARED_POM_COORDINATE_PRESENT' if paths else 'DECLARED_POM_COORDINATE_ABSENT'),
            candidate_paths=paths)

    for path, (coordinate, kind, doc) in documents.items():
        if kind == 'module':
            if doc.get('formatVersion') != '1.1':
                unsupported.append(path)
                continue
            component = doc['component']
            declared = _exact_coordinate([component.get(k) for k in ('group','module','version')])
            if declared == coordinate and 'url' not in component:
                continue
            filename = _logical_path(declared).rsplit('/', 1)[-1] if declared else None
            paths = candidate_paths(declared, 'module', filename)
            status = 'UNRESOLVED_COMPONENT_IDENTITY'
            if doc.get('formatVersion') == '1.1' and declared:
                status = _origin_url_status(coordinate, declared, component.get('url'))
                if status is None:
                    status = ('TARGET_DESCRIPTOR_ABSENT' if not paths else
                              'AMBIGUOUS_TARGET_DESCRIPTORS' if len(paths) != 1 else
                              'TARGET_IDENTITY_UNRESOLVED')
                    if len(paths) == 1:
                        target = documents[paths[0]][2]
                        expected = dict(zip(('group','module','version'), declared))
                        if (target.get('formatVersion') == '1.1' and
                                all(target['component'].get(k) == v for k,v in expected.items())
                                and 'url' not in target['component']):
                            status = 'EXACT_LOCAL_ORIGIN_LINK'
            origins.append(dict(descriptor=path, cached_coordinate=list(coordinate),
                declared_coordinate=list(declared) if declared else None,
                component=component, status=status, candidate_paths=paths))
            continue

        root, ns = doc
        declared = _fields(root, ns, ('groupId','artifactId','version','packaging','modelVersion'))
        own = _exact_coordinate([declared.get(k) for k in ('groupId','artifactId','version')])
        coordinate_status = ('NEEDS_EFFECTIVE_MODEL' if own is None else
                             'DECLARED_COORDINATE_MATCH' if own == coordinate else
                             'DECLARED_COORDINATE_DIFFERS')
        props, property_declarations, duplicate_properties, edges = {}, [], set(), []
        properties = _child(root, ns, 'properties')
        if properties is not None:
            for child in properties:
                name = child.tag[len(ns):]
                if len(child):
                    raise ValueError('scalar POM property required')
                value = (child.text or '').strip()
                property_declarations.append(dict(name=name, value=value))
                if name in props:
                    duplicate_properties.add(name)
                    del props[name]
                elif name not in duplicate_properties:
                    props[name] = value
        parent = _child(root, ns, 'parent')
        if parent is not None:
            edges.append(relation('parent', _fields(parent, ns,
                ('groupId','artifactId','version','relativePath'))))
        management = _child(root, ns, 'dependencyManagement')
        containers = [(management, 'dependency_management'), (root, 'dependency')]
        for container, label in containers:
            dependencies = _child(container, ns, 'dependencies') if container is not None else None
            if dependencies is None:
                continue
            for dep in dependencies:
                if dep.tag != ns + 'dependency':
                    raise ValueError('POM dependency element required')
                fields = _fields(dep, ns,
                    ('groupId','artifactId','version','type','classifier','scope','optional','systemPath'))
                exclusions = []
                excluded = _child(dep, ns, 'exclusions')
                if excluded is not None:
                    for exclusion in excluded:
                        if exclusion.tag != ns + 'exclusion':
                            raise ValueError('POM exclusion element required')
                        exclusions.append(_fields(exclusion, ns, ('groupId','artifactId')))
                edge_kind = 'bom_import' if (label == 'dependency_management' and
                    fields.get('type') == 'pom' and fields.get('scope') == 'import') else label
                edges.append(relation(edge_kind, fields, exclusions))
        unevaluated = [name for name in ('profiles','build','repositories','pluginRepositories',
            'distributionManagement','modules','reporting','prerequisites') if _child(root,ns,name) is not None]
        poms.append(dict(descriptor=path, cached_coordinate=list(coordinate), declaration=declared,
            coordinate_status=coordinate_status, properties=props, relations=edges,
            property_declarations=property_declarations, duplicate_property_names=sorted(duplicate_properties),
            unevaluated_sections=unevaluated, effective_model_computed=False))
    return dict(status='STATIC_METADATA_DECLARATIONS_AND_LINKS_ONLY', component_origins=origins,
        poms=poms, metadata_files=len(documents), metadata_bytes=total,
        unsupported_module_formats=unsupported,
        module_variants_rebound=False, POM_declarations_parsed=True,
        network_requests=0, SDK_or_Gradle_starts=0, **FLAGS)
