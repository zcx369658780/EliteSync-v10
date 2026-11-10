# EliteSync v10｜PowerShell系统模块加载与策略取证收敛结果 v0.1

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY`

结论：**正常系统模块显式导入成功；策略查询未执行，scope/effective仍UNKNOWN。** 本轮采证器加入了错误的ModuleBase守卫，提前结束同进程分支；不是系统模块导入失败。策略取证目标未完成，不声明完整闭环。
ID：M3-POLICY-002；日期2026-09-08（Asia/Shanghai）。

## 固定身份与来源

- main A=0b69c4ca027b09413edc857383df4b06610ce7bb，实时匹配；FIRST交接blob 18485c95262051e43892436fb52413132c5ee626匹配，历史startup不执行。
- task/m3-powershell-module-load-closure-v0-1 → T=95dd76b1f4e8616cf70675e713f76cd59447d0d2；任务blob 44a5cd55e3becff0739ae1baef4d8a51344213ad。
- T唯一父A，仅新增任务单；tree 6e9d0aff8d652c561acc2cc04b587956f24f0e68。A中的AGENTS f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1及001结果dea17c28809c00c030dbc02e1b0bccdbf61a836d均核验。
- D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-001/policy-observation.json安全祖先检查通过，SHA-256 BF80D0B1A0649BEB93E4A115DDE6C80C313C0C171DAF6B5AD1DB87F50B426B7B匹配。只采用其调用/运行时/ASCII错误，不恢复中文损失。
- 独占新建D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-002；未访问004 helper或重查其他旧attempt。

## 同进程实测

唯一诊断进程PID=13912，实际exe=C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe；普通调用、-NoProfile -NonInteractive -Command，无策略覆盖/提权/替代运行时。
开始2026-09-07T23:48:53.3318006Z，结束23:48:53.4691137Z；调用端总耗时约0.396秒，进程actual exit=1，无超时或后台等待。
PSVersion=5.1.26100.9168；PSEdition=Desktop；64-bit=true；LanguageMode=FullLanguage；独立PSHOME=C:/Windows/System32/WindowsPowerShell/v1.0。
PSModuleAutoLoadingPreference变量不存在，value=null；PSExecutionPolicyPreference进程环境键不存在，value=null；Get-Module -Name Microsoft.PowerShell.Security返回空数组。
PSModulePath原值如下，仅读取字符串，没有探测所列目录：

```text
C:\Users\zcxve\Documents\PowerShell\Modules;C:\Program Files\PowerShell\Modules;c:\program files\powershell\7\Modules;;%ProgramFiles%\WindowsPowerShell\Modules;C:\Program Files\WindowsPowerShell\Modules;C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules
```

P=C:/Windows/System32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1。字面祖先为目录、P为Archive文件，无reparse；776 bytes，SHA-256 FA7150089E8A67A0AAD27CD324D119B9778CCBEAD6242397780C5D5077246D30。未跟进manifest引用进行agent读取。

唯一一次Import-Module -Name P -PassThru -ErrorAction Stop成功，返回：
- Name=Microsoft.PowerShell.Security；Version=3.0.0.0。
- Path与P完全一致。
- ModuleBase=C:/Windows/System32/WindowsPowerShell/v1.0。

上述Name/Path满足任务绑定。采证器却额外要求ModuleBase等于P的所在目录，触发自有IMPORTED_MODULE_BINDING_MISMATCH并在查询前退出。这个额外要求不来自任务，不能据此认定系统路径不安全、模块错误或依赖损坏。事后仅对保存原值纠正解释，没有再导入/查询。

## 原始错误与scope

系统Import-Module底层错误：无；导入成功。实际捕获的是自有守卫错误：
- Exception=System.Management.Automation.RuntimeException；Message/FullyQualifiedErrorId/TargetObject=IMPORTED_MODULE_BINDING_MISMATCH。
- HResult=-2146233087；CategoryInfo=OperationStopped: (IMPORTED_MODULE_BINDING_MISMATCH:String) [], RuntimeException。
- InvocationInfo：诊断命令第41行、字符212，自有ModuleBase比较后的throw；完整行、PositionMessage与异常ToString已保存。
- Exception链仅这一层，无InnerException，未截断。不是再次CouldNotAutoloadMatchingModule，也不是策略/签名拒绝。

| 项目 | 结果 |
| --- | --- |
| MachinePolicy | UNKNOWN，未执行查询 |
| UserPolicy | UNKNOWN，未执行查询 |
| Process | UNKNOWN，未执行查询 |
| CurrentUser | UNKNOWN，未执行查询 |
| LocalMachine | UNKNOWN，未执行查询 |
| effective policy | UNKNOWN，未执行查询 |

各进程内步骤分别保存success/value/error；cmdlet没有独立OS exit，记录native_exit=null并说明共享进程actual exit=1，不能把成功导入写成exit=1失败。scope/effective调用数各0，正常导入数1，无重试。一次导入预算用尽后不重启进程；取证失败责任在执行者采证器，不转成Owner缺少普通诊断批准。

## 证据质量与可决定的处置

诊断进程输出编码UTF-8，调用端按严格UTF-8解码，并保存未解码原始字节。stdout.bin=3995 bytes，stderr.bin=0 bytes；本轮中文错误位置文本完整，没有沿用001损失文本。保留参数、时间、PID、原值和错误；没有新.ps1或DLL直接加载。
W为D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-002：
- observation.json：18BFD21FFB70C05DD86D3D57FB424E8EB719C3052BBAB57DE451723BB087AAF6。
- diagnostic.log：F98043398EE830D443CDFAA926D3349808B3AE315597A53FC02758DBABFBDEF2。
- stdout.bin：B7F643A7A454AF1D0ACAD7A397377C375575FC60A80517F66A53182292399D17。
- stderr.bin：E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855。

**唯一后续处置：修正采证器为按任务检查Name和精确Path，去掉错误的ModuleBase目录相等要求，在后续具名的一次同进程诊断预算中完成两项策略查询。** 这是具体采证缺陷修正，不是继续读取下一层依赖或修复系统。已有普通诊断批准无需重批；本轮不自行增加一次导入预算、不另发任务。当前没有证据需要Owner批准策略、信任或系统组件变更，亦不建议这类变更。

本轮只证明当前精确manifest可正常导入；未解释001自动发现失败，不还原004当时策略，不证明helper获准、长路径自测通过或M3可运行。环境字符串不能单独证明自动加载失败根因。
未改变策略/PSModulePath/签名信任或系统配置，未安装修复系统；标准模块加载可能产生运行时记录，不宣称绝对零副作用。未自测、复制SDK/cache/源码、Sandbox、pub、M3或M2。
CURRENT_CONTEXT/AGENTS/历史报告/项目源不修改；原仓库/index不操作，无旧仓库、README/FD02、真实数据或全局枚举。legal/Safety/no-processing与阶段边界保持；模型配置未改、无辅助代理。
一个单父T候选只新增本报告，待独立审查；不自我接受、不更新main，发布并核验后停止。
