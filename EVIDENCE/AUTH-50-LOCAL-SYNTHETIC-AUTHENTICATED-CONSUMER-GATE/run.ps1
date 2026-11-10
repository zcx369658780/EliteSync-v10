$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$fixedParent = 'C:\Users\zcxve\AppData\Local\Temp'
$fixedDir = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth50-synthetic-gate'
$backupDir = 'C:\Users\zcxve\EliteSync-v10-DB-Backups'
$keysDir = 'C:\Users\zcxve\EliteSync-v10-DB-Keys'
$configPath = 'C:\Users\zcxve\miniconda3\Library\ssl\openssl.cnf'
$expectedHash = 'A65A2CB9F4EE8FFDC7EF4F0AC600C0BDAFB95B7B1AB457188AC610A62F5AD6B3'
$fixedBytes = [Text.Encoding]::UTF8.GetBytes('AUTH50-SYNTHETIC-ONLY')
$bufferLimit = 65536
$clock = [Diagnostics.Stopwatch]::StartNew()
$created = $false
$safeParent = $false
$firstFailure = 'NONE'
$cleanup = 'NOT_CHECKED'
$opensslVersion = 'UNKNOWN'
$configHashMatch = 'UNKNOWN'
$opensslPath = $null
$exitCodes = [ordered]@{ certificate = 'NOT_CHECKED'; encrypt = 'NOT_CHECKED'; normal = 'NOT_CHECKED'; tampered = 'NOT_CHECKED' }
$stages = [ordered]@{ preflight = 'NOT_CHECKED'; create_temp = 'NOT_CHECKED'; certificate = 'NOT_CHECKED'; encrypt = 'NOT_CHECKED'; normal = 'NOT_CHECKED'; tamper = 'NOT_CHECKED'; tampered = 'NOT_CHECKED'; cleanup = 'NOT_CHECKED' }
$calls = [ordered]@{ certificate = 0; encrypt = 0; normal = 0; tampered = 0; normal_consumer = 0; tampered_consumer = 0; remove = 0 }
$normalReceived = 0
$tamperedReceived = 0
$normalMatch = $false
$tamperedMatch = $false
$normalObserved = $false
$tamperedObserved = $false
$normalCleared = $false
$tamperedCleared = $false

