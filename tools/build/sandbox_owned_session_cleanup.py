"""Bind a specific Sandbox host pair and render a guarded cleanup command.

No command is executed here. The caller owns scope authorization and must retain
the original STOP/claim. Never use a process-name-wide termination command.
"""
from datetime import datetime, timezone
from pathlib import PureWindowsPath

from current_product_build_plan import _path


def _pid(value):
    if type(value) is not int or value <= 0:
        raise ValueError('positive exact process ID required')
    return value


def _time(value):
    if type(value) is not str:
        raise ValueError('explicit process creation timestamp required')
    result = datetime.fromisoformat(value.replace('Z', '+00:00'))
    if result.tzinfo is None:
        raise ValueError('creation timestamp must have a timezone')
    return result.astimezone(timezone.utc)


def windows_arguments(command):
    """Parse Windows quote/backslash argument rules, rejecting unmatched quotes."""
    if type(command) is not str:
        raise ValueError('Windows command line required')
    args, index = [], 0
    while index < len(command):
        while index < len(command) and command[index] in ' \t': index += 1
        if index == len(command): break
        value, quoted = [], False
        while index < len(command) and (quoted or command[index] not in ' \t'):
            if command[index] == '\\':
                start = index
                while index < len(command) and command[index] == '\\': index += 1
                count = index - start
                if index < len(command) and command[index] == '"':
                    value.extend('\\' * (count // 2))
                    if count % 2:
                        value.append('"'); index += 1
                    elif quoted and index + 1 < len(command) and command[index + 1] == '"':
                        value.append('"'); index += 2
                    else:
                        quoted = not quoted; index += 1
                else:
                    value.extend('\\' * count)
            elif command[index] == '"':
                if quoted and index + 1 < len(command) and command[index + 1] == '"':
                    value.append('"'); index += 2
                else:
                    quoted = not quoted; index += 1
            else:
                value.append(command[index]); index += 1
        if quoted:
            raise ValueError('unmatched command-line quote')
        args.append(''.join(value))
    return args


def bind_owned_pair(launch, recorded, current, configuration):
    """Reject ambiguity; require the exact recorded config and parent/birth chain.

    current must include ALL four Sandbox process names; exactly this pair may
    remain. Executable authentication is separate from process ownership.
    """
    configuration = str(_path(configuration))
    if PureWindowsPath(configuration).name != 'qualification.wsb':
        raise ValueError('only the owned frozen configuration is covered')
    parent = _pid(launch.get('pid'))
    launch_time = _time(launch.get('creationUtc'))
    if type(recorded) is not list or type(current) is not list or len(recorded) != 2 or len(current) != 2:
        raise ValueError('exactly the owned session/server pair must remain')
    by_name, by_pid = {}, {}
    for row in current:
        if type(row) is not dict:
            raise ValueError('process snapshot row required')
        pid, name = _pid(row.get('ProcessId')), row.get('Name')
        if name not in ('WindowsSandboxRemoteSession.exe', 'WindowsSandboxServer.exe') or name in by_name or pid in by_pid:
            raise ValueError('unexpected or duplicate Sandbox process')
        _pid(row.get('ParentProcessId'))
        _time(row.get('CreationDate'))
        executable = str(_path(row.get('ExecutablePath')))
        if PureWindowsPath(executable).name != name or type(row.get('CommandLine')) is not str:
            raise ValueError('process path/command identity missing')
        by_name[name], by_pid[pid] = row, row
    if len({row.get('ProcessId') for row in recorded}) != 2:
        raise ValueError('recorded snapshot must have distinct IDs')
    for row in recorded:
        current_row = by_pid.get(_pid(row.get('ProcessId')))
        if current_row is None or any(row.get(k) != current_row.get(k) for k in
                ('ParentProcessId', 'Name', 'ExecutablePath', 'CommandLine')) or _time(row.get('CreationDate')) != _time(current_row['CreationDate']):
            raise ValueError('recorded process identity changed')
    session, server = by_name['WindowsSandboxRemoteSession.exe'], by_name['WindowsSandboxServer.exe']
    if session['ParentProcessId'] != parent or server['ParentProcessId'] != session['ProcessId']:
        raise ValueError('host process ancestry mismatch')
    delta = (_time(session['CreationDate']) - launch_time).total_seconds()
    if not 0 <= delta <= 5 or _time(server['CreationDate']) < _time(session['CreationDate']):
        raise ValueError('process birth is outside the owned launch chain')
    if sum(arg.casefold() == configuration.casefold() for arg in windows_arguments(session['CommandLine'])) != 1:
        raise ValueError('exact owned configuration token missing')
    if PureWindowsPath(session['ExecutablePath']).parent != PureWindowsPath(server['ExecutablePath']).parent:
        raise ValueError('session and server images differ in package root')
    return {'configuration': configuration, 'launch_pid': parent,
            'session_pid': session['ProcessId'], 'server_pid': server['ProcessId'],
            'session_created': session['CreationDate'], 'server_created': server['CreationDate'],
            'session_executable': session['ExecutablePath'], 'server_executable': server['ExecutablePath'],
            'session_command': session['CommandLine'], 'server_command': server['CommandLine']}


def render_cleanup(launch, recorded, current, configuration):
    """Render PowerShell that rebinds fresh observations and holds both handles.

    The output is a proposal. No launch budget or terminal verdict is granted.
    """
    bound = bind_owned_pair(launch, recorded, current, configuration)
    def quote(value):
        return "'" + str(value).replace("'", "''") + "'"
    lines = ["$ErrorActionPreference = 'Stop'",
             '$expectedIds = @(' + str(bound['session_pid']) + ',' + str(bound['server_pid']) + ')',
             '$all = @(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue)',
             "if($all.Count -ne 2 -or @($all | Where-Object {$_.Id -notin $expectedIds}).Count -ne 0){throw 'Another Sandbox process exists'}"]
    for role in ('session', 'server'):
        pid = bound[role + '_pid']
        lines += [
            '$' + role + "Cim = Get-CimInstance Win32_Process -Filter 'ProcessId=" + str(pid) + "'",
            'if(-not $' + role + 'Cim -or $' + role + 'Cim.ExecutablePath -cne ' + quote(bound[role + '_executable'])
            + ' -or $' + role + 'Cim.CommandLine -cne ' + quote(bound[role + '_command'])
            + ' -or $' + role + 'Cim.CreationDate.ToUniversalTime() -ne ([datetime]' + quote(bound[role + '_created'])
            + ").ToUniversalTime()){throw 'Owned process identity drifted'}",
            '$' + role + ' = Get-Process -Id ' + str(pid),
            '$held' + role + ' = $' + role + '.Handle',
            'if([math]::Abs(($' + role + '.StartTime.ToUniversalTime() - $' + role
            + ".Cim.CreationDate.ToUniversalTime()).TotalMilliseconds) -gt 1){throw 'Held handle identity differs'}"]
    lines += ['Stop-Process -InputObject $session', '$null = $session.WaitForExit(5000)',
              'if(-not $server.HasExited){Stop-Process -InputObject $server; $null = $server.WaitForExit(5000)}',
              "if(Get-Process -Name WindowsSandbox,WindowsSandboxClient,WindowsSandboxRemoteSession,WindowsSandboxServer -ErrorAction SilentlyContinue){throw 'Sandbox exit unverified'}"]
    return '\n'.join(lines) + '\n'
