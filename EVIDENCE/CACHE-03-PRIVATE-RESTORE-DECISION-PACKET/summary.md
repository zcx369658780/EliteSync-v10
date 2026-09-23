# CACHE-03｜私密恢复逐类待决材料

Status: `WORK LEVEL 2 ACCEPT — DECISION PACKET ONLY`
类型：`docs-only`；本地分支 `main`；基线 HEAD `c3fea157a95cf70f708ae111d94916fefa9c0648`。本页只整理决策输入，不作产品决定或恢复实现。

## 已决定的边界与证据等级

- **已决定**：Owner 选择方案 B，可按账户加密保存私密候选；重启后先在线重新核验当前有效性，通过前不显示。旧未加密聊天缓存不迁移，允许清除及未发送草稿丢失。`PRODUCT_DECISIONS.md` 末三行；`EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md` §§2–3。
- **已接受的权限合同**：当前主体和对象须分别取得同一 context 下的权威 `CN_ACTIVE`、独立 `MC_ACTIVE`；live read 与 send 分开，send 提交时重查。缓存、旧路由、旧同意和本地 token/profile 不授予当前权限。revoke/pause/close 后历史只读默认不开；任何例外需要另外明确的历史访问权威。`APP-INT-07` §§2–5；`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md` D-02/03。
- **来源现状：UNKNOWN**。`EVIDENCE/APP-INT-09-RECOVERY-AUTHORITY-SOURCE-MAP/source-map.md` §§2–3、§6 的独立接受结论未建立真实身份绑定、当前 Connection/Consent/CV 来源、两条 lineage 的 currentness/freshness 证明或新门到读发路径的接线。`EVIDENCE/APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR/summary.md` 的 13 项测试只使用虚构调用方证据；其 positive candidate 不是权限。当前 Flutter `chat_providers.dart` 的 `conversationListProvider/chatRoomMessagesProvider` 仍依据本地 `conversationAccessProvider`，`chat_remote_data_source.dart` 有 mock 与旧 v1 请求；后端纯 evaluator、synthetic adapter 和旧 `ConversationCapabilityService` 也不是新合同的真实权威。这里是已接受的限定静态映射，非运行或生产不存在证明。
- **已接受的 containment**：`EVIDENCE/CACHE-01-LEGACY-PRIVATE-READ-WRITE-CONTAINMENT/summary.md` 只停止两个页面对旧草稿、列表快照和搜索历史的读写与提前展示，没有加密、恢复或在线重验。`EVIDENCE/CACHE-02-LEGACY-PRIVATE-CACHE-PURGE/summary.md` 只建立启动及账户边界的精确清除代码路径；synthetic tests 16/16 PASS，不是实际设备擦除观察。`EVIDENCE/APP-INT-10-LOCAL-PRIVATE-CACHE-AUDIT/summary.md` 描述的是 CACHE-01/02 之前的旧写入风险，不能当成当前页面仍写旧键的证据。

## 逐类决策矩阵

以下“保存、期限、处理、离线”栏均为 **UNKNOWN／待 Owner 决定**，不因方案 B 自动变成允许或必须保存。若某类获准保存，仍须另证实按账户加密和对象绑定，并先解决真实在线权威来源。

