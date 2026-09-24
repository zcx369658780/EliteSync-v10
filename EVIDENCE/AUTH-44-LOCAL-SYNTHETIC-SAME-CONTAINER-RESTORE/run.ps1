$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$containerName = 'elitesync-auth44-synthetic-restore'
$imageName = 'mariadb:10.11'
$fakePassword = 'Auth44_Synthetic_Only_2026'
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
    df_space = 'NOT_CHECKED'
    auth = 'NOT_CHECKED'
    source_schema = 'NOT_CHECKED'
    source_table = 'NOT_CHECKED'
    insert_rows = 'NOT_CHECKED'
    source_verify = 'NOT_CHECKED'
    dump = 'NOT_CHECKED'
    target_schema = 'NOT_CHECKED'
    import = 'NOT_CHECKED'
    target_verify = 'NOT_CHECKED'
    cleanup = 'NOT_CHECKED'
}
$space = 'UNKNOWN'
$sourceCountThree = 'NOT_CHECKED'
$sourceContent = 'NOT_CHECKED'
$targetCountThree = 'NOT_CHECKED'
$targetContent = 'NOT_CHECKED'
$sourceTargetEqual = 'NOT_CHECKED'
$failureExit = 'NOT_CHECKED'
$failureError = 'NOT_CHECKED'
$isolationFacts = [ordered]@{
    id_name_match = 'UNKNOWN'
    fake_password_env_match = 'UNKNOWN'
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
    isolation_inspect = 0; df_space = 0; auth = 0; source_schema = 0
    source_table = 0; insert_rows = 0; source_verify = 0; dump = 0
    target_schema = 0; import = 0; target_verify = 0
    remove = 0
    absence_check = 0; ownership_check = 0
}