function Stop-At([string]$code) {
    if ($script:firstFailure -eq 'NONE') { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Is-EmptyDirectory([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    if ($item -isnot [IO.DirectoryInfo] -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { return $false }
    $iterator = [IO.Directory]::EnumerateFileSystemEntries($path).GetEnumerator()
    try { return -not $iterator.MoveNext() } finally { $iterator.Dispose() }
}

# Every subprocess uses byte-oriented stdout. Nothing reaches a consumer here.
function Invoke-BoundedOpenSsl([string[]]$arguments) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $script:opensslPath
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in $arguments) { [void]$info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    $buffer = [byte[]]::new($script:bufferLimit)
    $chunk = [byte[]]::new(4096)
    $count = 0
    $started = $false
    $code = 'UNKNOWN'
    $timedOut = $false
    $overLimit = $false
    $observed = $false
    $bytes = $null
    try {
        $remaining = 105000 - [int]$script:clock.ElapsedMilliseconds
        if ($remaining -le 0) { $timedOut = $true }
        elseif ($process.Start()) {
            $started = $true
            $stderrDrain = $process.StandardError.BaseStream.CopyToAsync([IO.Stream]::Null)
            while ($true) {
                $remaining = 105000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0) { $timedOut = $true; break }
                $readTask = $process.StandardOutput.BaseStream.ReadAsync($chunk, 0, $chunk.Length)
                if (-not $readTask.Wait($remaining)) { $timedOut = $true; break }
                $read = $readTask.GetAwaiter().GetResult()
                if ($read -eq 0) { break }
                $observed = $true
                if ($read -gt $script:bufferLimit - $count) { $overLimit = $true; break }
                [Array]::Copy($chunk, 0, $buffer, $count, $read)
                $count += $read
            }
            if (-not $timedOut -and -not $overLimit) {
                $remaining = 105000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0 -or -not $process.WaitForExit($remaining)) { $timedOut = $true }
                else { $code = [int]$process.ExitCode }
            }
            if ($code -is [int] -and $code -eq 0 -and -not $timedOut -and -not $overLimit) {
                $bytes = [byte[]]::new($count)
                [Array]::Copy($buffer, $bytes, $count)
            }
        }
    } catch {
        $code = 'UNKNOWN'
        if ($null -ne $bytes) { [Array]::Clear($bytes, 0, $bytes.Length); $bytes = $null }
    } finally {
        if ($started -and -not $process.HasExited) {
            try { $process.Kill($true); [void]$process.WaitForExit(1000) } catch { }
        }
        [Array]::Clear($buffer, 0, $buffer.Length)
        [Array]::Clear($chunk, 0, $chunk.Length)
        $process.Dispose()
    }
    return [pscustomobject]@{ code = $code; timeout = $timedOut; over_limit = $overLimit; observed = $observed; cleared = ($null -eq $bytes); bytes = $bytes }
}

function Consume-Synthetic([byte[]]$bytes) {
    return [pscustomobject]@{
        received = $bytes.Length
        matches = [bool]([Linq.Enumerable]::SequenceEqual([byte[]]$script:fixedBytes, $bytes))
    }
}

try {
    $command = Get-Command -Name openssl -CommandType Application -ErrorAction Stop | Select-Object -First 1
    $opensslPath = $command.Source
    $reply = Invoke-BoundedOpenSsl @('version')
    if ($reply.timeout -or $reply.over_limit -or $reply.code -ne 0) { $stages.preflight = 'FAIL'; Stop-At 'OPENSSL_VERSION_FAILED' }
    $version = [Text.Encoding]::ASCII.GetString($reply.bytes)
    [Array]::Clear($reply.bytes, 0, $reply.bytes.Length)
    $match = [regex]::Match($version, '^OpenSSL\s+(3\.[0-9]+\.[0-9]+)\b')
    if (-not $match.Success) { $stages.preflight = 'FAIL'; Stop-At 'OPENSSL_NOT_VERSION_3' }
    $opensslVersion = $match.Groups[1].Value

    $config = Get-Item -LiteralPath $configPath -Force -ErrorAction Stop
    if ($config -isnot [IO.FileInfo] -or ($config.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or
        [IO.Path]::GetFullPath($configPath) -cne $configPath -or $config.FullName -cne $configPath) {
        $stages.preflight = 'FAIL'; Stop-At 'CONFIG_PATH_UNSAFE'
    }
    $configHashMatch = [bool]((Get-FileHash -LiteralPath $configPath -Algorithm SHA256).Hash -ceq $expectedHash)
    if (-not $configHashMatch) { $stages.preflight = 'FAIL'; Stop-At 'CONFIG_HASH_MISMATCH' }

    $parent = Get-Item -LiteralPath $fixedParent -Force -ErrorAction Stop
    $canonicalParent = [IO.Path]::GetFullPath($fixedParent)
    $canonicalDir = [IO.Path]::GetFullPath($fixedDir)
    $reportedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
    $safeParent = [bool]($parent -is [IO.DirectoryInfo] -and
        ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
        $canonicalParent -ceq $fixedParent -and $canonicalParent -ceq $reportedTemp -and
        $canonicalDir -ceq $fixedDir -and [IO.Path]::GetDirectoryName($canonicalDir) -ceq $canonicalParent)
    if (-not $safeParent) { $stages.preflight = 'FAIL'; Stop-At 'TEMP_PARENT_UNSAFE' }
    if (Test-Path -LiteralPath $fixedDir) { $stages.preflight = 'FAIL'; Stop-At 'TEMP_TARGET_OCCUPIED' }
    if (-not (Is-EmptyDirectory $backupDir)) { $stages.preflight = 'FAIL'; Stop-At 'BACKUP_DIRECTORY_NOT_EMPTY' }
    if (-not (Is-EmptyDirectory $keysDir)) { $stages.preflight = 'FAIL'; Stop-At 'KEY_DIRECTORY_NOT_EMPTY' }
    $stages.preflight = 'PASS'

    [void](New-Item -ItemType Directory -Path $fixedDir -ErrorAction Stop)
    $created = $true
    $stages.create_temp = 'PASS'
    $key = Join-Path $fixedDir 'synthetic.key.pem'
    $cert = Join-Path $fixedDir 'synthetic.cert.pem'
    $plain = Join-Path $fixedDir 'synthetic.input.bin'
    $cipher = Join-Path $fixedDir 'synthetic.cms.der'
    $tampered = Join-Path $fixedDir 'synthetic.tampered.der'

    $calls.certificate++
    $reply = Invoke-BoundedOpenSsl @('req','-config',$configPath,'-x509','-newkey','rsa:3072','-nodes',
        '-keyout',$key,'-out',$cert,'-days','1','-subj','/CN=AUTH50-SYNTHETIC-ONLY')
    $exitCodes.certificate = $reply.code
    if ($reply.timeout -or $reply.over_limit -or $reply.code -ne 0) { $stages.certificate = 'FAIL'; Stop-At 'CERTIFICATE_FAILED' }
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length) }
    $stages.certificate = 'PASS'

    [IO.File]::WriteAllBytes($plain, $fixedBytes)
    $calls.encrypt++
    $reply = Invoke-BoundedOpenSsl @('cms','-encrypt','-binary','-stream','-outform','DER','-aes-256-gcm',
        '-in',$plain,'-out',$cipher,$cert)
    $exitCodes.encrypt = $reply.code
    if ($reply.timeout -or $reply.over_limit -or $reply.code -ne 0) { $stages.encrypt = 'FAIL'; Stop-At 'CMS_ENCRYPT_FAILED' }
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length) }
    $cipherBytes = [IO.File]::ReadAllBytes($cipher)
    if ($cipherBytes.Length -le 64) { $stages.encrypt = 'FAIL'; Stop-At 'CIPHERTEXT_TOO_SHORT' }
    $stages.encrypt = 'PASS'

    $calls.normal++
    $reply = Invoke-BoundedOpenSsl @('cms','-decrypt','-binary','-inform','DER','-in',$cipher,'-recip',$cert,'-inkey',$key)
    $exitCodes.normal = $reply.code
    $normalObserved = $reply.observed
    $normalCleared = $reply.cleared
    if ($reply.timeout -or $reply.over_limit -or $reply.code -ne 0) { $stages.normal = 'FAIL'; Stop-At 'NORMAL_DECRYPT_FAILED' }
    try {
        if (-not [Linq.Enumerable]::SequenceEqual([byte[]]$fixedBytes, [byte[]]$reply.bytes)) {
            $stages.normal = 'FAIL'; Stop-At 'NORMAL_CONTENT_MISMATCH'
        }
        $calls.normal_consumer++
        $consumed = Consume-Synthetic $reply.bytes
        $normalReceived = $consumed.received
        $normalMatch = $consumed.matches
    } finally {
        if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length); $normalCleared = $true }
    }
    if (-not $normalMatch -or $normalReceived -ne $fixedBytes.Length) { $stages.normal = 'FAIL'; Stop-At 'NORMAL_CONSUMER_MISMATCH' }
    $stages.normal = 'PASS'

    $tamperedBytes = [byte[]]$cipherBytes.Clone()
    $flipIndex = $tamperedBytes.Length - 1
    while ($flipIndex -gt 32 -and $tamperedBytes[$flipIndex] -eq 0) { $flipIndex-- }
    if ($flipIndex -le 32 -or ($tamperedBytes.Length - 1 - $flipIndex) -gt 16) { $stages.tamper = 'FAIL'; Stop-At 'TAMPER_INDEX_UNSAFE' }
    $tamperedBytes[$flipIndex] = $tamperedBytes[$flipIndex] -bxor 1
    [IO.File]::WriteAllBytes($tampered, $tamperedBytes)
    $stages.tamper = 'PASS'

    $calls.tampered++
    $reply = Invoke-BoundedOpenSsl @('cms','-decrypt','-binary','-inform','DER','-in',$tampered,'-recip',$cert,'-inkey',$key)
    $exitCodes.tampered = $reply.code
    $tamperedObserved = $reply.observed
    $tamperedCleared = $reply.cleared
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length); $tamperedCleared = $true }
    if ($reply.timeout -or $reply.over_limit -or $reply.code -isnot [int] -or $reply.code -eq 0 -or
        -not $tamperedCleared -or $calls.tampered_consumer -ne 0 -or $tamperedReceived -ne 0) {
        $stages.tampered = 'FAIL'; Stop-At 'TAMPER_GATE_FAILED'
    }
    $stages.tampered = 'PASS'
} catch {
    if ($firstFailure -eq 'NONE') { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($created) {
        try {
            $resolved = [IO.Path]::GetFullPath($fixedDir)
            $actual = Get-Item -LiteralPath $fixedDir -Force -ErrorAction Stop
            $parentAgain = Get-Item -LiteralPath $fixedParent -Force -ErrorAction Stop
            $mayDelete = $safeParent -and $resolved -ceq $fixedDir -and
                [IO.Path]::GetDirectoryName($resolved) -ceq $fixedParent -and
                $actual -is [IO.DirectoryInfo] -and
                ($actual.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
                ($parentAgain.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0
            if (-not $mayDelete) { $cleanup = 'CLEANUP_UNRESOLVED' }
            else {
                $calls.remove++
                Remove-Item -LiteralPath $fixedDir -Recurse -Force -ErrorAction Stop
                $cleanup = if (Test-Path -LiteralPath $fixedDir) { 'CLEANUP_FAILED' } else { 'PASS' }
            }
        } catch { $cleanup = 'CLEANUP_UNRESOLVED' }
    } else { $cleanup = 'NOT_NEEDED' }
    $stages.cleanup = $cleanup
    if ($cleanup -ne 'PASS' -and $cleanup -ne 'NOT_NEEDED' -and $firstFailure -eq 'NONE') { $firstFailure = $cleanup }
}

[ordered]@{
    stages = $stages; calls = $calls; openssl_version = $opensslVersion
    config_hash_match = $configHashMatch; buffer_limit_bytes = $bufferLimit
    exit_codes = $exitCodes; normal_buffered_bytes_observed = $normalObserved
    normal_buffer_cleared = $normalCleared; normal_consumer_bytes = $normalReceived
    normal_consumer_match = $normalMatch; tampered_buffered_bytes_observed = $tamperedObserved
    tampered_buffer_cleared = $tamperedCleared; tampered_consumer_bytes = $tamperedReceived
    tampered_consumer_match = $tamperedMatch; cleanup = $cleanup
    first_failure = $firstFailure; elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
} | ConvertTo-Json -Depth 5 -Compress
