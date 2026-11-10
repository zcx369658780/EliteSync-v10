# BE-09｜synthetic Messaging 双输入 live gate 应用合同候选

**状态：docs-only 作者候选，待 Work LEVEL 2 独立审查。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；本轮只新增本 `plan.md`。BE-05 repository family 与 BE-08 当前态 adapter 的接受均限 synthetic/dev-test 非权限关联，不代表真实 MC 来源或 live-read/live-send 使用点已建立。

## 1. 来源、绑定与信任等级

| 输入 | 每次保护性使用须绑定的事实 | 当前来源/信任等级 |
| --- | --- | --- |
| Product Connection | 当次 Connection aggregate identity、恰两名参与者、目标 audience/purpose、来源 owner/scope、状态 `CN_ACTIVE`、独立 lineage/revision、condition=`PRESENT`、currentness/freshness=true，且未被 correction/supersession/revocation 失效 | 未来 Product Connection 权威来源应签发；当前只见 synthetic evaluator fixture 与非权威派生记录。真实来源签发者、认证/查询接口、快照一致性 `NOT_READY` |
| Messaging Consent（read） | read-purpose 的独立 consent identity、requester/recipient 方向、同一当前 Connection/参与者/audience，`CONVERSATION_LIVE_READ`、来源 owner/scope、`MC_ACTIVE`、其自身 lineage/revision/condition/currentness/freshness、未失效 | 未来独立 MC writer/来源应签发；当前 BE-08 adapter 只相关联调用方携带的 synthetic 值，不验真实签发者。真实来源 `NOT_READY` |
| Messaging Consent（send） | send-purpose 的**另一个独立** consent identity/来源集合，`CONVERSATION_LIVE_SEND`，其余同上；提交点重新取最新 CN 与此用途 MC | 同样 `NOT_READY`；read-purpose grant 不可借给 send |
| 使用点上下文/失效 | 精确 Connection/consent identity、双方参与者、audience、请求用途、动作方向；失效输入须为命中 gate dependency identity 的 correction/revocation/supersession | synthetic 请求只提供比较目标，不证明身份；失效只能撤回命中的已派生 gate，不能生成新来源或新许可 |

Product Connection 与 MC revision 不合成全局序号。调用方自报 owner/audience/revision、BE-08 的 `correlation_usable=true`、repository `RESOLVED`、旧 Conversation row、route、cache、通知、transport ACK 或历史 `MC_ACTIVE` 都只可帮助定位候选查询，不能充当当次来源。当前源码没有真实 auth/session、MC writer、受信任来源获取接口；因此**真实读发使用点 `NOT_READY`**。BA-05/IP-05 的接受是产品/实现职责设计，不直接授权真实数据处理。

## 2. 当次调用顺序与结果边界

公开方法 `MessagingConsentConversationLiveGateEvaluator::evaluateLiveGates(connection, connectionEvidence, readConsent, readConsentEvidence, sendConsent, sendConsentEvidence)` 返回两个独立描述性布尔值及 dependency/reasons。`evaluateTransition(...)` 与 `invalidateLiveGate(...)` 是不同职责；repository 仍仅接受 `MC_TRANSITION=UNKNOWN`，不可把 evaluator 的 `ADMISSIBLE/REJECTED` 直接持久化，更不能以存储成功取得读发许可。若要持久化非 UNKNOWN 转移，先另立 evaluator provenance 与输入 identities/revisions/result fingerprint/失效关系合同，修订 repository 并独立审查；不与此 live gate 切片合包。

**live-read：**调用入口只接收非私密的目标 context 和 operation kind；在每次拟构造私密 list/detail/message/preview 之前，重新向各自权威来源取得当前 CN 与 read-purpose MC evidence（synthetic 探针则从隔离的测试快照提供者当次取得）。核恰同 Connection、参与者、audience、purpose、consent identity、各自 owner/lineage/revision/currentness/freshness/失效条件后调用六参数 evaluator；send-purpose 输入也须按 evaluator 合同提供，但**只能**检查 `live_read_allowed/valid_for_live_read` 作为本次 read 分支的门。两者有任一不一致或未知，不调用私密内容构造动作。通过后才允许本次动作，结果不可缓存为下一次 read 或转成 send grant。历史只读在 revoke/pause/close 后默认不可用，除非另有独立 history authority。

