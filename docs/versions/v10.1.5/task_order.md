# EliteSync v10.1.5｜通信可靠性＋可信离线私有缓存＋通知隐私｜Codex唯一综合长任务

2026-10-21，Astra签发。**LONG_TASK_READY / PLAN_FROZEN / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED / REAL_PUSH_PROVIDER_PENDING**。

Owner已在新会话明确要求下发下一版任务。本文件是**给本地Codex的唯一综合长任务**；只有Owner手动把它完整交给Codex，才授权下述受控开发实施。请勿再次进行一轮plan提案、仓库无界考古或微任务来回。Codex可在已冻结范围内自主调查、编码、修复、定点测试、非作者有界复核与集中交付，不逐步骤要求Owner转发。Astra独立功能验收、可能一次R1及后续单次安全集成**尚未预先批准**。

## A. 首读权威与技术基线

1. 首先读取唯一冻结计划：`docs/versions/v10.1.5/plan.md`，**固定Git Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`**。本次范围及`AC-10.1.5-01～11`以该计划为准；不得改变已冻结计划来迎合实际实现。
2. 读取 `docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`、`ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`、`TEMP_REVIEW_EVIDENCE_PROTOCOL.md`、`SESSION_HANDOFF_20261021_V1014_ACCEPTED_V1015_PENDING.md`；`PRODUCT_DECISIONS.md`、2026-10-19后续路线§6.5及Owner隐私决定；既有`docs/versions/v10.0.7/acceptance.md`、`v10.0.9/plan.md`、`v10.1.4/{acceptance.md,integration_acceptance.md}`。
3. 冻结签发前主线为`7a8798ef182998b228c4cb986a61835bcf3ca94f`（后续文档提交会更新HEAD）。**开工重新GET live origin/main/Root Tree/apps/services及本地连续代码树状态**，核对已接受v10.1.4完整apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。产品集成锚 `759015ad0c897c92516531c2f3a94a3a7ff77c02`；后续仅docs改变不要求重放v10.1.4集成。
4. 针对本版一次性定点审查：`ConversationAtomicSendService`及`MessageController`、Flutter `chat_room_page`消息attempt、聊天provider/datasource及WS；`RtcSessionService`、`RtcAuthorityService`、相关信令/LiveKit配置；`NotificationService`、`NotificationController`、Flutter notification provider、现有站内通知；`OfflinePrivateRetentionPolicy`及其测试，`AuthController` login/refresh、Sanctum、Flutter auth/session/secure storage/local storage、缓存键。读取 `EVIDENCE/CACHE-06-OFFLINE-RETENTION-PURE-POLICY/summary.md`、`EVIDENCE/APP-INT-10-LOCAL-PRIVATE-CACHE-AUDIT/summary.md`、`EVIDENCE/AUTH-07-LOCAL-LOGIN-REFRESH-T0-GAP-MAP/summary.md`及既有Owner数据权利合同；这些是历史定点审计，当前源码变化须本版验证后才作判断。
5. 先列“已有且已接受／已存在但缺真实接线／本版需新增／外部供应商或设备未获准”的短矩阵，**矩阵直接放主报告，不额外立治理任务**。同版有疑问先按上述精确路径确定，不重复编写架构报告。

## B. 一版连续实现与最小必要回归

**B1 文字／图片／短视频消息可靠性。** 在现有服务端CN＋Messaging Consent＋ChatMessage＋媒体附件真实合同上，修复发送状态、超时/重试/重复去重/冲突、WS断线重连与前后台读取。已有`client_message_id`和服务端幂等实现优先复用，禁止平行建立第二消息权威或丢弃已接受内容。区分“本机发送中”“服务端已持久确认”“未知是否已成功”“确证失败”；请求超时不宣告发送失败并自动换新键重复发送。相同payload重放返回同一记录，无重复消息/通知/媒体绑定；同键不同payload拒绝。端到端包括真实APP双账户、API、MariaDB、服务短暂不可用/恢复、重启读回。断网期间不创建真实发送队列；任何恢复后的发送都需当时服务端许可，不能复活旧MC。

**B2 旧权限与私有媒体/通知协同。** 在一方Block、MC撤销、CN关闭、账号禁用/注销、设备session撤销/切号、旧JWT、旧URL、旧站内卡片、旧attachment/Range、旧WS事件、迟到HTTP应答下，分别验证“未授权不能新发”“不能越权读私密正文/预览”“不能让旧缓存或通知产生权限”。后端以最新权威事实拒绝而不是仅隐藏Flutter按钮。新通知事件仅传最小指针，不把聊天原文、昵称或Safety详情送到外部可见payload。不要改变Buddy/Friendship/正式恋爱/Activity/Safety业务事实或旧冻结AC。

**B3 RTC受控加固。** 复用v10.0.9接受的本地双端RTC和当前SFU防绕过接口，只在有名问题处修复：WS实际端点、RTC连接/断线/后台恢复、Android网络策略、回声消除配置、接听/拒绝/忙线/挂断、撤权/终止立即禁止旧令牌新入房及停止已有媒体。保留原受控测试的**撤权后不再新join、有效媒体5秒内终止**安全目标；没有具名物理设备与声学条件时对AEC真实音质给`NOT_RUN/DEVICE_PENDING`，不虚构现场听感。受影响的Laravel会话和Flutter RTC/UI做有限回归，不重构全部实时通讯。任何新增真实手机、麦克风/摄像头、系统音频设备、UDP/防火墙/公网需Owner单独授权，**只暂停该子项**。

**B4 T0与期限的真正后端/客户端接线。** 按Owner已决定的15/30天合同，真正成功在线login在服务端形成可信`T0`、事件/账号及设备绑定、服务端时间和可复核权威；注册、单纯refresh、APP重启与profile更新不得偷换T0。在线Token/refresh使用必须受15天与账号当前有效状态限制，在线read/send仍分别重查服务端CN/MC/Block/数据权利。针对可靠经过时间来源、防回拨、离线时钟异常、密钥/设备绑定做实际保护；如当前设备平台不能跨重启证明可信时钟与离线资格，应锁定而不是用本地DateTime假定可信。不得为了跑通15/30策略测试而放行未知撤权。明确记录真实登录→refresh→过15天→离线只读→30天清理的同账号时序。

**B5 方案B缓存保护与真实清理。** 在已有`OfflinePrivateRetentionPolicy`上做安全接线，不把纯判定的三个`candidate`当真实授权。处理已审计的未加密SharedPreferences：全局会话摘要、消息预览、动态`chat_draft_*`、搜索历史和其它实际本版确定的敏感字段。采用已存在且经审查可用的平台安全密钥/加密存储及账户/设备/对象命名空间，明确定义丢密钥/重启/Android备份恢复策略。重启未经在线current-read核验前锁屏，不显示旧草稿/peer名称；有可信已建立离线授权才允许只读已存私密内容，离线不编辑/发送/排队。登出、切号、已知Block/撤权、时钟异常、密文校验失败均fail-closed。到30天对**本次新建的受控测试密文**真正做有限清理并提供清理成功或失败回执，不能仅显示`PURGE_DUE`；旧明文缓存不得反向迁移到另一账号，也不得向GUI泄露。离线未知远端撤权无法实时同步的风险在报告显式列明，联网后先重验后显示；绝不宣称不可撤销地抹去对方已下载副本。检查`auth_interceptor.dart`历史Bearer Token调试输出，如当前仍可达，在本版受影响网络链中删除且做无敏感日志测试。严禁删除历史SQL/APK/原dirty目录。

**B6 通知偏好与授权Push预留。** 逐事件核实“领域事实→资格→最小payload→投递/回执”四层。站内通知和可控Android通知权限、拒绝/撤销、用户类别偏好、静默设置、锁屏通用文案、当前权限点击重验/旧通知失效应真正在已有受控设备/APP上有可见结果。沿用`NotificationService::presentationForUser`及v10.1.4 Activity/Safety最小owner权限，不把本地`pushNotificationEnabled`视为真实投递。当真实Push供应商、SDK/Key/费用/用户授权数据流尚未批准时，只提供可核对后端token注册/轮换/注销接口和无真实投递的isolated transport seam；模拟器或fake transport状态写`TEST_ONLY`，最终标`PROVIDER_PENDING / REAL_PUSH_NOT_RUN`。严禁采购、连接真实Push Provider、注入生产Key或宣称锁屏后台远端Push已成功。无系统通知权限不阻断核心APP。

**B7 一次定点旧来源取舍。** 对语音留言与必要地图/地点只查已知旧源和已接受实现身份，主报告注明`EXISTS_ACCEPTED / NOT_PROVEN / UNKNOWN`；本版不默默新增录音留言、定位发现、陌生人地图/跟踪、真实支付或其它新大型模块。

## C. 开发环境与保护检查必须先于可写测试

- 仅本次任务的受控本地工具、合成账号/媒体、单独干净开发代码树、**全新独立空MariaDB库及专属volume**、回环API/WS端口和既有安全AVD。先列资产归属与占用，再选择新库名（如`elitesync_v1015_dev`），不要照抄旧版本端口/volume。开始任何DB迁移、测试或seed之前，逐项确认effective `APP_DB_CONNECTION`、`DB_CONNECTION`、连接URL、host/port/database、APP_ENV、test runner及`testing/sqlite/:memory:`防误清门；本版新库事前事后建立恢复点。
- 原`D:/EliteSync-v10` dirty、`D:/EliteSync`、各现存代码树及未跟踪/ignored成果、v10.1.1事故数据库/恢复点、v10.1.2～1.4卷与SQL/APK、本地其他项目、全部历史候选与Review分支**一律不自动删除、覆盖、迁移或清理**。不得盲`pull/reset/rebase/stash/clean/prune/force push`；必要时一个隔离工作树即可。既存历史测试失败和原始stderr必须保留，不为追求绿灯修改旧结果。
- 可用Owner既有允许的本地Flutter/Laravel/MariaDB/AVD，必要构建/安装并从同版本APP/API/DB验证。**不授权**任何阿里云生产/公网、更改Windows UAC/防火墙、额外设备麦克风摄像头或外部录制、外部真实Push/AI/支付/身份服务、真实用户与新费用。若新权限/下载/SDK/真实硬件是必要条件，停对应分项，保留其余软件进度，并向Owner集中报告缺口。
- 原始私聊、SQL、APK、签名密钥、JWT/手机号/设备日志/隐私音视频LOCAL_ONLY。公开GitHub仅有界匿名源码/摘要/无隐私测试证据，独立短期审阅分支按现有协议，不合main、不因完成自动删除。

## D. 自验与独立审查——对照固定11项AC

必须逐项以计划中`AC-10.1.5-01～11`提供一个**真实正例＋关键负例＋实物身份/来源与exit**，重点按下表组织，勿把历史suite PASS迁移成本版PASS：

1. 安全起点/开发独立库/保护、固定Commit/Tree；
2. 真实聊天发送、重复请求去重、timeout/重试/WS恢复及站内通知去重；
3. Block/MC/CN/旧JWT/旧media/迟到响应/会话切换，至少一条需要的真实MariaDB reader/writer提交后拒绝证据（须精准thread、连接和时序，死锁/500不能冒PASS）；
4. 图片/视频私有播放、Range、撤权与重启；
5. RTC受控会话状态/重连/挂断/撤权；真机AEC证明不能从模拟器推断；
6. 真正login T0、refresh不重计、15/30天各边界、可信时间异常；
7. 密文在APP设备跨启动、切号与失效，离线只读及实际有限30天清理结果；
8. 通知真实APP站内/GUI权限/类别/当前reader重新鉴权、平台Safety不泄漏；
9. 外部Push明确`NOT_RUN`但transport seam、token登记和撤销的合成正反例可运行；
10. 同一候选APK/后端/持久DB关键旅程、后端定向测试、Flutter定向测试、静态检查与重启恢复；
11. 最终唯一报告、manifest、非作者有界安全复核及脱敏证据。APP字节修改则重建APK/安装/读取版本与SHA；若设备不可用不得虚构安装PASS。

核心软件缺陷导致AC不通过时如实列`OPEN_BLOCKER/CHANGES_REQUIRED`，不能用供应商PENDING一概放行。优先查权限和真值，不以“断言数量很多”替代独立审查。用已接受上版测试验证不变代码时标`REUSED_EVIDENCE`，本版新执行标`NEW_RUN`，未运行标`NOT_RUN`。

## E. 一次集中交付、发布与停止边界

1. 在`docs/versions/v10.1.5/`集中交一份`IMPLEMENTATION_REPORT.md`和一个`artifact_manifest.json`，报告包含实施差异、冻结AC逐项表、代码/持久DB/APP/RTC/通知/离线结果、原失败与deprecation、风险/未验、恢复点及保护、Git固定身份/最终candidate、各证据的`ASTRA_DIRECT`（如有）/`CODEX_REPORTED`/`LOCAL_ONLY`/`TEST_ONLY`分层；不要制作多套相互冲突的报告或让Codex替Astra签验收。
2. 记录源码commit、Root Tree、完整apps/services Tree、唯一Parent/来源基线，提交候选分支及必要脱敏材料供Astra只读复核；绝不把未接受产品自动merge至main。原Owner/工作流/已冻结plan/旧接受、历史SQL、APK、review分支不改变。
3. 如果范围内有P1，先在本次长任务内自主集中普通修复/重测；无法安全解决或需要Owner新权限时标出具体阻断，不无限开始R2/新版本。完结状态：`V10.1.5_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / PRODUCT_MAIN_NOT_INTEGRATED / REAL_PUSH_PROVIDER_PENDING`（若核心仍不满足，改`PARTIAL / OPEN_BLOCKERS`，如实列出）。
4. 完成交付立即停止：**不自行写`acceptance.md`、不生成`integration_acceptance.md`、不安全集成main、不自动发布v10.1.6、不修改生产/云端、不清理历史**。后续由Astra独立验收，必要时一次有界同版R1，再由Owner另行批准单次安全集成。

**本次授权范围仅为受控本地软件开发，不代表实名Provider/Push供应商/真实线下活动/支付/外部AI/录音设备/公网生产已经许可。**

## F. Owner授权续接补充（2026-10-25｜与原冻结计划共同构成当前唯一综合长任务）

Owner明确要求恢复v10.x原定的“长任务单＋中途无监督”模式，并继续下达当前版本任务。本补充不创建第二份版本任务、不改写冻结功能计划；它更新本文件的执行上下文与自治权限。原A-E范围、AC-10.1.5-01～11、隐私/产品合同及外部权限边界继续有效。

### F1. 当前状态与起点

- v10.1.4仍为已接受产品基线：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。开工必须重新核验live `main`、Root、完整apps/services Tree与本地工作树；不得reset回旧SHA。
- D0-B两字段投影与D0-C aggregate failure fallback wiring均已通过Astra静态接受。D0-C候选 `7b8b9959c9e53994ec5c52736d1fb3ca00ba4239`，Root `8b51a383eebfc60e221b6b2936d17f398bb61e16`；审阅包和源码Hash以对应复核与Manifest为准。
- 最近一次Gate 2入口尝试候选 `f9d281d03d1f9ad7a3f7b0b3f3e85582c8580dff` 报告 `SecurityError / UnauthorizedAccess`，exit 1、退出已确认、监督耗时0.375秒。正例、负例、Writer、Serializer、fallback均`NOT_RUN`，没有receipt。该次原任务的一次性启动预算已消费；这不构成Writer运行失败或测试FAIL。
- 本次Owner要求继续下达v10.1.5综合版本任务，授权Codex在此长任务内继续处理版本范围。历史启动尝试仍记录为已消费，不得把旧预算改写成未消费；Gate 2后续尝试须独立记录新执行预算与真实入口证据，不重跑D0-A。

### F2. Codex在本长任务内的自治权限

Codex可在冻结的v10.1.5范围内自主调查、实现、集成、构建、运行必要测试、分析失败、修改代码并重测，完成B1-B7所有可在现有受控环境内完成的工作；可自主选择合理实现细节、修复普通缺陷、调整内部测试编排并做集中返修。不要求Owner逐次批准普通文件修改、测试命令、测试失败分析或范围内修复，也不把每个技术子步骤另立任务单。

优先推进互不依赖的v10.1.5功能，不让一个环境阻断冻结不相关的功能模块。Gate 2/SDK/Producer/30项解析按原任务依赖关系执行；只有前置条件确实未满足时才阻断依赖该门的部分，其余可独立推进的B1-B7工作继续。最终按AC-10.1.5-01～11逐项报告真实证据。

### F3. Gate 2环境阻断处理

1. 不重复调用已被拒绝的原入口，不把0.375秒失败伪称为Writer测试。
2. 在本长任务范围内调查实际拒绝类别与受支持执行方式，核对有效策略/入口要求。不得修改执行策略、系统/全局安全设置、ACL/owner，不使用`-ExecutionPolicy Bypass`或其它规避机制，不申请额外权限。
3. 若存在当前权限已允许、受支持且不改变安全配置的执行方式，可在本长任务下建立并记录一次新的定点正负例运行预算，执行真实Writer验证；遵循原定点测试合同的时限和证据要求。必须保存真实命令、退出、receipt和Hash证据。
4. 若不存在合法执行方式，记录`GATE2_ENVIRONMENT_BLOCKED`，不反复尝试入口；继续推进与该门无依赖的v10.1.5工作，最终报告将Gate 2及其依赖的SDK/Producer/30项解析列为未运行。
5. 只有Gate 2真实正负例通过后才运行完整37案例suite；只有37案例suite通过后才按原条件执行最多一次新独立Sandbox SDK、Producer与30项配置解析。Codex可在本长任务中连续完成依赖阶段，无需Owner逐阶段重新派单，但不得越过真实失败门禁。

### F4. 普通返修与真正停止边界

普通代码缺陷、测试失败、格式/构建问题、同一功能范围的调用链缺口、夹具问题与可逆本地开发问题，均由Codex在本任务内自主处理、重测并记录，不需逐项询问Owner。

仅在需要改变冻结产品合同或版本方向、触及生产/真实用户数据或对外发布、需要敏感信息外传/真实费用/真实供应商或实人操作、需要改变系统/全局安全设置/ACL/owner或未知环境权限、需要删除覆盖历史备份/原dirty根/SQL/APK/密钥等不可逆资产，或工作超出冻结v10.1.5范围时暂停并集中报告。

不要求为普通代码路径增加额外防御层或抽象来替代开发进度；按现有架构实现清晰可维护的逻辑与必要错误处理即可。不得伪造测试结果、把NOT_RUN写成PASS、隐瞒真实环境拒绝或把mock说成真实供应商成功。

### F5. 集中交付

Codex在同一长任务内完成可执行范围后，集中交付一份`IMPLEMENTATION_REPORT.md`和一个`artifact_manifest.json`，覆盖AC-10.1.5-01～11、实施差异、测试/构建结果、APP/API/持久库/Web/RTC/通知/离线证据、外部门禁、源码与apps/services Tree、恢复点及未解决项。范围内普通失败可自主集中修复重测，不另发微任务。

普通non-force发布必要的脱敏候选与报告后，核验Commit/Parent/Root/Blob/原始字节并保留产品双Tree身份。不得自动合并main、不自行签发Astra接受结论、不自动启动v10.1.6。完成后停止等待Astra集中独立验收；Astra可一次列出不合格项，Codex在同一任务范围集中返修后交付。

### F6. 授权边界

本次Owner要求继续下达v10.1.5综合版本任务，Codex仍需Owner手动派发本文件全文。此授权不包含真实Push Provider、外部AI、支付、实人认证、真实线下活动、公网生产或系统级安全策略修改。