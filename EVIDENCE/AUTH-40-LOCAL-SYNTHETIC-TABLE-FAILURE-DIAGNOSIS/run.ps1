$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$containerName = 'elitesync-auth40-table-probe'
$imageName = 'mariadb:10.11'
$fakePassword = 'AUTH40_FAKE_ONLY_DO_NOT_REUSE_8163'
$parserPath = Join-Path -Path $PSScriptRoot -ChildPath '..\AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR\parse_mounts.ps1'
$expectedParserHash = 'AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974'
$nonce = [Guid]::NewGuid().ToString('N')
$clock = [Diagnostics.Stopwatch]::StartNew()
$contextName = $null
$createdId = $null
$ownershipConfirmed = $false
$containerStartedMs = $null
$runAttempted = $false
$firstFailure = $null
$cleanup = 'NOT_CHECKED'
$stages = [ordered]@{
    preflight = 'NOT_CHECKED'
    start = 'NOT_CHECKED'
    isolation = 'NOT_CHECKED'
    socket = 'NOT_CHECKED'
    source_schema = 'NOT_CHECKED'
    original_table = 'NOT_CHECKED'
    control_table = 'NOT_CHECKED'
    cleanup = 'NOT_CHECKED'
}
$originalCode = 'NOT_CHECKED'
$controlCode = 'NOT_CHECKED'
$isolationFacts = [ordered]@{
    id_name_match = 'UNKNOWN'
    network_none = 'UNKNOWN'
    port_bindings_empty = 'UNKNOWN'
    binds_empty = 'UNKNOWN'
    tmpfs_targets_match = 'UNKNOWN'
    mounts_count = 'UNKNOWN'
    mounts_parse_ok = 'UNKNOWN'
    mounts_all_tmpfs = 'UNKNOWN'
    mounts_destinations_allowed = 'UNKNOWN'
}
$calls = [ordered]@{
    parser_read = 0; context = 0; daemon = 0; image = 0; name_preflight = 0; run = 0
    isolation_inspect = 0; socket = 0; source_schema = 0; original_table = 0
    control_table = 0
    remove = 0
    absence_check = 0; ownership_check = 0
}

function Stop-At([string]$code) {
    if ($null -eq $script:firstFailure) { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Get-SafeErrorCode([object]$reply) {
    if ($reply.TimedOut) { return 'UNRECOGNIZED/UNKNOWN' }
    $found = [regex]::Matches([string]$reply.Err, '(?i)\bERROR\s+([0-9]+)\b')
    if ($found.Count -ne 1) { return 'UNRECOGNIZED/UNKNOWN' }
    $code = $found[0].Groups[1].Value
    if ($code -cin @('1064', '1005', '1030', '1114', '1044', '1049', '1142', '1050')) { return $code }
    return 'UNRECOGNIZED/UNKNOWN'
}

function Invoke-Docker([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    $deadlineMs = if ($forCleanup) { 145000 } else { 110000 }
    $remainingMs = $deadlineMs - [int]$script:clock.ElapsedMilliseconds
    if ($remainingMs -le 0) {
        return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $true }
    }
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'docker'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.CreateNoWindow = $true
    foreach ($part in $dockerArguments) { [void]$startInfo.ArgumentList.Add($part) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $startInfo
    try {
        if (-not $process.Start()) {
            return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $false }
        }
        $outTask = $process.StandardOutput.ReadToEndAsync()
        $errTask = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($remainingMs)) {
            $process.Kill($true)
            $process.WaitForExit()
            return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $true }
        }
        return [pscustomobject]@{
            Code = $process.ExitCode
            Out = $outTask.GetAwaiter().GetResult()
            Err = $errTask.GetAwaiter().GetResult()
            TimedOut = $false
        }
    } catch {
        return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $false }
    } finally {
        $process.Dispose()
    }
}

