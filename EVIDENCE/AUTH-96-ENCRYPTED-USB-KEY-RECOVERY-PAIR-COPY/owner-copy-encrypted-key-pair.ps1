param([switch]$Elevated)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

$expectedScript = 'D:\EliteSync-v10\EVIDENCE\AUTH-96-ENCRYPTED-USB-KEY-RECOVERY-PAIR-COPY\owner-copy-encrypted-key-pair.ps1'
$windowsPowerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$keySource = 'C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.key.pem'
$certSource = 'C:\Users\zcxve\EliteSync-v10-DB-Keys\elitesync-v10-db-backup-recipient-20260925.cert.pem'
$keyTarget = 'E:\elitesync-v10-db-backup-recipient-20260925.key.pem'
$certTarget = 'E:\elitesync-v10-db-backup-recipient-20260925.cert.pem'
$expectedCertFingerprint = '3AB76496F11B2AF5D3AE7975569A6100FD54E6BC99A41BBF7A22967ED5567461'

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
        if ([double]$volume.SizeRemaining -lt 1MB) { return $false }
        return $true
    } catch {
        return $false
    }
}

function Test-TargetAbsent {
    try {
        foreach ($target in @($keyTarget, $certTarget)) {
            if (Test-Path -LiteralPath $target) { return $false }
        }
        return $true
    } catch {
        return $false
    }
}

