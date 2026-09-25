param([switch]$Elevated)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

$expectedScript = 'D:\EliteSync-v10\EVIDENCE\AUTH-95-USB-BITLOCKER-PROTECTION-ENUM-REPAIR\owner-usb-bitlocker-readonly.ps1'
$windowsPowerShell = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'

function Get-ProtectionClass {
    param([object]$Status)
    if ($null -eq $Status) { return 3 }
    if ($Status.GetType().FullName -cne 'Microsoft.BitLocker.Structures.BitLockerVolumeProtectionStatus') { return 3 }
    switch -CaseSensitive ([string]$Status) {
        'On' { return 0 }
        'Off' { return 1 }
        'Unknown' { return 2 }
        default { return 3 }
    }
}

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
    if (-not $Elevated) { Write-Output 'AUTH95_RESULT=SCRIPT_PATH_MISMATCH' }
    exit 10
}

if (-not (Test-FixedUsbIdentity)) {
    if (-not $Elevated) { Write-Output 'AUTH95_RESULT=IDENTITY_MISMATCH' }
    exit 20
}

if ($Elevated) {
    try {
        $principal = [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
        if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { exit 21 }
        $states = @(Get-BitLockerVolume -MountPoint 'E:' -ErrorAction Stop)
        if ($states.Count -ne 1) { exit 31 }
        $state = $states[0]
        $protectionClass = Get-ProtectionClass $state.ProtectionStatus
        $mask = 0
        if ([string]$state.LockStatus -cne 'Unlocked') { $mask = $mask -bor 1 }
        if ([string]$state.VolumeStatus -cne 'FullyEncrypted') { $mask = $mask -bor 4 }
        if ([string]$state.EncryptionPercentage -cne '100') { $mask = $mask -bor 8 }
        if ($mask -eq 0 -and $protectionClass -eq 0) { exit 0 }
        exit (100 + 16 * $protectionClass + $mask)
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
    Write-Output 'AUTH95_RESULT=UAC_OR_LAUNCH_FAILED'
    exit 40
}

if ($code -eq 0) {
    Write-Output 'AUTH95_RESULT=ALL_FOUR_MATCH;CHILD_EXIT=0'
    exit 0
}
if ($code -ge 100 -and $code -le 161) {
    $raw = $code - 100
    $protectionClass = [int][math]::Floor($raw / 16)
    $mask = $raw % 16
    if (($mask -band 2) -ne 0 -or ($protectionClass -eq 0 -and $mask -eq 0)) {
        Write-Output 'AUTH95_RESULT=CHILD_EXIT_UNEXPECTED;CHILD_EXIT=OTHER'
        exit 47
    }
    $lock = if (($mask -band 1) -eq 0) { 'UNLOCKED' } else { 'OTHER' }
    $protection = switch ($protectionClass) {
        0 { 'ON' }
        1 { 'OFF' }
        2 { 'UNKNOWN' }
        default { 'INVALID' }
    }
    $volume = if (($mask -band 4) -eq 0) { 'FULLY_ENCRYPTED' } else { 'OTHER' }
    $percentage = if (($mask -band 8) -eq 0) { '100' } else { 'OTHER' }
    Write-Output "AUTH95_RESULT=FIELD_MISMATCH;LOCK=$lock;PROTECTION=$protection;VOLUME=$volume;PERCENT=$percentage;CHILD_EXIT=$code"
    exit 41
}
switch ($code) {
    10 { Write-Output 'AUTH95_RESULT=CHILD_SCRIPT_PATH_MISMATCH;CHILD_EXIT=10'; exit 42 }
    20 { Write-Output 'AUTH95_RESULT=CHILD_IDENTITY_MISMATCH;CHILD_EXIT=20'; exit 43 }
    21 { Write-Output 'AUTH95_RESULT=CHILD_NOT_ELEVATED;CHILD_EXIT=21'; exit 44 }
    30 { Write-Output 'AUTH95_RESULT=QUERY_FAILED;CHILD_EXIT=30'; exit 45 }
    31 { Write-Output 'AUTH95_RESULT=QUERY_RESULT_INVALID;CHILD_EXIT=31'; exit 46 }
    default { Write-Output 'AUTH95_RESULT=CHILD_EXIT_UNEXPECTED;CHILD_EXIT=OTHER'; exit 47 }
}