| 候选类别 | 当前静态存储或数据来源；核对点 | 当前有效性权威 | 待决：保存、期限与账户/撤权处理 | 待决：核验后离线及历史 |
|---|---|---|---|---|
| Conversation 列表、对方身份、名称、预览 | 当前 `conversation_list_page.dart` 的 `_AuthorizedConversationListPageState.build()` 取 `conversationListProvider`，loading/error 不用旧快照；`chat_remote_data_source.dart#getConversations()` 为 mock 或旧 v1 `/api/v1/conversations`。旧 `messages_conversation_snapshot_v1` 曾包含标识、名称、`lastMessage`、未读（APP-INT-10 §2；`conversation_snapshot_utils.dart`），但 CACHE-01 移除了页面旧键读写。 | **UNKNOWN**：现有 provider、旧 v1 返回或快照都不是当前双输入 live-read grant（APP-INT-09 §2）。 | 是否仅保存不透明索引、是否含姓名/预览/未读须逐字段决定；每字段 purpose/owner、保留起止和终点；logout、A→B、撤权时隔离还是清除均待定。 | 重启前在线核验规则已定；核验成功后掉线是否还能看及可见字段 **UNKNOWN**。revoke/pause/close 后历史默认不开。 |
| 消息正文及附件元数据 | `chat_room_page.dart` 的 `_localMessages` 与输入框是页面内存；`chat_providers.dart#chatRoomMessagesProvider` → `chat_remote_data_source.dart#getMessages()` 的 mock/旧 v1 路径。APP-INT-10 §2 在其限定范围未找到完整正文的设备持久写；插件/系统副本 **UNKNOWN**。 | **UNKNOWN**：旧消息 API 与本地 `conversationAccessProvider` 未接新双输入、当前 CV 和数据权利（APP-INT-09 §2）。 | 是否新增加密正文/附件缓存、字段范围、purpose/owner、保留起止、删除终点与跨账户隔离均待定；旧内容存在不等于可继续保留。 | 在线核验后断网可否读正文、附件或历史 **UNKNOWN**；撤权/暂停/关闭后无独立历史权威则不可读。 |
| 未发送文字草稿 | 当前 `chat_room_page.dart` 的 `_controller` 仅保存本页输入，发送失败在本页回填；CACHE-01 停止 `chat_draft_*` 旧键读写，CACHE-02 只尝试精确清除旧值。旧键缺账户绑定（APP-INT-10 §2）。 | **UNKNOWN**：草稿归属、恢复可见与可发应分别核验；live read 不推出 send，提交仍须重查（APP-INT-07 §3）。 | 是否新增加密草稿、按账户及 peer/conversation/context 如何绑定、未发送内容保留多久、登出/换账户/撤权如何处理均待定；旧明文不迁移已决定。 | 在线核验后掉线时能否继续看或编辑草稿 **UNKNOWN**；掉线不得凭草稿获得发送权。历史只读默认门不因草稿存在改变。 |
| 搜索词与最近搜索 | 当前 `conversation_list_page.dart#_addSearchHistory()` 只更新 `_recentSearches` 内存列表；CACHE-01 停止 `messages_search_history` 旧键读写，CACHE-02 只尝试清除。旧搜索词可能含对方身份或正文（APP-INT-10 §2）。 | **UNKNOWN**：当前页面内存交互不是重启恢复的在线权威。 | 是否加密保存搜索词、是否只存非私密偏好、保留期限与 logout/A→B/撤权处理均待定；`messagesSelectedTab` 整数 UI 偏好与搜索词分开。 | 在线核验后掉线能否显示旧搜索词 **UNKNOWN**；不能以搜索历史重建对方身份或历史访问权。 |
| 未读数、通知预览 | 当前列表从 provider item 的 `unread` 计算；旧列表快照曾含 `unread/lastMessage`，CACHE-01 不再使用。APP-INT-10 §2 对系统通知/插件存储未作设备结论。 | **UNKNOWN**：计数与通知渠道需同当前 grant 和可信来源绑定（APP-INT-07 §3）。 | 是否持久保存计数或通知预览、保存期限与撤销传播/账户切换处理均待定；不能把计数当同意。 | 离线显示及系统通知残留 **UNKNOWN**，不因 UI 置零就声称设备副本清除。 |

**可供 Owner 比较的候选建议，非默认政策**：APP-INT-10 §5 曾提出“最小加密候选索引，名称/预览/未读先不缓存”及“草稿、搜索词、正文先不新增持久化”的第一版建议；也可逐类选择其他保存范围，但每一项都须明确目的、权威、期限与处理。没有任何候选建议已由本页接受。

## Owner 最小问题集与答案影响

