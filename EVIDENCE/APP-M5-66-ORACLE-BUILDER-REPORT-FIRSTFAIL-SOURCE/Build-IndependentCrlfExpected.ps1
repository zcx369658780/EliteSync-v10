# SOURCE-ONLY M5-65. Execution requires a separate issued task and budget.
# Fixed independent oracle: original offsets, never a candidate/scratch transform.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = 'D:\EliteSync-v10'
$fixtureRel = 'EVIDENCE/APP-M5-52-RAW-NEWLINE-SOURCE-FIXTURE/flutter_plugin_original.bin'
$contractRel = 'EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md'
$outputRel = 'EVIDENCE/APP-M5-67-FROZEN-INDEPENDENT-EXPECTED-ONCE/flutter_plugin_expected.bin'
$fixtureHash = '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313'
$contractHash = '214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051'
$utf = [Text.UTF8Encoding]::new($false, $true)
$tag = 'INITIALIZATION'
$reads = 0
$completedReads = 0
$constructionCount = 0
$createNewAttempted = $false
$created = $false
$outputMayExist = $false
$writeState = 'NOT_ATTEMPTED'
$firstFailurePhase = ''
$firstFailureTag = ''
$disposeFailureTag = ''
$disposeState = 'NOT_ATTEMPTED'

function Require([bool] $condition, [string] $failureTag) {
    if (-not $condition) { throw $failureTag }
}

function Assert-DirectoryChain([IO.DirectoryInfo] $directory) {
    Require ($null -ne $directory) 'DIRECTORY_MISSING'
    $cursor = $directory
    while ($null -ne $cursor) {
        Require ($cursor -is [IO.DirectoryInfo]) 'DIRECTORY_TYPE'
        Require (($cursor.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) 'DIRECTORY_REPARSE'
        $cursor = $cursor.Parent
    }
}

function Assert-OrdinaryFile([string] $path, [long] $size) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
    Require ($item -is [IO.FileInfo]) 'FILE_TYPE'
    Require (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) 'FILE_REPARSE'
    Assert-DirectoryChain $item.Directory
    Require ($item.Length -eq $size) 'FILE_SIZE'
}

