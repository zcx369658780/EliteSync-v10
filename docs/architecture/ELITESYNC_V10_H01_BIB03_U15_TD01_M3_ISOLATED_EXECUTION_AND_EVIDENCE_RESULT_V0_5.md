# EliteSync v10｜进程级RemoteSigned与隔离M3续行结果 v0.5

Status: `PROPOSED — AWAITING INDEPENDENT REVIEW — NO M2 OR PRODUCT IMPLEMENTATION AUTHORITY`

最终分类：**M3 PRECONDITION BLOCKED — PUB COMMAND DISPATCH FAILURE**。
本轮宿主/客体RemoteSigned准入、长路径自测、八项输入复制及客体Git/JDK验证通过；唯一pub启动调用在cmd命令行派发阶段exit=1，尚无Flutter/pub实际执行证据。不能认定离线缺包。M3未启动，AAR=NOT_CHECKED。
Attempt=M3-ISO-V02-005；日期2026-09-08（Asia/Shanghai）。不是生成成功或M2成功。

## 1. 固定身份与授权

main A=0a7d18e762581a491bee253361cead56d49d47b0实时匹配。FIRST交接blob 18485c95262051e43892436fb52413132c5ee626匹配，历史startup未执行。
task/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-5指向T=05511d43cbedd5c67209c0c747b10991188c8a91，任务blob ee9a9a26406bb5a95059171250f552036721f06c。T唯一父A，且仅新增任务单。
A中AGENTS、CURRENT_CONTEXT、POLICY-003结果、004结果、v0.4任务及两个Android合同输入blob均按任务§2匹配。仅采用许可内容，不跟进引用或读取旧仓库。
Owner本任务批准专用宿主自测/沙箱客体入口进程级RemoteSigned；未重复申请，未设置整个Codex或宿主编排环境，未改变持久scope、组策略或信任。
POLICY-003策略诊断已由A接受关闭；003/004历史分别保留其原有有限含义。本轮没有重做Git发现、策略治理或系统修复。

本地root D:/EliteSync-v10，origin=git@github.com:zcx369658780/EliteSync-v10.git；HEAD=d1b45cc5da30bba3f377ef4ead2c677d0fb6eb88仅作上下文。
A对象最初不可用，必要fetch --no-tags --no-recurse-submodules origin refs/heads/main:refs/elitesync/m3-iso-v02-005-input；输入ref核验恰为A，Git同时按既有映射更新origin/main。未切换/清理工作区，无status或默认index操作。

## 2. 来源保护、脚本和加载合同

W=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005，字面祖先安全，开始时不存在并独占创建。旧input/标志/客体均不复用。
仅采用两项旧来源，开始和结束主体hash均匹配：
- D:/EliteSync-M3-readiness-v02/diagnostics/M3-POLICY-003/observation.json：E53D19BCFC78AF2A8DB2FE91D34D894C86B86BB22C662ED94A52802443FA1A56。
- D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-004/scripts/copy.ps1：9177A1B3A713F1414E6846BCACAD77773CEFE19E24E5FBB81FC81E9A9C397CCD。
旧脚本仅审阅/派生，不直接执行或修改。其Zone.Identifier精确读取返回流不存在；未读URL、删ADS、解锁或绕过来源/签名检查。新脚本及部署副本采用正常文件写入/复制，未消除已有来源限制。

| 实际执行脚本（相对W） | SHA-256 | 用途与加载关系 |
| --- | --- | --- |
| scripts/host-selftest.ps1 | 4907E638B03A1717D215546621603BDA11DD78A28CEA11094403A7F3162AA8A8 | 两轮专用宿主入口；正常dot-source本轮绑定copy |
| scripts/copy.ps1，首轮 | 7F5AE4E8A0B3A1C642070B31499FC889F9FD30FBC6C2B82283D2E04B4AED7284 | 旧起点改attempt标识并用UTF-8 BOM；原版本保存在evidence/copy-round-1.txt |
| scripts/copy.ps1，最终 | C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC | 一次摘要汇总纠错；第二轮通过后冻结 |
| scripts/guest.ps1与input/runner/guest.ps1 | 701405E5B5FF33E542FB539C1EA7D6AC5D5F30B40B97EC2C998F0FF288BA52CB | 审阅版/只读部署副本字节一致；guest bootstrap正常调用 |
| input/runner/copy.ps1 | C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC | 与最终宿主版本一致；guest正常dot-source |

