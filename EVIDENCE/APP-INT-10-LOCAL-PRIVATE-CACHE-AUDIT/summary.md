# APP-INT-10｜Flutter 私密本地缓存静态审计

**状态：WORK LEVEL 2 ACCEPT — STATIC CACHE AUDIT ONLY。** 作者本地 `main` 基线 `33cecb208b857658a6d3530ae8e06b3a99b435d0`。源码明确存在未做应用层加密的草稿、Conversation 列表快照与搜索历史写入路径；旧缓存展示门未接在线双输入重新核验。这里的“明确”指源码把字符串/JSON 直接交给 `SharedPreferences`，**不声称已读取设备文件或证明操作系统物理字节为明文**。运行可达性和设备现存内容均未核验。

## 1. 权威边界与可复核来源

Owner 在 `PRODUCT_DECISIONS.md`（blob `2a7b8ddc7ee3715398ddf2ba19cb306be1290734`）选择方案 B：**允许加密私密缓存；重启后在线核验通过前不显示**。APP-INT-07 合同 `EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md`（`f17cbce1ab83e697b81210d13d5a7208f452c2eb`）要求锁定后分别核验当前 Connection/Consent、读发分离。APP-INT-09 已接受映射 `EVIDENCE/APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP/source-map.md`（`58752f3826b5c2208b39ec6a2d81fc96c944b103`）确认真实来源与产品接线未建立。Owner 数据权利接受记录 `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`（`7f8e98b0d82ff666db401964e32f80deb08d7e15`）D-02 禁止旧路由/缓存/未读恢复 live consent，D-03 在 revoke/pause/close 后不默认开放历史只读，D-07 要求每类保留数据有 purpose、owner、起止、复核和终点；具体期限未定。

以下源码 blob 均由 `HEAD:<path>` 核对；编号供矩阵引用。