function Hash-Bytes([byte[]] $bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return [BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-', '') }
    finally { $sha.Dispose() }
}

function Require-Number($value, [long] $expected, [string] $failureTag) {
    Require (($value -is [int] -or $value -is [long]) -and $value -eq $expected) $failureTag
}

function Require-String($value, [string] $expected, [string] $failureTag) {
    Require ($value -is [string]) $failureTag
    Require ([string]::Equals($value, $expected, [StringComparison]::Ordinal)) $failureTag
}

function Get-UniqueById([object[]] $items, [string] $id) {
    $matches = @($items | Where-Object { $_.ID -is [string] -and [string]::Equals($_.ID, $id, [StringComparison]::Ordinal) })
    Require ($matches.Count -eq 1) 'SCHEMA_UNIQUE_ID'
    return $matches[0]
}

function Require-Slice([byte[]] $source, [int] $start, [int] $end, [byte[]] $literal) {
    Require ($start -ge 0 -and $end -ge $start -and $end -le $source.Length) 'SLICE_BOUNDS'
    Require (($end - $start) -eq $literal.Length) 'SLICE_LENGTH'
    for ($i = 0; $i -lt $literal.Length; $i++) {
        Require ($source[$start + $i] -eq $literal[$i]) 'SLICE_BYTES'
    }
}

function Count-Overlapping([byte[]] $source, [byte[]] $literal) {
    Require ($literal.Length -gt 0 -and $literal.Length -le $source.Length) 'PATTERN_LENGTH'
    $count = 0
    for ($start = 0; $start -le $source.Length - $literal.Length; $start++) {
        $equal = $true
        for ($i = 0; $i -lt $literal.Length; $i++) {
            if ($source[$start + $i] -ne $literal[$i]) { $equal = $false; break }
        }
        if ($equal) { $count++ }
    }
    return $count
}

try {
    $tag = 'NO_ARGUMENTS'
    Require ($args.Count -eq 0) 'ARGUMENTS_FORBIDDEN'
    $tag = 'SOURCE_FILE_GATES'
    $fixturePath = Join-Path $root $fixtureRel
    $contractPath = Join-Path $root $contractRel
    Assert-OrdinaryFile $fixturePath 42405
    Assert-OrdinaryFile $contractPath 14300
    $tag = 'FIXTURE_READ'
    $reads++
    $original = [IO.File]::ReadAllBytes($fixturePath)
    $completedReads++
    $tag = 'FIXTURE_IDENTITY'
    Require ($original.Length -eq 42405) 'FIXTURE_SIZE'
    Require ((Hash-Bytes $original) -ceq $fixtureHash) 'FIXTURE_HASH'
    $tag = 'CONTRACT_READ'
    $reads++
    $contractBytes = [IO.File]::ReadAllBytes($contractPath)
    $completedReads++
    $tag = 'CONTRACT_IDENTITY_UTF8'
    Require ($contractBytes.Length -eq 14300) 'CONTRACT_SIZE'
    Require ((Hash-Bytes $contractBytes) -ceq $contractHash) 'CONTRACT_HASH'
    $contractText = $utf.GetString($contractBytes)

    $tag = 'CONTRACT_JSON_DATA'
    $open = '```json' + "`n"
    $close = "`n" + '```'
    $start = $contractText.IndexOf($open, [StringComparison]::Ordinal)
    Require ($start -ge 0) 'JSON_OPEN'
    Require ($contractText.IndexOf($open, $start + $open.Length, [StringComparison]::Ordinal) -eq -1) 'JSON_OPEN_UNIQUE'
    $bodyStart = $start + $open.Length
    $end = $contractText.IndexOf($close, $bodyStart, [StringComparison]::Ordinal)
    Require ($end -gt $bodyStart) 'JSON_CLOSE'
    Require ($contractText.IndexOf($close, $end + $close.Length, [StringComparison]::Ordinal) -eq -1) 'JSON_CLOSE_UNIQUE'
    $data = ConvertFrom-Json -InputObject $contractText.Substring($bodyStart, $end - $bodyStart) -ErrorAction Stop

    $tag = 'ORIGINAL_ROOT_SCHEMA'
    Require-Number $data.OriginalFixtureBytes 42405 'ROOT_BYTES'
    Require-String $data.OriginalFixtureSHA256 $fixtureHash 'ROOT_HASH'
    Require-Number $data.OriginalCRLF 821 'ROOT_CRLF'
    Require-Number $data.OriginalBareLF 0 'ROOT_BARE_LF'
    Require-Number $data.OriginalBareCR 0 'ROOT_BARE_CR'
    Require ($data.OriginalBOM -is [bool] -and -not $data.OriginalBOM) 'ROOT_BOM'
    Require-Number $data.OriginalFinalByte 10 'ROOT_FINAL_BYTE'
    Require (@($data.Literals).Count -eq 8) 'LITERALS_COUNT'
    Require (@($data.Anchors).Count -eq 4) 'ANCHORS_COUNT'
    Require (@($data.Declarations).Count -eq 3) 'DECLARATIONS_COUNT'

    $tag = 'ORIGINAL_NEWLINES'
    $crlf = 0
    $bareLF = 0
    $bareCR = 0
    $lineStarts = [Collections.Generic.List[int]]::new()
    $lineStarts.Add(0)
    for ($i = 0; $i -lt $original.Length; $i++) {
        if ($original[$i] -eq 13) {
            if ($i + 1 -lt $original.Length -and $original[$i + 1] -eq 10) { $crlf++ }
            else { $bareCR++ }
        }
        if ($original[$i] -eq 10) {
            if ($i -eq 0 -or $original[$i - 1] -ne 13) { $bareLF++ }
            $lineStarts.Add($i + 1)
        }
    }
    Require ($crlf -eq 821 -and $bareLF -eq 0 -and $bareCR -eq 0) 'FIXTURE_NEWLINES'
    Require (-not ($original[0] -eq 239 -and $original[1] -eq 187 -and $original[2] -eq 191)) 'FIXTURE_BOM'
    Require ($original[$original.Length - 1] -eq 10) 'FIXTURE_FINAL_BYTE'

    # Every literal comes from the independently frozen document, not a transform.
    $tag = 'EIGHT_LITERAL_SCHEMA'
    $literalSpecs = @(
        @('helper-member-before', 100, 3, 97),
        @('helper-member-after', 2337, 46, 2291),
        @('apply-preflight-before', 32, 1, 31),
        @('apply-preflight-after', 69, 2, 67),
        @('repository-consumer-before', 602, 14, 588),
        @('repository-consumer-after', 658, 16, 642),
        @('tasks-consumer-before', 128, 4, 124),
        @('tasks-consumer-after', 1300, 25, 1275)
    )
    $literalBytes = @{}
    foreach ($spec in $literalSpecs) {
        $entry = Get-UniqueById @($data.Literals) $spec[0]
        Require ($entry.Raw -is [string]) 'LITERAL_RAW_TYPE'
        Require-Number $entry.RawCRLFBytes $spec[1] 'LITERAL_BYTES_FIELD'
        Require-Number $entry.CRLFCount $spec[2] 'LITERAL_CRLF_FIELD'
        Require-Number $entry.LFBytes $spec[3] 'LITERAL_LF_BYTES_FIELD'
        Require-Number $entry.LFCount $spec[2] 'LITERAL_LF_COUNT_FIELD'
        Require-Number $entry.MappingDelta $spec[2] 'LITERAL_MAPPING_FIELD'
        $bytes = $utf.GetBytes($entry.Raw)
        Require ($bytes.Length -eq $spec[1]) 'LITERAL_BYTES'
        $pairs = 0
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            if ($bytes[$i] -eq 13) {
                Require ($i + 1 -lt $bytes.Length -and $bytes[$i + 1] -eq 10) 'LITERAL_BARE_CR'
                $pairs++
            }
            if ($bytes[$i] -eq 10) {
                Require ($i -gt 0 -and $bytes[$i - 1] -eq 13) 'LITERAL_BARE_LF'
            }
        }
        Require ($pairs -eq $spec[2] -and $bytes[$bytes.Length - 1] -eq 10) 'LITERAL_NEWLINES'
        Require ($bytes.Length - $pairs -eq $spec[3]) 'LITERAL_MAPPING_LENGTH'
        $literalBytes.Add($spec[0], $bytes)
    }

    $tag = 'THREE_DECLARATIONS'
    $declarationSpecs = @(
        @('class', 34, 1327, 1368, "class FlutterPlugin : Plugin<Project> {`r`n"),
        @('apply', 46, 1849, 1893, "    override fun apply(project: Project) {`r`n"),
        @('addFlutterTasks', 349, 16485, 16550, "    private fun addFlutterTasks(projectToAddTasksTo: Project) {`r`n")
    )
    $declarations = @{}
    foreach ($spec in $declarationSpecs) {
        $entry = Get-UniqueById @($data.Declarations) $spec[0]
        Require (@($entry.Lines).Count -eq 2) 'DECLARATION_LINES'
        Require-Number $entry.Lines[0] $spec[1] 'DECLARATION_LINE_START'
        Require-Number $entry.Lines[1] $spec[1] 'DECLARATION_LINE_END'
        Require-Number $entry.Start $spec[2] 'DECLARATION_START'
        Require-Number $entry.End $spec[3] 'DECLARATION_END'
        Require-Number $entry.Bytes ($spec[3] - $spec[2]) 'DECLARATION_BYTES'
        Require-Number $entry.CRLF 1 'DECLARATION_CRLF'
        Require-Number $entry.WholeFileOverlapCount 1 'DECLARATION_COUNT_FIELD'
        Require-String $entry.Raw $spec[4] 'DECLARATION_RAW'
        $bytes = $utf.GetBytes($spec[4])
        Require-Slice $original $spec[2] $spec[3] $bytes
        Require ($lineStarts[$spec[1] - 1] -eq $spec[2] -and $lineStarts[$spec[1]] -eq $spec[3]) 'DECLARATION_LINE_BYTE'
        Require ((Count-Overlapping $original $bytes) -eq 1) 'DECLARATION_OVERLAP_UNIQUE'
        $declarations.Add($spec[0], $entry)
    }

    $tag = 'FOUR_ANCHORS_SCOPES'
    $anchorSpecs = @(
        @('helper-member', 44, 46, 1793, 1893, 100, 2337, 2237, 'class34/apply46 boundary'),
        @('apply-preflight', 47, 47, 1893, 1925, 32, 69, 37, 'after apply46 before addFlutterTasks349'),
        @('repository-consumer', 88, 101, 3530, 4132, 602, 658, 56, 'after apply46 before addFlutterTasks349'),
        @('tasks-consumer', 453, 456, 22417, 22545, 128, 1300, 1172, 'after addFlutterTasks349')
    )
    $delta = 0
    $priorEnd = 0
    $anchors = @{}
    foreach ($spec in $anchorSpecs) {
        $entry = Get-UniqueById @($data.Anchors) $spec[0]
        Require (@($entry.Lines).Count -eq 2) 'ANCHOR_LINES'
        Require-Number $entry.Lines[0] $spec[1] 'ANCHOR_LINE_START'
        Require-Number $entry.Lines[1] $spec[2] 'ANCHOR_LINE_END'
        Require-Number $entry.Start $spec[3] 'ANCHOR_START'
        Require-Number $entry.End $spec[4] 'ANCHOR_END'
        Require-Number $entry.BeforeBytes $spec[5] 'ANCHOR_BYTES'
        Require-Number $entry.ReplacementDelta $spec[7] 'ANCHOR_DELTA'
        Require-Number $entry.AcceptedWholeFileOverlapCount 1 'ANCHOR_COUNT_FIELD'
        Require ($entry.RawBeforeEqualsAcceptedMap -is [bool] -and $entry.RawBeforeEqualsAcceptedMap) 'ANCHOR_MAP_EQUAL'
        Require-String $entry.ScopeReference $spec[8] 'ANCHOR_SCOPE'
        $before = [byte[]] $literalBytes[$spec[0] + '-before']
        $after = [byte[]] $literalBytes[$spec[0] + '-after']
        Require-Slice $original $spec[3] $spec[4] $before
        Require ((Count-Overlapping $original $before) -eq 1) 'ANCHOR_OVERLAP_UNIQUE'
        Require ($lineStarts[$spec[1] - 1] -eq $spec[3] -and $lineStarts[$spec[2]] -eq $spec[4]) 'ANCHOR_LINE_BYTE'
        Require ($spec[3] -ge $priorEnd -and $spec[4] -gt $spec[3]) 'ANCHOR_ORDER'
        Require ($after.Length - $before.Length -eq $spec[7]) 'ANCHOR_DELTA_BYTES'
        $priorEnd = $spec[4]
        $delta += $spec[7]
        $anchors.Add($spec[0], $entry)
    }
    # Fixed original declarations delimit these line-context scopes; this is not AST proof.
    Require ($declarations['class'].End -le $anchors['helper-member'].Start -and
        $declarations['apply'].Start -ge $anchors['helper-member'].Start -and
        $declarations['apply'].End -eq $anchors['helper-member'].End) 'HELPER_SCOPE'
    Require ($anchors['apply-preflight'].Start -eq $declarations['apply'].End -and
        $anchors['apply-preflight'].End -lt $declarations['addFlutterTasks'].Start) 'PREFLIGHT_SCOPE'
    Require ($anchors['repository-consumer'].Start -gt $declarations['apply'].End -and
        $anchors['repository-consumer'].End -lt $declarations['addFlutterTasks'].Start) 'REPOSITORY_SCOPE'
    Require ($anchors['tasks-consumer'].Start -gt $declarations['addFlutterTasks'].End) 'TASKS_SCOPE'
    Require ($delta -eq 3502 -and 42405 + $delta -eq 45907) 'TOTAL_DELTA_BYTES'
    Require-Number $data.TotalReplacementDelta 3502 'TOTAL_DELTA_FIELD'
    Require-Number $data.ProspectiveFullOutputBytes 45907 'OUTPUT_SIZE_FIELD'

    $tag = 'OUTPUT_PARENT_PRECHECK'
    $outputPath = Join-Path $root $outputRel
    $outputParent = Get-Item -LiteralPath ([IO.Path]::GetDirectoryName($outputPath)) -Force -ErrorAction Stop
    Require ($outputParent -is [IO.DirectoryInfo]) 'OUTPUT_PARENT_TYPE'
    Assert-DirectoryChain $outputParent
    Require (-not (Test-Path -LiteralPath $outputPath -ErrorAction Stop)) 'OUTPUT_ALREADY_EXISTS'

    $tag = 'NINE_FIXED_SEGMENTS_CONSTRUCTION'
    $constructionCount++
    $segments = [Collections.Generic.List[object]]::new()
    $stream = [IO.MemoryStream]::new(45907)
    try {
        # Five original spans and four document-derived replacements, in fixed order.
        $spans = @(@(0,1793), @(1893,1893), @(1925,3530), @(4132,22417), @(22545,42405))
        for ($i = 0; $i -lt 5; $i++) {
            $os = $spans[$i][0]
            $oe = $spans[$i][1]
            $outStart = [int] $stream.Position
            $stream.Write($original, $os, $oe - $os)
            $segments.Add([ordered]@{ID=('keep' + $i);Kind='original';OriginalStart=$os;OriginalEnd=$oe;OutputStart=$outStart;OutputEnd=[int]$stream.Position;Bytes=($oe-$os);Equal=$true})
            if ($i -lt 4) {
                $spec = $anchorSpecs[$i]
                $replacement = [byte[]] $literalBytes[$spec[0] + '-after']
                $outStart = [int] $stream.Position
                $stream.Write($replacement, 0, $replacement.Length)
                $segments.Add([ordered]@{ID=$spec[0];Kind='replacement';OriginalStart=$spec[3];OriginalEnd=$spec[4];OutputStart=$outStart;OutputEnd=[int]$stream.Position;Bytes=$replacement.Length})
            }
        }
        $expected = $stream.ToArray()
    }
    finally { $stream.Dispose() }
    Require ($expected.Length -eq 45907 -and $segments.Count -eq 9) 'CONSTRUCTION_SIZE'
    $tag = 'FIVE_RETAINED_SEGMENTS_BYTE_CHECK'
    foreach ($segment in $segments) {
        if ($segment.Kind -eq 'original') {
            for ($i = 0; $i -lt $segment.Bytes; $i++) {
                Require ($expected[$segment.OutputStart + $i] -eq $original[$segment.OriginalStart + $i]) 'RETAINED_BYTE_MISMATCH'
            }
        }
    }

    $tag = 'REPORT_BEFORE_SAVE'
    $expectedHash = Hash-Bytes $expected
    $report = [ordered]@{
        Phase='INDEPENDENT_EXPECTED';Result='PASS'
        Inputs=@(
            [ordered]@{Path=$fixtureRel;Bytes=42405;SHA256=$fixtureHash},
            [ordered]@{Path=$contractRel;Bytes=14300;SHA256=$contractHash}
        )
        Reads=$reads;CompletedReads=$completedReads
        OriginalCRLF=$crlf;OriginalBareLF=$bareLF;OriginalBareCR=$bareCR
        OriginalBOM=($original[0] -eq 239 -and $original[1] -eq 187 -and $original[2] -eq 191)
        OriginalFinalByte=$original[$original.Length - 1]
        Expected=[ordered]@{Path=$outputRel;Bytes=45907;SHA256=$expectedHash}
        Segments=$segments.ToArray();Deltas=@(2237,37,56,1172);TotalDelta=3502;OutputBytes=45907
        AllRetainedSegmentsEqual=$true;CandidateReads=0;CandidateInvocation=0;SDKReads=0
        ConstructionCount=$constructionCount;CreateNewAttempted=$true;CreateNew=$true;WriteState='FLUSHED_DISPOSED'
        DisposeState='COMPLETED';DisposeFailureTag=''
    }
    $reportText = (ConvertTo-Json -InputObject $report -Depth 8 -Compress) + "`r`n"
    Require ($utf.GetByteCount($reportText) -le 4096) 'SUCCESS_REPORT_LIMIT'
    # Recheck the existing parent chain and absence immediately before CreateNew.
    $tag = 'OUTPUT_FINAL_PRECHECK'
    $outputParent.Refresh()
    Require ($outputParent.Exists) 'OUTPUT_PARENT_GONE'
    Assert-DirectoryChain $outputParent
    Require (-not (Test-Path -LiteralPath $outputPath -ErrorAction Stop)) 'OUTPUT_ALREADY_EXISTS'
    $tag = 'CREATE_NEW'
    $createNewAttempted = $true
    $outputMayExist = $true
    $writeState = 'CREATE_NEW_OUTCOME_UNKNOWN'
    $file = [IO.FileStream]::new($outputPath, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    $created = $true
    $writeState = 'CREATED_POSSIBLE_PARTIAL'
    try {
        $tag = 'WRITE_EXPECTED'
        $file.Write($expected, 0, $expected.Length)
        $writeState = 'WRITE_RETURNED_NOT_FLUSHED'
        $tag = 'FLUSH_EXPECTED'
        $file.Flush($true)
        $writeState = 'FLUSHED_NOT_DISPOSED'
    }
    catch {
        $firstFailurePhase = $tag
        $reason = [string] $_.Exception.Message
        $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}
    $tag = 'SUCCESS_REPORT_EMIT'
    [Console]::Out.Write($reportText)
    exit 0
}
catch {
    # Keep the first Write/Flush/Dispose failure; secondary Dispose is separate.
    if ($firstFailurePhase -eq '') {
        $firstFailurePhase = $tag
        $reason = [string] $_.Exception.Message
        $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}
    $failure = [ordered]@{
        Phase=$firstFailurePhase;Result='FAIL';FailureTag=$firstFailureTag
        DisposeState=$disposeState;DisposeFailureTag=$disposeFailureTag
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$firstFailurePhase;Result='FAIL';FailureTag=$firstFailureTag;DisposeState=$disposeState;DisposeFailureTag=$disposeFailureTag;Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState;ReportLimitExceeded=$true}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
) { $reason } else { 'UNEXPECTED_EXCEPTION' }
        $firstFailureTag = $firstFailurePhase + '/' + $detail
    }
    # Dispose is attempted once; a second failure cannot replace Write/Flush.
    $tag = 'DISPOSE_EXPECTED'
    $disposeState = 'ATTEMPTED_OUTCOME_UNKNOWN'
    try {
        $file.Dispose()
        $disposeState = 'COMPLETED'
    }
    catch {
        $disposeState = 'FAILED'
        $reason = [string] $_.Exception.Message
        $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}
    $tag = 'SUCCESS_REPORT_EMIT'
    [Console]::Out.Write($reportText)
    exit 0
}
catch {
    # Stage survives unexpected exceptions. Fixed explicit throw tags add detail.
    $reason = [string] $_.Exception.Message
    $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}$') { $reason } else { 'UNEXPECTED_EXCEPTION' }
    $failure = [ordered]@{
        Phase=$tag;Result='FAIL';FailureTag=($tag + '/' + $detail)
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$tag;Result='FAIL';FailureTag='FAILURE_REPORT_LIMIT';Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
) { $reason } else { 'UNEXPECTED_EXCEPTION' }
        $disposeFailureTag = 'DISPOSE_EXPECTED/' + $detail
        if ($firstFailurePhase -eq '') {
            $firstFailurePhase = 'DISPOSE_EXPECTED'
            $firstFailureTag = $disposeFailureTag
        }
    }
    if ($firstFailurePhase -ne '') {
        $tag = $firstFailurePhase
        throw 'RECORDED_IO_FAILURE'
    }
    $writeState = 'FLUSHED_DISPOSED'
    $tag = 'SUCCESS_REPORT_EMIT'
    [Console]::Out.Write($reportText)
    exit 0
}
catch {
    # Stage survives unexpected exceptions. Fixed explicit throw tags add detail.
    $reason = [string] $_.Exception.Message
    $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}$') { $reason } else { 'UNEXPECTED_EXCEPTION' }
    $failure = [ordered]@{
        Phase=$tag;Result='FAIL';FailureTag=($tag + '/' + $detail)
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$tag;Result='FAIL';FailureTag='FAILURE_REPORT_LIMIT';Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
) { $reason } else { 'UNEXPECTED_EXCEPTION' }
        $firstFailureTag = $firstFailurePhase + '/' + $detail
    }
    $failure = [ordered]@{
        Phase=$tag;Result='FAIL';FailureTag=($tag + '/' + $detail)
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$tag;Result='FAIL';FailureTag='FAILURE_REPORT_LIMIT';Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
) { $reason } else { 'UNEXPECTED_EXCEPTION' }
        $firstFailureTag = $firstFailurePhase + '/' + $detail
    }
    # Dispose is attempted once; a second failure cannot replace Write/Flush.
    $tag = 'DISPOSE_EXPECTED'
    $disposeState = 'ATTEMPTED_OUTCOME_UNKNOWN'
    try {
        $file.Dispose()
        $disposeState = 'COMPLETED'
    }
    catch {
        $disposeState = 'FAILED'
        $reason = [string] $_.Exception.Message
        $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}
    $tag = 'SUCCESS_REPORT_EMIT'
    [Console]::Out.Write($reportText)
    exit 0
}
catch {
    # Stage survives unexpected exceptions. Fixed explicit throw tags add detail.
    $reason = [string] $_.Exception.Message
    $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}$') { $reason } else { 'UNEXPECTED_EXCEPTION' }
    $failure = [ordered]@{
        Phase=$tag;Result='FAIL';FailureTag=($tag + '/' + $detail)
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$tag;Result='FAIL';FailureTag='FAILURE_REPORT_LIMIT';Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
) { $reason } else { 'UNEXPECTED_EXCEPTION' }
        $disposeFailureTag = 'DISPOSE_EXPECTED/' + $detail
        if ($firstFailurePhase -eq '') {
            $firstFailurePhase = 'DISPOSE_EXPECTED'
            $firstFailureTag = $disposeFailureTag
        }
    }
    if ($firstFailurePhase -ne '') {
        $tag = $firstFailurePhase
        throw 'RECORDED_IO_FAILURE'
    }
    $writeState = 'FLUSHED_DISPOSED'
    $tag = 'SUCCESS_REPORT_EMIT'
    [Console]::Out.Write($reportText)
    exit 0
}
catch {
    # Stage survives unexpected exceptions. Fixed explicit throw tags add detail.
    $reason = [string] $_.Exception.Message
    $detail = if ($reason -cmatch '^[A-Z][A-Z0-9_]{1,63}$') { $reason } else { 'UNEXPECTED_EXCEPTION' }
    $failure = [ordered]@{
        Phase=$tag;Result='FAIL';FailureTag=($tag + '/' + $detail)
        Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount
        CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState
        CandidateReads=0;CandidateInvocation=0;SDKReads=0
    }
    $failureText = (ConvertTo-Json -InputObject $failure -Depth 4 -Compress) + "`r`n"
    # Fixed bounded fields; never print exception, fixture, contract or expected text.
    if ($utf.GetByteCount($failureText) -gt 4096) {
        $minimal = [ordered]@{Phase=$tag;Result='FAIL';FailureTag='FAILURE_REPORT_LIMIT';Reads=$reads;CompletedReads=$completedReads;ConstructionCount=$constructionCount;CreateNewAttempted=$createNewAttempted;CreateNew=$created;OutputMayExist=$outputMayExist;WriteState=$writeState}
        [Console]::Out.Write((ConvertTo-Json -InputObject $minimal -Compress) + "`r`n")
    }
    else { [Console]::Out.Write($failureText) }
    exit 1
}
