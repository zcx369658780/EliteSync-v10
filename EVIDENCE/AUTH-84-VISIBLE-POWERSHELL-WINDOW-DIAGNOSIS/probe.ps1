#Requires -Version 5.1
param([switch]$Child)

$ErrorActionPreference = 'Stop'
$powerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$probe = 'D:\EliteSync-v10\EVIDENCE\AUTH-84-VISIBLE-POWERSHELL-WINDOW-DIAGNOSIS\probe.ps1'

if (-not $Child) {
    try {
        if (-not (Test-Path -LiteralPath $powerShell -PathType Leaf)) { throw 'PROGRAM_MISSING' }
        if (-not (Test-Path -LiteralPath $probe -PathType Leaf)) { throw 'PROBE_MISSING' }
        $process = Start-Process -FilePath $powerShell -ArgumentList @('-NoLogo', '-NoProfile', '-File', $probe, '-Child') -WindowStyle Normal -Wait -PassThru
        $code = [int]$process.ExitCode
        if ($code -lt 0 -or $code -gt 31) {
            Write-Output 'AUTH84_CATEGORY=CHILD_EXIT_OUT_OF_RANGE'
            exit 1
        }
        Write-Output "AUTH84_CHILD_EXIT=$code"
        Write-Output "AUTH84_USER_INTERACTIVE=$([bool](-not ($code -band 1)))"
        Write-Output "AUTH84_CONSOLE_HOST=$([bool](-not ($code -band 2)))"
        Write-Output "AUTH84_STDIN_REDIRECTED=$([bool]($code -band 4))"
        Write-Output "AUTH84_STDOUT_REDIRECTED=$([bool]($code -band 8))"
        Write-Output "AUTH84_STDERR_REDIRECTED=$([bool]($code -band 16))"
        Write-Output 'AUTH84_CATEGORY=FINITE_CONSOLE_BITS'
        exit 0
    }
    catch {
        Write-Output 'AUTH84_CATEGORY=WINDOW_LAUNCH_FAILED'
        exit 1
    }
}

$code = 0
if (-not [Environment]::UserInteractive) { $code = $code -bor 1 }
if ($Host.Name -ne 'ConsoleHost') { $code = $code -bor 2 }
if ([Console]::IsInputRedirected) { $code = $code -bor 4 }
if ([Console]::IsOutputRedirected) { $code = $code -bor 8 }
if ([Console]::IsErrorRedirected) { $code = $code -bor 16 }
Write-Host 'AUTH84_VISIBLE_PROBE'
Start-Sleep -Seconds 12
exit $code
