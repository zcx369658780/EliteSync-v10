$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$sourceName = 'elitesync-auth45-source'
$targetName = 'elitesync-auth45-target'
$imageName = 'mariadb:10.11'
$sourcePassword = 'Auth45_Source_Only_2026'
$targetPassword = 'Auth45_Target_Only_2026'
$parserPath = Join-Path -Path $PSScriptRoot -ChildPath '..\AUTH-32-DOCKER-MOUNTS-PARSER-STATIC-REPAIR\parse_mounts.ps1'
$expectedParserHash = 'AA11EA742604C2EA9B76EF81EA8C4CD19E678D1C4E368AD421EB38D66F20D974'
$clock = [Diagnostics.Stopwatch]::StartNew()
$contextName = $null
$activeName = $null
$activePassword = $null
$activeNonce = $null
$activeId = $null
$activeOwnership = $false
$activeRunAttempted = $false
$activeCleanupAttempted = $false
$activeStartedMs = $null
$firstFailure = $null
$sourceCleanup = 'NOT_CHECKED'
$targetCleanup = 'NOT_CHECKED'
$dumpBytes = $null
$dumpByteCount = 'NOT_CHECKED'
$stages = [ordered]@{
    preflight = 'NOT_CHECKED'
    source_start = 'NOT_CHECKED'
    source_isolation = 'NOT_CHECKED'
    source_df = 'NOT_CHECKED'
    source_auth = 'NOT_CHECKED'
    source_schema = 'NOT_CHECKED'
    source_table = 'NOT_CHECKED'
    insert_rows = 'NOT_CHECKED'
    source_verify = 'NOT_CHECKED'
    dump = 'NOT_CHECKED'
    source_cleanup = 'NOT_CHECKED'
    target_start = 'NOT_CHECKED'
    target_isolation = 'NOT_CHECKED'
    target_df = 'NOT_CHECKED'
    target_auth = 'NOT_CHECKED'
    target_schema = 'NOT_CHECKED'
    import = 'NOT_CHECKED'
    target_verify = 'NOT_CHECKED'
    target_cleanup = 'NOT_CHECKED'
}
$sourceSpace = 'UNKNOWN'
$targetSpace = 'UNKNOWN'
$sourceCountThree = 'NOT_CHECKED'
$sourceContent = 'NOT_CHECKED'
$targetCountThree = 'NOT_CHECKED'
$targetContent = 'NOT_CHECKED'
$sourceTargetEqual = 'NOT_CHECKED'
$failureExit = 'NOT_CHECKED'
$failureError = 'NOT_CHECKED'
$sourceIsolation = 'UNKNOWN'
$targetIsolation = 'UNKNOWN'
$calls = [ordered]@{
    parser_read = 0; context = 0; daemon = 0; image = 0; source_name_preflight = 0; target_name_preflight = 0
    source_run = 0; source_inspect = 0; source_df = 0; source_auth = 0; source_schema = 0
    source_table = 0; insert_rows = 0; source_verify = 0; dump = 0
    source_remove = 0; source_absence = 0; source_ownership = 0
    target_run = 0; target_inspect = 0; target_df = 0; target_auth = 0
    target_schema = 0; import = 0; target_verify = 0
    target_remove = 0; target_absence = 0; target_ownership = 0
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

function Invoke-Docker([string[]]$dockerArguments, [bool]$forCleanup = $false, [AllowNull()][byte[]]$inputBytes = $null) {
    $deadlineMs = if ($forCleanup) { 295000 } else { 240000 }
    $remainingMs = $deadlineMs - [int]$script:clock.ElapsedMilliseconds
    if ($remainingMs -le 0) {
        return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $true }
    }
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = 'docker'
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $startInfo.RedirectStandardInput = $null -ne $inputBytes
    $startInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false, $true)
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
        if ($null -ne $inputBytes) {
            $writeTask = $process.StandardInput.BaseStream.WriteAsync($inputBytes, 0, $inputBytes.Length)
            if (-not $writeTask.Wait($remainingMs)) {
                $process.Kill($true); $process.WaitForExit()
                return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $true }
            }
            $process.StandardInput.Close()
        }
        $remainingMs = $deadlineMs - [int]$script:clock.ElapsedMilliseconds
        if ($remainingMs -le 0) {
            $process.Kill($true); $process.WaitForExit()
            return [pscustomobject]@{ Code = -1; Out = ''; Err = ''; TimedOut = $true }
        }
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

