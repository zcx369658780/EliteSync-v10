"""Pure data plan for current-product input layout. Never grants execution."""
from pathlib import PureWindowsPath
import re


LEGACY_G2_SOURCE = '6ca09a66c0ef9619df7a3d7d4b089516f409954f'
_GUEST_INPUTS = {
    'stock_flutter': r'C:\Inputs\Flutter',
    'source_pub': r'C:\Inputs\Pub',
    'tooling_snapshot': r'C:\Inputs\ToolingSnapshot',
    'old_seed': r'C:\Inputs\DependencyCache',
}
_PRIVATE = {
    'tooling_copy': r'C:\BuildWork\Tooling\packages\flutter_tools\gradle',
    'module_root': r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android',
    'plugin_outputs': r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android\plugins_build_output',
    'jni_staging': r'C:\BuildWork\state\cmake\jni',
    'gradle_home': r'C:\BuildWork\GradleHome',
}
_RESERVED = {'CON', 'PRN', 'AUX', 'NUL', *(f'COM{i}' for i in range(1, 10)),
             *(f'LPT{i}' for i in range(1, 10))}


def _path(value):
    """Reject ambiguous path spellings without querying the filesystem."""
    if not isinstance(value, str) or not re.match(r'^[A-Za-z]:\\', value):
        raise ValueError('A drive-qualified absolute Windows path is required')
    if '/' in value or any(ord(char) < 32 for char in value) or any(char in value for char in '*?<>|%$~"'):
        raise ValueError('Redirect/device/variable path syntax is not allowed')
    parts = value[3:].split('\\')
    if not parts or any(not part or part in ('.', '..') or ':' in part or
                        part.rstrip(' .') != part or part.split('.')[0].upper() in _RESERVED
                        for part in parts):
        raise ValueError('A canonical non-root path is required')
    path = PureWindowsPath(value)
    if not path.is_absolute() or str(path).casefold() != value.casefold():
        raise ValueError('Non-canonical path')
    return path


def _sha(value):
    if not isinstance(value, str) or re.fullmatch(r'[0-9a-f]{40}', value) is None:
        raise ValueError('Code identities must be lowercase 40-hex values')
    return value


def _overlap(left, right):
    return left.is_relative_to(right) or right.is_relative_to(left)


def _fields(value, expected, label):
    if type(value) is not dict or set(value) != set(expected):
        raise ValueError('Unexpected ' + label + ' fields')
    return value


def make_plan(*, source_commit, apps_tree, services_tree, stock_flutter,
              source_pub, tooling_snapshot, old_seed):
    """Describe fixed inputs/outputs only; no filesystem or process operations."""
    hosts = dict(stock_flutter=stock_flutter, source_pub=source_pub,
                 tooling_snapshot=tooling_snapshot, old_seed=old_seed)
    plan = {
        'schema': 1,
        'kind': 'current-product-configuration-layout-plan',
        'source_identity': {'source_commit': source_commit, 'apps_tree': apps_tree,
                            'services_tree': services_tree},
        'readonly_inputs': {role: {'host': host, 'guest': _GUEST_INPUTS[role], 'readonly': True}
                            for role, host in hosts.items()},
        'private_paths': dict(_PRIVATE),
        'seed_modules_root': r'C:\Inputs\DependencyCache\modules-2',
        'legacy_g2': {'source_commit': LEGACY_G2_SOURCE, 'source_differs': True,
                      'preserve_fixed_contract': True},
        'guard_conflict': {'stock_tooling': r'C:\Inputs\Flutter\packages\flutter_tools\gradle',
                           'private_tooling': _PRIVATE['tooling_copy'],
                           'path_identity_differs': True, 'original_guard_conflict_preserved': True},
        'execution_allowed': False,
        'G2': False,
        'old_claims_reused': False,
        'new_runtime_budget': 'UNKNOWN',
    }
    validate_plan(plan)
    return plan


