# EliteSync v10｜M3脚本策略定点诊断 v0.1

Status: `TASK ONLY — READ-ONLY POLICY DIAGNOSTIC — NO POLICY CHANGE / BYPASS / SELFTEST / COPY / SANDBOX / BUILD`
日期：2026-09-08（Asia/Singapore）。简体中文；实际模型由Owner在宿主选择，不改模型配置、不默认调用辅助代理。

## 1. 目标与授权限度

004候选db1c457b44a780f7957d70d84e488787af730110已由a19564a48913a8ecaca7cd12274ad58395f00149接受为前置失败记录。Windows PowerShell拒绝加载自有copy.ps1；没有执行自测、复制或M3。策略scope未记录，不能认定Restricted、组策略、互联网标记或正确修复方式。003的Git绑定和当次隔离证据保留，但不替代当前环境验证。
本任务依Owner对限定证据分析及自动续发的授权，只回答：同一PowerShell当前生效什么策略、由哪个scope控制，与004加载错误是否相容，以及需要什么最小的合法后续决定。不重新搭环境、不重试004、不新增M3-ISO attempt，也不重新盘点SDK/cache。
读取配置不等于修改配置。选项1仍有效，但不自动批准策略改变、解锁脚本或绕过管理控制。本诊断结束即提交一个小结果，不把它扩展成全局安全审计或新规划链。

## 2. 固定入口与GitHub输入

仓库：zcx369658780/EliteSync-v10。开始实时读取main，要求恰为：
`a19564a48913a8ecaca7cd12274ad58395f00149`（A）。
FIRST主动读取A中的`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob `18485c95262051e43892436fb52413132c5ee626`。不重跑其历史startup。随后读取启动prompt给定的本任务commit/blob，验证唯一父A及只新增本任务。失配只停止其依赖动作，不换基线。
其余仓库内容限A中的：
- `AGENTS.md`，blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_4.md`，blob `10b9cf14a78c20578c4d0f7d96340ec671565456`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_4.md`，blob `cb46cea5c9c5610d1771d96448c955d58c5218bb`，仅解释历史加载/策略边界，不执行它。
可读A接受commit的元数据与消息。无需本地fetch/HEAD/status/工作区同步；全部发布用GitHub连接器。CURRENT_CONTEXT、AGENTS和历史报告均不修改；不沿链接扩大读取。

## 3. 最小本地证据和写入范围

仅定点读取/校验004以下对象；先检查这些字面路径及祖先没有未批准跳转，不列目录：
- `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/evidence/result.json`，SHA-256 `AB185A357E52FF7A3C34B85AB6D782781CF16C5CCF4DA6D86DBBDDE3242B788B`。
- 同一evidence下`host-selftest-load-error.json`，SHA-256 `2BC28481AA519A77ABAC8ABA98D70162CFB95728A127A453A0ADB26061C9EA75`。
- `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/scripts/copy.ps1`，仅文件元数据、SHA-256和下面允许的ZoneId；要求主体SHA-256 `9177A1B3A713F1414E6846BCACAD77773CEFE19E24E5FBB81FC81E9A9C397CCD`。本任务不审查/载入/执行正文。
缺失或hash不符时保留现状，不修补004；报告出处冲突，仍可完成独立的当前策略查询，不能宣称与004形成精确关联。不需要重验002/003八份证据。
新诊断ID为M3-POLICY-001。可在已批准父根下独占新建`D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-001`，只保存`policy-observation.json`和`diagnostic.log`。目录已存在不覆盖；仍用当前工具输出完成GitHub报告并披露无法新建本地记录。其余已有文件不写；不创建input、SDK副本、自测目录或.ps1 helper。

## 4. 直接运行内置只读查询，不加载被拒脚本

使用004实际调用的同一可执行文件`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，普通用户、相同调用通道，参数仅`-NoProfile -NonInteractive -Command`加可审阅的下列内置查询。不是把copy.ps1改成命令文本执行。不要加入-ExecutionPolicy或清除/覆盖既有策略环境值，不RunAs、不改用pwsh来规避拒绝。
一次批量记录：
1. 当前进程实际exe、PID、64位状态、PSVersionTable的PSVersion/PSEdition/PSHOME，以及ExecutionContext.SessionState.LanguageMode。只查当前诊断进程，不全局列进程/环境。
2. `Get-ExecutionPolicy -List`原始各scope值；另用`Get-ExecutionPolicy`取得实际有效值，不只按记忆计算优先级。
3. 当前进程环境变量`PSExecutionPolicyPreference`的有无和策略文本，仅此键，不改变它，不读取其他用户环境或注册表树。
4. 对§3精确copy.ps1，最多一次用`Get-Content -LiteralPath <该路径> -Stream Zone.Identifier`只提取ZoneId。流不存在与查询失败分开；不保存HostUrl/ReferrerUrl、其他流或脚本正文，不Unblock。文件hash不能证明ZoneId，因为它们是不同证据。
每项单独捕获成功/错误，保留stdout/stderr/实际退出码；不要让最后一个成功命令掩盖前面失败。JSON用序列化器，路径用正斜杠；不拼接未转义参数。只运行诊断内置命令及写本任务自有结果，不创建并加载另一份.ps1。
若纯参数/序列化错误，允许在已记录原始输出上修正；至多一轮相同范围的诊断调用修正，不将策略/权限拒绝当成可绕过的脚本bug。每个子进程最多60秒，无后台等待；被拒查询记录UNKNOWN后交付，不换运行时、不提权、不新增探测。普通查询可运行不等于helper获准运行。