function Invoke-Current([string[]]$dockerArguments, [bool]$forCleanup = $false, [AllowNull()][byte[]]$inputBytes = $null) {
    return Invoke-Docker -dockerArguments (@('--context', $script:contextName) + $dockerArguments) -forCleanup $forCleanup -inputBytes $inputBytes
}

function Start-Active([string]$phase, [string]$name, [string]$password) {
    $script:activeName = $name
    $script:activePassword = $password
    $script:activeNonce = [Guid]::NewGuid().ToString('N')
    $script:activeId = $null
    $script:activeOwnership = $false
    $script:activeRunAttempted = $true
    $script:activeCleanupAttempted = $false
    $script:calls["${phase}_run"]++
    $reply = Invoke-Current @(
        'run', '-d', '--name', $name, '--pull', 'never', '--network', 'none',
        '--label', "elitesync.auth45.nonce=$($script:activeNonce)",
        '--tmpfs', '/var/lib/mysql:rw,nosuid,noexec,size=512m',
        '--tmpfs', '/run/mysqld:rw,nosuid,size=16m',
        '--tmpfs', '/tmp:rw,nosuid,size=64m',
        '-e', "MARIADB_ROOT_PASSWORD=$password", $imageName
    )
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command "${phase}_start" 'CONTAINER_START_FAILED' $reply }
    $script:activeId = $reply.Out.Trim()
    if ($script:activeId -notmatch '^[a-f0-9]{64}$') {
        $script:activeId = $null
        $script:stages["${phase}_start"] = 'FAIL'
        Stop-At 'CREATED_ID_UNPARSEABLE'
    }
    $script:activeStartedMs = [int]$script:clock.ElapsedMilliseconds
    $script:stages["${phase}_start"] = 'PASS'
}

function Check-Active([string]$phase) {
    $script:calls["${phase}_inspect"]++
    $reply = Invoke-Current @('container', 'inspect', $script:activeId)
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command "${phase}_isolation" 'ISOLATION_INSPECT_FAILED' $reply }
    try {
        $items = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
        if ($items.Count -ne 1) { Stop-At 'ISOLATION_UNPARSEABLE' }
        $item = $items[0]
        $keys = @($item.HostConfig.Tmpfs.PSObject.Properties.Name)
        $passwordEntries = @($item.Config.Env | Where-Object { $_ -is [string] -and $_ -clike 'MARIADB_ROOT_PASSWORD=*' })
        $facts = [ordered]@{
            id_name_nonce = [bool]($item.Id -ceq $script:activeId -and $item.Name -ceq "/$($script:activeName)" -and
                $item.Config.Labels.PSObject.Properties['elitesync.auth45.nonce'].Value -ceq $script:activeNonce)
            password_match = [bool]($passwordEntries.Count -eq 1 -and $passwordEntries[0] -ceq "MARIADB_ROOT_PASSWORD=$($script:activePassword)")
            network_none = [bool]($item.HostConfig.NetworkMode -ceq 'none')
            ports_empty = [bool]($null -eq $item.HostConfig.PortBindings -or @($item.HostConfig.PortBindings.PSObject.Properties).Count -eq 0)
            binds_empty = [bool]($null -eq $item.HostConfig.Binds -or @($item.HostConfig.Binds).Count -eq 0)
            tmpfs_exact = [bool]($keys.Count -eq 3 -and @($keys | Where-Object { $_ -notin @('/var/lib/mysql','/run/mysqld','/tmp') }).Count -eq 0 -and
                $item.HostConfig.Tmpfs.'/var/lib/mysql' -ceq 'rw,nosuid,noexec,size=512m' -and
                $item.HostConfig.Tmpfs.'/run/mysqld' -ceq 'rw,nosuid,size=16m' -and
                $item.HostConfig.Tmpfs.'/tmp' -ceq 'rw,nosuid,size=64m')
        }
        $script:activeOwnership = $facts.id_name_nonce
        $mount = Parse-Mounts -Mounts $item.Mounts
        $facts.mounts_count = $mount.count
        $facts.mounts_parse_ok = $mount.parse_ok
        $facts.mounts_all_tmpfs = $mount.all_tmpfs
        $facts.mounts_destinations_allowed = $mount.destinations_allowed
        $mountSafe = $mount.parse_ok -eq $true -and $mount.count -is [int] -and
            ($mount.count -eq 0 -or ($mount.count -gt 0 -and $mount.all_tmpfs -eq $true -and $mount.destinations_allowed -eq $true))
        if ($phase -eq 'source') { $script:sourceIsolation = $facts } else { $script:targetIsolation = $facts }
        if (-not $facts.id_name_nonce -or -not $facts.password_match -or -not $facts.network_none -or
            -not $facts.ports_empty -or -not $facts.binds_empty -or -not $facts.tmpfs_exact -or -not $mountSafe) {
            Stop-At 'ISOLATION_MISMATCH'
        }
    } catch {
        $script:stages["${phase}_isolation"] = 'FAIL'
        if ($null -eq $script:firstFailure) { Stop-At 'ISOLATION_UNPARSEABLE' }
        throw
    }
    $script:stages["${phase}_isolation"] = 'PASS'
}

