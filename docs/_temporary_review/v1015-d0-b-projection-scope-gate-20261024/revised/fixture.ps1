param([string]$RunId)
$ErrorActionPreference='Stop';$root=$PSScriptRoot;$phase='writer-fixture';$suiteClock=[Diagnostics.Stopwatch]::StartNew();$started=(Get-Date -Format o)
$document=Get-Content -Raw -LiteralPath (Join-Path $root 'receipt-schema.json') | ConvertFrom-Json
$script:receiptAllowedKeys=@($document.allowedKeys);$script:receiptTypeSchemas=[ordered]@{}
foreach($s in $document.typeSchemas.PSObject.Properties){$m=[ordered]@{};foreach($p in $s.Value.PSObject.Properties){$m[$p.Name]=[string]$p.Value};$script:receiptTypeSchemas[$s.Name]=$m}
$control=Get-Content -Raw -LiteralPath (Join-Path (Split-Path $root) 'v1015-sandbox-scoped-git-trust-conditional-producer-20261024\runtime-session\input\control.json') | ConvertFrom-Json
$control.runId=$RunId;$script:enforceRunId=$true
. (Join-Path $root 'receipt_writer.ps1')
$cases=[Collections.Generic.List[object]]::new();$expected=Get-Content -Raw -LiteralPath (Join-Path $root 'fixture-plan.json') | ConvertFrom-Json
function Fresh([string]$name){
 if($suiteClock.Elapsed.TotalSeconds -gt 50){throw 'INTERNAL_SUITE_DEADLINE'}
 $script:currentCase=$name;$script:outputRoot=Join-Path (Join-Path $root 'fixture-output') $name
 if(Test-Path -LiteralPath $outputRoot){throw 'CASE_OUTPUT_PREEXISTED'};[void][IO.Directory]::CreateDirectory($outputRoot)
}
function Template([string]$schemaName){
 $v=[ordered]@{};foreach($k in $script:receiptTypeSchemas[$schemaName].Keys){switch($script:receiptTypeSchemas[$schemaName][$k]){'string' {$v[$k]='fixture'} 'nullable-string' {$v[$k]=$null} 'boolean' {$v[$k]=$true} 'integer' {$v[$k]=[long]1} 'number' {$v[$k]=[decimal]'0.125'} 'array' {$v[$k]=@()} 'object' {$v[$k]=@{}}}}
 $v.runId=$control.runId;$v.time=Get-Date -Format o
 if($schemaName -eq 'framework-identity.json'){$v.head=$control.frameworkHead;$v.root=$control.gitTrustRoot;$v.gitDir=$control.gitTrustRoot+'/.git'}
 if($schemaName -eq 'sdk-preflight.json'){
  $v.actualFlutter=[ordered]@{frameworkVersion=$control.framework;engineRevision=$control.engine;dartSdkVersion=$control.dart;frameworkRevision=$control.frameworkHead}
  $v.sourceGitHead=$control.frameworkHead;$v.sealedKeys=53;$v.baseSealedKeys=50;$v.jarPreexisted=$false;$v.producerRuns=0;$v.resolveRuns=0;$v.hostSdkStandalone=$false
 }
 return $v
}
function Positive([string]$id,[string]$receipt,$value){
 Fresh $id;Write-Receipt $receipt $value
 $path=Join-Path $outputRoot $receipt;$raw=[IO.File]::ReadAllBytes($path);$parsed=(New-ReceiptParser).DeserializeObject([Text.UTF8Encoding]::new($false,$true).GetString($raw));Assert-ReceiptSchema $receipt $parsed
 if(@(Get-ChildItem -LiteralPath $outputRoot -Filter '*.tmp').Count -ne 0){throw 'SUCCESS_LEFT_PARTIAL_FILE'}
 $cases.Add([ordered]@{case=$id;kind='positive';passed=$true;receipt=$receipt;sha256=(Receipt-Hash $raw);bytes=$raw.Length})
}
function Negative([string]$id,[scriptblock]$make,[string]$receipt='framework-identity.json'){
 Fresh $id;$rejected=$false
 try{$v=& $make;Write-Receipt $receipt $v}catch{if($_.Exception.Message -cne 'RECEIPT_SERIALIZATION_FAILURE'){throw};$rejected=$true}
 $fail=@(Get-ChildItem -LiteralPath $outputRoot -Filter 'receipt-failure-*.json' -File)
 if(-not $rejected -or $fail.Count -ne 1 -or (Test-Path -LiteralPath (Join-Path $outputRoot $receipt))){throw 'NEGATIVE_NOT_CONCLUSIVE'}
 $raw=[IO.File]::ReadAllBytes($fail[0].FullName);$v=(New-ReceiptParser).DeserializeObject([Text.UTF8Encoding]::new($false,$true).GetString($raw));Assert-ReceiptSchema $fail[0].Name $v
 if($v.runId -cne $control.runId -or $v.ready -ne $false){throw 'FAILURE_NOT_BOUND_OR_READY'}
 $cases.Add([ordered]@{case=$id;kind='negative';passed=$true;receipt=$fail[0].Name;sha256=(Receipt-Hash $raw);bytes=$raw.Length;readyDenied=$true;independentFailureValid=$true})
}
$passed=$false;$failureType=$null;$failureCode=$null
try{
 foreach($schemaName in @($script:receiptTypeSchemas.Keys | Where-Object {$_ -notin @('failure.json','phase.json')})){
  $name=switch($schemaName){'native-started.json' {'java-version.started.json'} 'native-result.json' {'dart-version.result.json'} default {$schemaName}}
  Positive ('schema-'+$schemaName.Replace('.json','')) $name (Template $schemaName)
 }
 $lines=@(Get-Content -LiteralPath (Join-Path (Split-Path $root) 'v1015-sandbox-scoped-git-trust-conditional-producer-20261024\runtime-session\output\framework-head.stdout.txt') | Where-Object {$_.Trim()})
 $v=Template 'framework-identity.json';$v.root=$lines[0];$v.gitDir=$lines[1];$v.head=$lines[2];Positive 'actual-identity-field-categories' 'framework-identity.json' $v
 $v=Get-Content -Raw -LiteralPath (Join-Path (Split-Path $root) 'v1015-sandbox-scoped-git-trust-conditional-producer-20261024\runtime-session\output\dart-version.result.json') | ConvertFrom-Json
 $v.runId=$RunId;Positive 'observed-decimal-native-result' 'dart-version.result.json' (Copy-ReceiptValue $v)
 $v=Template 'framework-identity.json';$v.root='C:\'+[char]0x8def+[char]0x5f84+"\quote`"\tab`t";Positive 'unicode-windows-path' 'framework-identity.json' $v
 $read=(New-ReceiptParser).DeserializeObject([IO.File]::ReadAllText((Join-Path $outputRoot 'framework-identity.json'),[Text.Encoding]::UTF8));if($read.root -cne $v.root){throw 'UNICODE_CONTENT_MISMATCH'}
 Fresh 'phase-receipt';Write-Phase 'seed-copy' 'START';$path=Join-Path $outputRoot 'phase-01-seed-copy.json';$raw=[IO.File]::ReadAllBytes($path)
 $v=(New-ReceiptParser).DeserializeObject([Text.Encoding]::UTF8.GetString($raw));Assert-ReceiptSchema 'phase-01-seed-copy.json' $v
 if($v.phase -cne 'seed-copy' -or $v.status -cne 'START'){throw 'PHASE_CONTENT_MISMATCH'}
 $cases.Add([ordered]@{case='phase-receipt';kind='positive';passed=$true;receipt='phase-01-seed-copy.json';sha256=(Receipt-Hash $raw);bytes=$raw.Length})
 Negative 'missing-required' {$v=Template 'framework-identity.json';$v.Remove('head');$v}
 Negative 'required-null' {$v=Template 'framework-identity.json';$v.root=$null;$v}
 Negative 'wrong-scalar' {$v=Template 'framework-identity.json';$v.root=7;$v}
 Negative 'object-rejected' {$v=Template 'framework-identity.json';$v.root=[Diagnostics.ProcessStartInfo]::new();$v}
 Negative 'scriptblock-rejected' {$v=Template 'framework-identity.json';$v.root={Get-Date};$v}
 Negative 'deep-object-rejected' {$v=Template 'framework-identity.json';$x='end';foreach($i in 1..8){$x=@{root=$x}};$v.root=$x;$v}
 Negative 'cycle-rejected' {$v=Template 'framework-identity.json';$x=@{};$x.root=$x;$v.root=$x;$v}
 Negative 'array-limit' {$v=Template 'native-started.json';$v.command=@(1..129 | ForEach-Object {'x'});$v} 'java-version.started.json'
 Negative 'string-limit' {$v=Template 'framework-identity.json';$v.root='x'*32769;$v}
 Negative 'byte-limit' {$v=Template 'native-started.json';$v.command=@(1..30 | ForEach-Object {'x'*5000});$v} 'java-version.started.json'
 Negative 'invalid-unicode' {$v=Template 'framework-identity.json';$v.root=[string][char]0xD800;$v}
 Negative 'nonfinite-value' {$v=Template 'native-result.json';$v.seconds=[double]::NaN;$v} 'dart-version.result.json'
 Negative 'unknown-key' {$v=Template 'framework-identity.json';$v['undeclared']='discard';$v}
 Negative 'sdk-nested-type' {$v=Template 'sdk-preflight.json';$v.actualFlutter.frameworkRevision=123;$v} 'sdk-preflight.json'
 Negative 'sdk-incomplete' {$v=Template 'sdk-preflight.json';$v.actualFlutter.Remove('engineRevision');$v} 'sdk-preflight.json'
 Negative 'sdk-ready-false' {$v=Template 'sdk-preflight.json';$v.passed=$false;$v} 'sdk-preflight.json'
 Negative 'foreign-run-id' {$v=Template 'framework-identity.json';$v.runId='foreign';$v}
 Fresh 'serializer-fallback';function ConvertTo-Json {throw 'SYNTHETIC_SERIALIZER_FAILURE'}
 $denied=$false;try{Write-Receipt 'framework-identity.json' (Template 'framework-identity.json')}catch{$denied=$_.Exception.Message -ceq 'RECEIPT_SERIALIZATION_FAILURE'}
 Remove-Item Function:\ConvertTo-Json
 $fail=@(Get-ChildItem -LiteralPath $outputRoot -Filter 'receipt-failure-*.json' -File);if(-not $denied -or $fail.Count -ne 1){throw 'INDEPENDENT_SERIALIZER_FALLBACK_NOT_PROVEN'}
 $raw=[IO.File]::ReadAllBytes($fail[0].FullName);$v=(New-ReceiptParser).DeserializeObject([Text.Encoding]::UTF8.GetString($raw));Assert-ReceiptSchema $fail[0].Name $v
 $cases.Add([ordered]@{case='serializer-fallback';kind='negative';passed=$true;receipt=$fail[0].Name;sha256=(Receipt-Hash $raw);bytes=$raw.Length;readyDenied=$true;independentFailureValid=$true})
 Fresh 'invalid-json-serializer';function ConvertTo-Json {return '{broken'}
 $denied=$false;try{Write-Receipt 'framework-identity.json' (Template 'framework-identity.json')}catch{$denied=$_.Exception.Message -ceq 'RECEIPT_SERIALIZATION_FAILURE'}
 Remove-Item Function:\ConvertTo-Json
 $fail=@(Get-ChildItem -LiteralPath $outputRoot -Filter 'receipt-failure-*.json' -File);if(-not $denied -or $fail.Count -ne 1 -or (Test-Path -LiteralPath (Join-Path $outputRoot 'framework-identity.json'))){throw 'INVALID_JSON_NOT_REFUSED'}
 $raw=[IO.File]::ReadAllBytes($fail[0].FullName);Assert-ReceiptSchema $fail[0].Name ((New-ReceiptParser).DeserializeObject([Text.Encoding]::UTF8.GetString($raw)))
 $cases.Add([ordered]@{case='invalid-json-serializer';kind='negative';passed=$true;receipt=$fail[0].Name;sha256=(Receipt-Hash $raw);bytes=$raw.Length;readyDenied=$true;independentFailureValid=$true})
 Fresh 'no-overwrite';Write-Receipt 'framework-identity.json' (Template 'framework-identity.json');$normal=Join-Path $outputRoot 'framework-identity.json';$hash=Receipt-Hash ([IO.File]::ReadAllBytes($normal))
 $denied=$false;try{Write-Receipt 'framework-identity.json' (Template 'framework-identity.json')}catch{$denied=$_.Exception.Message -ceq 'RECEIPT_SERIALIZATION_FAILURE'}
 if(-not $denied -or (Receipt-Hash ([IO.File]::ReadAllBytes($normal))) -cne $hash){throw 'OVERWRITE_NOT_REFUSED'}
 $fail=@(Get-ChildItem -LiteralPath $outputRoot -Filter 'receipt-failure-*.json' -File);if($fail.Count -ne 1){throw 'OVERWRITE_FAILURE_RECEIPT_MISSING'}
 $raw=[IO.File]::ReadAllBytes($fail[0].FullName);Assert-ReceiptSchema $fail[0].Name ((New-ReceiptParser).DeserializeObject([Text.Encoding]::UTF8.GetString($raw)))
 $cases.Add([ordered]@{case='no-overwrite';kind='negative';passed=$true;receipt=$fail[0].Name;sha256=(Receipt-Hash $raw);bytes=$raw.Length;readyDenied=$true;independentFailureValid=$true;originalHash=$hash})
 $actualNames=@($cases | ForEach-Object {$_.case})
 if(($actualNames -join '|') -cne ($expected.cases -join '|')){throw 'EXPECTED_ACTUAL_CASE_SET_MISMATCH'}
 $passed=$true
}catch{$failureType=$_.Exception.GetType().FullName;$failureCode=$_.Exception.Message}
$body=[ordered]@{runId=$RunId;passed=$passed;expectedCount=$expected.count;actualCount=$cases.Count;cases=$cases.ToArray();started=$started;finished=(Get-Date -Format o);childElapsedSeconds=$suiteClock.Elapsed.TotalSeconds;currentCase=$script:currentCase;failureType=$failureType;failureCode=$failureCode;runtimeProcessesStarted=0;jobsStarted=0}
$json=Write-Aggregate $body;$temp=Join-Path $root 'fixture-body.tmp';$final=Join-Path $root 'fixture-body.json'
[IO.File]::WriteAllText($temp,$json,[Text.UTF8Encoding]::new($false,$true));$read=[IO.File]::ReadAllBytes($temp)
if((Receipt-Hash ([Text.Encoding]::UTF8.GetBytes($json))) -cne (Receipt-Hash $read)){throw 'BODY_HASH_MISMATCH'}
[void](New-ReceiptParser).DeserializeObject([Text.Encoding]::UTF8.GetString($read));[IO.File]::Move($temp,$final)
if(-not $passed){exit 1};exit 0
