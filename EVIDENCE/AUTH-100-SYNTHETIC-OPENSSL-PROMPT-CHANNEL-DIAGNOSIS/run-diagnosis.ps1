$ErrorActionPreference = 'Stop'

$openssl = 'C:\Program Files\Git\usr\bin\openssl.exe'
$expectedHash = '21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B'
$ps51 = Join-Path $env:WINDIR 'System32\WindowsPowerShell\v1.0\powershell.exe'
$parent = 'C:\Users\zcxve\AppData\Local\Temp'
$tempDir = Join-Path $parent 'elitesync-auth100-synthetic'
$key = Join-Path $tempDir 'synthetic-encrypted-key.pem'
$child = Join-Path $PSScriptRoot 'probe-child.ps1'
$testPassphrase = 'AUTH100_SYNTHETIC_ONLY'

function Invoke-BoundedProcess([string]$file, [string]$arguments, [string]$stdinText) {
    $info = New-Object System.Diagnostics.ProcessStartInfo
    $info.FileName = $file
    $info.Arguments = $arguments
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $info
    if (-not $process.Start()) { throw 'PROCESS_START_FAILED' }
    try {
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        if ($stdinText) { $process.StandardInput.WriteLine($stdinText) }
        $process.StandardInput.Close()
        if (-not $process.WaitForExit(15000)) {
            $process.Kill()
            $process.WaitForExit()
            throw 'PROCESS_TIMEOUT'
        }
        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result
        if ($stdout.Length -gt 8192 -or $stderr.Length -gt 8192) { throw 'OUTPUT_LIMIT_EXCEEDED' }
        return [pscustomobject]@{ ExitCode = $process.ExitCode; Stdout = $stdout; Stderr = $stderr }
    } finally {
        $process.Dispose()
    }
}

$stage = 'PREFLIGHT'
try {
    foreach ($file in @($openssl, $ps51, $child)) {
        $item = Get-Item -LiteralPath $file -Force
        if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'FIXED_FILE_INVALID' }
    }
    if ((Get-FileHash -LiteralPath $openssl -Algorithm SHA256).Hash -ne $expectedHash) { throw 'OPENSSL_HASH_MISMATCH' }
    $parentItem = Get-Item -LiteralPath $parent -Force
    if (-not $parentItem.PSIsContainer -or ($parentItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'TEMP_PARENT_INVALID' }
    if (Test-Path -LiteralPath $tempDir) { throw 'TEMP_TARGET_EXISTS' }
    if ((& $ps51 -NoProfile -NonInteractive -Command '$PSVersionTable.PSVersion.Major') -ne 5) { throw 'PS_VERSION_MISMATCH' }

    $stage = 'KEY_GENERATION'
    [void][IO.Directory]::CreateDirectory($tempDir)
    $generated = Invoke-BoundedProcess $openssl ('genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -aes-256-cbc -pass "pass:' + $testPassphrase + '" -out "' + $key + '"') ''
    if ($generated.ExitCode -ne 0 -or -not (Test-Path -LiteralPath $key -PathType Leaf)) { throw 'KEY_GENERATION_FAILED' }
    $keyItem = Get-Item -LiteralPath $key -Force
    if (($keyItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $keyItem.Length -lt 100) { throw 'SYNTHETIC_KEY_INVALID' }
    Write-Output 'KEY_GENERATION=PASS;BUDGET=1/1'

    foreach ($mode in @('A', 'B', 'C')) {
        $stage = 'MODE_' + $mode
        $args = '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' + $child + '" -Mode ' + $mode
        $observed = Invoke-BoundedProcess $ps51 $args $testPassphrase
        $markers = @([regex]::Matches($observed.Stdout, 'AUTH100_CHILD=(EXIT_ZERO|NATIVE_NONZERO|CAUGHT)'))
        if ($markers.Count -ne 1 -or $observed.ExitCode -notin @(0, 10, 11)) { throw 'CHILD_RESULT_INVALID' }
        $classification = $markers[0].Groups[1].Value
        if (($classification -eq 'EXIT_ZERO' -and $observed.ExitCode -ne 0) -or
            ($classification -eq 'NATIVE_NONZERO' -and $observed.ExitCode -ne 10) -or
            ($classification -eq 'CAUGHT' -and $observed.ExitCode -ne 11)) { throw 'CHILD_RESULT_MISMATCH' }
        $promptPattern = '(?i)(enter|input|type|please).{0,60}(pass.?phrase|password)|(pass.?phrase|password).{0,60}(enter|input|type|please)'
        $outPrompt = [regex]::IsMatch($observed.Stdout, $promptPattern)
        $errPrompt = [regex]::IsMatch($observed.Stderr, $promptPattern)
        Write-Output ('MODE=' + $mode + ';RESULT=' + $classification + ';EXIT=' + $observed.ExitCode + ';PROMPT_STDOUT=' + $outPrompt + ';PROMPT_STDERR=' + $errPrompt + ';OUTPUT_LIMIT=PASS;BUDGET=1/1')
    }

    $stage = 'CLEANUP'
    $remaining = @(Get-ChildItem -LiteralPath $tempDir -Force)
    if ($remaining.Count -ne 1 -or $remaining[0].FullName -ne $key) { throw 'TEMP_CONTENT_MISMATCH' }
    Remove-Item -LiteralPath $key -Force
    if (Test-Path -LiteralPath $key) { throw 'KEY_CLEANUP_FAILED' }
    Remove-Item -LiteralPath $tempDir
    if (Test-Path -LiteralPath $tempDir) { throw 'DIR_CLEANUP_FAILED' }
    Write-Output 'CLEANUP=PASS;TEMP_DIR_ABSENT=TRUE'
    exit 0
} catch {
    Write-Output ('STOP_STAGE=' + $stage + ';CLASS=' + $_.Exception.Message)
    exit 1
}
