"""Host-only repair primitives; never launch a Sandbox or grant a new budget.

Keep consumed lifecycle/cleanup helpers unchanged. Project CIM objects to six
primitive fields before JSON serialization, and repair only the two confirmed
variable-token errors in the SHA-bound old cleanup template.
"""
import base64
import hashlib
import json
import math
from pathlib import Path
import subprocess

import sandbox_owned_session_cleanup as original_cleanup


ORIGINAL_CLEANUP_SHA256 = 'aa5f09f731ea45f28cf48bebe613c0840c5d43b94ecd178c52aba54826185588'
NAMES = {'WindowsSandbox.exe', 'WindowsSandboxClient.exe',
         'WindowsSandboxRemoteSession.exe', 'WindowsSandboxServer.exe'}
FIELDS = {'ProcessId', 'ParentProcessId', 'Name', 'CreationDate', 'ExecutablePath', 'CommandLine'}
MAX_SNAPSHOT_BYTES = 1024 * 1024


def snapshot_command():
    return r'''$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$rows = @(foreach($item in @(Get-CimInstance Win32_Process -Filter "Name='WindowsSandbox.exe' OR Name='WindowsSandboxClient.exe' OR Name='WindowsSandboxRemoteSession.exe' OR Name='WindowsSandboxServer.exe'" -ErrorAction Stop)) {
    [ordered]@{
        ProcessId = [int]$item.ProcessId
        ParentProcessId = [int]$item.ParentProcessId
        Name = [string]$item.Name
        CreationDate = $item.CreationDate.ToUniversalTime().ToString('o')
        ExecutablePath = [string]$item.ExecutablePath
        CommandLine = [string]$item.CommandLine
    }
})
$json = ConvertTo-Json -InputObject $rows -Depth 3 -Compress -WarningAction Stop
[Console]::Write($json)
'''


def parse_snapshot(raw):
    if type(raw) is not bytes or not raw or len(raw) > MAX_SNAPSHOT_BYTES:
        raise ValueError('nonempty bounded snapshot bytes required')
    try:
        rows = json.loads(raw.decode('utf-8-sig'))
    except (UnicodeDecodeError, json.JSONDecodeError) as error:
        raise ValueError('host observation is not a clean UTF-8 JSON array') from error
    if type(rows) is not list:
        raise ValueError('null/scalar is not evidence of an empty process set')
    seen = set()
    for row in rows:
        if type(row) is not dict or set(row) != FIELDS:
            raise ValueError('only six primitive observation fields are accepted')
        if type(row['ProcessId']) is not int or row['ProcessId'] <= 0 or row['ProcessId'] in seen:
            raise ValueError('distinct process identities required')
        seen.add(row['ProcessId'])
        if type(row['ParentProcessId']) is not int or row['ParentProcessId'] < 0 or row['Name'] not in NAMES:
            raise ValueError('unexpected process observation')
        if any(type(row[key]) is not str or not row[key] for key in ['CreationDate', 'ExecutablePath']):
            raise ValueError('process creation/path identity missing')
        if type(row['CommandLine']) is not str:
            raise ValueError('process command must be explicit')
        original_cleanup._time(row['CreationDate'])
    return rows


def observe(*, timeout_seconds=15):
    """Read current host processes only; return raw diagnostics as well as rows."""
    if type(timeout_seconds) not in (int, float) or not math.isfinite(timeout_seconds) or timeout_seconds <= 0:
        raise ValueError('positive finite observation timeout required')
    encoded = base64.b64encode(snapshot_command().encode('utf-16-le')).decode('ascii')
    result = subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-EncodedCommand', encoded],
                            capture_output=True, timeout=timeout_seconds)
    if result.returncode:
        raise ValueError('host process query failed; do not infer absence')
    return {'rows': parse_snapshot(result.stdout), 'stdout': result.stdout, 'stderr': result.stderr,
            'exit_code': result.returncode}


def render_corrected_cleanup(launch, recorded, current, configuration):
    source = Path(original_cleanup.__file__).read_bytes()
    if hashlib.sha256(source).hexdigest() != ORIGINAL_CLEANUP_SHA256:
        raise ValueError('consumed cleanup template differs from the known baseline')
    command = original_cleanup.render_cleanup(launch, recorded, current, configuration)
    for role in ('session', 'server'):
        old = '$' + role + '.Cim.CreationDate'
        new = '$' + role + 'Cim.CreationDate'
        if command.count(old) != 1:
            raise ValueError('variable repair anchor is not unique')
        command = command.replace(old, new, 1)
    return command
