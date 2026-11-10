# EliteSync v10.1.5｜通信可靠性、离线私有数据与授权通知｜冻结功能计划

日期：2026-10-21（Asia/Singapore）。状态：**FROZEN_FUNCTIONAL_PLAN / OWNER_REQUESTED_NEXT_TASK / MANUAL_CODEX_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING**。

本计划根据Owner在新会话明确要求“根据路线图继续下达任务单”而冻结软件开发范围；**发布计划、任务单本身不启动Codex或本地服务**。最终不可逆决定、真实用户/生产数据、设备与系统权限扩大、费用、供应商和外部运营仍由Owner单独授权。Astra负责冻结和独立审阅；Codex仅在Owner手动完整派发后实施。与本计划相冲突的旧规划时点仅视为历史，不倒改已接受版本。

## 1. 版本入口与不变基线

- 仓库：`zcx369658780/EliteSync-v10`。签发前只读live main：`7a8798ef182998b228c4cb986a61835bcf3ca94f`。签发后纯文档提交会使HEAD前进，Codex开工必须重新读live main及产品子Tree，**不能reset回该旧SHA**。
- v10.1.4已具备两道Astra独立正式裁决：`FUNCTION_ACCEPTED_WITH_OBSERVATIONS`与`INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`。已接受源码Commit `1062603bfd5866eb4c40b4773657343a1eca2af7`、完整apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`；产品集成Commit `759015ad0c897c92516531c2f3a94a3a7ff77c02`。Codex只在真实已接受主线继续，不重集成v10.1.4。
- 来源：`docs/workflow/{ACTIVE_STATE.md,CURRENT_WORKFLOW.md,ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md,SESSION_HANDOFF_20261021_V1014_ACCEPTED_V1015_PENDING.md}`、`docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md` §6.5、`PRODUCT_DECISIONS.md`、2026-10-19 Owner方向及原06/07设计、`docs/versions/v10.0.7/acceptance.md`、`docs/versions/v10.0.9/plan.md`、`docs/versions/v10.1.4/integration_acceptance.md`。
- 必须继承的产品事实：Match、Friendship、Buddy、Connection、Messaging Consent、Conversation、Formal Relationship和平台Safety分别授权；Block/禁用/撤权在服务端使用点生效，重连、旧通知、旧JWT/缓存、旧媒体不能复活同意。已接收v10.1.1～1.4不因本版升级重做原业务。真实身份Provider/Push/支付/活动/公网仍未授权。

## 2. 冻结范围及明确非目标

**F1 消息可靠性（已有文字、图片、短视频的加固，不重造消息协议）**：
- 基于现有 `ConversationAtomicSendService`、消息客户端attempt/idempotency、WebSocket与通知通路做定点源码调查；落实发送中、服务端确认、失败可重试、回放/去重、顺序/旧消息读回、弱网/切前后台/重连、重复提交和不同payload复用idempotency key的行为。
- 服务端状态为最终事实，客户端不得在超时或断线时虚构“已发送”；允许安全重试相同逻辑消息而不重复消息/附件/站内通知；明确禁令、CN/MC/Block、失效token、不同账号/旧会话代际回来的晚响应均不能越权写入或错显。
- 图片/短视频继续使用既有私有媒体验证、Range读取和授权附件关联；撤权、旧URL、取消/过期、视频处理失败均需负例，勿对全部旧媒体重新采集/转码。

**F2 RTC稳定性与有限质量加固**：
- 复用已接受受控双端voice/video及既有`RtcSessionService`、token/epoch/RTC guard/SFU撤权边界，不重建LiveKit架构。定点处理WS端点/返回地址/Android明文策略差异、重连/超时/来电退出、取消/挂断/Block/MC撤销后的旧房间/旧令牌及通知授权，保留历史不弱化5秒媒体停止安全目标。
- AEC/回声与人耳音质：先定位既有配置和可测试设备；在**已批准且确实可用**的开发设备上作有界实验和修复。若需新的真实手机、麦克风、摄像头、UDP/防火墙、设备驱动、系统提权或新外部权限，仅隔离该测试项并报Owner，不冒称真机音质PASS。模拟器/静态测试不能证明现实回声已经修好。

**F3 可信登录时间、15/30天与加密离线只读**：
- 继承已存在的`OfflinePrivateRetentionPolicy`：最后一次**真正成功在线登录**作为T0，`0≤Δ<15天`为15天时间窗候选，`15≤Δ<30天`在额外安全门均通过且设备离线时可读已有保存内容；`Δ≥30天`拒绝离线展示并进入受控清理。自动token刷新、应用重启、profile变更不重置T0。判定器只处理调用方声明，不是可信权限或擦除的现成证明。
- 在实际后端认证和客户端会话链上建立可验证的T0/账户/设备及受信时间来源；针对时间回拨、缺失/不可信、跨账号、设备恢复与离线重启采取fail-closed。在线读/发永远需要当前服务端CN/MC/Block/账号状态与相应用途权限，不因15天窗口而自动获准；refresh不能规避服务端到期。禁止为达测试结果放宽这些门。
- 依Owner此前接受的方案B，明确加密保存的范围（草稿、会话摘要、搜索历史、选定已缓存消息/媒体、必要身份资料），将敏感数据从无账户命名空间/未加密SharedPreferences路径移出或停止持久写；清理旧动态`chat_draft_*`键与全局快照泄露路径。重启后必须先重新在线核验，**未经核验不得仅凭token/profile或缓存展示私密内容**。已持有可证明的有效离线读取上下文可读合格的加密已存数据，但不允许新发送、编辑并写回或预置离线发送队列；当可信设备时间与撤权状态无法确定时锁定。无法即时得知的远端撤权不得虚称已传播到断网设备；重新联机时必须先核验再显示。
- 满30天必须提供受控实际清理的正反回执（仅本版拥有的测试密文副本）；删除失败、设备时钟异常、未知来源、别的账号数据须fail-closed/隔离并说明，`PURGE_DUE`不等于`PURGE_COMPLETED`。**本版不得扫除历史LOCAL_ONLY原证、旧数据库备份或受保护工作树**。

**F4 通知偏好、最小内容及Push预留**：
- 保留“领域事件→通知资格→最小payload→发送尝试/回执”四层；完成APP中通知授权请求/拒绝/撤销、站内类别偏好、静默、通用锁屏内容、打开时当前服务端重鉴权、token登记/换号注销（仅对实际获准的可用通道）。
- 未有Owner批准的真实Push供应商、凭据、SDK和数据流时，只实现不依赖该供应商的后端/客户端契约、偏好及受控本地/测试替身；标`REAL_PUSH_PROVIDER_PENDING / DELIVERY_NOT_VERIFIED`，不可让模拟回执冒真实系统后台/锁屏通知送达。拒绝OS通知权限不影响核心Match/消息/安全入口，撤销后不能继续登记或泄露旧私密通知。
- 既有 v10.1.4 平台活动、安全案卷通知继续按原owner current-read鉴权；不得把报告或处罚、私聊正文、联系人名、关系状态直接暴露在外部通知。

**F5 有界旧资产来源判断**：仅对“语音留言/其他旧附件、地图/地点”做一次具名路径和已接受来源检查。未证功能记`UNKNOWN / OUT_OF_SCOPE`、后续由Owner决定；不以RTC语音代替语音留言，不自动新增附近人、实时位置、完整地图或更广社交功能。

## 3. 环境与原证保护

- Codex获Owner手动派发后仅可用经核归属的本地代码树、已有开发工具/AVD及**新建空且独立**的本版本MariaDB库/volume和回环端口；名称如`elitesync_v1015_dev`仅为建议，端口先查占用。迁移/任何测试前确认有效`APP_DB_CONNECTION`优先于`DB_CONNECTION`、URL/socket/host/port/database及testing/sqlite/:memory:；先备份/隔离再迁移，确保不连接旧事故库、3306、生产或他版卷。仅本版本新建的受控测试数据可清理，并保留必要恢复点。
- 原`D:/EliteSync-v10` dirty、`D:/EliteSync`、全部已有工作树/候选与审阅分支、SQL/APK/日志、密钥、事故恢复卷及历史失败保护；不得盲pull/reset/rebase/stash/clean/prune/force。无需每版新造多个worktree。
- 敏感原始消息、证件、语音/视频、Bearer Token、数据库与LOCAL_ONLY设备日志严禁上传公开GitHub或ChatGPT Project。任何调试日志若仍输出Bearer Token属于本版受影响登录/网络链的必须有界移除项；原始凭据不做取证上传。
- 不操作公网/云端生产、不采购第三方Push/音视频/AI、不启用真实外部服务、不接触真实用户、不扩大设备系统权限；因外部门禁无法运行的子项保留`NOT_RUN/PENDING`，不阻断其他可交付软件能力。

## 4. 冻结接受条件 AC-10.1.5-01～11

| AC | 独立验收可观察终点 |
|---|---|
| 01 技术基线/数据保护 | 真实main/两子Tree来源、受控开发树、独立空库/卷/有效DB选择器与事前后保护对象身份可核；无历史数据误清或隐私原件发布。 |
| 02 消息幂等/故障恢复 | 两虚构有权账号在实际APP/API/DB走消息发收、重试/相同键回放/不同payload冲突/重复通知、超时与重连；服务端每逻辑消息至多一次，用户看到的状态可解释，不以mock代替。 |
| 03 授权和跨账号晚响应 | Block/MC撤权/CN关闭/禁用、旧JWT/旧room/media URL、用户切换、掉线旧结果及并发失败均fail-closed，无新消息或附件越权、旧资料重显；必要受影响真实MariaDB并发验权有精确时序。 |
| 04 私有图片/短视频 | 已授权相同版本客户端发送/持久重读/受控重启；媒体200/206、撤权后的404/403等实际响应及错误提示相符，失败素材不可假READY；不重跑全部v10.0.9。 |
| 05 RTC保护及有界质量 | 既有有权通话/拒绝/挂断/重连/撤权的一组真实可用受控链，旧令牌不重新入房；AEC/回声按设备与可观察音质实际分级，缺真机条件则`NOT_RUN`，不得宣称声音已实测达标。 |
| 06 可信15/30计时 | 真实成功登录产生可核T0且账户/设备绑定；refresh/重启不续期；按15天/30天前后边界和服务端受权路径验证，不能用任意本地时钟或纯策略测试冒真实有效期。 |
| 07 加密离线只读/清理 | 真正APP持久密文、重启/切号/离线/超期演练；未在线核验前不显示旧私密缓存；只读不发/不改；30天受控本版密文实际清理回执，失败/时间异常/旧明文残留有处理；不得损害历史原证。 |
| 08 通知隐私与权限 | 站内通知/类别偏好/系统权限拒绝和撤销、锁屏通用正文契约、当前状态点击重验；原message/Buddy/status/platform_event/Safety越权、禁用与旧路由测试无泄漏。 |
| 09 Push供应商隔离 | 无已获准供应商时provider接口、token生命周期可用受控替身测试；真实Push状态严格`PENDING/NOT_RUN`，不声称后台真实投递；需要SDK/密钥/费用时停该项等Owner。 |
| 10 关键运行与复用 | 同一开发APK/后端/持久库的目标流程，重启前后指定权威业务事实不变；Flutter/PHP及相关静态检查有完整exit/stdout。仅运行受影响CN/MC/Activity/Safety/RTC有限回归，旧失败不删。 |
| 11 集中交付与独立审阅 | 一份`IMPLEMENTATION_REPORT.md`、一个`artifact_manifest.json`，固定源码Commit/Root/apps/services、测试/设备/本地证据分层、APK build/install及hash（若APP变）、必要脱敏审阅材料与非作者有界复核。Codex停在候选，不自行ACCEPTED、不合main、不派发v10.1.6。 |

如可信计时、加密私密内容、授权边界等核心AC未满足，必须如实报告`CHANGES_REQUIRED/PARTIAL`，不能以“供应商待定”掩盖软件缺陷。只有**真正外部**的Push供货、真机音质设备、实名/公网/运营门禁可单列为待验证，不虚称通过。

## 5. 出口与权限状态

Codex收到Owner手动派发后，按单一综合任务集中实现/修复/受控测试与非作者有界复核。交付标`V10.1.5_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / NO_PRODUCT_MAIN_INTEGRATION`。Astra独立核源码/实物/证据，必要时发一次同版有界R1；**功能接受后仍需Owner单独批准单次安全集成**，由Codex精确接入接受apps/services，Astra再独立签集成验收。任何之前的“默认集成接续”不取代实际人工派发和版本门禁。

v10.1.0整版`PARTIAL/NOT_ACCEPTED`和AC-10.1-08 PARTIAL、v10.1.1开发库事故/恢复、v10.1.2/1.3/1.4原证和观察、真实身份Provider、RTC/AEC、通知GUI及旧项目源ZIP `BYTE_MIRROR_PENDING`继续保留。Owner已手动更新ChatGPT Project Sources，不再为ZIP重开治理任务。