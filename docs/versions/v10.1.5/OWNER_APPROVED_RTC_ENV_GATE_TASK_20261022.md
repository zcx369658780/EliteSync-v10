# EliteSync v10.1.5｜Owner批准的唯一RTC环境门禁补证任务｜Codex

2026-10-22（Asia/Singapore）。**OWNER_APPROVED_BOUNDED_RTC_ENV_VALIDATION / LONG_TASK_READY / MANUAL_CODEX_DISPATCH_PENDING / EXECUTION_NOT_STARTED / NO_R2_AUTODISPATCH / V10.1.5_PARTIAL_NOT_ACCEPTED / MAIN_NOT_INTEGRATED**。

## 一、授权与唯一目标

Owner在Astra **2026-10-22 v10.1.5 R1独立复审**后明确回复“可以我批准，请继续”，批准此前提出的**一次限定于既有测试资源的RTC环境诊断＋验收补证**。这不是批准完整第二轮R2、产品需求变更、采购、新物理设备、新系统或网络权限、上线、与main合并；亦不等于批准改变v10.1.5冻结验收合同。GPT/Astra作为顾问已签发本任务，Owner将任务手动转交本地Codex后才实际执行。

**唯一任务**：在已合法拥有的两台A/B Android AVD、已存在Emulator Controller合成PCM／虚拟麦克风能力、既有隔离SFU镜像与localhost TCP及本版独立合成开发库条件下，一次性定位`authority_monitor_failed / sfu_fail_closed`与虚拟音频RPC故障，争取形成**真的双端APP/SFU流动音频、同call断线重连、旧RTC JWT撤权后首入/重入拒绝和流动媒体撤权COMMIT后5秒内停止**的端到端证据。不生成假媒体、不降级服务端拒绝策略、不把控制面当媒体。

## 二、固定上位真值（严禁倒改）

- GitHub `zcx369658780/EliteSync-v10`；签发前live main `49ce45c38b08ca514e5d4d8bcfbdce814d68cb6a`，以执行前重新GET为准；该main仍是v10.1.4接受产品，仅后继独立裁决文档变化。不得从主线覆盖/丢失R1候选。
- v10.1.5冻结plan `docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；唯一最初长任务 Blob `0df56f69712a85541b5f24bef281e2a9a61520a4`；Astra初审R1任务 Blob `be3045b206b75b7ccd0d8b28bc366678fc890302`。
- 最新独立[R1复审](r1_independent_review.md) Blob `ff9916e0b227dc0996165b2b6d5024b6199ead17`，正式`V10.1.5_PARTIAL/NOT_ACCEPTED/RTC_MEDIA_CORE_GATE_OPEN`。
- R1接受待核源码Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，Root Tree `165eb1f362db533ca94bfe1db677ff6f7bd477ed`，apps `0784c8aa7b0915a04b83693a45401197e31d93a2`，services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`；R1最终交付 `6da9a05156fda8b603224fd10e04ac1cc997ad79`。正式原报告`IMPLEMENTATION_REPORT.md`与`artifact_manifest_R1.json`均保留。先前独立脱敏R1审阅 `6e9b7441839954d0d8847399c91482354c61e473`；`docs/_temporary_review/v1015-r1-20261022/rtc-open-blocker.json`是环境故障及非因果性原证。
- 冻结`AC-10.1.5-05`及v10.0.9既有RTC即时撤权规则原样生效：合法CN+双方MC+当前账号/设备+独立接听；旧令牌/绕过入口不得重入，已流动媒体撤权后**≤5秒停止**，失败即fail-closed。v10.1.5其他AC继续沿用前轮独立审查结论，不重新验收B1/B3。

## 三、准许与明禁

