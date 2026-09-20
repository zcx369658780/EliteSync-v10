# EliteSync v10｜当前上下文与交付入口

维护版本：2026-09-21（Asia/Singapore）。

本次整理状态：`PROPOSED — INDEPENDENT REVIEW REQUIRED — NO IMPLEMENTATION AUTHORIZED`。

事实快照基线：`67b14d97732fe831e4ac9321373a8a0a6f7d22f9`。这是证据日期的 base，不是未来 main 必须等于的常量。每轮按明确任务 fresh-fetch；本版本只有在独立接受记录绑定精确 blob 并进入 main 后才作为新入口生效。

## 1. 当前结论

`PRODUCT_CONNECTION_SELECTED — R17_CANDIDATE_REJECTED — PRODUCT_IMPLEMENTATION_PAUSED — PLANNING_DOCUMENT_OPTIMIZATION_ONLY`

Owner 本轮授权优化项目计划、路线及必要项目源，并要求给出 Codex 同步入口；不是恢复 R17 修复、发布 R18 或启动 Messaging 的授权。

R17 独立拒绝记录：
`docs/architecture/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
blob `415ee64eb70894eed21eee97e58762307d6e408f`。

候选 `6af50b3cdf82ac8bc285bd160f773b48b29f1328` / result `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8` 未接受、未合入。拓扑通过；拒绝源于 evaluator 在“旧等修订冲突 + 更高修订”组合下顺序敏感，以及后继来源清单缺项。

9 月 21 日交接 blob `ed36cab735c57f57d516400cf549dec2a1bae8db` 保留为完成会话的历史上下文；其中 R17 IN FLIGHT 已被上述拒绝记录更新。原 R17 冻结 authority `b0196202c78f688723600ac9919cf96463908375` 仍是其历史审查基线，不因本轮文档改变而要求重写旧候选。

## 2. 只读所需的四类入口

| 文件 | 职责 | 不能替代 |
|---|---|---|
| `AGENTS.md` | 稳定协作和保护规则 | 本轮授权 |
| 本文件 | 当前状态、活动边界及 lane | 代码/测试事实源 |
| `ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` | 产品交付里程碑与依赖 | 精确任务单 |
| `ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md` | 固定来源、纠正/继承关系 | 被引用的原文 |

工作方式见同目录 `ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md`。路径引用不是自动读取所有来源的授权。

## 3. 进度必须按交付层区分

| 层/能力 | 本轮证据支持的状态 | 尚不能宣称 |
|---|---|---|
| 产品目标 | Owner 已接受 15-domain 设计与四栏 IA | 生产功能全部完成 |
| 客户端契约/界面基础 | APP-T12 rerun 结果已存在 main，记录 11-area 静态集成矩阵及 retained gaps | 本轮重新验收全部客户端；可运行/可安装 MVP 已证明 |
| Runtime Readiness | 最新交接记录 synthetic/dev-test 纵向切片接受至 HTTP | 真实身份保证、生产 readiness authority |
| Canonical Match | 最新交接记录 synthetic/dev-test 切片接受至 HTTP | 自动 Connection、实际生产 matching/mutation authority |
| Product Connection | 历史 evaluator 接受、R15-R1 reason 与 R16-R1 record/cross-field 契约保留；R17 新反例未解决 | persistence family / application adapter / HTTP 已完成 |
| Messaging / Conversation | 客户端契约基础已有报告；运行边界受 Connection 和 messaging consent 依赖阻塞 | 真实读/发消息权限 |
| Calm Home / Notifications | 静态/隐私展示已有报告；live projection 与 delivery 仍属后续 | 活态摘要或 OS delivery 已接受 |
| 客户端工具链/恢复链 | 独立 lane；本轮无运行、安装、缓存或构建新证据 | 恢复成功、全局构建失败或全局无产物 |
| 真实内测/生产 | 独立授权与成熟度门槛尚未开放 | 可以采集数据、部署或上线 |

APP-T12 证据：`ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`，blob `4c00def5a94a117c8d9812996baf193de4a4aeb1`。结果内的 ACCEPTED 是当时契约/静态范围的分类；该文还保留 candidate-only 文本。本轮核实其 main 内容，不用“在 main”替代其完整独立接受链，不据此授权新实现，也不把当时未运行的 Flutter 测试写成通过。

## 4. 产品与架构不变项

目标：calm, consent-sequenced Relationship Decision Support System；体验为状态、权限、下一步、原因、退出路径清楚，不以更多 Match、消息或停留时间为目标。

`Home | Progress | Messages | Me`；Progress 仅是导航容器。Explore 与 Relationship 支持为 Phase 2，optional AI/reference signals 为 Later/Optional，不变成 MVP 阻塞。

`Match != Connection != Conversation != Relationship`。各阶段分别授权；Match 不自动创建 Connection，Connection 不自动开放 Conversation，Conversation 活跃度不推断 Relationship。Private Identity / Matching Inputs / Readiness / Showcase 分离；MVP 无 globally public Profile、无单一权威 Compatibility 总分。

信息按 Meaning / Provenance / Purpose / Lifecycle Authority 区分；七个概念责任上下文不是七个服务或数据库的实现要求。用户声明不是客观事实，AI 输出不是已验证事实，Safety 证据不是 Compatibility/Ranking/reputation 输入，private Conversation 不是默认 AI/training/ranking/ads 数据。

Privacy、Safety、User Control 优先；Explainability、Reliability、Fairness、Auditability 支撑。Block != Report；Report/Allegation != Finding；即时保护不等于罪责；未推进不证明举报者说谎；UNKNOWN != FALSE/SAFE。

## 5. Product Connection 保留基线

`NEXT_DOMAIN = PRODUCT_CONNECTION`；`MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`。

family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`；facts `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` / `PRODUCT_CONNECTION_TRANSITION_DERIVATION`；Binding Model A 为 derivation-owned deterministic non-authoritative correlation bindings。

