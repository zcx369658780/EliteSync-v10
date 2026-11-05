"""Bind the existing source-only producer entry to guest boundary primitives.

No launch, VM configuration, grant, nonce allocation or claim is created here.
"""
import hashlib
import json
from pathlib import PureWindowsPath
import subprocess


ENTRY_SHA256 = '52d35954c0147ad41865e74196c89e3177d9218d3f8a98c90d3fdd91dd88a48c'


def _unique(pairs):
    value = {}
    for key, item in pairs:
        if key in value:
            raise ValueError('duplicate producer entry field')
        value[key] = item
    return value


def bind_entry(raw, boundary_source):
    if (type(raw) is not bytes or not 0 < len(raw) <= 1024**2
            or hashlib.sha256(raw).hexdigest() != ENTRY_SHA256):
        raise ValueError('exact source-only producer entry required')
    if type(boundary_source) is not bytes or not 0 < len(boundary_source) <= 1024**2:
        raise ValueError('bounded boundary source bytes required')
    entry = json.loads(raw, object_pairs_hook=_unique)
    if (entry.get('status') != 'FULL_ROOT_PRODUCER_SOURCE_WIRED_NOT_EXECUTABLE'
            or any(entry.get(k) is not False for k in
                   ('execution_allowed', 'claim_created', 'G2', 'inherit_environment', 'old_claims_reused'))
            or entry.get('producer_budget') != 'UNKNOWN_NOT_CREATED'):
        raise ValueError('source-only producer authority must remain closed')
    argv = entry['stage1']['argv']
    if (type(argv) is not list or not argv or len(argv) > 128
            or any(type(arg) is not str or not arg or any(c in arg for c in '\0\r\n') for arg in argv)
            or argv[0] != 'C:/Inputs/Jdk/bin/java.exe' or argv[-1] != 'assembleAarRelease'
            or '--offline' not in argv or '--max-workers=1' not in argv or '--dry-run' in argv):
        raise ValueError('exact bounded Java producer action required')
    cwd = str(PureWindowsPath(entry['stage1']['working_directory']))
    if cwd != r'C:\BuildWork\Project\apps\flutter_elitesync_module\.android':
        raise ValueError('private producer working directory required')
    environment = entry['environment']
    if type(environment) is not dict or not 0 < len(environment) <= 64:
        raise ValueError('explicit producer environment required')
    folded = set()
    for key, value in environment.items():
        if (type(key) is not str or not key or len(key) > 128 or '=' in key
                or type(value) is not str or len(value) > 8192
                or any(c in key + value for c in '\0\r\n')
                or key.casefold() in folded or key.casefold() == 'flutter_already_locked'):
            raise ValueError('invalid or inherited producer environment')
        folded.add(key.casefold())
    if sum(len(k) + len(v) + 2 for k, v in environment.items()) + 1 > 32760:
        raise ValueError('Windows environment block bound')
    command = subprocess.list2cmdline(argv)
    if len(command) > 30000:
        raise ValueError('Windows command-line bound')
    return {
        'kind':'producer-boundary-source-binding', 'producer_entry_sha256':ENTRY_SHA256,
        'boundary_source_sha256':hashlib.sha256(boundary_source).hexdigest(),
        'source_identity':entry['source_identity'], 'publication_version':entry['publication_version'],
        'launch_request':{'command_line':command,'cwd':cwd,'environment':environment},
        'nonce':None, 'authorization':None, 'runtime_authorized':False, 'claim_created':False,
        'producer_budget':'UNKNOWN_NOT_CREATED', 'G2':False,
        'write_scope_candidate':'C:\\BuildWork only; explicit log handles stay inside that guest workspace',
        'source_controls':['restricted write SID and low token', 'owned workspace ACL/low label',
                           'suspended root assigned to kill-on-close Job before resume',
                           '64 process / 4 GiB Job limits', 'three inherited stdio handles only'],
        'runtime_qualified':False, 'network_enforcement_proven':False,
        'input_read_closure_proven':False, 'preexecution_image_allowlist_proven':False,
        'DLL_closure_proven':False, 'SDK_or_VM_starts':0,
    }
