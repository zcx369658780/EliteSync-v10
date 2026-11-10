param([switch]$Elevated)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

$expectedScript = 'D:\EliteSync-v10\EVIDENCE\AUTH-93-CURRENT-USB-BITLOCKER-READONLY-PREFLIGHT\owner-usb-bitlocker-readonly.ps1'
$windowsPowerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'

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
        if ([double]$disk.Size -lt (25GB) -or [double]$disk.Size -gt (35GB)) { return $false }

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

if ([string]$PSCommandPath -ine $expectedScript) {
    if (-not $Elevated) { Write-Output 'AUTH93_RESULT=SCRIPT_PATH_MISMATCH' }
    exit 10
}

if (-not (Test-FixedUsbIdentity)) {
    if (-not $Elevated) { Write-Output 'AUTH93_RESULT=IDENTITY_MISMATCH' }
    exit 20
}

if ($Elevated) {
    try {
        $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 21 }
        $states = @(Get-BitLockerVolume -MountPoint 'E:' -ErrorAction Stop)
        if ($states.Count -ne 1) { exit 31 }
        $state = $states[0]
        $mask = 0
        if ([string]$state.LockStatus -cne 'Unlocked') { $mask = $mask -bor 1 }
        if ([string]$state.ProtectionStatus -cne 'ProtectionOn') { $mask = $mask -bor 2 }
        if ([string]$state.VolumeStatus -cne 'FullyEncrypted') { $mask = $mask -bor 4 }
        if ([string]$state.EncryptionPercentage -cne '100') { $mask = $mask -bor 8 }
        if ($mask -eq 0) { exit 0 }
        exit (100 + $mask)
    } catch {
        exit 30
    }
}

try {
    $arguments = @('-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'RemoteSigned',
        '-File', ('"' + $expectedScript + '"'), '-Elevated')
    $child = Start-Process -FilePath $windowsPowerShell -ArgumentList $arguments -Verb RunAs -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
    $code = [int]$child.ExitCode
} catch {
    Write-Output 'AUTH93_RESULT=UAC_OR_LAUNCH_FAILED'
    exit 40
}

if ($code -eq 0) {
    Write-Output 'AUTH93_RESULT=ALL_FOUR_MATCH;CHILD_EXIT=0'
    exit 0
}
if ($code -ge 101 -and $code -le 115) {
    $mask = $code - 100
    $lock = if (($mask -band 1) -eq 0) { 'UNLOCKED' } else { 'OTHER' }
    $protection = if (($mask -band 2) -eq 0) { 'PROTECTION_ON' } else { 'OTHER' }
    $volume = if (($mask -band 4) -eq 0) { 'FULLY_ENCRYPTED' } else { 'OTHER' }
    $percentage = if (($mask -band 8) -eq 0) { '100' } else { 'OTHER' }
    Write-Output "AUTH93_RESULT=FIELD_MISMATCH;LOCK=$lock;PROTECTION=$protection;VOLUME=$volume;PERCENT=$percentage;CHILD_EXIT=$code"
    exit 41
}
switch ($code) {
    10 { Write-Output 'AUTH93_RESULT=CHILD_SCRIPT_PATH_MISMATCH;CHILD_EXIT=10'; exit 42 }
    20 { Write-Output 'AUTH93_RESULT=CHILD_IDENTITY_MISMATCH;CHILD_EXIT=20'; exit 43 }
    21 { Write-Output 'AUTH93_RESULT=CHILD_NOT_ELEVATED;CHILD_EXIT=21'; exit 44 }
    30 { Write-Output 'AUTH93_RESULT=QUERY_FAILED;CHILD_EXIT=30'; exit 45 }
    31 { Write-Output 'AUTH93_RESULT=QUERY_RESULT_INVALID;CHILD_EXIT=31'; exit 46 }
    default { Write-Output 'AUTH93_RESULT=CHILD_EXIT_UNEXPECTED;CHILD_EXIT=OTHER'; exit 47 }
}
