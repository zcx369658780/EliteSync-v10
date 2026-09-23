# EliteSync v10｜当前上下文与交付入口

> 本页为 2026-09-21 历史快照。实时本地入口已迁至仓库根 `CURRENT.md`、`TASK_CURRENT.md` 与 `REVIEW_GATE.md`；GitHub 仅用于备份、里程碑与发布。以下原文保留作来源，不作为此后任务的当前状态。

维护修订：2026-09-21 / delivery-refresh-2。事实核验基线：`608c6b04dc17022db7fcf72c34b494a0944ece03`，不是未来 main 必须等于的常量。
本修订：`REVIEW CANDIDATE — FACTUAL STATUS REFRESH + PROSPECTIVE DELIVERY RULES`；非作者 ACCEPT 绑定精确 blob 且进入 main 后生效。上一版计划包已由独立记录 `4d7164e157cd9c0e1274af51661bd0857de05f91` 接受，不能仅因旧正文仍写 PROPOSED 将其判为未接受。

## 1. 当前状态与唯一代码任务

`R17-R3 ACCEPTED — R18 REJECTED — R18-R1 ISSUED, OWNER REPORTS NOT STARTED — NO DOWNSTREAM IMPLEMENTATION AUTHORIZED`

| 对象 | 已核验处置 | 固定证据 |
|---|---|---|
| 原 R17 | 历史候选仍 REJECTED，不追认 | rejection `415ee64eb70894eed21eee97e58762307d6e408f` |
| R17-R1 / R17-R2 | Option A 及 evaluator 修复已有接受记录 | acceptance `cb44607f773705c168f15ca093935be1893259b7` / `acfedada11c3c6e76b83f9674142168245db9c0f` |
| R17-R3 | 自包含映射、IP-13E sufficient、Package A 已接受 | result `813817fdfe4a67c2835021ca64d74d4ed41acc03`；acceptance `2b1f23520912517f0e3ae6735208253fbfa37b4f` |
| R18 | 六路径实现候选有局部绑定键序缺陷，未集成 | candidate `64dd8f8dccbbb3582656f98a70b1e36c6449fe0b`；rejection `26bcbaf64953159c0ea53c5e9be78e817e2192c9` |
| R18-R1 | 仅应用修正及回归；Owner 本轮报告未执行 | task `b28397028f8795149886b7c8ecb9ddb51a691b86`；原发布基线即本页事实基线 |

当前工程任务路径：
`docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_TASK_V0_1.md`。

不因本轮流程优化修改此任务的技术内容、六路径范围、最多两次 PHPUnit 及首次 PASS 停止规则。若文档集成推进 main，必须通过显式的首次执行基线重发再启动，不能假称它已通过在途 gate。重发规则见本次精确 dispatch；新工作流不自动覆盖旧任务。

R18 三个 Phase-A blob 仅获准在修正候选中原样复用，并非已独立接受的实现：IP-13A `6178bc7290a9e542a39155756c9dd9e43d9eb0b2`、IP-13D `678881a6c5868170270f4a400351966dd2e69a95`、persistence test `e4e6b946e5bace72da0bf36db6fd49caa328d00f`。当前 main 尚不包含这些实现。

## 2. 读取入口：只展开本次消费的来源

先实时核验明确远端，再读对应 `AGENTS.md`。当前状态读本页；排程读 `ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`；固定来源读 `ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md`；任务编写读 `ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md`，均位于本目录。

来源索引不是批量读取授权。Product Connection 新实现默认消费已接受的 R17-R3 自包含契约及当前精确修正，不再惯例性重读整条 rejected R16/R17 链。真实矛盾出现时才按任务展开对应历史定义。

## 3. 已有能力与尚未证明的出口

| 能力层 | 可复用事实／报告 | 尚不能宣称 |
|---|---|---|
| 产品设计 | 15-domain、四栏 IA、MVP/Phase 2/Later 已有 Owner 接受 | 整条愿景已经实现 |
| 客户端 | APP-T12 报告 11-area 静态矩阵及 retained gaps | 当前 Android/iOS 安装、启动、端到端通过 |
| Readiness / Canonical Match | 9/21 历史交接报告 synthetic/dev-test 至 HTTP | 真实账户、状态写入、生产 matching authority |
| Product Connection | 已接受 evaluator 和映射；实现等待 R18-R1 | persistence/application 已接受、HTTP 已授权 |
| Messaging / Conversation | fail-closed 客户端基础已有报告 | 真实读写、交流同意和运行主循环已闭合 |
| Home / Notifications | 静态／隐私展示基础已有报告 | live projection、OS delivery 已完成 |
| 平台运行 | 本轮无新的环境、构建或设备观察 | 全局无 APK、工具链必坏或已恢复 |

APP-T12 result `4c00def5a94a117c8d9812996baf193de4a4aeb1` 的契约通过不等于运行通过；本轮没有重新验证其完整独立接受链或运行。历史 handoff `ed36cab735c57f57d516400cf549dec2a1bae8db` 是前序信息，不是当前任务授权。

## 4. 下一段交付方向

近期以单平台、显式虚构数据的可安装开发演示为排程目标；平台暂按 Android 估算，尚非已核验的平台决定或构建许可。R18-R1 收口后，应优先把最小平台运行证明插入核心开发早期，而非等待所有后端完成。

