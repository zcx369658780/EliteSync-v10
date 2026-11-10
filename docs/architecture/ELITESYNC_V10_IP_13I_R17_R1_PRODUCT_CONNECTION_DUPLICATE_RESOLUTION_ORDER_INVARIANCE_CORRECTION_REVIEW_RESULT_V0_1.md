# EliteSync v10｜IP-13I-R17-R1 Product Connection Duplicate-Resolution Order-Invariance Correction Review Result｜v0.1

状态：`REVIEW COMPLETE — MAXIMAL COMPARABLE REVISION SCOPE FIXED — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

日期：2026-09-21（Asia/Singapore）。
仓库：`zcx369658780/EliteSync-v10`。

## 1. 发布 authority 与范围

- task-publication authority：`2e85797c0d2add024a21ab524ff502421e45bc27`；
- authority sole parent：`fb919b821514bf4c8137922b8404baace2760414`；
- authority tree：`07b83922f7ea9da7d47629c2ffc1832ec32cecfd`；
- task blob：`e44162780c1d7b411897cc743beaa1b6cffbdfb5`；
- review branch：`review/next-ip-13i-r17-r1-product-connection-duplicate-resolution-order-invariance-correction-v0-1`；
- tracked scope：只新增本结果文档；
- candidate commit / sole parent / tree：由 immutable Git publication receipt 固定；candidate 必须以 task-publication authority 为 sole parent，且只能新增本结果路径。

本任务是 document-only domain-policy correction review。没有修改 evaluator、Common Authority、tests、persistence、application、route、controller、HTTP、roadmap、context、AGENTS 或任何下游文档。

## 2. 固定证据 ledger

已按任务精确 ref/path 读取并核验：

- `AGENTS.md`：`c9a8e192f7647a1613a195655fe9c22c56502ddb`；
- R17-R1 task：`e44162780c1d7b411897cc743beaa1b6cffbdfb5`；
- current context：`d75de90b3c0dafe6c5241f135936d0ae653c7e30`；
- current roadmap：`6f49159f1cce7a28362284191c05adbc08e768aa`；
- current evidence index：`5b26a4e396dd8f64c18e25b16ef577df124a6725`；
- R17 independent rejection：`415ee64eb70894eed21eee97e58762307d6e408f`；
- accepted R15-R1 result：`fb064b7e290916ba7aa42d53990c9c54d289f5ba`；
- R15-R1 acceptance：`7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`；
- accepted R16-R1 result：`f0da912cb3dcb1525fa36053168310f187cf58cb`；
- R16-R1 acceptance：`96110d9484897012c7946b42a2256951ec8a60fc`；
- retained R16 result only at rejected ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`：`aee15cf45c75c5a8f1733f5604803fc3ee766b4b`；
- Product Connection evaluator：`35a889ee5460e5c374a5a99bd93bebae49718c5b`；
- Common Authority：`e98e7db731d41269a7b89e01db12e1a81364751d`；
- old R17 task only at frozen ref `b0196202c78f688723600ac9919cf96463908375`：`68d18d4100ba24b493fd2b5ee9388f564aca9100`；
- rejected R17 result only at candidate `6af50b3cdf82ac8bc285bd160f773b48b29f1328`：`14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`。

没有读取任务清单外来源。rejected R16/R17 只按任务限定用途消费，没有整体升级为 accepted contract。

## 3. 顶层决定

选择 Option A：

`MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`

在同一 evidence identity、同一可比较 source-local revision namespace 内，duplicate semantic-conflict 的当前评价范围只包含 maximal revision candidates。严格较旧的可比较候选仍保留在输入证据集合中，但对当前 duplicate semantic-conflict classification 属于 dominated history。

选择 A 的控制理由：

1. accepted R15-R1 明确固定：`Comparable higher source-local revision selects the newer candidate`；
2. equal revision 且 semantic signature 不同仍是现有 bounded conflict；
3. namespace 不同仍是 `INCOMPARABLE`，identity 不同仍是现有 identity conflict；
4. Option A 使上述三条同时成立并对所有 permutation 给出同一结果；
5. Option B 会让已被更高可比较 revision 支配的历史 equal-revision conflict 永久毒化当前解析，背离已接受的 higher-revision selection；
6. 固定来源足以作此窄化 domain-policy 决定，因此不选择 Option C。

这不是“revision 在所有领域上权威”。它只固定 Product Connection duplicate resolution 的 conflict evaluation scope。

