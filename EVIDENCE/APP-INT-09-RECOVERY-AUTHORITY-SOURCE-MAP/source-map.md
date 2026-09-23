# APP-INT-09｜恢复权限权威来源静态映射

**状态：WORK LEVEL 2 ACCEPT — REAL RECOVERY AUTHORITY NOT ESTABLISHED。** 作者基线为本地 `main` `9ff9990d2aff57ae2f607572faf404d4bf5d692d`。本文件仅记录受限静态读取；`APP-INT-08` 的 `authoritativeClaim` 与各项 `passed` 均可由未来调用方构造，不能证明真实身份、来源真伪或当前有效性。当前不得据此恢复私密内容、授予读写或发消息。

## 1. 合同与源码定位

下表 blob 均为本地 `HEAD:<path>`，不是运行回执。后文用编号引用精确路径、类/方法与 blob。状态词：**合同**＝已接受语义；**存在**＝静态代码存在；**synthetic**＝仅本地开发演示；**接线**＝本地代码实际调用关系；**运行证明**仅指现有回执明说的范围。未列为接线或运行证明的项目均不能外推。

| ID | 精确路径；Git blob；核对点 |
|---|---|
| C1 | `EVIDENCE/APP-INT-07-RECOVERY-REVALIDATION-CONTRACT/contract.md`；`f17cbce1ab83e697b81210d13d5a7208f452c2eb`；§§2–5，Work LEVEL 2 接受的设计合同。 |
| C2 | `EVIDENCE/APP-INT-08-RECOVERY-GATE-PURE-EVALUATOR/summary.md`；`d0603fe8c6a87780ade56550a9f969b97d2daa5a`；Work LEVEL 2 接受及 13 项虚构输入测试回执。 |
| C3 | `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`；`d3b6cf099009d44302925e98f9ab8dfb70a19f2f`；BA-04 §§2–5，仅 Connection 设计接受。 |
| C4 | `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`；`a133285b0a1923d5d2965ced989d1c8b1dbf8e49`；BA-05 §§2–6，独立两输入、读发分离。 |
| C5 | `docs/architecture/ELITESYNC_V10_IP_12D_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_EVALUATOR_IMPLEMENTATION_ACCEPTANCE_V0_1.md`；`b66e971eca989f59292de4a9ec167451d2bb1359`；纯 backend evaluator 接受，不含 persistence/API/client。 |
| F1 | `apps/flutter_elitesync_module/lib/features/chat/domain/conversation_revalidation_gate.dart`；`080f1a2efb9ec941e93e7dfd53506f2cd06bb6e8`；`RevalidationRequest/Evidence/Checks`、`ConversationRevalidationGate.evaluate()`，纯调用方声明判定。 |
| F2 | `apps/flutter_elitesync_module/lib/shared/providers/session_provider.dart`；`786444bf0de85f799eb2612fcf65029314a24004`；`SessionNotifier.build()/setAuthenticated()`，从本地 token 和缓存 profile 恢复会话状态。 |
| F3 | `apps/flutter_elitesync_module/lib/features/auth/data/datasource/auth_local_data_source.dart`；`b07045b16c8a818da65aae75f3df2d94a8ca8e9d`；`persistSession()/clearSession()`，本地会话及账户缓存。 |
| F4 | `apps/flutter_elitesync_module/lib/features/auth/data/datasource/auth_remote_data_source.dart`；`647c81582a8fa0958d764c70b28ecb41ba8dbdd2`；`login()` 有 mock 与 v1 请求分支。 |
| F5 | `apps/flutter_elitesync_module/lib/features/connection/presentation/providers/connection_presentation_provider.dart`；`8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f`；`ConnectionPresentationController.build()/apply()`，dev synthetic 内存状态。 |
| F6 | `apps/flutter_elitesync_module/lib/features/chat/presentation/state/conversation_access_state.dart`；`a652a3421408f9e59045cd1cd95a99306b405da7`；`ConversationAccessController.build()/apply()`，dev synthetic 内存 consent/Conversation，并在 Connection 非 active 时重锁。 |
| F7 | `apps/flutter_elitesync_module/lib/features/chat/domain/product_conversation_contract.dart`；`a226f717dd5d91373402d6129e0cf700cb43f7b9`；`ProductConversationContract.transitions`、`ConversationEvidenceAuthority`。 |
| F8 | `apps/flutter_elitesync_module/lib/features/chat/presentation/providers/chat_providers.dart`；`68788783eea53649056725b74f21d692fceda0a9`；`conversationListProvider/conversationDetailProvider/chatRoomMessagesProvider/sendMessageUseCaseProvider`。 |
| F9 | `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart`；`6a7f332254ca662cc07031fd09f242b6236292ca`；`ConversationListPage.build()` 及 `_loadConversationSnapshot()`。 |
| F10 | `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`；`393d9989199e462d62284645b23a4fdb43b95781`；`ChatRoomPage.build()`、`_sendMessage()` 与本地草稿/乐观消息路径。 |
| F11 | `apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_remote_data_source.dart`；`b6c8c281aabb45e3dcbfa6bb00b27d41ca35a2a6`；`getConversations()/getConversation()/getMessages()/sendMessage()`，mock 分支先于 ApiClient；非 mock 为旧 v1 chat 请求。 |
| F12 | `apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_socket_data_source.dart`；`afa90445767349b69c933cc37939266b200eeb31`；mock `observeMessages()` 返回 `Stream.empty()`。 |
| B1 | `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`；`a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`；`evaluateCurrent()/evaluateTransition()/invalidate()`，纯派生判定。 |
| B2 | `services/backend-laravel/app/Domain/ProductConnectionPersistenceApplicationAdapter.php`；`06e1dfa4134a3c01dde5b4cf1ccc592a352f8e84`；四个 `*Synthetic()`、`execute()/submitAndRead()`，仅 synthetic/dev-test 派生投影。 |
| B3 | `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php`；`900acab11dda301abdecc7491b10be27655c2155`；`evaluateTransition()/evaluateLiveGates()/invalidateLiveGate()`，纯 Consent 与双输入判定。 |
| B4 | `services/backend-laravel/app/Domain/CoreDomainSemanticIntegrationHarness.php`；`3ca0e5cd5bec86b44173212ec0099a281ddb6775`；`run()` 将场景数组交给 B1/B3，声明 `zero_writer`。 |
| B5 | `services/backend-laravel/app/Services/ConversationCapabilityService.php`；`f564dd507f2d4d35c87327b937c1f7c91ba8166c`；`evaluate()/authorizeSend()`，旧 `DatingMatch`/block/member 条件。 |
| B6 | `services/backend-laravel/app/Services/ConversationDomainService.php`；`ac6107e1220c1cc545db3ea6fdc8c2e9c3302c8b`；`listForUser()/summarizeConversation()/findConversationForParticipant()`，存量 Conversation/消息读取。 |
| B7 | `services/backend-laravel/app/Services/ConversationAtomicSendService.php`；`d75a4bfa7a224ad0b1b88ce6e57264a3ac803238`；`send()` 在事务内调用 B5 `authorizeSend()`，写存量消息。 |
| B8 | `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php`；`60622aa2312b5b99d92441de791a762a352e095f`；`index()/store()/show()/showPeer()` 使用 `$request->user()`、B5/B6。 |

