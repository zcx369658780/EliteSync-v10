# SOURCE-ONLY: no execution permission is conveyed by this source.
# Future Work must issue exact M5-100 authority after current Owner approval.
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\APP-M5-100-DISTRIBUTION-ONLY-API-PROBE-ONCE'
$probePath='D:\EliteSync-v10\EVIDENCE\APP-M5-92-SINGLE-JVM-API-PROBE-SOURCE\Probe-GroovyGradleApi.groovy'
$tsvPath='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv'
$root='D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib'
$java='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe'
$utf=[Text.UTF8Encoding]::new($false,$true)
$baseVerified=$false;$authorityVerified=$false;$phase='BASE'
$first=$null;$secondary=[Collections.Generic.List[string]]::new()
$externalGet=0;$externalRead=0;$tsvRead=0;$probeRead=0
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
    ExactKeys $authority @('TaskId','Status','JVM','OwnerAuthorization','ProbeSha256','ProbeBytes','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath')
foreach($k in @('TaskId','Status','OwnerAuthorization','ProbeSha256','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath')){if($authority[$k]-isnot[string]){throw 'AUTHORITY_STRING'}}
    if($authority.TaskId-cne'APP-M5-100-DISTRIBUTION-ONLY-API-PROBE-ONCE'-or$authority.Status-cne'ISSUED'-or
       ($authority.JVM-isnot[long]-and$authority.JVM-isnot[int])){throw 'AUTHORITY_FIELDS'}
    if($authority.JVM-ne1-or$authority.OwnerAuthorization-cne'OWNER_SINGLE_JVM_API_PROBE_AUTHORIZED'-or
       $authority.ProbePath-cne$probePath-or$authority.ManifestPath-cne$tsvPath-or
       $authority.InputRoot-cne$root-or$authority.OutputRoot-cne$base-or
       $authority.JavaPath-cne$java-or
       $authority.ProbeSha256-notmatch'^[0-9A-F]{64}$'-or
       ($authority.ProbeBytes-isnot[long]-and$authority.ProbeBytes-isnot[int])){throw 'AUTHORITY_BINDING'}
    if($authority.ProbeBytes-le0-or$authority.ProbeBytes-gt4096){throw 'PROBE_SIZE_AUTHORITY'}
    $phase='WORKSPACE'
    $snap=ReadText ($base+'\workspace-before.json') 262144|ConvertFrom-Json -AsHashtable
    if((Get-Location).Path-ne'D:\EliteSync-v10'-or(git branch --show-current)-ne'main'-or
       (git rev-parse HEAD)-ne'cf8bfaa4a03b8c9a682105617b185141904413be'-or
       $snap.Branch-ne'main'-or$snap.HEAD-ne'cf8bfaa4a03b8c9a682105617b185141904413be'){throw 'WORKSPACE_IDENTITY'}
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
    $phase='PROBE_SOURCE'
    $f=Get-Item -LiteralPath $probePath
    if($f-isnot[IO.FileInfo]-or$f.Length-ne$authority.ProbeBytes){throw 'PROBE_METADATA'};Ordinary $f
    $probeRead++;$probeBytes=[IO.File]::ReadAllBytes($f.FullName)
    if($probeBytes.Length-ne$authority.ProbeBytes-or(Digest $probeBytes)-cne$authority.ProbeSha256){throw 'PROBE_IDENTITY'}
    $null=$utf.GetString($probeBytes)
    $phase='OWNED_DIRECTORIES'
    foreach($name in @('cwd','tmp','user-home','appdata','localappdata','gradle-home')){
        $new=[IO.Directory]::CreateDirectory($base+'\'+$name);Ordinary $new
    }
    $phase='PROBE_COPY'
    SaveBytes ($base+'\cwd\probe.groovy') $probeBytes;$scriptCopies++;$probeBytes=$null
    $arguments=@('-Xms32m','-Xmx256m',('-Duser.home='+$base+'\user-home'),
        ('-Djava.io.tmpdir='+$base+'\tmp'),'-cp',[string]::Join(';',$classpath),
        'groovy.ui.GroovyMain',($base+'\cwd\probe.groovy'))
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
        $phase='PROBE_VALIDATE'
        if(-not$started-or-not$exited-or$exitCode-ne0-or-not$captureComplete-or$stderr.Length-ne0){throw 'CHILD_RESULT_OR_STREAM'}
        $json=$utf.GetString($stdout)|ConvertFrom-Json -AsHashtable
        $null=$utf.GetString($stderr)
        ExactKeys $json @('mode','synthetic','runtimeReady','groovyVersion','javaVersion','javaRuntimeVersion','candidateInvocation','types')
foreach($k in @('mode','groovyVersion','javaVersion','javaRuntimeVersion')){if($json[$k]-isnot[string]){throw 'PROBE_STRING'}}
        if($json.mode-cne'EXACT_GROOVY_GRADLE_API_PROBE'-or$json.synthetic-isnot[bool]-or-not$json.synthetic-or
           $json.runtimeReady-isnot[bool]-or$json.runtimeReady-or$json.groovyVersion-cne'3.0.24'-or
           $json.javaVersion-cne'17.0.18'-or$json.javaRuntimeVersion-cne'17.0.18+8'-or
           ($json.candidateInvocation-isnot[int]-and$json.candidateInvocation-isnot[long])-or
           $json.candidateInvocation-ne0-or$json.types-isnot[array]-or$json.types.Count-ne3){throw 'PROBE_SCHEMA'}
        $names=@('org.gradle.api.Project','org.gradle.api.plugins.ExtensionContainer','org.gradle.api.plugins.ExtraPropertiesExtension')
        for($i=0;$i-lt3;$i++){
            $item=$json.types[$i];ExactKeys $item @('className','isInterface','codeSource')
            if($item.className-isnot[string]-or$item.className-cne$names[$i]-or$item.isInterface-isnot[bool]-or-not$item.isInterface-or$item.codeSource-isnot[string]){throw 'TYPE_SCHEMA'}
            $u=[Uri]::new($item.codeSource,[UriKind]::Absolute)
            if(-not$u.IsFile-or$u.Query-ne''-or$u.Fragment-ne''-or$u.Host-ne''){throw 'CODE_SOURCE_URI'}
            # URI decoding maps text only; no file/URL access or new lookup.
            $matched=$false
            foreach($path in $classpath){if([StringComparer]::OrdinalIgnoreCase.Equals($u.LocalPath,$path)){$matched=$true;break}}
            if(-not$matched){throw 'CODE_SOURCE_OUTSIDE_LIST'}
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
    mode='SINGLE_JVM_API_PROBE_RECEIPT';Result=$(if($success){'PASS_API_SCOPE_ONLY'}else{'FAIL'});
    Root=$base;BaseVerified=$baseVerified;AuthorityVerified=$authorityVerified;
    TSVRead=$tsvRead;ProbeSourceRead=$probeRead;ProbeCopies=$scriptCopies;
    ExternalGet=$externalGet;ExternalRead=$externalRead;ExternalBytes=$externalBytes;
    ProcessStartAttempt=$processAttempts;Started=$started;Exited=$exited;ExitCode=$exitCode;
    Timeout=$timedOut;KillAttempt=$killAttempted;CleanupComplete=$cleanupComplete;
    CaptureComplete=$captureComplete;StdoutComplete=$(if($out){$out.EOF-and-not$out.Gap-and-not$out.Overflow}else{$false});
    StderrComplete=$(if($err){$err.EOF-and-not$err.Gap-and-not$err.Overflow}else{$false});
    StdoutBytes=$stdout.Length;StdoutSHA256=$outHash;StderrBytes=$stderr.Length;StderrSHA256=$errHash;
    ProbeSchemaChecked=$schemaChecked;Failure=$first;SecondaryFailure=$secondary;
    ExplicitInterfaceRequest=$(if($schemaChecked){3}else{'UNKNOWN'});ProbeScript=$(if($started){1}else{0});
    ImplicitClassloads='NOT_MEASURED';CandidateInvocation=0;FourteenCaseInvocation=0;RuntimeReady=$false;
    OSHardCutoff='NOT_PROVEN';OSFileNetworkIsolation='NOT_PROVEN';ParentToolStderr='UNKNOWN';
    RealBinding='NOT_CHECKED';LibraryExtensionTiming='NOT_CHECKED';SDKCompatibility='NOT_CHECKED'
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
        ProcessStartAttempt=$processAttempts;CandidateInvocation=0;RuntimeReady=$false;
        OSHardCutoff='NOT_PROVEN';OSFileNetworkIsolation='NOT_PROVEN'}|ConvertTo-Json -Compress
    if($utf.GetByteCount($receipt)-gt4096-or$receipt.Length-gt4096){throw 'SMALL_RECEIPT_LIMIT'}
    [Console]::WriteLine($receipt)
}catch{Fail 'SMALL_RECEIPT_EMIT' $_.Exception;StopFirst}
if($success){exit 0}else{exit 1}
