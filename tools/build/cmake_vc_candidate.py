"""Independent CMake app-local candidate, derived from immutable host source.

Preparation compiles an existing C# observer, never a native SDK or guest.
Launching still requires this candidate's exact new grant and nonrefundable claim.
The consumed predecessor, its partial recovery and its authority stay untouched.
"""
import ast
import hashlib
from pathlib import Path
from types import ModuleType

import native_role_host as base
import current_product_tree_inventory as tree_inventory


HERE = Path(__file__).resolve().parent
SCOPE = 'v1015-cmake-app-local-version-candidate-20261105'
INPUT_ROOT = Path.home() / 'EliteSyncDev/v1015-cmake-vc-inputs-20261105'
PRIVATE_CMAKE = INPUT_ROOT / 'CMake'
MATERIALIZATION = INPUT_ROOT / 'materialization-outcome-private.json'
MATERIALIZATION_SHA = '131ab25bea79927f2e18f08273fbf5b6b02c0c3855f91b8f61ce643451bf5adf'
READSET_SHA = '13bf160717fcc7b56ca41d8a0494f72811b0778e625fc661a06f069f57914704'
HOST_SHA = 'e729091443269a56e2b6ba9406d6cd5f3bc10f1d1772c931a6462b7cb814f4c8'
WRAPPER_SHA = 'feee40132f2fa8412f7a61be4ad24cec7387bfd04258a9209db7590e1adf69f7'
TREE_CAPS = dict(file_limit=5000, entry_limit=15000, byte_limit=512 * 1024**2, depth_limit=64)


def replace_once(text, old, new):
    if text.count(old) != 1:
        raise ValueError('unique immutable derivation anchor required: ' + old[:80])
    return text.replace(old, new, 1)


def derive_wrapper(raw):
    if hashlib.sha256(raw).hexdigest() != WRAPPER_SHA:
        raise ValueError('immutable guest lifecycle source differs')
    text = raw.decode().replace('\r\n', '\n')
    text = replace_once(text, 'files!=252||dirs!=15', 'files!=270||dirs!=15')
    return replace_once(text, 'native-cmake-preflight', 'native-cmake-vc-preflight').encode()


