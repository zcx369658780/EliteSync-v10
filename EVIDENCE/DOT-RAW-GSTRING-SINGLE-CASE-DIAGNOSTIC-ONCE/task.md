# DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE
Status: REJECT_CLOSED_A_METADATA / stop / no successor.
A executed once and native exit1 A_METADATA. Invocation0 / B0 / FailureDisclosure0 / JVMStart0. Remaining budgets closed. Actual per-file A read counts were not emitted; no claim of body-read0. Sources and fixed commands unchanged; no correction or retry. Original preparation failure remains CLOSED; administrative correction1/1 remains spent.
Owner delegated ordinary bounded tests; parent dot issued this exact new scope.
Base HEAD: 71fa57f8c734bf4ea2597b4bf453515ef3c37461 / main / D:\EliteSync-v10.
14-key authority has no HEAD key; HEAD binding is the reviewed launcher literal plus workspace-before.json and this task. Do not add a fifteenth key or change reviewed source.

Sources, immutable:
- DiagnoseRawGString.groovy: 9812 bytes / 0FDF72979FE6C6C174CAFDB8A8B7975AFA86D6F22743DD0520BAAE87EC4368EB.
- Invoke-RawGStringDiagnostic.ps1: 26073 bytes / A10012BF520B5A3F928A46D8E1240636F094A663330F13BEE53F162C284F0048.
- Original M84 installer: 6141 bytes / 7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37.
No changes to M112, old receipts, installer or 22 frozen items; two old bins body0.
No candidate PASS, real binding, Android project/device, Gradle build, protected data, install/download, security change, push or successor.

Preparation:
Create authority, this task, native-receipts.json and placeholder workspace-before.json before the final complete --untracked-files=all snapshot. Native receipt updates reuse the existing path. No file/path may be added after A except the exact Invocation outputs below.
Receipt saving is administrative evidence persistence, not another A/Invocation/B or budget reset. No authority/source patch or retry is allowed after a failure.

New budgets:
A <=1, local GetItem/body-read1 each of exactly harness, launcher, M84 installer, M90 TSV, new authority and snapshot; no external bytes/JVM. Launcher local A size cap32768 covers26073.
Invocation <=1, authority/snapshot/TSV/harness each local GetItem/body-read1; parent installer preflight GetItem/body-read1; exact188 TSV jars plus Java =189 external GetItem/ReadAllBytes1 each, sum115118021 bytes, no enumeration. Harness owned copy1; implicit PowerShell reading of the invoked launcher and GroovyMain loading of owned harness1 are separate from identity/preflight reads. Groovy/JVM implicit classloading is NOT_MEASURED and is not claimed to be limited to189 reads.
Child installer sourceReadAttempt<=1 / parseClassLoadAttempt<=1 / candidateInvocationAttempt<=1. Thus installer A1 + parent preflight1 + child1 are separate allowances, not totalRead1.
JVM ProcessStartAttempt<=1, 30s child/2s cleanup, KillAttempt<=1 if needed, stdout/stderr8192 bytes each, child JSON4096, wrapper8192, small receipt4096. No OS hard cutoff or filesystem/network isolation claim.
B <=1 only after native exit0, complete diagnostic receipt. Exactly stdout/stderr/wrapper GetItem/body-read1 each; same-caller cache check against original Invocation native output makes no file reads.
FailureDisclosure <=1 instead of B after Invocation failure: TestPath on three exact raw paths, GetItem/body-read1 only if actually present, no fabricated missing artifacts. If A fails, stop without Invocation/B/disclosure. If B is requested, FailureDisclosure budget is closed; a B/cache failure uses original in-memory evidence only.
Every failure closes remaining budget, preserves partial and stops. No retries or new case/call, including no comparison invocation. DIRECT_INVOKE_EXCEPTION is a catch-channel observation, not proof of exception origin. A GString array element plus normal return does not prove method-entry type or installer defect.

Allowed Invocation creations only in this task root:
invocation-started.json; cwd/harness.groovy; tmp, user-home, appdata, localappdata, gradle-home; stdout.bin, stderr.bin, probe-wrapper.json.
Existing authority/task/native/snapshot may be updated only to persist original receipts and closed status. No later result path is required.

The command texts below are fixed before snapshot/A. Tool output objects are retained exactly, not replaced by hand-written receipts. Scientific command budgets count tool calls; polling one already-running process does not rerun commands.

