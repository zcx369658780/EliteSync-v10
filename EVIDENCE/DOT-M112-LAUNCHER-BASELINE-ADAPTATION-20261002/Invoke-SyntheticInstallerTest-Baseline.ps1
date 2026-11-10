# SOURCE-ONLY: no execution permission is conveyed by this source.
# Future Work must issue exact M5-112 single-use authority under Owner delegation.
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE'
$probePath='D:\EliteSync-v10\EVIDENCE\APP-M5-85-SYNTHETIC-INSTALLER-HARNESS-SOURCE\VerifyLocalExtraRecipeInstaller.groovy'
$installerPath='D:\EliteSync-v10\EVIDENCE\APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE\LocalExtraRecipeInstaller.groovy'
$tsvPath='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv'
$root='D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib'
$java='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe'
$utf=[Text.UTF8Encoding]::new($false,$true)
$baseVerified=$false;$authorityVerified=$false;$phase='BASE'
$first=$null;$secondary=[Collections.Generic.List[string]]::new()
$externalGet=0;$externalRead=0;$tsvRead=0;$probeRead=0;$installerRead=0
[long]$externalBytes=0
$started=$false;$exited=$false;$exitCode=$null;$timedOut=$false;$killAttempted=0
$process=$null;$cts=$null;$out=$null;$err=$null
$stdout=[byte[]]@();$stderr=[byte[]]@()
$cleanupComplete=$false;$captureComplete=$false;$schemaChecked=$false
$success=$false;$scriptCopies=0;$processAttempts=0
function Fail([string]$tag,[Exception]$cause=$null) {
    if($null-eq$script:first){
        $script:first=[ordered]@{Phase=$script:phase;Tag=$tag;Class=$(if($cause){$cause.GetType().FullName}else{'FIXED_TAG'})}
    }else{$script:secondary.Add($script:phase+':'+$tag)}
}
function StopFirst {
if(!$first){Fail 'TERMINAL'}
$p=@();$cut=$false
foreach($x in @($first.Phase,$first.Tag,$first.Class,([string]::Join('|',$secondary)))){
$x=[string]$x;$cut=$cut-or($x.Length-gt128)
$p+=-join($x.Substring(0,[Math]::Min(128,$x.Length)).ToCharArray()|ForEach-Object{'\u'+([int]$_).ToString('X4')})
}
throw [InvalidOperationException]::new('Encoding=UTF16_CODE_UNITS_HEX;Phase/Tag/Class/SecondaryPrefix='+[string]::Join('|',$p)+';Cut='+$cut+';SecondaryCount='+$secondary.Count)
}
function Ordinary($f) {
    if(($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'REPARSE'}
    $d=if($f-is[IO.FileInfo]){$f.Directory}else{$f}
    while($null-ne$d){
        if($d-isnot[IO.DirectoryInfo]-or($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'ANCESTOR'}
        $d=$d.Parent
    }
}
function Digest([byte[]]$bytes) {
    $h=$null;$failure=$null;$value=$null
    try{$h=[Security.Cryptography.SHA256]::Create();$value=[BitConverter]::ToString($h.ComputeHash($bytes)).Replace('-','')}
    catch{$failure=$_.Exception}
    if($null-ne$h){try{$h.Dispose()}catch{if($null-eq$failure){$failure=$_.Exception}else{$secondary.Add('HASH_DISPOSE_SECONDARY')}}}
    if($null-ne$failure){throw $failure}
    return $value
}
function ReadText([string]$path,[int]$limit) {
    $f=Get-Item -LiteralPath $path
    if($f-isnot[IO.FileInfo]-or$f.Length-gt$limit){throw 'LOCAL_FILE_SIZE'}
    Ordinary $f
    $b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne$f.Length-or$b.Length-gt$limit){throw 'LOCAL_READ_SIZE'}
    return $utf.GetString($b)
}
function SaveBytes([string]$path,[byte[]]$bytes) {
    if(-not($script:baseVerified-and$script:authorityVerified)){throw 'SAVE_PERMISSION'}
    $stream=$null;$failure=$null
    try{
        $stream=[IO.File]::Open($path,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
        $stream.Write($bytes,0,$bytes.Length);$stream.Flush()
    }catch{$failure=$_.Exception}
    if($null-ne$stream){
        try{$stream.Dispose()}catch{
            if($null-eq$failure){$failure=$_.Exception}else{$script:secondary.Add('SAVE_DISPOSE_SECONDARY')}
        }
    }
    if($null-ne$failure){throw $failure}
}
function NewPump($stream,[string]$name) {
    return @{Name=$name;Stream=$stream;Memory=[IO.MemoryStream]::new();Buffer=[byte[]]::new(4096);Task=$null;EOF=$false;Overflow=$false;Gap=$false}
}
function BeginRead($p) {
    $remaining=32768-[int]$p.Memory.Length
    $count=[Math]::Min(4096,$remaining+1)
    $p.Task=$p.Stream.ReadAsync($p.Buffer,0,$count,$script:cts.Token)
}
function StepRead($p,[bool]$again) {
    if($null-eq$p.Task-or-not$p.Task.IsCompleted){return}
    $script:phase='READ_'+$p.Name
    $task=$p.Task;$p.Task=$null
    try{
        $count=$task.GetAwaiter().GetResult()
        if($count-eq0){$p.EOF=$true}
        else{
            $keep=[Math]::Min($count,32768-[int]$p.Memory.Length)
            if($keep-gt0){$p.Memory.Write($p.Buffer,0,$keep)}
            if($count-gt$keep){$p.Overflow=$true;$p.Gap=$true;Fail 'STREAM_LIMIT'}
        }
    }catch{$p.Gap=$true;Fail 'STREAM_READ' $_.Exception}
    try{$task.Dispose()}catch{Fail 'READTASK_DISPOSE' $_.Exception}
    if($again-and$null-eq$script:first-and-not$p.EOF){BeginRead $p}
}
function ExactKeys($map,[string[]]$keys) {
    if($map-isnot[Collections.IDictionary]-or$map.Count-ne$keys.Length){throw 'JSON_KEYS'}
    foreach($k in $keys){if(-not$map.Contains($k)){throw 'JSON_KEY_MISSING'}}
}
try{
    $d=Get-Item -LiteralPath $base
    if($d-isnot[IO.DirectoryInfo]){throw 'BASE_DIRECTORY'}
    Ordinary $d;$baseVerified=$true
    $phase='AUTHORITY'
    $authority=ReadText ($base+'\runtime-authority.json') 8192|ConvertFrom-Json -AsHashtable
    ExactKeys $authority @('TaskId','Status','JVM','OwnerAuthorization','ProbeSha256','ProbeBytes','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath','InstallerPath','InstallerSha256','InstallerBytes')
    foreach($k in @('TaskId','Status','OwnerAuthorization','ProbeSha256','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath','InstallerPath','InstallerSha256')){if($authority[$k]-isnot[string]){throw 'AUTHORITY_STRING'}}
    foreach($k in @('JVM','ProbeBytes','InstallerBytes')){if($authority[$k]-isnot[int]-and$authority[$k]-isnot[long]){throw 'AUTHORITY_INTEGER'}}
    if($authority.TaskId-cne'APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE'-or$authority.Status-cne'ISSUED'-or
       $authority.JVM-ne1-or$authority.OwnerAuthorization-cne'OWNER_DELEGATED_SINGLE_JVM_SYNTHETIC_TEST_AUTHORIZED'-or
       $authority.ProbePath-cne$probePath-or$authority.ManifestPath-cne$tsvPath-or
       $authority.InputRoot-cne$root-or$authority.OutputRoot-cne$base-or$authority.JavaPath-cne$java-or
       $authority.InstallerPath-cne$installerPath){throw 'AUTHORITY_BINDING'}
    if($authority.ProbeBytes-ne14402-or$authority.ProbeBytes-gt16384-or
       $authority.ProbeSha256-cne'7251ACF92C24055EEFC5E299DEF620D09263C3F5C4DFA80E7DB3A763702E5CCD'-or
       $authority.InstallerBytes-ne6141-or
       $authority.InstallerSha256-cne'7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37'){throw 'AUTHORITY_SOURCE_IDENTITY'}
    $phase='WORKSPACE'
    $snap=ReadText ($base+'\workspace-before.json') 262144|ConvertFrom-Json -AsHashtable
    if((Get-Location).Path-ne'D:\EliteSync-v10'-or(git branch --show-current)-ne'main'-or
       (git rev-parse HEAD)-ne'4f5bea7e558bc15d24ce45d3e4704ac658906a38'-or
       $snap.Branch-ne'main'-or$snap.HEAD-ne'4f5bea7e558bc15d24ce45d3e4704ac658906a38'){throw 'WORKSPACE_IDENTITY'}
    $now=@(git -c core.quotepath=false status --porcelain=v1|ForEach-Object{$_.Substring(3)})
    if($snap.Count-ne$snap.Paths.Count-or@($snap.Paths|Where-Object{$_ -notin $now}).Count-ne0){throw 'WORKSPACE_MEMBERS'}
    $authorityVerified=$true
    foreach($name in @('stdout.bin','stderr.bin','probe-wrapper.json','cwd','tmp','user-home','appdata','localappdata','gradle-home')){
        if(Test-Path -LiteralPath ($base+'\'+$name)){throw 'OUTPUT_EXISTS'}
    }
    $phase='TSV'
    $f=Get-Item -LiteralPath $tsvPath
    if($f-isnot[IO.FileInfo]-or$f.Length-ne19534){throw 'TSV_SIZE'};Ordinary $f
    $tsvRead++;$b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne19534-or(Digest $b)-ne'E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80'){throw 'TSV_IDENTITY'}
    foreach($v in $b){if($v-gt127){throw 'TSV_ASCII'}}
    $t=$utf.GetString($b);$b=$null
    $crlf=([string][char]13)+[char]10
    $lines=$t.Split(@($crlf),[StringSplitOptions]::None)
    if($lines.Count-ne190-or$lines[189]-ne''-or$lines[0]-cne('Name'+[char]9+'Bytes'+[char]9+'SHA256')){throw 'TSV_SCHEMA'}
    $inputs=[Collections.Generic.List[object]]::new();$classpath=[Collections.Generic.List[string]]::new()
    $last='';[long]$sum=0
    for($i=1;$i-le188;$i++){
        $c=$lines[$i].Split([char]9)
        if($c.Count-ne3-or$c[0]-notmatch'^[A-Za-z0-9_-][A-Za-z0-9_.-]*\.jar$'-or$c[0].Contains('..')-or
           $c[1]-notmatch'^(0|[1-9][0-9]*)$'-or$c[2]-notmatch'^[0-9A-F]{64}$'){throw 'TSV_ROW'}
        if($i-gt1-and[StringComparer]::Ordinal.Compare($last,$c[0])-ge0){throw 'TSV_ORDER'}
        [long]$size=$c[1];if($size-gt268435456){throw 'INPUT_SIZE'}
        $sum+=$size;$last=$c[0];$path=$root+'\'+$c[0]
        $inputs.Add(@{Path=$path;Bytes=$size;Hash=$c[2]});$classpath.Add($path)
    }
    if($sum-ne115067677){throw 'TSV_TOTAL'}
    $t=$null;$lines=$null
    $inputs.Add(@{Path=$java;Bytes=50344;Hash='5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B'})
    foreach($item in $inputs){
        $phase='INPUT_META_'+($externalGet+1);$externalGet++
        $f=Get-Item -LiteralPath $item.Path
        if($f-isnot[IO.FileInfo]-or$f.Length-ne$item.Bytes-or$f.Length-gt268435456-or
           ($externalBytes+$f.Length)-gt1073741824){throw 'INPUT_METADATA'};Ordinary $f
        $phase='INPUT_READ_'+($externalRead+1);$externalRead++
        $b=[IO.File]::ReadAllBytes($f.FullName)
        if($b.Length-ne$item.Bytes-or$b.Length-gt268435456-or($externalBytes+$b.Length)-gt1073741824){throw 'INPUT_READ_SIZE'}
        if((Digest $b)-cne$item.Hash){throw 'INPUT_HASH'}
        $externalBytes+=$b.Length;$b=$null
    }
    if($externalGet-ne189-or$externalRead-ne189-or$externalBytes-ne115118021){throw 'INPUT_TOTAL'}
    $phase='INSTALLER_PREFLIGHT'
    $f=Get-Item -LiteralPath $installerPath
    if($f-isnot[IO.FileInfo]-or$f.Length-ne6141-or$f.Length-ne$authority.InstallerBytes){throw 'INSTALLER_METADATA'};Ordinary $f
    $installerRead++;$installerBytes=[IO.File]::ReadAllBytes($f.FullName)
    if($installerBytes.Length-ne6141-or(Digest $installerBytes)-cne$authority.InstallerSha256){throw 'INSTALLER_IDENTITY'}
    $null=$utf.GetString($installerBytes);$installerBytes=$null
    $phase='HARNESS_SOURCE'
    $f=Get-Item -LiteralPath $probePath
    if($f-isnot[IO.FileInfo]-or$f.Length-ne14402-or$f.Length-gt16384-or$f.Length-ne$authority.ProbeBytes){throw 'HARNESS_METADATA'};Ordinary $f
    $probeRead++;$probeBytes=[IO.File]::ReadAllBytes($f.FullName)
    if($probeBytes.Length-ne14402-or$probeBytes.Length-gt16384-or(Digest $probeBytes)-cne$authority.ProbeSha256){throw 'HARNESS_IDENTITY'}
    $null=$utf.GetString($probeBytes)
    $phase='OWNED_DIRECTORIES'
    foreach($name in @('cwd','tmp','user-home','appdata','localappdata','gradle-home')){
        $new=[IO.Directory]::CreateDirectory($base+'\'+$name);Ordinary $new
    }
    $phase='PROBE_COPY'
    SaveBytes ($base+'\cwd\harness.groovy') $probeBytes;$scriptCopies++;$probeBytes=$null
    $arguments=@('-Xms32m','-Xmx256m',('-Duser.home='+$base+'\user-home'),
        ('-Djava.io.tmpdir='+$base+'\tmp'),'-cp',[string]::Join(';',$classpath),
        'groovy.ui.GroovyMain',($base+'\cwd\harness.groovy'))
    # Fixed arguments contain no embedded quotes. Model Windows quoting exactly.
    $quoted=[Collections.Generic.List[string]]::new()
    foreach($arg in @($java)+$arguments){
        if($arg.Contains('"')-or$arg.Contains([char]0)-or$arg.Contains([char]13)-or$arg.Contains([char]10)){throw 'ARGUMENT_CHAR'}
        if($arg-match'\s'){$quoted.Add('"'+[regex]::Replace($arg,'(\\+)$','$1$1')+'"')}else{$quoted.Add($arg)}
    }
    $commandline=[string]::Join(' ',$quoted)
    if($commandline.Length-gt30000){throw 'COMMANDLINE_LIMIT'}
    $phase='PROCESS_PREPARE'
    $si=[Diagnostics.ProcessStartInfo]::new()
    $si.FileName=$java;$si.WorkingDirectory=$base+'\cwd'
    $si.UseShellExecute=$false;$si.CreateNoWindow=$true
    $si.RedirectStandardInput=$true;$si.RedirectStandardOutput=$true;$si.RedirectStandardError=$true
    foreach($arg in $arguments){$si.ArgumentList.Add($arg)}
    $si.Environment.Clear()
    $environment=@{SystemRoot='C:\Windows';windir='C:\Windows';TEMP=($base+'\tmp');TMP=($base+'\tmp');
        USERPROFILE=($base+'\user-home');HOME=($base+'\user-home');APPDATA=($base+'\appdata');
        LOCALAPPDATA=($base+'\localappdata');JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot';
        GRADLE_USER_HOME=($base+'\gradle-home')}
    foreach($key in $environment.Keys){$si.Environment.Add($key,$environment[$key])}
    $process=[Diagnostics.Process]::new();$process.StartInfo=$si
    $cts=[Threading.CancellationTokenSource]::new()
    $phase='PROCESS_START';$processAttempts++
    if(-not$process.Start()){throw 'PROCESS_NOT_STARTED'};$started=$true
    $watch=[Diagnostics.Stopwatch]::StartNew()
    $phase='STDIN_CLOSE';$process.StandardInput.Close()
    $out=NewPump $process.StandardOutput.BaseStream 'STDOUT'
    $err=NewPump $process.StandardError.BaseStream 'STDERR'
    BeginRead $out;BeginRead $err
    while($null-eq$first){
        StepRead $out $true
        if($null-ne$first){break}
        StepRead $err $true
        if($null-ne$first){break}
        $phase='PROCESS_WAIT';$exited=$process.HasExited
        if($exited-and$out.EOF-and$err.EOF){break}
        if($watch.ElapsedMilliseconds-ge30000){$timedOut=$true;Fail 'CHILD_TIMEOUT';break}
        [Threading.Thread]::Sleep(10)
    }
}catch{Fail $_.Exception.Message $_.Exception}
# Cleanup is a separate 2s monotonic budget. Synchronous OS calls are not
# asserted interruptible: exceeding this budget is FAIL/NOT_PROVEN.
$cleanWatch=[Diagnostics.Stopwatch]::StartNew()
if($started){
    try{
        $phase='CLEANUP_EXIT';$exited=$process.HasExited
        if(-not$exited){
            $phase='CLEANUP_KILL';$killAttempted++
            $process.Kill($true)
        }
    }catch{Fail 'KILL_OR_EXIT' $_.Exception}
    if($null-ne$first-and$null-ne$cts){try{$cts.Cancel()}catch{Fail 'CTS_CANCEL' $_.Exception}}
    while($cleanWatch.ElapsedMilliseconds-lt2000){
        if($null-ne$out){StepRead $out $false}
        if($null-ne$err){StepRead $err $false}
        try{$exited=$process.HasExited}catch{Fail 'EXIT_OBSERVATION' $_.Exception;break}
        $pending=($null-ne$out-and$null-ne$out.Task)-or($null-ne$err-and$null-ne$err.Task)
        if($exited-and-not$pending){break}
        [Threading.Thread]::Sleep(10)
    }
    if(-not$exited){$phase='CLEANUP';Fail 'CHILD_EXIT_NOT_PROVEN'}
    if($exited){try{$exitCode=$process.ExitCode}catch{Fail 'EXIT_CODE' $_.Exception}}
}
foreach($p in @($out,$err)){
    if($null-eq$p){continue}
    try{
        if($p.Name-eq'STDOUT'){$stdout=$p.Memory.ToArray()}else{$stderr=$p.Memory.ToArray()}
    }catch{Fail 'CAPTURE_ARRAY' $_.Exception}
    if($null-ne$p.Task){
        if($p.Task.IsCompleted){try{$p.Task.Dispose()}catch{Fail 'PENDING_TASK_DISPOSE' $_.Exception}}
        else{$p.Gap=$true;Fail 'READTASK_COMPLETION_NOT_PROVEN'}
    }
    foreach($resource in @($p.Stream,$p.Memory)){
        try{$resource.Dispose()}catch{Fail 'STREAM_DISPOSE' $_.Exception}
    }
}
$captureComplete=($null-ne$out-and$null-ne$err-and$out.EOF-and$err.EOF-and
    -not$out.Gap-and-not$err.Gap-and-not$out.Overflow-and-not$err.Overflow)
foreach($resource in @($cts,$process)){
    if($null-ne$resource){try{$resource.Dispose()}catch{Fail 'PROCESS_RESOURCE_DISPOSE' $_.Exception}}
}
if($cleanWatch.ElapsedMilliseconds-ge2000){$phase='CLEANUP';Fail 'CLEANUP_DEADLINE_NOT_PROVEN'}
$cleanupComplete=($null-eq$first)
if($null-eq$first){
    try{
        $phase='TEST_VALIDATE'
        if(-not$started-or-not$exited-or$exitCode-ne0-or-not$captureComplete-or$stderr.Length-ne0){throw 'CHILD_RESULT_OR_STREAM'}
        $json=$utf.GetString($stdout)|ConvertFrom-Json -AsHashtable
        $null=$utf.GetString($stderr)
        ExactKeys $json @('mode','synthetic','runtimeReady','sourceRead','parseClassLoad','executedCase','candidateInvocation','cases','realBinding','hook','libraryExtensionTiming','sdkCompatibility')
        foreach($k in @('mode','realBinding','hook','libraryExtensionTiming','sdkCompatibility')){if($json[$k]-isnot[string]){throw 'TEST_STRING'}}
        foreach($k in @('sourceRead','parseClassLoad','executedCase','candidateInvocation')){if($json[$k]-isnot[int]-and$json[$k]-isnot[long]){throw 'TEST_INTEGER'}}
        if($json.mode-cne'TEST_SOURCE_SPEC'-or$json.synthetic-isnot[bool]-or-not$json.synthetic-or
           $json.runtimeReady-isnot[bool]-or$json.runtimeReady-or$json.sourceRead-ne1-or$json.parseClassLoad-ne1-or
           $json.executedCase-ne14-or$json.candidateInvocation-ne14-or$json.cases-isnot[array]-or$json.cases.Count-ne14){throw 'TEST_SCHEMA'}
        foreach($k in @('realBinding','hook','libraryExtensionTiming','sdkCompatibility')){if($json[$k]-cne'NOT_CHECKED'){throw 'TEST_LIMITATION'}}
        $names=@('EMPTY_OWN','MIXED_OWN','SAME_OWN','LATE_VALUE_CONFLICT','LATE_TYPE_CONFLICT','RAW_GSTRING_PATH','RAW_NULL_TARGET','RAW_NONMAP','MISSING_KEY','GSTRING_VALUE','WRONG_MODE','TARGET_MISMATCH','THIRD_SET_FAIL','POST_READ_FAIL')
        for($i=0;$i-lt14;$i++){
            $item=$json.cases[$i];ExactKeys $item @('caseId','result','invocationCount')
            if($item.caseId-isnot[string]-or$item.caseId-cne$names[$i]-or$item.result-isnot[string]-or$item.result-cne'PASS'-or
               ($item.invocationCount-isnot[int]-and$item.invocationCount-isnot[long])-or$item.invocationCount-ne1){throw 'CASE_SCHEMA'}
        }
        $schemaChecked=$true;$success=$true
    }catch{Fail $_.Exception.Message $_.Exception}
}
$success=$success-and$null-eq$first
# A denied base/authority causes no output files or directories anywhere.
if(-not($baseVerified-and$authorityVerified)){
    StopFirst
}
$phase='RECEIPT_HASH'
try{$outHash=Digest $stdout;$errHash=Digest $stderr}catch{Fail 'RECEIPT_HASH' $_.Exception;StopFirst}
$phase='SAVE_STDOUT'
try{SaveBytes ($base+'\stdout.bin') $stdout}catch{Fail 'SAVE_STDOUT' $_.Exception;StopFirst}
$phase='SAVE_STDERR'
try{SaveBytes ($base+'\stderr.bin') $stderr}catch{Fail 'SAVE_STDERR' $_.Exception;StopFirst}
$phase='WRAPPER_SERIALIZE'
$wrapper=[ordered]@{
    mode='SINGLE_JVM_SYNTHETIC_TEST_RECEIPT';Result=$(if($success){'PASS_SYNTHETIC_14CASE_SCOPE_ONLY'}else{'FAIL'});
    Root=$base;BaseVerified=$baseVerified;AuthorityVerified=$authorityVerified;
    TSVRead=$tsvRead;HarnessSourceRead=$probeRead;HarnessCopies=$scriptCopies;LocalInstallerPreflightRead=$installerRead;
    ExternalGet=$externalGet;ExternalRead=$externalRead;ExternalBytes=$externalBytes;
    ProcessStartAttempt=$processAttempts;Started=$started;Exited=$exited;ExitCode=$exitCode;
    Timeout=$timedOut;KillAttempt=$killAttempted;CleanupComplete=$cleanupComplete;
    CaptureComplete=$captureComplete;StdoutComplete=$(if($out){$out.EOF-and-not$out.Gap-and-not$out.Overflow}else{$false});
    StderrComplete=$(if($err){$err.EOF-and-not$err.Gap-and-not$err.Overflow}else{$false});
    StdoutBytes=$stdout.Length;StdoutSHA256=$outHash;StderrBytes=$stderr.Length;StderrSHA256=$errHash;
    TestSchemaChecked=$schemaChecked;Failure=$first;SecondaryFailure=$secondary;
    CandidateParseClassLoad=$(if($schemaChecked){1}elseif($started){'UNKNOWN'}else{0});
    CandidateSourceRead=$(if($schemaChecked){1}elseif($started){'UNKNOWN'}else{0});
    CandidateInvocation=$(if($schemaChecked){14}elseif($started){'UNKNOWN'}else{0});
    FourteenCaseInvocation=$(if($schemaChecked){14}elseif($started){'UNKNOWN'}else{0});
    ExplicitInterfaceRequest='NOT_APPLICABLE';HarnessScript=$(if($started){1}else{0});
    ImplicitClassloads='NOT_MEASURED';VersionProvenance='SAME_INPUT_IDENTITIES_NOT_REMEASURED';RuntimeReady=$false;
    OSHardCutoff='NOT_PROVEN';OSFileNetworkIsolation='NOT_PROVEN';ParentToolStderr='UNKNOWN';
    RealBinding='NOT_CHECKED';Hook='NOT_CHECKED';LibraryExtensionTiming='NOT_CHECKED';SDKCompatibility='NOT_CHECKED'
}
try{
    $w=$wrapper|ConvertTo-Json -Depth 5 -Compress;$wb=$utf.GetBytes($w)
    if($wb.Length-gt8192){throw 'WRAPPER_LIMIT'}
}catch{Fail 'WRAPPER_SERIALIZE' $_.Exception;StopFirst}
$phase='SAVE_WRAPPER'
try{SaveBytes ($base+'\probe-wrapper.json') $wb}catch{Fail 'SAVE_WRAPPER' $_.Exception;StopFirst}
$phase='SMALL_RECEIPT'
try{
    $wh=Digest $wb
    $receipt=[ordered]@{Result=$wrapper.Result;Root=$base;WrapperBytes=$wb.Length;WrapperSHA256=$wh;
        StdoutBytes=$stdout.Length;StdoutSHA256=$outHash;StderrBytes=$stderr.Length;StderrSHA256=$errHash;
        ProcessStartAttempt=$processAttempts;CandidateInvocation=$wrapper.CandidateInvocation;
        CandidateParseClassLoad=$wrapper.CandidateParseClassLoad;CandidateSourceRead=$wrapper.CandidateSourceRead;
        FourteenCaseInvocation=$wrapper.FourteenCaseInvocation;RuntimeReady=$false;
        OSHardCutoff='NOT_PROVEN';OSFileNetworkIsolation='NOT_PROVEN'}|ConvertTo-Json -Compress
    if($utf.GetByteCount($receipt)-gt4096-or$receipt.Length-gt4096){throw 'SMALL_RECEIPT_LIMIT'}
    [Console]::WriteLine($receipt)
}catch{Fail 'SMALL_RECEIPT_EMIT' $_.Exception;StopFirst}
if($success){exit 0}else{exit 1}
