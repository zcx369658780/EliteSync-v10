# Task-owned JSON boundary. No environment, process, SDK or network operations.
function Copy-ReceiptValue($value,[int]$depth=0,[string]$fieldPath='$'){
 $script:lastReceiptField=$fieldPath;$script:lastReceiptType=if($null -eq $value){'NULL'}else{$value.GetType().FullName}
 if($depth -gt 6){throw 'RECEIPT_DEPTH_REJECTED'}
 if($null -eq $value){return $null}
 if($value -is [string]){if($value.Length -gt 32768){throw 'RECEIPT_STRING_TOO_LONG'};[void][Text.UTF8Encoding]::new($false,$true).GetByteCount($value);return [string]::new($value.ToCharArray())}
 if($value -is [bool]){return [bool]$value}
 if($value -is [byte] -or $value -is [int16] -or $value -is [uint16] -or $value -is [int32] -or $value -is [uint32] -or $value -is [int64]){return [long]$value}
 if($value -is [decimal]){return [decimal]$value}
 if($value -is [double]){if([double]::IsNaN($value) -or [double]::IsInfinity($value)){throw 'RECEIPT_NUMBER_REJECTED'};return [double]$value}
 if($value -is [Enum]){return [string]::new($value.ToString().ToCharArray())}
 if($value -is [Collections.IDictionary]){
  if($value.Count -gt 64){throw 'RECEIPT_MAP_TOO_LARGE'};$copy=[ordered]@{}
  foreach($key in @($value.Keys | Sort-Object)){
   if($key -isnot [string] -or $script:receiptAllowedKeys -cnotcontains $key){throw 'RECEIPT_UNKNOWN_KEY'}
   $copy[[string]::new($key.ToCharArray())]=Copy-ReceiptValue $value[$key] ($depth+1) ($fieldPath+'.'+$key)
  };return $copy
 }
 if($value -is [array]){
  if($value.Count -gt 128){throw 'RECEIPT_ARRAY_TOO_LARGE'};$copy=[Collections.Generic.List[object]]::new()
  foreach($item in $value){$copy.Add((Copy-ReceiptValue $item ($depth+1) ($fieldPath+'[]')))};return ,($copy.ToArray())
 }
 if($value -is [Management.Automation.PSCustomObject]){
  $copy=[ordered]@{};foreach($property in $value.PSObject.Properties){
   if($property.MemberType -ne 'NoteProperty' -or $script:receiptAllowedKeys -cnotcontains $property.Name){throw 'RECEIPT_OBJECT_PROPERTY_REJECTED'}
   $copy[$property.Name]=Copy-ReceiptValue $property.Value ($depth+1) ($fieldPath+'.'+$property.Name)
  };return $copy
 }
 throw 'RECEIPT_TYPE_REJECTED'
}
[void][Reflection.Assembly]::LoadWithPartialName('System.Web.Extensions')
function New-ReceiptParser{
 $parser=[Web.Script.Serialization.JavaScriptSerializer]::new();$parser.MaxJsonLength=131072;$parser.RecursionLimit=9;return $parser
}
function Receipt-Hash([byte[]]$bytes){
 $h=[Security.Cryptography.SHA256]::Create();try{return ([BitConverter]::ToString($h.ComputeHash($bytes))).Replace('-','').ToLowerInvariant()}finally{$h.Dispose()}
}
function Assert-ReceiptSchema([string]$name,$value){
 if($name -notmatch '^[a-z][a-z0-9.-]*\.json$' -or $name.Contains('..')){throw 'RECEIPT_NAME_REJECTED'}
 $schemaName=$name
 if($name -match '^(java-version|dart-version|gradle-version|git-trust-config|framework-head|flutter-version|producer|resolution)\.(started|result)\.json$'){$schemaName='native-'+$Matches[2]+'.json'}
 if($name -match '^phase-[0-9]{2}-[a-z-]+\.json$'){$schemaName='phase.json'}
 if($name -match '^receipt-failure-[a-f0-9]{32}\.json$'){$schemaName='failure.json'}
 if(-not $script:receiptTypeSchemas.Contains($schemaName)){throw 'RECEIPT_SCHEMA_NOT_FOUND'}
 $schema=$script:receiptTypeSchemas[$schemaName]
 if($value -isnot [Collections.IDictionary] -or $value.Count -ne $schema.Count){throw 'RECEIPT_FIELD_COUNT_REJECTED'}
 foreach($key in $schema.Keys){
  if(-not $value.ContainsKey($key)){throw 'RECEIPT_REQUIRED_FIELD_MISSING'}
  $v=$value[$key];$kind=$schema[$key];$ok=$false
  switch($kind){
   'string' {$ok=$v -is [string] -and $v.Length -gt 0}
   'nullable-string' {$ok=$null -eq $v -or $v -is [string]}
   'boolean' {$ok=$v -is [bool]}
   'integer' {$ok=$v -is [int] -or $v -is [long] -or $v -is [uint32]}
   'number' {$ok=$v -is [decimal] -or $v -is [double] -or $v -is [int] -or $v -is [long]}
   'array' {$ok=$v -is [array]}
   'object' {$ok=$v -is [Collections.IDictionary]}
  }
  if(-not $ok){$script:lastReceiptField='$.'+$key;$script:lastReceiptType=if($null -eq $v){'NULL'}else{$v.GetType().FullName};throw 'RECEIPT_FIELD_TYPE_REJECTED'}
 }
 if($value.ContainsKey('runId') -and $value.runId -cne $control.runId -and $script:enforceRunId){throw 'RECEIPT_RUN_BINDING_REJECTED'}
 if($name -eq 'framework-identity.json' -and ($value.head -notmatch '^[0-9a-f]{40}$' -or -not $value.passed -or -not $value.matchesFrozenHead)){throw 'FRAMEWORK_IDENTITY_VALUE_REJECTED'}
 if($schemaName -eq 'phase.json' -and $value.status -notin @('START','PASS','READY')){throw 'PHASE_STATUS_REJECTED'}
 if($name -eq 'sdk-preflight.json'){
  $version=$value.actualFlutter;$required=@('frameworkVersion','engineRevision','dartSdkVersion','frameworkRevision')
  if($version.Count -ne 4){throw 'SDK_VERSION_FIELD_COUNT_REJECTED'}
  foreach($k in $required){if(-not $version.ContainsKey($k) -or $version[$k] -isnot [string] -or -not $version[$k]){throw 'SDK_VERSION_SCHEMA_REJECTED'}}
  if(-not $value.passed -or -not $value.runtimeSdkViewReady -or -not $value.gitTrustPassed -or $value.jarPreexisted -or $value.sealedKeys -ne 53 -or $value.baseSealedKeys -ne 50 -or $value.producerRuns -ne 0 -or $value.resolveRuns -ne 0){throw 'SDK_READY_SEMANTICS_REJECTED'}
  if($script:enforceRunId -and ($version.frameworkVersion -cne $control.framework -or $version.engineRevision -cne $control.engine -or $version.dartSdkVersion -cne $control.dart -or $version.frameworkRevision -cne $control.frameworkHead)){throw 'SDK_READY_VERSION_BINDING_REJECTED'}
 }
 if($schemaName -eq 'failure.json'){
  if($value.status -cne 'RECEIPT_SERIALIZATION_FAILURE' -or $value.ready -ne $false -or $value.metadataSha256 -notmatch '^[a-f0-9]{64}$'){throw 'FAILURE_SCHEMA_REJECTED'}
  $material=$value.runId+'|'+$value.phase+'|'+$value.field+'|'+$value.inputType+'|'+$value.exceptionType
  if((Receipt-Hash ([Text.Encoding]::UTF8.GetBytes($material))) -cne $value.metadataSha256){throw 'FAILURE_METADATA_HASH_REJECTED'}
 }
}
function Escape-ReceiptString([string]$s){
 $b=[Text.StringBuilder]::new();[void]$b.Append('"')
 foreach($c in $s.ToCharArray()){$n=[int]$c;if($n -eq 34 -or $n -eq 92){[void]$b.Append('\');[void]$b.Append($c)}elseif($n -lt 32 -or $n -gt 126){[void]$b.Append(('\u{0:x4}' -f $n))}else{[void]$b.Append($c)}}
 [void]$b.Append('"');return $b.ToString()
}
function Write-AtomicReceiptJson([string]$name,[string]$json){
 $encoding=[Text.UTF8Encoding]::new($false,$true);$bytes=$encoding.GetBytes($json)
 if($bytes.Length -gt 131072){throw 'RECEIPT_BYTES_TOO_LARGE'}
 $parser=New-ReceiptParser;$before=$parser.DeserializeObject($json);Assert-ReceiptSchema $name $before
 $destination=Join-Path $outputRoot $name
 if([IO.File]::Exists($destination)){throw 'RECEIPT_EXISTS'}
 $temporary=Join-Path $outputRoot ('.receipt-'+[Guid]::NewGuid().ToString('N')+'.tmp')
 $stream=[IO.File]::Open($temporary,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
 try{$stream.Write($bytes,0,$bytes.Length);$stream.Flush($true)}finally{$stream.Dispose()}
 $readBytes=[IO.File]::ReadAllBytes($temporary);$roundtrip=$parser.DeserializeObject($encoding.GetString($readBytes));Assert-ReceiptSchema $name $roundtrip
 if((Receipt-Hash $bytes) -cne (Receipt-Hash $readBytes)){throw 'RECEIPT_READBACK_HASH_REJECTED'}
 [IO.File]::Move($temporary,$destination)
 if((Receipt-Hash ([IO.File]::ReadAllBytes($destination))) -cne (Receipt-Hash $bytes)){throw 'RECEIPT_PUBLISHED_HASH_REJECTED'}
}
function Write-IndependentFailure([string]$receipt,[string]$exceptionType){
 $id=[Guid]::NewGuid().ToString('N');$name='receipt-failure-'+$id+'.json'
 $run=[string]$control.runId;$phaseValue=if($null -ne $phase){[string]$phase}else{'fixture'}
 $field=if($script:lastReceiptField){$script:lastReceiptField}else{'$'};$type=if($script:lastReceiptType){$script:lastReceiptType}else{'UNKNOWN'}
 $material=$run+'|'+$phaseValue+'|'+$field+'|'+$type+'|'+$exceptionType;$hash=Receipt-Hash ([Text.Encoding]::UTF8.GetBytes($material))
 $fields=[ordered]@{runId=$run;phase=$phaseValue;field=$field;inputType=$type;exceptionType=$exceptionType;metadataSha256=$hash;receipt=$receipt;time=(Get-Date -Format o)}
 $pairs=[Collections.Generic.List[string]]::new();foreach($k in $fields.Keys){$pairs.Add((Escape-ReceiptString $k)+':'+(Escape-ReceiptString $fields[$k]))}
 $json='{"status":"RECEIPT_SERIALIZATION_FAILURE","ready":false,'+($pairs -join ',')+'}'
 # This path does not call Copy-ReceiptValue or ConvertTo-Json.
 Write-AtomicReceiptJson $name $json
}
function Write-Receipt([string]$name,$value){
 $script:lastReceiptField='$';$script:lastReceiptType=if($null -eq $value){'NULL'}else{$value.GetType().FullName}
 try{
  $clean=Copy-ReceiptValue $value
  $json=ConvertTo-Json -InputObject $clean -Depth 8 -Compress -ErrorAction Stop
  Write-AtomicReceiptJson $name $json
 }catch{
  Write-IndependentFailure $name $_.Exception.GetType().FullName
  throw 'RECEIPT_SERIALIZATION_FAILURE'
 }
}
$script:phaseSequence=0
function Write-Phase([string]$phase,[string]$status){
 $script:phaseSequence++;$name='phase-'+$script:phaseSequence.ToString('D2')+'-'+$phase+'.json'
 Write-Receipt $name ([ordered]@{runId=$control.runId;time=(Get-Date -Format o);phase=$phase;status=$status;sequence=[long]$script:phaseSequence})
}


# Aggregate-only boundary; this helper is loaded by the existing dot-source.
# It never calls Copy-ReceiptValue and never walks cases or other body fields.
function Write-Aggregate($body){
 if($null -eq $body -or $body.GetType() -ne [Collections.Specialized.OrderedDictionary]){throw 'AGGREGATE_BODY_TYPE_REJECTED'}
 $projected=[Collections.Generic.Dictionary[string,string]]::new([StringComparer]::Ordinal)
 foreach($fieldPath in @('$.started','$.finished')){
  if($fieldPath -ceq '$.started'){$fieldName='started'}
  elseif($fieldPath -ceq '$.finished'){$fieldName='finished'}
  else{throw 'AGGREGATE_PROJECTION_PATH_REJECTED'}
  if(-not $body.Contains($fieldName)){throw 'AGGREGATE_TIMESTAMP_REQUIRED'}
  $value=$body[$fieldName]
  if($null -eq $value -or $value.GetType() -ne [string]){throw 'AGGREGATE_TIMESTAMP_TYPE_REJECTED'}
  $baseValue=$value.PSObject.BaseObject
  if($null -eq $baseValue -or $baseValue.GetType() -ne [string]){throw 'AGGREGATE_TIMESTAMP_BASE_TYPE_REJECTED'}
  $projected.Add($fieldName,[string]::new($baseValue.ToCharArray()))
 }
 # Validate both before either replacement; .NET setters receive typed strings.
 $body.set_Item('started',$projected['started'])
 $body.set_Item('finished',$projected['finished'])
 return (New-ReceiptParser).Serialize($body)
}