PowerShell 5.1语法校对通过。新实现仅为本任务复制、自测、日志、条件执行及进程Job管理；没有产品源码修改。bootstrap预期hash使用启动前确定的字面值，脚本加载前检查精确文件/hash/reparse；嵌套copy hash也独立检查。ModuleBase/Version只记录，不加错误门槛。
宿主TEMP/TMP仅在专用进程设为W/scratch/tmp；guest为C:/M3/tmp。原生复制器固定System32/robocopy.exe，基准参数/R:0 /W:0等沿任务；无删除/移动/提权/自动重试选项。启动后未热修脚本、SDK、Wrapper或命令。

## 3. 实际策略与自测

宿主两个自测入口及guest入口均使用各自C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe：
-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned -Command，正常系统Security manifest导入、Name/精确Path绑定后查询策略，再正常加载已绑定脚本。实际版本5.1.26100.9168。
三次专用入口观测相同：MachinePolicy/UserPolicy/CurrentUser/LocalMachine=Undefined，Process=RemoteSigned，effective=RemoteSigned；无管理策略拒绝。
普通宿主收尾查询无ExecutionPolicy参数，五个scope均Undefined、effective=Restricted，exit=0。仅对照，没有“恢复”或重写设置。

| 自测 | 实际结果 |
| --- | --- |
| host第1轮，PID36376 | 原生长路径复制exit=1，文件已复制；自有Measure-Object对hashtable摘要的Property处理报PSArgumentException，HResult=-2147024809；wrapper exit=1 |
| 一次纠错 | 保存首轮脚本/错误，确认进程结束；仅改failed/mismatch/extras为显式数值字段求和，不改真实输入 |
| host第2轮，PID45416 | PASS，wrapper exit=0；源/目标绝对路径395字符，中文/空格、已知内容hash均通过；长复制exit=1，负例exit=16且准确记录不存在源 |
| guest，同控制器PID10992 | PASS；同类Win32 Unicode扩展路径合成测试，真实工具复制前完成 |
| 分类 | 覆盖0/1/7/8/16；0–7还结合摘要，额外测试7伴mismatch/extras时拒绝；8/16拒绝 |

已知内容SHA-256=CA0F203DA1D5F25BAE800BBD65DB12D952261A4E980D68DB008CA3CE1893F75D。复制后摘要与native元数据检查通过；合成文件保留，未清理。
宿主专用自测共2轮、允许纠错使用1轮；首轮不是策略拒绝或原生复制失败。另有宿主普通编排文本在派发前的语法错误，经修正才执行，不计成Sandbox/pub/M3重试。没有重复成功查询来填满预算。

## 4. 固定输入、隔离与真实复制

A的apps/flutter_elitesync_module Git对象机械过滤物化：526文件、1排除项，排除旧输出/元数据及README类、FD02、保护/凭据/数据/日志对象；拒绝穿越/链接；未分析业务代码。runner明确为自产辅助输入。defines按许可键顺序解析，结果EMPTY、0项。
具名七个工具/seed根及祖先安全检查通过；Git直接采用C:/Program Files/Git，不重新发现或回退旧默认.gradle。未导入宿主Gradle顶层配置/凭据/daemon或用户Git配置。
m3.wsb SHA-256=5A9A7943668D3883867DD9E94EFD053396880929B97514EF50DE90DCDA4F4817。9个映射经XML回读：8输入只读，唯一可写W/evidence→C:/M3/e；六项Networking/Clipboard/Audio/Video/Printer/VGpu均Disable。未映射整仓、用户根、旧根或整个GradleHome。
只提交一次新Sandbox，宿主PID41064；同次会话PID42404、parent41064、创建05:53:49.6602280Z。没有复用或处置003窗口。
nonce=m3-005-1788846795441-c32e40666d1ca8，guest匹配；2026-09-08T05:54:11Z客体活动适配器0、默认路由空，与冻结禁网配置共同支持本次控制通过。无ping/DNS/HTTP或宿主seed试写。

| copy_id | 原生exit | copied文件数 | copied bytes |
| --- | --- | --- | --- |
| module | 1 | 526 | 3233801 |
| flutter | 1 | 17932 | 3230107924 |
| android | 1 | 103648 | 9759961961 |
| java | 1 | 492 | 317293526 |
| git | 1 | 9311 | 419706698 |
| pub-seed | 1 | 82432 | 1668056282 |
| gradle-cache | 1 | 57859 | 8416661749 |
| wrapper | 1 | 67592 | 1976278523 |

八项failed/mismatch/extras均0，原生摘要与安全检查均通过；不以文件数表示产品进度。每项源/目标、PID/创建时间、参数、start/end、elapsed和UNILOG保存在本地。准备从05:54:08到06:01:25，未超过30分钟；无5分钟无进展状态或超时。
客体Git --version exit=0：2.53.0.windows.1；java -version exit=0：Temurin 17.0.18+8。这些不证明所有依赖充分。

