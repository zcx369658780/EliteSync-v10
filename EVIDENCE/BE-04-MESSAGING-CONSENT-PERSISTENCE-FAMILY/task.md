# BE-04｜MC 派生记录族最小后端切片

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；LEVEL 2，**synthetic/dev-test backend repository-only**。BE-03 `plan.md` 与 `work-review.md` 是接受的合同和精确边界；BE-02 `plan.md` 已 REJECT，不得作为实现合同。

## 允许路径与唯一结果

只可修改：

- `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
- `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
- 新建 `services/backend-laravel/tests/Unit/MessagingConsentPersistenceFamilyTest.php`
- 本目录 `summary.md`（唯一任务回执，记差异、验证和停点）

只读对照限根 `AGENTS.md`、`CURRENT.md` 当前入口、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`、BE-03 `plan.md`/`work-review.md`，`CommonAuthorityEvidenceContract.php`、`MessagingConsentConversationLiveGateEvaluator.php`、`ProductConnectionPersistenceFamilyTest.php`、`CanonicalMatchPersistenceFamilyTest.php`、`LogicalPersistenceAdapterConformanceContractTest.php`、`InMemoryLogicalPersistenceRepositoryContractTest.php`、`SqliteInMemoryLogicalPersistenceAdapterTest.php`。`composer.json`、`phpunit.xml` 和固定 test runner 路径可只读核对命令。若合同与现有接口发生不可消解的冲突，记录精确阻断并停，不自行改其他源码或扩权。

## 实现和验证

在两个 repository 中加入相同的独立 MC family 支持：严格 15 键 envelope/typed payload、Common Authority 十一键 bindings 与五键 revision、来源依赖与派生 owner 分离、稳定 identity/幂等、同 revision 冲突/不可比、乱序和失效读回。只存 synthetic 来源携带证据的**非权威关联记录**；`MC_CURRENT_STATE` 不调用不存在的 evaluator 当前态入口；本切片不执行 transition/live gate 求值。未知、不新鲜、跨 context/purpose、终态旧 identity 重开或失效时 fail closed。SQLite 必须保留并严格读回新 typed payload；原有 RR03、Canonical Match 和 Product Connection family 行为不可退化。

新测试须有内存/SQLite 同形正负矩阵，至少覆盖精确键与错误类型、当前态来源关联、缺失/UNKNOWN/不新鲜、changed-input identity、同 revision 冲突、不可比 lineage、乱序、跨 Connection/参与者/用途、终态重开、失效、transport timeout 非提交、投影非权限和旧 family 回归。不得用 synthetic `MC_ACTIVE` 声称当前真实许可。

只允许在 `services/backend-laravel` 下运行本地 `php vendor/bin/phpunit` 的定向 Unit 测试：新 `MessagingConsentPersistenceFamilyTest.php`，以及 `ProductConnectionPersistenceFamilyTest.php`、`CanonicalMatchPersistenceFamilyTest.php`、`LogicalPersistenceAdapterConformanceContractTest.php`、`InMemoryLogicalPersistenceRepositoryContractTest.php`、`SqliteInMemoryLogicalPersistenceAdapterTest.php`。每个文件初跑一次；若本任务修改后失败，可修复并只重跑失败文件一次。可对允许的三个 PHP 源/测试文件各运行一次 `php -l`，修复后只复检受影响文件。不得运行 Composer、Artisan、Docker、全套测试、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复或 UAC。保留现有 modified/untracked，不访问旧 `D:\EliteSync`、GitHub、`.env`、私钥、业务行或日志；不提交/pull/push。

`summary.md` 写明精确文件差异、测试/语法检查命令与结果、未运行项、非权威界限和失败回退（拒绝新 family，不影响旧三个 family）。作者完成后停在 Work 独立 LEVEL 2 审查，不自接受、不派发 application adapter、endpoint、migration、writer、Flutter、真实账号或生产动作。BE-01/02/03 及 AUTH-152/153 的历史预算均不重置。