## 2. APP-INT-08 输入逐项映射

| 输入／必须证明的事情 | 已存在的候选来源与证据等级 | 当前结论／缺口 |
|---|---|---|
| 当前主体、双方参与者及其身份真实性 | F2 `SessionNotifier.build()` 读取本地 token/profile，F3 保存；F4 `login()` 有 mock/远端分支。B8 从 `$request->user()` 取 actor；B5/B6 使用旧 user/peer/member。**代码存在**，但没有对 F1 请求的当前主体、双方参与者及 B1/B3 证据做同一权威绑定；本轮无服务运行核验。 | 当前真实身份与跨端绑定来源 **NOT ESTABLISHED**。缓存 profile、token 存在或 `$request->user()` 的静态调用均不证明 APP-INT-08 的七项 caller check 已通过；不记录任何真实 token/账号值。 |
| 当前 Connection aggregate/context、`CN_ACTIVE` | C3/C4 为**合同**。B1 `evaluateCurrent()` 能从输入 evidence 派生状态；B2 四个 `*Synthetic()` 能校验输入并存取派生投影；F5 仅 **synthetic** 内存状态。 | 生产/真实 Connection authoring、当前 aggregate 查询及到 Flutter 的受信投影 **NOT ESTABLISHED**。B2 结果显式否认 `connection_authority`/`production_ready`，不能以投影或 F5 的 `CN_ACTIVE` 代替源证据。 |
| 独立 `MC_ACTIVE`、同一 Connection 下的 purpose/audience | C4/C5 为**合同/纯 evaluator 接受**。B3 `evaluateConsentCurrent()` 核对 `consent_identity`、`connection_identity`、参与者、purpose 与 protected bindings；`evaluateLiveGates()` 将 read/send Consent 分开。F6 的 `hasLocalMutualConsent` 和 `CV_ACTIVE` 仅 **synthetic**。 | 独立 Messaging Consent writer、persistence、当前 read/send Consent 取回、撤销传播及客户端受信来源 **NOT ESTABLISHED**。Connection active、F6、本地布尔值或 CV 状态均不能证明 `MC_ACTIVE`。 |
| source owner/provenance、两个独立 lineage/revision/currentness/freshness | C3/C4 要求各自独立且不能按到达顺序裁决。B1/B3 通过输入 evidence 与 `CommonAuthorityEvidenceContract` 判定；B2 `buildRecord()/submitAndRead()` 保留 Product Connection 派生依赖和 source-local revision，但只针对给定 synthetic 证据。F1 的 `RevalidationEvidence` 存储不透明 revision 与调用方 `RevalidationChecks`。 | 可表达和核对**调用方提供的字段**，不能产生/认证真实来源，不能证明新于撤销/关闭事实。两条权威 lineage 的 authoring、取回、比较/冲突协调与可信 freshness receipt **NOT ESTABLISHED**；不能发明全局 revision、客户端 TTL 或 LWW。 |
| 当前 Conversation lifecycle、存量内容归属 | F7 定义 CV transitions；F6 只在 synthetic 本地推进。B6 读取存量 Conversation/member/message；B5 根据存量会话或 released Match 判断 read。F9 有本地 snapshot，F10 有草稿与乐观消息。 | authoritative `CV_ACTIVE/CV_PAUSED/CV_CLOSED` 来源、与当前 Connection/Consent/subject 的绑定、历史访问和数据权利 **NOT ESTABLISHED**。存量行、snapshot、草稿或 UI 路由不是当前授权；F1 根本不消费 CV lifecycle（C2 明示）。 |
| live read 与 send submission 重查 | C1/C4 要求双输入当前有效、读发分开、send 时重查。B3 纯函数分别计算 live read/send；B4 场景 harness **接线** B3，但不是 transport 或 writer。F1 `evaluate()` 在 `sendSubmission` 才可能给 send **candidate**；F8/F9/F10 当前用 F6 `canRevealPrivateContent/canSend`；F11 mock 本地返回、非 mock 走 v1 API。B8/B7 旧路径调用 B5，而 B5 读可因存量 Conversation 或 released Match 成立，发可因 released Match 成立。 | F1 在 Flutter `lib/` 中没有产品调用点；B3 在 Laravel `app/` 中仅见 B4 调用。新门到 F8–F11、B5–B8 的实际 live-read/live-send 接线 **NOT ESTABLISHED**。旧 v1 聊天路径不满足 BA-05 双输入，不得作为恢复目标或新权限来源；发送时读过页面并不构成新门的提交点重查。 |

