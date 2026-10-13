# EliteSync-v10 版本登记入口

**最新版本：v10.0.1 已冻结规划，等待 Owner 手动派发。** [正式冻结计划](v10.0.1/plan.md)（A已接受测试增强选择性纳入，B真实 PHP 资格诊断→新生成 synthetic JSON→独立 Dart 只读消费，C有界验证）；状态 `FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED`。[版前草案](v10.0.1/PLAN_PROPOSAL_V0_1.md)为历史来源，非执行依据。无 live chat bridge/权限/生产授权；不自动合并 v10.0.0 候选，V57 仍暂停。


2026-10-13 `v10.0.0` 已完成独立终验与复盘：**ACCEPT/CLOSED WITH OBSERVATIONS（限定 synthetic/dev-test）**。固定 [冻结计划](v10.0.0/plan.md)（计划提交 `8072ba51ad1dde2e3c3262a418af54531dcec7e0`）、[执行候选](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09)、[Astra 验收](v10.0.0/acceptance.md)、[版本复盘](v10.0.0/retrospective.md)。A+B+D 结束，C另版；候选未合并 main，未取得正式运行/真实数据/生产资格；后继版本等待 Owner 决定。历史 [版前草案](v10.0.0/PLAN_PROPOSAL_V0_1.md) 保留。

未来可采用 `docs/versions/<经 Owner 与 Astra 确定的版本号>/` 下的 `plan.md`、`execution.md`、`acceptance.md`、`retrospective.md`；仅实际创建后才能链接，也可复用具名任务/证据目录。每版登记记录冻结计划与提交、代码基线/候选、实际证据、Acceptance Status、Integration Status 及复盘。版前草案允许反馈，冻结后不得追改目标/验收门，历史原件保持。

**双状态规则**：`Acceptance Status` 表示本版相对冻结标准的独立验收状态与适用范围；`Integration Status` 表示候选代码/工件是否实际并入**具名目标代码主线**。允许记录 `NOT_MERGED`、`INTEGRATED`、`PARTIALLY_INTEGRATED`、`BLOCKED`、`NOT_APPLICABLE`、`UNKNOWN` 等明确值；不得从验收 PASS 推导已合并，也不得因需要整合而自动授权合并。没有目标或原证时如实标注。

**版前轻量既有成果核查**：从已接受、已实现待验收、历史拒绝、本地未核、真正缺失、暂停/保护及未知中识别所需对象，注明依据、真实代码基线和排除范围，再与 Codex 集中确定冻结版。不得重开全历史审查链、重复实现已接受成果或增加日常微审批。原始日志与源码格式检查结论分别记录。

|版本/既有事项|Acceptance Status|Integration Status|固定依据、证据与限制|
|---|---|---|---|
|v10.0.1|**FROZEN_PLAN / NOT_STARTED**|**NOT_APPLICABLE — NO CANDIDATE**|[冻结计划](v10.0.1/plan.md)：A accepted 232行/139数据集 + B nonproduction PHP→JSON→Dart 诊断 + C有界验证；等待 Owner 手动派发。旧[草案](v10.0.1/PLAN_PROPOSAL_V0_1.md)保留|
|v10.0.0|**ACCEPTED / CLOSED WITH OBSERVATIONS**（限 synthetic/dev-test）|**NOT_MERGED**（候选尚未并入 GitHub main，亦不声称并入本地源码主线）|[冻结计划](v10.0.0/plan.md) A+B+D、[终验](v10.0.0/acceptance.md)、[复盘](v10.0.0/retrospective.md)；[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09)：301 tests / 4056 assertions、11类、0 fail；55/55 Git blob；C 另版|
|stage-e2e-v2，WORK-STAGE-M5-TOOLCHAIN-E2E-SYNTHETIC-20261005|历史 **ACCEPT/CLOSED SOURCEONLY+SYNTHETIC**|**NOT_MERGED / LOCAL_ONLY_CODE**（完整作者候选未作为代码发布）|原计划[固定任务](https://github.com/zcx369658780/EliteSync-v10/blob/6fcf3b0178ef3619776211786f1485c22138377d/EVIDENCE/WORK-STAGE-M5-TOOLCHAIN-E2E-SYNTHETIC-20261005/task.md)，本地基线 `4bebc8f394248e254c1368a06fbdee5d2c883301`；manifest `C78CBD247932C0799B455F34A4F7EB3670F02988A7D14DA91BDD20F1F8090518`；[历史验收转录](../migration/ASTRA_HANDOFF_20261012.md)；不等于正式运行合格|
|V57 / H1准确SOURCE_ONLY提案|**DOCUMENT/PROPOSAL ACCEPTED；PAUSED**（窄准备例外已批准）|**NOT_APPLICABLE — NOT_ACTIVATED**（尚无代码执行或行为验收）|原计划与预算本地 `EVIDENCE/WORK-STAGE-H1-EXACT-SOURCE-SCOPE-PROPOSAL-20261011-V43`，LOCAL_ONLY；未激活、未派发、未执行；不能把准备批准提升为实现|

动态登记不能更改原冻结目标。新需求/纯优化进入未来版；计划错误保留原件并记录原因。每版结果无论通过、部分完成、失败或终止都复盘执行偏差、计划错误、环境、验证不足与验收漂移，实际可取得的用时/额度未知则写UNKNOWN。