| ID | 精确文件与 Git blob；静态核对点 |
|---|---|
| S1 | `apps/flutter_elitesync_module/lib/core/storage/local_storage_service.dart` `6f7e67f4fa65e7c010a4250e78314801a9c44351`；`setString/getString/setJson/getJson/remove()` 直连 `SharedPreferences`，`remove` 仅对给定完整 key。 |
| S2 | `apps/flutter_elitesync_module/lib/core/storage/secure_storage_service.dart` `c2d6c84ac40868c5c854da57936c039c1fd66f03`；封装 `FlutterSecureStorage`。此封装没有证明 Android 实际密钥配置、备份或恢复语义。 |
| S3 | `apps/flutter_elitesync_module/lib/core/storage/cache_keys.dart` `b1881756c063b18fe8d403afd592e5368d2499ee`；各 key 常量，注释“Non-sensitive”不是敏感性或加密证明。 |
| S4 | `apps/flutter_elitesync_module/lib/shared/providers/app_providers.dart` `c1228beb511341ccff4219ade67ec0e70fbc0c04`；`localStorageProvider/secureStorageProvider` 绑定 S1/S2。 |
| S5 | `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart` `393d9989199e462d62284645b23a4fdb43b95781`；`_loadDraft/_persistDraftNow/_sendMessage`。 |
| S6 | `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` `3caf566f5954bbdb6764801df6d874bf40bb7ea4`；`stableKey` 为 `peer:<id>` 或 `conversation:<id>`，没有账户 ID。 |
| S7 | `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart` `6a7f332254ca662cc07031fd09f242b6236292ca`；`_load/_saveConversationSnapshot()`、`_buildSnapshotLoadingScaffold()`、搜索历史与偏好。 |
| S8 | `apps/flutter_elitesync_module/lib/features/chat/domain/utils/conversation_snapshot_utils.dart` `9246b13182e68a10e6412788aba7cf8a7e95b3a7`；序列化 name、lastMessage、lastTime、unread、peer/conversation/match ID。 |
| S9 | `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart` `fb09ca4ed76590c78c889eccba49b26a4a33f259`；仅在 snapshot `canRevealPrivateContent` 时构造受保护页面。 |
| S10 | `apps/flutter_elitesync_module/lib/features/chat/domain/product_conversation_contract.dart` `a226f717dd5d91373402d6129e0cf700cb43f7b9`；`ConversationAccessSnapshot.canRevealPrivateContent/canSend` 对 synthetic active 同样为真。 |
| S11 | `apps/flutter_elitesync_module/lib/features/chat/presentation/state/conversation_access_state.dart` `a652a3421408f9e59045cd1cd95a99306b405da7`；本地 synthetic lifecycle，Connection 非 active 时清本地状态，不清 S1 缓存。 |
| S12 | `apps/flutter_elitesync_module/lib/features/chat/presentation/providers/chat_providers.dart` `68788783eea53649056725b74f21d692fceda0a9`；列表/详情/消息 provider 用 S10 门，再走 repository。 |
| S13 | `apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_remote_data_source.dart` `b6c8c281aabb45e3dcbfa6bb00b27d41ca35a2a6`；mock 本地数据，非 mock 为 v1 API；此处没有消息正文的设备写入。 |
| S14 | `apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_socket_data_source.dart` `afa90445767349b69c933cc37939266b200eeb31`；mock socket 空流，非 mock 可读缓存 profile 或 v1 profile。 |
| S15 | `apps/flutter_elitesync_module/lib/features/auth/data/datasource/auth_local_data_source.dart` `b07045b16c8a818da65aae75f3df2d94a8ca8e9d`；`persistSession/clearSession/_clearAccountScopedCaches`。 |
| S16 | `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart` `786444bf0de85f799eb2612fcf65029314a24004`；`build/setAuthenticated/updateProfile/setUnauthenticated`。 |
| S17 | `apps/flutter_elitesync_module/lib/features/auth/data/repository/auth_repository_impl.dart` `e40857b10058962916d2a08c7a5e79eadee86b54`；`login()` 调 S15 保存，`logout()` 调 S15 清理。 |
| S18 | `apps/flutter_elitesync_module/lib/features/auth/presentation/providers/login_form_provider.dart` `14ef367ef046f369c8b33db0395bbcb89ea867ea`；`submit()` 后另调 S16 `setAuthenticated()`。 |
| T1 | `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart` `5f7c485c1587dae70453b93f6dad25f8a46344cb`；已有测试明确期待 refresh pending/failure 时显示缓存 name/lastMessage；本轮未运行。 |
| T2 | `apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart` `1879d383276c2345018a0b74c3b0a66be375ae92`；存在开场建议写草稿和发送失败回填测试，未证明加密或重启授权。 |

## 2. 按数据类别的读写与暴露矩阵

“无加密证据”表示这些精确调用在到达 S1 前没有加密层，不能由 S3 注释或设备系统保护补写为“已满足方案 B”。“NOT FOUND IN SCOPE”限本任务 Flutter 目录，非全仓不存在证明。

