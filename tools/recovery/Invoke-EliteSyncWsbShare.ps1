#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $WsbExePath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $SandboxId,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $HostPath,

    [Parameter()]
    [AllowNull()]
    [string] $SandboxPath,

    [Parameter(Mandatory)]
    [bool] $Writable,

    [Parameter(Mandatory)]
    [bool] $RawOutput,

    [Parameter()]
    [ValidateSet('DRY_RUN_ONLY', 'OPERATIONAL')]
    [string] $ExecutionMode = 'DRY_RUN_ONLY',

    [Parameter()]
    [AllowNull()]
    [string] $ActivationToken,

    [Parameter()]
    [AllowNull()]
    [string] $EvidenceDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-UnambiguousText {
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "$Name must contain non-whitespace text."
    }

    if ($Value.IndexOf([char] 0) -ge 0 -or $Value.Contains("`r") -or $Value.Contains("`n")) {
        throw "$Name must not contain NUL, CR, or LF characters."
    }
}

function ConvertTo-DeterministicJsonString {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Value
    )

    $builder = [System.Text.StringBuilder]::new()
    [void] $builder.Append('"')

    foreach ($character in $Value.ToCharArray()) {
        $codePoint = [int] $character
        if ($codePoint -eq 8) {
            [void] $builder.Append('\b')
        }
        elseif ($codePoint -eq 9) {
            [void] $builder.Append('\t')
        }
        elseif ($codePoint -eq 10) {
            [void] $builder.Append('\n')
        }
        elseif ($codePoint -eq 12) {
            [void] $builder.Append('\f')
        }
        elseif ($codePoint -eq 13) {
            [void] $builder.Append('\r')
        }
        elseif ($codePoint -eq 34) {
            [void] $builder.Append('\"')
        }
        elseif ($codePoint -eq 92) {
            [void] $builder.Append('\\')
        }
        elseif ($codePoint -lt 32) {
            [void] $builder.Append(('\u{0:x4}' -f $codePoint))
        }
        else {
            [void] $builder.Append($character)
        }
    }

    [void] $builder.Append('"')
    return $builder.ToString()
}

function New-ArgvReceiptJson {
    param(
        [Parameter(Mandatory)]
        [string] $Mode,

        [Parameter(Mandatory)]
        [bool] $ProcessLaunch,

        [Parameter(Mandatory)]
        [string] $ExecutablePath,

        [Parameter(Mandatory)]
        [string[]] $ArgumentTokens
    )

    $serializedArguments = foreach ($token in $ArgumentTokens) {
        '    ' + (ConvertTo-DeterministicJsonString -Value $token)
    }

    $argumentBlock = $serializedArguments -join ",`n"
    $launchText = if ($ProcessLaunch) { 'true' } else { 'false' }

    return @(
        '{'
        '  "schema": "elitesync.wsb-share.argv-receipt.v1",'
        ('  "executionMode": {0},' -f (ConvertTo-DeterministicJsonString -Value $Mode))
        ('  "processLaunch": {0},' -f $launchText)
        ('  "executablePath": {0},' -f (ConvertTo-DeterministicJsonString -Value $ExecutablePath))
        '  "argv": ['
        $argumentBlock
        '  ]'
        '}'
    ) -join "`n"
}

Assert-UnambiguousText -Name 'WsbExePath' -Value $WsbExePath
Assert-UnambiguousText -Name 'SandboxId' -Value $SandboxId
Assert-UnambiguousText -Name 'HostPath' -Value $HostPath

if ($SandboxId -cnotmatch '^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$') {
    throw 'SandboxId must use the unambiguous 8-4-4-4-12 hexadecimal form.'
}

$sandboxPathWasSupplied = $PSBoundParameters.ContainsKey('SandboxPath')
if ($sandboxPathWasSupplied) {
    if ($null -eq $SandboxPath) {
        throw 'SandboxPath was supplied but is null.'
    }
    Assert-UnambiguousText -Name 'SandboxPath' -Value $SandboxPath
}

$argv = [System.Collections.Generic.List[string]]::new()
$argv.Add('share')
$argv.Add('--id')
$argv.Add($SandboxId)
$argv.Add('--host-path')
$argv.Add($HostPath)

if ($sandboxPathWasSupplied) {
    $argv.Add('--sandbox-path')
    $argv.Add($SandboxPath)
}

if ($Writable) {
    $argv.Add('--allow-write')
}

