# EliteSync v10｜采证守卫修正与策略查询完成任务 v0.1

Status: `TASK ONLY — COLLECTOR CORRECTION AND NORMAL POLICY QUERIES — NO POLICY CHANGE / HELPER EXECUTION / BUILD`
日期：2026-09-08（Asia/Singapore）。简体中文；模型由Owner选择，不改模型配置、不默认调用辅助代理。

## 1. 要完成的事与本轮差异

M3-POLICY-002候选ae3088597085787eb7ec7255670c5f1362de2ee6已由4d45d0e3ac1818274d6bae5c35567276efc330cb接受为有限观察记录，诊断目标没有通过。精确系统manifest正常导入成功，Name/Path符合原任务；执行者自行添加ModuleBase等于manifest所在目录的守卫，导致两项查询均未执行。该自有错误不是系统加载拒绝，也不支持修复Windows、改变策略或重新找Git。

本任务依据Owner已有普通限定诊断和自动续发权限，修正采证器并完成同一进程的scope与effective查询；无需新的Owner决定。不读取下一层依赖，不建立新的构建attempt。明确撤销错误ModuleBase附加条件，并以§5替代上轮“导入一次之后自有采证bug也只能停止”的局部预算。其余真实身份/路径/加载拒绝和无策略修改边界保留。

完成条件：两项查询分别实际执行并保留结果；若标准加载或查询真实失败，则保留原始错误及NOT_RUN/FAILED区别。报告入库不自动证明诊断目标或M3完成。不得在成功取证后另行增加同义诊断或全量复制步骤。

## 2. 固定入口与项目只读范围

仓库：zcx369658780/EliteSync-v10。先实时读取main，要求恰为A：
`4d45d0e3ac1818274d6bae5c35567276efc330cb`。
FIRST主动读取A中的`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob `18485c95262051e43892436fb52413132c5ee626`。
随后读取启动prompt绑定的本任务commit/blob，验证唯一父A及只新增本任务路径。旧startup不执行；main/task/blob失配停止依赖操作，不自行换基线。
其他仓库内容只限A中的AGENTS.md（blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`）和`docs/architecture/ELITESYNC_V10_M3_POWERSHELL_MODULE_LOAD_CLOSURE_RESULT_V0_1.md`（blob `8c53405554e2f5855da77f17598dfa6d7b7f6466`）；可读A接受消息。无需读取全部旧任务、CURRENT_CONTEXT、004 helper或旧仓库，无本地Git操作。

## 3. 新记录与唯一系统输入

新诊断ID：M3-POLICY-003。可只读核对`D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-002/observation.json`，预期SHA-256 `18BFD21FFB70C05DD86D3D57FB424E8EB719C3052BBAB57DE451723BB087AAF6`，仅采用已保存模块原值/自有错误；缺失或hash变化不阻止独立的当前查询，只限制历史关联。无需重验更早attempt。
允许在已批准父根的diagnostics下独占创建`D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-003`（W），保存observation.json、diagnostic.log、各轮原始stdout/stderr字节与可审阅的collector-command.txt。仅写这些本任务记录；旧文件不覆盖。W已有或不可写则用工具输出完成报告，披露未新建本地证据；不得因此虚构本地文件或改变路径。

只用已绑定的`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，普通用户、64位、`-NoProfile -NonInteractive -Command`，不传任何ExecutionPolicy参数。记录实际exe/PSHOME/版本/LanguageMode/PID/UTC，不以Version/ModuleBase附加身份门。真实exe/PSHOME不符则停止依赖操作。
唯一模块manifest P：`C:/Windows/System32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`。仅定点检查该文件及字面祖先的类型/reparse，记录其现有.NET SHA-256；不列目录、不跟进manifest依赖作agent读取。危险跳转或P缺失停止导入；不搜索替代。不要求manifest哈希与历史永远不变，变化须披露，不冒充旧快照。
标准Import-Module可由系统加载器正常读取自身依赖；这不是直接加载DLL的授权，不保证绝对零系统运行时记录。禁止改变PSModulePath、自动加载偏好和策略环境；无需再次采集完整PSModulePath、ZoneId或其他环境。

## 4. 固定核心顺序：正常导入 → Name/Path → 两项查询

先用纯内存合成对象检查判定函数：Name和Path正确且ModuleBase为PSHOME时应通过；Name或Path错误时不通过；空/多返回值须显式处理。合成字符串不得用来探测磁盘。不要建设通用模块审计器。
一次正常导入P；先保留返回对象的Name/Path/ModuleBase/Version原值，再判定Name和精确Path。允许Windows大小写与正反斜杠归一，不推导其他路径。ModuleBase与Version只记录，不要求ModuleBase等于P的父目录、Version等于历史值，不添加额外签名、依赖或版本研究关口。真实Name/Path不符仍停止，不通过取消正确绑定来继续。

以下是核心执行顺序，外层可以增加记录/异常序列化，不可把它改成诊断被拒helper的执行器；应在同一进程完成。所有版本均使用Windows PowerShell 5.1可用语法：

```powershell
$p = 'C:/Windows/System32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1'
$modules = @(Import-Module -Name $p -PassThru -ErrorAction Stop)
$moduleRows = @($modules | ForEach-Object {
    [ordered]@{ Name=$_.Name; Path=$_.Path; ModuleBase=$_.ModuleBase; Version=[string]$_.Version }
})
# 把moduleRows落入当前观察对象；在真实绑定失败之前也必须保存。
$bound = @($modules | Where-Object {
    [string]::Equals([string]$_.Name, 'Microsoft.PowerShell.Security', [StringComparison]::OrdinalIgnoreCase) -and
    [string]::Equals(([string]$_.Path).Replace([char]92,[char]47), $p, [StringComparison]::OrdinalIgnoreCase)
})
if ($bound.Count -ne 1) { throw 'MODULE_NAME_OR_EXACT_PATH_MISMATCH' }

