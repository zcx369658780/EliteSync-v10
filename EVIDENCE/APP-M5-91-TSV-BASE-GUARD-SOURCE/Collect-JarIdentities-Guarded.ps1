$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY'
$root='D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib'
$utf=[Text.UTF8Encoding]::new($false,$true)
$phase='PRECHECK';$sourceRead=0;$gets=0;$reads=0
[long]$total=0
$rows=[Collections.Generic.List[string]]::new()
$first=$null;$firstPhase=$null;$secondary=[Collections.Generic.List[string]]::new()
$manifestBytes=$null;$manifestHash=$null;$manifestSaved=$false
$baseVerified=$false
function Ordinary($f) {
    if(($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'REPARSE'}
    $d=if($f-is[IO.FileInfo]){$f.Directory}else{$f}
    while($null-ne$d){
        if($d-isnot[IO.DirectoryInfo]-or($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'ANCESTOR'}
        $d=$d.Parent
    }
}
function Digest([byte[]]$bytes,[string]$prefix) {
    $sha=$null;$e=$null;$ep=$null;$value=$null
    try {
        $script:phase=$prefix+'_HASH_CREATE'
        $sha=[Security.Cryptography.SHA256]::Create()
        $script:phase=$prefix+'_HASH_COMPUTE'
        $value=[BitConverter]::ToString($sha.ComputeHash($bytes)).Replace('-','')
    } catch {$e=$_.Exception;$ep=$script:phase}
    if($null-ne$sha){
        try {$script:phase=$prefix+'_HASH_DISPOSE';$sha.Dispose()}
        catch {if($null-eq$e){$e=$_.Exception;$ep=$script:phase}}
    }
    if($null-ne$e){$script:phase=$ep;throw $e}
    return $value
}
try {
    if((Get-Location).Path-ne'D:\EliteSync-v10'-or(git branch --show-current)-ne'main'-or(git rev-parse HEAD)-ne'cf8bfaa4a03b8c9a682105617b185141904413be'){throw 'AUTHORITY'}
    $s=Get-Content -LiteralPath ($base+'\workspace-before.json') -Raw|ConvertFrom-Json
    $now=@(git -c core.quotepath=false status --porcelain=v1|ForEach-Object{$_.Substring(3)})
    if($s.Count-ne248-or$s.Paths.Count-ne248-or@($s.Paths|Where-Object{$_ -notin $now}).Count-ne0){throw 'SNAPSHOT'}
    Ordinary (Get-Item -LiteralPath $base)
    $baseVerified=$true
    foreach($name in @('jar-identities.tsv','identity-summary.md')){
        if(Test-Path -LiteralPath ($base+'\'+$name)){throw 'TARGET_EXISTS'}
    }
    $phase='INVENTORY_META'
    $f=Get-Item -LiteralPath 'D:\EliteSync-v10\EVIDENCE\APP-M5-88-EXACT-LIB-JAR-NAME-INVENTORY\jar-name-inventory.md'
    if($f-isnot[IO.FileInfo]-or$f.Length-ne7957){throw 'INVENTORY_SIZE'}
    Ordinary $f
    $phase='INVENTORY_READ';$sourceRead++
    $b=[IO.File]::ReadAllBytes($f.FullName)
    if($b.Length-ne7957){throw 'INVENTORY_READ_SIZE'}
    $hash=Digest $b 'INVENTORY'
    if($hash-ne'93B5275470685BED1EF322AE2970030BBC06343699FC243F70E2E1F067A6028A'){throw 'INVENTORY_HASH'}
    $phase='INVENTORY_UTF8';$text=$utf.GetString($b);$b=$null
    $phase='INVENTORY_PARSE'
    $fence=([string][char]96)*3
    $pattern='(?ms)^'+[regex]::Escape($fence)+'text\n(.*?)\n'+[regex]::Escape($fence)+'$'
    $matches=[regex]::Matches($text,$pattern)
    if($matches.Count-ne1){throw 'INVENTORY_FENCE'}
    $names=$matches[0].Groups[1].Value.Split([char]10)
    if($names.Length-ne188){throw 'INVENTORY_COUNT'}
    for($i=0;$i-lt188;$i++){
        $name=$names[$i]
        if($name-notmatch'^[A-Za-z0-9_-][A-Za-z0-9_.-]*\.jar$'-or$name.Contains('..')){throw 'INVENTORY_NAME'}
        if($i-gt0-and[StringComparer]::Ordinal.Compare($names[$i-1],$name)-ge0){throw 'INVENTORY_ORDER'}
    }
    $text=$null
    for($i=0;$i-lt188;$i++){
        $phase='JAR_'+($i+1)+'_META';$gets++
        $f=Get-Item -LiteralPath ($root+'\'+$names[$i])
        if($f-isnot[IO.FileInfo]){throw 'JAR_FILE'}
        Ordinary $f
        if($f.Length-gt268435456-or($total+$f.Length)-gt1073741824){throw 'JAR_SIZE_LIMIT'}
        $phase='JAR_'+($i+1)+'_READ';$reads++
        $b=[IO.File]::ReadAllBytes($f.FullName)
        if($b.Length-ne$f.Length-or$b.Length-gt268435456-or($total+$b.Length)-gt1073741824){throw 'JAR_READ_SIZE'}
        $hash=Digest $b ('JAR_'+($i+1))
        $rows.Add($names[$i]+[char]9+$b.Length+[char]9+$hash)
        $total+=$b.Length;$b=$null
    }
} catch {$first=$_.Exception;$firstPhase=$phase;$b=$null}
# Save one complete/partial record, without continuing failed jar work.
if($baseVerified){
$stream=$null;$writeError=$null;$writePhase=$null
try {
    $phase='TSV_PREPARE'
    $crlf=([string][char]13)+[char]10
    $tsv='Name'+[char]9+'Bytes'+[char]9+'SHA256'+$crlf
    if($rows.Count-gt0){$tsv+=[string]::Join($crlf,$rows)+$crlf}
    $record=$utf.GetBytes($tsv)
    if($record.Length-gt24576-or$tsv.Length-gt24000){throw 'TSV_LIMIT'}
    $manifestBytes=$record.Length
    $manifestHash=Digest $record 'TSV'
    $phase='TSV_CREATE'
    $stream=[IO.File]::Open($base+'\jar-identities.tsv',[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
    $phase='TSV_WRITE';$stream.Write($record,0,$record.Length)
    $phase='TSV_FLUSH';$stream.Flush()
} catch {$writeError=$_.Exception;$writePhase=$phase}
if($null-ne$stream){
    try {$phase='TSV_DISPOSE';$stream.Dispose()}
    catch {if($null-eq$writeError){$writeError=$_.Exception;$writePhase=$phase}else{$secondary.Add('TSV_DISPOSE_AFTER_WRITE_FAILURE')}}
}
if($null-ne$writeError){
    if($null-eq$first){$first=$writeError;$firstPhase=$writePhase}else{$secondary.Add($writePhase)}
}else{$manifestSaved=$true}
}else{
    $manifestSaved=$false
    if($null-eq$first){
        $first=[InvalidOperationException]::new('BASE_NOT_VERIFIED')
        $firstPhase='BASE_NOT_VERIFIED'
    }
    $secondary.Add('TSV_NOT_EXECUTED_BASE_NOT_VERIFIED')
}
$failure=if($null-ne$first){[ordered]@{Phase=$firstPhase;Tag=$first.Message;Class=$first.GetType().FullName}}else{$null}
$success=($null-eq$first-and$rows.Count-eq188-and$manifestSaved)
$phase='STDOUT_SERIALIZE'
$o=[ordered]@{Result=$(if($success){'A_OK'}else{'A_FAIL'});Root=$root;InventoryRead=$sourceRead;InventoryHash='93B5275470685BED1EF322AE2970030BBC06343699FC243F70E2E1F067A6028A';DirectoryEnumeration=0;GetItemAttempted=$gets;ReadAttempted=$reads;Completed=$rows.Count;Remaining=(188-$rows.Count);TotalJarBytes=$total;JarOrdinaryFullAncestors=$true;TSVBytes=$manifestBytes;TSVSHA256=$manifestHash;TSVSaved=$manifestSaved;Failure=$failure;SecondaryFailure=$secondary;Branch='main';HEAD='cf8bfaa4a03b8c9a682105617b185141904413be';Old=248;MissingOld=$(if($null-ne$s){@($s.Paths|Where-Object{$_ -notin $now}).Count}else{$null});Status=$now.Count;JVM=0;HTTP=0}|ConvertTo-Json -Depth 4 -Compress
if($utf.GetByteCount($o)-gt4096-or$o.Length-gt4096){throw 'STDOUT_LIMIT'}
[Console]::WriteLine($o)
if($success){exit 0}else{exit 1}
