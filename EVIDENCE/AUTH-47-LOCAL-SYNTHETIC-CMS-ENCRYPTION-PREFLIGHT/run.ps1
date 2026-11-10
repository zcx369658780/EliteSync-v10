$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$fixedParent = 'C:\Users\zcxve\AppData\Local\Temp'
$fixedDir = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth47-synthetic-cms'
$backupDir = 'C:\Users\zcxve\EliteSync-v10-DB-Backups'
$fixedBytes = [Text.Encoding]::UTF8.GetBytes('AUTH47-SYNTHETIC-ONLY')
$clock = [Diagnostics.Stopwatch]::StartNew()
$created = $false
$safeParent = $false
$firstFailure = $null
$cleanup = 'NOT_CHECKED'
$cipherLength = 'NOT_CHECKED'
$plainMatches = 'NOT_CHECKED'
$tamperRejected = 'NOT_CHECKED'
$opensslVersion = 'UNKNOWN'
$exitCodes = [ordered]@{ certificate = 'NOT_CHECKED'; encrypt = 'NOT_CHECKED'; decrypt = 'NOT_CHECKED'; tamper_decrypt = 'NOT_CHECKED' }
$stages = [ordered]@{
    preflight = 'NOT_CHECKED'; create_temp = 'NOT_CHECKED'; certificate = 'NOT_CHECKED'
    input = 'NOT_CHECKED'; encrypt = 'NOT_CHECKED'; decrypt = 'NOT_CHECKED'
    tamper = 'NOT_CHECKED'; tamper_decrypt = 'NOT_CHECKED'; backup_empty_after = 'NOT_CHECKED'
    cleanup = 'NOT_CHECKED'
}
$calls = [ordered]@{
    openssl_lookup = 0; openssl_version = 0; temp_parent = 0; temp_absence = 0
    backup_empty_before = 0; create_temp = 0; certificate = 0; input_write = 0
    encrypt = 0; decrypt = 0; tamper_copy = 0; tamper_decrypt = 0
    backup_empty_after = 0; remove = 0; absence_check = 0
}
$opensslPath = $null

