# EliteSync v10｜原生参数派发修复与条件式隔离 M3 v0.8

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不改模型配置、不默认调用辅助代理。ChatGPT负责规划与独立验收。

## 1. 激活、目标与范围

007候选 `940d8870d9f80af4aaabf3dba02d3c20de7616dd` 已由 `146d6e9eb1219314eaa14e3a1579426dd4ababe8` 接受为失败记录。已接受事实包括：host三轮最终六组派发集成PASS；一次新Sandbox的RemoteSigned/禁网/nonce/guest同派发器冒烟PASS；固定模块物化和八项输入复制PASS。真实pub、M3、AAR均未启动。

新增具体缺陷仅在共享 `RunNative` 普通exe分支：PowerShell 5.1 将 `[string]$SerializedArguments=$null` 绑定为 `''`，导致 `if ($null -ne $SerializedArguments)` 为真，空覆盖值压过 `ArgumentList`。因此Git `--version` 与Java `-version`虽传入函数，最终OS参数为空并显示usage。此结果不推翻CMD-001及007的批处理派发PASS，也不是Git/JDK损坏。

本任务把最小修复、host原生参数回归、同一runner guest冒烟与条件式真实执行合并。不得重开策略/Git发现/长路径/cmd引号研究，不重写已通过的批处理构造或复制器。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8任务；仅在其专用宿主自测和沙箱客体入口进程使用RemoteSigned，限定脚本路径、hash与生命周期；批准新建008工作区，修复RunNative可选SerializedArguments语义并验证普通exe参数派发，通过后执行一次禁网隔离准备、一次离线pub及条件式一次M3。不改持久策略/组策略/信任/来源标记，不提权、不使用Bypass/Unrestricted，不下载，不写原仓库或宿主SDK/cache，其余边界不变。

无批准只报告 `WAITING OWNER ACTIVATION`，不开始本地步骤。批准只限v0.8，不自动延续未来任务。

## 2. 固定入口与精确只读输入

仓库 `zcx369658780/EliteSync-v10`。开始实时读取main，必须为 A=`146d6e9eb1219314eaa14e3a1579426dd4ababe8`。
FIRST主动读取A中的 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob `18485c95262051e43892436fb52413132c5ee626`。历史startup不执行。
随后核验本任务ref/commit/blob、唯一父A和单文件新增范围；失配停止依赖动作，不自行换基线。

其他仓库读取仅限A中的：
- `AGENTS.md`，blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，blob `5ef59aa9e6ad12b03ad34ab335b461fa68bbe5c9`，仅作为本轮指定更新对象。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md`，blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_TASK_V0_7.md`，blob `cf7b9f29cc0b0ed81a764239fdf17a34eeb86e33`，仅沿用已通过的策略/隔离/复制/生命周期控制，差异以本任务为准。
- `docs/architecture/ELITESYNC_V10_M3_CMD_DISPATCH_REPAIR_RESULT_V0_1.md`，blob `d1b0fd080665df717b237de44ad47b6285289ace`，仅保留批处理构造支持域。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。

不读取README/FD02/旧仓库，不枚举仓库。必要固定对象fetch只到声明ref，不status/index/checkout/pull/reset/stash/clean。

## 3. 新工作区与来源绑定

激活后独占创建 `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`，Attempt=`M3-ISO-V02-008`；仅在该W写input/scripts/scratch/evidence/m3.wsb及自产文件。W存在则不覆盖、不清理、不换号规避。

只读采用007最终来源，开始/结束各核对hash：
- `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-007/scripts/copy.ps1` = `C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`
- `.../scripts/dispatch.ps1` = `8AE2F95549921F5DF6A7249F9E8549462506883AB620603A61846F1E5A1D2A29`
- `.../scripts/host-selftest.ps1` = `C1F575B07F3927FA93D5C72BD2CE667B1CB4ECFC15604D311B0F215CB1BFDEC0`
- `.../scripts/guest.ps1` = `6A4A8C5750AC5BD952524834DFAC9A16C848963BDC28B7B4E25DEA6DEEE8ACCC`
- `.../evidence`中用于本缺陷的最终native-tool记录只按007报告精确定位；不得列目录倒推。

允许审阅上述自产脚本仅用于修复RunNative的可选参数覆盖、host/guest调用点、Job/timeout/日志；不扩大产品源码分析。缺失/hash不符停止对应复用，不搜索替代。

## 4. 最小代码修复：显式区分“无覆盖”和“空覆盖”

不得继续用 `[string]$SerializedArguments=$null` 的值本身判断覆盖是否存在。使用显式存在性语义，推荐二选一且必须实测：

