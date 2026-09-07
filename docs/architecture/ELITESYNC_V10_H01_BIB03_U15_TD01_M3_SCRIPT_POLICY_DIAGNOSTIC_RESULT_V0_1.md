# EliteSync v10｜M3脚本策略定点诊断结果 v0.1

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — DIAGNOSTIC ONLY — NO EXECUTION AUTHORITY`

结论：**effective policy=UNKNOWN；控制scope=UNKNOWN**。两项Get-ExecutionPolicy查询均因Microsoft.PowerShell.Security自动加载失败而退出，不能推定Restricted或组策略控制。004证据hash关联成立，但本轮未取得解释其当时拒绝的完整策略证据。
诊断ID：M3-POLICY-001；2026-09-08（Asia/Shanghai），查询时间2026-09-07T23:32:30–31Z。

## 固定身份与004关联

- 实时main A：a19564a48913a8ecaca7cd12274ad58395f00149；FIRST交接blob 18485c95262051e43892436fb52413132c5ee626匹配，旧startup不执行。
- task/h01-bib03-u15-td01-m3-script-policy-diagnostic-v0-1 → T=05e61f9d712e21bb81f8b9407076e25f1d59f40e；任务blob d02c6a89e48d3c07e9277f6ef89392c17960ceca。
- T唯一父A，仅新增任务单，ahead=1/behind=0；tree df6a4279f674e2ae458f0c17fbe9c367611adcab。
- A中的AGENTS、004报告和v0.4历史任务blob分别核验f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1、10b9cf14a78c20578c4d0f7d96340ec671565456、cb46cea5c9c5610d1771d96448c955d58c5218bb；不执行历史任务，不跟进链接。
- 字面祖先/文件无reparse跳转。004 result.json、host-selftest-load-error.json分别匹配AB185A357E52FF7A3C34B85AB6D782781CF16C5CCF4DA6D86DBBDDE3242B788B、2BC28481AA519A77ABAC8ABA98D70162CFB95728A127A453A0ADB26061C9EA75。
- 精确helper：D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/scripts/copy.ps1；主体SHA-256为9177A1B3A713F1414E6846BCACAD77773CEFE19E24E5FBB81FC81E9A9C397CCD，9948 bytes、Archive，LastWriteTimeUtc=2026-09-07T22:53:24.4058232Z。仅取元数据/hash/ZoneId，不读正文、不加载或修改。
- 004保存的PSSecurityException/UnauthorizedAccess、包装exit=1及terminal=true一致；当时policy_scope=NOT_QUERIED。本轮没有重查002/003证据。

## 当前运行时和查询原值

一次批量、五个独立只读子进程，以便每项保留真实exit；统一使用C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe及-NoProfile -NonInteractive -Command。普通调用通道，无RunAs或策略参数，未改变继承环境。
runtime子进程PID=37992，实际exe与指定路径一致，64-bit=true，PSVersion=5.1.26100.9168，PSEdition=Desktop，LanguageMode=FullLanguage；PSHOME独立读取为C:/Windows/System32/WindowsPowerShell/v1.0。运行时信息不代表helper准入。

| 查询 | PID | 实际exit | 原值/错误 |
| --- | --- | --- | --- |
| runtime | 37992 | 0 | 上述运行时字段 |
| Get-ExecutionPolicy -List | 14284 | 1 | CommandNotFoundException；CouldNotAutoloadMatchingModule；ObjectNotFound |
| Get-ExecutionPolicy | 19912 | 1 | CommandNotFoundException；CouldNotAutoloadMatchingModule；ObjectNotFound |
| PSExecutionPolicyPreference（Process环境） | 16892 | 0 | present=false，value=null |
| exact Zone.Identifier，仅ZoneId | 30792 | 1 | System.IO.FileNotFoundException；GetContentReaderFileNotFoundError,Microsoft.PowerShell.Commands.GetContentCommand；ObjectNotFound |

两项策略查询错误指向Microsoft.PowerShell.Security自动加载；没有执行错误提示中的Import-Module。每项stderr为空，捕获错误在stdout JSON中；无最后成功掩盖前面失败。全部小于60秒且已退出，无后台任务。
重定向stdout的中文错误message发生解码替换字符损失；保留工具实际收到的字符串，ASCII异常类型/error_id完整，不伪造原中文。未因该损失重跑失败查询。编排首次JS模板语法错误发生在任何shell/诊断启动之前，仅修正命令构造；实际诊断批次1、查询重试0。

| Scope | 当前值 |
| --- | --- |
| MachinePolicy | UNKNOWN |
| UserPolicy | UNKNOWN |
| Process | UNKNOWN |
| CurrentUser | UNKNOWN |
| LocalMachine | UNKNOWN |

有效策略独立查询同样为UNKNOWN。没有证据确认MachinePolicy/UserPolicy已配置，也没有证据确认未配置；环境键不存在不能替代scope查询成功。
Zone.Identifier指定流返回FileNotFound，结合主体文件存在/hash匹配，记录该流不存在；ZoneId无值，不写成ZoneId=0。该结果不同于策略模块查询失败。未读取HostUrl/ReferrerUrl、其他流或签名/证书；主体hash不证明来源标记或可信签名。没有Zone标记也不等于获准执行。

## 关联程度、推荐及必要决定

关联程度：同一exe和精确004文件/错误记录已绑定；当前观测到策略查询模块无法自动加载。它既不能确定004受哪个scope控制，也不能证明004当时Restricted、组策略限制或互联网标记导致拒绝。004进程已退出，不能补写成当时完整实测；本次FullLanguage与环境键缺失亦不排除其他准入控制。

**唯一推荐后续处置：由Owner授权一项仅针对同一Windows PowerShell中Microsoft.PowerShell.Security自动加载失败的最小只读诊断，明确所允许的模块加载错误取证方式。** 当前必要决定仅为该精确新增读取/诊断范围，不是策略更改、解除标记或执行helper的批准；本轮不执行该建议，不另发任务。取得真实scope前，不推荐改变任何Process/CurrentUser/LocalMachine策略或用其他加载器规避。若随后证实管理策略限制，应由适当系统管理者处理。

## 本地保存与停止边界

独占创建D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-001，仅保存policy-observation.json和diagnostic.log，含三份004主体元数据/hash、每项调用参数、PID、时间、stdout/stderr/exit及限制。
policy-observation.json SHA-256：BF80D0B1A0649BEB93E4A115DDE6C80C313C0C171DAF6B5AD1DB87F50B426B7B。
diagnostic.log SHA-256：F990BD0E4692F28A10E9F95C02A160A06FF03F28582EAB0068ABC5FFFD9908FF。
JSON经序列化与反解析；没有新.ps1、新M3-ISO attempt或input。所有旧证据保持原状；本地日志不上传GitHub。

helper加载/执行、Add-Type、自测、robocopy、源码/SDK/cache复制、Sandbox启动/关闭、pub/M3/M2均0次。未查询SDK/cache、未改变/绕过执行策略、未签名/解锁、未提权；长路径复制与离线输入充分性仍未知，M3无新执行证据。
CURRENT_CONTEXT、AGENTS、历史报告、原仓库内容、用户配置和受保护index不写；无status、fetch/HEAD查询、旧仓库、README/FD02或项目源更新。legal/Safety/no-processing及阶段边界保持。
Owner选择模型；本轮未修改模型配置或调用辅助代理，未补查完整模型/加载链。发布仅一个单父T候选、仅新增本报告；不自我接受、不更新main，完成即停止。