## 5. 结果必须收敛到可决定的事实

结论先给当前effective policy、各scope、是否有MachinePolicy/UserPolicy配置，以及原始错误的关联程度。新诊断是当前快照；004进程已退出，不能补写成当时策略的完整实测。
- 若组策略控制且限制脚本：明确需要适当系统管理者处理；不提出用更低scope或其他加载器越过它。
- 若无组策略限制，当前有效值禁止脚本或要求签名：说明相容的限制及所需最小授权类别，例如由Owner决定适当的任务级加载条件/可信签名安排；不默认修改CurrentUser/LocalMachine，不将本报告当批准。
- 若当前策略并不解释原错误：记录差异，列出现有证据无法区分的原因；不要试跑copy.ps1来补证，更不要假称已修复。
- ZoneId只是文件来源标记证据；未检查签名可信性就不能认定完整RemoteSigned/AllSigned准入。不得联网验证证书或扫描证书库。
最后只给一个推荐后续处置及必要决定；不是另开广泛研究。长路径复制、离线缓存充分性和M3仍未验证，即便策略信息齐全也不在本任务启动它们。

## 6. 单一候选交付

只新增`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_SCRIPT_POLICY_DIAGNOSTIC_RESULT_V0_1.md`，建议控制在80行内，必要原始scope表和错误不可省。标记`PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY — NO EXECUTION AUTHORITY`；不为这一小诊断更新CURRENT_CONTEXT或项目源。
报告包含A/任务身份、004证据关联、诊断调用与实际结果、scope表、ZoneId及限制、是否有管理策略、最小后续决定和零helper/复制/Sandbox/pub/M3执行。不得把UNKNOWN写成Absent或PASS。
候选分支`review/h01-bib03-u15-td01-m3-script-policy-diagnostic-v0-1`；subject `docs: record M3 script policy diagnostic`。一个候选commit，唯一父为本任务commit，只新增该结果。发布前一次核验main/task未变；发布后一次核验parent/单路径/blob。冲突保留草稿、不覆盖、不强推。用GitHub Git Database/连接器，不本地commit/index。完成后停止，不自我接受、不推进main、不发下一任务。
后续独立验收沿用同tree单父接受commit，不新增closeout。只有明确授权支持下一动作时才续发；策略更改或新的运行条件不能从诊断结果自动获得。

## 7. 官方依据与不变边界

2026-09-08定点核验官方Get-ExecutionPolicy和about_Execution_Policies：无参数返回当前有效值，-List给各scope；Restricted允许单条命令但禁止脚本文件；组策略与进程/用户/机器scope需分开。官方页面是机制依据，不是本机配置证据。
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/get-executionpolicy?view=powershell-7.5
- https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/5.1/Microsoft.PowerShell.Core/About/about_Execution_Policies.md
执行者仅必要时核对以上主题，不运行页面中的改策略、解锁或安装示例。
明确禁止Set-ExecutionPolicy（含Process）、-ExecutionPolicy Bypass/Unrestricted、修改PSExecutionPolicyPreference、Unblock-File、签名/证书信任变更、注册表/组策略修改、提权，以及把已拒helper正文改用Invoke-Expression/ScriptBlock/EncodedCommand/另一运行时执行。不得禁用安全产品或改应用控制。
不加载copy.ps1、不运行Add-Type/合成自测/robocopy，不启动或关闭Sandbox，不复制SDK/cache或源码，不执行pub/M3/M2，不更改旧attempt。不访问README/FD02、旧仓库、默认index/受保护暂存状态或真实数据；不扫描仓库/磁盘/用户配置。原仓库、宿主SDK/cache与用户配置不写。legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI及LC-03/LC-04/Phase36/产品实现边界保持。GitHub文档通道不构成依赖下载或构建联网授权。
