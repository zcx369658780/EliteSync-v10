. (Join-Path $PSScriptRoot 'receiver_core.ps1')

$script:checks = 0
function Assert-Check([bool]$Condition) {
    if (-not $Condition) { throw 'SYNTHETIC_ASSERTION_FAILED' }
    $script:checks++
}

$legacy = '{"checked_entries":3}' | ConvertFrom-Json
Assert-Check ($legacy.checked_entries.GetType().FullName -ceq 'System.Int64')
Assert-Check ($legacy.checked_entries -isnot [int])

$base = '{"stage":"KEY_BASE64","category":"FORMAT_INVALID","checked_entries":3,"prior_target_candidate":"NO","port":"UNKNOWN","host_key_trust":"UNKNOWN"}'
$good = Convert-Auth123Receipt -Stdout ($base + "`n") -Stderr '' -ProcessExit 0
Assert-Check ($good.receiver_status -ceq 'ACCEPTED_CANDIDATE')
Assert-Check ($good.checked_entries -eq 3 -and $good.stage -ceq 'KEY_BASE64' -and $good.exit_code -eq 0)
Assert-Check ($good.port -ceq 'UNKNOWN' -and $good.host_key_trust -ceq 'UNKNOWN')
$goodCrlf = Convert-Auth123Receipt -Stdout ($base + "`r`n") -Stderr '' -ProcessExit 0
Assert-Check ($goodCrlf.receiver_status -ceq 'ACCEPTED_CANDIDATE' -and $goodCrlf.checked_entries -eq 3)

function Check-Rejected([string]$Json, [object]$ExitCode, [string]$ExpectedReason) {
    $r = Convert-Auth123Receipt -Stdout $Json -Stderr '' -ProcessExit $ExitCode
    Assert-Check ($r.receiver_status -ceq 'REJECTED' -and $r.reason -ceq $ExpectedReason)
    Assert-Check ($r.stage -ceq 'UNKNOWN' -and $r.checked_entries -ceq 'UNKNOWN')
}

Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":true') + "`n") 0 'COUNT_INVALID'
Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":"3"') + "`n") 0 'COUNT_INVALID'
Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":3.0') + "`n") 0 'COUNT_INVALID'
Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":-1') + "`n") 0 'COUNT_INVALID'
Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":257') + "`n") 0 'COUNT_INVALID'
Check-Rejected ($base.Replace('"checked_entries":3','"checked_entries":3,"checked_entries":3') + "`n") 0 'SCHEMA_INVALID'
Check-Rejected ($base.Replace('"port":"UNKNOWN"','"port":"UNKNOWN","extra":"SYNTHETIC_SECRET"') + "`n") 0 'SCHEMA_INVALID'
Check-Rejected ($base.Replace(',"port":"UNKNOWN"','') + "`n") 0 'SCHEMA_INVALID'
Check-Rejected ($base + "`n") 1 'EXIT_OR_SCHEMA_CONTRADICTION'
Check-Rejected ($base + "`n" + $base + "`n") 0 'FRAME_INVALID'
Check-Rejected ($base + "`r`r`n") 0 'FRAME_INVALID'
Check-Rejected ($base.Insert(4, "`r") + "`n") 0 'FRAME_INVALID'
Check-Rejected ($base) 0 'FRAME_INVALID'
Check-Rejected (('x' * 2049) + "`n") 0 'STREAM_LIMIT'

$stderrResult = Convert-Auth123Receipt -Stdout ($base + "`n") -Stderr 'SYNTHETIC_SECRET_STDERR' -ProcessExit 0
Assert-Check ($stderrResult.reason -ceq 'STDERR_NONEMPTY' -and ('SYNTHETIC_SECRET' -notin ($stderrResult | ConvertTo-Json -Compress)))
$timeoutResult = Convert-Auth123Receipt -Stdout ($base + "`n") -Stderr '' -ProcessExit 0 -TimedOut $true
Assert-Check ($timeoutResult.reason -ceq 'TIMEOUT')
$limitResult = Convert-Auth123Receipt -Stdout ($base + "`n") -Stderr '' -ProcessExit 0 -Overflow $true
Assert-Check ($limitResult.reason -ceq 'STREAM_LIMIT')
$failedJson = '{"stage":"TARGET_READ_FAILED","category":"DIAGNOSTIC_FAILED","checked_entries":0,"prior_target_candidate":"NO","port":"UNKNOWN","host_key_trust":"UNKNOWN"}'
$failed = Convert-Auth123Receipt -Stdout ($failedJson + "`n") -Stderr '' -ProcessExit 1
Assert-Check ($failed.receiver_status -ceq 'ACCEPTED_CANDIDATE' -and $failed.category -ceq 'DIAGNOSTIC_FAILED')
Check-Rejected ($failedJson + "`n") 0 'EXIT_OR_SCHEMA_CONTRADICTION'

$python = 'C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe'
$emitter = Join-Path $PSScriptRoot 'fake_emitter.py'
$normal = Invoke-Auth123BoundedProcess -Executable $python -Arguments @('-I','-B',$emitter,'normal') -TimeoutMs 2000
Assert-Check ($normal.status -ceq 'COMPLETE' -and $normal.exit -eq 0)
$projected = Convert-Auth123Receipt -Stdout $normal.stdout -Stderr $normal.stderr -ProcessExit $normal.exit
Assert-Check ($projected.receiver_status -ceq 'ACCEPTED_CANDIDATE' -and $projected.checked_entries -eq 3)
$withErr = Invoke-Auth123BoundedProcess -Executable $python -Arguments @('-I','-B',$emitter,'stderr') -TimeoutMs 2000
Assert-Check ($withErr.status -ceq 'COMPLETE')
$projected = Convert-Auth123Receipt -Stdout $withErr.stdout -Stderr $withErr.stderr -ProcessExit $withErr.exit
Assert-Check ($projected.reason -ceq 'STDERR_NONEMPTY' -and ('SYNTHETIC_SECRET' -notin ($projected | ConvertTo-Json -Compress)))
$large = Invoke-Auth123BoundedProcess -Executable $python -Arguments @('-I','-B',$emitter,'overflow') -TimeoutMs 2000
Assert-Check ($large.status -ceq 'STREAM_LIMIT' -and $large.stdout -ceq '' -and $large.stderr -ceq '')
Assert-Check ($large.reaped -eq $true -and $large.pid -is [int])
Assert-Check ($null -eq (Get-Process -Id $large.pid -ErrorAction SilentlyContinue))
$slow = Invoke-Auth123BoundedProcess -Executable $python -Arguments @('-I','-B',$emitter,'timeout') -TimeoutMs 200
Assert-Check ($slow.status -ceq 'TIMEOUT' -and $slow.stdout -ceq '' -and $slow.stderr -ceq '')
Assert-Check ($slow.reaped -eq $true -and $slow.pid -is [int])
Assert-Check ($null -eq (Get-Process -Id $slow.pid -ErrorAction SilentlyContinue))

Write-Output "SYNTHETIC_CHECKS_PASS=$script:checks"
