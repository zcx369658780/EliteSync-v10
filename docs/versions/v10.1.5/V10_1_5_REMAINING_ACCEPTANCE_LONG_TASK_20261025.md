# EliteSync v10.1.5｜Remaining Acceptance Closure｜综合长任务单

状态：LONG_TASK_READY / OWNER_MANUAL_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED_UNTIL_DISPATCH / PCM_CLEANUP_LOCAL_REPAIR_ACCEPTED / AC05_OPEN / GATE2_NOT_AUTHORIZED_IN_THIS_TASK

日期：2026-10-25（Asia/Singapore）
仓库：zcx369658780/EliteSync-v10
Owner：最终产品方向和不可逆决策 authority
执行者：Codex（仅Owner手动派发后开始）
顾问/验收者：Astra

## 1. 任务目的

这是v10.1.5的单一综合剩余验收任务，不是新微任务。Owner已要求恢复长任务单+中途无监督模式，并要求在Astra完成上一次PCM capture清理修复验收后下达后续任务。目标是在同一任务中推进所有当前已授权、可执行的v10.1.5剩余功能/验收工作，集中修复普通缺陷，最后一次性提交完整AC状态与候选证据。

默认执行方式：Codex自主调查、实现/修复、构建、测试、必要真机验证、普通non-force候选发布与远端回读；Astra在整版集中交付后独立验收。普通失败、范围内代码修复和重测不要求Owner逐步骤审批，不另拆微任务。本任务不会自动合并产品main、不会自行接受整版，也不会启动v10.1.6。

## 2. 当前权威基线（开工必须重新读取）

- Owner已接受产品基线：v10.1.4；apps Tree 3468a3dd97da7accfda2539a0f8d8f68931a6110；services Tree 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 本任务编制前最后确认的live main为748e7f5a627d71d4323c48c2b649e8104cb288d3，Root为1a85ae2624488992171f15477582b774abbd542c。该SHA仅是编制快照，不可替代Codex开工时fresh readback。
- 最近交付候选为1a3a9ff9daa315fe5e688f6f0aab8e378e1db97c，唯一Parent为1f9d1483268e957f7184625483ff6406071c1867，候选Root为97fc729f68fe8d0b4bd1fc2f7dfb7cb0b2bad100。源码Commit为1f9d1483268e957f7184625483ff6406071c1867，Root为9beff929abf3939ac863cd4096ee9fb09a64a48d；候选apps Tree为a5c6182ea9e064db4ef73e1627a6e38591c953cc，services Tree为21eebf69bbc6397b1562d40f8cd9ebd7b246720f。以上为未集成候选身份，不是已接受产品Tree。
- 冻结版本计划：docs/versions/v10.1.5/plan.md，Blob 7d3466b3be67135dc641cfee7c7faef78937ba03。不得改写冻结产品合同；若确需Owner方向性决策，集中报告该项并继续其它工作。
- 原综合任务单：docs/versions/v10.1.5/task_order.md，Blob 43b2396b2fba046d5c0ab00bea87293783d1c2fd，包含长任务授权、USB真机范围和既有停止边界。
- 最新实施报告：docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md，Blob a2327eeb14532c711213a96290b08c53824c2895；Manifest：docs/versions/v10.1.5/artifact_manifest.json，Blob 74bb3b2b6a74344ddca9156a2bc08912d6701c4e。
- Astra已接受PCM局部修复：docs/versions/v10.1.5/PCM_CAPTURE_CLEANUP_ASTRA_REVIEW_20261025.md，Blob 327ca8f7c68bf469c412a24129dc4d83c7742fe5。裁决为V10.1.5_PCM_CAPTURE_CLEANUP_REPAIR_ACCEPTED_WITH_OBSERVATIONS，不等于整版接受。

## 3. 任务范围与优先顺序

### A. 保持已接受的局部结果并核实新候选身份

1. 开工时重新读取live main、Root、ACTIVE_STATE、冻结plan、两个任务单、最新报告/Manifest及局部Astra接受记录；核验本地工作树、分支、候选Parent/Root、源码Blob和apps/services Tree。不得reset回旧SHA或把候选树当main。
2. 将PCM cleanup局部接受作为既有证据，不无谓重复已通过的48项检查；如本任务继续修改SDK清理路径，只重跑受影响定向测试与必要关联测试。
3. 维持应用自有LiveKit 2.10.0 path dependency、许可证、NOTICE、上游Hash清单和最小patch记录。若改动vendor源，更新patch、来源索引与Hash。

### B. RTC / AC-10.1.5-05 剩余验收

1. 继续修复并验证PCM capture cleanup的剩余观察项：在不忽略异常的前提下，检查track dispose、Room.dispose、renderer取消、capture start/stop交错、重复呼叫及下一通连接；用定向测试证明资源清理顺序与异常传播。只有实际观测到的清理结果才可记PASS。
2. 在Owner已授权的同一台USB调试手机及现有合成PC对端/已授权测试SFU可用时，执行最终候选的麦克风/摄像头mute-unmute、前后台切换、手动同call重连、UI挂断路径和清理后再次连接。此前服务API结束通话的证据不得冒充UI挂断通过。
3. 若当前受控环境支持，以合成测试音/已知信号开展有限AEC/回声路径观察，记录采样方式、设备路由、时间戳、可观测指标和局限；不得采集/上传私人语音，不得把单次主观听感写成AEC通过。若现有对端/设备条件不足，明确记录NOT_RUN及原因，不为此下载工具或扩大设备范围。
4. 在一次真实媒体成功建立的合成会话中，若现有授权服务和测试夹具允许，验证该成功媒体会话的旧JWT首次重新入房被拒绝；并区分撤权后新请求拒绝、已建立媒体停止和旧成功token重入三个不同命题。不得把此前无媒体的JWT负例替代成功媒体token负例。
5. 复用已接受的真实RTP、视频解码、同call手动重连和撤权停止0.790秒证据，不重复运行整套旅程，除非本次代码变化使它们失效。当前RTP计数和native stop日志是有界证据，不等同全平台资源普查。

