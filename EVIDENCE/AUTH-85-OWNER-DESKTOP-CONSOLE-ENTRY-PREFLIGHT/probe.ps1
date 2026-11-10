#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

try {
    Write-Output 'AUTH85_VISIBLE_PROBE'
    Write-Output "AUTH85_USER_INTERACTIVE=$([Environment]::UserInteractive)"
    Write-Output "AUTH85_CONSOLE_HOST=$($Host.Name -eq 'ConsoleHost')"
    Write-Output "AUTH85_STDIN_REDIRECTED=$([Console]::IsInputRedirected)"
    Write-Output "AUTH85_STDOUT_REDIRECTED=$([Console]::IsOutputRedirected)"
    Write-Output "AUTH85_STDERR_REDIRECTED=$([Console]::IsErrorRedirected)"
    Write-Output 'AUTH85_CATEGORY=CONTROL_FIELDS_PRINTED'
    exit 0
}
catch {
    Write-Output 'AUTH85_FAILURE=PROBE_EXCEPTION'
    exit 1
}