def derive_source(raw=None):
    if raw is None:
        raw = base.safe_bytes(HERE / 'native_role_host.py', 2 * 1024**2)
    if hashlib.sha256(raw).hexdigest() != HOST_SHA:
        raise ValueError('immutable consumed host source differs')
    text = raw.decode().replace('\r\n', '\n')
    # Remove predecessor-only recovery and identities, rather than synthesizing
    # a partial receipt or reusing its retained nonce for a fresh candidate.
    tree = ast.parse(text); lines = text.splitlines(keepends=True)
    removed = {'PARTIAL_RECEIPT_SHA', 'PARTIAL_NONCE', 'PARTIAL_FILES',
               'prepare', 'preserved_partial', 'finish_preparation'}
    nodes = [n for n in tree.body if
             (isinstance(n, ast.FunctionDef) and n.name in removed) or
             (isinstance(n, ast.Assign) and any(isinstance(t, ast.Name) and t.id in removed for t in n.targets))]
    if len(nodes) != len(removed):
        raise ValueError('exact predecessor recovery definitions required')
    for node in sorted(nodes, key=lambda n: n.lineno, reverse=True):
        del lines[node.lineno - 1:node.end_lineno]
    text = ''.join(lines)
    changes = {
        "SCOPE = 'v1015-native-cmake-version-qualification-20261105'": 'SCOPE = ' + repr(SCOPE),
        "READSET = Path.home() / 'EliteSyncDev/v1015-native-static-imports-20261104/candidate-native-readset-private.json'":
            "READSET = Path.home() / 'EliteSyncDev/v1015-cmake-vc-inputs-20261105/candidate-native-readset-private.json'",
        "READSET_SHA = 'b243c9d7b46fe7753b09b85e04d4c10b40e78e34fe6f03bd62a7ff7ce04b94e2'": 'READSET_SHA = ' + repr(READSET_SHA),
        "'input_files': 42": "'input_files': 45",
        'complete 42 PE inputs required': 'complete 45 PE inputs required',
        '    graph = decode_json(raw)\n': '    graph = decode_json(raw)\n    _verify_private_tree()\n',
        "    wrapper = safe_bytes(HERE / 'native_role_guest_lifecycle.cs', 1024**2)":
            "    wrapper = _derive_wrapper(safe_bytes(HERE / 'native_role_guest_lifecycle.cs', 1024**2))",
        "'readonly_preflight_file_denials': 252": "'readonly_preflight_file_denials': 270",
        "'file_denials': 252": "'file_denials': 270",
        "'kind': 'native-cmake-preflight'": "'kind': 'native-cmake-vc-preflight'",
        "'readset_sha256', 'partial_receipt_sha256', 'manifest'": "'readset_sha256', 'manifest'",
        'def frozen():\n': 'def frozen():\n    if (ROOT / \'preparation-failure-private.json\').exists():\n        raise ValueError(\'preparation is terminally failed; no runtime or recovery\')\n',
        "    if contract['partial_receipt_sha256'] != PARTIAL_RECEIPT_SHA:\n        raise ValueError('original partial receipt pin differs')\n    preserved_partial()\n": '',
        "'full_input_mapping_interop.py', 'windows_sandbox_launch.ps1']":
            "'full_input_mapping_interop.py', 'windows_sandbox_launch.ps1',\n             'cmake_vc_candidate.py', 'current_product_tree_inventory.py']",
        'import native_role_host as h;print(json.dumps(h.collect()))':
            'import cmake_vc_candidate as h;print(json.dumps(h.collect()))',
    }
    for old, new in changes.items():
        text = replace_once(text, old, new)
    if text.count('CMAKE_VERSION_SAMPLED_LIFECYCLE_SUPPORTED') != 2:
        raise ValueError('exact collector status anchors required')
    return text.replace('CMAKE_VERSION_SAMPLED_LIFECYCLE_SUPPORTED',
                        'CMAKE_VC_VERSION_SAMPLED_LIFECYCLE_SUPPORTED').encode()


def verify_private_tree():
    """Recheck all CMake files, beyond the 45-PE preflight sample."""
    raw = base.safe_bytes(MATERIALIZATION, 4 * 1024**2)
    if hashlib.sha256(raw).hexdigest() != MATERIALIZATION_SHA:
        raise ValueError('fixed app-local materialization inventory differs')
    expected = base.decode_json(raw)
    if expected['private_cmake_root'] != str(PRIVATE_CMAKE):
        raise ValueError('fixed private CMake root differs')
    actual = tree_inventory.inventory_trees(roots={'private_cmake': str(PRIVATE_CMAKE)}, **TREE_CAPS)
    if (actual['files'] != expected['inventory']['files']
            or len(actual['files']) != expected['private_files']
            or actual['total_bytes'] != expected['private_bytes']):
        raise ValueError('complete private CMake tree content/identity/membership drift')


def derive_host():
    host = ModuleType('_cmake_vc_immutable_host')
    host.__dict__.update(__file__=str(HERE / 'cmake_vc_candidate.py'),
                         _verify_private_tree=verify_private_tree, _derive_wrapper=derive_wrapper)
    exec(compile(derive_source(), str(HERE / 'cmake_vc_candidate.py') + ':derived', 'exec'), host.__dict__)
    return host


