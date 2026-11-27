# EliteSync V2｜M4 完整用户旅程与集中体验收口

任务 `V2-M4-INTEGRATED-USER-JOURNEY-20261127`，2026-11-27，北京时间。**阶段性 PARTIAL。** 核心关系旅程、社区与 Buddy、通知导航和后台一致性通过具名验证。三盘在 M4 集成镜像的正向运行证据仍缺。 总体发布状态 `R1_PARTIAL / CLOSED_BETA_NO_GO / PRODUCTION_NO_GO`。

## 固定身份

| 范围 | 回执 |
| --- | --- |
| 活动工程 | `D:/EliteSync/development/v2-cloud-r0-20261121`，`codex/v2-function-completion-20261121`，origin `git@github.com:zcx369658780/EliteSync-v10.git`。开工 HEAD `f5aa5da0f64a4408881826dd97edc5002ca8d001`，tree `e02400ade42b0bcf11f03db8d4214a75a6ce62da`，工作区与暂存区干净。项目主工作树受保护 |
| 本轮源码 | `ad520ba527580dba946cd904047c45abc069eebd`，tree `182bb46b6129ad5877c86759a0356ca7eb2efdcf`。Flutter `lib` tree `056656586e256fa8f4f8d32da765ef1bfaf58d34`，进度页 blob `e0afd166c6236767d3a1aed03bc889580c7bc4ff`。Laravel 产品 `app` tree `1849dba17fd0925b4ab144e64be2ae42ca42dbfa` |
| 模拟器 | `elitesync_api36` 只读 AVD，`emulator-5572`，Android 36.1 上 ARM64 转译。专用包 `com.elitesync.v2m4journeyqa / 1011807`，构建保留原 QA versionName `10.1.18-v2-m3-wlan-qa`。APK 和模拟器已装 SHA-256 同为 `a26145f85356dacfba614ffe782677716ce955b638edec1abf8d3394de089182`；签名证书 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。AAR 与 APK 的 ARM64 编译产物字节一致，SHA-256 `3e352c775e1db36e1a1f35a0e00f765f6877b98ca20edfce6f4ed5b58f971c85`。仅回环 TLS 与具名模拟器 ADB reverse |
| Laravel | 隔离容器 `m4-journey-api`，ID `0dedfc9526468a9e5dd5b22e9f6e893336bee9d52c4f76adcc3e05261f923a77`。基础镜像 `sha256:6bce0c32e49a3ac2800644fb42eac616742b88e9a0beffb159fe6045e42a9f10`，覆盖现行应用、路由、配置、迁移及 Web 视图。PHP 8.4 容器与 Windows PHP 8.5.3 验证分别记账 |
| MariaDB | 新建独立 socket、数据根、内部网络、数据库卷和媒体卷。容器 `m4-journey-db`，MariaDB 10.11.19，镜像 `sha256:5d60ca6129f939453472f4ed385c54820ec57f3aa384a8646619f9bc0e3b5eab`。现有 TEST_ONLY 门要求逻辑库 `elitesync_v2_function`、server ID `2621121` 以及签名和虚构批次。本轮在新卷满足原门禁 |

