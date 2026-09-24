$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$containerName = 'elitesync-auth31-isolation-probe'
$imageName = 'mariadb:10.11'
$nonce = [Guid]::NewGuid().ToString('N')
$clock = [Diagnostics.Stopwatch]::StartNew()
$contextName = $null
$createdId = $null
$runAttempted = $false
$firstFailure = $null
$cleanup = 'NOT_CHECKED'
$stage = [ordered]@{ preflight = 'NOT_CHECKED'; start = 'NOT_CHECKED'; inspect = 'NOT_CHECKED'; cleanup = 'NOT_CHECKED' }
$predicate = [ordered]@{
    id_name_match = 'UNKNOWN'
    network_none = 'UNKNOWN'
    port_bindings_empty = 'UNKNOWN'
    binds_empty = 'UNKNOWN'
    tmpfs_targets_match = 'UNKNOWN'
    mounts_count = 'UNKNOWN'
    mounts_all_tmpfs = 'UNKNOWN'
}
$calls = [ordered]@{
    context = 0; daemon = 0; image = 0; name_preflight = 0
    run = 0; inspect = 0; ownership_check = 0; remove = 0; absence_check = 0
}

function Stop-At([string]$code) {
    if ($null -eq $script:firstFailure) { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Invoke-Docker([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    $deadlineMs = if ($forCleanup) { 90000 } else { 75000 }
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
    } finally { $process.Dispose() }
}

function Invoke-Current([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    return Invoke-Docker -dockerArguments (@('--context', $script:contextName) + $dockerArguments) -forCleanup $forCleanup
}

try {
    $calls.context++
    $reply = Invoke-Docker @('context', 'inspect')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stage.preflight = 'FAIL'; Stop-At 'CONTEXT_QUERY_FAILED' }
    try {
        $contexts = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($contexts.Count -ne 1) { Stop-At 'CONTEXT_UNPARSEABLE' }
        $endpoint = [string]$contexts[0].Endpoints.docker.Host
        $contextName = [string]$contexts[0].Name
        if ($endpoint -notmatch '^npipe:////\./pipe/[^/]+$' -and $endpoint -notmatch '^unix:///[^\s]+$') { Stop-At 'CONTEXT_NOT_LOCAL' }
        if ($contextName -notmatch '^[A-Za-z0-9_.-]+$') { Stop-At 'CONTEXT_NAME_UNPARSEABLE' }
    } catch {
        if ($null -eq $firstFailure) { Stop-At 'CONTEXT_UNPARSEABLE' }
        throw
    }

    $calls.daemon++
    $reply = Invoke-Current @('info', '--format', '{{json .ServerVersion}}')
    if ($reply.TimedOut -or $reply.Code -ne 0 -or [string]::IsNullOrWhiteSpace($reply.Out)) {
        $stage.preflight = 'FAIL'; Stop-At 'DAEMON_UNREACHABLE'
    }

    $calls.image++
    $reply = Invoke-Current @('image', 'inspect', $imageName)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stage.preflight = 'FAIL'; Stop-At 'IMAGE_NOT_CONFIRMED' }

    $calls.name_preflight++
    $reply = Invoke-Current @('container', 'inspect', $containerName)
    if ($reply.TimedOut) { $stage.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_TIMEOUT' }
    if ($reply.Code -eq 0) { $stage.preflight = 'FAIL'; Stop-At 'CONTAINER_NAME_OCCUPIED' }
    if ($reply.Err -notmatch '(?i)No such (container|object)') { $stage.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_UNKNOWN' }
    $stage.preflight = 'PASS'

    $calls.run++
    $runAttempted = $true
    $reply = Invoke-Current @(
        'run', '-d', '--name', $containerName, '--pull', 'never', '--network', 'none',
        '--label', "elitesync.auth31.nonce=$nonce",
        '--tmpfs', '/var/lib/mysql:rw,nosuid,noexec,size=128m',
        '--tmpfs', '/run/mysqld:rw,nosuid,size=16m',
        '--tmpfs', '/tmp:rw,nosuid,size=32m',
        '--entrypoint', '/bin/sh', $imageName, '-c', 'sleep 75'
    )
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stage.start = 'FAIL'; Stop-At 'CONTAINER_START_FAILED' }
    $createdId = $reply.Out.Trim()
    if ($createdId -notmatch '^[a-f0-9]{64}$') { $createdId = $null; $stage.start = 'FAIL'; Stop-At 'CREATED_ID_UNPARSEABLE' }
    $stage.start = 'PASS'

    $calls.inspect++
    $reply = Invoke-Current @('container', 'inspect', $createdId)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stage.inspect = 'FAIL'; Stop-At 'ISOLATION_INSPECT_FAILED' }
    try {
        $items = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($items.Count -ne 1) { Stop-At 'ISOLATION_UNPARSEABLE' }
        $item = $items[0]
        $predicate.id_name_match = [bool]($item.Id -eq $createdId -and $item.Name -eq "/$containerName")
        $predicate.network_none = [bool]($item.HostConfig.NetworkMode -eq 'none')
        $portBindings = $item.HostConfig.PortBindings
        $predicate.port_bindings_empty = [bool]($null -eq $portBindings -or @($portBindings.PSObject.Properties).Count -eq 0)
        $binds = $item.HostConfig.Binds
        $predicate.binds_empty = [bool]($null -eq $binds -or @($binds).Count -eq 0)
        $expectedTmpfs = @('/var/lib/mysql', '/run/mysqld', '/tmp')
        $tmpfs = $item.HostConfig.Tmpfs
        $tmpfsKeys = if ($null -eq $tmpfs) { @() } else { @($tmpfs.PSObject.Properties.Name) }
        $predicate.tmpfs_targets_match = [bool]($tmpfsKeys.Count -eq 3 -and @($tmpfsKeys | Where-Object { $_ -notin $expectedTmpfs }).Count -eq 0)
        $mounts = if ($null -eq $item.Mounts) { @() } else { @($item.Mounts) }
        $predicate.mounts_count = [int]$mounts.Count
        $predicate.mounts_all_tmpfs = [bool](@($mounts | Where-Object { $_.Type -ne 'tmpfs' }).Count -eq 0)
    } catch {
        $stage.inspect = 'FAIL'
        if ($null -eq $firstFailure) { Stop-At 'ISOLATION_UNPARSEABLE' }
        throw
    }
    if ($predicate.id_name_match -ne $true -or $predicate.network_none -ne $true -or
        $predicate.port_bindings_empty -ne $true -or $predicate.binds_empty -ne $true -or
        $predicate.tmpfs_targets_match -ne $true -or $predicate.mounts_all_tmpfs -ne $true) {
        $stage.inspect = 'FAIL'; Stop-At 'REQUIRED_ISOLATION_FIELD_MISMATCH'
    }
    $stage.inspect = 'PASS'
} catch {
    if ($null -eq $firstFailure) { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stage.preflight -eq 'NOT_CHECKED') { $stage.preflight = 'FAIL' }
} finally {
    if ($runAttempted -and $null -eq $createdId -and $null -ne $contextName) {
        $calls.ownership_check++
        try {
            $ownerReply = Invoke-Current @('container', 'inspect', $containerName) $true
            if (-not $ownerReply.TimedOut -and $ownerReply.Code -eq 0) {
                $owned = @($ownerReply.Out | ConvertFrom-Json -ErrorAction Stop)
                if ($owned.Count -eq 1 -and $owned[0].Name -eq "/$containerName" -and
                    $owned[0].Config.Labels.PSObject.Properties['elitesync.auth31.nonce'].Value -eq $nonce -and
                    [string]$owned[0].Id -match '^[a-f0-9]{64}$') {
                    $createdId = [string]$owned[0].Id
                }
            }
        } catch { }
    }
    if ($null -ne $createdId) {
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
                } else { $cleanup = 'CLEANUP_FAILED' }
            }
        } catch { $cleanup = 'CLEANUP_FAILED' }
    } elseif ($runAttempted) {
        $cleanup = 'CLEANUP_UNRESOLVED'
    } else {
        $cleanup = 'NOT_NEEDED'
    }
    $stage.cleanup = $cleanup
    if ($cleanup -eq 'CLEANUP_FAILED' -or $cleanup -eq 'CLEANUP_UNRESOLVED') {
        if ($null -eq $firstFailure) { $firstFailure = $cleanup }
    }
}

[ordered]@{
    stage = $stage
    predicates = $predicate
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    cleanup = $cleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
    calls = $calls
} | ConvertTo-Json -Depth 5 -Compress