| 问题（尚无答案） | 答案如何改变后续边界 |
|---|---|
| **1. 第一版逐类保存什么？** 请分别选定索引字段、姓名/预览/未读、正文/附件、未发送草稿、搜索词、通知预览的“保存或不保存”；若保存，说明用途与对象绑定。 | 决定加密缓存 allowlist、按账户/Connection/Conversation 的隔离粒度及所需当前来源；未选类别不得由实现者自行加进缓存。 |
| **2. 每个获准保存类别保留到何时，遇到登出、换账户、撤权/暂停/关闭如何处置？** 请给每类起点、终点、复核触发与“清除或隔离”等明确结果；若需跨设备/法律例外，单独标出。 | 决定 retention 与删除/隔离合同、失败重试和可验证回执；D-07 没有通用期限，CACHE-02 旧键清除不能替代新类别政策。 |
| **3. 首次在线核验通过后掉线，允许看到哪些已核验类别？** 请分别说明当前会话掉线与重启后离线；后者必须遵守“重启后先在线核验”的已接受规则。是否需要未来另行审议 revoke/pause/close 后历史只读？ | 若不允许，离线继续锁定；若考虑允许任何内容，须另定有效性时效、失效传播、数据权利与独立审查，不能把上次 grant/缓存 TTL 当成当前授权。历史只读仍默认关闭，只有单独明确的 subject/audience/purpose/retention/jurisdiction 权威才能改变。 |

**非 Owner 答案可替代的依赖**：后端/身份责任方仍须给出真实主体、当前 Connection 与独立 Messaging Consent 的 authoring、persistence、受信读取、各自 revision/currentness/freshness 与冲突协调，以及权威 CV 生命周期和读发接线的可核验证据（APP-INT-09 §§2–4）。这些在本轮均为 `UNKNOWN / NOT ESTABLISHED`；不能从 synthetic provider、纯 evaluator、旧 v1 行或本地缓存推导。

## 本轮只读核对与停点

读取：`AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`；APP-INT-07～10、CACHE-01/02 既有证据；上述 Flutter 与 Laravel 指定源码及数据权利接受文档。仅用当前本地文件核对旧审计之后的 CACHE-01/02 页面和清除变化。文档来源、代码存在、synthetic 测试、设备观察和生产证明分开表述；本轮无新运行、设备或生产证明。未读取真实值、账户、Token 或密钥，未运行 Flutter/Android、HTTP/API、DB、网络或设备操作。原有无关未跟踪目录 `EliteSync-v10-ip13i-r17-r3-mapping-rereview-v0-1/` 保留原状。

路径与检查：`git status --short` 仅列出本证据目录和原有无关未跟踪目录，无 tracked 改动。`git diff --check` 按预算运行 **1 次，exit 0**；它不覆盖未跟踪新文件，另对本文件做只读尾随 tab 检查为 0。未运行产品测试或构建。本页不决定保存范围、期限、离线历史，不建立真实重验或恢复能力；作者未提交、备份、推送或派发后继。

## Work 独立验收（2026-09-23）

**LEVEL 2 ACCEPT — 限逐类决策材料。** Work 核对基线 `main` HEAD `c3fea157a95cf70f708ae111d94916fefa9c0648`、唯一新增文件范围、APP-INT-07/09/10 与 CACHE-01/02 接受证据，并定点核对当前 Flutter provider、旧 v1 数据源及两个页面的内存状态。矩阵把已接受的在线重验与先锁定规则和未建立的真实权威来源分开；保存类别、期限、账户/撤权处理及核验后离线访问均保持 `UNKNOWN`。Owner 三组问题只说明答案将改变的实现边界，没有代替 Owner 作选择。

Work 独立检查本文件无尾随空白，并在精确暂存后运行 `git diff --cached --check`；本任务没有产品测试或运行证明。此验收不授权新加密缓存、真实恢复、离线历史或生产读发；后续实现须等 Owner 逐类决定及真实权威来源证据。