这些是**实现接线缺口**，不是 C3/C4 两份已接受合同互相冲突。B5/B8 的旧匹配式聊天权限与 C4 新合同的要求不同；若未来复用该路径，必须先由独立任务明确迁移/隔离及验证，不能在本映射中判它为新合同的有效实现。

## 3. 最短静态数据流（`✓` 已存在；`×` 缺口）

```text
可能的 backend source authoring
  × 真实 identity + Connection current evidence + 独立 Consent current evidence：未定位到完整来源/服务接线
  ✓ 输入数组 -> B1 Connection evaluator；B3 Consent/live gate evaluator
  ✓ B4 场景 harness -> B1/B3；B2 synthetic evidence -> 派生投影 submit/readback
  × 真实 source authoring/reconciliation -> 当前权威 API/wire -> Flutter 受信输入

Flutter 恢复与消费
  ✓ F2/F3 本地会话缓存；F5/F6 synthetic 内存状态；F11 mock 或旧 v1 chat data source
  × 受信身份/双证据及各自 revision/currentness/freshness -> F1 caller checks
  ✓ F1 纯函数 -> liveReadCandidate/liveSendCandidate（仅给定 claims 的假设结果）
  × F1 + authoritative CV lifecycle + 数据权利 -> F8/F9/F10 私密 read/send 操作

现有旧路径（不能接为上述缺失边）
  ✓ B8 -> B5/B6；B7.send() -> B5.authorizeSend()；F11 非 mock -> 旧 v1 chat API
  × B3 双输入 live gate -> 旧 B5/B7/B8；× F1 -> F8/F9/F10
```

