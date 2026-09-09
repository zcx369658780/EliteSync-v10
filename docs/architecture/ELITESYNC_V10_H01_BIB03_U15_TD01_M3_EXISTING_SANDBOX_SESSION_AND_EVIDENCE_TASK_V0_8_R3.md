# EliteSync v10｜现有 Windows Sandbox 会话识别、接管式续行与条件式 M3 v0.8-R3

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 激活、已接受事实与本轮唯一目标

当前 main `c051d6bf4d725672af4292b000c2829c067ea2b1` 已接受 v0.8-R2 失败记录。已接受事实：旧008 host ordinary native 4/4 与 batch 6/6证据继续有效且未重跑；dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`；v0.8-R2记录器 `M3-R2-LAUNCH-RECORDER-1` SHA-256=`103EE48EA240BD15735E601C5657653A25F0586275093FF988024B7CF5D12AB5` 的无害真实进程自测PASS；唯一Sandbox launcher PID=`41372`、creation UTC=`2026-09-09T04:46:13.1356631Z`、真实exit=`0`已可靠保存，但未建立匹配nonce的`guest.started`。这不证明Windows Sandbox不可用，也不证明guest已启动或隔离已建立。

Owner随后补充：该宿主同时只能运行一个Sandbox；Owner不会主动关闭现有Sandbox窗口；未来任务可检测并使用现有Sandbox。该补充是本任务新增的有界Owner权限：**允许只读识别当前唯一Sandbox会话，并在可建立明确Sandbox ID/会话句柄后，通过Windows Sandbox官方CLI对该现有会话进行任务专用共享与guest执行；不得关闭、停止、重置或销毁现有Sandbox，也不得把未知会话状态自动视为干净环境。**

本任务唯一目标：优先安全识别并使用当前已存在的唯一Windows Sandbox会话，建立可归属的guest执行链；只有该会话无法被官方CLI安全引用且确认当前没有运行Sandbox时，才允许按§6一次新建任务Sandbox。成功建立guest隔离与两类冒烟后，再继续八项复制、真实Git/Java、一次offline pub与条件式一次M3。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R3任务；允许只读检测当前唯一Windows Sandbox会话，并在官方`wsb` CLI可用、得到唯一running sandbox ID且隔离预检通过时，对该现有会话使用任务专用`wsb share`和`wsb exec`；不得stop/close/reset现有Sandbox。仅在本任务专用guest PowerShell进程使用进程级RemoteSigned，限定脚本路径/hash与生命周期。若没有可用现有会话且确认无running session，才允许一次新任务Sandbox。guest隔离与两类冒烟通过后，允许八项复制、Git/Java验证、一次offline pub及条件式一次M3。不改持久策略/组策略/信任/来源标记，不提权、不使用Bypass/Unrestricted，不下载，不写原仓库或宿主SDK/cache，其余边界不变。

无批准只报告`WAITING OWNER ACTIVATION`。本批准仅限v0.8-R3，不自动延续未来任务。

## 2. 固定 GitHub 入口与只读来源

仓库：`zcx369658780/EliteSync-v10`。开始实时读取main，必须恰为A=`c051d6bf4d725672af4292b000c2829c067ea2b1`。

FIRST主动读取A中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob=`18485c95262051e43892436fb52413132c5ee626`。

随后核验本任务ref/commit/blob、唯一父A、相对A仅新增本任务文件；失配停止依赖动作，不自行换基线。

其他GitHub只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，使用A中实际blob作为本轮候选更新基底。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R2.md` blob `03a05c1388e5530922df0ed48163098a5b64344b`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8_R1.md` blob `99b98bfc81e4dfe431d9b6919b35a2383204c8d4`，仅沿用host/runner与WSB静态合同。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md` blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`，仅沿用guest/复制合同。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。

不读取README/FD02/旧仓库，不仓库枚举、搜索或访问默认index/受保护staged state。

## 3. 现有008工作区与新证据目录

固定工作区继续为：`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。不得清空、覆盖、移动或改号规避。

新证据仅写：
`W/evidence/resume-r3/`。