function Stop-At([string]$code) {
    if ($null -eq $script:firstFailure) { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Get-SafeErrorCode([object]$reply) {
    if ($reply.TimedOut) { return 'UNKNOWN' }
    $found = [regex]::Matches([string]$reply.Err, '(?i)\bERROR\s+([0-9]+)\b')
    if ($found.Count -ne 1) { return 'UNKNOWN' }
    $number = [int]0
    if (-not [int]::TryParse($found[0].Groups[1].Value, [ref]$number)) { return 'UNKNOWN' }
    if ($number -lt 1 -or $number -gt 65535) { return 'UNKNOWN' }
    return $number
}

function Get-SafeExit([object]$reply) {
    if ($reply.TimedOut -or $reply.Code -lt 0 -or $reply.Code -gt 255) { return 'UNKNOWN' }
    return [int]$reply.Code
}

function Parse-Df([object]$reply) {
    if ($reply.TimedOut -or $reply.Code -ne 0) { return $null }
    $found = [regex]::Matches([string]$reply.Out, '(?m)^\S+\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+[0-9]+%\s+/var/lib/mysql\s*$')
    if ($found.Count -ne 1) { return $null }
    $values = @()
    for ($i = 1; $i -le 3; $i++) {
        $number = [long]0
        if (-not [long]::TryParse($found[0].Groups[$i].Value, [ref]$number)) { return $null }
        $values += $number
    }
    return [pscustomobject][ordered]@{ size_kib = $values[0]; used_kib = $values[1]; available_kib = $values[2] }
}

function Fail-Command([string]$stage, [string]$code, [object]$reply) {
    $script:stages[$stage] = 'FAIL'
    $script:failureExit = Get-SafeExit $reply
    $script:failureError = Get-SafeErrorCode $reply
    Stop-At $code
}

function Invoke-Docker([string[]]$dockerArguments, [bool]$forCleanup = $false) {
    $deadlineMs = if ($forCleanup) { 205000 } else { 160000 }
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
        '--label', "elitesync.auth44.nonce=$nonce",
        '--tmpfs', '/var/lib/mysql:rw,nosuid,noexec,size=512m',
        '--tmpfs', '/run/mysqld:rw,nosuid,size=16m',
        '--tmpfs', '/tmp:rw,nosuid,size=64m',
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
            $item.Config.Labels.PSObject.Properties['elitesync.auth44.nonce'].Value -ceq $nonce)
        $ownershipConfirmed = $isolationFacts.id_name_match
        $passwordEntries = @($item.Config.Env | Where-Object { $_ -is [string] -and $_ -clike 'MARIADB_ROOT_PASSWORD=*' })
        $isolationFacts.fake_password_env_match = [bool]($passwordEntries.Count -eq 1 -and $passwordEntries[0] -ceq "MARIADB_ROOT_PASSWORD=$fakePassword")
        $isolationFacts.network_none = [bool]($item.HostConfig.NetworkMode -eq 'none')
        $isolationFacts.port_bindings_empty = [bool]($null -eq $item.HostConfig.PortBindings -or @($item.HostConfig.PortBindings.PSObject.Properties).Count -eq 0)
        $isolationFacts.binds_empty = [bool]($null -eq $item.HostConfig.Binds -or @($item.HostConfig.Binds).Count -eq 0)
        $isolationFacts.tmpfs_targets_match = [bool]($tmpfsKeys.Count -eq 3 -and @($tmpfsKeys | Where-Object { $_ -notin $allowedTmpfs }).Count -eq 0 -and
            $item.HostConfig.Tmpfs.'/var/lib/mysql' -ceq 'rw,nosuid,noexec,size=512m' -and
            $item.HostConfig.Tmpfs.'/run/mysqld' -ceq 'rw,nosuid,size=16m' -and
            $item.HostConfig.Tmpfs.'/tmp' -ceq 'rw,nosuid,size=64m')
        if ($isolationFacts.id_name_match -ne $true -or $isolationFacts.fake_password_env_match -ne $true -or $isolationFacts.network_none -ne $true -or
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
    if ($targetMs -ge 160000) { $stages.auth = 'FAIL'; Stop-At 'AUTH_TIME_BUDGET_EXHAUSTED' }
    $waitMs = $targetMs - [int]$clock.ElapsedMilliseconds
    if ($waitMs -gt 0) { Start-Sleep -Milliseconds $waitMs }

    $calls.df_space++
    $reply = Invoke-Current @('exec', $createdId, 'df', '-Pk', '/var/lib/mysql')
    $space = Parse-Df $reply
    if ($null -eq $space) { $space = 'UNKNOWN'; $stages.df_space = 'FAIL'; Stop-At 'DF_SPACE_UNPARSEABLE' }
    $stages.df_space = 'PASS'

    if ($space.available_kib -lt 131072) { $stages.df_space = 'FAIL'; Stop-At 'DF_SPACE_BELOW_THRESHOLD' }

    $calls.auth++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', '--batch', '--skip-column-names', '-e', 'SELECT 1;')
    if ($reply.TimedOut -or $reply.Code -ne 0 -or $reply.Out.Trim() -cne '1') { Fail-Command 'auth' 'AUTH_SELECT_FAILED' $reply }
    $stages.auth = 'PASS'

    $calls.source_schema++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', '-e', 'CREATE DATABASE auth44_source;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_schema' 'SOURCE_SCHEMA_FAILED' $reply }
    $stages.source_schema = 'PASS'

    $calls.source_table++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', 'auth44_source', '-e', 'CREATE TABLE sample_rows (id INT PRIMARY KEY, label VARCHAR(16) NOT NULL);')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_table' 'SOURCE_TABLE_FAILED' $reply }
    $stages.source_table = 'PASS'

    $calls.insert_rows++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', 'auth44_source', '-e', "INSERT INTO sample_rows VALUES (1,'alpha'),(2,'beta'),(3,'gamma');")
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'insert_rows' 'INSERT_ROWS_FAILED' $reply }
    $stages.insert_rows = 'PASS'

    $verifySql = "SELECT COUNT(*), GROUP_CONCAT(CONCAT(id, ':', label) ORDER BY id SEPARATOR ',') FROM sample_rows;"
    $calls.source_verify++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', '--batch', '--skip-column-names', 'auth44_source', '-e', $verifySql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_verify' 'SOURCE_VERIFY_QUERY_FAILED' $reply }
    $sourceCountThree = [bool]($reply.Out.Trim() -match '^3\t')
    $sourceContent = [bool]($reply.Out.Trim() -ceq "3`t1:alpha,2:beta,3:gamma")
    if (-not $sourceContent) { Fail-Command 'source_verify' 'SOURCE_CONTENT_MISMATCH' $reply }
    $stages.source_verify = 'PASS'

    $calls.dump++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'sh', '-c', 'mariadb-dump --no-defaults -uroot auth44_source sample_rows > /tmp/auth44_sample.sql')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'dump' 'DUMP_FAILED' $reply }
    $stages.dump = 'PASS'

    $calls.target_schema++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', '-e', 'CREATE DATABASE auth44_target;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'target_schema' 'TARGET_SCHEMA_FAILED' $reply }
    $stages.target_schema = 'PASS'

    $calls.import++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'sh', '-c', 'mariadb -uroot auth44_target < /tmp/auth44_sample.sql')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'import' 'IMPORT_FAILED' $reply }
    $stages.import = 'PASS'

    $calls.target_verify++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$fakePassword", $createdId, 'mariadb', '-uroot', '--batch', '--skip-column-names', 'auth44_target', '-e', $verifySql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'target_verify' 'TARGET_VERIFY_QUERY_FAILED' $reply }
    $targetCountThree = [bool]($reply.Out.Trim() -match '^3\t')
    $targetContent = [bool]($reply.Out.Trim() -ceq "3`t1:alpha,2:beta,3:gamma")
    $sourceTargetEqual = [bool]($sourceContent -eq $true -and $targetContent -eq $true)
    if (-not $sourceTargetEqual) { Fail-Command 'target_verify' 'TARGET_CONTENT_MISMATCH' $reply }
    $stages.target_verify = 'PASS'
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
                    $owned[0].Config.Labels.PSObject.Properties['elitesync.auth44.nonce'].Value -ceq $nonce -and
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
    space = $space
    isolation = $isolationFacts
    source_count_three = $sourceCountThree
    source_fixed_content = $sourceContent
    target_count_three = $targetCountThree
    target_fixed_content = $targetContent
    source_target_equal = $sourceTargetEqual
    failure_exit_code = $failureExit
    failure_error_number = $failureError
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    cleanup = $cleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
    calls = $calls
} | ConvertTo-Json -Depth 5 -Compress