两类 typed dependency 的 `protected_binding_satisfied` 是非权威验证元数据。fully usable 当且仅当它为 true，source_condition=PRESENT，currentness=true，freshness=true。保留 6 个 structural diagnostics、8/19 persisted reasons、R16-R1 dependency-presence/context/revision matrix、当前状态 terminality 及失效时上下文保留。

`GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`；`EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`；UNKNOWN/REJECTED 不因精确存取变成可用；`TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`。

R17-F1 的 conflict precedence 尚未裁定。本次不排序/过滤 evidence 来绕过 evaluator，不发明 reason，不修改现有源码。R17-F2 的有效来源继承已在索引显式列出；清单补全不是 R17 接受或 F1 修复。

## 6. 有界缺口与独立 lane

| 缺口 | 影响范围 | 本次处置 |
|---|---|---|
| R17-F1 / F2 | Connection 映射接受与其下游 | 保持拒绝/暂停；仅记录未来有界处理位置 |
| launch eligibility / minimum identity assurance | 对应真实资格与身份保证 | UNKNOWN，不阻塞无身份推断的文档工作 |
| exact proposal expiry | Match 具体到期行为 | 不从旧 countdown 继承 |
| Conversation retention/export/deletion/revoke/closed history | 共享内容与真实数据权利 | 无生产默认值，成熟度触发专项决定 |
| auth/session/token、durable authority writers、生产持久化/部署 | 真实端到端执行 | 未授权，不能被 derived HTTP 切片抵消 |
| 客户端运行验证及兼容性债务 | 集成/迁移交付 | 沿用 APP-T12 G-11/G-12，不重复产品设计 |
| Sandbox/DEP13/B12/M2/M3 | 客户端构建与恢复 lane | 不由后端或文档任务自动恢复 |
| Phase-2 工具及 optional AI/reference allowlist | 可选后续能力 | deferred/UNKNOWN，不扩核心 MVP |

M1 冻结 lane 耗尽；其 NON-HIT 不证明全局 artifact 不存在或构建失败。M2 deferred；M3/DEP13 未解除；保留 `WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.` 历史事实，B12 未授权。本轮不重新检查运行环境。

## 7. 历史边界不能被“优化”删除

README 预算耗尽；FD02 永久排除；旧仓库/旧目录禁止访问；不默认枚举、代码/文件名搜索、全仓 status/index 操作。保护无关 staged/untracked/modified 状态。

D-02 unresolved / D02-DURABLE-UNKNOWN-01、U-14、U-12、TP-SOURCE-CLASS-01、TP-TARGET-01、deferred PUI、PUI-PREREQ-12=0 及其原证据根/精确 scope 保留。历史 Backend 0/10、Database 0/8 受限盘点未自动解除，不把它们泛化成对后续已批准 synthetic 工作的否定。

沿用 `CORE PRE-ALPHA LEGAL BOUNDARY IS SUBSTANTIALLY COMPLETE; PRODUCTION LEGAL READINESS IS DEFERRED TO MATERIAL MATURITY TRIGGERS`，不是本次新法律结论。保留 Safety-only 运营风险评估 NOT DECIDED；不启动 research/recruitment、真实或私密数据、telemetry/analytics/measurement、Safety Operations、新 legal research、LC-03/LC-04/Phase36 或生产部署。

无 source/account/header/auth 推断；无 global revision、synthetic aggregate dependency revision、LWW 或 arrival-order/timestamp authority。历史明细可在本文件旧 blob `e22cc69b903ef852dbb558d6f3aa9d6abd08d604` / 原基线读取，仅在任务明确授权时展开。

## 8. 更新纪律

只在接受、拒绝、实际 blocker 或授权变化时更新本入口。旧 handoff 与 accepted 原文不覆写。当前路线是排程层，旧 2026-09-12 roadmap 仍是产品范围/历史顺序证据，不再作为“下一步 APP-T01”的实时指令。

任何完成状态附来源与层次；未知保留未知。日期仅为规划，不以任务数量/文档数量当完成百分比。不为每次 commit 重发项目源包。