只读绑定：
- `W/scripts/dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- `W/scripts/copy.ps1` 与v0.8-R2/v0.8-R1报告一致。
- 冻结guest脚本SHA-256=`578F97570EED07274A2E783730F5130126A5D12C8A03FA3F4B0E9A41C1889D39`；若本轮为兼容官方CLI挂载路径而只改bootstrap/路径参数，必须保存明确diff与新hash，dispatch主体不得改写。
- 旧008 host 4+6和resume-r1/r2证据只读，不重跑、不覆盖。

## 4. 官方 Windows Sandbox CLI 能力门

本任务允许定点检测Windows Sandbox官方CLI，不允许用进程名猜测会话身份作为最终控制句柄。

先在普通宿主环境只读/无副作用执行精确能力检查：
1. `Get-Command wsb.exe -ErrorAction SilentlyContinue`或精确等价，不递归搜索PATH/磁盘。
2. 若存在，记录resolved path、文件版本；运行`wsb --help`、`wsb list --help`、`wsb share --help`、`wsb exec --help`的帮助文本或`--raw`支持情况。帮助命令不创建/停止Sandbox。
3. 使用`wsb list --raw`（若本机版本支持；否则使用该CLI公开支持的list输出）一次，保存原始输出、解析结果、sandbox ID、state/status、uptime及CLI exit。

根据结果只允许：
- **EXISTING_SESSION_SINGLE**：恰好一个当前用户的running Sandbox，取得唯一Sandbox ID。继续§5。
- **NO_RUNNING_SESSION**：官方CLI明确返回0个running session。继续§6的一次新建路径。
- **MULTIPLE/AMBIGUOUS/CLI_UNAVAILABLE**：停止，分类`SANDBOX_SESSION_HANDLE_NOT_ESTABLISHED`；不得用Get-Process PID猜测后强行接管，也不得启动第二个Sandbox。

Owner关于“宿主同时只能运行一个Sandbox”的说明是本轮决策输入；仍需用官方CLI得到可调用Sandbox ID后才能执行share/exec。

Microsoft公开文档当前说明：Windows Sandbox CLI可`list`当前用户会话并返回Sandbox ID；`share`可给指定sandbox ID共享host folder，未指定`--allow-write`时保持只读；`exec`可在指定ID中执行命令；`stop`会终止会话。本任务明确禁止任何`wsb stop`。

## 5. 使用现有 Sandbox：先最小证据共享，再隔离门

当§4得到唯一running Sandbox ID时，不先共享SDK、缓存、模块或工具。现有会话状态未知，先只共享任务自有新证据目录与最小bootstrap：

- Host `W/evidence/resume-r3/` → Sandbox `C:/M3R3/evidence`，此一项允许`--allow-write`。
- Host中任务自产guest bootstrap/控制脚本目录 → Sandbox `C:/M3R3/bootstrap`，只读，不加`--allow-write`。

每次`wsb share`保存：sandbox ID、host path、sandbox path、allow-write是否启用、CLI exit。不得共享用户目录、原仓库、SDK/cache等尚未通过隔离门的输入。

随后用`wsb exec`针对该唯一Sandbox ID执行**最小guest preflight**，优先`-r System`，因为官方CLI允许System上下文且无需依赖已有交互登录会话；仅该guest PowerShell进程使用：
`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -NonInteractive -ExecutionPolicy RemoteSigned ...`

`wsb exec`本身不依赖stdout作为证据；guest必须把结果写入`C:/M3R3/evidence`共享目录。使用新nonce `M3-ISO-V02-008-R3-<random>`，host侧先保存sandbox ID+nonce绑定，再exec。

preflight只验证：
- guest脚本实际进入并写`guest.started`，nonce与sandbox ID绑定一致；
- Windows PowerShell版本；Process/effective=`RemoteSigned`；
- Security模块Name与精确Path门；
- 活动网络适配器为0且默认路由为空；
- `C:/M3R3`任务命名空间此前不存在或仅包含本任务刚共享的bootstrap/evidence映射；不得删除未知guest状态来制造“干净”。

若网络隔离不通过，立即停止，不共享任何SDK/cache/module/tool输入，不动态修改网络设置。

若`wsb exec`无法启动System guest、sandbox ID失效、share失败或guest.started未出现，保存CLI原始exit/输出与当前`wsb list`一次复核，分类`EXISTING_SANDBOX_GUEST_CONTROL_NOT_ESTABLISHED`；不得stop现有Sandbox，也不得在同任务另起新Sandbox。

## 6. 无现有会话时的一次新建路径

仅当§4由官方CLI明确证明`NO_RUNNING_SESSION`时才允许一次新任务Sandbox。优先使用本机已确认可用的官方`wsb start --config`能力；若本机CLI不支持start/config，则沿用v0.8-R2已验证的`.wsb`精确入口。

新建时必须继续满足：Networking/Clipboard/Audio/Video/Printer/VGpu Disable；八项输入不在启动前直接暴露，先仅task-owned evidence/bootstrap；得到Sandbox ID/guest.started并通过网络门后再共享剩余输入。

一次新建后不得第二次重试。若start返回ID而guest控制未建立，按新鲜证据分类停止。

## 7. guest两类冒烟与八项输入

§5或§6的guest preflight通过后，才将已有八项输入逐项共享/复制到任务专用`C:/M3R3`命名空间：
- 对官方CLI `wsb share`可直接满足只读语义的输入，优先使用只读share；
- 对必须落到guest本地磁盘且已在007/v0.5通过robocopy合同的输入，可从只读share复制到`C:/M3R3`任务目录；不得改写host来源。
- 唯一可写host共享仍是`resume-r3` evidence。

真实工具前，guest使用同一dispatch字节完成：
1. ordinary native无害参数冒烟，`override_present=false`且参数进入OS；
2. batch pub/M3形状及exit37冒烟。

两类PASS后才执行真实Git `--version`、Java `-version`各一次；记录RunNative收到参数、override=false、最终Arguments、actual executable、stdout/stderr（由guest证据文件记录）和exit。任一失败停止pub，不重新寻找Git/JDK。

## 8. offline pub、M3与AAR

Git/Java成功后，guest工作目录使用本任务专用模块副本路径，并将先前固定合同映射到R3命名空间；不得直接复用未知guest历史工作目录。

执行：
1. `flutter.bat pub get --offline` 至多一次，10分钟。
2. 仅pub成功后，`flutter.bat build aar --no-debug --no-profile --no-pub` 加绑定defines数组，至多一次，30分钟。

不联网、下载、安装、修改Wrapper/SDK/产品源码或重试。真实entry与dispatch分开记录；只有真实缺包/解析诊断才能标`OFFLINE_PUB_INSUFFICIENT`。

仅M3实际启动后一次检查本任务R3命名空间内对应精确AAR路径；报告必须同时给出该R3实际路径与它相对既有direct-AAR合同的映射关系。HIT记录size/SHA-256；未启动保持NOT_CHECKED；不搜替代。M2不执行。

## 9. 现有Sandbox生命周期边界

如果使用的是Owner现有Sandbox：
- **不得调用`wsb stop`、不得关闭窗口、不得终止Sandbox会话进程**；
- 本任务只停止/等待自己通过`wsb exec`创建的guest子进程，并取消/结束本任务新增共享或控制动作中可安全释放的task-owned句柄；若CLI没有unshare能力则记录共享仍存在，不通过stop清理；
- evidence完成后明确报告该现有Sandbox仍由Owner控制。

如果§6新建的是本任务Sandbox，则沿用007/R2任务进程收尾合同正常关闭本任务实例，但不得按名字影响其他会话。

## 10. 结果与候选

本地新证据仅写`resume-r3`。报告必须明确：
- `wsb.exe` resolved path/version/help能力；
- `wsb list`原始/解析结果与sandbox ID；
- 使用existing还是new-session路径；
- 每个share的host/sandbox path与write语义；
- exec command、run-as、CLI exit、guest.started/nonce关系；
- guest策略、网络隔离、两类冒烟；
- 八项输入、Git/Java、pub/M3/AAR；
- 若使用existing session，明确未stop/未关闭Owner Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-existing-sandbox-session-v0-8-r3`。

一个commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_SANDBOX_SESSION_AND_EVIDENCE_RESULT_V0_8_R3.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从本任务固定main A中的干净UTF-8版本开始更新；禁止从历史损坏blob构造；发布前检查UTF-8与明显mojibake。

发布后只核验一次parent/两路径/blob。执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。

## 11. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36和产品实现边界保持。除本任务具名guest PowerShell进程级RemoteSigned外，不改持久策略/信任/系统配置；不下载、不真实数据、不生产访问。宿主SDK/cache和原仓库不写。