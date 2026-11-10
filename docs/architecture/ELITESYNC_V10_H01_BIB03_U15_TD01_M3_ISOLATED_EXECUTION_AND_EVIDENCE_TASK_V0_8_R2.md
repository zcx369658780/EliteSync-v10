# EliteSync v10｜Sandbox 启动采证链修复与条件式隔离 M3 v0.8-R2

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 激活、已接受事实与唯一目标

当前 main `f7939bff46326eef2d41cc27b302f48d60b8568b` 已接受重封装后的 v0.8-R1 失败记录。已接受事实：旧008 host ordinary native 4/4 与 batch 6/6 证据已只读绑定且未重跑；dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；固定对象526文件、defines=EMPTY、runner与WSB静态合同通过。v0.8-R1仅调用一次Sandbox；`Start-Process`返回后，自有记录代码把PowerShell布尔字面量写成`true`而不是`$true`，在PID/创建时间/exit可靠落盘前失败；没有建立`guest.started`或guest result。此记录不证明Windows Sandbox不可用，也不证明guest启动失败；launcher精确exit为UNKNOWN。guest/复制/Git/Java/pub/M3均未运行，AAR=NOT_CHECKED，M2 deferred。

本任务只修复**Sandbox启动与采证编排链**，并在修复经无害本地自测后进行一次新的Sandbox续行。不得重跑host 4+6，不重写dispatch、copy、策略方法或cmd引用算法，不重新调查Git/JDK/SDK/cache。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R2任务；仅在本任务专用验证进程和沙箱客体入口进程使用RemoteSigned，限定脚本路径/hash与生命周期；允许在既有`M3-ISO-V02-008`工作区新增`resume-r2`证据，先用无害系统进程验证Sandbox启动记录器，再启动一次新Sandbox；guest两类冒烟通过后执行八项复制、Git/Java验证、一次离线pub及条件式一次M3。不改持久策略/组策略/信任/来源标记，不提权、不使用Bypass/Unrestricted，不下载，不写原仓库或宿主SDK/cache，其余边界不变。

无批准只报告`WAITING OWNER ACTIVATION`。本批准仅限v0.8-R2，不自动延续未来任务。

## 2. 固定 GitHub 入口与只读来源

仓库：`zcx369658780/EliteSync-v10`。开始实时读取 main，必须恰为 A=`f7939bff46326eef2d41cc27b302f48d60b8568b`。

FIRST主动读取A中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob=`18485c95262051e43892436fb52413132c5ee626`。

随后核验本任务ref/commit/blob、唯一父A、相对A仅新增本任务文件。失配停止依赖动作，不自行换基线。

其他GitHub只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，使用A中实际blob作为本轮候选更新基底。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R1.md` blob `99b98bfc81e4dfe431d9b6919b35a2383204c8d4`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_8_R1.md` blob `58cbfef2a382ae7aeeb78f17e1819fb0761ac251`，仅沿用已接受的隔离/复制/生命周期合同。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md` blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`，仅沿用007复制/guest环境基线。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。

不读取README/FD02/旧仓库，不仓库枚举、搜索或访问默认index/受保护staged state。

## 3. 复用既有008工作区，不覆盖旧证据

固定工作区：`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。本任务明确允许该目录存在；不得清空、覆盖、移动或换号规避。新增证据仅写：
`W/evidence/resume-r2/`。

只读核验并绑定现有：
- `W/scripts/dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- `W/scripts/copy.ps1` 与v0.8-R1结果记录一致。
- v0.8-R1冻结guest脚本SHA-256=`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`，如本轮仅修启动器而guest内容无变化则必须保持该hash。
- 旧008四份host证据与v0.8-R1结果中的SHA-256一致；不得重跑host 4+6。

旧`resume-r1`证据只读，不能改写。若来源hash失配，停止对应复用，不搜索替代。

## 4. 启动记录器最小修复与无害自测

本轮新增/修改的启动记录器只能解决v0.8-R1已报告的采证缺陷及其直接可靠性问题，不得改Sandbox安全合同。

