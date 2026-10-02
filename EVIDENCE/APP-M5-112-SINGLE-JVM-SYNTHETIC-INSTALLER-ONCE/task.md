# M112 单次任务｜首失败预算关闭

Task ID: APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE
Status: CLOSED_AFTER_FAILURE_PENDING_REVIEW。A1成功/Invocation1失败/B0关闭；等待父独立审查，不自接受。下文正式发单为原授权记录；不得借旧source适配行政2/2、旧M93/M100/M117等已耗额度。
基线：D:\EliteSync-v10/main/4f5bea7e558bc15d24ce45d3e4704ac658906a38；执行接续01a0fa2b-c777-77b2-ba66-00ed7c5260f5；父发布/终裁01a0fa1a-f62d-7091-a4a6-e5f60446b0f6。非作者独立审查另行进行。
父明确SOURCEONLY ACCEPT：派生launcher21223bytes/SHA256 1BD80E130718971FFF7FCA259CDE107A6439575D4C7D5F6D62D6F27EAFB9C7D2；结合独立审查01a0fab0-94cf-723b-a9cb-583b76f7a0d4。原M118仍冻结，旧HEAD阻塞已由仅两字面替换派生源码解决，原准备记录只作历史。授权来源是父会话本轮明确消息，执行者不自接受源码。
Owner已委托既定方向内测试授权；父明确接受本范围局限：不是OS强制文件/网络隔离或硬截止，implicit JVM/native loads未计量，失败ExternalBytes是已成功核hash的累计而非全部实际已读字节。不得冒強证明、安全设置变化或扩范围。

## 唯一行为与严格写集

最多一个JVM验证固定M84 installer/M85 harness的14 synthetic case及严格流/计数/schema/hash。成功也仅PASS_SYNTHETIC_14CASE_SCOPE_ONLY/runtimeReadyfalse；非真实binding/SDK/build/设备/发布证明。
本task新增放行前缀包含当前全部可执行命令，下方原准备计划中的PROPOSED/旧命令/待定B文本均仅历史，不能执行。准确189外部闭包、14case、字段类型/限制与首失败保持原准备task来源表；不更换Java/InputRoot/M84/M85。
写集：本M112目录task.md/authority/workspace-before/preparation-result(历史不改)/native-receipts.json<=262144/verification-B.json<=8192/result.md<=16384/父review.md<=16384；stdout.bin/stderr.bin各<=32768/probe-wrapper.json<=8192/cwd/harness.groovy14402及原六owned目录；CURRENT/TASK_CURRENT/当前路线状态维护。不改冻结原件或派生launcher源码，不写其他路径。当前正式放行只修改authority的Status/OwnerAuthorization两值且保持14键。
A仅本仓：原22冻结的20非bin各metadata/read1，2旧binmetadata/祖先1正文0，派生launchermetadata/read1，M90 TSV1，frozen-sync.json1、authority1、workspace1；这是新的preflight预算，不读外部。读数含失败尝试。
Invocation内部与被审源码一致：authority/workspace/TSV各Read1；189准确外部各GetItem/ReadAllBytes<=1，256MiB/文件、1GiB累计，成功合计115118021bytes；installer父preflightRead1、harnessSourceRead/copy1；ProcessStartAttempt<=1（异常/false亦耗1）；child installerRead1/parseClass1、install<=14，失败调用也计。30s单调wait+2s cleanup，最多一次kill；无重跑。
B仅Invocation全面成功后：raw stdout/stderr/wrapper各metadata/read1，原native-receipts metadata/read1；与原小回执16实际键严格比较，写verification-B一次CreateNew。B不启动进程、候选或依赖。
A/B完整命令及输出各<=8192UTF8bytes/字符；原smallreceipt<=4096。Invocation原工具展示预算16384tokens，原输出物理上限由launcher控制；若原工具截断，失败关闭且不据显示证明完整。
本轮前置普通行政纠错上限2次，已用1：首次JS编排因嵌入换行转义解析失败，工具未调用/文件未写/A-Invocation-B0。只作用于首次A前同范围文档/命令编写，不能重发A/Invocation/B或JVM。适配任务旧2/2不重置。科学/进程预算独立：A1→Invocation1→全面成功B1；一开始调用即计attempt，任何失败关闭剩余，包括工具错误/输出截断/回执缺失。不修补、不换会话、不补跑。

## 小回执与原tool证据保存

