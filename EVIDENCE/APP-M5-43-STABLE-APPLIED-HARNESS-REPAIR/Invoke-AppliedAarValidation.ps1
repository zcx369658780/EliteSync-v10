# Source-only candidate. Execution requires a new explicit Work task.
# Test mode additionally requires Work's accepted Static original receipt.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('Static','Test')]
    [string]$Mode,
    [Parameter(Mandatory=$true)]
    [ValidatePattern('\A[0-9A-Fa-f]{64}\z')]
    [string]$CheckerSha256
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$pythonPath = 'C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe'
$repoPath = 'D:\EliteSync-v10'
$checkerPath = 'D:\EliteSync-v10\EVIDENCE\APP-M5-43-STABLE-APPLIED-HARNESS-REPAIR\check_applied_sources.py'
$productionPath = 'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_entry_materials.py'
$testPath = 'D:\EliteSync-v10\apps\android_synthetic_demo\tools\test_aar_applied_materials.py'
$byteLimit = 32768
$hardSeconds = 60.0
# Reserve one second within the overall deadline for termination observation.
$executionSeconds = 59.0
$clock = [Diagnostics.Stopwatch]::new()
$process = $null
$started = $false
$startCount = 0
$startAttemptCount = 0
$timeout = $false
$limitExceeded = $false
$failure = $null
$childExit = $null
$stdoutText = $null
$stderrText = $null
$cleanupObservedExit = $false
$streams = @()

function Assert-FixedFile {
    param([string]$Path, [long]$ExpectedSize, [long]$MaximumSize, [string]$ExpectedHash)
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw 'FILE_GATE'
    }
    if ($item.Length -le 0 -or $item.Length -gt $MaximumSize -or
        ($ExpectedSize -gt 0 -and $item.Length -ne $ExpectedSize)) { throw 'SIZE_GATE' }
    if ($ExpectedHash -ne '') {
        $bytes = [IO.File]::ReadAllBytes($Path)
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
        if ($hash -cne $ExpectedHash.ToUpperInvariant()) { throw 'HASH_GATE' }
    }
}

function Start-StreamRead {
    param($State)
    # One outstanding asynchronous raw-byte read per stream; no characters
    # are counted or decoded until both pipes reach EOF.
    $State.Pending = $State.Stream.ReadAsync($State.Buffer, 0, $State.Buffer.Length)
}