启动序列必须满足：
1. 构造`Start-Process -PassThru`或等价返回`System.Diagnostics.Process`的调用。
2. **取得Process对象后，在进入任何复杂格式化、布尔字段计算、nonce等待或轮询前，立即提取并同步保存最小原子身份记录**：`pid`、可取得的`StartTime/creation_utc`、调用时间、目标可执行、参数/WSB路径、nonce、记录器版本/hash。
3. 该最小身份记录使用简单原生.NET/JSON路径，布尔值必须使用PowerShell合法`$true/$false`或直接避免布尔字段；不得让附加字段序列化失败阻止PID身份落盘。
4. 保存后立即回读并解析一次，确认PID为正整数且nonce/WSB/hash匹配，然后才进入guest nonce等待。
5. 进程exit仅在其真正结束后更新；启动后尚运行时不得伪造exit=0。若Process对象后续访问失败，保留已经写入的身份记录并单独记录失败。

在启动Sandbox前，必须用**无害系统进程**实测同一启动记录器边界一次，例如精确`C:/Windows/System32/cmd.exe`执行一个无副作用的立即退出命令。要求实际返回Process、原子身份记录先落盘、回读成功、最终exit被后续补录。该自测不使用Sandbox，不代表Sandbox成功。

该记录器自测允许至多两次针对自有代码/采证错误的定点纠正；真实权限/系统拒绝不得绕过。自测成功后冻结记录器脚本hash。不得因为记录器自测而重跑dispatch host 4+6。

## 5. 一次新 Sandbox 与guest前置

只有§4记录器实测PASS后，启动**一次**新Windows Sandbox。沿用v0.8-R1/v0.7静态合同：Networking/Clipboard/Audio/Video/Printer/VGpu全部Disable；八项宿主输入ReadOnly=true；唯一宿主可写映射为`W/evidence/resume-r2/`到guest证据目录。使用新nonce。

宿主必须先完成§4原子身份写入并回读，再等待`guest.started`。等待最多5分钟；不得因日志格式化错误丢弃已保存PID。若Sandbox进程在guest.started前退出，保存实际exit和进程身份；若仍运行而nonce未出现，分类`GUEST_STARTUP_NOT_ESTABLISHED`并按任务拥有的进程规则正常收尾。不得自动第二次启动Sandbox。

只有guest.started建立后才读取guest结果。guest必须实际验证：
- Windows PowerShell 5.1专用Process/effective=`RemoteSigned`；
- Security模块Name/精确Path门；
- nonce匹配；
- 活动网络适配器0、默认路由空；
- 同一dispatch字节；
- ordinary native无害参数冒烟，`override_present=false`且参数进入OS；
- batch pub/M3形状及exit37冒烟。

两类冒烟及隔离门均PASS后才复制。

## 6. 八项复制、真实工具、pub与M3

沿用007/v0.5已验证八项复制与robocopy合同，不重做算法研究。复制后真实执行一次：
- Git `--version`
- Java `-version`

必须记录RunNative收到参数、`override_present=false`、最终Arguments、actual executable、stdout/stderr和exit。任一失败则停止pub，并按真实错误分类；不重新寻找Git/JDK。

Git/Java成功后，guest cwd=`C:/M3/w/apps/flutter_elitesync_module`：
1. `C:/M3/t/f/bin/flutter.bat pub get --offline` 至多一次，10分钟。
2. 仅pub成功后，同batch执行 `build aar --no-debug --no-profile --no-pub`，加已绑定defines数组，至多一次，30分钟。

不联网、下载、安装、修改Wrapper/SDK/产品源码或重试。真实entry与dispatch分开记录；只有真实缺包/解析诊断才能标`OFFLINE_PUB_INSUFFICIENT`。

仅M3实际启动后一次检查精确AAR：
`C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录size/SHA-256；未启动保持NOT_CHECKED；不搜替代。M2不执行。

## 7. 结果与候选

本地新证据只写`resume-r2`。报告必须区分：已接受v0.8-R1失败事实、旧host证据复用、本轮记录器自测、本轮唯一Sandbox、guest/复制/真实工具/pub/M3新鲜证据。

候选分支：`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-8-r2`。

一个commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R2.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从本任务固定main A中的干净UTF-8版本开始更新；禁止从历史损坏blob构造。发布前检查UTF-8与明显mojibake。

报告返回：记录器修复片段/hash、自测结果、Sandbox PID/creation/exit及nonce关系、guest两类冒烟、隔离、八项复制、Git/Java、pub/M3/AAR、进程收尾和证据限制。发布后只核验一次parent/两路径/blob。执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。

## 8. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36和产品实现边界保持。除激活后本任务专用RemoteSigned外，不改持久策略/信任/系统配置；不下载、不真实数据、不生产访问。宿主SDK/cache和原仓库不写。