function Check-Ready([string]$phase) {
    if ($script:activeStartedMs + 45000 -ge 240000) { Stop-At 'READINESS_TIME_BUDGET_EXHAUSTED' }
    $waitMs = $script:activeStartedMs + 45000 - [int]$script:clock.ElapsedMilliseconds
    if ($waitMs -gt 0) { Start-Sleep -Milliseconds $waitMs }
    $script:calls["${phase}_df"]++
    $reply = Invoke-Current @('exec', $script:activeId, 'df', '-Pk', '/var/lib/mysql')
    $space = Parse-Df $reply
    if ($null -eq $space) { $script:stages["${phase}_df"] = 'FAIL'; Stop-At 'DF_UNPARSEABLE' }
    if ($phase -eq 'source') { $script:sourceSpace = $space } else { $script:targetSpace = $space }
    if ($space.available_kib -lt 131072) { $script:stages["${phase}_df"] = 'FAIL'; Stop-At 'DF_BELOW_THRESHOLD' }
    $script:stages["${phase}_df"] = 'PASS'
    $script:calls["${phase}_auth"]++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$($script:activePassword)", $script:activeId,
        'mariadb', '-uroot', '--batch', '--skip-column-names', '-e', 'SELECT 1;')
    if ($reply.TimedOut -or $reply.Code -ne 0 -or $reply.Out.Trim() -cne '1') { Fail-Command "${phase}_auth" 'AUTH_SELECT_FAILED' $reply }
    $script:stages["${phase}_auth"] = 'PASS'
}

