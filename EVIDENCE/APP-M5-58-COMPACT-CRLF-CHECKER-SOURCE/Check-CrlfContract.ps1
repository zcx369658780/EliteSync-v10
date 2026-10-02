# APP-M5-58 source-only candidate; execution requires a separate issued task.
# Fixed document data checker. No SDK, fixture, transform, or output-file access.
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = 'D:\EliteSync-v10'
$utf8 = [Text.UTF8Encoding]::new($false, $true)
$lf = [string][char]10
$cr = [string][char]13
$fence = ([string][char]96) * 3
$checks = [Collections.Generic.List[object]]::new()
$identities = [Collections.Generic.List[object]]::new()
$reads = 0
$failureTag = 'INTERNAL_EXCEPTION'
$specs = @(
    [pscustomobject]@{ Path='EVIDENCE/APP-M5-55-LOCAL-CRLF-MATERIALS-CONTRACT/crlf-contract.md'; Bytes=14300; SHA256='214F7D4232DE8A8A71CF71353968466ECFD2E55B74D85792A7026BD8B3E2A051' },
    [pscustomobject]@{ Path='EVIDENCE/APP-M5-54-RAW-ANCHOR-SCOPE-MAP/anchor-map.md'; Bytes=5879; SHA256='CC1DA4B0484DC29E5BA2DE0DC4765337629394D327D8775869883533E9CE4774' },
    [pscustomobject]@{ Path='EVIDENCE/APP-M5-49-SCOPED-KOTLIN-PATCH-MATERIALS/patch-materials.md'; Bytes=13818; SHA256='B783379A7FC307B8750F73758261BEBCF739CDFA72A234B80148D96F4AD9DA49' }
)
function Fail([string]$tag) {
    $script:failureTag = $tag
    throw 'FIXED_CHECK_FAILURE'
}
function Check([string]$name, [bool]$ok) {
    if ($script:checks.Count -ge 64) { Fail 'CHECK_COUNT_LIMIT' }
    if (-not $ok) { Fail $name }
    $script:checks.Add([pscustomobject]@{ Name=$name; Result='PASS' })
}
function RequireFields($obj, [string[]]$names, [string]$tag) {
    if ($null -eq $obj -or $obj -isnot [pscustomobject]) { Fail $tag }
    foreach ($name in $names) {
        if ($null -eq $obj.PSObject.Properties[$name]) { Fail $tag }
    }
}
function SameBytes([string]$a, [string]$b) {
    if ($a -cne $b) { return $false }
    $ab = $script:utf8.GetBytes($a)
    $bb = $script:utf8.GetBytes($b)
    if ($ab.Length -ne $bb.Length) { return $false }
    for ($i=0; $i -lt $ab.Length; $i++) {
        if ($ab[$i] -ne $bb[$i]) { return $false }
    }
    return $true
}
# Explicit flat metadata comparison, including arrays of scalar line/scope values.
# No recursive tree traversal, no field-order dependence, no executable evaluation.
function SameValue($a, $b) {
    if ($null -eq $a -or $null -eq $b) { return ($null -eq $a -and $null -eq $b) }
    if ($a -is [array] -or $b -is [array]) {
        if ($a -isnot [array] -or $b -isnot [array] -or $a.Count -ne $b.Count) { return $false }
        for ($i=0; $i -lt $a.Count; $i++) {
            if ($a[$i] -is [pscustomobject] -or $b[$i] -is [pscustomobject] -or
                $a[$i] -is [array] -or $b[$i] -is [array]) { return $false }
            if (($a[$i] -is [string]) -ne ($b[$i] -is [string])) { return $false }
            if ($a[$i] -cne $b[$i]) { return $false }
        }
        return $true
    }
    if ($a -is [pscustomobject] -or $b -is [pscustomobject]) { return $false }
    if (($a -is [string]) -ne ($b -is [string])) { return $false }
    return ($a -ceq $b)
}
function SameFlatObject($a, $b) {
    if ($a -isnot [pscustomobject] -or $b -isnot [pscustomobject]) { return $false }
    $ap = @($a.PSObject.Properties)
    $bp = @($b.PSObject.Properties)
    if ($ap.Count -ne $bp.Count) { return $false }
    foreach ($p in $ap) {
        $q = $b.PSObject.Properties[$p.Name]
        if ($null -eq $q -or -not (SameValue $p.Value $q.Value)) { return $false }
    }
    return $true
}
function FixedIndex($items, [string[]]$expected, [string]$tag) {
    if ($items -isnot [array] -or $items.Count -ne $expected.Count) { Fail $tag }
    $index = [Collections.Generic.Dictionary[string,object]]::new([StringComparer]::Ordinal)
    foreach ($item in $items) {
        RequireFields $item @('Id') $tag
        if ($item.Id -isnot [string] -or $item.Id -cnotin $expected -or $index.ContainsKey($item.Id)) { Fail $tag }
        $index.Add($item.Id, $item)
    }
    foreach ($id in $expected) { if (-not $index.ContainsKey($id)) { Fail $tag } }
    return ,$index
}
function JsonDocument([string]$text, [string]$tag) {
    $open = $script:fence + 'json' + $script:lf
    $start = $text.IndexOf($open, [StringComparison]::Ordinal)
    if ($start -lt 0 -or $text.IndexOf($open, $start+$open.Length, [StringComparison]::Ordinal) -ge 0) { Fail ($tag+'_FENCE') }
    $close = $script:lf + $script:fence + $script:lf
    $end = $text.IndexOf($close, $start+$open.Length, [StringComparison]::Ordinal)
    if ($end -lt 0) { Fail ($tag+'_CLOSE') }
    $script:failureTag = $tag+'_JSON'
    $obj = $text.Substring($start+$open.Length, $end-$start-$open.Length) | ConvertFrom-Json
    $script:failureTag = 'INTERNAL_EXCEPTION'
    return $obj
}
function KotlinLiteral([string]$text, [string]$id) {
    $open = $script:fence + 'kotlin id=' + $id + $script:lf
    $start = $text.IndexOf($open, [StringComparison]::Ordinal)
    if ($start -lt 0 -or $text.IndexOf($open, $start+$open.Length, [StringComparison]::Ordinal) -ge 0) { Fail ($id+'_FENCE') }
    $body = $start+$open.Length
    $close = $script:fence + $script:lf
    $end = $text.IndexOf($close, $body, [StringComparison]::Ordinal)
    if ($end -le $body -or $text.Substring($end-1,1) -cne $script:lf) { Fail ($id+'_CLOSE_LF') }
    $value = $text.Substring($body, $end-$body)
    if ($value.Contains($script:cr)) { Fail ($id+'_LOCAL_CR') }
    return $value
}
try {
    Check 'NO_ARGUMENTS' ($args.Count -eq 0)
    $texts = [Collections.Generic.List[string]]::new()
    for ($si=0; $si -lt $specs.Count; $si++) {
        $spec = $specs[$si]
        $failureTag = 'SOURCE'+($si+1)+'_ORDINARY'
        $item = Get-Item -LiteralPath (Join-Path $root $spec.Path)
        if ($item.PSIsContainer) { Fail $failureTag }
        $ancestor = $item
        while ($null -ne $ancestor) {
            if (($ancestor.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { Fail $failureTag }
            if ($ancestor -is [IO.FileInfo]) { $ancestor=$ancestor.Directory } else { $ancestor=$ancestor.Parent }
        }
        $failureTag = 'SOURCE'+($si+1)+'_READ'
        $bytes = [IO.File]::ReadAllBytes($item.FullName)
        $reads++
        $failureTag = 'SOURCE'+($si+1)+'_IDENTITY'
        $hash = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
        Check $failureTag ($bytes.Length -eq $spec.Bytes -and $hash -ceq $spec.SHA256)
        $failureTag = 'SOURCE'+($si+1)+'_UTF8'
        $texts.Add($utf8.GetString($bytes))
        $identities.Add([pscustomobject]@{ Path=$spec.Path; Bytes=$bytes.Length; SHA256=$hash })
        $failureTag = 'INTERNAL_EXCEPTION'
    }
    $contract = JsonDocument $texts[0] 'CONTRACT'
    $map = JsonDocument $texts[1] 'MAP'
    RequireFields $contract @('Phase','Result','Sources','Anchors','Literals','Declarations','TotalReplacementDelta','ProspectiveFullOutputBytes','Budget') 'CONTRACT_FIELDS'
    RequireFields $map @('Phase','Result','Source','Spans','Budget') 'MAP_FIELDS'
    Check 'ROOT_PHASE_RESULT' ($contract.Phase -ceq 'A' -and $map.Phase -ceq 'A' -and $contract.Result -ceq 'PASS' -and $map.Result -ceq 'PASS')
    Check 'SAVED_BUDGETS' ($contract.Budget -ceq 'A1/1 closed; B0/1 at save' -and $map.Budget -ceq 'A1/1 closed; B0/1 at save')
    # These exact schema requirements are intentionally fail closed.
    RequireFields $map.Source @('Bytes','SHA256','CRLF') 'MAP_SOURCE_FIELDS'
    Check 'ACCEPTED_FIXTURE_REFERENCE' ($map.Source.Bytes -eq 42405 -and $map.Source.SHA256 -ceq '1EEB49A1E17859B150E8ED5109C9AF0932FAFACB06810D2A02BC688A69387313' -and $map.Source.CRLF -eq 821)
    if ($contract.Sources -isnot [array] -or $contract.Sources.Count -ne 2) { Fail 'SOURCE_REFERENCE_COUNT' }
    foreach ($spec in $specs[1..2]) {
        $matches = @($contract.Sources | Where-Object { $_.Path -ceq $spec.Path })
        if ($matches.Count -ne 1) { Fail 'SOURCE_REFERENCE_ID' }
        RequireFields $matches[0] @('Path','Bytes','SHA256') 'SOURCE_REFERENCE_FIELDS'
        Check ('REFERENCE_'+[IO.Path]::GetFileNameWithoutExtension($spec.Path)) ($matches[0].Bytes -eq $spec.Bytes -and $matches[0].SHA256 -ceq $spec.SHA256)
    }
    $groups = @('helper-member','apply-preflight','repository-consumer','tasks-consumer')
    $beforeIds = @('helper-member-before','preflight-before','repository-consumer-before','tasks-consumer-before')
    $literalIds = @()
    foreach ($group in $groups) { $literalIds += ($group+'-before'),($group+'-after') }
    $literalIndex = FixedIndex $contract.Literals $literalIds 'LITERAL_IDS'
    $anchorIndex = FixedIndex $contract.Anchors $groups 'ANCHOR_IDS'
    if ($map.Spans -isnot [array] -or $map.Spans.Count -ne 7 -or $contract.Declarations -isnot [array] -or $contract.Declarations.Count -ne 3) { Fail 'SPAN_DECLARATION_COUNT' }
    $declarationIds = @($contract.Declarations | ForEach-Object { $_.Id })
    $declarationIndex = FixedIndex $contract.Declarations $declarationIds 'DECLARATION_IDS'
    $spanIndex = FixedIndex $map.Spans ($beforeIds+$declarationIds) 'SPAN_IDS'
    Check 'EXPLICIT_ID_COUNTS' ($literalIndex.Count -eq 8 -and $anchorIndex.Count -eq 4 -and $spanIndex.Count -eq 7 -and $declarationIndex.Count -eq 3)
    $computed = @{}
    foreach ($id in $literalIds) {
        $literal = $literalIndex[$id]
        RequireFields $literal @('Raw','LFBytes','LFCount','RawCRLFBytes','CRLFCount','MappingDelta') ($id+'_FIELDS')
        if ($literal.Raw -isnot [string]) { Fail ($id+'_RAW_TYPE') }
        $local = KotlinLiteral $texts[2] $id
        $raw = $local.Replace($lf,$cr+$lf)
        $lb = $utf8.GetByteCount($local)
        $rb = $utf8.GetByteCount($raw)
        $count = $local.Split([char]10).Count-1
        $ok = (SameBytes $literal.Raw $raw) -and $literal.LFBytes -eq $lb -and
            $literal.LFCount -eq $count -and $literal.RawCRLFBytes -eq $rb -and
            $literal.CRLFCount -eq $count -and $literal.MappingDelta -eq ($rb-$lb)
        Check ($id+'_RAW_LENGTH_COUNTS') $ok
        $computed[$id] = [pscustomobject]@{ Raw=$raw; Bytes=$rb }
    }
    $expectedDeltas = @(2237,37,56,1172)
    $deltas = @()
    $previousEnd = -1
    for ($i=0; $i -lt 4; $i++) {
        $group = $groups[$i]
        $anchor = $anchorIndex[$group]
        $span = $spanIndex[$beforeIds[$i]]
        RequireFields $anchor @('Lines','Start','End','BeforeBytes','AcceptedWholeFileOverlapCount','ScopeReference','ReplacementDelta') ($group+'_ANCHOR_FIELDS')
        RequireFields $span @('Raw','Lines','Start','End','WholeFileOverlapCount','ScopeReference') ($group+'_SPAN_FIELDS')
        $before = $computed[$group+'-before']
        $after = $computed[$group+'-after']
        $rangeOk = $span.Start -is [long] -or $span.Start -is [int]
        $rangeOk = $rangeOk -and ($span.End -is [long] -or $span.End -is [int])
        $rangeOk = $rangeOk -and $span.Start -ge 0 -and $span.End -gt $span.Start -and $span.End -le 42405 -and $span.Start -ge $previousEnd
        $metadataOk = (SameBytes $span.Raw $before.Raw) -and
            (SameValue $anchor.Lines $span.Lines) -and $anchor.Start -eq $span.Start -and
            $anchor.End -eq $span.End -and $anchor.BeforeBytes -eq $before.Bytes -and
            ($span.End-$span.Start) -eq $before.Bytes -and
            $anchor.AcceptedWholeFileOverlapCount -eq $span.WholeFileOverlapCount -and
            $span.WholeFileOverlapCount -eq 1 -and
            (SameValue $anchor.ScopeReference $span.ScopeReference)
        Check ($group+'_RAW_RANGE_SCOPE') ($rangeOk -and $metadataOk)
        $previousEnd = $span.End
        $delta = $after.Bytes-$before.Bytes
        Check ($group+'_REPLACEMENT_DELTA') ($delta -eq $expectedDeltas[$i] -and $anchor.ReplacementDelta -eq $delta)
        $deltas += $delta
    }
    # Declarations compare every stored flat field, including full Raw, by Id.
    foreach ($id in $declarationIds) {
        $declaration = $declarationIndex[$id]
        $span = $spanIndex[$id]
        RequireFields $declaration @('Id','Raw','Lines','Start','End') 'DECLARATION_REQUIRED_FIELDS'
        RequireFields $span @('Id','Raw','Lines','Start','End') 'DECLARATION_MAP_FIELDS'
        Check ($id+'_FULL_DECLARATION') (SameFlatObject $declaration $span)
    }
    $total = ($deltas | Measure-Object -Sum).Sum
    $prospective = 42405+$total
    Check 'STORED_TOTAL_AND_SIZE' ($total -eq 3502 -and $prospective -eq 45907 -and $contract.TotalReplacementDelta -eq $total -and $contract.ProspectiveFullOutputBytes -eq $prospective)
    $report = [ordered]@{
        Phase='A'; Result='PASS'; Sources=$identities; Checks=$checks
        LiteralCount=8; AnchorCount=4; DeclarationCount=3
        ReplacementDeltas=$deltas; TotalReplacementDelta=$total
        ProspectiveFullOutputBytes=$prospective; ScopeProof='exact line context only'
        Reads=$reads; Execution=0; FixtureSDKM550Reads=0
        Budget='This invocation only; M5-55 A/B remain closed'
    }
    $failureTag = 'OUTPUT_SERIALIZE'
    $output = $report | ConvertTo-Json -Depth 8 -Compress
    $failureTag = 'OUTPUT_LIMIT'
    if ($utf8.GetByteCount($output)+2 -gt 4096) { Fail 'OUTPUT_LIMIT' }
    [Console]::Write($output+([string][char]13)+([string][char]10))
    exit 0
} catch {
    # No exception text, source text, or partial success table is printed.
    $failure = [ordered]@{
        Phase='A'; Result='FAIL'; FailureTag=$failureTag; Reads=$reads
        Execution=0; FixtureSDKM550Reads=0; Budget='Failed invocation closed'
    }
    $output = $failure | ConvertTo-Json -Compress
    if ($utf8.GetByteCount($output)+2 -gt 4096) {
        $output = '{"Phase":"A","Result":"FAIL","FailureTag":"FAILURE_OUTPUT_LIMIT","Execution":0}'
    }
    [Console]::Write($output+([string][char]13)+([string][char]10))
    exit 1
}
