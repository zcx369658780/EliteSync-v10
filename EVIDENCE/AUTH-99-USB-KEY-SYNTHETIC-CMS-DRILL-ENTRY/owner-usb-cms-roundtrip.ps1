param([switch]$ElevatedCheck)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

$expectedScript = 'D:\EliteSync-v10\EVIDENCE\AUTH-99-USB-KEY-SYNTHETIC-CMS-DRILL-ENTRY\owner-usb-cms-roundtrip.ps1'
$windowsPowerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$openssl = 'C:\Program Files\Git\usr\bin\openssl.exe'
$keyPath = 'E:\elitesync-v10-db-backup-recipient-20260925.key.pem'
$certPath = 'E:\elitesync-v10-db-backup-recipient-20260925.cert.pem'
$expectedCertFingerprint = '3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461'
$tempRoot = 'C:\Users\zcxve\AppData\Local\Temp'
$markerPath = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth99-synthetic-marker.txt'
$cmsPath = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth99-synthetic-cms.der'
$decryptedPath = 'C:\Users\zcxve\AppData\Local\Temp\elitesync-auth99-synthetic-decrypted-marker.txt'

function Test-FixedUsbIdentity {
    try {
        $partitions = @(Get-Partition -DriveLetter 'E' -ErrorAction Stop)
        if ($partitions.Count -ne 1) { return $false }
        $partition = $partitions[0]
        $usbDisks = @(Get-Disk -ErrorAction Stop | Where-Object { [string]$_.BusType -ceq 'USB' })
        if ($usbDisks.Count -ne 1) { return $false }
        $disk = $usbDisks[0]
        if ([string]$disk.FriendlyName -cne 'Kingston DataTraveler Duo') { return $false }
        if ([int]$disk.Number -ne [int]$partition.DiskNumber) { return $false }
        if ([double]$disk.Size -lt 25GB -or [double]$disk.Size -gt 35GB) { return $false }
        $diskPartitions = @(Get-Partition -DiskNumber $disk.Number -ErrorAction Stop |
            Where-Object { [string]$_.DriveLetter -ceq 'E' })
        if ($diskPartitions.Count -ne 1) { return $false }
        if ([int]$diskPartitions[0].PartitionNumber -ne [int]$partition.PartitionNumber) { return $false }
        $volumesByPartition = @(Get-Volume -Partition $partition -ErrorAction Stop)
        $volumesByLetter = @(Get-Volume -DriveLetter 'E' -ErrorAction Stop)
        if ($volumesByPartition.Count -ne 1 -or $volumesByLetter.Count -ne 1) { return $false }
        $volume = $volumesByPartition[0]
        if ([string]$volume.DriveLetter -cne 'E') { return $false }
        if ([string]$volume.DriveType -cne 'Removable') { return $false }
        if ([string]$volume.ObjectId -cne [string]$volumesByLetter[0].ObjectId) { return $false }
        return $true
    } catch {
        return $false
    }
}