### C. 其它可独立推进的AC

1. 按冻结plan与AC-10.1.5-01～11逐项核对现有证据，推进所有与Gate 2无依赖的缺口。优先处理可在当前手机/本地测试服务中完成的通知GUI边界、消息/媒体权限边界、离线冷启动/受控时钟边界和构建身份验证。
2. 对15/30天期限和30天清理，可执行现有受控时钟/边界测试并记录真实T0、到期边界、离线状态和清理结果；不得通过改系统时钟或压缩时间伪称实际经过15/30天。真实日历时间尚未经过的项目继续标记NOT_RUN/WAITING_ELAPSED_TIME。
3. 真实Push Provider、供应商凭据、费用或外部送达未获得新的Owner授权，不接入、不付费、不创建真实供应商资源；继续完成内部通知偏好、系统权限与隐私行为，真实Push保持PENDING。
4. ICE诊断旗标可通过只读源码/构建变体与现有测试核验；不得启动未知guest、访问未授权环境或改变系统/全局网络设置。OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS保持未知，不作推断。

### D. Gate 2与条件式SDK链的权限门

1. 两次历史启动失败预算继续保持已消费：Windows PowerShell执行策略拒绝0.375秒；PowerShell 7/.NET TypeLoadException启动失败0.390秒。不得改写历史预算，不重跑D0-A，不重试被拒绝的原入口，不修改执行策略或使用Bypass。
2. 本任务仅授权只读分析Gate 2的TypeLoadException、核对宿主已安装组件/支持的启动入口并记录一个可审查的合规方案；本任务不授权启动Writer/Serializer，不创建新Gate 2预算。
3. Gate 2定点正负例、完整37案例suite、条件式Sandbox SDK、Producer、libs.jar与30项Configuration.resolve均保持NOT_RUN，直到Owner对该Gate另行明确授权。不得以mock、静态检查或其它测试替代真实运行结果。

### E. 自主修复、发布与停止边界

Codex可在冻结v10.1.5范围内自主调查、实现、集成、构建、运行测试、修复普通缺陷并重测；不需要Owner逐项批准普通文件修改、失败分析、局部返修或测试编排。不要求为普通代码路径增加额外防御抽象来替代进度。

只有需要改变冻结产品合同/方向、真实生产或用户数据、敏感外传、真实费用/供应商/实人、系统/全局安全设置/ACL/owner、删除覆盖历史备份或其它不可逆资产、超出v10.1.5范围，或需要启动Gate 2等单独授权门时，才暂停对应动作并集中报告。被一个门禁阻断时，继续与之无依赖的工作。

继续保留原始失败、dirty roots、历史refs、SQL/APK/日志和本地证据。不得force push、清理历史资产、自动合并main、宣布整版接受或启动v10.1.6。普通non-force候选发布仅用于备份/审查，不等于产品集成。

## 4. 最终集中交付

在同一综合任务内集中更新现有docs/versions/v10.1.5/IMPLEMENTATION_REPORT.md和artifact_manifest.json，逐项报告AC-10.1.5-01～11。必须区分：Astra已接受的复用证据、Codex旧报告、当前新运行、TEST_ONLY、DEVICE_NEW_RUN、NOT_RUN、BLOCKED及WAITING_ELAPSED_TIME。

至少交付：
- 当前源码Commit、唯一Parent、Root、apps/services Tree与关键Blob。
- PCM cleanup修复后的定向测试、关联Flutter测试、Dart分析、APK构建/安装/回取Hash和真实设备路径结果。
- RTC UI挂断、清理后再连接、成功媒体token旧JWT负例、AEC观察（若可执行）的逐项结果与限制。
- 15/30天边界与真实elapsed-time项目的区分。
- Gate 2仍未运行的明确记录，以及所有其它未解决项。
- 最小脱敏审阅包、远端Commit/Parent/Root/Blob/原字节回读、工作树与保护资产核验。

所有普通缺陷可在任务范围内集中修复后重测；不要为每项失败另建任务。完成后普通non-force发布候选并停止等待Astra集中独立验收。Astra接受局部结果不自动关闭整版AC，不自动放行Gate 2或产品main集成。

## 5. 明确的当前终态与授权

本任务当前状态为PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED（正式文件发布并完成Blob/正文回读后生效）。Codex在Owner手动派发前不得执行。

本任务不授权Gate 2运行、真实Push Provider、外部AI/支付/身份供应商、生产服务、额外设备或系统级安全设置修改。Gate 2后续运行需Owner另行明确授权；真实15/30天经过时间不可被模拟替代。

完成本任务的目标是尽可能推进v10.1.5剩余可执行AC并形成一个可集中验收的候选，不保证所有依赖真实时间或单独授权的门禁能够在本轮关闭。任何未完成项必须保留真实状态，不得伪造PASS。