| 类别 | 精确 key、读写时机、后端与绑定 | 门控/状态及判断 |
|---|---|---|
| **消息文字草稿** | S5 `_draftKey`＝`chat_draft_` + S6 `stableKey`；输入变更 220 ms 后 `_persistDraftNow()` 把 trim 后正文通过 S1 `setString()` 写入 `SharedPreferences`；空串/发送成功前按 exact key 删除；受保护房间 `initState()` 中 `_loadDraft()` 经 S1 `getString()` 读回输入框。仅 peer/conversation 绑定，**无账户绑定**。 | **静态确定：应用层未加密持久写路径**。写前检查 S10 `canSend`，读前检查 `canRevealPrivateContent`，但它们可由 synthetic active 满足；没有在线双输入门。`_loadDraft()` 在 await 前检查权限，读回后只查 `mounted`，若期间权限变化是否短暂回填为**可能/运行未知**。S5 `dispose()` 取消 debounce，不保证已经落盘的草稿清除。发送失败会回填输入框并可能触发再次保存。 |
| **Conversation 索引、对方标识、名称** | S7 `_saveConversationSnapshot()` 把 S8 的 `id/name/peerUserId/conversationId/matchId/entryKind` 编为 JSON，写固定 key `messages_conversation_snapshot_v1` 到 S1；受保护列表 `initState()` 读回。**固定全局 key、无账户或 Connection aggregate 命名空间**。 | **静态确定：应用层未加密持久写路径**。S9 在构造受保护子页面前有 snapshot 门；默认未建立态应不构造子页面，但没有在线重新核验。若子页面已开放且 provider loading/error，S7 使用已读的快照；T1 测试明确断言先显示缓存名称。设备重启后真实可达性为 **UNKNOWN**，不能用此测试冒称复现。 |
| **消息预览、时间与未读** | S8 同一个快照保存 `lastMessage/lastTime/unread`；S7 loading/error 的 `_buildSnapshotLoadingScaffold()` 把显示用 unread 改为 0，仍显示 name 与 `lastMessage`，并标“上次内容”。 | **静态确定：预览及旧未读数已进入未加密应用层缓存；条件满足时预览可在当前刷新完成前显示**。未读 0 只发生在显示副本，原 JSON 仍含旧 unread。该路径与方案 B 的“在线核验前不显示”存在条件冲突；与 D-02/03 也不能互相授权。 |
| **完整消息正文、附件与本地临时媒体** | S12 消息 provider → S13 mock/旧 v1 remote；S5 有 `_localMessages`、输入框、待发附件路径/预览等内存字段。除文字草稿及列表 `lastMessage` 外，在限定 `features/chat`＋S1/S2 搜索中未见正文/附件写入本地持久存储的调用。媒体选择/上传读取本地文件的路径不等于本模块创建或保留该文件。 | 设备上是否有插件/系统临时媒体文件、HTTP 缓存或其他模块副本 **UNKNOWN**；本范围完整消息持久缓存为 **NOT FOUND IN SCOPE**。旧 v1 与 mock 路径均不能作为方案 B 的真实恢复证明。 |
| **搜索词、列表偏好** | S7 `_addSearchHistory()` 将最多 8 个搜索词写 `messages_search_history` 到 S1；`initState()` 读；`messages_selected_tab` 写读整数。S3 `messages_search_query` 常量在本范围未见写调用。 | 搜索词可能包含对方姓名或消息内容，**静态确定：无应用层加密写路径**。偏好整数本身不证明私密权限；搜索词类别敏感性由用途/输入决定。 |
| **通知/未读展示** | S7 用当前 provider 的 unread 展示，也从 S8 快照持久保存 Conversation unread；`messages_quick_unread_only` 只有 S15 清理与 S3 定义，本范围未定位写入。通知数量来源实现不在本次允许目录。 | 单独的通知正文/预览持久 key **NOT FOUND IN SCOPE**；通知插件/系统存储与实际设备展示 **UNKNOWN**。不能因为离线 UI 将 unread 置 0，就称磁盘旧数已清。 |
| **路由标识** | S6 `ChatRouteState` 在内存持有 peer/conversation/match ID 与 title，`stableKey` 拼入草稿持久 key；S7 点击会话时构造 route state。此范围未见将完整 route state 单独序列化到 S1/S2。 | 草稿 key 本身泄露关联标识的风险属**静态确定**；路由恢复、系统深链/历史栈持久化是否发生为 **UNKNOWN**。route ID 不代表 consent（D-02）。 |
| **账户与会话缓存** | S15/S16：access/refresh token 经 S2 `FlutterSecureStorage`；`last_known_profile` 含用户标识/联系方式及资料，经 S1 `setJson()` 存 `SharedPreferences`，启动时 S16 同时读 token 与 profile。S17 登录先调用 S15 清理后写；S18 随后再写 profile/token。 | token 使用安全存储封装，但实际平台密钥/备份语义未审；profile **静态确定无应用层加密**，且缓存 profile 不是当前身份权威。S16 `setUnauthenticated()` 仅删 token；S15 `clearSession()` 删 profile/固定快照，但动态草稿键清理有缺口。 |

## 3. 时序、账户切换与清理缺口