if ($RawOutput) {
    $argv.Add('--raw')
}

$argumentTokens = $argv.ToArray()

if ($ExecutionMode -ceq 'DRY_RUN_ONLY') {
    if ($PSBoundParameters.ContainsKey('ActivationToken') -or $PSBoundParameters.ContainsKey('EvidenceDirectory')) {
        throw 'ActivationToken and EvidenceDirectory are invalid in DRY_RUN_ONLY mode.'
    }

    New-ArgvReceiptJson -Mode 'DRY_RUN_ONLY' -ProcessLaunch $false -ExecutablePath $WsbExePath -ArgumentTokens $argumentTokens
    return
}

if (-not $PSBoundParameters.ContainsKey('ActivationToken')) {
    throw 'OPERATIONAL mode requires an explicit ActivationToken parameter.'
}
if ($null -eq $ActivationToken) {
    throw 'ActivationToken must not be null.'
}
Assert-UnambiguousText -Name 'ActivationToken' -Value $ActivationToken

$taskOwnedActivationToken = [Environment]::GetEnvironmentVariable(
    'ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN',
    [EnvironmentVariableTarget]::Process
)
if ([string]::IsNullOrWhiteSpace($taskOwnedActivationToken) -or
    -not [string]::Equals($ActivationToken, $taskOwnedActivationToken, [StringComparison]::Ordinal)) {
    throw 'OPERATIONAL mode activation gate is not satisfied.'
}

if (-not $PSBoundParameters.ContainsKey('EvidenceDirectory') -or $null -eq $EvidenceDirectory) {
    throw 'OPERATIONAL mode requires an explicit EvidenceDirectory parameter.'
}
Assert-UnambiguousText -Name 'EvidenceDirectory' -Value $EvidenceDirectory

if (-not (Test-Path -LiteralPath $WsbExePath -PathType Leaf)) {
    throw 'WsbExePath must identify an existing file in OPERATIONAL mode.'
}
if (-not (Test-Path -LiteralPath $EvidenceDirectory -PathType Container)) {
    throw 'EvidenceDirectory must identify a pre-existing directory; this wrapper never creates it.'
}

$receiptPath = Join-Path -Path $EvidenceDirectory -ChildPath 'wsb-share-argv-receipt.json'
$stdoutPath = Join-Path -Path $EvidenceDirectory -ChildPath 'wsb-share-stdout.txt'
$stderrPath = Join-Path -Path $EvidenceDirectory -ChildPath 'wsb-share-stderr.txt'
$resultPath = Join-Path -Path $EvidenceDirectory -ChildPath 'wsb-share-result.json'

foreach ($outputPath in @($receiptPath, $stdoutPath, $stderrPath, $resultPath)) {
    if (Test-Path -LiteralPath $outputPath) {
        throw "Refusing to overwrite existing evidence file: $outputPath"
    }
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$operationalReceipt = New-ArgvReceiptJson -Mode 'OPERATIONAL' -ProcessLaunch $true -ExecutablePath $WsbExePath -ArgumentTokens $argumentTokens
[System.IO.File]::WriteAllText($receiptPath, $operationalReceipt + "`n", $utf8NoBom)
Write-Output $operationalReceipt

$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = $WsbExePath
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
$startInfo.RedirectStandardOutput = $true
$startInfo.RedirectStandardError = $true

foreach ($token in $argumentTokens) {
    $startInfo.ArgumentList.Add($token)
}

$process = [System.Diagnostics.Process]::new()
$process.StartInfo = $startInfo

try {
    if (-not $process.Start()) {
        throw 'Direct process launch returned false.'
    }

    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $process.WaitForExit()
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()

    [System.IO.File]::WriteAllText($stdoutPath, $stdout, $utf8NoBom)
    [System.IO.File]::WriteAllText($stderrPath, $stderr, $utf8NoBom)

    $resultJson = @(
        '{'
        '  "schema": "elitesync.wsb-share.process-result.v1",'
        ('  "exitCode": {0},' -f $process.ExitCode)
        '  "stdoutFile": "wsb-share-stdout.txt",'
        '  "stderrFile": "wsb-share-stderr.txt",'
        '  "argvReceiptFile": "wsb-share-argv-receipt.json"'
        '}'
    ) -join "`n"
    [System.IO.File]::WriteAllText($resultPath, $resultJson + "`n", $utf8NoBom)

    exit $process.ExitCode
}
finally {
    $process.Dispose()
}
