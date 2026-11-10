$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$containerName = 'elitesync-auth30-synthetic-restore'
$imageName = 'mariadb:10.11'
$fakePassword = 'AUTH30_FAKE_ONLY_DO_NOT_REUSE_9073'
$nonce = [Guid]::NewGuid().ToString('N')
$clock = [Diagnostics.Stopwatch]::StartNew()
$contextName = $null
$createdId = $null
$runAttempted = $false
$firstFailure = $null
$cleanup = 'NOT_CHECKED'
$stages = [ordered]@{
    preflight = 'NOT_CHECKED'
    start = 'NOT_CHECKED'
    isolation = 'NOT_CHECKED'
    synthetic_dump_restore = 'NOT_CHECKED'
    validation = 'NOT_CHECKED'
    cleanup = 'NOT_CHECKED'
}
$calls = [ordered]@{
    context = 0; daemon = 0; image = 0; name_preflight = 0; run = 0
    isolation_inspect = 0; readiness = 0; setup = 0; dump = 0
    restore_schema = 0; restore = 0; validation = 0; remove = 0
    absence_check = 0; ownership_check = 0
}

function Stop-At([string]$code) {
    if ($null -eq $script:firstFailure) { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Invoke-Docker([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    $deadlineMs = if ($forCleanup) { 120000 } else { 105000 }
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
    } finally {
        $process.Dispose()
    }
}

function Invoke-Current([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    return Invoke-Docker -dockerArguments (@('--context', $script:contextName) + $dockerArguments) -forCleanup $forCleanup
}

try {
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
        '--label', "elitesync.auth30.nonce=$nonce",
        '--tmpfs', '/var/lib/mysql:rw,nosuid,noexec,size=128m',
        '--tmpfs', '/run/mysqld:rw,nosuid,size=16m',
        '--tmpfs', '/tmp:rw,nosuid,size=32m',
        '-e', "MARIADB_ROOT_PASSWORD=$fakePassword", $imageName
    )
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.start = 'FAIL'; Stop-At 'CONTAINER_START_FAILED' }
    $createdId = $reply.Out.Trim()
    if ($createdId -notmatch '^[a-f0-9]{64}$') { $createdId = $null; $stages.start = 'FAIL'; Stop-At 'CREATED_ID_UNPARSEABLE' }
    $stages.start = 'PASS'

    $calls.isolation_inspect++
    $reply = Invoke-Current @('container', 'inspect', $createdId)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.isolation = 'FAIL'; Stop-At 'ISOLATION_INSPECT_FAILED' }
    try {
        $inspected = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($inspected.Count -ne 1) { Stop-At 'ISOLATION_UNPARSEABLE' }
        $item = $inspected[0]
        $allowedTmpfs = @('/var/lib/mysql', '/run/mysqld', '/tmp')
        $tmpfsKeys = @($item.HostConfig.Tmpfs.PSObject.Properties.Name)
        $mounts = @($item.Mounts)
        $mountsOk = $mounts.Count -eq 3
        foreach ($mount in $mounts) {
            if ($mount.Type -ne 'tmpfs' -or $mount.Destination -notin $allowedTmpfs) { $mountsOk = $false }
        }
        $portsOk = $null -eq $item.HostConfig.PortBindings -or @($item.HostConfig.PortBindings.PSObject.Properties).Count -eq 0
        $bindsOk = $null -eq $item.HostConfig.Binds -or @($item.HostConfig.Binds).Count -eq 0
        if ($item.Id -ne $createdId -or $item.Name -ne "/$containerName" -or
            $item.HostConfig.NetworkMode -ne 'none' -or -not $portsOk -or -not $bindsOk -or
            $tmpfsKeys.Count -ne 3 -or @($tmpfsKeys | Where-Object { $_ -notin $allowedTmpfs }).Count -ne 0 -or
            -not $mountsOk) {
            Stop-At 'ISOLATION_DECLARATION_MISMATCH'
        }
    } catch {
        $stages.isolation = 'FAIL'
        if ($null -eq $firstFailure) { Stop-At 'ISOLATION_UNPARSEABLE' }
        throw
    }
    $stages.isolation = 'PASS'

    if ($clock.ElapsedMilliseconds + 20000 -ge 105000) { Stop-At 'WAIT_BUDGET_EXHAUSTED' }
    Start-Sleep -Seconds 20
    $calls.readiness++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'mariadb-admin', '-uroot', 'ping')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.synthetic_dump_restore = 'FAIL'; Stop-At 'DB_NOT_READY' }

    $calls.setup++
    $setupSql = "CREATE DATABASE auth30_source; CREATE TABLE auth30_source.probe (id INT PRIMARY KEY, token VARCHAR(32) NOT NULL); INSERT INTO auth30_source.probe VALUES (1,'alpha-fiction'),(2,'beta-fiction'),(3,'gamma-fiction');"
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'mariadb', '-uroot', '-e', $setupSql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.synthetic_dump_restore = 'FAIL'; Stop-At 'SYNTHETIC_SETUP_FAILED' }

    $calls.dump++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'sh', '-c', 'mariadb-dump --no-defaults -uroot auth30_source probe > /tmp/auth30.sql')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.synthetic_dump_restore = 'FAIL'; Stop-At 'SYNTHETIC_DUMP_FAILED' }

    $calls.restore_schema++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'mariadb', '-uroot', '-e', 'CREATE DATABASE auth30_restored;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.synthetic_dump_restore = 'FAIL'; Stop-At 'RESTORE_SCHEMA_FAILED' }

    $calls.restore++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'sh', '-c', 'mariadb -uroot auth30_restored < /tmp/auth30.sql')
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.synthetic_dump_restore = 'FAIL'; Stop-At 'SYNTHETIC_RESTORE_FAILED' }
    $stages.synthetic_dump_restore = 'PASS'

    $calls.validation++
    $checkSql = "SELECT COUNT(*),SHA2(GROUP_CONCAT(CONCAT(id,':',token) ORDER BY id SEPARATOR '|'),256) FROM auth30_source.probe; SELECT COUNT(*),SHA2(GROUP_CONCAT(CONCAT(id,':',token) ORDER BY id SEPARATOR '|'),256) FROM auth30_restored.probe;"
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $containerName, 'mariadb', '-uroot', '--batch', '--skip-column-names', '-e', $checkSql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { $stages.validation = 'FAIL'; Stop-At 'VALIDATION_QUERY_FAILED' }
    $rows = @($reply.Out.Trim() -split "`r?`n")
    $expectedText = '1:alpha-fiction|2:beta-fiction|3:gamma-fiction'
    $hashBytes = [Security.Cryptography.SHA256]::Create().ComputeHash([Text.Encoding]::UTF8.GetBytes($expectedText))
    $expectedHash = [BitConverter]::ToString($hashBytes).Replace('-', '').ToLowerInvariant()
    if ($rows.Count -ne 2 -or $rows[0] -ne "3`t$expectedHash" -or $rows[1] -ne "3`t$expectedHash") {
        $stages.validation = 'FAIL'; Stop-At 'SYNTHETIC_CONTENT_MISMATCH'
    }
    $stages.validation = 'PASS'
} catch {
    if ($null -eq $firstFailure) { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($runAttempted -and $null -eq $createdId -and $null -ne $contextName) {
        $calls.ownership_check++
        try {
            $ownerReply = Invoke-Current @('container', 'inspect', $containerName) $true
            if (-not $ownerReply.TimedOut -and $ownerReply.Code -eq 0) {
                $owned = @($ownerReply.Out | ConvertFrom-Json -ErrorAction Stop)
                if ($owned.Count -eq 1 -and $owned[0].Name -eq "/$containerName" -and
                    $owned[0].Config.Labels.PSObject.Properties['elitesync.auth30.nonce'].Value -eq $nonce -and
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
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    cleanup = $cleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
    calls = $calls
} | ConvertTo-Json -Depth 5 -Compress