## 4. Common Authority 解释

Common Authority 的 source revision 仍恰好为：

`[authority_owner, authority_scope, lineage, aggregate_context, value]`。

前四个字段组成 source-local namespace。只有四字段全部相等时，`value` 才给出 `OLDER | EQUAL | NEWER`。任一 namespace 字段不同即 `INCOMPARABLE`。

Common Authority 只提供 ordering/comparability relation；本结果在 Product Connection domain 内增加的唯一 policy 是：当前 duplicate semantic conflict 只在 maximal comparable revision scope 内评价。没有修改 Common Authority tuple、comparison method 或 evidence contract。

因此：

- 没有 global revision；
- 没有跨 owner/scope/lineage/aggregate-context 比较；
- 没有 LWW、last-received-wins、timestamp 或 arrival-order authority；
- 较旧证据没有被删除、改写、失效或从原输入消失；
- maximal scope 只决定当前 resolver 输出，不建立 Connection source authority、state mutation、permission 或 production truth；
- source condition、currentness、freshness 与 binding usability 仍由既有规则独立评价。

## 5. 确定性算法契约

本算法在 strict structural gate 之后运行。gate 仍须先验证每个候选；六个 structural diagnostics 不变。空集合仍由现有 state/transition caller 返回各自 missing-evidence reason。

对非空、结构合法的 state 或 transition evidence multiset：

1. **Identity gate**：收集全部 evidence identity。若不恰好一个 distinct identity，返回现有 identity conflict reason；不比较 revision，不选候选。
2. **Namespace gate**：从每个完整 source revision 提取 `[authority_owner, authority_scope, lineage, aggregate_context]`。若不恰好一个 distinct namespace，返回现有 incomparable reason；不选候选。
3. **Maximal revision**：对该单一 namespace 的非负整数 `value` 求数学最大值 `M`。该运算只依赖 multiset。
4. **Maximal scope**：保留对解析决策的视图 `value === M`；严格较旧候选仍在原输入中，只是不参与当前 equal-revision semantic-conflict 判断。
5. **Signature evaluation**：使用现有 state 或 transition semantic signature，对 maximal candidates 做严格语义比较。
6. **Identical maximal signatures**：若 maximal signatures 全部严格相同，返回该共同语义的 maximal evidence。由于 strict gate 固定 exact key set，且现有 signature 覆盖对应 evidence 的全部语义字段，任何 maximal representative 都产生相同 evaluator dependency/result；实现不得让 representative index 泄漏到输出。
7. **Conflicting maximal signatures**：若 maximal scope 内出现多个不同 signature，返回现有 equal-revision conflict reason，不保留该类型 dependency。

固定 reason 参数：

| Evidence | Identity reason | Incomparable reason | Equal-max conflict reason |
|---|---|---|---|
| state | `CONFLICTING_STATE_EVIDENCE_IDENTITY` | `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE` | `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE` |
| transition | `CONFLICTING_TRANSITION_IDENTITY` | `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE` | `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE` |

优先级固定为 identity conflict → incomparable namespace → maximal-revision signature evaluation。它只表达现有 resolver 已有检查类别的集合级、order-independent 版本，不把任何语义冲突改为 structural input error。

算法是 evidence multiset 与 accepted source-local comparison 的纯函数。排序可以作为未来实现的机械手段，但必须得到上述集合定义的结果；sort stability、原索引或 tie arrival order 不得影响输出。

## 6. State duplicate policy

State 使用现有 `stateSemanticSignature`，包括：

- state-evidence identity；
- Connection identity；
- participants；
- state；
- required bindings；
- 完整 source evidence。

若 maximal scope 唯一或 signatures 全同，选择共同 maximal state evidence，再由现有 `stateEvidenceIsUsable()` 决定：

- fully usable → 现有已知 `CN_*` classification、空 reasons、保留 current dependency；
- 不 fully usable → `UNKNOWN / CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`、保留 current dependency。

若 maximal signatures 冲突：

- `UNKNOWN / CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`；
- current dependency 为 null；
- current state 为 null；
- top-level currentness/freshness 为 `null/null`；
- downstream-active 与 valid-for-protected-use 为 false。

Identity conflict 或 incomparable namespace 同样使用各自现有 state reason，且不保留 current dependency。

## 7. Transition duplicate policy