**本次准许且只准许**：
1. 定点只读分析当前已接受RTC代码使用点、配置和既有本地运行原证：`RtcAuthorityService`、`RtcSessionService`、`RtcController`／`RtcGuardController`／`LiveKitTokenService`、守护代理与`authority_monitor`、APP的`RTC` providers/screens以及原`v10.0.9`受控SFU和`v10.1.5`R1测试日志。路径以仓库实际存在的名称为准，不要求不存在的组件。
2. 在**先确认归属/关闭状态、有效DB连接与恢复点后**恢复已有两个AVD、现有虚拟麦克风/已被Owner批准的RECORD_AUDIO（仅虚拟设备）、Emulator Controller的既有合成PCM、既有digest镜像的隔离SFU与已有受限loopback TCP 7894/7891、原有开发API/guard。可用新本版专属空测试库/卷，或有明确精确归属且已备份的R1专用合成库，绝不能混用旧事故库与生产；端口必须检查占用，不照搬冲突端口。
3. 有界进行进程/AVD/gRPC通道健康检查、控制面/数据面分层对照、服务/设备重启与同归属目录内的普通非破坏性配置修正及必要RTC源码最小修复和定向回归；修复后必须用真实双端同版本APP验证，不得通过放宽安全授权达到测试绿灯。
4. 对已构成可用流动音频的会话执行可重复、有权且合成的安全撤权与时序验证。真实音频源可为已获准Emulator Controller送入的不同频率合成PCM；证据需实际APP接收track、media/SFU可观察变化及有界测量，禁止把单纯WAV生成、SFU房间存在、麦克风权限granted或HTTP呼叫返回标为双端媒体成功。
5. 可采用既存控制程序、现有本地可用日志与合成指标。**不得**扩装工具、更新SDK、pull/build新镜像、启用真实手机/宿主麦克风或摄像头、新摄像头源、新网络监听面、UDP/防火墙/UAC提权、公网Cloud、供应商账户、费用或任何真实私人数据。若必要先集中报告Owner，不以用户本次“批准”泛化授权。

## 四、一次连续的分层诊断和事实验证

**G0 固定身份和安全前置（必须先于写/启动）**：独立核当前main与R1源码对象及一处有归属的干净连续工作树，保护五历史根、旧SQL/APK/审阅原证、私密env与所有旧refs；记录有效`APP_DB_CONNECTION`和`DB_CONNECTION/DB_URL/host/port/socket/database/APP_ENV`，迁移/seed前fail-closed，禁止3306旧库/阿里云/生产/已有v10.1.1事故库。记录SFU镜像digest、容器身份、localhost实际绑定、A/B AVD进程/ADB及gRPC endpoint、Audio权限、RTC相关代码SHA、开始与结束戳的来源；先保存恢复点。若已有端口或进程不属于本版，不碰它。

**G1 区分根因，不胡乱重试**：先各自证明（a）Emulator Controller channel能对两AVD进行**非敏感、非音频**的既有只读健康调用与一致返回，（b）SFU/guard/authority monitor在没有用户通话时健康、原始SFU不能外部直达，且`authority_monitor_failed` 的实际发生位置/异常类别/上下文可诊断而不泄露令牌，（c）真实RTC呼叫在合法CN/MC和接听时进入实际状态机，（d）单机合成PCM注入RPC执行与AVD存活在同次测试中绑定。对于RPC`UNAVAILABLE/connection reset`、`DEADLINE_EXCEEDED`、AVD退出、logcat阻塞，逐个建立时间和因果范围，不得仅以“先后同时发生”判定谁导致崩溃。使用少量可复现尝试与差异定位，避免高成本无界刷日志/重复容器重建。

**G2 双端真实媒体**：只有G1基础健康与合法服务端授权成立，才启动A/B两独立合成账号在同一有效call中进行真实APP双方操作：发起→响铃→对端接听→双方各自有可验证的publish/subscribe/receive事实→持续媒体流。分别标记A→B和B→A；采样真实SFU媒体级信号（track状态、RTP/帧/字节/可靠接收统计）与必要客户端回执，最优再用两路440/880Hz虚拟音频样本识别实际有效远端接收。**控制面/声学源存在不等于远端媒体可用**。如果一个方向没成功，按单向失败记PARTIAL。不得碰未获准的摄像头视频源：视频`NOT_RUN/NO_AUTHORIZED_CAMERA`。

**G3 相同call重连和旧凭据负例**：建立已经流动的音频后，按既有授权网络/APP可控的断线/前后台动作演练一次同call重连；证明重连前后call id、epoch、权限与媒体恢复的确切身份。然后使用仅合成测试里的历史JWT，在Block/MC撤销/结束或设备session撤销后的合法可控时序内，验证旧JWT首次join和rejoin均由guard+SFU的最终进入面拒绝；不可通过直连raw SFU、过期缓存、重新生成room或SFU自动token刷新绕过。只测既有隔离内部路径，不对host公网开放raw入口。若没有成功的已流动会话，不得将现有HTTP404/控制端点拒绝改名为`RTC_JWT_MEDIA_REENTRY_PASS`。

**G4 ≤5秒媒体停止**：在**双方已经实际交换媒体时**，对本版受控合成通话明确执行授权撤回（MC/Block/账号/设备session等选定场景），采集撤权COMMIT确切时点与media stop时点，统一可靠时钟基准/多事件关联ID，客观判断`T_stop - T_commit <= 5s`；双方客户端及SFU需无继续有效媒体，老令牌重新入房被拒。若guard故障、kick失败、SFU重连未知，应fail-closed并记缺口，**不能**用`ended` DB行、旧token Laravel404、UI挂断、JWT TTL到期或控制面返回替代真实流动媒体终止。只在确实实施并可测场景上作具名判定，未测试的撤权类型逐项UNKNOWN。