$scopeRows = $null
$scopeError = $null
$scopeStatus = 'STARTED'
try {
    $scopeRows = @(Microsoft.PowerShell.Security\Get-ExecutionPolicy -List -ErrorAction Stop |
        ForEach-Object { [ordered]@{ Scope=[string]$_.Scope; ExecutionPolicy=[string]$_.ExecutionPolicy } })
    $scopeStatus = 'SUCCEEDED'
} catch { $scopeError = $_; $scopeStatus = 'FAILED' }

# 第一项失败也不能略过第二项；正常导入已成功，不新增导入。
$effective = $null
$effectiveError = $null
$effectiveStatus = 'STARTED'
try {
    $effective = [string](Microsoft.PowerShell.Security\Get-ExecutionPolicy -ErrorAction Stop)
    $effectiveStatus = 'SUCCEEDED'
} catch { $effectiveError = $_; $effectiveStatus = 'FAILED' }
```

外层在导入前将import/scopes/effective初始化为NOT_RUN；在实际调用之前写STARTED，完成后写SUCCEEDED或FAILED，并单独记录collector_error。标准导入失败则不调用两项命令触发自动再导入。原值取得后再序列化，不能让输出格式错误把已经完成的查询改成NOT_RUN。查询成功返回Undefined时保留Undefined，不改成UNKNOWN；缺行或取证失败保留UNKNOWN并说明原因。五个scope按名称绑定而非数组下标，不基于历史或记忆填值。必须保留原生effective返回，不只自行算优先级。

两项cmdlet没有独立OS退出码；分别记录调用状态/error，另记整个诊断进程actual exit。不要用最后一项或包装exit覆盖前项结果。异常至少保存完整类型/Message/HResult/FullyQualifiedErrorId/Category/InvocationInfo及可用InnerException，并明确系统错误与自有throw。标准输出UTF-8、调用端相同解码，保留原始字节；JSON失败时保存字段文本，不把报表失败当系统策略拒绝。

## 5. 有限纠错在同一任务内完成

正常计划是一轮导入加两项查询。若确证仅为本任务采证代码的语法、字段判断、路径转义或序列化错误，先保存原值和具体缺陷，允许同一任务内修正；已有数据优先只重新解析，不重新读取。若进程已退出且查询尚缺，授权至多一轮同范围纠错进程；本任务最多2个实际诊断进程，每进程普通导入最多1次，每项查询最多1次。首轮已成功的查询不因重报表而重跑。
禁止重试或绕过实际系统加载拒绝、真实Name/Path冲突、签名/访问/组策略拒绝；不得将此类结果伪装为采证bug。纠错不改变系统设置、不增加输入范围，不转为构建重试。每进程最多60秒；本地诊断最多180秒，仅终止自身超时进程。用尽后如实交付具体结果，不递归另造前置门。不要为了填满预算主动重复成功查询。

## 6. 产物与决定

只新增`docs/architecture/ELITESYNC_V10_M3_POLICY_QUERY_COLLECTOR_FIX_RESULT_V0_1.md`；建议80行以内，但保留原始scope表、effective、调用次数和所有实际错误。标题状态`PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY`。分开记录002已接受的导入事实、其未执行查询、003实际查询；新快照不还原004历史策略，也不解释001自动加载根因。
若当前策略已明确，只提出一个与实际值相符的合法后续处置及确切需批准范围，不执行策略修改或helper。若查询真实失败，汇总当前错误及管理者所需信息，不默认再建议查看下一层依赖。不得以“继续诊断如何诊断”为交付，不要求Owner重批本次普通查询。
候选分支`review/m3-policy-query-collector-fix-v0-1`；subject `docs: record policy queries after collector correction`。一个候选commit，唯一父为本任务commit，仅新增结果文件。GitHub Git Database/连接器发布，不本地commit/index；发表前确认main/task绑定未变，发表后一次核验parent/单路径/blob。冲突保留草稿不覆盖。独立接受可同tree单父记录，无额外closeout。执行者不自我接受、不推进main、不发下一任务，完成即停止。

## 7. 依据与保持边界

原合同已要求Name/Path匹配后查询；本次更改是项目级采证合同，不是宣称所有系统模块的ModuleBase都应为何值。2026-09-08核验微软Import-Module和Get-ExecutionPolicy机制，仅支持正常显式导入与两项查询语义，不证明本机必然成功：
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/Import-Module.md
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-executionpolicy

不执行/读取copy.ps1，不创建或加载新.ps1；仅可审阅的正常诊断命令文本。禁止Set-ExecutionPolicy（含Process）、-ExecutionPolicy、策略环境值修改、Unblock-File、签名/证书信任/注册表/组策略改变，禁止改模块路径或安全产品、提权、直接载入DLL绕过manifest、另一运行时执行被拒载荷、安装/下载/修复Windows。
不Add-Type/长路径自测/robocopy，不复制SDK/cache/源码，不启动或关闭Sandbox，不pub/M3/M2，不创建M3-ISO工作区。README/FD02、旧仓库、枚举、默认index/受保护staged state、真实数据等排除保持。原仓库、宿主工具及用户配置不写；legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI及LC-03/LC-04/Phase36/产品实现边界不变。M3 blocked、M2 deferred；CURRENT_CONTEXT、AGENTS和ChatGPT项目源均不更新。