[最终工程源码](https://github.com/zcx369658780/EliteSync-v10/commit/ad520ba527580dba946cd904047c45abc069eebd) · [M3-R 固定报告](https://github.com/zcx369658780/EliteSync-v10/blob/f5aa5da0f64a4408881826dd97edc5002ca8d001/docs/versions/v2/cloud-r0-20261121/V2_M3_R_FINAL_CLOSURE_REPORT_20261127.md) · [Owner 已接受的四阶段路线图](https://github.com/zcx369658780/EliteSync-v10/blob/8f528e6dc1df3d52ba931e65d8ce5658cfaf11f7/docs/product/ELITESYNC_V2_POST_S1_CONSOLIDATED_ENGINEERING_ROADMAP_V0_1_20261119.md) · [关系与安全决定](../../../decisions/OWNER_PRODUCT_DECISIONS_20261019_LONG_TERM_RELATIONSHIP_V1_0.md)

## 用户旅程与权威状态

| 用户路径 | 入口与权威 | 合法操作、去向及失败处理 | 定向核验 |
| --- | --- | --- | --- |
| 注册、登录和账号 | 登录页、`AuthController`、`DeviceSessions`、`users/account_closures` | 登录并按设备绑定会话，首次引导可跳过。受限账号或失效令牌阻断受保护页面。退出使该次会话失效。断网需要恢复当前读 | 注册隔离测试，合成账号真实登录；共享公开注册沿原门槛 |
| 基础资料和隐私 | 我的、设置、`/profile/basic`、`/privacy`、`ProfileReadinessService` | 保存本人自述及用途允许的字段。查看对端按当前关系、字段许可和 Block 投影，普通资料修改不授权重算或扩大受众 | 本人读回及对端精确出生字段不披露，隐私／数据权利 PHP 定向运行 |
| Lifestyle | 首页、匹配准备、`/profile/lifestyle-discovery`、`lifestyle_discoveries` | 五场景可写、可跳过或重设。明确保存后进入下一题。版本或请求结果未知先查权威状态，旧版本不覆写 | 两人共十个场景持久保存，首个命令重试 revision 未增长 |
| 匹配准备、资格、候选 | 进度、匹配资料、`/matching-inputs`、`/journey`、`matching_participations`、轮次与提案表 | 资格包含运营审核、实际身份权威、资料、有效答题及参与条件。合成批次具名令牌仅用于 TEST_ONLY。双方分别回应。拒绝、撤回、到期走当前提案与权限重查 | 无身份拒绝；真实轮次 Worker 生成并发布一对，响应从 `ACCEPTED_BY_ONE` 到 `MUTUALLY_ACCEPTED` |
| Connection | 进度至连接详情、`/connections/{peer}`、`product_connections` | 双方确认独立连接，可拒绝、撤回或关闭。尚未完成时不赋予私信 | 本人接受自身请求拒绝，对端拒绝，再请求后双方完成 |
| Messaging Consent | 连接详情、`/connections/{peer}/consent`、`messaging_consents` | 同意受当前 Connection 约束，双方独立决定；拒绝、撤回和 Block 令旧读写收敛 | CN 有效时 MC 拒绝与重新接受，撤回后 CN 仍有效，旧房间不可读 |
| Conversation | 进度、消息、`/messages`、`conversations/chat_messages` | 服务端现行读写门及 room key 约束。首条合法发送建立会话，已存在会话读回，重复消息编号只对应一条。网络失败保留未知发送及明确核对入口 | 真实 HTTP 空房间、首条、同键重放；模拟器显示真实落库消息 |
| Relationship | 进度的正式关系、`/formal-relationships`、`formal_relationships` | 合法联系来源与对端请求设置允许申请。实际确认还需双方有效凭据和独立同意。可拒绝、撤回或结束；结束与会话撤权分别处理 | 双方确认 TEST_ONLY，单方结束后当前聊天仍合法，再单独撤回 MC |
| 首页、社区、Buddy | 首页 `/user-state`；`/status/posts` 与评论；`/buddy` | 当前本人投影导引操作。精选和好友内容使用各自受众政策；发布、评论、历史及媒体依各自权限，Block 影响当前可读性；搭子按自身活动状态申请及退出 | 真实好友作品、Buddy 公开摘要及申请，申请后旧私信仍拒绝。Block 后旧内容读取和允许操作复核 |
| 个人理解工具、Showcase | 我的、`/profile/natal`、`/profile/mbti/*`、`/profile/showcase/*`、`user_natal_profiles/user_tool_revisions` | 本人提交与结果版本独立。坐标来源可留存，展示草稿审核与发布版独立。既有候选读取绑定的合法旧版本。人格、三盘按自愿参考语义 | Showcase 与旧候选绑定、人格私有版本定向通过。M4 计算运行身份不足返回 503，输入 v1 留存、结果版本空，异账号不可读。以现行源码和 M1 锁定依赖作 Windows 无网络计算，八字 `COMPUTED_UNVERIFIED`、紫微和西洋 `CALCULATED`。正式正向保存与 App 重登读回沿用 M1 固定证据 |
| 站内通知、设置 | 消息、通知中心、`/notifications`、`NotificationService`、站内通知记录 | 当前有权的通知指向当前业务，已读和待办独立；撤回或失权后旧入口不授予权限。系统返回回通知中心。Push 是独立依赖 | 通知读取、已读、撤权只读与过期测试；APP 打开当前连接页和返回按实测单列 |
| Web 管理 | `/admin`、`/admin/matching`、`/admin/showcase`、`/admin/buddy-community` | 后台使用管理员角色／名单、Web 会话、CSRF、版本与审计。用户视图跟随业务事实。后台资格与运营审核只影响其定义的范围 | 真 Web 登录，用户审核状态、已揭示轮次和成功运行三端状态一致；后台无法读普通用户私信。Showcase 和 Buddy 管理页可读，审核行为和通知通过 PHP 定向验证 |

关系合同在本轮保持独立。`Match ≠ Connection ≠ Messaging Consent ≠ Conversation ≠ Relationship`。本机合成身份、站内事件与 E1／E2 真服务各自记账。[M1 固定报告](V2_M1_NATAL_SAVE_READBACK_REPORT_20261126.md) · [M1-R 运行身份审计](V2_M1_R_DEVICE_BACKEND_IDENTITY_AUDIT_20261126.md)

## 缺陷、回归与证据

- **P1 首条消息入口。** 进度页原先同时依赖已存在会话。新配对在 MC 已生效时没有会话记录，进度页因而不显示「进入聊天」。Widget 回归先失败。修复在当前服务端允许读写时显示入口，保留已有会话的读取路径。MC 待处理、拒绝和权限未知的原有检查通过。
- **验证夹具。** 通知旧夹具未完成 TEST_ONLY 身份和 Lifestyle。补齐先决条件，通知断言改为现行当前旅程路由及失效收敛。后台旧夹具用同步队列覆盖了待处理回执，现使用队列断言，并带当前版本验证补偿拒绝。产品后端状态转换保持现合同。
- **Flutter 159/159；PHP 128/128、1,858 断言。** 进度页产品文件 Dart 静态分析无问题。测试文件仍有七条原有花括号风格提示。初轮 Windows 测试缺 GD 及 Blade 临时目录，启用机器已有 GD 与独立视图目录后恢复。保留旧夹具失败。
- **真实 MariaDB、HTTP 与 Web。** 六份阶段回执合计 **9 组通过、119 次 HTTP 响应**。覆盖资格不足、真实后台 Worker 和轮次、双方候选和许可、消息幂等、独立 Relationship、好友受众、Buddy、撤权、Block 后拒读及历史保留。另有初始夹具失败原证。 首轮在 Matching Inputs 少传显式可空字段，重试按现行校验保存；管理员创建轮次按当前 channel version 重试。Block 后 Connection 端点按合同返回 404，补做只读复核并验证旧消息及提案行保留。仅合成环境执行迁移。
- **模拟器。** 独立 QA 包在模拟器完成首次登录及可跳过引导、首页进入进度、显示持久消息、Android Back 返回进度、通知打开当前 Connection/MC 并返回通知中心、退出与第二个 QA 账号重登。Block 后旧聊天从消息页收敛。模拟器 ADB reverse 单独断开后显示刷新重试，恢复后可继续使用。字体比例 1.3 下目视核对进度页代表内容；全页读屏和无障碍矩阵 `NOT_RUN`。UI 正常操作、HTTP 执行的业务状态和组件故障注入分别取证。
- **截图索引。** 代表性原件包括 `m4-screen-01-home.private.png`（`a250a696…`）、`m4-screen-02-progress.private.png`（`82a4a7c7…`）、`m4-screen-03-chat.private.png`（`de5be4e2…`）、`m4-screen-04-notices.private.png`（`4f6b35d9…`）、`m4-screen-06-blocked-inbox.private.png`（`3f9614bb…`）、`m4-screen-06-offline.private.png`（`ccf8fb5b…`）及 `m4-screen-07-font-scale-130.private.png`（`04eb4c61…`）。 原件与脱敏 HTTP 证据留在 `D:/EliteSync/development/v2-m4-local-20261127`。无 APK、数据库、令牌、账号口令或私有截图进入 GitHub。

## 出口与门槛

| 出口 | 状态和范围 |
| --- | --- |
| `M4_USER_JOURNEY_CONTRACT_MAPPED` | **PASS**，以具体源码口径和路径为准 |
| `M4_CORE_RELATIONSHIP_JOURNEY_SCOPED_PASS` | **PASS**，隔离 TEST_ONLY 用户和明确的已运行用例 |
| `M4_HOME_COMMUNITY_BUDDY_SCOPED_PASS` | **PASS**，覆盖现有受众、独立申请、Block 及组件层社区矩阵 |
| `M4_PROFILE_PRIVACY_TOOLS_SCOPED_PASS` | **PARTIAL**。本人权限、异账号隔离、Showcase 快照、人格及资料纠错合同通过定向检查。M4 镜像的命盘运行身份不可用，503 安全留存 v1。另起 Windows HTTP 服务的命令被本机执行策略拒绝，改用无网络计算核实三盘当前源码及 M1 锁定依赖。正式正向保存读回沿用 M1。 |
| `M4_NAVIGATION_NOTIFICATION_CONSISTENCY_PASS` | **PASS**，本机合成站内通知、主流程和系统 Back 范围。真实 Push 单列 `NOT_RUN`。 |
| `M4_CROSS_SURFACE_STATE_CONSISTENCY_PASS` | **PASS**，本地具名状态；Web 会话中的内容审核代表行为由 PHP 核验 |
| `M4_INTEGRATED_SOFTWARE_CANDIDATE_READY` | **PARTIAL**。合成旅程候选已构建并实测。M4 环境缺三盘正向运行证据，外部依赖及真实设备范围仍待独立验收。 |

E1 真身份回执、失效和合法资格链仍待证明，影响正式报名、自动参与与正式关系。E2 真 Push 需真实投递、拒绝与撤回设备证据。E3 仍缺适用法律、对象级保留删除、数据处理及第三方资产依据。相应外部事项和正式界面信息架构由 Owner 与顾问决定。

M3-R04 保留原初始阶段样本。最新本机过程记录停在 07:40:23，后两条无法核定原进程，观察进程与入口进程已不在运行，未发现到期或重连终态回执，状态 **PARTIAL**、中断根因 **UNKNOWN**。M4 使用新环境，未发起重测。M1-R 历史身份仍 PARTIAL，三盘整体数值精度限制沿用。P1 仅 /32 为 FAIL／根因 UNKNOWN；正式证书自然续期、独立 Chrome 公网管理、双实体、真实移动网络及孤立文件存储治理继续按原范围。封闭内测和生产仍为 NO_GO。

报告准备供 Owner 按现行流程转交网页 GPT 顾问。顾问验收及 Owner 终裁待回执。