function Test-TempBoundary {
    try {
        $root = Get-Item -LiteralPath $tempRoot -Force -ErrorAction Stop
        if (-not $root.PSIsContainer -or ($root.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        foreach ($path in @($markerPath, $cmsPath, $decryptedPath)) {
            if (Test-Path -LiteralPath $path) { return $false }
        }
        return $true
    } catch {
        return $false
    }
}

function Test-FixedEFiles {
    try {
        $key = Get-Item -LiteralPath $keyPath -Force -ErrorAction Stop
        $cert = Get-Item -LiteralPath $certPath -Force -ErrorAction Stop
        if ($key.PSIsContainer -or $cert.PSIsContainer) { return $false }
        if (($key.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ($cert.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        if ($key.Length -ne 2666 -or $cert.Length -ne 1541) { return $false }
        $header = [Text.Encoding]::ASCII.GetBytes('-----BEGIN ENCRYPTED PRIVATE KEY-----')
        $stream = [IO.File]::Open($keyPath, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            foreach ($byte in $header) {
                if ($stream.ReadByte() -ne $byte) { return $false }
            }
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
    } catch {
        return $false
    }
}

function Test-OpenSslIdentity {
    try {
        $item = Get-Item -LiteralPath $openssl -Force -ErrorAction Stop
        if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        return ((Get-FileHash -LiteralPath $openssl -Algorithm SHA256 -ErrorAction Stop).Hash -ceq
            '21C43808DDC48B9B2133ED4FE9F4F90D77305568EF3BB8291DD05D271E29A54B')
    } catch {
        return $false
    }
}

function Stop-Finite {
    param([string]$Category, [int]$Code)
    Write-Output "AUTH99_RESULT=$Category;EXIT=$Code"
    exit $Code
}

if ([string]$PSCommandPath -ine $expectedScript) {
    if ($ElevatedCheck) { exit 10 }
    Stop-Finite 'SCRIPT_PATH_MISMATCH' 10
}
if (-not (Test-FixedUsbIdentity)) {
    if ($ElevatedCheck) { exit 20 }
    Stop-Finite 'USB_IDENTITY_FAILED' 20
}
if (-not (Test-TempBoundary)) {
    if ($ElevatedCheck) { exit 21 }
    Stop-Finite 'TEMP_BOUNDARY_FAILED' 21
}

if ($ElevatedCheck) {
    try {
        $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 22 }
        try { $states = @(Get-BitLockerVolume -MountPoint 'E:' -ErrorAction Stop) }
        catch { exit 30 }
        if ($states.Count -ne 1) { exit 31 }
        $state = $states[0]
        if ($null -eq $state.ProtectionStatus -or
            $state.ProtectionStatus.GetType().FullName -cne 'Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus' -or
            [string]$state.LockStatus -cne 'Unlocked' -or
            [string]$state.ProtectionStatus -cne 'On' -or
            [string]$state.VolumeStatus -cne 'FullyEncrypted' -or
            [string]$state.EncryptionPercentage -cne '100') { exit 32 }
        if (-not (Test-FixedUsbIdentity)) { exit 20 }
        if (-not (Test-FixedEFiles)) { exit 40 }
        exit 0
    } catch {
        exit 49
    }
}

if (-not (Test-OpenSslIdentity)) { Stop-Finite 'OPENSSL_IDENTITY_FAILED' 41 }
try {
    $arguments = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'RemoteSigned',
        '-File', ('"' + $expectedScript + '"'), '-ElevatedCheck')
    $child = Start-Process -FilePath $windowsPowerShell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
    $childExit = [int]$child.ExitCode
} catch {
    Stop-Finite 'UAC_OR_LAUNCH_FAILED' 50
}
if ($childExit -ne 0) {
    switch ($childExit) {
        10 { Stop-Finite 'CHILD_SCRIPT_PATH_MISMATCH' 51 }
        20 { Stop-Finite 'CHILD_USB_IDENTITY_FAILED' 52 }
        21 { Stop-Finite 'CHILD_TEMP_BOUNDARY_FAILED' 53 }
        22 { Stop-Finite 'CHILD_NOT_ELEVATED' 54 }
        30 { Stop-Finite 'BITLOCKER_QUERY_FAILED' 55 }
        31 { Stop-Finite 'BITLOCKER_RESULT_INVALID' 56 }
        32 { Stop-Finite 'BITLOCKER_STATE_MISMATCH' 57 }
        40 { Stop-Finite 'E_FILES_INVALID' 58 }
        default { Stop-Finite 'CHILD_UNEXPECTED_FAILURE' 59 }
    }
}
if (-not (Test-FixedUsbIdentity)) { Stop-Finite 'USB_IDENTITY_CHANGED' 60 }
if (-not (Test-FixedEFiles)) { Stop-Finite 'E_FILES_CHANGED' 61 }
if (-not (Test-OpenSslIdentity)) { Stop-Finite 'OPENSSL_IDENTITY_CHANGED' 62 }
if (-not (Test-TempBoundary)) { Stop-Finite 'TEMP_BOUNDARY_CHANGED' 63 }

try {
    $bytes = [Text.Encoding]::ASCII.GetBytes("AUTH99_USB_KEY_A_ONLY_20260925`r`n")
    $stream = [IO.File]::Open($markerPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
    if ((Get-Item -LiteralPath $markerPath -ErrorAction Stop).Length -ne 32) { Stop-Finite 'MARKER_FAILED' 70 }
} catch {
    Stop-Finite 'MARKER_FAILED' 70
}

try {
    & $openssl cms -encrypt -binary -aes-256-cbc -in $markerPath -out $cmsPath -outform DER $certPath 1>$null 2>$null
    $encryptExit = $LASTEXITCODE
} catch {
    Stop-Finite 'ENCRYPT_FAILED' 71
}
if ($encryptExit -ne 0 -or -not (Test-Path -LiteralPath $cmsPath)) { Stop-Finite 'ENCRYPT_FAILED' 71 }

try {
    & $openssl cms -decrypt -binary -inform DER -in $cmsPath -recip $certPath -inkey 'E:\elitesync-v10-db-backup-recipient-20260925.key.pem' -out $decryptedPath 1>$null 2>$null
    $decryptExit = $LASTEXITCODE
} catch {
    Stop-Finite 'DECRYPT_FAILED' 72
}
if ($decryptExit -ne 0 -or -not (Test-Path -LiteralPath $decryptedPath)) { Stop-Finite 'DECRYPT_FAILED' 72 }

try {
    & 'C:\Windows\System32\fc.exe' /b $markerPath $decryptedPath 1>$null 2>$null
    $compareExit = $LASTEXITCODE
} catch {
    Stop-Finite 'COMPARE_FAILED' 73
}
if ($compareExit -ne 0) { Stop-Finite 'COMPARE_FAILED' 73 }

foreach ($path in @($markerPath, $cmsPath, $decryptedPath)) {
    try {
        [IO.File]::Delete($path)
        if (Test-Path -LiteralPath $path) { Stop-Finite 'CLEANUP_FAILED' 74 }
    } catch {
        Stop-Finite 'CLEANUP_FAILED' 74
    }
}
Stop-Finite 'A_MATCH_AND_CLEAN' 0