| 场景 | 静态证据与确定性 |
|---|---|
| 首次安装/无缓存 | 无现存设备数据证明。S9/S11 默认未建立态关闭私密子页面；不能推断所有路由、外部插件或设备状态。**静态可见的默认门，运行 UNKNOWN**。 |
| 重启及异步回填 | S16 可凭持久 token/profile 构造 authenticated 状态，但不做本任务合同的在线双输入核验。S7/S5 只有在 S9 允许构造的受保护子页中才读取缓存；一旦被允许，S7 在刷新 pending/error 显示旧名称/预览（T1），S5 将草稿回填。**条件路径确定，真实重启可达性 UNKNOWN**。 |
| Connection/Consent 失效 | S11 清本地 synthetic lifecycle，S9 按 snapshot 隐藏子页；S5 页面销毁取消待执行 debounce、清内存 widget，S1 的草稿与列表快照不会因该失效自动删除。失效期间已发起的 S7 `_loadConversationSnapshot()` 仅在读后检查 `mounted`；已发起的 `_saveConversationSnapshot()` 用 `unawaited`，没有提交前二次核验。**磁盘保留确定，异步竞态实际显示/写入 UNKNOWN**。 |
| logout | S17 `logout()` → S15 `clearSession()` 删除 secure token、固定 `last_known_profile`、`messages_conversation_snapshot_v1`、搜索历史等。S15 调 `remove('chat_draft_')`；S1 `remove` 只删精确 key，而 S5 实际键为 `chat_draft_peer:<id>` 或 `chat_draft_conversation:<id>`。**动态草稿键不会被该调用命中，静态确定**。未读副本随固定快照被删；是否有其他系统副本 UNKNOWN。 |
| 账户切换/重新登录 | S15 `persistSession()` 会清固定缓存再写新 profile；动态草稿不在精确清理范围，且 S6 key 不含账户 ID。若不同账户触及相同 peer/conversation 数值并由既有门打开，旧草稿可被同 key 读取，属于**静态可能的交叉账户暴露路径**，未在设备复现。S16 `setAuthenticated()` 自身不清旧缓存；本范围已见的 S18 登录先经 S17/S15，但其他调用路径不作全仓断言。 |
| 发送与页面销毁 | S5 `_sendMessage()` 只检查当前 S10 `canSend`，没有 APP-INT-08 的在线 `sendSubmission` 当前双输入重验；旧 mock/v1 发送与本次真实恢复无关。S5 `dispose()` 不持久化新草稿也不清已写草稿。**当前代码关系确定；真实服务端提交行为未运行**。 |

## 4. 最小 containment、负向验证与回退要求（建议，尚未授权实施）

1. **先阻断未加密私密写与旧快照展示。** 未来独立任务可先使 S5/S7 在没有受信在线双输入 read/send 门时不读取、不展示、不写入私密缓存；旧 v1 兼容路径与 synthetic 演示须明确隔离。负向用例：重启 loading/offline/timeout、Consent revoked、Connection closed、新 aggregate、旧快照存在时均不显示名称/预览/草稿、不发送。单靠 “上次内容” 标签或把 unread 设 0 不满足方案 B。
2. **既存数据迁移不可默默遗忘。** `chat_draft_*` 与 `messages_conversation_snapshot_v1` 已可能存在于旧安装的 S1；仅切换新加密库不会自动移除或保护旧值。先决定是否允许读取旧值以迁移、何时清除、失败/中断/账户切换时如何处理、如何证明没有跨账户回填。任何设备数据处置须另行授权；本轮没有删除、枚举或读取真实值。回退不得重新启用旧明文读取/展示；须有能识别旧版本缓存并保持锁定的回退条件。
3. **按类别建立独立保存与清理合同。** 对草稿、最小索引、预览、搜索词、未读分别规定加密与账户/Conversation 绑定、purpose/owner、保留起止、撤销/退出后的处理及迁移版本。负向用例：logout、A→B 账户切换、相同 peer ID、route adoption、异步 read/write 在 revoke 后返回、发送失败回填、进程退出/恢复。通过前不扩大到正文/附件或离线历史。
4. **验证层级。** 先做静态与 fake-storage 单元负向测试，再在获授权的设备测试中观察真实缓存迁移与首帧遮蔽；真实来源和数据权利未建立前，任何正向“恢复可见”只能留在 synthetic fixture。接受门至少 LEVEL 2；涉及真实用户数据、政策/保留决定或不可逆删除时依最高风险升 LEVEL 3 并取得具体授权。

