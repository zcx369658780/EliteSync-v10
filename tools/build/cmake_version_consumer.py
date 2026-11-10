"""New independent host with a frozen full-version output consumer.

Derives immutable predecessor code without changing or collecting its spent
case. Preparation is observer compilation only. Launch remains gated by a new
scope-specific grant/claim; no producer, device or G2 authority is introduced.
"""
import hashlib
from pathlib import Path
from types import ModuleType

import cmake_vc_candidate as previous
import cmake_version_binding as binding


HERE = Path(__file__).resolve().parent
SCOPE = 'v1015-cmake-version-bound-consumer-20261105'
PREVIOUS_SHA = '0149cef24b3ad688527e51e98daa2eaa42903b35352701be9ca47d48b8d2f04a'
EXPECTATION = Path.home() / 'EliteSyncDev/v1015-cmake-version-binding-20261105/version-expectation-private.json'
EXPECTATION_SHA = 'f7ab715afc911d941a61122318831635399ca3e9a3c27672d228445bdecfe780'
PRIVATE_CMAKE = previous.PRIVATE_CMAKE


def _inputs(pins):
    raw = previous.base.safe_bytes(EXPECTATION, 64 * 1024)
    if hashlib.sha256(raw).hexdigest() != EXPECTATION_SHA:
        raise ValueError('independently frozen version expectation differs')
    expected = previous.base.decode_json(raw)
    path = previous.base.core._guest(*previous.base.core.ROLES['cmake'][:2])
    if (type(expected) is not dict or type(expected.get('expected_first_line')) is not str
            or path not in pins or expected.get('pe_sha256') != pins[path]):
        raise ValueError('version expectation does not bind the declared CMake PE')
    pe = previous.base.safe_bytes(PRIVATE_CMAKE / 'bin/cmake.exe', binding.CAPS['pe'])
    return raw, expected, pe


def read_expectation(pins):
    """Validate the frozen data/PE before compilation or a runtime claim."""
    raw, expected, pe = _inputs(pins)
    # This is synthetic validation of expectation consistency, never SDK output.
    template = expected['expected_first_line'].encode('ascii') + b'\n\n' + binding.FOOTER
    binding.check_output(raw, EXPECTATION_SHA, pe, template, b'')
    return raw


def consume_version(pins, stdout, stderr):
    raw, _, pe = _inputs(pins)
    return binding.check_output(raw, EXPECTATION_SHA, pe, stdout, stderr)


def bound_wrapper(raw):
    text = previous.derive_wrapper(raw).decode()
    return previous.replace_once(text, 'native-cmake-vc-preflight', 'native-cmake-bound-version-preflight').encode()


def derive_source(raw=None):
    if raw is None:
        raw = previous.base.safe_bytes(HERE / 'cmake_vc_candidate.py', 2 * 1024**2)
    if hashlib.sha256(raw).hexdigest() != PREVIOUS_SHA:
        raise ValueError('immutable predecessor adapter differs')
    text = previous.derive_source().decode()
    changes = {
        "SCOPE = 'v1015-cmake-app-local-version-candidate-20261105'": 'SCOPE = ' + repr(SCOPE),
        "'cmake_vc_candidate.py', 'current_product_tree_inventory.py']":
            "'cmake_vc_candidate.py', 'current_product_tree_inventory.py',\n             'cmake_version_binding.py', 'cmake_version_consumer.py']",
        '    pins = core.input_pins(graph)\n': '    pins = core.input_pins(graph)\n    _read_expectation(pins)\n',
        '    _, pins, mappings = readset()\n': '    _, pins, mappings = readset()\n    _read_expectation(pins)\n',
        "'device_media_allowed': False, 'G2': False}":
            "'device_media_allowed': False, 'version_expectation_sha256': " + repr(EXPECTATION_SHA) + ", 'G2': False}",
        "'kind': 'native-cmake-vc-preflight'": "'kind': 'native-cmake-bound-version-preflight'",
        "    lines = raw['tool.stdout'].decode('utf-8-sig').splitlines()\n"
        "    if raw['tool.stderr'].strip() or not lines or lines[0] != 'cmake version 3.22.1':\n"
        "        raise ValueError('expected CMake version output required')":
            "    version_bytes = _consume_version(pins, raw['tool.stdout'], raw['tool.stderr'])",
        "            'proof': proof, 'sample_log': logs, 'guest_preflight': expected_preflight,":
            "            'proof': proof, 'sample_log': logs, 'guest_preflight': expected_preflight,\n"
            "            'version_expectation_sha256': " + repr(EXPECTATION_SHA) + ", 'version_bytes': version_bytes,",
        'import cmake_vc_candidate as h;print(json.dumps(h.collect()))':
            'import cmake_version_consumer as h;print(json.dumps(h.collect()))',
    }
    for old, new in changes.items():
        text = previous.replace_once(text, old, new)
    if text.count('CMAKE_VC_VERSION_SAMPLED_LIFECYCLE_SUPPORTED') != 2:
        raise ValueError('exact predecessor collector status anchors required')
    return text.replace('CMAKE_VC_VERSION_SAMPLED_LIFECYCLE_SUPPORTED',
                        'CMAKE_BOUND_VERSION_SAMPLED_LIFECYCLE_SUPPORTED').encode()


def derive_host():
    host = ModuleType('_cmake_bound_version_host')
    host.__dict__.update(__file__=str(HERE / 'cmake_version_consumer.py'),
        _verify_private_tree=previous.verify_private_tree, _derive_wrapper=bound_wrapper,
        _read_expectation=read_expectation, _consume_version=consume_version)
    exec(compile(derive_source(), str(HERE / 'cmake_version_consumer.py') + ':derived', 'exec'), host.__dict__)
    return host


def prepare():
    return previous.prepare_host(derive_host())


def frozen():
    return derive_host().frozen()


def launch(*, new_scope_authorized=False, owner_reference=''):
    return derive_host().launch(new_scope_authorized=new_scope_authorized, owner_reference=owner_reference)


def wait_and_collect():
    return derive_host().wait_and_collect()


def collect():
    return derive_host().collect()
