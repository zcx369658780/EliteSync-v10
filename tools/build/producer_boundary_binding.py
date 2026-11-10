"""Bind the existing source-only producer entry to guest boundary primitives.

No launch, VM configuration, grant, nonce allocation or claim is created here.
"""
import hashlib
import json
from pathlib import PureWindowsPath
import subprocess


ENTRY_SHA256 = '52d35954c0147ad41865e74196c89e3177d9218d3f8a98c90d3fdd91dd88a48c'


def bind_entry(raw, boundary_source):
    if (type(raw) is not bytes or not 0 < len(raw) <= 1024**2
            or hashlib.sha256(raw).hexdigest() != ENTRY_SHA256):
        raise ValueError('exact source-only producer entry required')
    if type(boundary_source) is not bytes or not 0 < len(boundary_source) <= 1024**2:
        raise ValueError('bounded boundary source bytes required')
    # The exact immutable artifact is checked once above. Its internal fields
    # are application data, not a second untrusted API requiring another schema.
    entry = json.loads(raw)
    argv = list(entry['stage1']['argv'])
    argv[-1:-1] = ['-I', 'C:/BuildWork/Control/producer-output.init.gradle']
    cwd = str(PureWindowsPath(entry['stage1']['working_directory']))
    environment = entry['environment']
    command = subprocess.list2cmdline(argv)
    return {
        'kind':'producer-boundary-source-binding', 'producer_entry_sha256':ENTRY_SHA256,
        'boundary_source_sha256':hashlib.sha256(boundary_source).hexdigest(),
        'source_identity':entry['source_identity'], 'publication_version':entry['publication_version'],
        'launch_request':{'command_line':command,'cwd':cwd,'environment':environment},
        'nonce':None, 'authorization':None, 'runtime_authorized':False, 'claim_created':False,
        'producer_budget':'UNKNOWN_NOT_CREATED', 'G2':False,
        'host_write_scope':'fresh output mapping only; BuildWork stays inside the guest',
        'source_controls':['Sandbox network disabled and host inputs read-only',
                           'suspended root assigned to kill-on-close Job before resume',
                           '64 process / 4 GiB Job limits', 'three inherited stdio handles only'],
        'runtime_qualified':False, 'network_enforcement_proven':False,
        'input_read_closure_proven':False, 'preexecution_image_allowlist_proven':False,
        'DLL_closure_proven':False, 'SDK_or_VM_starts':0,
    }