function Cleanup-Active([string]$phase) {
    if (-not $script:activeRunAttempted) { return 'NOT_NEEDED' }
    $script:activeCleanupAttempted = $true
    if (-not $script:activeOwnership) {
        $script:calls["${phase}_ownership"]++
        try {
            $reply = Invoke-Current @('container', 'inspect', $script:activeName) $true
            if (-not $reply.TimedOut -and $reply.Code -eq 0) {
                $items = @($reply.Out | ConvertFrom-Json -ErrorAction Stop)
                if ($items.Count -eq 1 -and $items[0].Name -ceq "/$($script:activeName)" -and
                    $items[0].Config.Labels.PSObject.Properties['elitesync.auth45.nonce'].Value -ceq $script:activeNonce -and
                    [string]$items[0].Id -match '^[a-f0-9]{64}$') {
                    $script:activeId = [string]$items[0].Id
                    $script:activeOwnership = $true
                }
            }
        } catch { }
    }
    if (-not $script:activeOwnership -or $null -eq $script:activeId) { return 'CLEANUP_UNRESOLVED' }
    $script:calls["${phase}_remove"]++
    $reply = Invoke-Current @('rm', '-f', $script:activeId) $true
    if ($reply.TimedOut -or $reply.Code -ne 0) { return 'CLEANUP_FAILED' }
    $script:calls["${phase}_absence"]++
    $reply = Invoke-Current @('container', 'inspect', $script:activeName) $true
    if (-not $reply.TimedOut -and $reply.Code -ne 0 -and $reply.Err -match '(?i)No such (container|object)') {
        $script:activeRunAttempted = $false
        $script:activeId = $null
        return 'PASS'
    }
    return 'CLEANUP_FAILED'
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

    foreach ($entry in @(@('source', $sourceName), @('target', $targetName))) {
        $phase = [string]$entry[0]; $name = [string]$entry[1]
        $calls["$($phase)_name_preflight"]++
        $reply = Invoke-Current @('container', 'inspect', $name)
        if ($reply.TimedOut) { $stages.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_TIMEOUT' }
        if ($reply.Code -eq 0) { $stages.preflight = 'FAIL'; Stop-At 'CONTAINER_NAME_OCCUPIED' }
        if ($reply.Err -notmatch '(?i)No such (container|object)') {
            $stages.preflight = 'FAIL'; Stop-At 'NAME_PREFLIGHT_UNKNOWN'
        }
    }
    $stages.preflight = 'PASS'

    Start-Active 'source' $sourceName $sourcePassword
    Check-Active 'source'
    Check-Ready 'source'

    $calls.source_schema++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$sourcePassword", $activeId,
        'mariadb', '-uroot', '-e', 'CREATE DATABASE auth45_source;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_schema' 'SOURCE_SCHEMA_FAILED' $reply }
    $stages.source_schema = 'PASS'

    $calls.source_table++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$sourcePassword", $activeId,
        'mariadb', '-uroot', 'auth45_source', '-e',
        'CREATE TABLE sample_rows (id INT PRIMARY KEY, label VARCHAR(16) NOT NULL);')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_table' 'SOURCE_TABLE_FAILED' $reply }
    $stages.source_table = 'PASS'

    $calls.insert_rows++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$sourcePassword", $activeId,
        'mariadb', '-uroot', 'auth45_source', '-e',
        "INSERT INTO sample_rows VALUES (1,'alpha'),(2,'beta'),(3,'gamma');")
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'insert_rows' 'INSERT_ROWS_FAILED' $reply }
    $stages.insert_rows = 'PASS'

    $verifySql = "SELECT COUNT(*), GROUP_CONCAT(CONCAT(id, ':', label) ORDER BY id SEPARATOR ',') FROM sample_rows;"
    $expectedRows = '3' + [char]9 + '1:alpha,2:beta,3:gamma'
    $calls.source_verify++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$sourcePassword", $activeId,
        'mariadb', '-uroot', '--batch', '--skip-column-names', 'auth45_source', '-e', $verifySql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'source_verify' 'SOURCE_VERIFY_QUERY_FAILED' $reply }
    $sourceCountThree = [bool]($reply.Out.Trim() -match '^3\t')
    $sourceContent = [bool]($reply.Out.Trim() -ceq $expectedRows)
    if (-not $sourceContent) { Fail-Command 'source_verify' 'SOURCE_CONTENT_MISMATCH' $reply }
    $stages.source_verify = 'PASS'

    $calls.dump++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$sourcePassword", $activeId,
        'mariadb-dump', '--no-defaults', '-uroot', 'auth45_source', 'sample_rows')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'dump' 'DUMP_FAILED' $reply }
    if ([string]::IsNullOrEmpty($reply.Out)) { Fail-Command 'dump' 'DUMP_EMPTY' $reply }
    $dumpBytes = [Text.UTF8Encoding]::new($false, $true).GetBytes($reply.Out)
    $dumpByteCount = $dumpBytes.Length
    $reply = $null
    if ($dumpByteCount -gt 262144) { $stages.dump = 'FAIL'; Stop-At 'DUMP_OVER_LIMIT' }
    $stages.dump = 'PASS'

    $sourceCleanup = Cleanup-Active 'source'
    $stages.source_cleanup = $sourceCleanup
    if ($sourceCleanup -cne 'PASS') { Stop-At 'SOURCE_CLEANUP_FAILED' }

    Start-Active 'target' $targetName $targetPassword
    Check-Active 'target'
    Check-Ready 'target'

    $calls.target_schema++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$targetPassword", $activeId,
        'mariadb', '-uroot', '-e', 'CREATE DATABASE auth45_target;')
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'target_schema' 'TARGET_SCHEMA_FAILED' $reply }
    $stages.target_schema = 'PASS'

    $calls.import++
    $reply = Invoke-Current -dockerArguments @('exec', '-i', '-e', "MYSQL_PWD=$targetPassword", $activeId,
        'mariadb', '-uroot', 'auth45_target') -inputBytes $dumpBytes
    [Array]::Clear($dumpBytes, 0, $dumpBytes.Length)
    $dumpBytes = $null
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'import' 'IMPORT_FAILED' $reply }
    $stages.import = 'PASS'

    $calls.target_verify++
    $reply = Invoke-Current @('exec', '-e', "MYSQL_PWD=$targetPassword", $activeId,
        'mariadb', '-uroot', '--batch', '--skip-column-names', 'auth45_target', '-e', $verifySql)
    if ($reply.TimedOut -or $reply.Code -ne 0) { Fail-Command 'target_verify' 'TARGET_VERIFY_QUERY_FAILED' $reply }
    $targetCountThree = [bool]($reply.Out.Trim() -match '^3\t')
    $targetContent = [bool]($reply.Out.Trim() -ceq $expectedRows)
    $sourceTargetEqual = [bool]($sourceContent -eq $true -and $targetContent -eq $true)
    if (-not $sourceTargetEqual) { Fail-Command 'target_verify' 'TARGET_CONTENT_MISMATCH' $reply }
    $stages.target_verify = 'PASS'
} catch {
    if ($null -eq $firstFailure) { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($activeRunAttempted -and -not $activeCleanupAttempted) {
        if ($activeName -ceq $sourceName) {
            $sourceCleanup = Cleanup-Active 'source'
            $stages.source_cleanup = $sourceCleanup
        } elseif ($activeName -ceq $targetName) {
            $targetCleanup = Cleanup-Active 'target'
            $stages.target_cleanup = $targetCleanup
        }
    }
    if ($null -ne $dumpBytes) {
        [Array]::Clear($dumpBytes, 0, $dumpBytes.Length)
        $dumpBytes = $null
    }
    if ($sourceCleanup -cin @('CLEANUP_FAILED', 'CLEANUP_UNRESOLVED') -or
        $targetCleanup -cin @('CLEANUP_FAILED', 'CLEANUP_UNRESOLVED')) {
        if ($null -eq $firstFailure) { $firstFailure = 'CLEANUP_FAILED' }
    }
}

[ordered]@{
    stages = $stages
    source_space = $sourceSpace
    target_space = $targetSpace
    source_isolation = $sourceIsolation
    target_isolation = $targetIsolation
    dump_bytes = $dumpByteCount
    source_count_three = $sourceCountThree
    source_fixed_content = $sourceContent
    target_count_three = $targetCountThree
    target_fixed_content = $targetContent
    source_target_equal = $sourceTargetEqual
    failure_exit_code = $failureExit
    failure_error_number = $failureError
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    source_cleanup = $sourceCleanup
    target_cleanup = $targetCleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
    calls = $calls
} | ConvertTo-Json -Depth 6 -Compress
