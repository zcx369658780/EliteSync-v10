$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$fixedParent = 'C:\Users\zcxve\AppData\Local\Temp'
$fixedDir = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth59-fd-cms-diagnosis'
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
$stages = [ordered]@{ preflight = 'NOT_CHECKED'; create_temp = 'NOT_CHECKED'; certificate = 'NOT_CHECKED'; fd_read = 'NOT_CHECKED'; x509_fd = 'NOT_CHECKED'; cms_encrypt = 'NOT_CHECKED'; cleanup = 'NOT_CHECKED' }
$exitCodes = [ordered]@{ certificate = 'NOT_CHECKED'; fd_read = 'NOT_CHECKED'; x509_fd = 'NOT_CHECKED'; cms_encrypt = 'NOT_CHECKED' }
$categories = [ordered]@{ certificate = 'NOT_CHECKED'; fd_read = 'NOT_CHECKED'; x509_fd = 'NOT_CHECKED'; cms_encrypt = 'NOT_CHECKED' }
$certLength = 'NOT_CHECKED'
$fdLength = 'NOT_CHECKED'
$fdMatch = 'NOT_CHECKED'
$cipherLength = 'NOT_CHECKED'
$certBytes = $null

function Stop-At([string]$stage) {
    if ($script:firstFailure -eq 'NONE') { $script:firstFailure = $stage }
    throw [InvalidOperationException]::new('bounded stop')
}

function Test-RegularFixedFile([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    return [bool]($item -is [IO.FileInfo] -and
        ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
        [IO.Path]::GetFullPath($path) -ceq $path -and $item.FullName -ceq $path)
}

function Get-Category([string]$stage, [byte[]]$errorBytes, [bool]$captureFailed) {
    if ($captureFailed -or $null -eq $errorBytes) { return 'UNKNOWN' }
    $safeText = [Text.Encoding]::UTF8.GetString($errorBytes)
    if ($safeText -match '(?i)(bad file descriptor|/dev/fd/3.*(no such file|cannot open|permission denied)|fd/3.*unreadable)') { return 'FD_UNREADABLE' }
    if ($safeText -match '(?i)(unable to load certificate|could not read certificate|no start line|PEM routines|certificate.*(parse|read|load))') { return 'CERT_PARSE' }
    if ($stage -eq 'cms_encrypt' -and $safeText -match '(?i)(unknown option|unsupported|recipient|no recipient|unable to load recipient|cms.*(option|recipient))') { return 'CMS_OPTION_OR_RECIPIENT' }
    if ($safeText.Length -eq 0) { return 'UNKNOWN' }
    return 'OTHER'
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
    $outBuffer = [byte[]]::new($script:limit)
    $errBuffer = [byte[]]::new(16384)
    $outChunk = [byte[]]::new(4096)
    $errChunk = [byte[]]::new(4096)
    $outCount = 0
    $errCount = 0
    $started = $false
    $failed = $false
    $code = 'UNKNOWN'
    $outBytes = $null
    $errorBytes = $null
    try {
        if ($script:clock.ElapsedMilliseconds -ge 90000) { $failed = $true }
        elseif ($process.Start()) {
            $started = $true
            if ($null -ne $inputBytes -and $inputBytes.Length -gt 0) {
                $process.StandardInput.BaseStream.Write($inputBytes, 0, $inputBytes.Length)
            }
            $process.StandardInput.Close()
            $outTask = $process.StandardOutput.BaseStream.ReadAsync($outChunk, 0, $outChunk.Length)
            $errTask = $process.StandardError.BaseStream.ReadAsync($errChunk, 0, $errChunk.Length)
            $outDone = $false
            $errDone = $false
            while (-not $outDone -or -not $errDone) {
                $remaining = 90000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0) { $failed = $true; break }
                $pending = @()
                if (-not $outDone) { $pending += $outTask }
                if (-not $errDone) { $pending += $errTask }
                $winner = [Threading.Tasks.Task]::WhenAny([Threading.Tasks.Task[]]$pending)
                if (-not $winner.Wait($remaining)) { $failed = $true; break }
                $completed = $winner.GetAwaiter().GetResult()
                if (-not $outDone -and [object]::ReferenceEquals($completed, $outTask)) {
                    $read = $outTask.GetAwaiter().GetResult()
                    if ($read -eq 0) { $outDone = $true }
                    elseif ($read -gt $outBuffer.Length - $outCount) { $failed = $true; break }
                    else {
                        [Array]::Copy($outChunk, 0, $outBuffer, $outCount, $read)
                        $outCount += $read
                        $outTask = $process.StandardOutput.BaseStream.ReadAsync($outChunk, 0, $outChunk.Length)
                    }
                } else {
                    $read = $errTask.GetAwaiter().GetResult()
                    if ($read -eq 0) { $errDone = $true }
                    elseif ($read -gt $errBuffer.Length - $errCount) { $failed = $true; break }
                    else {
                        [Array]::Copy($errChunk, 0, $errBuffer, $errCount, $read)
                        $errCount += $read
                        $errTask = $process.StandardError.BaseStream.ReadAsync($errChunk, 0, $errChunk.Length)
                    }
                }
            }
            if (-not $failed) {
                $remaining = 90000 - [int]$script:clock.ElapsedMilliseconds
                if ($remaining -le 0 -or -not $process.WaitForExit($remaining)) { $failed = $true }
                else { $code = [int]$process.ExitCode }
            }
            if (-not $failed) {
                $outBytes = [byte[]]::new($outCount)
                $errorBytes = [byte[]]::new($errCount)
                [Array]::Copy($outBuffer, $outBytes, $outCount)
                [Array]::Copy($errBuffer, $errorBytes, $errCount)
            }
        }
    } catch { $failed = $true }
    finally {
        if ($started -and -not $process.HasExited) {
            try { $process.Kill($true); [void]$process.WaitForExit(1000) } catch { }
        }
        [Array]::Clear($outBuffer, 0, $outBuffer.Length)
        [Array]::Clear($errBuffer, 0, $errBuffer.Length)
        [Array]::Clear($outChunk, 0, $outChunk.Length)
        [Array]::Clear($errChunk, 0, $errChunk.Length)
        $process.Dispose()
    }
    return [pscustomobject]@{ code = $code; failed = $failed; bytes = $outBytes; errorBytes = $errorBytes }
}