function Stop-At([string]$code) {
    if ($null -eq $script:firstFailure) { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Is-EmptyDirectory([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    if ($item -isnot [IO.DirectoryInfo] -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { return $false }
    $iterator = [IO.Directory]::EnumerateFileSystemEntries($path).GetEnumerator()
    try { return -not $iterator.MoveNext() } finally { $iterator.Dispose() }
}

function Invoke-OpenSsl([string[]]$arguments) {
    $remaining = 105000 - [int]$script:clock.ElapsedMilliseconds
    if ($remaining -le 0) { return [pscustomobject]@{ code = 'UNKNOWN'; timeout = $true } }
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $script:opensslPath
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($arg in $arguments) { [void]$info.ArgumentList.Add($arg) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    try {
        if (-not $process.Start()) { return [pscustomobject]@{ code = 'UNKNOWN'; timeout = $false } }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        if (-not $process.WaitForExit($remaining)) {
            $process.Kill($true); $process.WaitForExit()
            return [pscustomobject]@{ code = 'UNKNOWN'; timeout = $true }
        }
        $safeOut = $stdout.GetAwaiter().GetResult()
        [void]$stderr.GetAwaiter().GetResult()
        return [pscustomobject]@{ code = [int]$process.ExitCode; timeout = $false; out = $safeOut }
    } catch {
        return [pscustomobject]@{ code = 'UNKNOWN'; timeout = $false }
    } finally { $process.Dispose() }
}

try {
    $calls.openssl_lookup++
    try {
        $command = Get-Command -Name openssl -CommandType Application -ErrorAction Stop | Select-Object -First 1
        $opensslPath = $command.Source
    } catch { $stages.preflight = 'FAIL'; Stop-At 'OPENSSL_UNAVAILABLE' }

    $calls.openssl_version++
    $versionReply = Invoke-OpenSsl @('version')
    if ($versionReply.timeout -or $versionReply.code -ne 0) { $stages.preflight = 'FAIL'; Stop-At 'OPENSSL_VERSION_FAILED' }
    $versionMatch = [regex]::Match([string]$versionReply.out, '^OpenSSL\s+(3\.[0-9]+\.[0-9]+)\b')
    if (-not $versionMatch.Success) { $stages.preflight = 'FAIL'; Stop-At 'OPENSSL_NOT_VERSION_3' }
    $opensslVersion = $versionMatch.Groups[1].Value

    $calls.temp_parent++
    $parent = Get-Item -LiteralPath $fixedParent -Force -ErrorAction Stop
    $canonicalParent = [IO.Path]::GetFullPath($fixedParent)
    $canonicalDir = [IO.Path]::GetFullPath($fixedDir)
    $reportedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
    $safeParent = [bool]($parent -is [IO.DirectoryInfo] -and
        ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
        $canonicalParent -ceq $fixedParent -and $canonicalParent -ceq $reportedTemp -and
        $canonicalDir -ceq $fixedDir -and
        [IO.Path]::GetDirectoryName($canonicalDir) -ceq $canonicalParent)
    if (-not $safeParent) { $stages.preflight = 'FAIL'; Stop-At 'TEMP_PARENT_UNSAFE' }

    $calls.temp_absence++
    if (Test-Path -LiteralPath $fixedDir) { $stages.preflight = 'FAIL'; Stop-At 'TEMP_TARGET_OCCUPIED' }

    $calls.backup_empty_before++
    if (-not (Is-EmptyDirectory $backupDir)) { $stages.preflight = 'FAIL'; Stop-At 'BACKUP_DIRECTORY_NOT_EMPTY_OR_UNKNOWN' }
    $stages.preflight = 'PASS'

    $calls.create_temp++
    [void](New-Item -ItemType Directory -Path $fixedDir -ErrorAction Stop)
    $created = $true
    $stages.create_temp = 'PASS'
    $key = Join-Path $fixedDir 'synthetic.key.pem'
    $cert = Join-Path $fixedDir 'synthetic.cert.pem'
    $plain = Join-Path $fixedDir 'synthetic.input.bin'
    $cipher = Join-Path $fixedDir 'synthetic.cms.der'
    $restored = Join-Path $fixedDir 'synthetic.restored.bin'
    $tampered = Join-Path $fixedDir 'synthetic.tampered.der'
    $tamperedOutput = Join-Path $fixedDir 'synthetic.tampered.out'

    $calls.certificate++
    $reply = Invoke-OpenSsl @('req','-x509','-newkey','rsa:3072','-nodes','-keyout',$key,
        '-out',$cert,'-days','1','-subj','/CN=AUTH47-SYNTHETIC-ONLY')
    $exitCodes.certificate = $reply.code
    if ($reply.timeout -or $reply.code -ne 0) { $stages.certificate = 'FAIL'; Stop-At 'CERTIFICATE_FAILED' }
    $stages.certificate = 'PASS'

    $calls.input_write++
    [IO.File]::WriteAllBytes($plain, $fixedBytes)
    $stages.input = 'PASS'

    $calls.encrypt++
    $reply = Invoke-OpenSsl @('cms','-encrypt','-binary','-stream','-outform','DER','-aes-256-gcm',
        '-in',$plain,'-out',$cipher,$cert)
    $exitCodes.encrypt = $reply.code
    if ($reply.timeout -or $reply.code -ne 0) { $stages.encrypt = 'FAIL'; Stop-At 'CMS_GCM_ENCRYPT_FAILED' }
    $cipherBytes = [IO.File]::ReadAllBytes($cipher)
    $cipherLength = $cipherBytes.Length
    if ($cipherLength -le 64) { $stages.encrypt = 'FAIL'; Stop-At 'CIPHERTEXT_TOO_SHORT' }
    $stages.encrypt = 'PASS'

    $calls.decrypt++
    $reply = Invoke-OpenSsl @('cms','-decrypt','-binary','-inform','DER','-in',$cipher,
        '-recip',$cert,'-inkey',$key,'-out',$restored)
    $exitCodes.decrypt = $reply.code
    if ($reply.timeout -or $reply.code -ne 0) { $stages.decrypt = 'FAIL'; Stop-At 'CMS_DECRYPT_FAILED' }
    $restoredBytes = [IO.File]::ReadAllBytes($restored)
    $plainMatches = [bool]([Linq.Enumerable]::SequenceEqual([byte[]]$fixedBytes,[byte[]]$restoredBytes))
    if (-not $plainMatches) { $stages.decrypt = 'FAIL'; Stop-At 'PLAINTEXT_MISMATCH' }
    $stages.decrypt = 'PASS'

    $calls.tamper_copy++
    $tamperedBytes = [byte[]]$cipherBytes.Clone()
    $flipIndex = $tamperedBytes.Length - 24
    if ($flipIndex -le 32) { $stages.tamper = 'FAIL'; Stop-At 'TAMPER_INDEX_UNSAFE' }
    $tamperedBytes[$flipIndex] = $tamperedBytes[$flipIndex] -bxor 1
    [IO.File]::WriteAllBytes($tampered, $tamperedBytes)
    $stages.tamper = 'PASS'

    $calls.tamper_decrypt++
    $reply = Invoke-OpenSsl @('cms','-decrypt','-binary','-inform','DER','-in',$tampered,
        '-recip',$cert,'-inkey',$key,'-out',$tamperedOutput)
    $exitCodes.tamper_decrypt = $reply.code
    $tamperedMatches = $false
    if (Test-Path -LiteralPath $tamperedOutput) {
        $observed = [IO.File]::ReadAllBytes($tamperedOutput)
        $tamperedMatches = [bool]([Linq.Enumerable]::SequenceEqual([byte[]]$fixedBytes,[byte[]]$observed))
    }
    $tamperRejected = [bool](-not $reply.timeout -and $reply.code -is [int] -and $reply.code -ne 0 -and -not $tamperedMatches)
    if (-not $tamperRejected) { $stages.tamper_decrypt = 'FAIL'; Stop-At 'TAMPER_NOT_REJECTED' }
    $stages.tamper_decrypt = 'PASS'

    $calls.backup_empty_after++
    if (-not (Is-EmptyDirectory $backupDir)) { $stages.backup_empty_after = 'FAIL'; Stop-At 'BACKUP_DIRECTORY_CHANGED_OR_UNKNOWN' }
    $stages.backup_empty_after = 'PASS'
} catch {
    if ($null -eq $firstFailure) { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
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
                $calls.absence_check++
                $cleanup = if (Test-Path -LiteralPath $fixedDir) { 'CLEANUP_FAILED' } else { 'PASS' }
            }
        } catch { $cleanup = 'CLEANUP_UNRESOLVED' }
    } else { $cleanup = 'NOT_NEEDED' }
    $stages.cleanup = $cleanup
    if ($cleanup -cin @('CLEANUP_UNRESOLVED','CLEANUP_FAILED') -and $null -eq $firstFailure) { $firstFailure = $cleanup }
}

[ordered]@{
    stages = $stages; calls = $calls; openssl_version = $opensslVersion
    ciphertext_length = $cipherLength; plaintext_equal = $plainMatches
    tamper_rejected = $tamperRejected; exit_codes = $exitCodes
    first_failure = if ($null -eq $firstFailure) { 'NONE' } else { $firstFailure }
    cleanup = $cleanup; elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
} | ConvertTo-Json -Depth 5 -Compress