保留现有 M0–M6：M0 已完成上一轮归一；M1 映射已接受；M2 待实现修正接受；M3/M4 仍待领域与实际消费边界闭合；M5 的“首次可运行证明”前移，完整集成仍在其后；M6 分真实内测与公开运营出口。这里的 M 编号不是历史工具链 M1/M2/M3。

只在实际消费需要时补 transport；不为形式自动加 Connection HTTP。synthetic 投影不等于状态写入：可操作演示必须单独说明虚构 actor、测试状态驱动／写入、保存与重启恢复，不能靠 UI 本地布尔值伪装服务端权限。详细工作量与条件性窗口在现有路线图内，不另建平行路线。

## 5. 不变产品及 Product Connection 边界

`Home | Progress | Messages | Me`；Progress 仅为导航容器。`Match != Connection != Conversation != Relationship`；各阶段独立授权。Explore、Relationship 支持为 Phase 2；optional AI/reference 为 Later，不拉入近期 MVP。

Private Identity / Matching Inputs / Readiness / Showcase 分离；MVP 无 globally public Profile、无单一权威 Compatibility 总分。Meaning / Provenance / Purpose / Lifecycle Authority 区分；七个责任上下文不是七个服务／数据库。用户声明不是客观事实；AI 不是已验证事实；Safety 不进入普通 Compatibility/Ranking/reputation；private Conversation 不是默认 AI/training/ranking/ads 数据。

Privacy、Safety、User Control 优先；Explainability、Reliability、Fairness、Auditability 支撑。Block != Report；Report/Allegation != Finding；即时保护不等于罪责；未推进不证明举报者说谎；UNKNOWN != FALSE/SAFE。

`NEXT_DOMAIN = PRODUCT_CONNECTION`；`MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`。family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`；facts `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` / `PRODUCT_CONNECTION_TRANSITION_DERIVATION`；Binding Model A 为派生自有、确定性、非权威关联。

fully usable 当且仅当 `protected_binding_satisfied=true AND source_condition=PRESENT AND currentness=true AND freshness=true`。保留 6 structural diagnostics、8/19 persisted reasons、R16-R1 矩阵及 R17-R3 自包含定义；保留 terminal 和失效前上下文。`GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`；`EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`；`TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`。

## 6. 保留缺口、工具链及法律／数据边界

APP-T12 G-02/G-03/G-05/G-06/G-08/G-13 的真实后端权威缺口不被 derived slices 自动关闭；G-07 共享数据权利、G-04/G-09 UNKNOWN、G-10 Phase 2、G-11 兼容债务、G-12 工具证据分类保留。launch eligibility、minimum identity assurance、exact proposal expiry、Conversation retention/export/deletion/revoke/closed history 均不推断默认值。

auth/session/token、真实 authority writers、生产持久化／部署仍需精确授权。真实内测前必须分别关闭必要权限、写入、恢复、撤回及数据处理出口；不把它们藏进笼统“最后上线”步骤。

历史工具链 M1 冻结 lane 耗尽、M2 deferred、M3/DEP13 未解除、B12 未授权；NON-HIT 不证明全局无 artifact 或构建失败。保留 `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`。前移平台证明不解除这些规则，不授权本轮 probe、安装、缓存检查、Flutter/Dart/Gradle/Java/Android。

README 预算耗尽；FD02 永久排除；旧 `D:\EliteSync` / `zcx369658780/EliteSync` 禁止访问；无默认枚举／搜索／全仓 status/index 操作，保护无关 staged/untracked/modified 内容。

保留 accepted ADR、D-02 unresolved / D02-DURABLE-UNKNOWN-01、U-14、U-12、TP-SOURCE-CLASS-01、TP-TARGET-01、deferred PUI、PUI-PREREQ-12=0 及原证据根。历史 Backend 0/10、Database 0/8 受限盘点未解除，也不否定后来精确获准的 synthetic 工作。

沿用 `CORE PRE-ALPHA LEGAL BOUNDARY IS SUBSTANTIALLY COMPLETE; PRODUCTION LEGAL READINESS IS DEFERRED TO MATERIAL MATURITY TRIGGERS`，不是新法律结论。Safety-only 运营风险评估 NOT DECIDED；不启动 research/recruitment、真实或私密数据、telemetry/analytics/measurement、Safety Operations、新 legal research、LC-03/LC-04/Phase36 或生产部署。

无 source/account/header/auth 推断、global revision、synthetic aggregate dependency revision、LWW、arrival-order/timestamp authority。历史细节在旧 context blob `e22cc69b903ef852dbb558d6f3aa9d6abd08d604`、ref `67b14d97732fe831e4ac9321373a8a0a6f7d22f9`，仅在精确任务需要时读取。

## 7. 状态维护纪律

接受／拒绝／新任务发布时，在同一授权交付内更新受影响状态与来源指针；不再为纯事实同步串行增设预审、实施、验收。必须保留历史 task/result/acceptance/rejection/ADR/handoff 原文。事实更新不改变契约或独立接受结论；语义规则变更仍需非作者审查。

本页核验的是截至所列 base 的状态；此后以更新的精确任务／接受记录为准。不得把本页“未执行”写成执行器现场证明，也不得由本页自动启动后继。