**G5 闭环和清理本版资源**：如果只修环境而源代码不变，报告`SOURCE_UNCHANGED`并保持R1固定Tree；若需要有界RTC产品代码修复，仅从R1最终交付普通新候选出发，列所有变更path/mode/Blob、唯一Parent/新Root/apps/services及对应定向测试，不修改原R1对象、原冻结AC、旧报告和main。收尾严格只关闭本任务实际启动且属于本版的API/WS/guard/SFU/AVD/本版forward/reverse等，停止独立测试DB而保留专属volume、SQL/APK、RTC原失败和恢复点；不停止全局ADB/Docker/WSL、不清理历史证据。

## 五、验收证据合同（不改变原AC）

一份候选必须明确列四条RTC硬门：
1. `DUAL_APP_SFU_FLOWING_AUDIO`：双端当前有权APP与SFU双向媒体真实存在并有接收统计；
2. `SAME_CALL_RECONNECT`：同call真实断线、重新鉴权和有效媒体恢复；
3. `OLD_RTC_JWT_DENIAL`：撤权后的旧token首入/重入及隔离直连尝试不越权；
4. `FLOWING_MEDIA_STOP_LE_5S`：实际流动音频从撤权COMMIT起不超过5秒停止，清楚给出判定时钟、用户对、call id、前后媒体观测。

每条分别写`PASS / FAIL / NOT_RUN / ENV_BLOCKED / INSUFFICIENT_EVIDENCE`，输出最小复现场景、源码/APP/容器/设备身份、命令/exit、关联事件时序、有效负例与可核 hash。音频注入RPC故障如果继续，记录**准确层、返回码、发生时序和隔离测试是否把服务弄停**；不能臆断因果。全部回执由Codex现场实测＝`CODEX_REPORTED/LOCAL_ONLY`，脱敏GitHub只负责Astra独立复核Git对象，不能升格Astra现场物理实测。

**未获准物理AEC与摄像头事实**必须分别标`AEC_HUMAN_HEARING_NOT_RUN / VIDEO_CAMERA_NOT_RUN`，没有证据不得称完整音视频质量PASS。历史v10.0.9受控成功原证可作来源，不能当v10.1.5此次媒体复验成功。既有Android期限、消息重试、图片视频Range、Safety回执全部继承上轮独立限定结论，无关对象不重跑、不清零。原消息WS综合脚本exit1另保留，不属于本次RTC工作，不借此重开消息开发。

## 六、唯一交付和停止门

交付单文档 `docs/versions/v10.1.5/RTC_ENV_GATE_EXECUTION_REPORT.md` 和一份 `docs/versions/v10.1.5/rtc_env_gate_manifest.json`，包含上述证据判定、精确基线/若修改则最终源码Git身份、普通开发APK及双端安装回读（若客户端被改）、新改动定向回归、原/新失败、必要非作者一次有界静态复核、私人原证hash/范围、文件保护/本版资源停用。附最小且匿名脱敏可审证据，不上传原始token/SFU secret/设备标识/SQL/图片/音视频/私聊或真实个人数据；历史R1报告、manifest和审阅分支原封保留。普通非force候选/审阅发布，固定SHA和Git tree readback；不得改变主线已接受产品。

出口仅二选一：
- 四条媒体硬门全部受证支持：`V10.1.5_RTC_ENV_GATE_CANDIDATE_DELIVERED / RTC_EVIDENCE_READY_FOR_ASTRA_INDEPENDENT_REREVIEW`，**不自己签v10.1.5 ACCEPTED**。Astra仍需审读后判断完整AC-05、视频与AEC未验证限制，不预先保证整版接受。
- 条件不具备或安全失败：`V10.1.5_RTC_ENV_GATE_PARTIAL / ENV_BLOCKED_OR_CORE_OPEN / OWNER_DECISION_REQUIRED`，明确最小具体权限/设备/环境阻断与已证安全边界，停止再试，不自动R2。

本次Owner**尚未**授权真实手机、宿主麦克风/摄像头、UDP/防火墙/UAC、公网、新镜像、新SDK、真实Push/供应商、费用、生产及真实用户；绝不自动扩大。退出后Astra独立验收与Owner进一步单项取舍；不得自动集成main、清理历史或启动v10.1.6。