caller保留每次exec_command及必要同session write_stdin的原结构化返回，不把会话轮询当新Invocation。native-receipts.json容器Schema=M112_ORIGINAL_TOOL_RECEIPTS_V1，A.calls保留A原返回；Invocation.calls保留唯一启动及同session续取原返回，Invocation.ExitCode是真实最后退出码，SmallReceiptText为各原output按序直接拼接（原空白保留）。不从wrapper合成小回执。只有唯一Invocation exit0、输出为单个JSON且Result=PASS_SYNTHETIC_14CASE_SCOPE_ONLY才进入B。
caller每阶段结束原JSON串化保存，最多4次证据保存，UTF8<=262144；写入失败停止、不重发科学调用。小回执源是launcher SMALL_RECEIPT真实Console输出，B检查trim后长度并strict JSON解析16键，原文本不改。B之后可把B.calls附入同容器；不覆盖raw三输出或B证据。
完整原工具命令身份是以下逐字文本UTF8 SHA-256（包含代码块内末尾LF）；保存task内容与实际exec.cmd逐字一致。Invocation文本不含末尾LF。caller运行工具时login=false，cwd D:\EliteSync-v10；启动A/B治理宿主不构成额外JVM，工具失败也耗该阶段1。Invoke需本次写入/外部/JVM工具许可，B需verification写入工具许可；权限拒绝同样首失败，不重试。
无论PASS或首FAIL，保存原错误/partial/attempt/UNKNOWN与结果及精确备份增量，停止供父独立审查；不commit/push、清理或自动后继。

