# EliteSync-v10 版本登记入口

**最新集成状态（2026-10-13）**：Owner既有K08授权下，v10.0.3 已接受的**一个 `app_router.dart` 修复 Blob 和一个动态 Guard 回归测试 Blob**已经定点集成 GitHub `main`；见 [v10.0.3 集成回执](v10.0.3/integration.md)。原候选仍以独立提交保留，不整支merge；**新远端主线没有重跑本版42项运行测试，本地隔离开发基线需要由 Owner 手动交 Codex 安全接续并做限域回归**。原脏工作树仍保留、未对齐；不自动启动下一版。


**最新终验（2026-10-13）**：v10.0.3 已 `ACCEPTED/CLOSED WITH OBSERVATIONS`，仅 synthetic/dev-test 真实 GoRouter 动态Guard修复。[正式冻结计划](v10.0.3/plan.md)、[Astra 验收](v10.0.3/acceptance.md)、[复盘](v10.0.3/retrospective.md)；[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/e2f6db455a329c59b2b4158cc50c0e18561a7c99)。修复前2 PASS/5 FAIL，修复后42/42相关Flutter测试、analyze exit0，45/45 manifest blob。此条在**定点代码集成前**：Integration=`ISOLATED_CANDIDATE_ONLY / NOT_MERGED`；后续按K08单独记录远端定点集成、本地隔离基线与真正集成后运行测试，不覆盖本验收时间点。


**本地隔离基线接续（2026-10-13）**：Codex 报告基于当前 GitHub `main=2175dd62d9384efa05dd6b5201f58c5282379fbb` 建立 `codex/local-baseline-2175dd6` 干净 worktree，HEAD/Tree相符，17项已接受文件在 GitHub 实际逐个校验正确；该本地基线已报告完成范围测试：PHP294/3420，diagnostic12/930，Flutter28，BE-12纯middleware8（完整 Feature、Profile/Release、设备仍 NOT_RUN）。**LOCAL_DEVELOPMENT_BASELINE_READY（Codex 回执；网页未直接读取本机） / ORIGINAL_DIRTY_MAIN_PRESERVED**。具体见 [CURRENT_STATE](../../CURRENT_STATE.md) 与 [知识 K09](../memory/knowledge.md)。不由此认定原 dirty main 已合入或全部历史代码已吸收。

**当前有效状态（2026-10-13）**：v10.0.0、v10.0.1、v10.0.2 均 `ACCEPTED/CLOSED WITH OBSERVATIONS`（仅各自冻结的 synthetic/dev-test 范围）。Owner 分别授权后，前两版14项及 v10.0.2 三项接受的**必要代码/测试/工具 Git Blob**已定点整合进 GitHub 远端 `main`。详见 [前两版集成回执](v10.0.1/integration.md)、[v10.0.2 集成回执](v10.0.2/integration.md)。

**现行多层事实不得混用**：远端 `GITHUB_MAIN_SCOPED_CODE_INTEGRATED`；新隔离本地 `LOCAL_DEVELOPMENT_BASELINE_READY（CODEX_REPORTED）`；原脏根 `ORIGINAL_DIRTY_MAIN_PRESERVED/NOT_RECONCILED`；目标基线 `POST_INTEGRATION_RUNTIME_VERIFIED_SCOPED_CODEX_REPORTED`。旧 `POST_INTEGRATION_RUNTIME_NOT_RUN` 属本次独立基线测试之前的事实快照；完整 APP/Feature/设备/正式生产仍 NOT_RUN。未自动立 v10.0.3，原冻结版验收不重裁。

未来可采用 `docs/versions/<经 Owner 与 Astra 确定的版本号>/` 下的 `plan.md`、`execution.md`、`acceptance.md`、`retrospective.md`；仅实际创建后才能链接，也可复用具名任务/证据目录。每版登记记录冻结计划与提交、代码基线/候选、实际证据、Acceptance Status、Integration Status 及复盘。版前草案允许反馈，冻结后不得追改目标/验收门，历史原件保持。

**双状态规则**：`Acceptance Status` 表示本版相对冻结标准的独立验收状态与适用范围；`Integration Status` 表示候选代码/工件是否实际并入**具名目标代码主线**。允许记录 `NOT_MERGED`、`INTEGRATED`、`PARTIALLY_INTEGRATED`、`BLOCKED`、`NOT_APPLICABLE`、`UNKNOWN` 等明确值；不得从验收 PASS 推导已合并，也不得因需要整合而自动授权合并。没有目标或原证时如实标注。

**版前轻量既有成果核查**：从已接受、已实现待验收、历史拒绝、本地未核、真正缺失、暂停/保护及未知中识别所需对象，注明依据、真实代码基线和排除范围，再与 Codex 集中确定冻结版。不得重开全历史审查链、重复实现已接受成果或增加日常微审批。原始日志与源码格式检查结论分别记录。