**live-send：**任何早期列表、编辑或先前 gate 结果都不授权提交。提交入口只带非私密 context 与 synthetic intent identity；在虚构 commit 边界**重新**取得当前 CN 与 send-purpose MC evidence，运行同一六参数 evaluator，仅检查 `live_send_allowed/valid_for_live_send`，成功后才创建 synthetic draft/send sentinel 并记录一次虚构动作。若前后来源变化（例如较新 `MC_REVOKED`、`CN_CLOSED`、失效、旧 revision）则拒绝；不能使用此前 read snapshot 或旧 send 结果。真实消息 writer 还须在自己的原子提交边界复核当前 revision/domain 前提；当前没有该 writer/CAS，因此这里绝不声称能消除 gate 与真实写入之间的竞态或已发送消息。timeout/ambiguous transport 只触发来源再核与同 intent reconciliation，不推断已发或未发。

失效后 `invalidateLiveGate(gateResult, dependencyIdentity, relation)` 只对精确命中的 connection/read/send dependency 撤销对应布尔值；未命中不改结果，但下次使用点仍须重新取来源。对任何缺失、UNKNOWN/UNAVAILABLE/STALE/SUPERSEDED/INCOMPARABLE、非 `CN_ACTIVE`/`MC_ACTIVE`、跨 Connection/参与者/audience/purpose、旧 consent identity 重开、来源纠正或撤销，一律不调用受保护动作。展示性投影可以显示受限状态，不构成允许构造私密内容的依据。

## 3. 下一段最小切片判定

**真实应用代码 `NOT_READY`：**固定源码中有 evaluator 和非权限当前态关联 adapter，但没有受信任、当次可重取的 CN/MC 来源端口，也没有在读前/提交点受控且可证明调用顺序的保护性动作接口。直接再包一层 evaluator 只重复求值，不能证明内容未提前构造或 send 在提交前重取；接入现有消息存储/HTTP/Flutter 则越过本任务和 auth/writer 门。

可供 Work **另发任务审查**的最小无真实 I/O 探针为新增 `services/backend-laravel/app/Domain/MessagingConsentSyntheticLiveGateUsePoint.php` 与 `services/backend-laravel/tests/Unit/MessagingConsentSyntheticLiveGateUsePointTest.php`（路径只是候选，本文不授权写入）。单一候选接口可为 `attemptReadSynthetic(context, evidenceProvider, actionProbe)` / `attemptSendSynthetic(context, evidenceProvider, actionProbe)`：

- `context` 只含 Connection/两个 consent identities、恰两位参与者、requester/recipient、明确 protected audience、operation kind 与 synthetic intent；**不含消息正文或预先构造的私密 payload**。
- `evidenceProvider` 仅测试用隔离内存双输入快照端口，`acquireForRead`/`acquireForSendAtCommit` 每调用一次返回六参数的当次 synthetic 来源集合、来源身份/各自 revision 与失效标记；不从 BE-08 projection 反向构造。端口调用次数与顺序可观测。它不是可信来源签发者。
- `actionProbe` 是无 I/O 的测试计数器，只能在对应 gate true 后调用 `constructPrivateSentinel` 或 `commitSendSentinel`；不得访问消息库、网络或文件。探针回执只含 `GATE_DENIED/PROBE_PERFORMED/UNKNOWN`、read/send 分别的调用次数、受限 reason 和当次 dependency identities；无正文、真实账户、权限 token、`message_sent=true` 或持久化成功。

若 Work 认为上述测试专用端口仍不能保证“私密内容只能在 gate 后构造”和“提交点取新 snapshot”，则先单独接受端口/时点合同，代码仍 `NOT_READY`。即使探针测试通过，也只证明**虚构调用顺序**；真实来源签发、auth/session、消息 writer 的原子提交/回滚、历史/数据权利、endpoint 和生产 DB 仍须各自任务。失败回退为不接入探针，保留 BE-08 已接受的非权限关联。