try {
    # Additional fixed application source gate, inside the original receipt try.
    # Original adapter and adapted test gates below remain authoritative.
    $appliedGatePath = 'D:\EliteSync-v10\apps\android_synthetic_demo\tools\aar_applied_materials.py'
    $appliedGateItem = Get-Item -LiteralPath $appliedGatePath -Force -ErrorAction Stop
    if ($appliedGateItem.PSIsContainer -or (($appliedGateItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0)) { throw 'SOURCE_NOT_ORDINARY' }
    if ($appliedGateItem.Length -ne 6510) { throw 'SOURCE_SIZE' }
    $appliedGateBytes = [IO.File]::ReadAllBytes($appliedGatePath)
    $appliedGateSha = [Security.Cryptography.SHA256]::Create()
    try { $appliedGateDigest = [BitConverter]::ToString($appliedGateSha.ComputeHash($appliedGateBytes)).Replace('-', '') } finally { $appliedGateSha.Dispose() }
    if ($appliedGateBytes.Length -ne 6510 -or $appliedGateDigest -cne '123A1164B1B0805AE28867CC0A80BB0C8085D091794A8EE78CDFE1E680CF0224') { throw 'SOURCE_HASH' }
    $null = [Text.UTF8Encoding]::new($false, $true).GetString($appliedGateBytes)

    Assert-FixedFile $pythonPath 0 1073741824 ''
    Assert-FixedFile $checkerPath 0 65536 $CheckerSha256
    Assert-FixedFile $productionPath 20338 20338 'B324943D7CC88EB714DD19450E0E9A2853609580C3A6F9FBFACAC0DA11D04DD7'
    Assert-FixedFile $testPath 72513 72513 '29B2E8C28EEA9E11EB41591D8395FD3B96CB2CF75C7F456EC33BE6E763FB6F9F'
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $pythonPath
    $info.WorkingDirectory = $repoPath
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.ArgumentList.Add('-I')
    $info.ArgumentList.Add('-B')
    if ($Mode -ceq 'Static') { $info.ArgumentList.Add($checkerPath) }
    elseif ($Mode -ceq 'Test') { $info.ArgumentList.Add($testPath) }
    else { throw 'MODE_GATE' }
    $process = [Diagnostics.Process]::new()
    $process.StartInfo = $info
    $clock.Start()
    $startAttemptCount = 1
    if (-not $process.Start()) { throw 'START_FAILED' }
    $started = $true
    $startCount = 1
    foreach ($baseStream in @($process.StandardOutput.BaseStream, $process.StandardError.BaseStream)) {
        $state = [pscustomobject]@{
            Stream = $baseStream
            Buffer = [byte[]]::new(4096)
            Data = [IO.MemoryStream]::new()
            Total = [long]0
            Eof = $false
            Pending = $null
        }
        $streams += $state
        Start-StreamRead $state
    }
    while ($true) {
        if ($clock.Elapsed.TotalSeconds -ge $executionSeconds) {
            $timeout = $true
            throw 'DEADLINE'
        }
        foreach ($state in $streams) {
            if (-not $state.Eof -and $state.Pending.IsCompleted) {
                $count = $state.Pending.GetAwaiter().GetResult()
                $state.Pending = $null
                if ($count -eq 0) { $state.Eof = $true; continue }
                $state.Total += $count
                $remaining = $byteLimit - $state.Data.Length
                if ($remaining -gt 0) {
                    $kept = [int][Math]::Min([long]$remaining, [long]$count)
                    $state.Data.Write($state.Buffer, 0, $kept)
                }
                if ($state.Total -gt $byteLimit) {
                    $limitExceeded = $true
                    throw 'OUTPUT_LIMIT'
                }
                Start-StreamRead $state
            }
        }
        if ($process.HasExited -and $streams[0].Eof -and $streams[1].Eof) {
            $childExit = $process.ExitCode
            $cleanupObservedExit = $true
            break
        }
        # Polling interval is capped by the remaining execution deadline.
        $remainingMs = [Math]::Max(0, ($executionSeconds - $clock.Elapsed.TotalSeconds) * 1000)
        if ($remainingMs -gt 0) { [Threading.Thread]::Sleep([int][Math]::Min(5, $remainingMs)) }
    }
    $decoder = [Text.UTF8Encoding]::new($false, $true)
    try {
        $stdoutText = $decoder.GetString($streams[0].Data.ToArray())
        $stderrText = $decoder.GetString($streams[1].Data.ToArray())
    } catch { throw 'UTF8_DECODE' }
    if ($childExit -ne 0) { $failure = 'CHILD_NONZERO' }
} catch {
    # Only fixed gate labels are emitted, never arbitrary exception contents.
    $label = $_.Exception.Message
    if ($label -cin @('FILE_GATE','SIZE_GATE','HASH_GATE','MODE_GATE','START_FAILED',
                      'DEADLINE','OUTPUT_LIMIT','UTF8_DECODE','SOURCE_NOT_ORDINARY','SOURCE_SIZE','SOURCE_HASH')) { $failure = $label }
    else { $failure = 'LAUNCHER_INTERNAL_OR_FILE_ERROR' }
} finally {
    if ($started -and $null -ne $process) {
        try {
            if (-not $process.HasExited) { $process.Kill() }
            while (-not $process.HasExited -and $clock.Elapsed.TotalSeconds -lt $hardSeconds) {
                $remainingMs = ($hardSeconds - $clock.Elapsed.TotalSeconds) * 1000
                if ($remainingMs -gt 0) { [Threading.Thread]::Sleep([int][Math]::Min(5, $remainingMs)) }
            }
            $cleanupObservedExit = $process.HasExited
            if ($cleanupObservedExit -and $null -eq $childExit) { $childExit = $process.ExitCode }
            if (-not $cleanupObservedExit) { $failure = 'CLEANUP_EXIT_NOT_OBSERVED' }
        } catch { $failure = 'CLEANUP_FAILURE' }
    }
    if ($clock.Elapsed.TotalSeconds -ge $hardSeconds) {
        $timeout = $true
        if ($null -eq $failure) { $failure = 'DEADLINE' }
    }
    $clock.Stop()
}

$stdoutBytes = if ($streams.Count -ge 1) { $streams[0].Total } else { [long]0 }
$stderrBytes = if ($streams.Count -ge 2) { $streams[1].Total } else { [long]0 }
# On failure raw captured bytes remain available without pretending valid UTF8.
$stdoutRaw = if ($streams.Count -ge 1) { [Convert]::ToBase64String($streams[0].Data.ToArray()) } else { '' }
$stderrRaw = if ($streams.Count -ge 2) { [Convert]::ToBase64String($streams[1].Data.ToArray()) } else { '' }
$launcherExit = if ($null -eq $failure -and $childExit -eq 0) { 0 } else { 1 }
$receipt = [pscustomobject]@{
    Mode = $Mode
    Failure = $failure
    Exit = $launcherExit
    ChildExit = $childExit
    ElapsedSeconds = $clock.Elapsed.TotalSeconds
    Timeout = $timeout
    OutputLimitExceeded = $limitExceeded
    StartCount = $startCount
    StartAttemptCount = $startAttemptCount
    CleanupObservedExit = $cleanupObservedExit
    StdoutRawBytes = $stdoutBytes
    StderrRawBytes = $stderrBytes
    Stdout = $stdoutText
    Stderr = $stderrText
    StdoutCapturedBase64 = $stdoutRaw
    StderrCapturedBase64 = $stderrRaw
}
# Closing streams cancels/disposes any outstanding read; no WaitForExit,
# Task.Wait, ReadToEnd or a second process is used for failure cleanup.
foreach ($state in $streams) {
    try { $state.Stream.Dispose() } catch { }
    $state.Data.Dispose()
}
if ($null -ne $process) { $process.Dispose() }
$receipt | ConvertTo-Json -Depth 4 -Compress
exit $launcherExit
