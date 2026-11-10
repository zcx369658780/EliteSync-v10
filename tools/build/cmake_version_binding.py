"""Offline CMake version expectations from PE, metadata and recorded bytes.

No execution/claim/collector API. An existing rejected case stays rejected.
The output checker requires an independently pinned expectation SHA; a byte
match says nothing about a launch, exit status, DLL loading or qualification.
"""
from contextlib import ExitStack
import copy
import hashlib
import json
import re
import xml.etree.ElementTree as ET

from current_product_apk_inventory import _absolute_path
from current_product_aar_handoff import _bound_file
from native_import_inventory import parse_imports


CAPS = {'pe': 16 * 1024**2, 'properties': 64 * 1024, 'package_xml': 256 * 1024,
        'stdout': 4096, 'stderr': 4096}
FOOTER = b'CMake suite maintained and supported by Kitware (kitware.com/cmake).\n'
NUMBER = r'(?:0|[1-9][0-9]{0,4})'
REVISION = NUMBER + r'\.' + NUMBER + r'\.' + NUMBER
VERSION = re.compile('(' + REVISION + r')(?:-g[0-9a-f]{7,40}(?:-dirty)?)?')
FIXED = {'schema': 1, 'kind': 'cmake-version-literal-expectation', 'status': 'OFFLINE_EXPECTATION_ONLY',
         'execution_allowed': False, 'runtime_qualified': False, 'producer_allowed': False, 'G2': False}
FIELDS = set(FIXED) | {'package_revision', 'version_literal', 'expected_first_line', 'pe_sha256', 'pe_bytes',
    'literal_offsets', 'source_properties_sha256', 'package_xml_sha256',
    'stdout_sha256', 'stdout_bytes', 'stderr_sha256', 'stderr_bytes'}


def _sha(raw):
    return hashlib.sha256(raw).hexdigest()


def _bytes(raw, cap, *, empty=False):
    if type(raw) is not bytes or not (0 if empty else 1) <= len(raw) <= cap:
        raise ValueError('bounded bytes required')
    return raw


def _revision(value):
    if type(value) is not str or not re.fullmatch(REVISION, value) or any(int(x) > 65535 for x in value.split('.')):
        raise ValueError('canonical release package revision required')
    return value


def _metadata(properties, package_xml):
    fields = {}
    for line in properties.decode('utf-8-sig').splitlines():
        if not line.strip():
            continue
        parts = line.split('=', 1)
        if len(parts) != 2 or parts[0].strip() in fields:
            raise ValueError('unique package properties required')
        fields[parts[0].strip()] = parts[1].strip()
    if set(fields) != {'Pkg.Revision', 'Pkg.Path', 'Pkg.Desc'}:
        raise ValueError('exact CMake package properties required')
    revision = _revision(fields['Pkg.Revision'])
    if fields['Pkg.Path'] != 'cmake;' + revision or fields['Pkg.Desc'] != 'CMake ' + revision:
        raise ValueError('CMake package path/description revision mismatch')
    text = package_xml.decode('utf-8-sig')
    if '\0' in text or '<!doctype' in text.lower() or '<!entity' in text.lower():
        raise ValueError('UTF-8 package XML required without NUL, DTD or entities')
    try:
        root = ET.fromstring(text)
    except ET.ParseError as error:
        raise ValueError('well-formed package XML required') from error
    if root.tag != '{http://schemas.android.com/repository/android/common/02}repository':
        raise ValueError('declared Android repository namespace required')
    packages = root.findall('{*}localPackage')
    if len(packages) != 1 or packages[0].get('path') != 'cmake;' + revision:
        raise ValueError('one matching CMake localPackage required')
    revisions = packages[0].findall('{*}revision')
    if len(revisions) != 1:
        raise ValueError('one package revision required')
    parts = list(revisions[0])
    if [n.tag.rsplit('}', 1)[-1] for n in parts] != ['major', 'minor', 'micro']:
        raise ValueError('unique ordered release revision fields required')
    if '.'.join(n.text or '' for n in parts) != revision:
        raise ValueError('XML/properties revision mismatch')
    return revision


def _output(stdout, stderr):
    _bytes(stdout, CAPS['stdout']);_bytes(stderr, CAPS['stderr'], empty=True)
    if stderr:
        raise ValueError('empty stderr required')
    first = stdout.partition(b'\n')[0]
    if not first.startswith(b'cmake version '):
        raise ValueError('literal CMake first line required')
    version = first[len(b'cmake version '):].decode('ascii')
    match = VERSION.fullmatch(version)
    if match is None or stdout != first + b'\n\n' + FOOTER:
        raise ValueError('complete literal version output required, including suffix and LF bytes')
    return version, _revision(match.group(1))


def _offsets(pe, version):
    needle = b'\0' + version.encode('ascii') + b'\0'
    offsets, start = [], 0
    while (position := pe.find(needle, start)) >= 0:
        offsets.append(position + 1);start = position + 1
        if len(offsets) > 64:
            raise ValueError('version literal occurrence cap')
    if not offsets:
        raise ValueError('whole NUL-bounded version token absent from fixed PE')
    return offsets


