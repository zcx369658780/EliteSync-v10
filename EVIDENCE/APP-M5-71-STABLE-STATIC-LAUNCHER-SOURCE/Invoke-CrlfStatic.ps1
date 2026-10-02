# SOURCE-ONLY M5-71. Execution requires a separate issued task and budget.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = 'D:\EliteSync-v10'
$python = 'C:\Users\zcxve\AppData\Local\Programs\Python\Python311\python.exe'
$validator = Join-Path $root 'EVIDENCE/APP-M5-69-STABLE-CRLF-VALIDATOR-SOURCE/validate_crlf_transform.py'
$candidate = Join-Path $root 'apps/android_synthetic_demo/tools/aar_scoped_crlf_kotlin_transform.py'
$outputDir = Join-Path $root 'EVIDENCE/APP-M5-72-FROZEN-STATIC-LAUNCHER-ONCE'
$stdoutPath = Join-Path $outputDir 'invocation-stdout.txt'
$stderrPath = Join-Path $outputDir 'invocation-stderr.txt'
$utf = [Text.UTF8Encoding]::new($false, $true)
$phase = 'INITIALIZATION'
$firstPhase = $null
$firstTag = $null
$secondary = [Collections.Generic.List[string]]::new()
$resources = [Collections.Generic.List[object]]::new()
$attempt = 0
$started = 0
$exited = $false
$timedOut = $false
$killAttempt = 0
$killReturned = $false
$exitCode = $null
$waitAttempt = 0
$cleanupWaitAttempt = 0
$joinAttempt = 0
$stdoutCopyStarted = $false
$stderrCopyStarted = $false
$stdoutComplete = $false
$stderrComplete = $false
$stdoutBytes = $null
$stderrBytes = $null
$stdoutText = $null
$stderrText = $null
$stdoutHash = $null
$stderrHash = $null
$validatorReads = 0
$parsedReports = 0
$saveStates = [Collections.Generic.List[object]]::new()
$process = $null
$outTask = $null
$errTask = $null
$watch = [Diagnostics.Stopwatch]::StartNew()

