# Pure receipt validation and bounded in-memory process capture.
# Importing this file defines functions only; it does not start a process.

function New-Auth123Failure {
    param([string]$Reason, [object]$ExitCode = 'UNKNOWN')
    $safeExit = if (($ExitCode -is [int] -or $ExitCode -is [long]) -and $ExitCode -in @(0, 1)) { [int]$ExitCode } else { 'UNKNOWN' }
    return [ordered]@{
        receiver_status = 'REJECTED'
        reason = $Reason
        stage = 'UNKNOWN'
        category = 'UNKNOWN'
        checked_entries = 'UNKNOWN'
        prior_target_candidate = 'UNKNOWN'
        port = 'UNKNOWN'
        host_key_trust = 'UNKNOWN'
        exit_code = $safeExit
    }
}

function Convert-Auth123Receipt {
    param(
        [AllowNull()][object]$Stdout,
        [AllowNull()][object]$Stderr,
        [AllowNull()][object]$ProcessExit,
        [bool]$StdoutComplete = $true,
        [bool]$StderrComplete = $true,
        [bool]$TimedOut = $false,
        [bool]$Overflow = $false
    )
    if ($TimedOut) { return New-Auth123Failure 'TIMEOUT' $ProcessExit }
    if ($Overflow) { return New-Auth123Failure 'STREAM_LIMIT' $ProcessExit }
    if (-not $StdoutComplete -or -not $StderrComplete) { return New-Auth123Failure 'INCOMPLETE_STREAM' $ProcessExit }
    if ($Stdout -isnot [string] -or $Stderr -isnot [string]) { return New-Auth123Failure 'INVALID_CAPTURE' $ProcessExit }
    try {
        $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
        if ($utf8.GetByteCount($Stdout) -gt 2048 -or $utf8.GetByteCount($Stderr) -gt 2048) {
            return New-Auth123Failure 'STREAM_LIMIT' $ProcessExit
        }
    } catch { return New-Auth123Failure 'INVALID_ENCODING' $ProcessExit }
    if ($Stderr.Length -ne 0) { return New-Auth123Failure 'STDERR_NONEMPTY' $ProcessExit }
    if ($ProcessExit -isnot [int] -and $ProcessExit -isnot [long]) {
        return New-Auth123Failure 'EXIT_UNKNOWN' $ProcessExit
    }
    if ($ProcessExit -notin @(0, 1)) { return New-Auth123Failure 'EXIT_UNEXPECTED' $ProcessExit }
    if ($Stdout.Length -lt 2 -or [int]$Stdout[$Stdout.Length - 1] -ne 10 -or [int]$Stdout[0] -eq 0xFEFF) {
        return New-Auth123Failure 'FRAME_INVALID' $ProcessExit
    }
    $jsonLength = $Stdout.Length - 1
    if ($jsonLength -gt 0 -and [int]$Stdout[$jsonLength - 1] -eq 13) { $jsonLength-- }
    if ($jsonLength -lt 2) { return New-Auth123Failure 'FRAME_INVALID' $ProcessExit }
    for ($index = 0; $index -lt $jsonLength; $index++) {
        if ([int]$Stdout[$index] -in @(10, 13)) { return New-Auth123Failure 'FRAME_INVALID' $ProcessExit }
    }
    $doc = $null
    try {
        $doc = [System.Text.Json.JsonDocument]::Parse($Stdout.Substring(0, $jsonLength))
        $root = $doc.RootElement
        if ($root.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) {
            return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit
        }
        $names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
        $props = [System.Collections.Generic.Dictionary[string,System.Text.Json.JsonElement]]::new([System.StringComparer]::Ordinal)
        foreach ($property in $root.EnumerateObject()) {
            if (-not $names.Add($property.Name)) { return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit }
            $props.Add($property.Name, $property.Value)
        }
        $required = @('stage','category','checked_entries','prior_target_candidate','port','host_key_trust')
        if ($names.Count -ne 6) { return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit }
        foreach ($name in $required) {
            if (-not $names.Contains($name)) { return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit }
        }
        foreach ($name in @('stage','category','prior_target_candidate','port','host_key_trust')) {
            if ($props[$name].ValueKind -ne [System.Text.Json.JsonValueKind]::String) {
                return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit
            }
        }
        if ($props['checked_entries'].ValueKind -ne [System.Text.Json.JsonValueKind]::Number) {
            return New-Auth123Failure 'COUNT_INVALID' $ProcessExit
        }
        $rawCount = $props['checked_entries'].GetRawText()
        if ($rawCount -cnotmatch '^(0|[1-9][0-9]*)$') { return New-Auth123Failure 'COUNT_INVALID' $ProcessExit }
        $count = [long]::Parse($rawCount, [System.Globalization.CultureInfo]::InvariantCulture)
        if ($count -gt 256) { return New-Auth123Failure 'COUNT_INVALID' $ProcessExit }
        $stage = $props['stage'].GetString()
        $category = $props['category'].GetString()
        $prior = $props['prior_target_candidate'].GetString()
        if ($props['port'].GetString() -cne 'UNKNOWN' -or $props['host_key_trust'].GetString() -cne 'UNKNOWN') {
            return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit
        }
        if ($prior -cnotin @('NO','YES_CANDIDATE')) { return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit }
        $formatStages = @('INPUT_NUL','INPUT_CR','LINE_ENCODING','LINE_WHITESPACE','FIELD_COUNT','HOST_FIELD','KEY_BASE64')
        $failureStages = @('SOURCE_RESULT_MISMATCH','DIAG_INCONSISTENT','ENTRY_FAILED','AUTH121_DEPENDENCY_FAILED','DIAGNOSTIC_DEPENDENCY_FAILED','AUTH120_DEPENDENCY_FAILED','TARGET_READ_FAILED','ARGS_UNSUPPORTED')
        if ($category -ceq 'FORMAT_INVALID') {
            if ($ProcessExit -ne 0 -or $stage -cnotin $formatStages) {
                return New-Auth123Failure 'EXIT_OR_SCHEMA_CONTRADICTION' $ProcessExit
            }
        } elseif ($category -ceq 'DIAGNOSTIC_FAILED') {
            if ($ProcessExit -ne 1 -or $stage -cnotin $failureStages -or $count -ne 0 -or $prior -cne 'NO') {
                return New-Auth123Failure 'EXIT_OR_SCHEMA_CONTRADICTION' $ProcessExit
            }
        } else { return New-Auth123Failure 'SCHEMA_INVALID' $ProcessExit }
        return [ordered]@{
            receiver_status = 'ACCEPTED_CANDIDATE'
            reason = 'NONE'
            stage = $stage
            category = $category
            checked_entries = [int]$count
            prior_target_candidate = $prior
            port = 'UNKNOWN'
            host_key_trust = 'UNKNOWN'
            exit_code = [int]$ProcessExit
        }
    } catch { return New-Auth123Failure 'OUTPUT_INVALID' $ProcessExit }
    finally { if ($null -ne $doc) { $doc.Dispose() } }
}

