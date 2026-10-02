# SOURCEONLY: execute only after independent review and a new contract-test budget.
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\DOT-RAW-GSTRING-COUNT-CONTRACT-SOURCE-20261002'
$head='9ac66fc5566cd1fa5da23ed797cb6a08606e01d5'
$utf=[Text.UTF8Encoding]::new($false,$true)
$bytes=@{};$texts=@{};$identities=[Collections.Generic.List[object]]::new()
foreach($name in @('A.ps1','Invoke-RawGStringDiagnostic.ps1','DiagnoseRawGString.groovy','runtime-authority.json','workspace-before.json')){
    $file=Get-Item -LiteralPath ($base+'\'+$name)
    if($file-isnot[IO.FileInfo]-or$file.Length-gt65536-or($file.Attributes-band[IO.FileAttributes]::ReparsePoint)-ne0){throw 'CONTRACT_LOCAL_METADATA'}
    $bytes[$name]=[IO.File]::ReadAllBytes($file.FullName)
    if($bytes[$name].Length-ne$file.Length){throw 'CONTRACT_LOCAL_SIZE'}
    $texts[$name]=$utf.GetString($bytes[$name])
    $identities.Add(@{Name=$name;Bytes=$file.Length;SHA256=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes[$name]));ExplicitBodyReads=1})
}
function Assert($condition,[string]$tag){if(-not$condition){throw $tag}}
function ParseSource([string]$text){
    $tokens=$null;$errors=$null;$ast=[Management.Automation.Language.Parser]::ParseInput($text,[ref]$tokens,[ref]$errors)
    Assert ($errors.Count-eq0) 'CONTRACT_SOURCE_PARSE'
    return $ast
}
function PureExpression($ast,[string[]]$allowedCommands=@()){
    foreach($command in @($ast.FindAll({param($n)$n-is[Management.Automation.Language.CommandAst]},$true))){
        Assert ($command.GetCommandName()-cin$allowedCommands) 'CONTRACT_UNEXPECTED_COMMAND'
    }
    Assert (@($ast.FindAll({param($n)$n-is[Management.Automation.Language.InvokeMemberExpressionAst]},$true)).Count-eq0) 'CONTRACT_UNEXPECTED_METHOD'
    return [scriptblock]::Create($ast.Extent.Text)
}
function KeysHelper($ast){
    $fn=$ast.Find({param($n)$n-is[Management.Automation.Language.FunctionDefinitionAst]-and$n.Name-ceq'ExactKeys'},$true)
    Assert ($null-ne$fn) 'CONTRACT_HELPER_MISSING'
    Assert (@($fn.FindAll({param($n)$n-is[Management.Automation.Language.CommandAst]},$true)).Count-eq0) 'CONTRACT_HELPER_COMMAND'
    Assert ($fn.Extent.Text.Contains('$map.psbase.Count')) 'CONTRACT_HELPER_COUNT'
    foreach($call in @($fn.FindAll({param($n)$n-is[Management.Automation.Language.InvokeMemberExpressionAst]},$true))){
        Assert ($call.Expression.Extent.Text-ceq'$map'-and$call.Member.Extent.Text-ceq'Contains') 'CONTRACT_HELPER_METHOD'
    }
    return [scriptblock]::Create('param($map,[string[]]$keys)'+[char]10+$fn.Extent.Text+[char]10+'ExactKeys $map $keys')
}
function Guard($ast,[string]$tag,[string[]]$allowedCommands=@()){
    $matches=@($ast.FindAll({param($n)$n-is[Management.Automation.Language.IfStatementAst]-and$n.Extent.Text.Contains("throw '"+$tag+"'")},$true))
    # Select the smallest containing if, excluding the surrounding try/function.
    $guard=$matches|Sort-Object {$_.Extent.Text.Length}|Select-Object -First 1
    Assert ($null-ne$guard-and$guard.Clauses.Count-eq1) ('CONTRACT_GUARD_'+$tag)
    return PureExpression $guard.Clauses[0].Item1 $allowedCommands
}
$aAst=ParseSource $texts['A.ps1'];$wAst=ParseSource $texts['Invoke-RawGStringDiagnostic.ps1']
$aKeys=KeysHelper $aAst;$wKeys=KeysHelper $wAst
$aSnapshotGuard=Guard $aAst 'A_SNAPSHOT'
$wMembersGuard=Guard $wAst 'WORKSPACE_MEMBERS' @('Where-Object','Select-Object')
$wBindingGuard=Guard $wAst 'AUTHORITY_BINDING'
$wIdentityGuard=Guard $wAst 'AUTHORITY_SOURCE_IDENTITY'
$expectedAssignment=$aAst.Find({param($n)$n-is[Management.Automation.Language.AssignmentStatementAst]-and$n.Left.Extent.Text-ceq'$expected'},$true)
$specAssignment=$aAst.Find({param($n)$n-is[Management.Automation.Language.AssignmentStatementAst]-and$n.Left.Extent.Text-ceq'$spec'},$true)
$expected= & (PureExpression $expectedAssignment.Right)
$spec= & (PureExpression $specAssignment.Right)
$authority=$texts['runtime-authority.json']|ConvertFrom-Json -AsHashtable
$snapshot=$texts['workspace-before.json']|ConvertFrom-Json -AsHashtable
$probePath=$base+'\DiagnoseRawGString.groovy';$tsvPath=$expected.ManifestPath
$root=$expected.InputRoot;$java=$expected.JavaPath;$installerPath=$expected.InstallerPath
$schema=@('Branch','HEAD','Count','Paths')
function BothKeys($map,[string[]]$keys){& $aKeys $map $keys;& $wKeys $map $keys}
function CheckAuthority($map,[string]$status){
    BothKeys $map @($expected.Keys)
    foreach($key in $expected.Keys){
        $wanted=if($key-ceq'Status'){$status}else{$expected[$key]}
        if($wanted-is[string]){Assert ($map[$key]-is[string]-and$map[$key]-ceq$wanted) 'AUTH_STRING_OR_BINDING'}
        else{Assert (($map[$key]-is[int]-or$map[$key]-is[long])-and$map[$key]-eq$wanted) 'AUTH_INTEGER_TYPE'}
    }
    if($status-ceq'ISSUED'){
        $authority=$map
        Assert (-not(& $wBindingGuard)) 'WRAPPER_BINDING'
        Assert (-not(& $wIdentityGuard)) 'WRAPPER_SOURCE_IDENTITY'
    }
}
function CheckSnapshot($map){
    BothKeys $map $schema
    Assert ($map['Branch']-is[string]-and$map['Branch']-ceq'main'-and$map['HEAD']-is[string]-and$map['HEAD']-ceq$head) 'SNAPSHOT_IDENTITY'
    Assert (($map['Count']-is[int]-or$map['Count']-is[long])-and$map['Count']-ge0) 'SNAPSHOT_COUNT_TYPE'
    Assert ($map['Paths']-is[array]) 'SNAPSHOT_PATHS_TYPE'
    Assert ($map['Count']-eq$map['Paths'].Count) 'SNAPSHOT_COUNT_VALUE'
    $seen=[Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach($path in $map['Paths']){
        Assert ($path-is[string]-and$path.Length-gt0-and$path-notmatch'[\r\n\\]'-and-not$path.StartsWith('/')-and$path-notmatch'^[A-Za-z]:') 'SNAPSHOT_PATH_TYPE_OR_FORMAT'
        Assert ($seen.Add($path)) 'SNAPSHOT_DUPLICATE'
    }
    $snap=$map;$now=$map['Paths']
    Assert (-not(& $aSnapshotGuard)) 'A_SNAPSHOT_GUARD'
    Assert (-not(& $wMembersGuard)) 'WRAPPER_MEMBERS_GUARD'
}
function CloneMap($map){return ($map|ConvertTo-Json -Depth 6 -Compress|ConvertFrom-Json -AsHashtable)}
$results=[Collections.Generic.List[object]]::new()
function Case([string]$name,[scriptblock]$body,[string]$expectedFailure=''){
    $observed=''
    try{& $body}catch{$observed=$_.Exception.Message}
    if($expectedFailure-eq''){Assert ($observed-eq'') ('CASE_FAILURE_'+$name+':'+$observed)}
    else{Assert ($observed-ceq$expectedFailure) ('CASE_WRONG_FAILURE_'+$name+':'+$observed)}
    $results.Add(@{Case=$name;Result='PASS';ExpectedFailure=$expectedFailure})
}
$synthetic=[ordered]@{Branch='main';HEAD=$head;Count=21;Paths=@(1..21|ForEach-Object{'SYNTHETIC/path-'+$_})}
$synthetic=CloneMap $synthetic
Case 'BUSINESS_COUNT_21_KEYS_4' {BothKeys $synthetic $schema;Assert ($synthetic.psbase.Count-eq4-and$synthetic['Count']-eq21) 'COUNT_REGRESSION';CheckSnapshot $synthetic}
Case 'A_MISSING_KEY' {$m=CloneMap $synthetic;$m.Remove('HEAD');& $aKeys $m $schema} 'A_JSON_KEYS'
Case 'WRAPPER_MISSING_KEY' {$m=CloneMap $synthetic;$m.Remove('HEAD');& $wKeys $m $schema} 'JSON_KEYS'
Case 'A_EXTRA_KEY' {$m=CloneMap $synthetic;$m.Extra=$true;& $aKeys $m $schema} 'A_JSON_KEYS'
Case 'WRAPPER_EXTRA_KEY' {$m=CloneMap $synthetic;$m.Extra=$true;& $wKeys $m $schema} 'JSON_KEYS'
Case 'A_NOT_DICTIONARY' {& $aKeys 21 $schema} 'A_JSON_KEYS'
Case 'WRAPPER_NOT_DICTIONARY' {& $wKeys 21 $schema} 'JSON_KEYS'
Case 'AUTHORITY_SERIALIZED_PREPARED' {CheckAuthority $authority 'PREPARED_NOT_RELEASED'}
Case 'AUTHORITY_ISSUED_MEMORY_ONLY' {$m=CloneMap $authority;$m.Status='ISSUED';CheckAuthority $m 'ISSUED'}
Case 'AUTHORITY_WRONG_INTEGER_TYPE' {$m=CloneMap $authority;$m.JVM='1';CheckAuthority $m 'PREPARED_NOT_RELEASED'} 'AUTH_INTEGER_TYPE'
Case 'AUTHORITY_WRONG_IDENTITY' {$m=CloneMap $authority;$m.ProbeSha256='INVALID';CheckAuthority $m 'PREPARED_NOT_RELEASED'} 'AUTH_STRING_OR_BINDING'
Case 'AUTHORITY_WRONG_PATH' {$m=CloneMap $authority;$m.OutputRoot='SYNTHETIC_WRONG_PATH';CheckAuthority $m 'PREPARED_NOT_RELEASED'} 'AUTH_STRING_OR_BINDING'
Case 'SNAPSHOT_SERIALIZED_ACTUAL' {CheckSnapshot $snapshot}
Case 'SNAPSHOT_COUNT_STRING' {$m=CloneMap $synthetic;$m['Count']='21';CheckSnapshot $m} 'SNAPSHOT_COUNT_TYPE'
Case 'SNAPSHOT_PATH_ELEMENT_TYPE' {$m=CloneMap $synthetic;$m['Paths'][0]=21;CheckSnapshot $m} 'SNAPSHOT_PATH_TYPE_OR_FORMAT'
Case 'SNAPSHOT_COUNT_MISMATCH' {$m=CloneMap $synthetic;$m['Count']=4;CheckSnapshot $m} 'SNAPSHOT_COUNT_VALUE'
Case 'SNAPSHOT_DUPLICATE_PATH' {$m=CloneMap $synthetic;$m['Paths'][1]=$m['Paths'][0];CheckSnapshot $m} 'SNAPSHOT_DUPLICATE'
Case 'SNAPSHOT_WRONG_HEAD' {$m=CloneMap $synthetic;$m['HEAD']='SYNTHETIC_WRONG_HEAD';CheckSnapshot $m} 'SNAPSHOT_IDENTITY'
Case 'SERIALIZED_SOURCE_IDENTITIES_AND_PATHS' {
    Assert ($spec.Count-eq6) 'SPEC_ROWS'
    foreach($row in $spec){
        Assert ($row.psbase.Count-eq5-and$row['Path']-is[string]-and$row['Bytes']-is[int]-and$row['Limit']-is[int]) 'SPEC_FIELDS'
        $name=switch($row['Name']){'Harness'{'DiagnoseRawGString.groovy'};'Launcher'{'Invoke-RawGStringDiagnostic.ps1'};default{$null}}
        if($null-ne$name){
            Assert ($row['Path']-ceq($base+'\'+$name)-and$row['Bytes']-eq$bytes[$name].Length-and$row['Limit']-ge$bytes[$name].Length) 'SPEC_SOURCE_SIZE_PATH'
            Assert ($row['Hash']-ceq[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes[$name]))) 'SPEC_SOURCE_HASH'
        }
    }
    Assert ($authority.ProbeBytes-eq$bytes['DiagnoseRawGString.groovy'].Length-and$authority.ProbeSha256-ceq[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes['DiagnoseRawGString.groovy']))) 'AUTH_HARNESS_IDENTITY'
}
Case 'PERMISSION_GATE_AND_OUTPUT_ORDER' {
    $authority=$authority.Clone();$authority.Status='PREPARED_NOT_RELEASED'
    Assert (& $wBindingGuard) 'PREPARED_MUST_DENY_RUNTIME'
    $text=$texts['Invoke-RawGStringDiagnostic.ps1']
    Assert ($text.Contains("if(-not(`$script:baseVerified-and`$script:authorityVerified)){throw 'SAVE_PERMISSION'}")) 'SAVE_GATE'
    $verified=$text.IndexOf('$authorityVerified=$true')
    $members=$text.IndexOf("throw 'WORKSPACE_MEMBERS'")
    $marker=$text.IndexOf("SaveBytes (`$base+'\invocation-started.json')")
    $tsv=$text.IndexOf("`$phase='TSV'",$marker)
    Assert ($members-ge0-and$verified-gt$members-and$marker-gt$verified-and$tsv-gt$marker) 'OUTPUT_ORDER'
    Assert ($text.Contains("[IO.FileMode]::CreateNew")) 'CREATE_NEW_REQUIRED'
}
Assert ($results.Count-eq20) 'CASE_COUNT'
$receipt=@{Mode='PURE_PREPARATION_CONTRACT';Result='CONTRACT_PASS';Cases=$results;Identities=$identities;CandidateScriptExecution=0;InstallerRead=0;Groovy=0;JVM=0;ExternalRead=0;FileWrites=0;PermissionMode='READONLY_CONTRACT_NO_RUNTIME_RELEASE';NegativeTypeChecks='Preparation validator plus extracted pure consumer guards; not a claim that legacy consumers independently reject every bad scalar.'}|ConvertTo-Json -Depth 6 -Compress
Assert ($utf.GetByteCount($receipt)-le8192) 'CONTRACT_RECEIPT_LIMIT'
[Console]::WriteLine($receipt)
