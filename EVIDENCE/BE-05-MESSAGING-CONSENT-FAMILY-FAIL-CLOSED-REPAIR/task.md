# BE-05｜MC repository fail-closed 修复与定向复核

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；LEVEL 2、synthetic/dev-test backend。BE-04 候选已 REJECT，保留其未提交差异作为本任务修复起点；旧 BE-04 PHPUnit 初跑/复跑预算已耗尽，**不重置**。

只允许修改 `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`、`services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`、`services/backend-laravel/tests/Unit/MessagingConsentPersistenceFamilyTest.php` 和本目录 `summary.md`。只读固定来源：根 `AGENTS.md`、`CURRENT.md` 当前入口、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`、BE-03 `plan.md`/`work-review.md`、BE-04 `task.md`/`summary.md`/`work-review.md`，`CommonAuthorityEvidenceContract.php`、`MessagingConsentConversationLiveGateEvaluator.php` 及其同名 Unit test、五个 BE-04 已运行的既有定向测试文件。不得扩大源码/测试写入路径。

修复目标只有三项：

1. 让 `MC_CURRENT_STATE` 的 `current_state` 对任何分类都与单份来源 state 一致；`UNKNOWN` 不允许保存与来源冲突的状态。缺失/不新鲜条件仍可保存为非权限 `UNKNOWN`，绝不可升为 active grant。
2. repository-only 尚不调用 `evaluateTransition`。在后继 adapter 获独立授权和真实 evaluator 输出绑定前，MC transition 记录最多只能有 `UNKNOWN` 分类；不得接受仅凭自报 `ADMISSIBLE/REJECTED` 的记录。仍严格核对 source transition 的 from/to、expected MC revision、actor 与绑定参与者，并以负向测试证明非法角色、旧终态重开、直接 `MC_NONE→MC_ACTIVE` 均不能伪造可用分类。不要在 repository 中自行签发转移结果。
3. 修正 BE-04 测试夹具后，完成新 MC test 的真实行为验证，并补充上述负向用例及内存/SQLite 一致性；保留旧三个 family 的行为。

本任务新预算：在 `services/backend-laravel` 下只运行一次 `php vendor/bin/phpunit tests/Unit/MessagingConsentPersistenceFamilyTest.php`；如失败，可只修本任务允许文件并仅再运行该文件一次。通过后各运行一次 `ProductConnectionPersistenceFamilyTest.php`、`CanonicalMatchPersistenceFamilyTest.php`、`LogicalPersistenceAdapterConformanceContractTest.php`、`InMemoryLogicalPersistenceRepositoryContractTest.php`、`SqliteInMemoryLogicalPersistenceAdapterTest.php`；如因本次代码变化失败，可只复跑失败文件一次。对本任务实际改动的 PHP 文件可各运行一次 `php -l`，修后只复检受影响文件。不得运行其他测试、Composer、Artisan、Docker、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复或 UAC。

`summary.md` 为唯一回执，列精确差异、命令/结果、旧 BE-04 失败与本任务新预算的区分、`NOT_RUN` 和非权限边界。保留全部无关 modified/untracked；不访问旧 `D:\EliteSync`、GitHub、`.env`、私钥、真实账号、业务行或日志；不提交/pull/push。作者交付后停 Work 独立 LEVEL 2 审查，不自接受、不派发 application adapter、endpoint、migration、writer、Flutter 或生产动作。