## A (PowerShell, one tool call)
```powershell
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE'
$utf=[Text.UTF8Encoding]::new($false,$true)
$reads=[Collections.Generic.List[object]]::new()
$data=@{}
function Ordinary($f){
    if(($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'REPARSE'}
    $d=$f.Directory
    while($null-ne$d){
        if(($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'ANCESTOR_REPARSE'}
        $d=$d.Parent
    }
}
function HashBytes([byte[]]$b){
    $h=[Security.Cryptography.SHA256]::Create()
    try{[BitConverter]::ToString($h.ComputeHash($b)).Replace('-','')}finally{$h.Dispose()}
}
$spec=@(
    @('Harness',$base+'\DiagnoseRawGString.groovy',9812,16384,'0FDF72979FE6C6C174CAFDB8A8B7975AFA86D6F22743DD0520BAAE87EC4368EB'),
    @('Launcher',$base+'\Invoke-RawGStringDiagnostic.ps1',26073,32768,'A10012BF520B5A3F928A46D8E1240636F094A663330F13BEE53F162C284F0048'),
    @('Installer','D:\EliteSync-v10\EVIDENCE\APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE\LocalExtraRecipeInstaller.groovy',6141,6141,'7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37'),
    @('TSV','D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv',19534,19534,'E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80'),
    @('Authority',$base+'\runtime-authority.json',-1,8192,''),
    @('Snapshot',$base+'\workspace-before.json',-1,262144,'')
)
foreach($item in $spec){
    $f=Get-Item -LiteralPath $item[1]
    if($f-isnot[IO.FileInfo]-or$f.Length-gt$item[3]-or($item[2]-ge0-and$f.Length-ne$item[2])){throw 'A_METADATA'}
    Ordinary $f
    [byte[]]$b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne$f.Length-or$b.Length-gt$item[3]){throw 'A_READ_SIZE'}
    $hash=HashBytes $b
    if($item[4]-ne''-and$hash-cne$item[4]){throw 'A_HASH'}
    $data[$item[0]]=$b
    $reads.Add([ordered]@{Name=$item[0];Bytes=$b.Length;SHA256=$hash;BodyReads=1})
}
function ExactKeys($map,[string[]]$keys){
    if($map-isnot[Collections.IDictionary]-or$map.Count-ne$keys.Count){throw 'A_JSON_KEYS'}
    foreach($k in $keys){if(-not$map.Contains($k)){throw 'A_JSON_KEY'}}
}
$auth=$utf.GetString($data.Authority)|ConvertFrom-Json -AsHashtable
ExactKeys $auth @('TaskId','Status','JVM','OwnerAuthorization','ProbeSha256','ProbeBytes','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath','InstallerPath','InstallerSha256','InstallerBytes')
$expected=@{
    TaskId='DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE';Status='ISSUED';JVM=1;
    OwnerAuthorization='OWNER_SINGLE_CASE_DIAGNOSTIC_AUTHORIZED';
    ProbeSha256='0FDF72979FE6C6C174CAFDB8A8B7975AFA86D6F22743DD0520BAAE87EC4368EB';ProbeBytes=9812;
    ProbePath=($base+'\DiagnoseRawGString.groovy');
    ManifestPath='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv';
    InputRoot='D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib';
    OutputRoot=$base;JavaPath='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe';
    InstallerPath='D:\EliteSync-v10\EVIDENCE\APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE\LocalExtraRecipeInstaller.groovy';
    InstallerSha256='7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37';InstallerBytes=6141
}
foreach($k in $expected.Keys){
    if($expected[$k]-is[string]){
        if($auth[$k]-isnot[string]-or$auth[$k]-cne$expected[$k]){throw 'A_AUTH_STRING'}
    }elseif(($auth[$k]-isnot[int]-and$auth[$k]-isnot[long])-or$auth[$k]-ne$expected[$k]){throw 'A_AUTH_INTEGER'}
}
$snap=$utf.GetString($data.Snapshot)|ConvertFrom-Json -AsHashtable
ExactKeys $snap @('Branch','HEAD','Count','Paths')
if($snap.Branch-cne'main'-or$snap.HEAD-cne'71fa57f8c734bf4ea2597b4bf453515ef3c37461'-or$snap.Paths-isnot[array]-or$snap.Count-ne$snap.Paths.Count){throw 'A_SNAPSHOT'}
foreach($p in $snap.Paths){if($p-isnot[string]){throw 'A_PATH_TYPE'}}
if(@($snap.Paths|Select-Object -Unique).Count-ne$snap.Count){throw 'A_DUPLICATE_PATH'}
if((Get-Location).Path-cne'D:\EliteSync-v10'){throw 'A_CWD'}
$branch=git branch --show-current
if($LASTEXITCODE-ne0-or$branch-cne'main'){throw 'A_BRANCH'}
$head=git rev-parse HEAD
if($LASTEXITCODE-ne0-or$head-cne$snap.HEAD){throw 'A_HEAD'}
$now=@(git --no-optional-locks -c core.quotepath=false status --porcelain=v1 --untracked-files=all)
if($LASTEXITCODE-ne0){throw 'A_GIT_STATUS'}
$paths=@($now|ForEach-Object{$_.Substring(3)})
if($paths.Count-ne$snap.Count-or@($snap.Paths|Where-Object{$_ -cnotin $paths}).Count-ne0){throw 'A_WORKSPACE_PATHS'}
foreach($name in @('invocation-started.json','stdout.bin','stderr.bin','probe-wrapper.json','cwd','tmp','user-home','appdata','localappdata','gradle-home')){
    if(Test-Path -LiteralPath ($base+'\'+$name)){throw 'A_OUTPUT_EXISTS'}
}
[ordered]@{Result='A_READY';HEAD=$head;Branch=$branch;SnapshotPaths=$paths.Count;Reads=$reads;ExternalRead=0;JVM=0}|ConvertTo-Json -Depth 5 -Compress
```