try {
    if ($fixedBytes.Length -ne 21) { $stages.preflight = 'FAIL'; Stop-At 'preflight' }
    foreach ($path in @($bashPath, $opensslPath, $configPath)) {
        if (-not (Test-RegularFixedFile $path)) { $stages.preflight = 'FAIL'; Stop-At 'preflight' }
    }
    $parent = Get-Item -LiteralPath $fixedParent -Force -ErrorAction Stop
    $canonicalParent = [IO.Path]::GetFullPath($fixedParent)
    $canonicalDir = [IO.Path]::GetFullPath($fixedDir)
    $reportedTemp = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')
    $safeParent = [bool]($parent -is [IO.DirectoryInfo] -and
        ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0 -and
        $canonicalParent -ceq $fixedParent -and $canonicalParent -ceq $reportedTemp -and
        $canonicalDir -ceq $fixedDir -and [IO.Path]::GetDirectoryName($canonicalDir) -ceq $canonicalParent)
    if (-not $safeParent -or (Test-Path -LiteralPath $fixedDir)) { $stages.preflight = 'FAIL'; Stop-At 'preflight' }
    $stages.preflight = 'PASS'

    [void](New-Item -ItemType Directory -Path $fixedDir -ErrorAction Stop)
    $created = $true
    $stages.create_temp = 'PASS'
    $key = Join-Path $fixedDir 'synthetic.key.pem'
    $cert = Join-Path $fixedDir 'synthetic.cert.pem'
    $reply = Invoke-Bounded $opensslPath @('req','-config',$configPath,'-x509','-newkey','rsa:2048','-nodes',
        '-keyout',$key,'-out',$cert,'-days','1','-subj','/CN=AUTH59-SYNTHETIC-ONLY') $null
    $exitCodes.certificate = $reply.code
    $categories.certificate = Get-Category 'certificate' $reply.errorBytes $reply.failed
    if (-not $reply.failed -and $reply.code -eq 0) { $categories.certificate = 'NOT_CHECKED' }
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length) }
    if ($null -ne $reply.errorBytes) { [Array]::Clear($reply.errorBytes, 0, $reply.errorBytes.Length) }
    if ($reply.failed -or $reply.code -ne 0 -or -not (Test-RegularFixedFile $cert) -or -not (Test-RegularFixedFile $key)) {
        $stages.certificate = 'FAIL'; Stop-At 'certificate'
    }
    $certBytes = [IO.File]::ReadAllBytes($cert)
    $certLength = $certBytes.Length
    if ($certLength -lt 500 -or $certLength -gt 8192) { $stages.certificate = 'FAIL'; Stop-At 'certificate' }
    $stages.certificate = 'PASS'

    $reply = Invoke-Bounded $bashPath @('-c','exec 3<&0; cat <&3') $certBytes
    $exitCodes.fd_read = $reply.code
    $categories.fd_read = Get-Category 'fd_read' $reply.errorBytes $reply.failed
    if (-not $reply.failed -and $reply.code -eq 0) { $categories.fd_read = 'NOT_CHECKED' }
    if ($null -ne $reply.errorBytes) { [Array]::Clear($reply.errorBytes, 0, $reply.errorBytes.Length) }
    if ($null -ne $reply.bytes) {
        $fdLength = $reply.bytes.Length
        $fdMatch = [bool]([Linq.Enumerable]::SequenceEqual([byte[]]$certBytes, [byte[]]$reply.bytes))
        [Array]::Clear($reply.bytes, 0, $reply.bytes.Length)
    }
    if ($reply.failed -or $reply.code -ne 0 -or $fdMatch -ne $true) { $stages.fd_read = 'FAIL'; Stop-At 'fd_read' }
    $stages.fd_read = 'PASS'

    $reply = Invoke-Bounded $bashPath @('-c','exec 3<&0; /usr/bin/openssl x509 -in /dev/fd/3 -noout') $certBytes
    $exitCodes.x509_fd = $reply.code
    $categories.x509_fd = Get-Category 'x509_fd' $reply.errorBytes $reply.failed
    if (-not $reply.failed -and $reply.code -eq 0) { $categories.x509_fd = 'NOT_CHECKED' }
    if ($null -ne $reply.bytes) { [Array]::Clear($reply.bytes, 0, $reply.bytes.Length) }
    if ($null -ne $reply.errorBytes) { [Array]::Clear($reply.errorBytes, 0, $reply.errorBytes.Length) }
    if ($reply.failed -or $reply.code -ne 0) { $stages.x509_fd = 'FAIL'; Stop-At 'x509_fd' }
    $stages.x509_fd = 'PASS'

    $bashScript = "set -o pipefail; exec 3<&0; printf 'AUTH57-SYNTHETIC-001\n' | /usr/bin/openssl cms -encrypt -binary -stream -outform DER -aes-256-gcm -recip /dev/fd/3"
    $reply = Invoke-Bounded $bashPath @('-c',$bashScript) $certBytes
    $exitCodes.cms_encrypt = $reply.code
    $categories.cms_encrypt = Get-Category 'cms_encrypt' $reply.errorBytes $reply.failed
    if (-not $reply.failed -and $reply.code -eq 0) { $categories.cms_encrypt = 'NOT_CHECKED' }
    if ($null -ne $reply.errorBytes) { [Array]::Clear($reply.errorBytes, 0, $reply.errorBytes.Length) }
    if ($null -ne $reply.bytes) {
        $cipherLength = $reply.bytes.Length
        [Array]::Clear($reply.bytes, 0, $reply.bytes.Length)
    }
    if ($reply.failed -or $reply.code -ne 0 -or $cipherLength -le 64) { $stages.cms_encrypt = 'FAIL'; Stop-At 'cms_encrypt' }
    $stages.cms_encrypt = 'PASS'
} catch {
    if ($firstFailure -eq 'NONE') { $firstFailure = 'UNEXPECTED_SCRIPT_FAILURE' }
    if ($stages.preflight -eq 'NOT_CHECKED') { $stages.preflight = 'FAIL' }
} finally {
    if ($null -ne $certBytes) { [Array]::Clear($certBytes, 0, $certBytes.Length) }
    [Array]::Clear($fixedBytes, 0, $fixedBytes.Length)
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
    stages = $stages; exit_codes = $exitCodes; categories = $categories
    fixed_input_bytes = 21; certificate_bytes = $certLength; fd_bytes = $fdLength
    fd_match = $fdMatch; ciphertext_bytes = $cipherLength
    first_failure = $firstFailure; cleanup = $cleanup
    elapsed_seconds = [int][Math]::Ceiling($clock.Elapsed.TotalSeconds)
} | ConvertTo-Json -Depth 5 -Compress
