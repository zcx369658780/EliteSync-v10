# EliteSync v10｜PowerShell系统模块加载与策略取证收敛 v0.1

Status: `TASK ONLY — NORMAL SYSTEM-MODULE LOAD DIAGNOSTIC — NO POLICY CHANGE / HELPER EXECUTION / BUILD`
日期：2026-09-08（Asia/Singapore）。简体中文；模型由Owner选择，不改配置、不默认调用辅助代理。

## 1. 目的与一次收敛

M3-POLICY-001候选94ba0cf7b965760ca85e3007048644eb2fc27d5b已由0b69c4ca027b09413edc857383df4b06610ce7bb接受为查询失败记录：Security模块自动加载失败，effective及五个scope均UNKNOWN。接受不表示策略诊断目标已完成。004脚本拒绝、003长路径问题和M3未启动均保持。
本任务落实Owner已授予的限定证据分析、可逆工作与自动续发权限。报告建议再次向Owner索取普通诊断许可不构成新的全局审批门。本任务明确新增同一Windows PowerShell中系统自带Microsoft.PowerShell.Security的正常显式导入及完整错误取证，并在导入成功后同进程完成两项策略查询。不再拆成查文件、审查文件、批准导入、再查策略四张单。
导入会改变当前诊断进程的模块状态并由标准加载器读取依赖，不是纯文件读取，也不保证宿主绝对零运行时写入；它不更改系统配置、不绕过标准加载/签名/执行策略检查，不加载004 helper。本任务不是再次隔离复制或M3尝试。

## 2. 固定仓库入口

仓库zcx369658780/EliteSync-v10。开始实时读取main，必须恰为0b69c4ca027b09413edc857383df4b06610ce7bb（A）。FIRST主动读取：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob 18485c95262051e43892436fb52413132c5ee626。
随后读取启动prompt固定的本任务commit/blob，要求唯一父A、只新增本任务。历史startup不重跑，失配停止依赖动作，不自行换基线。
其余项目输入仅A中的AGENTS.md（f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1）及`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_SCRIPT_POLICY_DIAGNOSTIC_RESULT_V0_1.md`（dea17c28809c00c030dbc02e1b0bccdbf61a836d）。可读A接受消息。不重读全部旧任务/日志，不本地fetch/HEAD/status/同步；CURRENT_CONTEXT、AGENTS和项目源不更新。

## 3. 精确本地输入和自有记录

先对字面路径及祖先作不跟随跳转的安全检查；没有目录/磁盘/注册表搜索。
只读上轮`D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-001/policy-observation.json`，主体SHA-256应为BF80D0B1A0649BEB93E4A115DDE6C80C313C0C171DAF6B5AD1DB87F50B426B7B。采用调用、运行时和ASCII错误ID，不猜测恢复解码损失。缺失/hash变动只阻止与001精确关联，不阻止独立的当前系统查询。
本轮ID=M3-POLICY-002；仅独占新建`D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-002`（W），保存observation.json、diagnostic.log和原始stdout/stderr字节。已有时不覆盖，仍可用当前工具输出交付并披露未新增本地文件。不创建M3-ISO attempt、input、自测目录或.ps1文件。不读写004 helper，不重新hash002/003全部证据。

## 4. 同一进程的闭合诊断

