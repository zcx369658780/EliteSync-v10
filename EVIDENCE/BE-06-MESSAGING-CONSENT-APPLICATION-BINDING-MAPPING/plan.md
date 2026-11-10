# BE-06｜MC application binding 最小后继映射候选

**状态：docs-only 作者候选，待 Work LEVEL 2 独立审查。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；`TASK_CURRENT.md` 向本会话派发 BE-06。BE-05 的 LEVEL 2 ACCEPT 仅覆盖 synthetic/dev-test repository-only、非权威 MC 关联记录。本文不下达代码任务，也不建立真实 MC writer、来源签发、账号、生产 DB 或 live permission。

## 1. 下一段最小 application 关联切片

建议独立后继任务只新增 `services/backend-laravel/app/Domain/MessagingConsentPersistenceApplicationAdapter.php` 与 `services/backend-laravel/tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php`，必要时精确列出同一已有 `PersistenceBoundaryApplicationInterfaceIntegrationContract.php` 的变更理由后重新审查；优先不改它，也不改 evaluator/repository/SQLite adapter。接口可定为 `correlateCurrentSynthetic(array $request): array` 与 `invalidateCurrentSynthetic(array $request): array`，不提供 grant 或消息写入方法。精确路径与预算须由 Work 在新任务单授权，本段只是建议。

`correlateCurrentSynthetic` 的输入固定为 synthetic consent context（consent identity、当前 Connection identity、恰两名参与者、requester、recipient、单一 `CONVERSATION_LIVE_READ` 或 `CONVERSATION_LIVE_SEND` purpose）、一份调用方携带的 CN state evidence 和**一份**同 context/purpose 的 MC state evidence，及独立的 immutable MC evidence identity。校验各来源自己的十一键 bindings、五键 source revision、condition/currentness/freshness、participant/context/purpose/owner/actor；严格区分顶层 `MC_DERIVATION` 作者和来源 owner。输入不能是 MC repository projection、缓存或 `CN_ACTIVE` 字符串代用品；现有 evaluator 没有公开 `evaluateCurrent`。多份相冲突/不可比来源不由 adapter 合成一个赢家。

对已给定来源作最小脱敏映射：`MC_CURRENT_STATE` 的 `current_state` 精确等于 MC state evidence，`classification` 只作来源报告；CN 缺失或任何来源条件未知/不新鲜时固定为非权限 `UNKNOWN`，不得升为 active grant。稳定 intent identity 取不可变 MC evidence identity 与 kind，logical record identity 再由 family/kind/intent 派生；semantic input 包含绑定、来源摘要与 typed payload。顶层本地 revision 只映射 MC 来源 lineage/value，不混入 CN revision。先用接受的 repository 合同校验记录，后经应用持久化边界 `submitAuthoritativeMutation` 提交；该方法名不授予 MC authority，必须把返回值当作 correlation disposition。只对允许的存储结果按精确 family、identity、intent、lineage、context、participants、purpose、typed payload 与未失效标记读回；`EXACT_DUPLICATE` 仅同输入幂等，`INCOMPARABLE_COEXISTS` 不产生 current selection。`CHANGED_INPUT_REUSE_REJECTED`、同 revision 冲突、缺失、`UNKNOWN`、`STALE`、`INCOMPARABLE`、`INVALIDATED`、读回不一致与 transport timeout 均 fail closed，返回 `correlation_usable=false`、`live_read_allowed=false`、`live_send_allowed=false` 和受限 reason。`RESOLVED` 或精确读回也只证明关联一致，不是授权。

失效路径只接受针对已选依赖 identity 的 correction/revocation/supersession，调用 repository/application 的精确 invalidation 并核对读回标记；不从 generic `REVOCATION` 推断 MC 来源进入 `MC_REVOKED`，不重开旧 consent identity。失败回退为拒绝本新增 adapter 候选并保留 BE-05 repository family；不接入使用点。

## 2. evaluator 与存储的顺序及不能跨越的门

现有公开入口是 `evaluateTransition(consent, connection, connectionEvidence, consentStateEvidence, transitionEvidence)`、`evaluateLiveGates(connection, connectionEvidence, readConsent, readConsentEvidence, sendConsent, sendConsentEvidence)`、`invalidateLiveGate(gateResult, dependencyIdentity, relation)`。evaluator 输入是各自的**当次来源携带 evidence 列表**；repository 的 `connection_dependency`/`consent_state_dependency` 是脱敏投影，不可反向冒充完整原始来源。现有 Product Connection adapter 可参考 request 校验、构造稳定记录、提交与精确读回的结构，但它的 Product Connection 投影和 `CN_ACTIVE` classification 不能替代本次 CN 来源证明。

转移的安全顺序是：先验证同一 consent/Connection/participants/purpose 的 CN、MC 当前态和 transition 来源集合；再调用 `evaluateTransition(...)`，得到仅本次 synthetic evaluator 的分类、原因和依赖向量；若需关联存储，当前 BE-05 repository **只接受 `MC_TRANSITION=UNKNOWN`**。不得把 evaluator 的 `ADMISSIBLE/REJECTED` 直接塞进该 typed payload，也不得把存储成功解释为转移通过。若未来确需持久化这些分类，须另立 LEVEL 2 合同，明确 evaluator provenance（方法/版本、输入 evidence identities 与各自 revision、canonical result fingerprint、失效关系、readback 验证），并同步修订 repository shape 与正负测试；在该门前记 `NOT_READY`。最小当前态 adapter 不需要改真实 writer。

