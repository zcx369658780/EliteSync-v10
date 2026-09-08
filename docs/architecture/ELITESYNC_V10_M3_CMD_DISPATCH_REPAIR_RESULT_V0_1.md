# EliteSync v10｜批处理派发修复与无构建回归结果 v0.1

Status: `PROPOSED — DISPATCH REPAIR VERIFIED — SYNTHETIC ONLY — NO PUB / M3 / M2 AUTHORITY`

最终分类：**DISPATCH REPAIR VERIFIED — SYNTHETIC ONLY**。

本轮从005绑定源码确认批处理派发缺陷，完成最小构造修复，并用同一`System.Diagnostics.ProcessStartInfo`边界实际完成六组无构建回归。全部最终断言通过。没有运行Flutter、Dart、Java、Gradle、真实pub、M3或M2；模拟ENTERED不是工具启动或M3启动证据。

诊断ID=`M3-CMD-001`；日期2026-09-08（Asia/Shanghai）。Owner本轮选择GPT-5.6 Sol、Medium；这是任务允许的Owner选择。未修改模型配置、未调用辅助代理，也不额外推断完整宿主model ID或加载链。

## 1. 固定入口与来源绑定

实时main A=`580e48bbfd1e4bb7d47e63f557baa78a8c7cdfed`匹配。FIRST交接blob=`18485c95262051e43892436fb52413132c5ee626`。任务分支指向T=`bd0608906bb98850be42601092c9bd6b79b8b6ae`，任务blob=`a9b1a3c91ae50daa5476d175f0dbe5bff87e9fd0`；T唯一父A，且相对A只新增任务单。

A中`AGENTS.md`、005结果、005任务的绑定blob分别为`f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`、`f5927cc0a5672208eec457a65e89959a8bcac124`、`ee9a9a26406bb5a95059171250f552036721f06c`。005任务只采用§3/§4/§7/§8解释原合同；未读取CURRENT_CONTEXT、产品源码、README、FD02或旧仓库。

W5三个精确对象的开始hash匹配：

| 对象 | SHA-256 | 使用 |
| --- | --- | --- |
| `scripts/guest.ps1` | `701405E5B5FF33E542FB539C1EA7D6AC5D5F30B40B97EC2C998F0FF288BA52CB` | 审阅RunNative、cmd/pub/M3调用和错误分类 |
| `scripts/copy.ps1` | `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC` | 只核验hash；派发器无依赖，正文未读、未执行 |
| `evidence/result.json` | `04578F2DFD5294992E586CDB6F6A5185C94749A11D2F27000960C4FBD99DC928` | 核对005阶段和host解释 |

路径祖先均为普通目录、目标为普通文件，无reparse/link。新工作区`D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001`开始时不存在并独占创建；全部新写入仅在该目录。

## 2. 具体缺陷与证据强度

005源码使用：

```powershell
$pi=[Diagnostics.ProcessStartInfo]::new()
$pi.FileName=$exe
foreach($a in $arguments){if($a.Contains('"')){throw 'ARGUMENT_QUOTE_REJECTED'}}
$pi.Arguments=($arguments|ForEach-Object{'"'+$_+'"'}) -join ' '
```

pub调用把`@('/d','/s','/c','C:/M3/t/f/bin/flutter.bat pub get --offline')`交给该普通exe序列化器。因此`ProcessStartInfo.FileName`是`C:/Windows/System32/cmd.exe`，而`Arguments`实际变为：

```text
"/d" "/s" "/c" "C:/M3/t/f/bin/flutter.bat pub get --offline"
```

这不是cmd `/c`所需的单一外层命令字符串；批处理路径和三个参数也没有形成独立token。005保存的cmd语法错误、exit=1和无Flutter/pub输出与该源码事实一致。根因关联强度为`DIRECT SOURCE CONFIRMATION + MATCHING RUNTIME RESULT`，不是仅凭错误文本猜测。

`ProcessStartInfo.Arguments`是传给目标程序解析的单一字符串；这里没有显式Win32 `CreateProcess` P/Invoke。底层等价边界是`.FileName`选择应用、`.Arguments`形成命令行参数字符串；不能用抽象数组替代对最终字符串的核验。

## 3. 最小修复

保留原RunNative的ProcessStartInfo、stdout/stderr原始字节重定向、10/30分钟期限、`M3Job.StopChildren()`及exit传播。只增加批处理专用构造：固定`/d /s /v:off /c`，把批处理路径与每个支持参数分别引用，再以一层外部引号形成`/c`的单一命令字符串；该字符串直接赋给`ProcessStartInfo.Arguments`，不再经过普通exe的逐项引用。

完整可复用片段：

```powershell
function Assert-CmdAtom([string]$Value,[string]$Role){
 if($null -eq $Value){throw "CMD_${Role}_NULL_REJECTED"}
 if($Value.IndexOf([char]0)-ge 0 -or $Value -match '[\r\n"%&|<>^!()]'){
  throw "CMD_${Role}_UNSUPPORTED_CHAR_REJECTED"
 }
}
function Quote-CmdAtom([string]$Value,[string]$Role){Assert-CmdAtom $Value $Role;return '"'+$Value+'"'}
function New-BatchArguments([string]$BatchPath,[string[]]$ArgumentList){
 Assert-CmdAtom $BatchPath 'TARGET'
 $tokens=New-Object System.Collections.Generic.List[string]
 $tokens.Add((Quote-CmdAtom $BatchPath 'TARGET'))
 foreach($item in $ArgumentList){$tokens.Add((Quote-CmdAtom ([string]$item) 'ARGUMENT'))}
 return '/d /s /v:off /c "'+($tokens -join ' ')+'"'
}
function RunBatch($id,[string]$batchPath,[string[]]$argumentList,[DateTime]$limit,[string]$cwd){
 $serialized=New-BatchArguments $batchPath $argumentList
 $existedBefore=[IO.File]::Exists($batchPath)
 $exit=RunNative $id 'C:/Windows/System32/cmd.exe' @() $limit $cwd $serialized
 if(!$existedBefore){throw ('BATCH_TARGET_ABSENT '+$batchPath)}
 return $exit
}
```