## 5. 给 Owner 的最少决策表

下列是**建议，不是已接受政策**；方案 B 只允许加密私密缓存且规定在线核验前不显示，并未指定哪些类别必须保存。

| 类别 | 第一版建议 | 尚需 Owner/法律/后端明确 |
|---|---|---|
| Conversation 候选索引 | 若确需连续性，只考虑经加密、按账户与当前 Connection/Conversation 绑定的最小不透明标识；在线核验前仅作不可见候选。名称、预览、未读先不缓存。 | 是否保存标识及其 retention/退出处理；后端当前来源与核验协议。 |
| 草稿、搜索词 | 暂不新增持久缓存；既存 `chat_draft_*`/搜索历史作为待处置风险，不自动读作新方案 B 材料。 | 是否允许加密保存、在哪个账户/对象范围、何时清除、旧明文值是迁移还是删除及失败回退。 |
| 正文/附件、通知预览、旧未读 | 第一版暂不缓存；只用在线获准的短生命周期内存数据。 | 每类 purpose、owner、保留起止与终点；离线历史是否另获权威；附件/系统通知和插件数据的设备边界。 |
| 核验失败、logout、账户切换 | 建议立即隐藏并停止读发；候选数据可选择隔离等待、按明确政策删除或在受控迁移后保留，但不能因缓存存在而自动恢复可见。 | 三种情形逐类选定保存/清除及跨账户隔离；是否允许旧明文迁移、何时可接触既存设备数据。D-03 默认无撤销后历史只读。 |

## 6. 本轮回执与停点

检索限定于任务允许的 Flutter `core/storage/`、`features/chat/`、`features/auth/`、`shared/providers/` 及上述已有测试；先用 `codebase-memory-mcp` 定位 S1/S5，发现图谱仍列出与当前 S5 不符的旧状态类名，后用受限 `rg` 与定点读取核对，图谱结果不作为当前文件内容证明。无数据库、设备或 app-private data 读取。现有 T1/T2 只作静态测试源码，不在本轮运行。未运行 Flutter/Dart/Gradle、模拟器、HTTP/API、DB、网络或远端同步；未修改产品源码、测试、依赖、配置、政策或控制面。根目录原有无关 untracked 保留。发现草稿与快照风险后已先向 Work 报告。唯一新增结果为本文件；候选等待 Work LEVEL 2 独立 ACCEPT/REJECT，不自接受、不提交、不备份、不派发后继。

## 7. Work 独立审查（2026-09-23）

Verdict: **ACCEPT — STATIC PRIVATE CACHE AUDIT; REMEDIATION REQUIRES POLICY DECISION**。Work 核对作者原候选 blob `a99848583f88f6f55e3e14dae1e25ea6882d3952` 及表中 20 个源码/测试 blob，均与本地文件匹配。独立阅读确认 S1 使用 `SharedPreferences.setString/getString/remove` 而没有应用层加密；S5 把文字草稿写到带 `stableKey` 后缀的 key，S15 登出只删除固定 `chat_draft_` key，故该调用不能清理动态草稿键。S7/S8 的快照包含名称、最后消息与未读；受保护子页面的 loading/error 分支可显示旧名称/预览，T1 既有测试源码亦明示该条件行为。以上均是限定静态路径结论，未读取设备文件、未运行测试或证明实际安装的缓存内容/重启可达性。

方案 B 的加密与在线重新核验前遮蔽尚未由现有路径满足。需要 Owner 决定旧 `chat_draft_*`、会话快照和搜索历史的清除/迁移政策，以及第一版各类缓存范围；删除旧值可能损失未发送草稿，盲目迁移则因旧键缺账户绑定而有跨账户风险。本验收不授权读取或删除设备现存数据，不授权产品修复、真实恢复或旧 v1 聊天路径接入。
