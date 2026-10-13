# EliteSync-v10｜v10.0.0 正式冻结版本计划

> **状态：FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**  
> **版本定位：** 已接受 Product Connection 持久化与应用边界的「当前依赖组合验证、必要回归补充及可复现交付」；内部开发版本，**不是**市场发布或 MVP 全部完成。  
> **冻结日期：** 2026-10-13（Asia/Shanghai）。冻结依据为本文件在 GitHub 的**实际发布提交及 Git blob**；其完整身份以发布回执/固定 URL 和后续版本验收登记为准，避免文档自写自身 commit。  
> **决策：** Owner 授权网页 GPT 顾问制定 v10.0.0 版本规划；Astra 阅读 Codex `READY_WITH_FINDINGS` 后选择 A+B+D，明确 C 另版。冻结不等于自动启动：**Owner 须将本固定计划手动转交指定 Codex 会话，发出执行指令后才可实施**。未经该手动派发，只能阅读。  
> **历史草案：** [PLAN_PROPOSAL_V0_1](PLAN_PROPOSAL_V0_1.md) 永久保留原样，作为版前来源，**不再是本版执行依据**。冻结后不得通过编辑本文追改目标/范围/验收标准；变动需记录偏差并另立版，不能通过变更 main 动态入口偷换冻结契约。

## 1. 身份、证据层级与生效规则

- 唯一仓库 `zcx369658780/EliteSync-v10`，源码本地根 `D:/EliteSync-v10`。冻结时顾问实际读取 GitHub `main`：`af045376b36fc592b453cfd6367612ee927d1d48`；这只是**计划发布前的文档基线**，不是本地源码 HEAD。
- Codex 2026-10-12/13 版前只读现场报告：本地 `main` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`；默认 index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`；staged 0、tracked 43、untracked normal 208（目录可折叠）；95/95 具名保护文件已于接收时核验。**这些是 Codex 报告，不是网页顾问现场重测；正式候选必须重新固定纳入对象身份。**
- 指定版前接收会话：`01a13084-65a4-7c71-bf32-fa60a68d2099/local`，其 `projectId=null` 仅是工具列表元数据，Owner 已确认 UI 项目归属和 Git 根。手动派发可交给此会话，若 Owner 更换会话须带同一冻结计划及接续证据。
- [新工作流](../../workflow/CURRENT_WORKFLOW.md)：Owner 定方向与保护决策；网页顾问冻结计划/最终独立验收与复盘；Codex 仅在冻结、派发的范围内自主实现和修复，不逐命令求批。旧 Work/Dot 不恢复实时监督。
- [R18-R1 独立接受](../../architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_ACCEPTANCE_V0_1.md) Git blob `3b40a1df27ccb345457029227a4dafe51064a5ca`，原历史结论 `ACCEPT`、130 tests/2798 assertions/0 fail/error/skip。接受的 adapter blob `06e1dfa4134a3c01dde5b4cf1ccc592a352f8e84`、test blob `f3e0d9839ea79795564b0962f36088a41735b727`；Codex 报告当前本地两者匹配。
- **重要差异：** R18 原候选仍 REJECT；R18-R1 已 ACCEPT，故本版**不重做 R18-R1、不重新声明同一缺陷未修**。历史 PASS 不是本版当前依赖的新运行 PASS，也没有赋予 HTTP/真实 writer/生产权限。
- Codex 报告现行共享内存/SQLite 包含 BE-05 后续 MC 修复，MC adapter/test 另有 BE-08 修复；具体当前本地身份与下游依赖仍须按本版有限 manifest 确认，禁止以 R18-R1 原 Phase-A blob 覆盖这些较新的已接受本地对象。

## 2. 本版范围（A+B+D，C 不纳入）

### A｜有界来源纳入与安全候选

1. 从上次只读现场记录恢复所需 **Product Connection / 共享持久化 / Messaging Consent** 的具名后端源、测试、fixture、配置与接受关系。每一纳入文件记录 path、来源（已跟踪基线/LOCAL_ONLY/历史具名接受）、Git blob 或 SHA256、理由及本版用途。仅项目内具名增量，不重扫/纳入整个历史 EVIDENCE/Flutter 树。
2. 固定代码 **Git 父基线** 为 `4bebc8f394248e254c1368a06fbdee5d2c883301`，选用**独立隔离的实现 worktree/分支**，以明确白名单从当前 LOCAL_ONLY 源码复制/物化必要对象。最终候选身份 = 父提交 + 逐文件纳入来源/内容 + 本版改动 + 提交/tree/交付 manifest；`af045...` 与本次计划发布提交属于文档来源，不得冒充上述代码父基线。
3. 原 `D:/EliteSync-v10` 根工作树、本地 main/HEAD/默认 index、dirty/staged/untracked、既有 223 个 worktree及原始 EVIDENCE 均不由本版重置/清理/覆盖；不 whole-tree add、pull/rebase、reset/clean/stash 或盲目 cherry-pick rejected 候选。隔离路径冲突或选定文件身份不符时先保存事实，提出具体阻碍，不静默切换父基线。
4. 本版只纳入实际 11-test 组合与有限负向回归所必需的源/测试依赖；Flutter、其它 `App/EliteSync`、BE-12 等暂列 `RETAINED_LOCAL_ONLY` 或 `HISTORICAL_ACCEPTED`，不得以本版之名全量迁移。