## 5. pub派发失败、M3及AAR

06:01:25Z唯一启动调用记录：exe=C:/Windows/System32/cmd.exe，参数数组[/d,/s,/c,C:/M3/t/f/bin/flutter.bat pub get --offline]，cwd=C:/M3/w/apps/flutter_elitesync_module；原生PID9636，exit=1，约0.054秒，无超时。
自有RunNative统一为各参数加引号。保存的原始stderr为90 bytes，按CP936解读为：
> 文件名、目录名或卷标语法不正确。
> 处理: .exe /d /s /c C:/M3/t/f/bin/flutter.bat 时出错。

stdout为空；没有Dart/pub依赖解析输出。可证失败对象是该cmd派发包装，不能将exit归为真实pub依赖不足。冻结guest通用throw名称OFFLINE_PUB_INSUFFICIENT不是事实根因；原始guest结果另存guest-result-raw.json，最终result的host_assessment明确纠正解释，未倒写原日志。
pub启动调用次数1；Flutter/pub本体执行NOT_ESTABLISHED。没有联网补包、换命令或重试。M3启动次数0、exit=null；AAR探测次数0、NOT_CHECKED，size/SHA-256=null；无Maven导出。005生成证据HIT条件不成立，M2证据条件不具备。

## 6. 进程生命周期与保存

客体Job将控制器及其正常子进程纳入同一归属范围，设置kill-on-job-close。收尾查询job_ids_before_finish与job_ids_at_finish都仅[10992]，没有工具子进程；guest-script-exit记录exit=1。
宿主自测控制器退出、已记录原生复制PID/创建时间定点检查无存活同一进程及其子进程。未仅用父PowerShell退出推断所有工具已停。
终态后核对本次Sandbox会话PID42404创建时间/父链一致，正常CloseMainWindow返回true；06:02:43Z同会话进程已不存在。收尾约78秒，未超过5分钟；未按名字全局终止进程，未关闭其他会话。外层看门狗按任务期限监控，终态自然退出。
普通宿主对照策略为Restricted；本任务RemoteSigned进程与归属会话生命周期已结束，无持续运行的本次工具树证据。

证据根W/evidence，含host/guest日志、两轮自测及版本绑定、原生copy日志、冻结配置/脚本、policy、nonce、输入manifest、工具/pub原始字节、归属/关闭/普通策略及旧来源保护。
result.json SHA-256=04578F2DFD5294992E586CDB6F6A5185C94749A11D2F27000960C4FBD99DC928。
host-2-selftest.json=EF577ACC63D29FEC2A49343D193D5B199789DBCA25FA8B5A0E4B18C829C59DCD。
guest-selftest.json=276D191F2365F0E713896E627D656CDA682744DF679B8FD7A2877746DD03360B。
lifecycle-final.json=8B1B4534298BFBE6457A3D61F994EE68B71FE2E458EB1A132F28DDDC996C409B。
其余摘要见final-evidence-hashes.json。PowerShell结构化输出UTF-8；cmd本地化错误原始字节保留，CP936解码解释另存，未伪造UTF-8文本。JSON序列化/反解析，路径保留盘符；日志/cache/源码/脚本/AAR不上传GitHub。

## 7. 最小剩余问题与边界

本轮已取得策略、自测、复制和工具可运行证据；剩余具体缺陷是自有cmd批处理派发参数构造。后续若另行续行，应先以自有无构建小样本验证正确的cmd引用合同，不能用再次全量复制替代该验证；本轮冻结后不修复/重跑，不默认再发仅改编号的复制任务，不重开策略治理或重复申请已批准条件。
长路径修复证据不等于pub/M3完成；真正离线依赖充分性仍未知。没有证据支持安装、下载或更改系统/SDK/Wrapper。
CURRENT_CONTEXT仅页首/§1/§4/§5更新，§2/§3/§6/§7原文保留。旧保护文字的本次例外由固定v0.5及Owner批准解释，不倒写历史、不改AGENTS。
README/FD02、旧仓库、默认index/受保护暂存状态、legal/Safety/no-processing及各未授权阶段边界保持。无产品实现、M2或项目源更新；原仓库内容、宿主seed和用户配置未写。正常Sandbox/系统模块运行记录不宣称全宿主绝对零写入。
Owner选择GPT-6 Astra；未修改模型配置、未调用辅助代理，未额外证明运行model ID/完整加载链，不宣称整仓clean或自动重载。
一个候选、唯一父T、恰好两路径；独立审查前不自我接受、不更新main。发布核验后停止。