def prepare_host(host):
    """Freeze one new candidate. Any partial output blocks re-preparation."""
    if host.ROOT.exists():
        raise FileExistsError('candidate already registered; no recompile, replacement or successor')
    host.inventory._checked_stat(host.ROOT.parent)
    source_pins = host.sources()
    _, pins, mappings = host.readset()
    compiler, compiler_sha = host.compiler_pin()
    compiler_stat = host.inventory._checked_stat(compiler)
    compiler_identity = (host.inventory._identity(compiler_stat), compiler_stat.st_nlink)
    nonce = host.uuid.uuid4().hex
    source = host.guest_source(pins, nonce)
    configuration = host.configuration(mappings, nonce)
    host.ROOT.mkdir()
    try:
        for name in ('probe', 'output', 'compile-temp'):
            (host.ROOT / name).mkdir()
        with (host.ROOT / 'probe/NativeRoleProbe.cs').open('xb') as stream:
            stream.write(source)
        with (host.ROOT / 'qualification.wsb').open('x', encoding='utf-8', newline='\n') as stream:
            stream.write(configuration)
        environment = {'SystemRoot': host.os.environ['SystemRoot'], 'WINDIR': host.os.environ['SystemRoot'],
            'PATH': str(Path(host.os.environ['SystemRoot']) / 'System32'),
            'TEMP': str(host.ROOT / 'compile-temp'), 'TMP': str(host.ROOT / 'compile-temp'),
            'HOME': str(host.ROOT / 'compile-temp'), 'USERPROFILE': str(host.ROOT / 'compile-temp')}
        result = host.subprocess.run([str(compiler), '/nologo', '/noconfig', '/target:winexe', '/platform:x64',
            '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll',
            '/main:NativeRoleGuestWrapper', '/out:' + str(host.ROOT / 'probe/NativeRoleProbe.exe'),
            str(host.ROOT / 'probe/NativeRoleProbe.cs')], capture_output=True,
            cwd=host.ROOT / 'compile-temp', env=environment, timeout=30)
        for name, raw in [('compiler.stdout', result.stdout), ('compiler.stderr', result.stderr)]:
            with (host.ROOT / name).open('xb') as stream:
                stream.write(raw)
        if result.returncode or result.stderr.strip():
            raise RuntimeError('observer compilation rejected; retain partial output, no retry')
        after_compiler, after_sha = host.compiler_pin()
        after_stat = host.inventory._checked_stat(after_compiler)
        if (host.sources() != source_pins or after_compiler != compiler or after_sha != compiler_sha
                or (host.inventory._identity(after_stat), after_stat.st_nlink) != compiler_identity):
            raise ValueError('preparation source or compiler identity drift; no contract')
        manifest = {**host.core.role_plan(host.ROLE, pins), 'nonce': nonce,
                    'binary_sha256': host.sha(host.safe_bytes(host.ROOT / 'probe/NativeRoleProbe.exe', 4 * 1024**2))}
        host.write_once(host.ROOT / 'probe/manifest.locked.json', manifest)
        contract = {**host.policy(), 'source_pins': source_pins, 'readset_sha256': host.READSET_SHA,
                    'manifest': manifest, 'mappings': mappings, 'source_sha256': host.sha(source),
                    'compiler_sha256': compiler_sha}
        host.write_once(host.ROOT / 'case-contract-private.json', contract)
        host.frozen()
        return {'status': contract['status'], 'scope': host.SCOPE, 'source_sha256': host.sha(source),
                'binary_sha256': manifest['binary_sha256'], 'claim_created': False, 'G2': False}
    except Exception as error:
        host.write_once(host.ROOT / 'preparation-failure-private.json', {
            'status': 'PREPARATION_FAILED_NO_RUNTIME', 'error': type(error).__name__ + ': ' + str(error),
            'scope': host.SCOPE, 'VM_launches': 0, 'SDK_starts': 0, 'claim_created': False,
            'partial_preserved': True, 'reprepare_allowed': False, 'G2': False})
        raise


def prepare():
    return prepare_host(derive_host())


def frozen():
    return derive_host().frozen()


def launch(*, new_scope_authorized=False, owner_reference=''):
    return derive_host().launch(new_scope_authorized=new_scope_authorized, owner_reference=owner_reference)


def wait_and_collect():
    return derive_host().wait_and_collect()


def collect():
    return derive_host().collect()