## 固定A（仅首次调用一次）
```powershell
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE'
$head='4f5bea7e558bc15d24ce45d3e4704ac658906a38'
$utf=[Text.UTF8Encoding]::new($false,$true)
function Demand($ok,$tag){if(-not $ok){throw $tag}}
function LocalBytes($path,$limit){
$f=Get-Item -LiteralPath $path -Force
Demand ($f -is [IO.FileInfo] -and $f.Length-le$limit) 'LOCAL_METADATA'
$d=$f.Directory
Demand (($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'FILE_REPARSE'
while($null-ne$d){Demand (($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'ANCESTOR_REPARSE';$d=$d.Parent}
$b=[IO.File]::ReadAllBytes($f.FullName)
Demand ($b.Length-eq$f.Length -and $b.Length-le$limit) 'LOCAL_BYTES'
return ,$b
}
function Hash($b){[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([byte[]]$b))}
Demand ((Get-Location).Path-ceq'D:\EliteSync-v10') 'CWD'
Demand ((git branch --show-current)-ceq'main' -and (git rev-parse HEAD)-ceq$head) 'GIT_BASE'
git diff --cached --quiet --exit-code
Demand ($LASTEXITCODE-eq0) 'INDEX_NOT_EMPTY'
$a=$utf.GetString((LocalBytes ($base+'\runtime-authority.json') 8192))|ConvertFrom-Json -AsHashtable
$expected=[ordered]@{
TaskId='APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE';Status='ISSUED';JVM=1
OwnerAuthorization='OWNER_DELEGATED_SINGLE_JVM_SYNTHETIC_TEST_AUTHORIZED'
ProbeSha256='7251ACF92C24055EEFC5E299DEF620D09263C3F5C4DFA80E7DB3A763702E5CCD';ProbeBytes=14402
ProbePath='D:\EliteSync-v10\EVIDENCE\APP-M5-85-SYNTHETIC-INSTALLER-HARNESS-SOURCE\VerifyLocalExtraRecipeInstaller.groovy'
ManifestPath='D:\EliteSync-v10\EVIDENCE\APP-M5-90-EXACT-188-JAR-IDENTITY\jar-identities.tsv'
InputRoot='D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib'
OutputRoot=$base;JavaPath='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe'
InstallerPath='D:\EliteSync-v10\EVIDENCE\APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE\LocalExtraRecipeInstaller.groovy'
InstallerSha256='7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37';InstallerBytes=6141
}
Demand ($a.Count-eq14) 'AUTHORITY_KEYS'
foreach($k in $expected.Keys){
Demand ($a.ContainsKey($k)) 'AUTHORITY_KEY'
if($expected[$k]-is[string]){Demand ($a[$k]-is[string] -and $a[$k]-ceq$expected[$k]) 'AUTHORITY_STRING'}
else{Demand (($a[$k]-is[int]-or$a[$k]-is[long])-and$a[$k]-eq$expected[$k]) 'AUTHORITY_INTEGER'}
}
$s=$utf.GetString((LocalBytes ($base+'\workspace-before.json') 262144))|ConvertFrom-Json -AsHashtable
Demand ($s.Branch-ceq'main'-and$s.HEAD-ceq$head-and$s.Count-eq$s.Paths.Count) 'WORKSPACE'
$now=@(git -c core.quotepath=false --no-optional-locks status --porcelain=v1|ForEach-Object{$_.Substring(3)})
Demand (@($s.Paths|Where-Object{$_ -notin $now}).Count-eq0) 'WORKSPACE_MEMBERS'
foreach($name in @('stdout.bin','stderr.bin','probe-wrapper.json','cwd','tmp','user-home','appdata','localappdata','gradle-home','native-receipts.json','verification-B.json','result.md','review.md')){
Demand (-not(Test-Path -LiteralPath ($base+'\'+$name))) 'OUTPUT_EXISTS'
}
$frozen=$utf.GetString((LocalBytes 'D:\EliteSync-v10\EVIDENCE\DOT-MIGRATION-GITHUB-SYNC-20261002\frozen-sync.json' 32768))|ConvertFrom-Json
Demand ($frozen.Count-eq22) 'FROZEN_COUNT'
$body=0;$metaOnly=0
foreach($e in $frozen){
$p='D:\EliteSync-v10\'+$e.path.Replace('/','\')
if($e.provenance-ceq'PRIOR_ACCEPTED_NO_BODY_READ'){
$f=Get-Item -LiteralPath $p -Force
Demand ($f-is[IO.FileInfo]-and$f.Length-eq$e.bytes-and($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'BIN_IDENTITY'
$d=$f.Directory;while($null-ne$d){Demand (($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'BIN_ANCESTOR';$d=$d.Parent};$metaOnly++
}else{$b=LocalBytes $p 131072;Demand ($b.Length-eq$e.bytes-and(Hash $b)-ceq$e.hash) 'FROZEN_HASH';$body++}
}
Demand ($body-eq20-and$metaOnly-eq2) 'FROZEN_BUDGET'
$b=LocalBytes 'D:\EliteSync-v10\EVIDENCE\DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002\Invoke-SyntheticInstallerTest-Baseline.ps1' 24576
Demand ($b.Length-eq21223-and(Hash $b)-ceq'1BD80E130718971FFF7FCA259CDE107A6439575D4C7D5F6D62D6F27EAFB9C7D2') 'NEW_LAUNCHER_IDENTITY'
$b=LocalBytes $a.ManifestPath 24576
Demand ($b.Length-eq19534-and(Hash $b)-ceq'E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80') 'MANIFEST_IDENTITY'
$o=[ordered]@{Phase='A';Result='PASS_LOCAL_PREFLIGHT_ONLY';HEAD=$head;FrozenBody=20;OldBinBody=0;NewLauncherQualified=$true;ExternalRead=0;JVM=0}
[Console]::WriteLine(($o|ConvertTo-Json -Compress))
```

## 固定Invocation（唯一一次）

```powershell
& 'D:\EliteSync-v10\EVIDENCE\DOT-M112-LAUNCHER-BASELINE-ADAPTATION-20261002\Invoke-SyntheticInstallerTest-Baseline.ps1'
```

## 固定B（全面成功后仅一次）