只用`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，普通用户、-NoProfile -NonInteractive -Command和可审阅的诊断命令文本。不是将被拒helper改为内联执行；不得传-ExecutionPolicy，不更换pwsh/位数/用户，不RunAs。
一次新诊断进程按以下顺序执行，所有项独立保留结果：
1. 记录实际exe、PID、开始UTC、PSVersion/PSEdition、独立变量PSHOME、64位状态、LanguageMode。只读取当前PSModuleAutoLoadingPreference的有无/值、进程PSModulePath字符串、PSExecutionPolicyPreference有无/值；不改这些值、不探测PSModulePath所列目录。记录当前已加载的同名Security模块可用`Get-Module -Name Microsoft.PowerShell.Security`，不得-ListAvailable。
2. 要求实际PSHOME归一后为C:/Windows/System32/WindowsPowerShell/v1.0。精确目标P固定为`C:/Windows/System32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1`。只查询P与字面祖先的存在/类型/reparse，并可读取P原文、长度与SHA-256作为系统manifest证据，不运行其中任意文本或跟进任意引用进行agent检查。P缺失、危险跳转或PSHOME失配时记录准确结果，不猜其他安装、搜索模块或直接加载DLL。
3. P安全存在后，唯一一次普通导入：`Import-Module -Name $P -PassThru -ErrorAction Stop`。允许标准加载器在当前Windows安装及其正常系统运行库范围读取自身系统依赖，不复制/替换模块，不人为逐项加载依赖、不改PSModulePath或模块自动加载配置。不使用Force、SkipEditionCheck、程序集反射加载或把manifest内的DLL拿出来绕开被拒manifest。普通导入若被拒，保存拒绝并结束相关分支；不得认为本任务允许越过安全检查。
4. 导入成功，记录返回模块的Name/Path/ModuleBase/Version；名称或路径不符合绑定时不继续。随后在同一进程分别执行`Microsoft.PowerShell.Security\Get-ExecutionPolicy -List`与`Microsoft.PowerShell.Security\Get-ExecutionPolicy`各一次。分别保存枚举结果或错误；某一项成功不能掩盖另一项失败。导入失败时不再调用命令触发第二次自动导入，scope/effective保持UNKNOWN。
5. 每个失败记录Exception完整类型、Message、HResult、FullyQualifiedErrorId、CategoryInfo、TargetObject（非敏感部分）、InvocationInfo和至多8层InnerException；消息不完整就明确缺失。若错误提示了新路径/依赖，它只是诊断结果，不自动授权访问。必须保留模块导入本身的底层错误，而不是再次仅报CouldNotAutoloadMatchingModule。

哈希可用现有.NET SHA256，文本/JSON写入可用现有.NET文件API；不让采证依赖正在失败的Security模块，不Add-Type、下载库或启动另一个shell规避拒绝。序列化采用已有ConvertTo-Json能力，失败时保留原始输出和字段文本，不因此把UNKNOWN写成空值。只调整本诊断进程的输出编码为UTF-8，并让调用端按同编码解码，保留原始字节；输出编码不是执行策略。不得仅改变解码器后编造此前损失的中文。
每个诊断子进程最多60秒、本轮本地诊断最多180秒。优先重用已保存原值修正纯解析/编码错误；尚未到达Import-Module的派发错误可修正一次，正常导入总计最多一次，安全拒绝不重试。超时仅停止本轮拥有的诊断进程；没有后台等待、全局进程扫描或额外分支。

## 5. 结论和不再递归拆任务

正常导入与策略查询均成功：报告当前scope/effective和与004错误相容性；明确是本进程快照，不是004历史重建，也不说明自动发现为何失败或helper已可执行。
导入失败：以实际InnerException/错误对象说明已知问题和仍未知点；不得把“模块缺失”“路径发现异常”“策略/签名拒绝”“系统组件问题”中某一种未经证实地确认为根因。没有具体原因也应如实交付，不修系统、不切换加载器。
最终必须给一个可决定的下一步：若策略已明确，指出合法运行条件所需的确切范围；若系统模块仍不可用，列明系统管理者需要处理的具体证据和仍待确认事项。任何策略/信任/系统组件/运行环境改变均是待Owner决定，不执行。不得把“请再授权查看下一层依赖”作为默认唯一产物；本次结束普通模块诊断链，不自动续发同义递归诊断或全量复制。
本任务能闭合的是当前查询可用性/失败对象，不承诺必定找到根因。M3尚未启动、长路径自测未验证及M2 deferred不变。已批准选项1无需重批，但不能替代新增系统变更授权。

## 6. 单文件候选

只新增`docs/architecture/ELITESYNC_V10_M3_POWERSHELL_MODULE_LOAD_CLOSURE_RESULT_V0_1.md`，建议80行以内，保留必要原值/错误和不同证据层。标记PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY。不要因为行数上限省略底层错误。
候选分支`review/m3-powershell-module-load-closure-v0-1`，subject `docs: record system-module load and policy closure`。一个commit，唯一父为本任务commit，只有结果文件；GitHub Git Database/连接器发布，不本地commit/index。发布前确认main/task仍匹配；发布后一次核验parent/单路径/blob。冲突保留草稿，不强推。独立接受仍可用同tree单父接受提交，不新增closeout。执行者不自我接受、不推进main、不下发下一任务。

## 7. 机制依据与边界

作者2026-09-08核验微软5.1 Import-Module文档：支持用完整模块文件路径正常导入；正常导入不等于安装模块。Get-ExecutionPolicy无参数返回当前有效值，-List返回scope。它们是外部机制依据，不是本机成功证据：
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/Import-Module.md
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/About/about_Execution_Policies.md
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-executionpolicy
禁止Set-ExecutionPolicy（含Process）、-ExecutionPolicy、修改PSExecutionPolicyPreference、Unblock-File、签名/证书信任/注册表/组策略/模块路径修改、禁用安全产品或应用控制；禁止执行被拒helper、直接加载DLL绕过manifest、替代运行时、安装/下载/修复Windows。未授权联网取证或凭据读取；标准模块加载可能产生系统运行时记录，不宣称绝对零副作用。
不复制SDK/cache/源码、不Add-Type/自测/robocopy、不启动或关闭Sandbox、不pub/M3/M2，不创建或复用构建attempt。README/FD02、旧仓库、默认index/受保护暂存状态、真实数据及枚举排除保持；原仓库内容和宿主工具/用户配置不写。legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36及产品实现边界保持。项目源、CURRENT_CONTEXT和AGENTS均不更新。
