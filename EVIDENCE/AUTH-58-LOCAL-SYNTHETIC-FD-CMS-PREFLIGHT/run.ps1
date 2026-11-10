$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$fixedParent = 'C:\Users\zcxve\AppData\Local\Temp'
$fixedDir = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth58-fd-cms-preflight'
$bashPath = 'C:\Program Files\Git\bin\bash.exe'
$opensslPath = 'C:\Program Files\Git\usr\bin\openssl.exe'
$configPath = 'C:\Program Files\Git\usr\ssl\openssl.cnf'
$fixedBytes = [Text.Encoding]::ASCII.GetBytes("AUTH57-SYNTHETIC-001`n")
$limit = 65536
$clock = [Diagnostics.Stopwatch]::StartNew()
$created = $false
$safeParent = $false
$firstFailure = 'NONE'
$cleanup = 'NOT_CHECKED'
$exitCodes = [ordered]@{ certificate = 'NOT_CHECKED'; encrypt = 'NOT_CHECKED'; decrypt = 'NOT_CHECKED' }
$stages = [ordered]@{ preflight = 'NOT_CHECKED'; create_temp = 'NOT_CHECKED'; certificate = 'NOT_CHECKED'; fd_encrypt = 'NOT_CHECKED'; decrypt = 'NOT_CHECKED'; cleanup = 'NOT_CHECKED' }
$lengths = [ordered]@{ certificate = 'NOT_CHECKED'; ciphertext = 'NOT_CHECKED'; decrypted = 'NOT_CHECKED' }
$matched = $false
$cipherCleared = $false
$plainCleared = $false
$cipherBytes = $null
$certBytes = $null

function Stop-At([string]$code) {
    if ($script:firstFailure -eq 'NONE') { $script:firstFailure = $code }
    throw [InvalidOperationException]::new('bounded stop')
}

function Test-RegularFixedFile([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    return [bool]($item -is [IO.FileInfo] -and
        ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
        [IO.Path]::GetFullPath($path) -ceq $path -and $item.FullName -ceq $path)
}

function Invoke-Bounded([string]$path, [string[]]$arguments, [byte[]]$inputBytes) {
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $path
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in $arguments) { [void]$info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    $buffer = [byte[]]::new($script:limit)
    $chunk = [byte[]]::new(4096)
    $count = 0
    $started = $false
    $code = 'UNKNOWN'
    $failed = $false
    $bytes = $null
    try {
        $remaining = 90000 - [int]$script:clock.ElapsedMilliseconds
        if ($remaining -le 0) { $failed = $true }
        elseif ($process.Start()) {
            $started = $true
            $stderrDrain = $process.StandardError.BaseStream.CopyToAsync([IO.Stream]::Null)
            if ($null -ne $inputBytes -and $inputBytes.Length -gt 0) {
                $process.StandardInput.BaseStream.Write($inputBytes, 0, $inputBytes.Length)
            }
            $process.StandardInput.Close()
            while ($true) {
                $remaining = 90000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0) { $failed = $true; break }
                $readTask = $process.StandardOutput.BaseStream.ReadAsync($chunk, 0, $chunk.Length)
                if (-not $readTask.Wait($remaining)) { $failed = $true; break }
                $read = $readTask.GetAwaiter().GetResult()
                if ($read -eq 0) { break }
                if ($read -gt $script:limit - $count) { $failed = $true; break }
                [Array]::Copy($chunk, 0, $buffer, $count, $read)
                $count += $read
            }
            if (-not $failed) {
                $remaining = 90000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0 -or -not $process.WaitForExit($remaining)) { $failed = $true }
                else { $code = [int]$process.ExitCode }
            }
            if (-not $failed -and $code -eq 0) {
                $bytes = [byte[]]::new($count)
                [Array]::Copy($buffer, $bytes, $count)
            }
        }
    } catch { $failed = $true }
    finally {
        if ($started -and -not $process.HasExited) {
            try { $process.Kill($true); [void]$process.WaitForExit(1000) } catch { }
        }
        [Array]::Clear($buffer, 0, $buffer.Length)
        [Array]::Clear($chunk, 0, $chunk.Length)
        $process.Dispose()
    }
    return [pscustomobject]@{ code = $code; failed = $failed; bytes = $bytes }
}