```powershell
[Console]::OutputEncoding=[Text.UTF8Encoding]::new($false)
$ErrorActionPreference='Stop'
$base='D:\EliteSync-v10\EVIDENCE\APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE'
$utf=[Text.UTF8Encoding]::new($false,$true)
function Demand($ok,$tag){if(-not$ok){throw $tag}}
function Hash($b){[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([byte[]]$b))}
function Read($name,$limit){
$f=Get-Item -LiteralPath ($base+'\'+$name) -Force
Demand ($f-is[IO.FileInfo]-and$f.Length-le$limit-and($f.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'B_METADATA'
$d=$f.Directory;while($null-ne$d){Demand (($d.Attributes-band[IO.FileAttributes]::ReparsePoint)-eq0) 'B_ANCESTOR';$d=$d.Parent}
$b=[IO.File]::ReadAllBytes($f.FullName);Demand ($b.Length-eq$f.Length-and$b.Length-le$limit) 'B_READ';return ,$b
}
function Keys($m,$keys){Demand ($m-is[Collections.IDictionary]-and$m.Count-eq$keys.Count) 'B_KEYS';foreach($k in $keys){Demand ($m.Contains($k)) 'B_KEY'}}
function Integer($m,$k,$v){Demand (($m[$k]-is[int]-or$m[$k]-is[long])-and$m[$k]-eq$v) ('B_INT_'+$k)}
function Boolean($m,$k,$v){Demand ($m[$k]-is[bool]-and$m[$k]-eq$v) ('B_BOOL_'+$k)}
function StringValue($m,$k,$v){Demand ($m[$k]-is[string]-and$m[$k]-ceq$v) ('B_STRING_'+$k)}
Demand (-not(Test-Path -LiteralPath ($base+'\verification-B.json'))) 'B_OUTPUT_EXISTS'
$stdout=Read 'stdout.bin' 32768;$stderr=Read 'stderr.bin' 32768;$wb=Read 'probe-wrapper.json' 8192
$native=Read 'native-receipts.json' 262144
$n=$utf.GetString($native)|ConvertFrom-Json -AsHashtable
Demand ($n.Invocation.ExitCode-eq0-and$n.Invocation.SmallReceiptText-is[string]) 'B_NATIVE_INVOCATION'
$small=$n.Invocation.SmallReceiptText
Demand ($utf.GetByteCount($small.Trim())-le4096-and$small.Trim().Length-le4096) 'B_SMALL_LIMIT'
$r=$small|ConvertFrom-Json -AsHashtable
Keys $r @('Result','Root','WrapperBytes','WrapperSHA256','StdoutBytes','StdoutSHA256','StderrBytes','StderrSHA256','ProcessStartAttempt','CandidateInvocation','CandidateParseClassLoad','CandidateSourceRead','FourteenCaseInvocation','RuntimeReady','OSHardCutoff','OSFileNetworkIsolation')
$w=$utf.GetString($wb)|ConvertFrom-Json -AsHashtable
StringValue $w 'mode' 'SINGLE_JVM_SYNTHETIC_TEST_RECEIPT'
StringValue $w 'Result' 'PASS_SYNTHETIC_14CASE_SCOPE_ONLY'
StringValue $w 'Root' $base
foreach($k in @('BaseVerified','AuthorityVerified','Started','Exited','CleanupComplete','CaptureComplete','StdoutComplete','StderrComplete','TestSchemaChecked')){Boolean $w $k $true}
foreach($k in @('Timeout','RuntimeReady')){Boolean $w $k $false}
foreach($k in @('TSVRead','HarnessSourceRead','HarnessCopies','LocalInstallerPreflightRead','ProcessStartAttempt','CandidateParseClassLoad','CandidateSourceRead','HarnessScript')){Integer $w $k 1}
foreach($k in @('ExternalGet','ExternalRead')){Integer $w $k 189}
Integer $w 'ExternalBytes' 115118021
foreach($k in @('ExitCode','KillAttempt','StderrBytes')){Integer $w $k 0}
foreach($k in @('CandidateInvocation','FourteenCaseInvocation')){Integer $w $k 14}
Demand ($null-eq$w.Failure-and$w.SecondaryFailure-is[array]-and$w.SecondaryFailure.Count-eq0) 'B_FAILURE_FIELDS'
Integer $w 'StdoutBytes' $stdout.Length
StringValue $w 'StdoutSHA256' (Hash $stdout)
StringValue $w 'StderrSHA256' (Hash $stderr)
Demand ($stderr.Length-eq0) 'B_STDERR_NONEMPTY'
foreach($k in @('OSHardCutoff','OSFileNetworkIsolation')){StringValue $w $k 'NOT_PROVEN'}
StringValue $w 'ParentToolStderr' 'UNKNOWN'
StringValue $w 'ImplicitClassloads' 'NOT_MEASURED'
StringValue $w 'VersionProvenance' 'SAME_INPUT_IDENTITIES_NOT_REMEASURED'
foreach($k in @('RealBinding','Hook','LibraryExtensionTiming','SDKCompatibility')){StringValue $w $k 'NOT_CHECKED'}
StringValue $w 'ExplicitInterfaceRequest' 'NOT_APPLICABLE'
foreach($k in @('Result','Root','StdoutSHA256','StderrSHA256','OSHardCutoff','OSFileNetworkIsolation')){StringValue $r $k $w[$k]}
foreach($k in @('StdoutBytes','StderrBytes','ProcessStartAttempt','CandidateInvocation','CandidateParseClassLoad','CandidateSourceRead','FourteenCaseInvocation')){Integer $r $k $w[$k]}
Integer $r 'WrapperBytes' $wb.Length
StringValue $r 'WrapperSHA256' (Hash $wb)
Boolean $r 'RuntimeReady' $false
$j=$utf.GetString($stdout)|ConvertFrom-Json -AsHashtable
$null=$utf.GetString($stderr)
Keys $j @('mode','synthetic','runtimeReady','sourceRead','parseClassLoad','executedCase','candidateInvocation','cases','realBinding','hook','libraryExtensionTiming','sdkCompatibility')
StringValue $j 'mode' 'TEST_SOURCE_SPEC';Boolean $j 'synthetic' $true;Boolean $j 'runtimeReady' $false
Integer $j 'sourceRead' 1;Integer $j 'parseClassLoad' 1;Integer $j 'executedCase' 14;Integer $j 'candidateInvocation' 14
foreach($k in @('realBinding','hook','libraryExtensionTiming','sdkCompatibility')){StringValue $j $k 'NOT_CHECKED'}
$names=@('EMPTY_OWN','MIXED_OWN','SAME_OWN','LATE_VALUE_CONFLICT','LATE_TYPE_CONFLICT','RAW_GSTRING_PATH','RAW_NULL_TARGET','RAW_NONMAP','MISSING_KEY','GSTRING_VALUE','WRONG_MODE','TARGET_MISMATCH','THIRD_SET_FAIL','POST_READ_FAIL')
Demand ($j.cases-is[array]-and$j.cases.Count-eq14) 'B_CASE_COUNT'
for($i=0;$i-lt14;$i++){Keys $j.cases[$i] @('caseId','result','invocationCount');StringValue $j.cases[$i] 'caseId' $names[$i];StringValue $j.cases[$i] 'result' 'PASS';Integer $j.cases[$i] 'invocationCount' 1}
$o=[ordered]@{Phase='B';Result='PASS_SYNTHETIC_14CASE_SCOPE_ONLY';WrapperBytes=$wb.Length;WrapperSHA256=(Hash $wb);StdoutBytes=$stdout.Length;StdoutSHA256=(Hash $stdout);StderrBytes=$stderr.Length;StderrSHA256=(Hash $stderr);CandidateInvocation=14;RuntimeReady=$false}
$bytes=$utf.GetBytes(($o|ConvertTo-Json -Compress))
Demand ($bytes.Length-le8192) 'B_RESULT_LIMIT'
$f=$null
try{$f=[IO.File]::Open($base+'\verification-B.json',[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None);$f.Write($bytes,0,$bytes.Length);$f.Flush()}finally{if($null-ne$f){$f.Dispose()}}
[Console]::WriteLine($utf.GetString($bytes))
```