限定检索内，Laravel `app/` 对 B3 的类名引用只有 B3 自身和 B4；Flutter `lib/` 对 F1 的符号/文件名引用只有 F1 自身。该负面结论限于这两个目录的静态字符串搜索，不是全仓或运行时不存在证明。F12 mock socket 为 `Stream.empty()`；它证明 mock 不创建此处的 real socket 订阅，不证明非 mock 安全或实时撤销链已接通。

## 4. 最小后继切片与门

**当前不能安全做真实恢复集成。** 缺少可信当前身份和独立 Consent 来源，任何把 F1 candidate 接到 F8–F11 的工作都会把可伪造的 caller claim 变为私密权限。无需真实服务/数据可证明的最小隔离切片，只能是未来另行下达的、虚构输入的**来源适配负向合同/测试 harness**：对缺失身份、旧 aggregate、独立 Consent 不存在、revision 不可比、撤销/关闭晚于 active、purpose/audience 不符、send 前失效，一律保持候选不可用于 UI/API；不新增真实 grant、不读私密缓存、不接旧聊天 writer。它最多证明 fail-closed 映射形状，不能重复宣称 C2 的纯判定测试已完成真实来源接线。

进入真实集成前至少需要：后端明确并证明当前主体/双方身份和会话绑定；Product Connection 与独立 Messaging Consent 各自的 authoring/persistence/current 读取、owner/provenance、revision 比较与冲突协调；当前 CV lifecycle 来源；live-read/live-send 的具体受信调用边界和提交点；按类别决定 Conversation 索引/正文/草稿/未读的本地保存、失效遮蔽、删除/保留及离线历史权利。反例包括缓存 token/profile、`CN_ACTIVE` 的 synthetic provider、旧 `CV_ACTIVE`、旧 released Match、旧 `MC_ACTIVE`、存量 Conversation 行、传输到达顺序：这些均不得单独或组合授予当前读发。

身份、Consent writer、受信来源/数据模型、旧 API 切换及私密数据处理至少为 **LEVEL 2 独立 Work 审查**；涉及新隐私/安全政策、真实数据、生产 DB/不可逆迁移或发布则为 **LEVEL 3 Owner 或明确高风险门及逐项授权**。Owner/法律需要决定保存类别、保留/删除、离线历史及撤销后的可见性；后端需要给出权威来源和并发核验协议。本文件不替这些决策选默认值，也不发布下一任务。

## 5. 静态回执与停点

仅检查本地控制面、C1–C5、F1–F12、B1–B8 及上述目录内的限定字符串调用关系；对源码使用本地 Git blob 核对。`codebase-memory-mcp` 的 `D-EliteSync-v10` 索引报告 ready，但对确实存在的 B3 精确类名搜索返回 0，因此回退到指定 Flutter `lib/`、Laravel `app/` 的 `rg` 和定点文件读取；未据图谱阴性结果判定代码不存在。APP-INT-08 回执中的 13 项测试是前任务作者报告，本轮**未运行**。本轮未运行 Flutter/Dart/Gradle/Android、PHP/PHPUnit/Artisan、HTTP/API、DB、网络、远端或真实数据操作；未查看 app-private data。根目录无关 untracked 保留。唯一授权写入是本 `source-map.md`；待 Work LEVEL 2 独立 ACCEPT/REJECT，不自接受、不提交、不备份、不派发后继。

## 6. Work 独立审查（2026-09-23）

Verdict: **ACCEPT — STATIC SOURCE MAP; REAL RECOVERY AUTHORITY NOT ESTABLISHED**。Work 核对作者候选 blob `704d36c2fa4d0e6b8633ba815429c24be32e0e6b`，逐一复核表中 25 个来源路径的本地 Git blob，均匹配。限定搜索确认 Flutter 产品 `lib/` 中没有 F1 纯门的调用者，Laravel `app/` 中 B3 live gate evaluator 只有 B4 场景 harness 调用；B5 `ConversationCapabilityService` 的读/发条件仍依赖存量 Conversation 或 released `DatingMatch`，未体现 BA-05 的独立 `CN_ACTIVE` 与 `MC_ACTIVE` 双输入。上述结论是静态范围内的代码事实，不是服务运行审计或全仓不存在证明。

本验收保留来源表所列 UNKNOWN/NOT ESTABLISHED：真实身份绑定、Connection/Consent authoring 与当前证据、独立 lineage/revision/freshness 核验、authoritative CV lifecycle、私密数据保存/保留、实际读发接线。未运行产品测试、API、DB 或设备操作，不授权用 APP-INT-08 的 caller claims 解锁 UI 或发送。下一真实恢复任务须先处理 Owner 的本地保存/离线历史方向和独立权威来源；本任务没有发布后继实现授权。