function Invoke-Current([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    return Invoke-Docker -dockerArguments (@('--context', $script:contextName) + $dockerArguments) -forCleanup $forCleanup
}

try {
    $calls.parser_read++
    try {
        if ((Get-FileHash -LiteralPath $parserPath -Algorithm SHA256 -ErrorAction Stop).Hash -cne $expectedParserHash) {
            $stages.preflight = 'FAIL'; Stop-At 'ACCEPTED_PARSER_HASH_MISMATCH'
        }
        . $parserPath
        if ($null -eq (Get-Command -Name Parse-Mounts -CommandType Function -ErrorAction Stop)) {
            $stages.preflight = 'FAIL'; Stop-At 'ACCEPTED_PARSER_UNAVAILABLE'
        }
    } catch {
        if ($null -eq $firstFailure) { $stages.preflight = 'FAIL'; Stop-At 'ACCEPTED_PARSER_UNAVAILABLE' }
        throw
    }

    $calls.context++
    $reply = Invoke-Docker @('context', 'inspect')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.preflight = 'FAIL'; Stop-At 'CONTEXT_QUERY_FAILED' }
    try {
        $contexts = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($contexts.Count -ne 1) { Stop-At 'CONTEXT_UNPARSEABLE' }
        $endpoint = [string]$contexts[0].Endpoints.docker.Host
        $contextName = [string]$contexts[0].Name
        if ($endpoint -notmatch '^npipe:////\./pipe/[^/]+$' -and $endpoint -notmatch '^unix:///[^\s]+$') {
            Stop-At 'CONTEXT_NOT_LOCAL'
        }
        if ($contextName -notmatch '^[A-Za-z0-9_.-]+$') { Stop-At 'CONTEXT_NAME_UNPARSEABLE' }
    } catch {
        if ($null -eq $firstFailure) { Stop-At 'CONTEXT_UNPARSEABLE' }
        throw
    }

    $calls.daemon++
    $reply = Invoke-Current @('info', '--format', '{{json .ServerVersion}}')
    if ($reply.TimedOut -or $reply.Code -ne 0 -or [string]::IsNullOrWhiteSpace($reply.Out)) {
        $stages.preflight = 'FAIL'; Stop-At 'DAEMON_UNREACHABLE'
    }

    $calls.image++
    $reply = Invoke-Current @('image', 'inspect', $imageName)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.preflight = 'FAIL'; Stop-At 'IMAGE_NOT_CONFIRMED' }

    $calls.name_preflight++
    $reply = Invoke-Current @('container', 'inspect', $containerName)
    if ($reply.TimedOut) { $stages.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_TIMEOUT' }
    if ($reply.Code -eq 0) { $stages.preflight = 'FAIL'; Stop-At 'CONTAINER_NAME_OCCUPIED' }
    if ($reply.Err -notmatch '(?i)No such (container|object)') {
        $stages.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_UNKNOWN'
    }
    $stages.preflight = 'PASS'

    $calls.run++
    $runAttempted = $true
    $reply = Invoke-Current @(
        'run', '-d', '--name', $containerName, '--pull', 'never', '--network', 'none',
        '--label', "elitesync.auth40.nonce=$nonce",
        '--tmpfs', '/var/lib/mysql:rw,nosuid,noexec,size=128m',
        '--tmpfs', '/run/mysqld:rw,nosuid,size=16m',
        '--tmpfs', '/tmp:rw,nosuid,size=32m',
        '-e', "MARIADB_ROOT_PASSWORD=$fakePassword", $imageName
    )
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.start = 'FAIL'; Stop-At 'CONTAINER_START_FAILED' }
    $createdId = $reply.Out.Trim()
    if ($createdId -notmatch '^[a-f0-9]{64}$') { $createdId = $null; $stages.start = 'FAIL'; Stop-At 'CREATED_ID_UNPARSEABLE' }
    $containerStartedMs = [int]$clock.ElapsedMilliseconds
    $stages.start = 'PASS'

    $calls.isolation_inspect++
    $reply = Invoke-Current @('container', 'inspect', $createdId)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.isolation = 'FAIL'; Stop-At 'ISOLATION_INSPECT_FAILED' }
    try {
        $inspected = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($inspected.Count -ne 1) { Stop-At 'ISOLATION_UNPARSEABLE' }
        $item = $inspected[0]
        $allowedTmpfs = @('/var/lib/mysql', '/run/mysqld', '/tmp')
        [string[]]$tmpfsKeys = @()
        if ($null -ne $item.HostConfig.Tmpfs) {
            $tmpfsKeys = @($item.HostConfig.Tmpfs.PSObject.Properties.Name)
        }
        $isolationFacts.id_name_match = [bool]($item.Id -ceq $createdId -and $item.Name -ceq "/$containerName" -and
            $item.Config.Labels.PSObject.Properties['elitesync.auth40.nonce'].Value -ceq $nonce)
        $ownershipConfirmed = $isolationFacts.id_name_match
        $isolationFacts.network_none = [bool]($item.HostConfig.NetworkMode -eq 'none')
        $isolationFacts.port_bindings_empty = [bool]($null -eq $item.HostConfig.PortBindings -or @($item.HostConfig.PortBindings.PSObject.Properties).Count -eq 0)
        $isolationFacts.binds_empty = [bool]($null -eq $item.HostConfig.Binds -or @($item.HostConfig.Binds).Count -eq 0)
        $isolationFacts.tmpfs_targets_match = [bool]($tmpfsKeys.Count -eq 3 -and @($tmpfsKeys | Where-Object { $_ -notin $allowedTmpfs }).Count -eq 0)
        if ($isolationFacts.id_name_match -ne $true -or $isolationFacts.network_none -ne $true -or
            $isolationFacts.port_bindings_empty -ne $true -or $isolationFacts.binds_empty -ne $true -or
            $isolationFacts.tmpfs_targets_match -ne $true) {
            Stop-At 'BASIC_ISOLATION_MISMATCH'
        }
        $mountResult = Parse-Mounts -Mounts $item.Mounts
        $isolationFacts.mounts_count = $mountResult.count
        $isolationFacts.mounts_parse_ok = $mountResult.parse_ok
        $isolationFacts.mounts_all_tmpfs = $mountResult.all_tmpfs
        $isolationFacts.mounts_destinations_allowed = $mountResult.destinations_allowed
        $emptyMountsSafe = $mountResult.parse_ok -eq $true -and $mountResult.count -is [int] -and $mountResult.count -eq 0
        $nonemptyMountsSafe = $mountResult.parse_ok -eq $true -and $mountResult.count -is [int] -and
            $mountResult.count -gt 0 -and $mountResult.all_tmpfs -eq $true -and $mountResult.destinations_allowed -eq $true
        if (-not $emptyMountsSafe -and -not $nonemptyMountsSafe) { Stop-At 'MOUNTS_ISOLATION_MISMATCH' }
    } catch {
        $stages.isolation = 'FAIL'
        if ($null -eq $firstFailure) { Stop-At 'ISOLATION_UNPARSEABLE' }
        throw
    }
    $stages.isolation = 'PASS'

    $targetMs = $containerStartedMs + 45000
    if ($targetMs -ge 110000) { $stages.socket = 'FAIL'; Stop-At 'SOCKET_TIME_BUDGET_EXHAUSTED' }
    $waitMs = $targetMs - [int]$clock.ElapsedMilliseconds
    if ($waitMs -gt 0) { Start-Sleep -Milliseconds $waitMs }

    $calls.socket++
    $reply = Invoke-Current @('exec', $createdId, 'mariadb', '-uroot', '--batch', '--skip-column-names', '-e', 'SELECT 1;')
    if ($reply.TimedOut -or $reply.Code -ne 0 -or $reply.Out.Trim() -cne '1') {
        $stages.socket = 'FAIL'; Stop-At 'SOCKET_SELECT_FAILED'
    }
    $stages.socket = 'PASS'

    $calls.source_schema++
    $reply = Invoke-Current @('exec', $createdId, 'mariadb', '-uroot', '-e', 'CREATE DATABASE auth40_source;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.source_schema = 'FAIL'; Stop-At 'SOURCE_SCHEMA_FAILED' }
    $stages.source_schema = 'PASS'

    $calls.original_table++
    $reply = Invoke-Current @('exec', $createdId, 'mariadb', '-uroot', 'auth40_source', '-e', 'CREATE TABLE sample_items (id INT PRIMARY KEY, label VARCHAR(32) NOT NULL, amount INT NOT NULL);')
    if (-not $reply.TimedOut -and $reply.Code -eq 0) {
        $stages.original_table = 'PASS'; $originalCode = 'NONE'
    } else {
        $stages.original_table = 'FAIL'
        $originalCode = Get-SafeErrorCode $reply
        if ($null -eq $firstFailure) { $firstFailure = 'ORIGINAL_TABLE_FAILED' }
        if ($originalCode -cne '1064') { Stop-At 'ORIGINAL_TABLE_FAILED' }

        $calls.control_table++
        $reply = Invoke-Current @('exec', $createdId, 'mariadb', '-uroot', 'auth40_source', '-e', 'CREATE TABLE sample_items (id INT PRIMARY KEY, item_text VARCHAR(32) NOT NULL, amount INT NOT NULL);')
        if (-not $reply.TimedOut -and $reply.Code -eq 0) {
            $stages.control_table = 'PASS'; $controlCode = 'NONE'
        } else {
            $stages.control_table = 'FAIL'
            $controlCode = Get-SafeErrorCode $reply
        }
    }
} catch {
    if ($null -eq $firstFailure) { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($runAttempted -and -not $ownershipConfirmed -and $null -ne $contextName) {
        $calls.ownership_check++
        try {
            $ownerReply = Invoke-Current @('container', 'inspect', $containerName) $true
            if (-not $ownerReply.TimedOut -and $ownerReply.Code -eq 0) {
                $owned = @($ownerReply.Out | ConvertFrom-Json -ErrorAction Stop)
                if ($owned.Count -eq 1 -and $owned[0].Name -ceq "/$containerName" -and
                    $owned[0].Config.Labels.PSObject.Properties['elitesync.auth40.nonce'].Value -ceq $nonce -and
                    [string]$owned[0].Id -match '^[a-f0-9]{64}$') {
                    $createdId = [string]$owned[0].Id
                    $ownershipConfirmed = $true
                }
            }
        } catch { }
    }
    if ($ownershipConfirmed -and $null -ne $createdId) {
        $calls.remove++
        try {
            $removeReply = Invoke-Current @('rm', '-f', $createdId) $true
            if ($removeReply.TimedOut -or $removeReply.Code -ne 0) {
                $cleanup = 'CLEANUP_FAILED'
            } else {
                $calls.absence_check++
                $absenceReply = Invoke-Current @('container', 'inspect', $containerName) $true
                if (-not $absenceReply.TimedOut -and $absenceReply.Code -ne 0 -and
                    $absenceReply.Err -match '(?i)No such (container|object)') {
                    $cleanup = 'PASS'
                } else {
                    $cleanup = 'CLEANUP_FAILED'
                }
            }
        } catch { $cleanup = 'CLEANUP_FAILED' }
    } elseif ($runAttempted) {
        $cleanup = 'CLEANUP_UNRESOLVED'
    } else {
        $cleanup = 'NOT_NEEDED'
    }
    $stages.cleanup = $cleanup
    if ($cleanup -eq 'CLEANUP_FAILED' -or $cleanup -eq 'CLEANUP_UNRESOLVED') {
        if ($null -eq $firstFailure) { $firstFailure = $cleanup }
    }
}

[ordered]@{
    stages = $stages
    original_code = $originalCode
    control_code = $controlCode
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    cleanup = $cleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
    calls = $calls
} | ConvertTo-Json -Depth 5 -Compress