## 命令身份与准备自检

A: 4539bytes/4539chars/SHA256 7D64D397F99CE969B4DCC122634C06A27D0B11A419933C26A96B539C68EBD573
Invocation: 119bytes/119chars/SHA256 4328452671995896FEF4CDCFC82C278D035AAF9A7BDACA6A6CD44994478336BE
B: 5889bytes/5889chars/SHA256 6FD9B0826317E862756AC5978F97DA6579CBFF40A2E0D9BBD2DF449E2751E54D
字段逐项与真实wrapper/smallreceipt核对；authority仅两值更改；输出槽检查由A固定文本完成。

---

## 下方完整原准备记录（历史；已解决HEAD阻塞及旧NOT_ISSUED命令不再生效）

# M112｜单次合成 installer 准备与运行计划

Task ID: APP-M5-112-SINGLE-JVM-SYNTHETIC-INSTALLER-ONCE
Status: PREPARED_BLOCKED_NOT_ISSUED。本次仅文档准备，未获父dot正式运行放行；runtime预算未消费，也不可消费。
风险：LEVEL 2；作者/执行者01a0fa2b-c777-77b2-ba66-00ed7c5260f5；发布/放行/终裁：父dot01a0fa1a-f62d-7091-a4a6-e5f60446b0f6；非作者Sol/high独立审查另行安排，不以作者自检或NO_FINDINGS替代终裁。
准备基线：D:\EliteSync-v10 / main / HEAD4f5bea7e558bc15d24ce45d3e4704ac658906a38。7旧排除原样保留。