A. `RunNative` 增加 `[switch]$UseSerializedArguments`，只有该switch为真时使用 `$SerializedArguments`；`RunBatch` 传switch，普通exe分支不传。

B. 以 `$PSBoundParameters.ContainsKey('SerializedArguments')` 判断调用方是否显式提供覆盖；调用方普通exe不提供该键，RunBatch明确提供。若采用B，必须证明splatting时键是否存在与期望一致。

优先A以降低歧义。不得用空字符串、特殊哨兵文本或再次依赖类型转换推断“未提供”。

普通exe分支仍使用 `ArgumentList`并记录函数接收数组、最终Arguments字符串；批处理分支仍使用已接受的New-BatchArguments与单一serialized字符串，不改支持域。参数名继续避开PowerShell自动变量。

## 5. Host先做两类真实无构建回归

在专用RemoteSigned host自测进程内，加载本轮实际dispatch.ps1，并使用同一RunNative边界完成：

1. 普通exe参数回归：仅调用 `C:/Windows/System32/cmd.exe` 的无害参数形状或本轮自有小目标，证明普通分支 `ArgumentList` 实际进入OS；至少覆盖单参数、双参数、空参数数组及固定非零exit传播。记录调用者数组、函数接收数组、override_present、最终Arguments、PID/exit/stdout/stderr。
2. 批处理六组回归：沿用已接受支持域，确保此次RunNative修改未破坏pub/M3形状、spaces、define、exit37、missing六组。

测试fixture必须使用具名字段对象和命名splatting；不得用位置嵌套数组。假目标无条件ENTERED，exit37无条件37。纯自有代码/采证错误允许最多两轮纠错、最多三个host自测进程；每轮先保存版本和错误。真实策略/hash/权限拒绝不得绕过。

最终host必须两类均PASS才冻结。若普通exe仍丢参，必须保存最终OS字符串/错误，不启动Sandbox。

## 6. 冻结、Sandbox与guest验证

沿用007已验证的Process RemoteSigned、Security模块Name/精确Path、脚本hash绑定、Job/timeout、禁网WSB和八输入只读映射。新脚本先PowerShell 5.1 AST校对，host/guest部署同一dispatch.ps1字节。

一次新Sandbox。要求本次nonce、Process/effective=RemoteSigned、无活动网络适配器和无默认路由；不ping/DNS/HTTP。guest在复制真实工具前，用同一dispatch.ps1做：
- 批处理pub/M3/exit37假目标冒烟；
- 普通exe参数冒烟（自有无害目标），确认普通分支override_present=false且参数进入OS。

两类guest冒烟均PASS后才复制真实工具。八项复制沿007/v0.5已验证robocopy合同，不重做算法研究。复制后真实Git `--version`、Java `-version`各一次；必须记录RunNative收到参数、override_present=false、最终Arguments、工具输出和exit。若此处失败，分类为 `NATIVE_TOOL_VERIFY_*`，不得继续pub。

## 7. 真实pub和M3

Git/Java验证均成功后，真实 `C:/M3/t/f/bin/flutter.bat pub get --offline` 至多一次、10分钟；仅pub成功后，`flutter.bat build aar --no-debug --no-profile --no-pub` 加已绑定defines数组至多一次、30分钟。使用同一RunBatch/RunNative，不另造生产字符串。

真实工具entry与派发分开记录。非零返回只有在工具入口已证实时才归COMMAND_FAILED；只有真实缺包/解析输出才写OFFLINE_PUB_INSUFFICIENT。不得自动下载、联网、安装、改Wrapper/SDK/产品源码或重试。

仅M3实际启动后一次检查精确AAR：`C:/M3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。HIT记录size/SHA-256；未启动保持NOT_CHECKED。不搜替代。M2不执行。

## 8. 交付与候选

本地evidence保存激活、脚本hash/diff、host两类回归、guest两类冒烟、策略/nonce/隔离、复制、Git/Java真实验证、真实pub/M3/AAR及进程收尾。未发生阶段不伪造日志。

GitHub候选分支：`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-8`。一个commit，唯一父本任务commit，恰好两路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_8.md`
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

报告必须给出最终RunNative修复片段、普通exe/批处理两类host和guest测试、Git/Java最终OS参数、真实pub/M3/AAR状态、进程结束及证据限制。不要只交付计划或“看起来已修复”。

发布后一次核验parent/两路径/blob。执行者不自我接受、不更新main、不M2、不修改AGENTS/项目源。完成后停止。

## 9. 边界

README/FD02、旧仓库、全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36和产品实现边界保持。除激活后本任务专用RemoteSigned外，不改持久策略/信任/系统配置；不下载、不真实数据、不生产访问。宿主SDK/cache和原仓库不写。