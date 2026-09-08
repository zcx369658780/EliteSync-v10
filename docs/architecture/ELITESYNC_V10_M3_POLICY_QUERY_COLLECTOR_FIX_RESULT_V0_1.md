# EliteSync v10｜采证守卫修正与策略查询结果 v0.1

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY`

结论：**本轮正常导入和两项策略查询均SUCCEEDED；实际effective=Restricted，五个scope均返回Undefined。** 当前策略查询目标完成，不是helper或M3执行授权。
诊断ID：M3-POLICY-003；2026-09-08（Asia/Shanghai）。

## 固定身份与历史保护

- 实时main A=4d45d0e3ac1818274d6bae5c35567276efc330cb匹配；FIRST交接blob 18485c95262051e43892436fb52413132c5ee626匹配，不执行旧startup。
- task/m3-policy-query-collector-fix-v0-1 → T=c83c992c2098518ad5c4d477149cc112f1ad3da7；任务blob 54e05bf175b89b8b2cf12971d28789bd2db155f9。
- task ref、T唯一父A、单文件任务新增范围均匹配。AGENTS blob f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1及002结果blob 8c53405554e2f5855da77f17598dfa6d7b7f6466匹配；未跟进其他文件。
- D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-002/observation.json字面祖先/文件无reparse，SHA-256 18BFD21FFB70C05DD86D3D57FB424E8EB719C3052BBAB57DE451723BB087AAF6匹配；仅采用已保存模块原值/自有错误，旧文件未写。
- 002已接受事实为系统导入成功、错误ModuleBase守卫令两项查询未执行；003以下是新快照，不倒写002或004。本轮未重验其他旧attempt，不读写copy.ps1。

## 采证修正与同进程运行

独占创建W=D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-003，仅保存本任务记录，没有M3-ISO/input/新.ps1。
固定exe=C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe，普通用户调用-NoProfile -NonInteractive -Command；实际exe匹配，64位，PID=36348。
PSHOME=C:/Windows/System32/WindowsPowerShell/v1.0；PSVersion=5.1.26100.9168；PSEdition=Desktop；LanguageMode=FullLanguage。未重新读取完整PSModulePath、ZoneId或其他环境。
开始2026-09-08T00:31:10.5639734Z，结束00:31:10.7314951Z；调用端约0.348秒，进程actual exit=0；无超时、后台等待。

先做纯内存判定测试：正确Name/Path且ModuleBase为PSHOME时true；错误Name、错误Path、空数组、多对象均false。全部符合预期，没有把合成路径用于磁盘探测。
修正仅为移除002额外ModuleBase门槛。ModuleBase/Version仅记录；未新增版本、签名或依赖审查门。实际正常导入前检查唯一manifest及字面祖先类型/reparse；无跳转，文件776 bytes。
manifest P=C:/Windows/System32/WindowsPowerShell/v1.0/Modules/Microsoft.PowerShell.Security/Microsoft.PowerShell.Security.psd1；SHA-256 FA7150089E8A67A0AAD27CD324D119B9778CCBEAD6242397780C5D5077246D30，与002记录相同，不用历史hash作为额外导入门。

Import-Module -Name P -PassThru -ErrorAction Stop一次成功；先保存返回原值再绑定：
- Name=Microsoft.PowerShell.Security。
- Path归一后与P精确一致；原始反斜杠值保存在observation.json和原始stdout。
- ModuleBase=C:/Windows/System32/WindowsPowerShell/v1.0；Version=3.0.0.0，均不参与绑定。
- 返回单对象，Name/Path绑定true；没有自有或系统错误。

## 两项查询的实际结果

同一PID内分别执行Microsoft.PowerShell.Security限定的Get-ExecutionPolicy -List与无参数Get-ExecutionPolicy，每项各一次。各自NOT_RUN→STARTED→SUCCEEDED独立保存；原值取得后持久化，不由包装exit推断结果。

| Scope（按名称） | 命令实际返回 |
| --- | --- |
| MachinePolicy | Undefined |
| UserPolicy | Undefined |
| Process | Undefined |
| CurrentUser | Undefined |
| LocalMachine | Undefined |

**Get-ExecutionPolicy实际effective返回：Restricted。** Undefined是成功取得的策略值，不是UNKNOWN；当前无上述scope的显式策略，MachinePolicy/UserPolicy均未配置执行策略。effective来自命令，不是只按优先级推算；五项Undefined与当前默认Restricted相容，不是矛盾。
普通导入=1次，scope查询=1次SUCCEEDED，effective查询=1次SUCCEEDED。两项错误对象null，import_error/collector_error亦null；诊断进程1个，运行中采证纠错0次、纠错进程0个，没有重复成功查询。
两项cmdlet无独立OS退出码，分别报告状态/error；共享进程actual exit=0，stderr空。本轮已完成针对002守卫缺陷的修正，不把此修正混作运行失败重试次数。

## 证据保存、限制与唯一后续处置

输出与解码均UTF-8，严格解码成功；原始stdout-1.bin=2133 bytes、stderr-1.bin=0 bytes已保存。observer JSON经反解析；导入原值在身份判断前保存，两项结果分别保存，未由序列化错误覆盖。W下文件SHA-256：
- observation.json：E53D19BCFC78AF2A8DB2FE91D34D894C86B86BB22C662ED94A52802443FA1A56。
- diagnostic.log：066FC4F4C2D9C561FB3F9555C29E908D4171CF039DD858B86B6CA87C91DC1171。
- collector-command.txt：13180FB25BC5BE53C8AD28438257347CC7CAA57A06D9197983D23E8CCB3E3BE4。
- stdout-1.bin：93262919F616BD20A6E702A5AE29734596DB738163861BD4E4CCE88ED994D9B2。
- stderr-1.bin：E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855。

Restricted允许交互命令而限制脚本文件，与004记录的“running scripts is disabled”相容；这只是当前快照关联，不证明004当时所有scope，不解释001自动加载根因。系统模块导入成功不等于004 helper获准或M3可运行。没有读取helper来源/签名，本轮不补认证。

**唯一建议：由Owner决定是否为后续具名、自有helper任务批准仅进程级RemoteSigned运行条件，限定准确脚本/哈希及任务进程生命周期，保留正常来源/签名检查，不改CurrentUser/LocalMachine持久策略。** 这是尚未授予的精确策略运行条件变更，不是重批普通诊断；本轮不设置策略、不执行helper，也不以建议取代后续任务的实际授权。没有再提出同义策略查询或读取下一层依赖；长路径复制自测、离线输入充分性和M3仍未验证。

未改变策略/模块路径/自动加载偏好/信任/用户配置，未提权、换运行时或直接载入DLL；标准系统模块加载不承诺绝对零运行时记录。未读写004 helper、未自测/复制/Sandbox/pub/M3/M2、未安装修复系统。
CURRENT_CONTEXT/AGENTS/项目源/历史报告不修改；原仓库/index无操作，README/FD02、旧仓库、真实数据与枚举排除保持。legal/Safety/no-processing及阶段边界不变，M3 blocked、M2 deferred。模型配置未修改，无辅助代理。
候选仅新增本结果、唯一父T；发布前main/task匹配且目标无冲突，发布后核验单父/单路径/blob。执行者不自我接受、不更新main、不发下一任务，完成后停止。
