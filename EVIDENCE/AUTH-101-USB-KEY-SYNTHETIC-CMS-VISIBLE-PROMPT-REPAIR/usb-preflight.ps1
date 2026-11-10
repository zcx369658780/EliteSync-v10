param([switch]$ElevatedCheck)

$ErrorActionPreference = 'Stop'
$expectedScript = 'D:\EliteSync-v10\EVIDENCE\AUTH-101-USB-KEY-SYNTHETIC-CMS-VISIBLE-PROMPT-REPAIR\usb-preflight.ps1'
$ps51 = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$openssl = 'C:\Program Files\Git\usr\bin\openssl.exe'
$compare = 'C:\Windows\System32\fc.exe'
$keyPath = 'E:\elitesync-v10-db-backup-recipient-20260925.key.pem'
$certPath = 'E:\elitesync-v10-db-backup-recipient-20260925.cert.pem'
$expectedCertFingerprint = '3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461'
$tempParent = 'C:\Users\zcxve\AppData\Local\Temp'
$tempDir = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth101-synthetic'

function Test-UsbIdentity {
    try {
        $partitions = @(Get-Partition -DriveLetter 'E' -ErrorAction Stop)
        if ($partitions.Count -ne 1) { return $false }
        $partition = $partitions[0]
        $disks = @(Get-Disk -ErrorAction Stop | Where-Object { [string]$_.BusType -ceq 'USB' })
        if ($disks.Count -ne 1) { return $false }
        $disk = $disks[0]
        if ([string]$disk.FriendlyName -cne 'Kingston DataTraveler Duo' -or
            [int]$disk.Number -ne [int]$partition.DiskNumber -or
            [double]$disk.Size -lt 25GB -or [double]$disk.Size -gt 35GB) { return $false }
        $mapped = @(Get-Partition -DiskNumber $disk.Number -ErrorAction Stop |
            Where-Object { [string]$_.DriveLetter -ceq 'E' })
        if ($mapped.Count -ne 1 -or [int]$mapped[0].PartitionNumber -ne [int]$partition.PartitionNumber) { return $false }
        $byPartition = @(Get-Volume -Partition $partition -ErrorAction Stop)
        $byLetter = @(Get-Volume -DriveLetter 'E' -ErrorAction Stop)
        if ($byPartition.Count -ne 1 -or $byLetter.Count -ne 1) { return $false }
        $volume = $byPartition[0]
        return ([string]$volume.DriveLetter -ceq 'E' -and
            [string]$volume.DriveType -ceq 'Removable' -and
            [string]$volume.ObjectId -ceq [string]$byLetter[0].ObjectId)
    } catch { return $false }
}