live gate 是另一个受保护使用点任务：每次 live-read 前分别取得当前 CN 和 read-purpose MC 来源；每次提交 live-send 前**重新取得并核验**当前 CN 和 send-purpose MC 来源。read/send consent identity、purpose 与结果各自独立，用公开 `evaluateLiveGates(...)` 六参数求值，只让本次同目的 gate 结果控制本次动作。缺一输入、任何非 `CN_ACTIVE`/`MC_ACTIVE`、跨 context/participant/audience/purpose、旧 revision、撤销、不可比或失效均不读/不发。`invalidateLiveGate(...)` 仅撤销命中精确 dependency identity 的已派生 gate，不能签发新来源，也不代替下一次使用点重新求值。离线/历史 Conversation、消息正文、真实身份/token、endpoint、migration、Flutter 与账号回填不属于这个最小切片。

现有 `PersistenceBoundaryApplicationInterfaceIntegrationContract::revalidateProtectedAction(...)` 是单一来源与单一投影的描述性核对；MC 顶层 projection owner 是 `MC_DERIVATION`，而来源 MC owner 独立，不能把这个单输入方法或它的 `GRANTED` 字段直接当作 CN+MC 双输入 live gate。`retrieveCurrentProjection(...)` 的 binding classification 与 `resolveCurrent` 只供精确关联读回，也不授予读发。

## 3. 后继代码任务的验证与审查证据

建议新 adapter Unit test 同时用内存/SQLite：精确单份 CN+MC 正例与 exact duplicate；CN/MC 各自缺失、`UNKNOWN/UNAVAILABLE/STALE/SUPERSEDED`、currentness/freshness false/null；跨 Connection、参与者、consent identity、purpose、audience 和来源 owner；同 identity 改输入、同 revision 冲突、不同 lineage 不可比、旧 active 晚到、旧终态重开；失效前后读回、transport timeout 与存储拒绝；read/send 互不借用；所有返回非权限字段始终 false。再跑被触及应用边界与 BE-05 repository family 的定向回归。若另发转移/使用点任务，单列 `evaluateTransition` 的允许边/角色负例，以及 live-read 与 send-time 独立重取的双输入测试；不能靠当前态 adapter 的测试替代。

Work LEVEL 2 审查需看到精确 diff、输入到 repository 记录的字段映射、CN/MC 来源身份及 revision 分离、每个失败状态的返回矩阵、内存/SQLite 同形回执、测试/未运行与文件哈希；高风险真实 writer、auth/session、生产 DB 和保护性使用点仍须各自授权。若完整来源证据不能从新 adapter 的 synthetic request 精确绑定，或应用接口无法保证无权限读回，则停止该切片为 `NOT_READY`，不补造来源。

## 4. 本轮静态回执

固定来源静态核对 **2/2 轮**：先核对本地 cwd/ref/HEAD/dirty 工作区、`TASK_CURRENT.md`、BE-06 `task.md`、BE-05 review；随后只读任务列明的治理/BE-03/BE-05、BA-05 acceptance、五个 Domain 文件及同名 Unit test 的存在与方法/相关代码片段。五个同名 Unit test 均存在；没有缺失路径。相对 BE-05 的差异仅新增本 `plan.md`，无源码或测试修改。

关键 SHA-256：`TASK_CURRENT.md` `05A08FDD1C7BC4D4A8E62DFEE748D1D17ED9205C5A8E7878CDF6F3FC85080EA7`；BE-03 `plan.md` `ADBC9AEAED2F9F319E2F5983A2A0B43A3C7DC98E0552D7E2644468FC31F96128`；BE-05 `work-review.md` `D42795CD32009157C6DA0D31EC4C2FE13C2AAF4023B423F1285DA41DA4D12EC0`；BA-05 acceptance `1FC25267CFD9006FCF5FC005B960CE70F7FBFDE77A981CECB856F544EA34E859`；MC evaluator `BE2D2B4AC6B1100159368D7ACCAE89542E75466F74B2D254D4001204574168D3`；内存 repository `3B7A808FEE6D4DAE22424F3AA9D74E2888B9CEBE06F12F68AFC5AA19C24DB58E`；SQLite adapter `39CDD2B47FB5D9F6F0C3466A73230C218E0007E27B6560964C432E67191906BD`；应用边界 `ABA6B0DE25403AF2B44D2E893233F55358519D1AA3D34A112761BB907C22659D`；Product Connection adapter `BA8AA1B49E5BD978383F1ABD89410FCBD8F784A833A1EFDF94404A39C8CE989E`。

`NOT_RUN`：PHPUnit、PHP lint、Composer、Artisan、Docker、构建、Web/模拟器、DB、SSH、备份/解密/恢复、UAC、Git commit/pull/push。未访问旧 `D:\EliteSync`、GitHub、`.env`、真实账号、私钥、业务行或日志；无关 modified/untracked 均保留。BE-04/05 与 AUTH-152/153 的旧预算不重置。作者停在 Work LEVEL 2 独立审查，不自接受、不派发后继代码。