## 授权与当前唯一目标

Owner：“好的，请开始同时推进这两个项目。如果遇到Owner决策（特指涉及到方向性的，一些简单的如测试数值授权的话你直接替我授权即可）就停下来。当你认为达到一个可以备份的进度时也请停下来，Github端已经很久没更新了，我们可以在这种备份节点整理下仓库避免太Dirty。”
父dot本轮明确仅允许准备task/14键authority/必要静态核对；未来运行由父dot正式放行。Owner简单测试授权委托不放宽安全/隐私/身份/生产/UAC门。
可验收行为：交付可立即实质审查的M112计划和安全封闭authority，明确准确来源、外部闭包、单次预算、命令、产物、失败计账和首停，暴露实际阻塞；不重跑旧预算、不补造技术路线。

## 关键阻塞：冻结launcher绑定旧HEAD

M118原接受launcher在121～122行两次硬编码cf8bfaa4a03b8c9a682105617b185141904413be；当前HEAD4f5bea7e558bc15d24ce45d3e4704ac658906a38不满足。即使authority转ISSUED，直接执行也会在WORKSPACE_IDENTITY停止，早于authorityVerified=true、TSV/189外部读取/JVM；base/authority拒绝路径不写stdout/stderr/wrapper。
不得回退Git、伪造workspace-before、修改冻结原源码、绕过guard或消耗一次运行验证已知失败。父dot需另行核定最窄SOURCEONLY工作区身份适配并独立接受新的准确launcher，或明确其他不绕门方案；这是源码范围缺口，本准备任务不修复。不改变Java/InputRoot/M84/M85路径。放行前必须把合法当前执行基线、准确新launcher路径/hash/bytes及Invocation命令落入本task，不能沿旧硬编码直接运行。

## 本次允许集与状态

准备读集：根入口/当前路线；M118准确handoff与work-review；冻结M84/M85/M118源码；本仓M90准确TSV；既读本地技能。只为静态文本核对，不运行parser/源码/版本探针。
准备写集：本目录task.md、runtime-authority.json、workspace-before.json、preparation-result.md；CURRENT.md/TASK_CURRENT.md新增当前准备入口；docs/architecture/ELITESYNC_V10_DOT_CURRENT_ROUTE_20261002.md更新M112准备状态/阻塞指针。旧根正文不改，旧任务证据不改。
本轮普通行政格式/路径纠错最多2次，只限上述文档同范围；每次计一次（批内相关文案一次），不增受保护读取/运行/源修改。当前未使用；用尽停止报告。真实冲突/身份差异/超范围不是行政纠错。
外部189身份访问0/JVM0/项目tests0/设备0/源码修改0。未commit/push，不启用自动化；NOT_READY/22冻结/历史拒绝保持。

## 固定来源与准确外部范围（未来新预算）

| 来源 | 本仓路径 | bytes / SHA-256 |
|---|---|---|
| M84 installer | EVIDENCE/APP-M5-84-RAW-OBJECT-INSTALLER-BOUNDARY-SOURCE/LocalExtraRecipeInstaller.groovy | 6141 / 7D45926082F323750A696439C4CE6E1791C89C9B867A26615DB1CB830888DB37 |
| M85 harness | EVIDENCE/APP-M5-85-SYNTHETIC-INSTALLER-HARNESS-SOURCE/VerifyLocalExtraRecipeInstaller.groovy | 14402 / 7251ACF92C24055EEFC5E299DEF620D09263C3F5C4DFA80E7DB3A763702E5CCD |
| M118原launcher（仅参考；已知HEAD阻塞） | EVIDENCE/APP-M5-117-SYNTHETIC-HARNESS-LAUNCHER-SOURCE/Invoke-SyntheticInstallerTest.ps1 | 21223 / 23A839B86195B28E3C86940BAF8B38A1610B8C2E007F18748EC7C32978FEC5FC |
| M90 TSV闭包 | EVIDENCE/APP-M5-90-EXACT-188-JAR-IDENTITY/jar-identities.tsv | 19534 / E405A9E6580DD1B63E534E09F3E24333E772E2C5FB78C39E8B4DB8128AC42D80 |