Transition 只有在 current-state resolution 已产生已知 current state 后才进入 transition duplicate resolution。若 current result 为 `UNKNOWN`，继续沿用现有提前返回与 propagated-current reason；本结果不强行解析 transition evidence。

Transition 使用现有 `transitionSemanticSignature`，包括：

- transition identity；
- Connection identity；
- participants；
- from/to state；
- 完整 `expected_state_revision`；
- required bindings；
- 完整 source evidence。

若 maximal scope 唯一或 signatures 全同，选择共同 maximal transition evidence，随后依次沿用现有 usability、current-context、target-state、terminal 与 allowed-transition 规则。结果可以是既有 `TRANSITION_NOT_CURRENT_FRESH_BOUND`、`TRANSITION_CURRENT_CONTEXT_MISMATCH`、`ADMISSIBLE` 或 policy `REJECTED`；不得由 duplicate policy预判这些后续结果。

若 maximal signatures 冲突：

- `UNKNOWN / CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`；
- 已解析且 fully usable 的 current dependency 保留；
- transition dependency 为 null；
- current state 保留；
- proposed state 为 null；
- top-level currentness/freshness 按 incomplete-vector rule 为 `null/null`；
- valid-for-protected-use 为 false；downstream-active 只描述 retained current state。

Identity conflict 或 incomparable namespace同样使用各自现有 transition reason，不保留 transition dependency。

## 8. 全排列证明矩阵

下表中的“结果”对 multiset 的每一种输入 permutation 相同。

| # | Multiset | State / transition order-independent result |
|---:|---|---|
| 1 | 单一候选 | 唯一 identity/namespace/maximal candidate；选择该候选 |
| 2 | equal revision 且 exact semantic duplicate | maximal signatures 全同；选择共同语义，重复数量与顺序不影响输出 |
| 3 | equal revision、semantic conflict、无更高候选 | maximal scope 内冲突；返回对应现有 equal-revision conflict reason，无该类型 dependency |
| 4 | revision N 有两个冲突候选，N+1 有一个候选 | maximal scope 只有 N+1；选择 N+1。R17-F1 两种历史排列收敛为同一结果 |
| 5 | #4 的 N+1 分别匹配两个 lower semantic variant | 两个独立 multiset 均各自选择唯一 N+1；lower conflict 不毒化当前解析，N+1 的实际语义决定后续既有结果 |
| 6 | maximal revision 上两个以上 identical signatures | 选择共同 maximal 语义；不得输出 representative index/order |
| 7 | maximal revision 上两个以上 conflicting signatures | 返回对应现有 equal-revision conflict reason，无该类型 dependency |
| 8 | 长度大于三的 comparable older/newer chain | 求唯一数学最大值；只在最大值组比较 signatures；链顺序不影响结果 |
| 9 | 至少两个 source-local namespace | identity 相同时返回对应现有 incomparable reason；不选择候选 |
| 10 | 至少两个 evidence identities | 返回对应现有 identity conflict reason；该优先级与 candidate order 无关 |
| 11 | transition 只在 `expected_state_revision` 上不同 | 若差异发生在 maximal tie，signature conflict；若仅较旧候选不同而 maximal 唯一/同签名，选择 maximal |
| 12 | transition 的 from/to 或 required/source bindings 不同 | 若差异发生在 maximal tie，signature conflict；若只存在于 dominated older revisions，不改变 maximal 结果 |

证明要点：identity set、namespace set、数学最大值和 maximal signature set 都是 multiset function；任何 permutation 保持它们不变，因此返回的 selected semantic evidence 或 bounded reason 不变。

## 9. Reason vocabulary disposition

现有 reason vocabulary 完全足够；不新增 reason。

保持精确六个 pre-materialization structural diagnostics、八个 persisted current-state reasons、十九个 persisted transition reasons。Option A 只固定三个已有 duplicate outcome 类别的 precedence/scope：identity、incomparable、equal-max conflict。

合法的 cross-Connection、participant mismatch、identity conflict、incomparable revision、equal-max conflict 与 transition context mismatch 仍是 evaluator domain semantics，不转成输入错误。

## 10. R15-R1 / R16-R1 compatibility

### 10.1 R15-R1

- structural gate 与六 diagnostics 不变；
- distinct identity、incomparable namespace、equal-max signature conflict 继续使用现有 persisted `UNKNOWN` reasons；
- “comparable higher source-local revision selects the newer candidate”获得集合级精确定义；
- state 与 transition 使用各自既有 signature/reason literals；
- deterministic correlation 与 arrival-order prohibition得到满足。