### B｜Product Connection 当前依赖的回归补齐（非历史缺陷重做）

1. 优先扩充 `services/backend-laravel/tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php` 中**有价值且现有覆盖不足**的用例：11 个命名绑定字段中的嵌套缺失/额外键、其它命名字段值或类型差异、`participants` required/source 精确字段值相等（顺序与类型保留）、descriptor participants 的独立集合语义；保留既有关联键插入顺序不变回归。
2. 必须遵守 [R17-R3 已接受契约](../../architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md) 与 R18-R1 已接受实现：11 个 named binding 字段按对应键严格比较；`protected_binding_satisfied` 不新增 currentness/freshness 等判据；匹配/连接/对话/关系的独立同意与权限不合并。
3. 不预设需要改产品源码。只有在本版新增的有效用例/现有 11-test 组合真实暴露 **本边界内的源码缺陷** 时，才允许针对 `ProductConnectionPersistenceApplicationAdapter.php` 做最小修复并补相应回归；不得擅自整体退回 shared repository/SQLite 的历史版本。若失败要求修改 BE-05/BE-08 共享合同或扩大其它领域/生产路由，记录 `BLOCKED_SCOPE_DECISION`，保持有效原证并请 Owner/Astra 决定另版，不能暗改冻结范围。
4. 重复现有有效测试不是额外成果；补测需显示具体新增区分力，不能为满足数量制造无意义断言。

### D｜有限联合回归、固定交付与审查

冻结后、Owner 手动派发时允许的验证仅限**本项目隔离候选、合成/开发测试环境**。PHP/Composer/vendor 等路径存在不代表当前能运行；无需自动安装、下载、升级或改变 SDK/全局配置。

拟定组合测试（冻结目标覆盖这些准确 11 个测试文件，命令/入口可由 Codex 在等价无副作用的本地环境内适配并在证据中记录）：

```powershell
$tests = @(
  'ProductConnectionPersistenceApplicationAdapterTest'
  'ProductConnectionPersistenceFamilyTest'
  'ProductConnectionStateTransitionEvaluatorTest'
  'CanonicalMatchPersistenceFamilyTest'
  'CanonicalMatchPersistenceApplicationAdapterTest'
  'InMemoryLogicalPersistenceRepositoryContractTest'
  'SqliteInMemoryLogicalPersistenceAdapterTest'
  'PersistenceBoundaryApplicationInterfaceIntegrationContractTest'
  'LogicalPersistenceAdapterConformanceContractTest'
  'MessagingConsentPersistenceFamilyTest'
  'MessagingConsentPersistenceApplicationAdapterTest'
)
$files = $tests | ForEach-Object { "tests/Unit/$_.php" }
& 'C:\tools\php85\php.exe' vendor/bin/phpunit --do-not-cache-result @files
```

从隔离候选中 `services/backend-laravel` 启动。只访问合成 fixture/内存或测试专用临时 SQLite；**禁止**读写真实/生产数据库或 .env 凭据、远端服务、用户消息。普通失败自主诊断修复重测，保留第一次及后续 raw stdout/stderr 与 exit、命令、输入和修复关联；不限制尝试次数，不删有效测试/降低断言求 PASS。若依赖缺失需要安装/升级或风险越界，停止对应操作并提供证据。

核对应用层是否通过**实际生产函数 + 真实测试序列化/读回/失效路径**完成提交→检索→比较→投影/权限决策链的预期结果。孤立构造 JSON、文本检索、已有历史 PASS 不足证明新候选当前通过。测试声明范围必须忠于实际执行的函数与依赖，不能把 synthetic 提升为 live grant。

交付时：
- 先固定源码/test/fixture、命令和原始验证证据的有限 technical manifest（完整 SHA256）；必要情况下明确哪些只有 LOCAL_ONLY。
- 提供候选 Git commit/tree/blob 的准确身份与区别于主仓 dirty root 的复现方法，保留 accepted/rejected 历史。
- **将供 Astra 终验所需的安全源代码候选、测试、脱敏 raw 运行证据和 manifest 发布至 GitHub 的明确候选分支/固定提交**（仅本版白名单、普通非强制推送，不合入 main、不触及生产）；无法安全发布的必需原证标 `EVIDENCE_INACCESSIBLE`，通过 Owner 安全方式提供后才可独立验收，不能仅给本地路径或作者自报。
- 最终集中交付，等待 Astra 版后独立验收及复盘。返修仅针对本版冻结目标，新增功能另版。

## 3. 明确排除（整个 v10.0.0 不变）