try {
    if ($fixedBytes.Length -ne 21) { $stages.preflight = 'FAIL'; Stop-At 'FIXED_INPUT_LENGTH' }
    foreach ($path in @($bashPath, $opensslPath, $configPath)) {
        if (-not (Test-RegularFixedFile $path)) { $stages.preflight = 'FAIL'; Stop-At 'FIXED_TOOL_PATH' }
    }
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
    $stages.preflight = 'PASS'

    [void](New-Item -ItemType Directory -Path $fixedDir -ErrorAction Stop)
    $created = $true
    $stages.create_temp = 'PASS'
    $key = Join-Path $fixedDir 'synthetic.key.pem'
    $cert = Join-Path $fixedDir 'synthetic.cert.pem'
    $reply = Invoke-Bounded $opensslPath @('req','-config',$configPath,'-x509','-newkey','rsa:2048','-nodes',
        '-keyout',$key,'-out',$cert,'-days','1','-subj','/CN=AUTH58-SYNTHETIC-ONLY') $null
    $exitCodes.certificate = $reply.code
    if ($reply.failed -or $reply.code -ne 0) { $stages.certificate = 'FAIL'; Stop-At 'CERTIFICATE_FAILED' }
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length) }
    if (-not (Test-RegularFixedFile $cert) -or -not (Test-RegularFixedFile $key)) {
        $stages.certificate = 'FAIL'; Stop-At 'CERTIFICATE_FILES_MISSING'
    }
    $certBytes = [IO.File]::ReadAllBytes($cert)
    $lengths.certificate = $certBytes.Length
    if ($certBytes.Length -lt 500 -or $certBytes.Length -gt 8192) {
        $stages.certificate = 'FAIL'; Stop-At 'CERTIFICATE_LENGTH'
    }
    $stages.certificate = 'PASS'

    # fd 3 retains the certificate stream; OpenSSL stdin is only fixed plaintext.
    $bashScript = "set -o pipefail; exec 3<&0; printf 'AUTH57-SYNTHETIC-001\n' | /usr/bin/openssl cms -encrypt -binary -stream -outform DER -aes-256-gcm -recip /dev/fd/3"
    $reply = Invoke-Bounded $bashPath @('-c',$bashScript) $certBytes
    $exitCodes.encrypt = $reply.code
    [Array]::Clear($certBytes, 0, $certBytes.Length)
    if ($reply.failed -or $reply.code -ne 0 -or $null -eq $reply.bytes) {
        $stages.fd_encrypt = 'FAIL'; Stop-At 'FD_ENCRYPT_FAILED'
    }
    $cipherBytes = $reply.bytes
    $lengths.ciphertext = $cipherBytes.Length
    if ($cipherBytes.Length -le 64) { $stages.fd_encrypt = 'FAIL'; Stop-At 'CIPHERTEXT_TOO_SHORT' }
    $stages.fd_encrypt = 'PASS'

    $reply = Invoke-Bounded $opensslPath @('cms','-decrypt','-binary','-inform','DER','-recip',$cert,'-inkey',$key) $cipherBytes
    $exitCodes.decrypt = $reply.code
    if ($reply.failed -or $reply.code -ne 0 -or $null -eq $reply.bytes) {
        $stages.decrypt = 'FAIL'; Stop-At 'DECRYPT_FAILED'
    }
    $lengths.decrypted = $reply.bytes.Length
    $matched = [bool]([Linq.Enumerable]::SequenceEqual([byte[]]$fixedBytes, [byte[]]$reply.bytes))
    [Array]::Clear($reply.bytes, 0, $reply.bytes.Length)
    $plainCleared = $true
    if (-not $matched) { $stages.decrypt = 'FAIL'; Stop-At 'DECRYPT_CONTENT_MISMATCH' }
    $stages.decrypt = 'PASS'
} catch {
    if ($firstFailure -eq 'NONE') { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($null -ne $cipherBytes) { [Array]::Clear($cipherBytes, 0, $cipherBytes.Length); $cipherCleared = $true }
    if ($null -ne $certBytes) { [Array]::Clear($certBytes, 0, $certBytes.Length) }
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
                Remove-Item -LiteralPath $fixedDir -Recurse -Force -ErrorAction Stop
                $cleanup = if (Test-Path -LiteralPath $fixedDir) { 'CLEANUP_FAILED' } else { 'PASS' }
            }
        } catch { $cleanup = 'CLEANUP_UNRESOLVED' }
    } else { $cleanup = 'NOT_NEEDED' }
    $stages.cleanup = $cleanup
    if ($cleanup -ne 'PASS' -and $cleanup -ne 'NOT_NEEDED' -and $firstFailure -eq 'NONE') { $firstFailure = $cleanup }
}

[ordered]@{
    stages = $stages; exit_codes = $exitCodes; lengths = $lengths
    fixed_input_bytes = $fixedBytes.Length; matched = $matched
    cipher_cleared = $cipherCleared; plain_cleared = $plainCleared
    cleanup = $cleanup; first_failure = $firstFailure
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
} | ConvertTo-Json -Depth 5 -Compress