|版本/既有事项|Acceptance Status|Integration Status|固定依据、证据与限制|
|---|---|---|---|
|v10.0.3|**ACCEPTED/CLOSED WITH OBSERVATIONS**（仅synthetic真实Router Guard修复）|**GITHUB_MAIN_SCOPED_CODE_INTEGRATED / LOCAL_NEW_MAIN_HANDOFF_PENDING / POST_INTEGRATION_RUNTIME_NOT_RUN**|[冻结计划](v10.0.3/plan.md)、[独立验收](v10.0.3/acceptance.md)、[复盘](v10.0.3/retrospective.md)、[定点集成](v10.0.3/integration.md)、[候选](https://github.com/zcx369658780/EliteSync-v10/commit/e2f6db455a329c59b2b4158cc50c0e18561a7c99)：原2/5→最终42/42PASS、45/45 Git Blob、新15项隔离哨兵0；Android/正式权限NOT_RUN|
|v10.0.2|**ACCEPTED/CLOSED WITH OBSERVATIONS**（仅 Debug/Test synthetic 只读 Widget）|**GITHUB_MAIN_SCOPED_CODE_INTEGRATED / LOCAL_ROOT_PENDING / POST_INTEGRATION_RUNTIME_NOT_RUN**|[冻结计划](v10.0.2/plan.md)、[终验](v10.0.2/acceptance.md)、[复盘](v10.0.2/retrospective.md)；[候选](https://github.com/zcx369658780/EliteSync-v10/commit/5bb2de6bed2eb8cbc063e707c39a594ae35eb301)、[定点集成回执](v10.0.2/integration.md)：3项新文件，36/36候选Git blobs、PHP12/930、Flutter28 PASS、同字节；Profile/Release & BE-12 runtime/Feature NOT_RUN|
|v10.0.1|**ACCEPTED/CLOSED WITH OBSERVATIONS**（限 synthetic/dev-test 只读诊断）|**GITHUB_MAIN_SCOPED_CODE_INTEGRATED / LOCAL_ROOT_PENDING**|[冻结计划](v10.0.1/plan.md)、[验收](v10.0.1/acceptance.md)、[复盘](v10.0.1/retrospective.md)、[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/ffbfeca78b97262f141d69e0542bb72b43e2f186)；56项blob，PHP294/3420，12场景930检查，Dart9 PASS；BE-12 pure middleware PASS，Feature NOT_RUN|
|v10.0.0|**ACCEPTED / CLOSED WITH OBSERVATIONS**（限 synthetic/dev-test）|**GITHUB_MAIN_TEST_BLOB_INTEGRATED / LOCAL_ROOT_PENDING**|[冻结计划](v10.0.0/plan.md) A+B+D、[终验](v10.0.0/acceptance.md)、[复盘](v10.0.0/retrospective.md)；[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09)：301 tests / 4056 assertions、11类、0 fail；55/55 Git blob；C 另版|
|stage-e2e-v2，WORK-STAGE-M5-TOOLCHAIN-E2E-SYNTHETIC-20261005|历史 **ACCEPT/CLOSED SOURCEONLY+SYNTHETIC**|**NOT_MERGED / LOCAL_ONLY_CODE**（完整作者候选未作为代码发布）|原计划[固定任务](https://github.com/zcx369658780/EliteSync-v10/blob/6fcf3b0178ef3619776211786f1485c22138377d/EVIDENCE/WORK-STAGE-M5-TOOLCHAIN-E2E-SYNTHETIC-20261005/task.md)，本地基线 `4bebc8f394248e254c1368a06fbdee5d2c883301`；manifest `C78CBD247932C0799B455F34A4F7EB3670F02988A7D14DA91BDD20F1F8090518`；[历史验收转录](../migration/ASTRA_HANDOFF_20261012.md)；不等于正式运行合格|
|V57 / H1准确SOURCE_ONLY提案|**DOCUMENT/PROPOSAL ACCEPTED；PAUSED**（窄准备例外已批准）|**NOT_APPLICABLE — NOT_ACTIVATED**（尚无代码执行或行为验收）|原计划与预算本地 `EVIDENCE/WORK-STAGE-H1-EXACT-SOURCE-SCOPE-PROPOSAL-20261011-V43`，LOCAL_ONLY；未激活、未派发、未执行；不能把准备批准提升为实现|

动态登记不能更改原冻结目标。新需求/纯优化进入未来版；计划错误保留原件并记录原因。每版结果无论通过、部分完成、失败或终止都复盘执行偏差、计划错误、环境、验证不足与验收漂移，实际可取得的用时/额度未知则写UNKNOWN。
