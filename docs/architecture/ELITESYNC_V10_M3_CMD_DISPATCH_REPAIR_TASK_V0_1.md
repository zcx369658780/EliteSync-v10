# EliteSync v10｜批处理派发修复与无构建回归 v0.1

Status: `TASK ONLY — DISPATCHER REPAIR AND SYNTHETIC TESTS — NO REMOTESIGNED / TOOL COPY / SANDBOX / PUB / M3`
日期：2026-09-08（Asia/Singapore）。使用简体中文；Owner选择模型，不修改模型配置、不默认调用辅助代理。

## 1. 本轮要交付可用修复，不重新研究环境

005候选21377a071760ed931dd4773b9d389f68c2d243d3已由580e48bbfd1e4bb7d47e63f557baa78a8c7cdfed接受：本次策略、host/guest长路径自测、八项复制和客体Git/JDK验证通过；唯一pub派发在cmd包装层语法失败，Flutter/pub本体执行未证实，M3未启动。原始OFFLINE_PUB_INSUFFICIENT标签不是缺包证据。005窗口已正常关闭，不承诺临时副本可复用。

依Owner既有普通限定证据分析、可逆helper修复和自动续发授权，本轮直接定位自产派发代码、修复引号/命令行构造，用无构建批处理样本验证，并交付可复用代码及回归证据。不要只返回“应当修复引用”的计划，不复制SDK来验证一条命令能否启动，不重开策略/Git/长路径调查。

本任务没有任何进程策略例外。005的RemoteSigned只授予那张具名任务，不能据报告中的“不重批”文字扩大成后续所有任务许可。本轮正常命令编排只运行下面新授权的无害样本，不执行005/004的helper或工具载荷；后续真实隔离构建的进程条件须由其明确授权覆盖。当前修复无需Owner再次批准。

## 2. 固定GitHub入口与范围

仓库zcx369658780/EliteSync-v10。先实时核验main必须为A：
`580e48bbfd1e4bb7d47e63f557baa78a8c7cdfed`。
FIRST主动读取A中的`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，blob `18485c95262051e43892436fb52413132c5ee626`。历史startup不执行。
随后读取启动prompt固定的本任务commit/blob；核验唯一父A且只新增本任务文件。main/task/blob失配停止依赖动作，不自行换基线。
其余项目只读输入：A中的`AGENTS.md`（blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`）、`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_5.md`（blob `f5927cc0a5672208eec457a65e89959a8bcac124`）、同目录`ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_5.md`（blob `ee9a9a26406bb5a95059171250f552036721f06c`，仅§3/§4/§7/§8解释原合同）。可读A接受消息。无需读取CURRENT_CONTEXT、产品源码或全部历史任务；无本地Git操作。

## 3. 只读旧来源与小型新工作区