建议后继若获派发，仅对两份新 PHP 各一次 `php -l`，对新 Unit test、现有 `MessagingConsentConversationLiveGateEvaluatorTest.php` 与 `MessagingConsentPersistenceApplicationAdapterTest.php` 各首跑一次；失败后仅失败文件一次修复复跑，预算应由新任务明确。Work LEVEL 2 审查需看到固定接口、无真实 I/O 证明、动作调用计数与时间顺序、负向矩阵、源码/test hashes、实际/未运行回执；不得将 synthetic PASS 写成 production backend 或真实用户可用。

## 4. 有限正负矩阵（后继建议，当前均未运行）

正例仅为同 context/participants/audience 的独立当前 `CN_ACTIVE` + read-purpose `MC_ACTIVE` 使 read sentinel **一次**、send sentinel **零次**；另一次独立取得同样当前 CN + send-purpose `MC_ACTIVE` 才使 send sentinel **一次**。负例分别覆盖 CN/MC 缺失及各自非 active、read/send purpose 交换、跨 Connection/参与者/audience、较新非 active revision 压过旧 active、等 revision 冲突/不可比、撤销后旧来源重入、精确 dependency 失效、send 点击到 commit 之间状态变更、私密 sentinel 试图提前构造、timeout/ambiguous transport；每例动作计数为 0，来源/投影不写入。新 Connection aggregate 不继承旧 MC；旧终态 consent identity 不能重开。所有结果限定 synthetic，无真实正文、账户或网络。

## 5. 静态回执

固定来源静态核对 **2/2 轮**：核对 cwd/ref/HEAD/dirty、当前 `TASK_CURRENT.md` 和 BE-09 `task.md`；只读列明的 BA-05/IP-05/Owner 决定文件、BE-05/06/08 审查/方案，以及 evaluator、BE-08 adapter、repository 与两个同名 Unit test 的方法和相关片段。BE-05 与 BE-08 精确 `plan.md` 路径不存在，已记录为缺口；其接受状态仅据各自 `work-review.md`，未搜索替代。任务所称“当前交付计划”未给精确路径，本轮没有猜测或搜索定位。本任务唯一写入为新增本 `plan.md`，其他修改/未跟踪内容保留。

输入 SHA-256：`TASK_CURRENT.md` `75B66D26CCD620513F33E5861008E269A09AD880224518BABC973F36B7EAE73A`；BE-09 `task.md` `CFF6612C0320C9689BA087BD7268020B964B127A2ADBBCFB87B4E107AD3F6872`；BA-05 design/acceptance `F994508A671B3818F21B73436E3FC013A743B51CBA2148C636F5D005991BBACA` / `1FC25267CFD9006FCF5FC005B960CE70F7FBFDE77A981CECB856F544EA34E859`；IP-05 plan/acceptance `9AB0A729493EDDB918FD067548D2983A9799211E8F3C0A34AD8C650027CD19AE` / `0954E38E8001789B835450713F97B62D2A61C279B0CAE54325522A7F44321452`；Owner data-rights acceptance `58F478C4E1ACF4838ED8C7CE57E2DBAA11F80AE6FEB379A7B94A3D94CC3CD872`；BE-06 `plan.md` `94040EADB213EF304364CE91C1E160329AF9094EBE26B159FCC7CAD074AC1213`；BE-08 `work-review.md` `487BE461952FA8C9A61E757DCC6B609D33432D82F679A32E35F79F9609AF919B`；evaluator `BE2D2B4AC6B1100159368D7ACCAE89542E75466F74B2D254D4001204574168D3`；BE-08 adapter `573E1147BBEBF92E574F5C61667A003314C6C97EAA1B4E515F288A8F9922C506`；repository `3B7A808FEE6D4DAE22424F3AA9D74E2888B9CEBE06F12F68AFC5AA19C24DB58E`。

`NOT_RUN`：PHPUnit/lint、Composer、Artisan、容器、构建、浏览器、DB、备份/密钥、SSH/云/生产接口、Git commit/pull/push。未读取 `.env`、业务行、真实密码哈希或旧 `D:\EliteSync`。BE-07/08 与 AUTH-152～155 旧预算不重置。作者现在停在 Work LEVEL 2 独立审查，不自接受、不启动下一代码任务。