## Invocation (PowerShell, exactly this command)
```powershell
& 'D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE\Invoke-RawGStringDiagnostic.ps1'
```

## B (PowerShell, one tool call; mutually exclusive with FailureDisclosure)
```powershell
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE'
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
if($LASTEXITCODE-ne0-or$head-cne'71fa57f8c734bf4ea2597b4bf453515ef3c37461'){throw 'B_HEAD'}
[ordered]@{Result='B_DISK_IDENTITIES_VERIFIED';HEAD=$head;Facts=$facts;Wrapper=$w;Diagnostic=$j;OriginalToolReceiptComparison='PENDING_SAME_CALLER_CACHE'}|ConvertTo-Json -Depth 8 -Compress
```

## B same-caller native cache comparison (JavaScript, no tool/file call)
```javascript
const inv = load("rawGStringInvocation");
const b = load("rawGStringB");
if (inv.exit_code !== 0 || b.exit_code !== 0) throw Error("NATIVE_EXIT");
const receipt = JSON.parse(inv.output.trim());
const disk = JSON.parse(b.output.trim());
if (receipt.Result !== "DIAGNOSTIC_CAPTURE_COMPLETE") throw Error("NATIVE_RESULT");
for (const [name, prefix] of [["stdout.bin","Stdout"],["stderr.bin","Stderr"],["probe-wrapper.json","Wrapper"]]) {
  if (receipt[prefix+"Bytes"] !== disk.Facts[name].Bytes ||
      receipt[prefix+"SHA256"] !== disk.Facts[name].SHA256) throw Error("NATIVE_DISK_IDENTITY");
}
for (const k of ["ProcessStartAttempt","CandidateInvocation","CandidateInvocationAttempt","CandidateParseClassLoad","CandidateSourceRead","FourteenCaseInvocation","InvokeOutcome","RuntimeReady"]) {
  if (receipt[k] !== disk.Wrapper[k]) throw Error("NATIVE_WRAPPER_FIELD");
}
text({Result:"B_ORIGINAL_NATIVE_AND_DISK_MATCH",CandidateAcceptance:"NOT_GRANTED"});

```

## FailureDisclosure (PowerShell, at most once, mutually exclusive with B)
```powershell
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-SINGLE-CASE-DIAGNOSTIC-ONCE'
$utf=[Text.UTF8Encoding]::new($false,$true)
function HashBytes([byte[]]$b){
    $h=[Security.Cryptography.SHA256]::Create()
    try{[BitConverter]::ToString($h.ComputeHash($b)).Replace('-','')}finally{$h.Dispose()}
}
$facts=@{}
foreach($name in @('stdout.bin','stderr.bin','probe-wrapper.json')){
    $p=$base+'\'+$name
    if(-not(Test-Path -LiteralPath $p)){$facts[$name]=[ordered]@{Exists=$false;BodyReads=0};continue}
    $f=Get-Item -LiteralPath $p
    if($f-isnot[IO.FileInfo]-or$f.Length-gt8192-or($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'DISCLOSURE_METADATA'}
    [byte[]]$b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne$f.Length){throw 'DISCLOSURE_SIZE'}
    $facts[$name]=[ordered]@{Exists=$true;Bytes=$b.Length;SHA256=(HashBytes $b);BodyReads=1;Text=$utf.GetString($b)}
}
[ordered]@{Result='FAILURE_DISCLOSURE_ONLY';Facts=$facts;RuntimeReady=$false}|ConvertTo-Json -Depth 5 -Compress
```

Stop immediately after observation and original artifact identities. Independent review/dot final verdict remains separate; automation PAUSED and NOT_READY, all old budgets/rejections unchanged.