W5=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-005`。按需仅采用下列精确对象；先检查字面祖先无危险跳转，主体hash匹配才作精确005来源。旧文件不执行、不改写，使用过的旧来源首尾各核对一次即可。
| W5下路径 | SHA-256 | 用途 |
| --- | --- | --- |
| scripts/guest.ps1 | 701405E5B5FF33E542FB539C1EA7D6AC5D5F30B40B97EC2C998F0FF288BA52CB | 只审阅RunNative、批处理派发、pub错误分类及所需调用关系 |
| scripts/copy.ps1 | C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC | 仅在派发函数依赖此文件时读相关实现；不运行复制/自测 |
| evidence/result.json | 04578F2DFD5294992E586CDB6F6A5185C94749A11D2F27000960C4FBD99DC928 | 原始派发状态和host解释，不将日志标签当根因 |

来源缺失/hash变化保留旧状态并披露；仍可完成独立的合成派发验证，但不能声称已修复或精确复现005源代码。不得猜其他日志名、扫描目录或恢复旧guest。
新ID为M3-CMD-001；在同一批准父根下独占创建W=`D:/EliteSync-M3-readiness-v02/diagnostics/M3-CMD-001`。仅写W内scratch、evidence和draft。保留旧全部证据，不创建新M3-ISO目录。W冲突不覆盖、不换名；可以提交已有工具输出，但必须披露未持久保存新证据。
允许保存新诊断命令文本、合成.bat/.cmd样本、源码最小diff、修复片段及结果。不得生成可自动恢复旧任务的启动器。draft中的guest修改只作为文本patch，不执行；不用全套guest去跑一个小样本。

## 4. 修复目标与最小实现

先从绑定源码提取实际使用的进程创建API、exe、参数序列化、cwd和返回码处理，保存关键原行及推导后的完整命令行。仅凭005错误消息不足以确定在哪层丢引号；区分实际源代码事实、合成重现和推断。至多一次把旧序列化器用于本轮无害样本作为对照；不能将实际Flutter路径送给宿主cmd。

给批处理派发独立处理cmd的开关与/c命令字符串，不把适用于普通exe参数的“每项加引号”机械套到所有层。明确区分ProcessStartInfo.FileName/Arguments与Win32 CreateProcess的lpApplicationName/lpCommandLine；不得丢掉或重复加入错误位置的exe。
候选形式是固定cmd.exe开关`/d /s /v:off /c`加正确包围的单个命令字符串，其中批处理文件路径和各参数有各自引号。/d关闭AutoRun，/v:off避免延迟展开，/s有外层引号剥离语义。只有本轮真实样例通过才称为可用修复，不把文档示例当本机实测。

本轮只需支持已知pub参数`pub get --offline`和M3参数`build aar --no-debug --no-profile --no-pub`，以及合成空格/等号参数；005实际defines=EMPTY，不读取真实defines或secret。对未支持的嵌入引号、换行、NUL、百分号及其他shell控制字符先拒绝并给明确原因，不偷偷执行、吞字符或宣称万能转义。此限制只描述本轮已验证输入域，不修改v10产品或未来配置合同。
只改派发构造与准确错误分类；不要重写已通过的复制器、策略bootstrap、Job/超时控制或全部guest框架。修复后的本地patch需要体现保留这些控制，报告内附完整的最小替换片段和接入位置。不能只改异常名字掩盖派发问题。

## 5. 无构建样例必须实际执行

普通用户使用现有`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`的`-NoProfile -NonInteractive -Command`作可审阅的本轮小型编排，调用固定`C:/Windows/System32/cmd.exe`。不加ExecutionPolicy参数、不加载任何ps1、不执行旧helper正文、不换运行时规避拒绝。仅允许本轮新编写、无复制/无构建/无网络的派发与观测命令文本，以及新.bat/.cmd中的echo/setlocal/exit等基本操作。
样本只在W/scratch下命名的普通与带空格目录中创建，批处理只输出本轮nonce、受控参数和cwd，然后按样例返回固定代码。不得启动SDK/Flutter/Dart/Java/Gradle、外部服务、其他仓库脚本或任何真实依赖处理。

至少实际覆盖以下六组：
1. pub三个参数，目标有ENTERED标记，收到的参数顺序和值精确一致，exit=0。
2. M3五个参数，同样验证；这是假目标，不能记作M3启动。
3. 批处理路径及cwd均含空格，验证不是仅短路径偶然成功。
4. 合成`--dart-define=TEST_ONLY=value with space`保持为一个参数；仅合成字符串，不是005实际配置。
5. 目标输出ENTERED后故意exit /b 37，派发器必须保留37，不抹成0或“派发失败”。
6. 精确不存在的W内目标，必须没有ENTERED且返回明确派发失败；另对危险字符做纯内存拒绝测试，不执行注入字符串。

测试必须调用将来patch采用的同一命令行构造，并覆盖实际进程API的序列化边界。不能用另一条更简单的启动命令跑通后称原RunNative已修复。如原接口为Win32 CreateProcess，可为此编写只启动上述固定cmd样本的小型测试适配，必要时在本轮普通命令中Add-Type/PInvoke；TEMP/TMP和编译临时输出限W/scratch。不导入原helper、不给适配器运行任意目标的权限，不更改Job保护以求测试通过。标准加载/应用控制真实拒绝时停止该步骤，不绕行。
每次记录exe、精确Arguments或完整lpCommandLine、cwd、PID/创建时间、启动与ENTERED状态、原始stdout/stderr字节、实际exit和耗时。有参数表不足以替代最终传给OS的字符串。中文输出按实际编码解释，保留原始字节；JSON用序列化器。
每个假目标最多10秒，全部本地试验最多180秒。最多两轮针对具体派发/采证代码缺陷的修复，用已有数据优先重算；已通过的组仅在改动影响它时重测。不得在第一处普通语法错误就要求另开任务；也不为用满预算重复成功测试。到限保存真实状态并仅结束本轮拥有的进程，不按名字杀其他会话。

## 6. 成果、接入和唯一GitHub候选

必须交付：005源代码问题及证据强度、最小修复代码/patch、六组实测表、实际命令字符串与返回码、旧来源保护及本地文件hash。本地建议保存draft/dispatch-repair.patch、draft/dispatcher-snippet.txt和evidence/test-results.json；报告含足以复用的代码，不只链接一个未来会丢失的本地文件。不能上传无关helper全文、私密配置或全量日志。
结果区分`DISPATCH REPAIR VERIFIED — SYNTHETIC ONLY`、`DISPATCH REPAIR INCOMPLETE`或来源关联受限；即使全部PASS也不代表Flutter/pub本体运行、依赖充分或M3成功。模拟ENTERED不能复制为真实工具启动标志。后续实际pub失败必须分派发失败、工具启动已证实后的命令失败、未确定，只有缺包的真实诊断才可写OFFLINE PUB INSUFFICIENT。

只新增`docs/architecture/ELITESYNC_V10_M3_CMD_DISPATCH_REPAIR_RESULT_V0_1.md`；不改CURRENT_CONTEXT、AGENTS、原代码或历史报告。候选分支`review/m3-cmd-dispatch-repair-v0-1`，subject `docs: record verified batch-dispatch repair without a build`。一个commit、唯一父为本任务commit、单文件新增。报告代码和证据不能为压行数省略。
GitHub Git Database发布，不用本地index。发布前一次核验main/task；变化保留草稿，不自行重定基线；发布后一次核对单父、单路径、blob。执行者不自我接受、不更新main、不另发任务。独立接受沿用同tree提交，不增加closeout。
修复验证完成后结束；不顺手重启005，不创建永久环境、重新复制或执行真实pub/M3。任何后续具名RemoteSigned进程与真实构建须由后续明确授权覆盖，不能继承005一次例外。普通诊断无需重复批准，但不能把本任务当策略例外。

## 7. 机制依据与保护边界

作者2026-09-08定点核验以下官方机制：
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/cmd ：/c、/s、/d、/v及命令字符串引号语义。
- https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.processstartinfo.arguments?view=netframework-4.8.1 ：Arguments为单一字符串、目标程序解释参数，不能用抽象数组掩盖实际序列化。
执行者仅按实际接口问题补读对应Microsoft官方API，不进行新环境调查，不运行文档中的策略/注册表示例。官方机制与本地测试、历史结果分开。

原D:/EliteSync-v10内容、宿主SDK/cache、用户配置、旧evidence不写；README/FD02、旧仓库、全仓/磁盘枚举、默认index/受保护staged state、真实数据和生产访问禁止。无策略/模块路径/信任/签名/来源标记/系统设置变更，无提权/安装/下载/Bypass/Unrestricted，无新RemoteSigned或被拒载荷替代加载。legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36及产品实现边界保持。M3尚未启动，M2 deferred；不更新或上传ChatGPT项目源。