def derive_expectation(*, pe, properties, package_xml, stdout, stderr):
    for name, raw in [('pe', pe), ('properties', properties), ('package_xml', package_xml)]:
        _bytes(raw, CAPS[name])
    parsed = parse_imports(pe)
    if parsed['machine'] != '0x8664' or parsed['bits'] != 64:
        raise ValueError('declared AMD64 CMake PE required')
    revision = _metadata(properties, package_xml)
    version, output_revision = _output(stdout, stderr)
    if output_revision != revision:
        raise ValueError('observed full version and package release differ')
    return {**FIXED, 'package_revision': revision, 'version_literal': version,
        'expected_first_line': 'cmake version ' + version, 'pe_sha256': _sha(pe), 'pe_bytes': len(pe),
        'literal_offsets': _offsets(pe, version), 'source_properties_sha256': _sha(properties),
        'package_xml_sha256': _sha(package_xml), 'stdout_sha256': _sha(stdout), 'stdout_bytes': len(stdout),
        'stderr_sha256': _sha(stderr), 'stderr_bytes': len(stderr)}


def _pairs(items):
    result = {}
    for key, value in items:
        if key in result:
            raise ValueError('duplicate expectation JSON field')
        result[key] = value
    return result


def _constant(value):
    raise ValueError('non-finite expectation JSON number')


def check_output(expectation_bytes, expected_sha256, pe, stdout, stderr):
    """Caller pins SHA before reading candidate output; never learn it here."""
    _bytes(expectation_bytes, 64 * 1024)
    if (type(expected_sha256) is not str or not re.fullmatch('[a-f0-9]{64}', expected_sha256)
            or _sha(expectation_bytes) != expected_sha256):
        raise ValueError('independently pinned expectation bytes differ')
    expected = json.loads(expectation_bytes, object_pairs_hook=_pairs, parse_constant=_constant)
    if type(expected) is not dict or set(expected) != FIELDS:
        raise ValueError('exact offline expectation fields required')
    if any(type(expected[k]) is not type(v) or expected[k] != v for k, v in FIXED.items()):
        raise ValueError('offline-only flags/types must stay fixed')
    for key in ['pe_sha256', 'source_properties_sha256', 'package_xml_sha256', 'stdout_sha256', 'stderr_sha256']:
        if type(expected[key]) is not str or not re.fullmatch('[a-f0-9]{64}', expected[key]):
            raise ValueError('fixed lowercase SHA required')
    _bytes(pe, CAPS['pe'])
    version, revision = _output(stdout, stderr)
    if (expected['version_literal'] != version or expected['package_revision'] != revision
            or expected['expected_first_line'] != 'cmake version ' + version):
        raise ValueError('exact version expectation mismatch')
    for prefix, raw in [('pe', pe), ('stdout', stdout), ('stderr', stderr)]:
        if type(expected[prefix + '_bytes']) is not int or expected[prefix + '_bytes'] != len(raw) or expected[prefix + '_sha256'] != _sha(raw):
            raise ValueError('fixed PE/output byte identity mismatch')
    offsets = expected['literal_offsets']
    if (type(offsets) is not list or any(type(n) is not int for n in offsets)
            or offsets != _offsets(pe, version)):
        raise ValueError('whole PE version literal offset mismatch')
    return {'status': 'OUTPUT_BYTES_MATCH_OFFLINE_EXPECTATION', 'execution_allowed': False,
            'runtime_qualified': False, 'producer_allowed': False, 'G2': False}


def _rows(root, rows, names):
    if type(rows) is not list or len(rows) != len(names):
        raise ValueError('exact declared input rows required')
    rows = copy.deepcopy(rows)
    seen = set()
    for row in rows:
        if type(row) is not dict or set(row) != {'role', 'path', 'relative_path', 'bytes', 'sha256', 'file_id'}:
            raise ValueError('exact inventoried row required')
        name = row['relative_path']
        if (type(name) is not str or name not in names or name in seen
                or _absolute_path(row['path']) != root / name
                or type(row['bytes']) is not int or not 0 <= row['bytes'] <= names[name]
                or type(row['sha256']) is not str or not re.fullmatch('[a-f0-9]{64}', row['sha256'])):
            raise ValueError('unique bounded inventoried input required')
        seen.add(name)
        if (type(row['file_id']) is not dict or set(row['file_id']) != {'device', 'inode'}
                or any(type(n) is not int or n <= 0 for n in row['file_id'].values())):
            raise ValueError('original file identity required')
    return rows


def inspect_inputs(cmake_root, cmake_rows, observation_root, observation_rows):
    """Read five declared files through held identities; never write or execute."""
    cmake_root, observation_root = (_absolute_path(str(root)) for root in (cmake_root, observation_root))
    cmake = _rows(cmake_root, cmake_rows, {'bin/cmake.exe': CAPS['pe'],
        'source.properties': CAPS['properties'], 'package.xml': CAPS['package_xml']})
    observed = _rows(observation_root, observation_rows, {'output/tool.stdout': CAPS['stdout'],
        'output/tool.stderr': CAPS['stderr']})
    payload = {}
    with ExitStack() as stack:
        for root, rows in [(cmake_root, cmake), (observation_root, observed)]:
            for row in rows:
                stream = stack.enter_context(_bound_file(root, row))
                raw = stream.read(row['bytes'] + 1)
                if len(raw) != row['bytes']:
                    raise ValueError('input byte count drift')
                payload[row['relative_path']] = raw
        expectation = derive_expectation(pe=payload['bin/cmake.exe'], properties=payload['source.properties'],
            package_xml=payload['package.xml'], stdout=payload['output/tool.stdout'], stderr=payload['output/tool.stderr'])
    return {'status': 'INVENTORIED_OFFLINE_BINDING_ONLY', 'bound_files': cmake + observed,
            'expectation': expectation, 'execution_allowed': False, 'runtime_qualified': False,
            'producer_allowed': False, 'G2': False}