function Test-EFiles {
    try {
        $key = Get-Item -LiteralPath $keyPath -Force -ErrorAction Stop
        $cert = Get-Item -LiteralPath $certPath -Force -ErrorAction Stop
        if ($key.PSIsContainer -or $cert.PSIsContainer -or
            ($key.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ($cert.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            $key.Length -ne 2666 -or $cert.Length -ne 1541) { return $false }
        $header = [Text.Encoding]::ASCII.GetBytes('-----BEGIN ENCRYPTED PRIVATE KEY-----')
        $stream = [IO.File]::Open($keyPath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            foreach ($byte in $header) { if ($stream.ReadByte() -ne $byte) { return $false } }
            $lineEnd = $stream.ReadByte()
            if ($lineEnd -eq 13) { $lineEnd = $stream.ReadByte() }
            if ($lineEnd -ne 10) { return $false }
        } finally { $stream.Dispose() }
        $certText = [IO.File]::ReadAllText($certPath)
        $match = [regex]::Match($certText,
            '\A-----BEGIN CERTIFICATE-----\s+(?<body>[A-Za-z0-9+/=\s]+)-----END CERTIFICATE-----\s*\z')
        if (-not $match.Success) { return $false }
        $der = [Convert]::FromBase64String(($match.Groups['body'].Value -replace '\s', ''))
        $sha = [Security.Cryptography.SHA256]::Create()
        try { $fingerprint = ([BitConverter]::ToString($sha.ComputeHash($der))).Replace('-', '') }
        finally { $sha.Dispose() }
        return ($fingerprint -ceq $expectedCertFingerprint)
    } catch { return $false }
}

function Test-ToolAndTemp {
    try {
        foreach ($path in @($ps51, $openssl, $compare)) {
            $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
            if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        }
        if ((Get-FileHash -LiteralPath $openssl -Algorithm SHA256 -ErrorAction Stop).Hash -cne
            '21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B') { return $false }
        $parent = Get-Item -LiteralPath $tempParent -Force -ErrorAction Stop
        if (-not $parent.PSIsContainer -or ($parent.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        return (-not (Test-Path -LiteralPath $tempDir))
    } catch { return $false }
}

function Stop-Finite([string]$category, [int]$code) {
    Write-Output "AUTH101_PREFLIGHT=$category;EXIT=$code"
    exit $code
}

if ([string]$PSCommandPath -cne $expectedScript) { Stop-Finite 'SCRIPT_PATH_MISMATCH' 10 }
if (-not (Test-UsbIdentity)) { Stop-Finite 'USB_IDENTITY_FAILED' 20 }

if ($ElevatedCheck) {
    try {
        $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 22 }
        $states = @(Get-BitLockerVolume -MountPoint 'E:' -ErrorAction Stop)
        if ($states.Count -ne 1) { exit 31 }
        $state = $states[0]
        if ($null -eq $state.ProtectionStatus -or
            $state.ProtectionStatus.GetType().FullName -cne 'Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus' -or
            [string]$state.LockStatus -cne 'Unlocked' -or
            [string]$state.ProtectionStatus -cne 'On' -or
            [string]$state.VolumeStatus -cne 'FullyEncrypted' -or
            [string]$state.EncryptionPercentage -cne '100') { exit 32 }
        if (-not (Test-UsbIdentity)) { exit 20 }
        if (-not (Test-EFiles)) { exit 40 }
        if (-not (Test-ToolAndTemp)) { exit 41 }
        exit 0
    } catch { exit 30 }
}

if (-not (Test-ToolAndTemp)) { Stop-Finite 'TOOL_OR_TEMP_FAILED' 41 }
try {
    $args = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'RemoteSigned',
        '-File', ('"' + $expectedScript + '"'), '-ElevatedCheck')
    $child = Start-Process -FilePath $ps51 -ArgumentList $args -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
    $childExit = [int]$child.ExitCode
} catch { Stop-Finite 'UAC_OR_LAUNCH_FAILED' 50 }

if ($childExit -ne 0) {
    switch ($childExit) {
        10 { Stop-Finite 'CHILD_SCRIPT_PATH_MISMATCH' 51 }
        20 { Stop-Finite 'CHILD_USB_IDENTITY_FAILED' 52 }
        22 { Stop-Finite 'CHILD_NOT_ELEVATED' 53 }
        30 { Stop-Finite 'BITLOCKER_QUERY_FAILED' 54 }
        31 { Stop-Finite 'BITLOCKER_RESULT_INVALID' 55 }
        32 { Stop-Finite 'BITLOCKER_STATE_MISMATCH' 56 }
        40 { Stop-Finite 'CHILD_E_FILES_INVALID' 57 }
        41 { Stop-Finite 'CHILD_TOOL_OR_TEMP_FAILED' 58 }
        default { Stop-Finite 'CHILD_UNEXPECTED_FAILURE' 59 }
    }
}
if (-not (Test-UsbIdentity)) { Stop-Finite 'USB_IDENTITY_CHANGED' 60 }
if (-not (Test-EFiles)) { Stop-Finite 'E_FILES_CHANGED' 61 }
if (-not (Test-ToolAndTemp)) { Stop-Finite 'TOOL_OR_TEMP_CHANGED' 62 }
Stop-Finite 'PASS' 0