function Stop-Auth123ProcessTree {
    param([System.Diagnostics.Process]$Process)
    try {
        if (-not $Process.HasExited) {
            try { $Process.Kill($true) }
            catch {
                if (-not $Process.HasExited) { return $false }
            }
        }
        return ($Process.WaitForExit(2000) -and $Process.HasExited)
    } catch { return $false }
}

function Invoke-Auth123BoundedProcess {
    param([string]$Executable, [string[]]$Arguments, [int]$TimeoutMs = 15000)
    $process = [System.Diagnostics.Process]::new()
    $started = $false
    try {
        $start = [System.Diagnostics.ProcessStartInfo]::new()
        $start.FileName = $Executable
        foreach ($arg in $Arguments) { $start.ArgumentList.Add($arg) }
        $start.UseShellExecute = $false
        $start.CreateNoWindow = $true
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        $process.StartInfo = $start
        if (-not $process.Start()) { return @{ status='LAUNCH_FAILED'; stdout=''; stderr=''; exit='UNKNOWN' } }
        $started = $true
        $processId = $process.Id
        $outBuffer = [char[]]::new(256)
        $errBuffer = [char[]]::new(256)
        $outText = [System.Text.StringBuilder]::new()
        $errText = [System.Text.StringBuilder]::new()
        $outTask = $process.StandardOutput.ReadAsync($outBuffer, 0, $outBuffer.Length)
        $errTask = $process.StandardError.ReadAsync($errBuffer, 0, $errBuffer.Length)
        $outDone = $false
        $errDone = $false
        $timer = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not $outDone -or -not $errDone) {
            if ($timer.ElapsedMilliseconds -gt $TimeoutMs) {
                $stopped = Stop-Auth123ProcessTree $process
                $status = if ($stopped) { 'TIMEOUT' } else { 'TERMINATION_FAILED' }
                return @{ status=$status; stdout=''; stderr=''; exit='UNKNOWN'; pid=$processId; reaped=$stopped }
            }
            if (-not $outDone -and $outTask.IsCompleted) {
                $n = $outTask.GetAwaiter().GetResult()
                if ($n -eq 0) { $outDone = $true }
                else {
                    [void]$outText.Append($outBuffer, 0, $n)
                    if ($outText.Length -gt 2048) {
                        $stopped = Stop-Auth123ProcessTree $process
                        $status = if ($stopped) { 'STREAM_LIMIT' } else { 'TERMINATION_FAILED' }
                        return @{ status=$status; stdout=''; stderr=''; exit='UNKNOWN'; pid=$processId; reaped=$stopped }
                    }
                    $outTask = $process.StandardOutput.ReadAsync($outBuffer, 0, $outBuffer.Length)
                }
            }
            if (-not $errDone -and $errTask.IsCompleted) {
                $n = $errTask.GetAwaiter().GetResult()
                if ($n -eq 0) { $errDone = $true }
                else {
                    [void]$errText.Append($errBuffer, 0, $n)
                    if ($errText.Length -gt 2048) {
                        $stopped = Stop-Auth123ProcessTree $process
                        $status = if ($stopped) { 'STREAM_LIMIT' } else { 'TERMINATION_FAILED' }
                        return @{ status=$status; stdout=''; stderr=''; exit='UNKNOWN'; pid=$processId; reaped=$stopped }
                    }
                    $errTask = $process.StandardError.ReadAsync($errBuffer, 0, $errBuffer.Length)
                }
            }
            if (-not $outDone -or -not $errDone) { [void][System.Threading.Tasks.Task]::WaitAny(@($outTask, $errTask), 20) }
        }
        if (-not $process.WaitForExit(2000)) {
            $stopped = Stop-Auth123ProcessTree $process
            $status = if ($stopped) { 'TIMEOUT' } else { 'TERMINATION_FAILED' }
            return @{ status=$status; stdout=''; stderr=''; exit='UNKNOWN'; pid=$processId; reaped=$stopped }
        }
        return @{ status='COMPLETE'; stdout=$outText.ToString(); stderr=$errText.ToString(); exit=$process.ExitCode }
    } catch {
        if ($started) {
            $stopped = Stop-Auth123ProcessTree $process
            $status = if ($stopped) { 'CAPTURE_FAILED' } else { 'TERMINATION_FAILED' }
            return @{ status=$status; stdout=''; stderr=''; exit='UNKNOWN'; pid=$processId; reaped=$stopped }
        }
        return @{ status='LAUNCH_FAILED'; stdout=''; stderr=''; exit='UNKNOWN' }
    } finally { $process.Dispose() }
}