### 10.2 R16-R1

Option A 改变 resolver 在 R17-F1 multiset 上选择哪一个既有合法 evaluator outcome，不改变任何持久化矩阵。

- state resolution failure reason：current dependency null，`UNKNOWN`、current state null、top-level currentness/freshness `null/null`；
- selected unusable state：保留 dependency，并进入既有 `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`；
- selected usable state：保留 fully usable dependency，并进入既有 known-state matrix；
- transition resolution failure reason：保留已解析 current dependency，transition dependency null，proposed state null，按 incomplete-vector aggregation；
- selected transition：依既有 usability/context/policy 进入 `UNKNOWN / ADMISSIBLE / REJECTED` matrix；
- exact five-field expected-state revision binding不变；
- protected-binding/currentness/freshness 仍由 selected maximal evidence 提供，不从 lower candidates 合成；
- invalidation 只作用于已保留 dependency，且保留 pre-invalidation dependency/state/aggregate；
- current-state terminality、no-reopen、generic-overlay separation 不变。

不为适配 resolver 重写 payload keys、dependency presence、aggregation、invalidation 或 persistence eligibility。

## 11. R17 disposition 与后继门

旧 R17 candidate `6af50b3cdf82ac8bc285bd160f773b48b29f1328` 继续保持 REJECTED。本结果不接受、不修改、不合入旧 R17，也不把其 sound fragments升级为完整 mapping contract。

`ORDER-INVARIANCE POLICY FIXED — EVALUATOR REPAIR REQUIRED BEFORE MAPPING RE-REVIEW`

只有本候选经 fresh independent ACCEPT 后，才可另行发布以下精确 successor family：

`IP-13I-R17-R2 PRODUCT CONNECTION DUPLICATE-RESOLUTION ORDER-INVARIANCE EVALUATOR REPAIR + TARGETED TEST TASK`

未来 R17-R2 必须仅修改精确 evaluator 与明确列出的 existing/new targeted tests，覆盖本结果的 state/transition permutation matrix，保留六 structural diagnostics 与 8/19 reasons，并只运行其任务另行授权的命令及 attempt budget。不得修改 persistence/application/HTTP。

只有 R17-R2 implementation 获得独立接受后，才可新写 fresh Product Connection domain-to-application mapping review。该 mapping review 必须消费完整 R16 retained/corrected source closure 与 repaired evaluator blob。

本分支不创建 R17-R2，不创建 R18。

## 12. 保留非权威与下游阻塞

继续保持：

- `NEXT_DOMAIN = PRODUCT_CONNECTION`；
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`；
- `Match != Connection != Conversation != Relationship`；
- Binding Model A；
- `GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`；
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`；
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`；
- 无 Connection source mutation/creation/activation authority；
- 无 Messaging consent、Conversation、Relationship、Home action、Notification delivery authority；
- 无 auth/session/token、global revision、LWW、arrival-order、timestamp、production、deployment 或 real/private-data authority。

Messaging/Conversation 继续受阻；Product Connection persistence/application/HTTP 未授权。

## 13. 执行回执

- 恰好创建一份 R17-R1 result document；
- 未修改 evaluator、Common Authority、tests、persistence、application、route、controller、HTTP 或其他既有文件；
- 未运行 PHP、PHPUnit、Composer、Artisan、server/HTTP、database、Flutter/Dart/Gradle/Java/Android、dependency resolution/download、migration/generator、provider/network product、production 或 real/private-data 操作；
- 只执行 static Git object/path/blob/topology 与授权文档/源码读取；
- 未 self-accept、merge、移动 main、创建 R17-R2/R18 或启动下游任务。

Fresh independent ACCEPT/REJECT review 必须绑定本 immutable candidate、sole parent、tree、result blob 与唯一 changed path。候选作者不得接受自己的修改。

## 14. 最终分类

`IP-13I-R17-R1 REVIEW COMPLETE — PRODUCT CONNECTION DUPLICATE-RESOLUTION ORDER-INVARIANCE POLICY FIXED — STATE + TRANSITION PERMUTATION SEMANTICS CLOSED — EXISTING STRUCTURAL/8-19 REASON BOUNDARIES PRESERVED — EVALUATOR REPAIR REQUIRED BEFORE FRESH MAPPING REVIEW — NO PERSISTENCE / APPLICATION / HTTP AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`