InputRoot = D:\GradleHome\wrapper\dists\gradle-8.14-all\dq61qkzrdg407zji6bwf6hwt7\gradle-8.14\lib
仅TSV188准确文件名按原顺序拼接InputRoot，每文件bytes/hash严格等于TSV；TSV是完整闭包，不另造副本或外部枚举。188总115067677bytes。
JavaPath = C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe
Java50344bytes / 5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B。
189合计115118021bytes。仅188classpath；generatedAPIcache不读、不入classpath；不读邻库、不通配/解压/SDK/cache/env/PATH/注册表搜索、不启动Gradle。

authority仅14键（没有扩展HEAD键）：TaskId,Status,JVM,OwnerAuthorization,ProbeSha256,ProbeBytes,ProbePath,ManifestPath,InputRoot,OutputRoot,JavaPath,InstallerPath,InstallerSha256,InstallerBytes。
本准备值Status=PREPARED_NOT_ISSUED，OwnerAuthorization=PENDING_PARENT_DOT_RUNTIME_RELEASE；JVM=1只表示拟议上限。父正式放行且来源阻塞闭合后才可改为Status=ISSUED、OwnerAuthorization=OWNER_DELEGATED_SINGLE_JVM_SYNTHETIC_TEST_AUTHORIZED。不得新增键或把当前authority称为有效运行许可。
workspace-before.json是准备时点普通路径快照，非原运行证据；正式运行前按实际批准基线新鲜核定并更新，不冒历史HEAD，不覆盖外来改动。

## 拟议A→Invocation→B：新预算，当前全部禁止执行

A（单次本地preflight治理调用）：核有效正式任务/14键authority/current main和批准HEAD/当前路径成员/普通祖先、准确M84/M85/新接受launcher/M90 bytes/hash及输出槽不存在；仅本仓。冻结20非bin最多各Read1/metadata1，2旧bin只metadata1不补正文；M90一次正文。新launcher与workspace/authority一并核定。不读取外部189。前门失败消耗A1/1，关闭Invocation/B，保留原错误；不重跑。
Invocation（单次治理tool调用，在当前pwsh宿主用&执行固定新接受launcher）：必须先完成上述SOURCEONLY阻塞闭合和父正式放行。原冻结命令仅用于定位，**不得执行**：
```powershell
& 'D:\EliteSync-v10\EVIDENCE\APP-M5-117-SYNTHETIC-HARNESS-LAUNCHER-SOURCE\Invoke-SyntheticInstallerTest.ps1'
```
合法替代launcher的准确命令目前NOT_ISSUED，不能通过临时替换文本、动态脚本或绕guard变成可运行。父核定新固定路径后更新本task唯一Invocation命令，未经准确命令发布不得执行。
Invocation内部拟议：authority/workspace各Read1；TSVRead1；189外部各GetItem1/ReadAllBytes1（含失败尝试，256MiB/文件、1GiB累计，成功应115118021bytes）；installer本地preflightRead1；harnessSourceRead1/ownedcopy1；ProcessStartAttempt<=1（异常/false也计1）；child installerRead1、parseClass1、install<=14，仅synthetic proxy。
子命令保持已接受参数：Java固定；-Xms32m -Xmx256m；task独立user.home/java.io.tmpdir；-cp为188准确分发jar；groovy.ui.GroovyMain、task\cwd\harness.groovy。无额外版本调用。环境清空后只白名单SystemRoot/windir/TEMP/TMP/USERPROFILE/HOME/APPDATA/LOCALAPPDATA/JAVA_HOME/GRADLE_USER_HOME，路径沿原launcher。父工具限额65536bytes/字符输出，保存原回执，不依赖截断显示作完整证据。
child单调等待30000ms；cleanup另2000ms；超时最多KillAttempt1；不是OS硬截止或网络文件沙箱证明。日志隐含加载NOT_MEASURED。
B（仅Invocation全面成功后，一次本地verifier治理调用）：stdout.bin、stderr.bin、probe-wrapper.json各metadata1/Read1；不读外部、不运行候选。命令固定为PowerShell内存SHA-256比较raw双流与wrapper/原smallreceipt，并strictUTF8解析原stdout12键/14case，与下列实际字段/类型/次数核对，写verification-B.json一次。B完整可执行文本须由父发布预算时固定；当前无补猜字段/动态发现许可。B失败计1/1并关闭，不重读或重跑。工具命令/结果限8192bytes字符；超限停止，不能借行政修正重复运行B。

## 14case与实际B成功断言

