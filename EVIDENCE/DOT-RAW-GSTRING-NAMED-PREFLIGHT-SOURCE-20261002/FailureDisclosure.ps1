$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-NAMED-PREFLIGHT-SOURCE-20261002'
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
