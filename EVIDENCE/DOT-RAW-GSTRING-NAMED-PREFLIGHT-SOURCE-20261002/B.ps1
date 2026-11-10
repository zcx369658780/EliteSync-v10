$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-NAMED-PREFLIGHT-SOURCE-20261002'
$utf=[Text.UTF8Encoding]::new($false,$true)
function HashBytes([byte[]]$b){
    $h=[Security.Cryptography.SHA256]::Create()
    try{[BitConverter]::ToString($h.ComputeHash($b)).Replace('-','')}finally{$h.Dispose()}
}
$raw=@{};$facts=@{}
foreach($name in @('stdout.bin','stderr.bin','probe-wrapper.json')){
    $f=Get-Item -LiteralPath ($base+'\'+$name)
    if($f-isnot[IO.FileInfo]-or$f.Length-gt8192-or($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'B_METADATA'}
    [byte[]]$b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne$f.Length-or$b.Length-gt8192){throw 'B_SIZE'}
    $raw[$name]=$b
    $facts[$name]=[ordered]@{Bytes=$b.Length;SHA256=(HashBytes $b);BodyReads=1}
}
$w=$utf.GetString($raw['probe-wrapper.json'])|ConvertFrom-Json -AsHashtable
if($w.mode-cne'SINGLE_JVM_RAW_GSTRING_DIAGNOSTIC_RECEIPT'-or$w.Result-cne'DIAGNOSTIC_CAPTURE_COMPLETE'-or
   $w.Root-cne$base-or$w.RuntimeReady-isnot[bool]-or$w.RuntimeReady-or
   $w.DiagnosticSchemaChecked-isnot[bool]-or-not$w.DiagnosticSchemaChecked-or
   $w.CaptureComplete-isnot[bool]-or-not$w.CaptureComplete-or
   $w.StdoutComplete-isnot[bool]-or-not$w.StdoutComplete-or
   $w.StderrComplete-isnot[bool]-or-not$w.StderrComplete-or
   $w.CleanupComplete-isnot[bool]-or-not$w.CleanupComplete-or
   $w.Timeout-isnot[bool]-or$w.Timeout-or$w.KillAttempt-ne0-or$w.ExitCode-ne0-or
   $w.Started-isnot[bool]-or-not$w.Started-or$w.Exited-isnot[bool]-or-not$w.Exited-or
   $w.ProcessStartAttempt-ne1-or$w.CandidateInvocationAttempt-ne1-or
   $w.CandidateSourceRead-ne1-or$w.CandidateParseClassLoad-ne1-or$w.FourteenCaseInvocation-ne0-or
   $w.ExternalGet-ne189-or$w.ExternalRead-ne189-or$w.ExternalBytes-ne115118021-or
   $w.TSVRead-ne1-or$w.HarnessSourceRead-ne1-or$w.HarnessCopies-ne1-or$w.LocalInstallerPreflightRead-ne1-or
   $null-ne$w.Failure-or$w.SecondaryFailure.Count-ne0){throw 'B_WRAPPER_SCOPE'}
if($w.StdoutBytes-ne$facts['stdout.bin'].Bytes-or$w.StdoutSHA256-cne$facts['stdout.bin'].SHA256-or
   $w.StderrBytes-ne$facts['stderr.bin'].Bytes-or$w.StderrSHA256-cne$facts['stderr.bin'].SHA256-or
   $facts['stderr.bin'].Bytes-ne0){throw 'B_STREAM_IDENTITY'}
$j=$utf.GetString($raw['stdout.bin'])|ConvertFrom-Json -AsHashtable
if($j.mode-cne'DIAGNOSTIC_ONLY'-or$j.caseId-cne'RAW_GSTRING_PATH'-or
   $j.observationComplete-isnot[bool]-or-not$j.observationComplete-or$j.runtimeReady-isnot[bool]-or$j.runtimeReady-or
   $j.sourceReadAttempt-ne1-or$j.parseClassLoadAttempt-ne1-or$j.candidateInvocationAttempt-ne1-or
   $j.invokeOutcome-cne$w.InvokeOutcome){throw 'B_CHILD_SCOPE'}
if($j.invokeOutcome-ceq'DIRECT_INVOKE_EXCEPTION'){
    if($w.CandidateInvocation-isnot[string]-or$w.CandidateInvocation-cne'UNKNOWN'){throw 'B_DIRECT_COUNT'}
}elseif($w.CandidateInvocation-ne1){throw 'B_CANDIDATE_COUNT'}
$head=git rev-parse HEAD
if($LASTEXITCODE-ne0-or$head-cne'9ac66fc5566cd1fa5da23ed797cb6a08606e01d5'){throw 'B_HEAD'}
[ordered]@{Result='B_DISK_IDENTITIES_VERIFIED';HEAD=$head;Facts=$facts;Wrapper=$w;Diagnostic=$j;OriginalToolReceiptComparison='PENDING_SAME_CALLER_CACHE'}|ConvertTo-Json -Depth 8 -Compress