function First-Failure([string] $where, [string] $tag) {
    if ($null -eq $script:firstPhase) {
        $script:firstPhase = $where
        $script:firstTag = $tag
    }
}
function Require([bool] $condition, [string] $tag) {
    if (-not $condition) { throw $tag }
}
function Register-Resource($object, [string] $name) {
    $entry = [pscustomobject]@{Object=$object;Name=$name;Disposed=$false}
    $script:resources.Add($entry)
    return $entry
}
function Dispose-Resource($entry) {
    if ($null -eq $entry -or $entry.Disposed) { return }
    $entry.Disposed = $true
    try { $entry.Object.Dispose() }
    catch {
        $tag = $entry.Name + '/DISPOSE_FAILURE'
        $script:secondary.Add($tag)
        First-Failure 'RESOURCE_DISPOSE' $tag
    }
}
function Directory-Chain([IO.DirectoryInfo] $directory) {
    Require ($null -ne $directory) 'DIRECTORY_MISSING'
    $cursor = $directory
    while ($null -ne $cursor) {
        Require ($cursor -is [IO.DirectoryInfo]) 'DIRECTORY_TYPE'
        Require (($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) 'DIRECTORY_REPARSE'
        $cursor = $cursor.Parent
    }
}
function Ordinary-File([string] $path, [long] $size) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    Require ($item -is [IO.FileInfo]) 'FILE_TYPE'
    Require (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) 'FILE_REPARSE'
    Directory-Chain $item.Directory
    if ($size -ge 0) { Require ($item.Length -eq $size) 'FILE_SIZE' }
}
function Hash-Bytes([byte[]] $bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    $entry = Register-Resource $sha 'SHA256'
    try { return [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '') }
    finally { Dispose-Resource $entry }
}
function Object-Schema($element, [string[]] $names) {
    Require ($element.ValueKind -eq [Text.Json.JsonValueKind]::Object) 'JSON_OBJECT'
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $count = 0
    foreach ($property in $element.EnumerateObject()) {
        Require ($names -ccontains $property.Name) 'JSON_EXTRA_FIELD'
        Require ($seen.Add($property.Name)) 'JSON_DUPLICATE_FIELD'
        $count++
    }
    Require ($count -eq $names.Length) 'JSON_MISSING_FIELD'
}
function String-Field($element, [string] $name, [string] $expected) {
    $value = $element.GetProperty($name)
    Require ($value.ValueKind -eq [Text.Json.JsonValueKind]::String) 'JSON_STRING_TYPE'
    Require ([string]::Equals($value.GetString(), $expected, [StringComparison]::Ordinal)) 'JSON_STRING_VALUE'
}
function Number-Field($element, [string] $name, [int] $expected) {
    $value = $element.GetProperty($name)
    Require ($value.ValueKind -eq [Text.Json.JsonValueKind]::Number) 'JSON_NUMBER_TYPE'
    $actual = 0
    Require ($value.TryGetInt32([ref] $actual)) 'JSON_INTEGER'
    Require ($actual -eq $expected) 'JSON_COUNT'
}
function Stop-OnlyChild {
    if ($script:started -eq 1 -and -not $script:exited -and $script:killAttempt -eq 0) {
        $script:killAttempt++
        try {
            $script:process.Kill($true)
            $script:killReturned = $true
        }
        catch { First-Failure 'CHILD_CLEANUP' 'KILL_FAILURE' }
        $script:cleanupWaitAttempt++
        try { $script:exited = $script:process.WaitForExit(5000) }
        catch { First-Failure 'CHILD_CLEANUP' 'EXIT_OBSERVATION_FAILURE' }
    }
}
function Save-Stream([string] $path, [byte[]] $bytes, [string] $label) {
    $state = [ordered]@{Stream=$label;CreateNewAttempt=0;Created=0;OutputMayExist=$false;WriteState='NOT_ATTEMPTED';DisposeAttempt=0;Saved=0}
    $script:saveStates.Add($state)
    $entry = $null
    try {
        $script:phase = $label + '_CREATE_NEW'
        $state.CreateNewAttempt++
        $state.OutputMayExist = $true
        $state.WriteState = 'CREATE_NEW_OUTCOME_UNKNOWN'
        $file = [IO.FileStream]::new($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
        $state.Created++
        $state.WriteState = 'CREATED_POSSIBLE_PARTIAL'
        $entry = Register-Resource $file ($label + '_FILE')
        $script:phase = $label + '_WRITE'
        $file.Write($bytes, 0, $bytes.Length)
        $state.WriteState = 'WRITE_RETURNED_NOT_FLUSHED'
        $script:phase = $label + '_FLUSH'
        $file.Flush($true)
        $state.WriteState = 'FLUSHED_NOT_DISPOSED'
    }
    catch { First-Failure $script:phase 'RECEIPT_SAVE_FAILURE' }
    finally {
        if ($null -ne $entry) {
            $state.DisposeAttempt++
            Dispose-Resource $entry
            if ($null -eq $script:firstPhase) {
                $state.WriteState = 'FLUSHED_DISPOSED'
                $state.Saved = 1
            }
        }
    }
    Require ($null -eq $script:firstPhase) 'RECEIPT_SAVE_STOP'
}
function Wrapper-Report {
    return [ordered]@{
        Result=$(if ($null -eq $script:firstPhase) {'PASS'} else {'FAIL'})
        Phase=$(if ($null -eq $script:firstPhase) {'COMPLETE'} else {$script:firstPhase})
        FailureTag=$script:firstTag
        SecondaryDisposeFailure=$script:secondary.ToArray()
        StartAttemptCount=$script:attempt;StartedCount=$script:started
        Exited=$script:exited
        Termination=$(if ($script:exited) {'EXIT_OBSERVED'} elseif ($script:started -eq 0) {'NOT_STARTED'} else {'UNKNOWN'})
        ChildExitCode=$script:exitCode
        WaitAttempt=$script:waitAttempt;WaitLimitMs=30000
        TimedOut=$script:timedOut;KillAttempt=$script:killAttempt;KillReturned=$script:killReturned
        CleanupWaitAttempt=$script:cleanupWaitAttempt;CleanupWaitLimitMs=5000
        StreamJoinAttempt=$script:joinAttempt;StreamJoinLimitMs=5000
        TimeoutKillPath=$(if ($script:timedOut) {'TIMEOUT_OBSERVED'} else {'NOT_EXERCISED'})
        AbsoluteHardDeadline='NOT_PROVEN';OSIsolation='NOT_PROVEN'
        ObservedMs=$script:watch.ElapsedMilliseconds
        IndependentStreams=$true
        StdoutCopyStarted=$script:stdoutCopyStarted;StderrCopyStarted=$script:stderrCopyStarted
        StdoutComplete=$script:stdoutComplete;StderrComplete=$script:stderrComplete
        StdoutUTF8Bytes=$(if ($null -eq $script:stdoutBytes) {$null} else {$script:stdoutBytes.Length})
        StderrUTF8Bytes=$(if ($null -eq $script:stderrBytes) {$null} else {$script:stderrBytes.Length})
        StdoutSHA256=$script:stdoutHash;StderrSHA256=$script:stderrHash
        Stdout=$script:stdoutText;Stderr=$script:stderrText
        StdoutReceiptPath=$script:stdoutPath;StderrReceiptPath=$script:stderrPath
        ReceiptStates=$script:saveStates.ToArray()
        ValidatorIdentityReads=$script:validatorReads;LauncherJSONParses=$script:parsedReports
    }
}
try {
    $phase = 'NO_ARGUMENTS'
    Require ($args.Count -eq 0) 'ARGUMENTS_FORBIDDEN'
    Require ([string]::Equals((Get-Location).Path, $root, [StringComparison]::Ordinal)) 'CWD'
    $phase = 'FILE_GATES'
    Ordinary-File $python -1
    Ordinary-File $validator 11574
    Ordinary-File $candidate 9600
    $validatorReads++
    $validatorBytes = [IO.File]::ReadAllBytes($validator)
    Require ($validatorBytes.Length -eq 11574) 'VALIDATOR_SIZE'
    Require ((Hash-Bytes $validatorBytes) -ceq '6F9292CD30BB47E5472A01E272C7B769940FA64C1332ECC0F254F64B494F743C') 'VALIDATOR_HASH'
    Require ($null -eq $firstPhase) 'HASH_RESOURCE_FAILURE'
    $phase = 'OUTPUT_GATES'
    $directory = Get-Item -LiteralPath $outputDir -Force -ErrorAction Stop
    Require ($directory -is [IO.DirectoryInfo]) 'OUTPUT_DIRECTORY_TYPE'
    Directory-Chain $directory
    Require (-not (Test-Path -LiteralPath $stdoutPath -ErrorAction Stop)) 'STDOUT_EXISTS'
    Require (-not (Test-Path -LiteralPath $stderrPath -ErrorAction Stop)) 'STDERR_EXISTS'

    $phase = 'PROCESS_START'
    $info = [Diagnostics.ProcessStartInfo]::new()
    $info.FileName = $python
    $info.WorkingDirectory = $root
    $info.UseShellExecute = $false
    $info.CreateNoWindow = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    foreach ($argument in @('-I', '-B', $validator, '--static')) { $info.ArgumentList.Add($argument) }
    $process = [Diagnostics.Process]::new()
    $null = Register-Resource $process 'PROCESS'
    $process.StartInfo = $info
    $attempt++
    Require ($process.Start()) 'START_FALSE'
    $started++
    $phase = 'STREAM_COPY_START'
    $outMemory = [IO.MemoryStream]::new()
    $null = Register-Resource $outMemory 'STDOUT_MEMORY'
    $errMemory = [IO.MemoryStream]::new()
    $null = Register-Resource $errMemory 'STDERR_MEMORY'
    $outTask = $process.StandardOutput.BaseStream.CopyToAsync($outMemory)
    $stdoutCopyStarted = $true
    $errTask = $process.StandardError.BaseStream.CopyToAsync($errMemory)
    $stderrCopyStarted = $true
    $phase = 'CHILD_WAIT'
    $waitAttempt++
    $exited = $process.WaitForExit(30000)
    if (-not $exited) {
        $timedOut = $true
        First-Failure $phase 'CHILD_TIMEOUT'
        Stop-OnlyChild
        throw 'CHILD_TIMEOUT'
    }
    $exitCode = $process.ExitCode
    $phase = 'STREAM_JOIN'
    $joinAttempt++
    $joined = [Threading.Tasks.Task]::WaitAll([Threading.Tasks.Task[]]@($outTask, $errTask), 5000)
    $stdoutComplete = $outTask.IsCompletedSuccessfully
    $stderrComplete = $errTask.IsCompletedSuccessfully
    Require ($joined -and $stdoutComplete -and $stderrComplete) 'STREAM_INCOMPLETE'
    $stdoutBytes = $outMemory.ToArray()
    $stderrBytes = $errMemory.ToArray()
    $phase = 'STREAM_LIMIT_UTF8'
    Require ($stdoutBytes.Length -le 4096 -and $stderrBytes.Length -le 4096 -and
        $stdoutBytes.Length + $stderrBytes.Length -le 8192) 'STREAM_LIMIT'
    $stdoutText = $utf.GetString($stdoutBytes)
    $stderrText = $utf.GetString($stderrBytes)
    $stdoutHash = Hash-Bytes $stdoutBytes
    $stderrHash = Hash-Bytes $stderrBytes
    Require ($null -eq $firstPhase) 'HASH_RESOURCE_FAILURE'
    $phase = 'STATIC_JSON_SCHEMA'
    Require ($exitCode -eq 0) 'CHILD_EXIT'
    Require ($stderrBytes.Length -eq 0) 'STDERR_NONEMPTY'
    $parsedReports++
    # JsonDocument requires consumption of the entire input; no extra JSON/trailing data.
    $document = [Text.Json.JsonDocument]::Parse([string] $stdoutText)
    $null = Register-Resource $document 'JSON_DOCUMENT'
    $element = $document.RootElement
    Object-Schema $element @('Mode','Phase','Result','Counts','Cases','InternalScopeAnchorScratchPaths','SDKCompatibility')
    String-Field $element 'Mode' 'STATIC'
    String-Field $element 'Phase' 'COMPLETE'
    String-Field $element 'Result' 'PASS'
    String-Field $element 'InternalScopeAnchorScratchPaths' 'NOT_CHECKED'
    String-Field $element 'SDKCompatibility' 'NOT_CHECKED'
    $cases = $element.GetProperty('Cases')
    Require ($cases.ValueKind -eq [Text.Json.JsonValueKind]::Array -and $cases.GetArrayLength() -eq 0) 'CASES'
    $ones = @('SourceReads','SourceCompletedReads','Parses','CompletedParses')
    $zeros = @('FixtureReads','FixtureCompletedReads','ExpectedReads','ExpectedCompletedReads','Compiles','CompletedCompiles','CandidateImport','CandidateModuleLoad','CompletedCandidateModuleLoad','CandidateInvocation')
    $counts = $element.GetProperty('Counts')
    Object-Schema $counts ($ones + $zeros)
    foreach ($name in $ones) { Number-Field $counts $name 1 }
    foreach ($name in $zeros) { Number-Field $counts $name 0 }
    $phase = 'WRAPPER_PRESAVE_LIMIT'
    $preview = ConvertTo-Json -InputObject (Wrapper-Report) -Depth 8 -Compress
    # Reserve 1024 bytes/characters for the two bounded receipt states and final timing.
    Require ($utf.GetByteCount($preview) -le 11264 -and $preview.Length -le 16976) 'WRAPPER_LIMIT'
    # Immediately recheck original directory chain and both paths before CreateNew.
    $directory.Refresh()
    Require ($directory.Exists) 'OUTPUT_DIRECTORY_GONE'
    Directory-Chain $directory
    Require (-not (Test-Path -LiteralPath $stdoutPath -ErrorAction Stop) -and
        -not (Test-Path -LiteralPath $stderrPath -ErrorAction Stop)) 'RECEIPT_EXISTS'
    Save-Stream $stdoutPath $stdoutBytes 'STDOUT'
    Save-Stream $stderrPath $stderrBytes 'STDERR'
}
catch {
    $reason = [string] $_.Exception.Message
    $tag = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}$') { $reason } else {'UNEXPECTED_EXCEPTION'}
    First-Failure $phase $tag
}
finally {
    # Only this child may be cleaned up. At most one kill and one cleanup wait.
    Stop-OnlyChild
    if ($null -ne $outTask) { $stdoutComplete = $outTask.IsCompletedSuccessfully }
    if ($null -ne $errTask) { $stderrComplete = $errTask.IsCompletedSuccessfully }
    for ($i = $resources.Count - 1; $i -ge 0; $i--) { Dispose-Resource $resources[$i] }
    $watch.Stop()
}
$report = Wrapper-Report
$reportText = ConvertTo-Json -InputObject $report -Depth 8 -Compress
if ($utf.GetByteCount($reportText) -gt 12288 -or $reportText.Length -gt 18000) {
    First-Failure 'WRAPPER_EMIT_LIMIT' 'WRAPPER_LIMIT'
    $report = Wrapper-Report
    $report.Remove('Stdout')
    $report.Remove('Stderr')
    $report.Result = 'FAIL'
    $report.StreamBodiesOmitted = 'OUTPUT_LIMIT'
    $reportText = ConvertTo-Json -InputObject $report -Depth 8 -Compress
}
[Console]::Out.Write($reportText)
if ($null -eq $firstPhase) { exit 0 } else { exit 1 }