function Test-FixedSources {
    try {
        $key = Get-Item -LiteralPath $keySource -Force -ErrorAction Stop
        $cert = Get-Item -LiteralPath $certSource -Force -ErrorAction Stop
        if ($key.PSIsContainer -or $cert.PSIsContainer) { return $false }
        if (($key.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ($cert.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        if ($key.Length -ne 2666 -or $cert.Length -ne 1541) { return $false }

        $acl = Get-Acl -LiteralPath $keySource -ErrorAction Stop
        $userSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
        $ownerSid = (New-Object -TypeName Security.Principal.NTAccount -ArgumentList $acl.Owner).Translate(
            [Security.Principal.SecurityIdentifier]).Value
        $rules = @($acl.Access)
        if (-not $acl.AreAccessRulesProtected -or $ownerSid -ne $userSid -or $rules.Count -ne 3) { return $false }
        $sids = @($rules | ForEach-Object {
            $_.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value
        })
        $expectedSids = @($userSid, 'S-1-5-18', 'S-1-5-32-544')
        if ((@($sids | Sort-Object) -join ',') -cne (@($expectedSids | Sort-Object) -join ',')) { return $false }
        foreach ($rule in $rules) {
            if ($rule.IsInherited -or $rule.AccessControlType -ne 'Allow' -or
                $rule.FileSystemRights -ne [Security.AccessControl.FileSystemRights]::FullControl) { return $false }
        }

        $headerBytes = [Text.Encoding]::ASCII.GetBytes('-----BEGIN ENCRYPTED PRIVATE KEY-----')
        $stream = [IO.File]::Open($keySource, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            foreach ($expectedByte in $headerBytes) {
                if ($stream.ReadByte() -ne $expectedByte) { return $false }
            }
            $lineEnd = $stream.ReadByte()
            if ($lineEnd -eq 13) { $lineEnd = $stream.ReadByte() }
            if ($lineEnd -ne 10) { return $false }
        } finally { $stream.Dispose() }

        $certText = [IO.File]::ReadAllText($certSource)
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

function Test-BytesMatch {
    param([string]$Source, [string]$Target, [long]$ExpectedLength)
    try {
        $sourceItem = Get-Item -LiteralPath $Source -Force -ErrorAction Stop
        $targetItem = Get-Item -LiteralPath $Target -Force -ErrorAction Stop
        if ($sourceItem.PSIsContainer -or $targetItem.PSIsContainer) { return $false }
        if (($sourceItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            ($targetItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return $false }
        if ($sourceItem.Length -ne $ExpectedLength -or $targetItem.Length -ne $ExpectedLength) { return $false }
        $sourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256 -ErrorAction Stop).Hash
        $targetHash = (Get-FileHash -LiteralPath $Target -Algorithm SHA256 -ErrorAction Stop).Hash
        return ($sourceHash -ceq $targetHash)
    } catch {
        return $false
    }
}

if ([string]$PSCommandPath -ine $expectedScript) {
    if (-not $Elevated) { Write-Output 'AUTH96_RESULT=SCRIPT_PATH_MISMATCH' }
    exit 10
}
if (-not (Test-FixedUsbIdentity)) {
    if (-not $Elevated) { Write-Output 'AUTH96_RESULT=IDENTITY_OR_SPACE_FAILED' }
    exit 20
}

if ($Elevated) {
    try {
        $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 21 }
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
        if (-not (Test-FixedSources)) { exit 40 }
        if (-not (Test-TargetAbsent)) { exit 41 }
        if (-not (Test-FixedUsbIdentity)) { exit 20 }
        try { [IO.File]::Copy($keySource, $keyTarget, $false) }
        catch { exit 42 }
        if (-not (Test-BytesMatch $keySource $keyTarget 2666)) { exit 43 }
        try { [IO.File]::Copy($certSource, $certTarget, $false) }
        catch { exit 44 }
        if (-not (Test-BytesMatch $certSource $certTarget 1541)) { exit 45 }
        if (-not (Test-BytesMatch $keySource $keyTarget 2666)) { exit 46 }
        exit 0
    } catch {
        exit 49
    }
}

if (-not (Test-FixedSources)) {
    Write-Output 'AUTH96_RESULT=SOURCE_INVALID'
    exit 40
}
if (-not (Test-TargetAbsent)) {
    Write-Output 'AUTH96_RESULT=TARGET_PRESENT'
    exit 41
}
try {
    $arguments = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'RemoteSigned',
        '-File', ('"' + $expectedScript + '"'), '-Elevated')
    $child = Start-Process -FilePath $windowsPowerShell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
    $code = [int]$child.ExitCode
} catch {
    Write-Output 'AUTH96_RESULT=UAC_OR_LAUNCH_FAILED'
    exit 50
}

switch ($code) {
    0 { Write-Output 'AUTH96_RESULT=PAIR_MATCH;CHILD_EXIT=0'; exit 0 }
    10 { Write-Output 'AUTH96_RESULT=CHILD_SCRIPT_PATH_MISMATCH;CHILD_EXIT=10'; exit 1 }
    20 { Write-Output 'AUTH96_RESULT=CHILD_IDENTITY_OR_SPACE_FAILED;CHILD_EXIT=20'; exit 1 }
    21 { Write-Output 'AUTH96_RESULT=CHILD_NOT_ELEVATED;CHILD_EXIT=21'; exit 1 }
    30 { Write-Output 'AUTH96_RESULT=BITLOCKER_QUERY_FAILED;CHILD_EXIT=30'; exit 1 }
    31 { Write-Output 'AUTH96_RESULT=BITLOCKER_RESULT_INVALID;CHILD_EXIT=31'; exit 1 }
    32 { Write-Output 'AUTH96_RESULT=BITLOCKER_STATE_MISMATCH;CHILD_EXIT=32'; exit 1 }
    40 { Write-Output 'AUTH96_RESULT=CHILD_SOURCE_INVALID;CHILD_EXIT=40'; exit 1 }
    41 { Write-Output 'AUTH96_RESULT=CHILD_TARGET_PRESENT;CHILD_EXIT=41'; exit 1 }
    42 { Write-Output 'AUTH96_RESULT=KEY_COPY_FAILED;CHILD_EXIT=42'; exit 1 }
    43 { Write-Output 'AUTH96_RESULT=KEY_VERIFY_FAILED;CHILD_EXIT=43'; exit 1 }
    44 { Write-Output 'AUTH96_RESULT=CERT_COPY_FAILED;CHILD_EXIT=44'; exit 1 }
    45 { Write-Output 'AUTH96_RESULT=CERT_VERIFY_FAILED;CHILD_EXIT=45'; exit 1 }
    46 { Write-Output 'AUTH96_RESULT=FINAL_KEY_VERIFY_FAILED;CHILD_EXIT=46'; exit 1 }
    49 { Write-Output 'AUTH96_RESULT=CHILD_UNEXPECTED_FAILURE;CHILD_EXIT=49'; exit 1 }
    default { Write-Output 'AUTH96_RESULT=CHILD_EXIT_UNEXPECTED;CHILD_EXIT=OTHER'; exit 1 }
}
