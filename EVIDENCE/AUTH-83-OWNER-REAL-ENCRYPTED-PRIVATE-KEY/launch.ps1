#Requires -Version 5.1
param([switch]$VisibleChild)

$ErrorActionPreference = 'Stop'
$scriptPath = 'D:\EliteSync-v10\EVIDENCE\AUTH-83-OWNER-REAL-ENCRYPTED-PRIVATE-KEY\launch.ps1'
$taskPath = 'D:\EliteSync-v10\TASK_CURRENT.md'
$powerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$openSsl = 'C:\Program Files\Git\usr\bin\openssl.exe'
$keyDirectory = 'C:\Users\zcxve\EliteSync-v10-DB-Keys'
$keyPath = 'C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem'

function Stop-Bounded([string]$category) {
    Write-Output "AUTH83_FIRST_FAILURE=$category"
    exit 1
}

function Test-ExactRegularFile([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return $false }
    $item = Get-Item -LiteralPath $path -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return $false }
    return [string]::Equals((Resolve-Path -LiteralPath $path).ProviderPath, $path, [StringComparison]::OrdinalIgnoreCase)
}

function Test-ExactDirectory([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { return $false }
    $item = Get-Item -LiteralPath $path -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { return $false }
    return [string]::Equals((Resolve-Path -LiteralPath $path).ProviderPath.TrimEnd('\'), $path.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
}

function Test-ThreePartyAcl([string]$path) {
    $acl = Get-Acl -LiteralPath $path
    $currentSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $expected = @($currentSid, 'S-1-5-18', 'S-1-5-32-544')
    $rules = @($acl.Access)
    if (-not $acl.AreAccessRulesProtected -or $rules.Count -ne 3) { return $false }
    if ($acl.GetOwner([Security.Principal.SecurityIdentifier]).Value -ne $currentSid) { return $false }
    $seen = @{}
    foreach ($rule in $rules) {
        try { $sid = $rule.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value }
        catch { return $false }
        if ($sid -notin $expected -or $seen.ContainsKey($sid)) { return $false }
        if ($rule.IsInherited -or $rule.AccessControlType -ne 'Allow' -or $rule.FileSystemRights.ToString() -ne 'FullControl') { return $false }
        $seen[$sid] = $true
    }
    return $seen.Count -eq 3
}

function Test-Preflight {
    if (-not (Test-ExactRegularFile $scriptPath)) { Stop-Bounded 'SCRIPT_PATH' }
    if (-not (Test-ExactRegularFile $taskPath)) { Stop-Bounded 'TASK_PATH' }
    $task = [IO.File]::ReadAllText($taskPath)
    if ($task -notmatch '(?m)^Status: `ISSUED — PHASE B RELEASED`') { Stop-Bounded 'PHASE_B_NOT_RELEASED' }
    foreach ($directory in @('C:\', 'C:\Users', 'C:\Users\zcxve', $keyDirectory)) {
        if (-not (Test-ExactDirectory $directory)) { Stop-Bounded 'DIRECTORY_BOUNDARY' }
    }
    if (-not (Test-ThreePartyAcl $keyDirectory)) { Stop-Bounded 'DIRECTORY_ACL' }
    if (Test-Path -LiteralPath $keyPath) { Stop-Bounded 'TARGET_ALREADY_EXISTS' }
    if (-not (Test-ExactRegularFile $openSsl)) { Stop-Bounded 'OPENSSL_PATH' }
}

try {
    Test-Preflight
    if (-not $VisibleChild) {
        if (-not (Test-ExactRegularFile $powerShell)) { Stop-Bounded 'POWERSHELL_PATH' }
        $child = Start-Process -FilePath $powerShell -ArgumentList @('-NoLogo', '-NoProfile', '-File', $scriptPath, '-VisibleChild') -WindowStyle Normal -Wait -PassThru
        Write-Output "AUTH83_WINDOW_PROCESS_EXIT=$($child.ExitCode)"
        exit $child.ExitCode
    }

    if (-not [Environment]::UserInteractive -or $Host.Name -ne 'ConsoleHost' -or [Console]::IsInputRedirected -or [Console]::IsOutputRedirected -or [Console]::IsErrorRedirected) {
        Stop-Bounded 'VISIBLE_CONSOLE_REQUIRED'
    }

    # OpenSSL alone reads the Owner's password from this separate visible console.
    # No passphrase is accepted or retained by PowerShell.
    & $openSsl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:3072 -aes-256-cbc -out $keyPath
    $generationExit = $LASTEXITCODE
    Write-Output "AUTH83_GEN_EXIT=$generationExit"
    if ($generationExit -ne 0) { Stop-Bounded 'GENERATION_FAILED' }
    if (-not (Test-ExactRegularFile $keyPath)) { Stop-Bounded 'KEY_FILE_MISSING_OR_REDIRECTED' }
    if ((Get-Item -LiteralPath $keyPath -Force).Length -le 0) { Stop-Bounded 'KEY_FILE_EMPTY' }

    $acl = Get-Acl -LiteralPath $keyPath
    $acl.SetAccessRuleProtection($true, $true)
    Set-Acl -LiteralPath $keyPath -AclObject $acl
    if (-not (Test-ThreePartyAcl $keyPath)) { Stop-Bounded 'KEY_FILE_ACL' }

    $reader = [IO.StreamReader]::new($keyPath)
    try { $encryptedHeader = $reader.ReadLine() -ceq '-----BEGIN ENCRYPTED PRIVATE KEY-----' }
    finally { $reader.Dispose() }
    Write-Output "AUTH83_ENCRYPTED_PKCS8_HEADER=$encryptedHeader"
    if (-not $encryptedHeader) { Stop-Bounded 'ENCRYPTED_HEADER_MISMATCH' }

    & $openSsl pkey -in $keyPath -noout
    $unlockExit = $LASTEXITCODE
    Write-Output "AUTH83_UNLOCK_EXIT=$unlockExit"
    if ($unlockExit -ne 0) { Stop-Bounded 'UNLOCK_FAILED' }
    Write-Output 'AUTH83_RESULT=AUTHOR_CHECK_PASS'
    exit 0
}
catch {
    # Do not print exception text, which could contain process output or paths.
    Stop-Bounded 'UNCLASSIFIED_EXCEPTION'
}