- **C：后端→Flutter Conversation live/完整 synthetic 跨层消费桥不属于本版。** APP-INT-04 / M5 等既有 Flutter synthetic 接受按其当时范围保留，不重新实施；BE-12 的七条真实私密消息路由默认 fail-closed/404，不得解除。backend qualifier contract-only、live grant=false、writer/使用点/来源契约仍未贯通；不得以本版声称消息 live 读发已放行。
- V57/H1 既有窄 `SOURCE_ONLY` 例外已获批准仍 `PAUSED/NOT_ACTIVATED/NOT_DISPATCHED/NOT_EXECUTED`，不作为本版必须工作包；H2/D0 未签发，旧路线和 `NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 不变。
- 不执行正式 Driver/JVM/compile/14case/Android/SDK/设备、真实账号迁移、双库解密/恢复、生产 DB/API/SSH、服务部署/发布、真实私密消息/凭据、真实用户测试、重要资产删除或环境/依赖升级；不能根据本版 PASS 解冻这些保护门。
- 不修改 canonical APP 设计、数据受众/用途、AI/Safety 法权界限或 R17-R3/R18-R1 接受语义；旧拒绝窗保持历史身份。
- 不“清空全部遗留任务”，不做全仓历史 worktree/日志清理，不自动恢复旧 Work/Dot/监督或旧任务队列。

## 4. 不可后改的完成标准（AC）

| 验收 ID | 本版唯一可接受的可观察标准 |
|---|---|
| **AC-01 基线** | 真实选定源/测试/fixture 的 path+identity+来源清单；隔离候选父 `4bebc8f...`、候选 commit/tree/manifest 可复现；原工作树及默认 index 无本版造成的破坏。 |
| **AC-02 合同** | 明确区分 R18 原拒绝与 R18-R1 历史独立接受；当前最终候选上键序不变性、字段缺失/额外/类型差异及两种 participant 比较语义经**有效测试**证明且不降低既定绑定合同。 |
| **AC-03 有限组合** | 上述准确 11 测试文件在最终候选的本地开发/synthetic 环境运行，报告真实命令、退出码、pass/fail/skip/deprecation、raw 双流；失败保留诊断/修复/重测链。缺依赖不得冒 PASS。 |
| **AC-04 真实边界** | 同一最终候选上的真实内存/SQLite 测试提交、回读、失效/拒绝和应用结果按其原合同受到联合回归覆盖。不得以孤立 JSON 或历史回执替代。 |
| **AC-05 可独立审查** | Astra 可经 GitHub 固定 ref 读取本版所需最终源/测试/manifest、必要安全原始日志或 Owner 脱敏等价材料；作者自述与哈希清单不足以独立终裁。 |
| **AC-06 残留缺口** | 本版具名清单逐项分类 `ALREADY_ACCEPTED`、`CLOSED_BY_V10_0_0`、`RETAINED_OUT_OF_SCOPE`、`BLOCKED_NEEDS_OWNER`、`UNKNOWN`；C/V57/正式运行/真实数据等不得伪列本版 PASS。 |
| **AC-07 交付复盘** | Codex 集中交付代码与证据身份、未完成事项；Astra 对这份固定计划作独立终验（通过/有条件/失败/退修），记录目标偏差、实际可取得的工时/额度与首版工作流复盘；同版仅修原范围缺陷。 |

**任何 AC 未满足不得宣布全部 PASS**。存在非本版的旧保护缺口不自动构成 AC 不通过，但仍不得授予超范围资格。仅本文明确列出的 AC 是本版冻结验收标准；草案中 C 的候选 AC-04 已撤销并由本版验证 AC-04 取代。

## 5. 执行与变更管理

- 本文发布后处于 **FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH**。Owner **手动**把本文固定 GitHub URL 和明确“执行 v10.0.0 冻结版”指令交给 Codex，才启动版内 A→B→D。不能因为 GitHub 文件出现而自动执行、监听或唤起 Work。
- Codex 在该版授权和安全范围内自主调整具体实现顺序/必要最小测试、调查、诊断、修复、重测；普通失败不需要 Astra 逐步批准。不可逆、真实数据/生产、变更既定产品/科学语义、全局依赖升级或持续实质阻塞须停在安全点报告。
- 如 11-test 目标在确切工具/依赖下无法运行，按 `BLOCKED/NOT_RUN` 留证。不得降验收门以宣布成功；可由 Astra 独立判定版本部分完成/失败，下一版处理无效计划，而不追改本文件。
- 完成后 Codex 通知 Owner 并提供精确固定 GitHub candidate、身份 manifest、受影响回归与原证；Astra 终验。未来 `execution.md`、`acceptance.md`、`retrospective.md` 可在版本目录建立；它们是历史执行/验收/复盘记录，不得更改本计划。
- 本版不自动合并到 `main`，不推送真实数据/原始私有 session/密钥。GitHub 文档备份不等于生产权限。

**结尾分类：`V10.0.0 FROZEN_PLAN — A+B+D — C DEFERRED — HISTORICAL R18-R1 ACCEPTED — AWAITING OWNER DISPATCH`**