固定顺序：EMPTY_OWN, MIXED_OWN, SAME_OWN, LATE_VALUE_CONFLICT, LATE_TYPE_CONFLICT, RAW_GSTRING_PATH, RAW_NULL_TARGET, RAW_NONMAP, MISSING_KEY, GSTRING_VALUE, WRONG_MODE, TARGET_MISMATCH, THIRD_SET_FAIL, POST_READ_FAIL；各install.invoke最多1，先增加executedCase/candidateInvocation再invoke，抛异常也消耗本case。预期负向案例获准确phase/class/tag/count/state/read/set序列才PASS；THIRD_SET_FAIL保留2completed/3attempted及已有副作用，不retry/rollback；POST_READ_FAIL保留6/6。先失败退出，不继续其余case。
成功wrapper实际字段必须核：mode=SINGLE_JVM_SYNTHETIC_TEST_RECEIPT；Result=PASS_SYNTHETIC_14CASE_SCOPE_ONLY；BaseVerified/AuthorityVerified true；TSVRead1；ExternalGet/ExternalRead189，ExternalBytes115118021；HarnessSourceRead1、HarnessCopies1、LocalInstallerPreflightRead1；ProcessStartAttempt1/Started/Exited true/ExitCode0/Timeoutfalse/KillAttempt0；CaptureComplete/CleanupComplete/StdoutComplete/StderrComplete true；StderrBytes0及空字节hash；StdoutBytes/hash与原raw匹配；TestSchemaChecked true；Failure null、SecondaryFailure空；CandidateSourceRead1、CandidateParseClassLoad1、CandidateInvocation14、FourteenCaseInvocation14；RuntimeReady false。布尔/整数/字符串类型严格区分，不用旧SchemaChecked/ProbeSchemaChecked猜测。
原childstdout确切12键：mode,synthetic,runtimeReady,sourceRead,parseClassLoad,executedCase,candidateInvocation,cases,realBinding,hook,libraryExtensionTiming,sdkCompatibility。mode=TEST_SOURCE_SPEC、synthetic true、runtimeReady false、三个源/parse/count字段1/1/14/14；cases为14数组，每项仅caseId/result/invocationCount，顺序如上、PASS/1。四个限制字段NOT_CHECKED。
UNKNOWN不能改填0：若Started且schema未核，CandidateSourceRead/ParseClassLoad/Invocation/FourteenCaseInvocation按wrapper保留UNKNOWN，child失败JSON计数是原partial声明，不能冒已独立证明调用总数；StartAttempt异常亦保留实际attempt而非Started替代。

## 输出写集、首停与备份节点

正式运行拟议写集只本目录：stdout.bin<=32768、stderr.bin<=32768、probe-wrapper.json<=8192；cwd/harness.groovy14402bytes；cwd/tmp/user-home/appdata/localappdata/gradle-home专属目录；受控native-receipts.json<=262144、verification-B.json<=8192、result.md<=16384、非作者review.md<=16384。原smallreceipt<=4096bytes/字符。JVM隐含写入总量与OS隔离NOT_PROVEN，不宣称这些目录是强制沙箱；父放行应接受该限定风险或停门，不自行扩容/清理。出错部分槽保留，不覆盖、不删除，不因空stdout推断runtime成功。
首失败立即关闭剩余A/Invocation/B及case预算，保留native原错误/phase/tag/secondary/已完成读写/startattempt/partial；低层调用抛错或工具截断也计已尝试调用，无法取得回执标UNKNOWN，不自动重发。若base/authority/workspace失败则launcher不会写三原输出，原tool回执仍须保存，不伪造wrapper。若源码语义/运行需修复超范围，交父会话另立新门；旧失败不追认。
执行后非作者独立Sol/high只读审查task/authority/workspace/准确接受源码/原native/raw双流/wrapper/B（失败则只实际存在材料），父dot对原证LEVEL2终裁。包括ProcessStart/子流/cleanup/schema/count/hash/限制字段与旧预算隔离；任何PASS只限synthetic14case、runtimeReadyfalse。
受界接受或首失败证据/状态完整后到备份节点停止，交精确新增/改变文件清单及7保留排除；不push、不清理、不启动后继。当前只是准备候选，因HEAD源码阻塞尚未到运行验收备份节点。
## 首失败关闭记录

唯一Invocation原exit1/FAIL；B未调用，余预算全部关闭。原tool与执行时authority全文保留native-receipts.json，partial三产物原样保留，结果见result.md；不修复、不重跑、不换会话，无commit/push或后继。
