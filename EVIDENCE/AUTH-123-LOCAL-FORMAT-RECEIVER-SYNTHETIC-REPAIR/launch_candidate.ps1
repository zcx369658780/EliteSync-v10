# Review-pending fixed launcher. AUTH-123 Phase B is not released.
param()

$ErrorActionPreference = 'Stop'
$root = 'D:\EliteSync-v10\EVIDENCE\AUTH-123-LOCAL-FORMAT-RECEIVER-SYNTHETIC-REPAIR'
$receiver = Join-Path $root 'receiver_core.ps1'
$python = 'C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe'
$entry = 'D:\EliteSync-v10\EVIDENCE\AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS\local_format_entry.py'
$locked = [ordered]@{
    $receiver = 'BF91E4A663581AC4636EB1A1E1A8846603D3574E6C2AAFEBBF40A55CDFA1E08F'
    $python = '5F7B89A612C9B8AF1D6456CDFCD1DBE5CA630849E79AEBCED9BEE9A6694952EC'
    $entry = '896EA25307601D4416F41219076800020526B96BC19D56338C09F60D14E3E928'
    'D:\EliteSync-v10\EVIDENCE\AUTH-122-LOCAL-KNOWN-HOST-FORMAT-DIAGNOSIS\format_diagnostic.py' = '7D38484AC564046607B0F94A65C63FB5141E3A14372FE5847DECEFF793D9DFDA'
    'D:\EliteSync-v10\EVIDENCE\AUTH-121-LOCAL-KNOWN-HOST-ONE-SHOT-ENTRY\local_known_host_entry.py' = 'E58812A8FCA60859899DAE8F4D87046583068BB383E92538B5AD7C2994005ABE'
    'D:\EliteSync-v10\EVIDENCE\AUTH-120-LOCAL-KNOWN-HOST-FINGERPRINT-CANDIDATE\known_host_candidate.py' = '2D139A7C397FD1DAC2C8719F5C4D939679571D434F689CCAE19D37FC9975E346'
}

function Emit-FixedFailure([string]$Reason) {
    $safe = [ordered]@{
        receiver_status='REJECTED'; reason=$Reason; stage='UNKNOWN'; category='UNKNOWN'
        checked_entries='UNKNOWN'; prior_target_candidate='UNKNOWN'
        port='UNKNOWN'; host_key_trust='UNKNOWN'; exit_code='UNKNOWN'
    }
    [Console]::Out.WriteLine(($safe | ConvertTo-Json -Compress))
    exit 1
}

if ($args.Count -ne 0) { Emit-FixedFailure 'ARGS_UNSUPPORTED' }
try {
    foreach ($path in $locked.Keys) {
        $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
        if ($item.PSIsContainer -or ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or $item.LinkType) {
            Emit-FixedFailure 'PRECHECK_FAILED'
        }
        $actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path -ErrorAction Stop).Hash
        if ($actual -cne $locked[$path]) { Emit-FixedFailure 'PRECHECK_FAILED' }
    }
    . $receiver
    $capture = Invoke-Auth123BoundedProcess -Executable $python -Arguments @('-I','-B',$entry) -TimeoutMs 15000
    if ($capture.status -cne 'COMPLETE') {
        $result = New-Auth123Failure $capture.status
    } else {
        $result = Convert-Auth123Receipt -Stdout $capture.stdout -Stderr $capture.stderr -ProcessExit $capture.exit
    }
    [Console]::Out.WriteLine(($result | ConvertTo-Json -Compress))
    if ($result.receiver_status -ceq 'ACCEPTED_CANDIDATE' -and $result.category -ceq 'FORMAT_INVALID') { exit 0 }
    exit 1
} catch {
    Emit-FixedFailure 'LAUNCHER_FAILED'
}
