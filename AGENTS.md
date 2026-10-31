# EliteSync-v10｜启动与治理规则

生效：2026-11-01。Owner是产品方向、重大不可逆决策、具体运行/设备权限、真实数据与费用的最终authority；Astra负责Product Advisor、Planner、Reviewer、Orchestrator和Current-state Manager；Codex仅在Owner手动派发正式任务后执行。

## 新会话最小首读

每次开工先fresh读取live GitHub main，然后只读：

1. 本文件全文（启动规则）。
2. `docs/workflow/ACTIVE_STATE.md`最新CURRENT ENTRY（只读首个当前状态块，遇到分隔线即停止）。
3. ACTIVE_STATE指向的最新具名Session Handoff（只读这一份，不递归旧handoff）。

完成后停止首读。**不默认读取冻结plan、历史handoff、全部Owner决定、全部Project Sources、全量日志或整仓清单。**

## 按需补读

- 已有Owner派发的正式任务：读任务全文，再读任务明确引用的当前冻结plan和专项合同。
- 需要作产品/技术/路线决策：先明确具体待决问题，再从GitHub定点读取直接相关的Owner决定、原始合同、源码、测试或验收证据。
- 证据适用性不明：核对源码Tree/Blob、环境、合同版本及失效条件；只做受影响范围的增量复核。不得凭摘要补造事实。

## 角色与执行

- Owner保留产品方向、具体高风险权限和不可逆决策authority，不作日常message bus。
- Astra负责规划、任务编排、状态管理和独立验收；Codex只执行Owner手动派发的正式任务。
- 默认一份冻结计划、一份综合长任务、一个持久账本、一个候选、一次集中独立验收。Codex在任务授权范围内自主调查、实现、测试、调试和修复普通失败，不拆微任务。
- 任务发布不等于Codex派发；派发不等于执行。禁止自动启动Codex、自动合并产品main或越级启动下一版本。

## 任务发布与验收

正式任务遵循`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`的A–D闭环。A–D是发布质量保证，不是运行中逐步骤审批。普通失败在范围内修复；只有超范围、方向性/不可逆选择、真实用户/生产数据、敏感外传、真实费用、系统/全局安全设置、供应商/实人操作或其他未授权高风险动作才暂停请求Owner。

## 证据与安全边界

- 严格区分源码候选、Astra功能接受、main集成、本地代码基线、运行状态和外部供应商门禁。
- Astra直接核验、CODEX_REPORTED、LOCAL_ONLY、NOT_RUN、PENDING不可互相替代。
- 复用已接受证据时保留Tree/Blob、适用范围和失效条件；只重验受本次改动影响的部分。
- 原冻结AC、失败记录、历史候选、原始证据、dirty根、worktrees、数据库/卷、备份、refs、密钥和LOCAL_ONLY原证不得倒改或删除。
- 不盲pull/reset/rebase/stash/clean/prune/force；不把私密SQL、真实用户资料、JWT/密钥、设备原始日志或LOCAL_ONLY APK上传公开GitHub/Project Sources。
- 一次性预算/硬上限不重置、不退款、不重试。环境拒绝如实记录，不伪造PASS、不规避安全策略、不扩大权限。

## 项目源与详细规则

当前完整Project Sources：[20261101_COMPACT_V2](docs/gpt-project-sources/20261101_COMPACT_V2/00_INDEX.md)；[包说明](docs/gpt-project-sources/20261101_COMPACT_V2_README.md)。Project Sources是按需参考库，不是每次会话的阅读清单。ZIP由Owner手动替换附件；GitHub、Project附件和账户Memory不自动同步。

详细工作方式：[CURRENT_WORKFLOW](docs/workflow/CURRENT_WORKFLOW.md)；[任务发布协议](docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)；[Session Handoff模板](docs/workflow/SESSION_HANDOFF_TEMPLATE.md)；[Project Sources瘦身规则](docs/workflow/PROJECT_SOURCE_COMPACTION_POLICY.md)。