def validate_plan(plan):
    """Validate shape/policy claims; does not attest actual paths or runtime."""
    expected_keys = {'schema', 'kind', 'source_identity', 'readonly_inputs', 'private_paths',
                     'seed_modules_root', 'legacy_g2', 'guard_conflict', 'execution_allowed',
                     'G2', 'old_claims_reused', 'new_runtime_budget'}
    if type(plan) is not dict or set(plan) != expected_keys:
        raise ValueError('Only the declared non-executable plan fields are allowed')
    if type(plan.get('schema')) is not int or plan['schema'] != 1 or plan.get('kind') != 'current-product-configuration-layout-plan':
        raise ValueError('Unknown plan schema or kind')
    identity = _fields(plan['source_identity'], ['source_commit', 'apps_tree', 'services_tree'], 'source identity')
    for key in ['source_commit', 'apps_tree', 'services_tree']:
        _sha(identity.get(key))
    if identity['source_commit'] == LEGACY_G2_SOURCE:
        raise ValueError('Current product source cannot be relabelled legacy G2 source')
    for key in ['execution_allowed', 'G2', 'old_claims_reused']:
        if plan.get(key) is not False:
            raise ValueError('No execution or inherited budget authority is granted')
    if plan.get('new_runtime_budget') != 'UNKNOWN':
        raise ValueError('A data plan cannot claim an available runtime budget')

    inputs = _fields(plan['readonly_inputs'], _GUEST_INPUTS, 'input role')
    host_paths, guest_paths = [], []
    for role, expected in _GUEST_INPUTS.items():
        row = _fields(inputs[role], ['host', 'guest', 'readonly'], 'input mapping')
        host, guest = _path(row.get('host')), _path(row.get('guest'))
        if guest != PureWindowsPath(expected) or row.get('readonly') is not True:
            raise ValueError('Stock SDK, Pub, tooling and Seed inputs must stay readonly')
        if any(_overlap(host, other) for other in host_paths):
            raise ValueError('Host input roots must not overlap')
        host_paths.append(host)
        guest_paths.append(guest)

    paths = _fields(plan['private_paths'], _PRIVATE, 'private output')
    private = {role: _path(value) for role, value in paths.items()}
    if 'build' in (part.casefold() for part in private['jni_staging'].parts):
        raise ValueError('CMake staging must be outside temporary build directories')
    if any(_overlap(private['gradle_home'], other) for role, other in private.items() if role != 'gradle_home'):
        raise ValueError('Writable Gradle home must be independent')
    if any(_overlap(path, input_path) for path in private.values() for input_path in guest_paths + host_paths):
        raise ValueError('Private writes must not overlap protected input roots')
    if any(private[role] != PureWindowsPath(expected) for role, expected in _PRIVATE.items()):
        raise ValueError('Private layout drift')
    if _path(plan.get('seed_modules_root')) != PureWindowsPath(_GUEST_INPUTS['old_seed']) / 'modules-2':
        raise ValueError('Read-only dependency cache base must contain modules-2')

    legacy = _fields(plan['legacy_g2'], ['source_commit', 'source_differs', 'preserve_fixed_contract'], 'legacy G2')
    if legacy.get('source_commit') != LEGACY_G2_SOURCE or legacy.get('source_differs') is not True or legacy.get('preserve_fixed_contract') is not True:
        raise ValueError('Original G2 contract and source difference must remain explicit')
    conflict = _fields(plan['guard_conflict'], ['stock_tooling', 'private_tooling', 'path_identity_differs',
                                             'original_guard_conflict_preserved'], 'guard conflict')
    stock = _path(conflict.get('stock_tooling'))
    target = _path(conflict.get('private_tooling'))
    if stock != PureWindowsPath(_GUEST_INPUTS['stock_flutter']) / 'packages/flutter_tools/gradle' or target != private['tooling_copy'] or stock == target:
        raise ValueError('Stock/private tooling identity conflict must remain explicit')
    if conflict.get('path_identity_differs') is not True or conflict.get('original_guard_conflict_preserved') is not True:
        raise ValueError('A data plan cannot waive the original guard conflict')
    return None
