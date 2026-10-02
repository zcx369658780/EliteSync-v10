$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-NAMED-PREFLIGHT-SOURCE-20261002'
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
$currentName='Task';$stage='SETUP'
try{
$spec=@(
    [ordered]@{Name='Harness';Path=($base+'\DiagnoseRawGString.groovy');Bytes=9812;Limit=16384;Hash='0FDF72979FE6C6C174CAFDB8A8B7975AFA86D6F22743DD0520BAAE87EC4368EB'},
    [ordered]@{Name='Launcher';Path=($base+'\Invoke-RawGStringDiagnostic.ps1');Bytes=26085;Limit=32768;Hash='C0BD3944E42A85A4DAB29D2BC4EC509803018ECDF5932895DE3BEAA3BCA697ED'},
    [ordered]@{Name='Installer';Path='D:\EliteSync-v10\EVIDENCE\APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE\LocalExtraRecipeInstaller.groovy';Bytes=6141;Limit=6141;Hash='7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37'},
    [ordered]@{Name='TSV';Path='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv';Bytes=19534;Limit=19534;Hash='E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80'},
    [ordered]@{Name='Authority';Path=($base+'\runtime-authority.json');Bytes=-1;Limit=8192;Hash=''},
    [ordered]@{Name='Snapshot';Path=($base+'\workspace-before.json');Bytes=-1;Limit=262144;Hash=''}
)
foreach($item in $spec){
    $currentName=$item.Name;$stage='SPEC'
    if($item.Count-ne5-or@(@('Name','Path','Bytes','Limit','Hash')|Where-Object{-not$item.Contains($_)}).Count-ne0){throw 'A_SPEC_KEYS'}
    if($item.Name-isnot[string]-or$item.Path-isnot[string]-or$item.Hash-isnot[string]-or
       $item.Bytes-isnot[int]-or$item.Limit-isnot[int]-or$item.Limit-le0-or$item.Bytes-lt-1-or$item.Bytes-gt$item.Limit){throw 'A_SPEC_TYPES'}
    $stage='METADATA'
    $f=Get-Item -LiteralPath $item.Path
    if($f-isnot[IO.FileInfo]-or$f.Length-gt$item.Limit-or($item.Bytes-ge0-and$f.Length-ne$item.Bytes)){throw 'A_METADATA'}
    $stage='ORDINARY';Ordinary $f
    $stage='READ'
    [byte[]]$b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne$f.Length-or$b.Length-gt$item.Limit){throw 'A_READ_SIZE'}
    $stage='HASH';$hash=HashBytes $b
    if($item.Hash-ne''-and$hash-cne$item.Hash){throw 'A_HASH'}
    $data[$item.Name]=$b
    $reads.Add([ordered]@{Name=$item.Name;Bytes=$b.Length;SHA256=$hash;BodyReads=1})
}
function ExactKeys($map,[string[]]$keys){
    if($map-isnot[Collections.IDictionary]-or$map.Count-ne$keys.Count){throw 'A_JSON_KEYS'}
    foreach($k in $keys){if(-not$map.Contains($k)){throw 'A_JSON_KEY'}}
}
$currentName='Authority';$stage='AUTHORITY'
$auth=$utf.GetString($data.Authority)|ConvertFrom-Json -AsHashtable
ExactKeys $auth @('TaskId','Status','JVM','OwnerAuthorization','ProbeSha256','ProbeBytes','ProbePath','ManifestPath','InputRoot','OutputRoot','JavaPath','InstallerPath','InstallerSha256','InstallerBytes')
$expected=@{
    TaskId='DOT-RAW-GSTRING-NAMED-PREFLIGHT-SOURCE-20261002';Status='ISSUED';JVM=1;
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
$currentName='Snapshot';$stage='SNAPSHOT'
$snap=$utf.GetString($data.Snapshot)|ConvertFrom-Json -AsHashtable
ExactKeys $snap @('Branch','HEAD','Count','Paths')
if($snap.Branch-cne'main'-or$snap.HEAD-cne'9ac66fc5566cd1fa5da23ed797cb6a08606e01d5'-or$snap.Paths-isnot[array]-or$snap.Count-ne$snap.Paths.Count){throw 'A_SNAPSHOT'}
foreach($p in $snap.Paths){if($p-isnot[string]){throw 'A_PATH_TYPE'}}
if(@($snap.Paths|Select-Object -Unique).Count-ne$snap.Count){throw 'A_DUPLICATE_PATH'}
$currentName='Workspace';$stage='WORKSPACE'
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
    $currentName=$name;$stage='OUTPUT_ABSENCE'
    if(Test-Path -LiteralPath ($base+'\'+$name)){throw 'A_OUTPUT_EXISTS'}
}
[ordered]@{Result='A_READY';HEAD=$head;Branch=$branch;SnapshotPaths=$paths.Count;Reads=$reads;ExternalRead=0;JVM=0}|ConvertTo-Json -Depth 5 -Compress
}catch{
    throw [InvalidOperationException]::new(('A_FAILURE Name='+$currentName+' Stage='+$stage+' Tag='+$_.Exception.Message+' Class='+$_.Exception.GetType().FullName+' CompletedReads='+$reads.Count),$_.Exception)
}