接入时给RunNative增加末尾可选参数`$serializedArguments`：有值时直接设`$pi.Arguments=$serializedArguments`，无值时保留原普通exe构造；记录最终`arguments_string`。pub使用`@('pub','get','--offline')`，M3使用`@('build','aar','--no-debug','--no-profile','--no-pub')+@($defines)`。非零pub exit改记`PUB_COMMAND_FAILED__TOOL_ENTRY_REQUIRES_OUTPUT_EVIDENCE`，不再冒充`OFFLINE_PUB_INSUFFICIENT`；Process.Start异常和目标不存在分别保留为派发失败。

支持域仅为已知pub/M3参数及空格/等号合成参数。嵌入引号、CR/LF、NUL、`% & | < > ^ ! ( )`在纯内存构造阶段拒绝；未验证通用cmd转义。

## 4. 六组实际回归

编排进程为`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -Command`，未带ExecutionPolicy。目标为W/scratch中的自产`.cmd`，只执行echo/setlocal/exit。每次使用修复采用的同一`ProcessStartInfo.FileName=cmd.exe`和单一`Arguments`构造，均未超10秒；最终六组约0.19秒。

| 组 | PID | 最终Arguments要点 | ENTERED/参数/cwd | exit | 结论 |
| --- | ---: | --- | --- | ---: | --- |
| 1 pub形状 | 6324 | `/d /s /v:off /c ""...fake-ok.cmd" "pub" "get" "--offline""` | nonce及3参数精确 | 0 | PASS |
| 2 M3形状 | 26688 | `... "build" "aar" "--no-debug" "--no-profile" "--no-pub""` | nonce及5参数精确 | 0 | PASS；不计M3启动 |
| 3 空格路径/cwd | 28488 | 目标及cwd均含空格 | nonce、3参数、精确cwd | 0 | PASS |
| 4 合成define | 43724 | `"--dart-define=TEST_ONLY=value with space"` | 保持一个参数 | 0 | PASS；不是005配置 |
| 5 固定返回码 | 12516 | `...fake-exit-37.cmd" "fixed-exit""` | ENTERED | 37 | PASS；未被抹成0/派发失败 |
| 6 不存在目标 | 34436 | 精确W内missing目标 | 无ENTERED | 1 | PASS；`DISPATCH_FAILURE_TARGET_ABSENT` |

组1、2、3、4、5的stderr均0 bytes。组6 stdout=0 bytes、stderr=147 bytes，原始字节保留；本机默认编码解释为目标不是内部或外部命令。各组完整exe、Arguments、cwd、PID/创建时间、start/end、elapsed、exit、原始stdout/stderr和解码文本保存在`evidence/test-results.json`及分项记录。

危险字符纯内存覆盖六项，全部在进程创建前返回`CMD_ARGUMENT_UNSUPPORTED_CHAR_REJECTED`，没有执行注入字符串；记录只保留测试值SHA-256和拒绝结果。

## 5. 有限纠错、证据与保护

首轮在六次调用后因PowerShell 5.1泛型列表展开触发自有汇总`ArgumentException`，只保留原始输出，未把任何组记PASS。第一次纠错改为分项立即JSON序列化并避免泛型列表展开，不改派发构造。

第二轮确认现有目标均ENTERED、exit37保留、missing无ENTERED/exit1，但假目标错误使用`%%~1`和`%%CD%%`，使参数/cwd观测输出为字面量；t1–t4未通过。第二次且最后一次纠错仅改自产fixture为`%~1`和`%CD%`，派发构造与API边界不变。第三次执行取得上述最终六组PASS；没有为填预算重复成功结果。首轮完整命令文本未在纠错前另存，这是明确证据限制；首轮不参与PASS。第二轮结果和harness hash已保留。

本地证据根：`D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001`。最终`test-results.json` SHA-256=`8E9BE24817C722F6FC54E3F162F75D526DCFA4C2A398EBE5AA7E986BCC3BBC5A`；最终harness SHA-256=`6DF5B196F97F37B9D6F89B2C04463CC042D4E7B392AC7F633407E24D6F77E5F5`；可复用snippet SHA-256=`9CC6B72536D21119B01E2AEBA925DAD9A60D96C6DF97A931BDFCEFCD5485A894`；最小patch SHA-256=`4F0532B9A632B2747E90F6E80FC26C2F85AF5F884FB5C0DA8964DE8FE009350A`。JSON已反解析，路径保留盘符。最终编排PID 44732和六个已记录cmd PID均在退出后定点核对为不存活，不以进程名终止其他会话。

旧三个来源仅只读，结束hash必须与开始值匹配。未执行或修改旧guest/copy/result，未写原仓库、SDK/cache、用户配置或旧证据；未启动Sandbox、网络或外部服务。普通命令没有策略例外。

## 6. 未验证范围与停止条件

本结果只证明受限输入域中的批处理派发构造和返回码传播可用。没有证明Flutter/pub本体启动、离线依赖充分、Gradle可执行、M3成功、AAR存在或M2条件成立；005的M3未启动和AAR=NOT_CHECKED事实不变。

候选只新增本报告，唯一父为任务T。未修改CURRENT_CONTEXT、AGENTS、源码、历史报告或项目源；不自我接受、不更新main、不另发任务。README/FD02、旧仓库、默认index/受保护staged state及legal/Safety/no-processing/阶段边界保持。
