$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
. (Join-Path -Path $PSScriptRoot -ChildPath 'parse_mounts.ps1')

$attempted = 0
$passed = 0
$currentCase = 'NOT_STARTED'

function Assert-Case {
    param(
        [string]$Label,
        [AllowNull()][object]$InputValue,
        [object]$ExpectedCount,
        [bool]$ExpectedAllTmpfs,
        [bool]$ExpectedDestinationsAllowed,
        [bool]$ExpectedParseOk
    )
    $script:currentCase = $Label
    $script:attempted++
    $actual = Parse-Mounts -Mounts $InputValue
    if ([string]$actual.count -cne [string]$ExpectedCount -or
        $actual.all_tmpfs -cne $ExpectedAllTmpfs -or
        $actual.destinations_allowed -cne $ExpectedDestinationsAllowed -or
        $actual.parse_ok -cne $ExpectedParseOk) {
        throw [InvalidOperationException]::new('fixed assertion failed')
    }
    $script:passed++
}

$validA = [pscustomobject]@{ Type = 'tmpfs'; Destination = '/var/lib/mysql' }
$validB = [pscustomobject]@{ Type = 'tmpfs'; Destination = '/run/mysqld' }
$validC = [pscustomobject]@{ Type = 'tmpfs'; Destination = '/tmp' }

try {
    Assert-Case 'null_count_safe' $null 0 $false $false $true
    Assert-Case 'empty_array_count_safe' ([object[]]@()) 0 $false $false $true
    Assert-Case 'three_valid_tmpfs' ([object[]]@($validA, $validB, $validC)) 3 $true $true $true
    Assert-Case 'one_valid_tmpfs' ([object[]]@($validC)) 1 $true $true $true
    Assert-Case 'bind_rejected' ([object[]]@([pscustomobject]@{ Type = 'bind'; Destination = '/tmp' })) 1 $false $true $false
    Assert-Case 'volume_rejected' ([object[]]@([pscustomobject]@{ Type = 'volume'; Destination = '/tmp' })) 1 $false $true $false
    Assert-Case 'extra_destination_rejected' ([object[]]@([pscustomobject]@{ Type = 'tmpfs'; Destination = '/elsewhere' })) 1 $true $false $false
    Assert-Case 'missing_type_rejected' ([object[]]@([pscustomobject]@{ Destination = '/tmp' })) 1 $false $false $false
    Assert-Case 'missing_destination_rejected' ([object[]]@([pscustomobject]@{ Type = 'tmpfs' })) 1 $false $false $false
    Assert-Case 'scalar_object_rejected' $validC 'UNKNOWN' $false $false $false
    Assert-Case 'malformed_scalar_rejected' 'not-an-array' 'UNKNOWN' $false $false $false
    Assert-Case 'malformed_entry_rejected' ([object[]]@('not-an-object')) 1 $false $false $false
    Assert-Case 'duplicate_destination_rejected' ([object[]]@($validC, $validC)) 2 $true $false $false
    $emptyFromIf = if ($true) { @() } else { @(1) }
    Assert-Case 'strict_mode_if_empty_count_safe' $emptyFromIf 0 $false $false $true
    [ordered]@{ status = 'PASS'; attempted = $attempted; passed = $passed; first_failure = 'NONE' } | ConvertTo-Json -Compress
} catch {
    [ordered]@{ status = 'FAIL'; attempted = $attempted; passed = $passed; first_failure = $currentCase } | ConvertTo-Json -Compress
    exit 1
}
