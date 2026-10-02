# BE-08｜MC 当前态 synthetic audience 绑定修复

状态：Work 派发给最新合资格 Codex 执行会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；LEVEL 2、synthetic/dev-test backend。BE-07 候选已 REJECT；保留其未提交新增 adapter/test 作为修复起点。旧 BE-07 测试预算不重置。

只允许修改 `services/backend-laravel/app/Domain/MessagingConsentPersistenceApplicationAdapter.php`、`services/backend-laravel/tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php` 与本目录 `summary.md`。只读固定来源：根 `AGENTS.md`、`CURRENT.md` 当前入口、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`、BE-06 `plan.md`/`work-review.md`、BE-07 `task.md`/`summary.md`/`work-review.md`、`CommonAuthorityEvidenceContract.php`、`MessagingConsentConversationLiveGateEvaluator.php`、`PersistenceBoundaryApplicationInterfaceIntegrationContract.php`、`InMemoryLogicalPersistenceRepositoryContract.php` 及 BE-05 MC family test。不得修改 repository、evaluator 或其他测试。

只修 synthetic protected audience 绑定：在请求中固定非空、显式的目标 audience，要求 CN 和 MC 两份 `required_bindings.audience` 分别与其精确相等；缺失、类型错误、CN 错配、MC 错配和两份来源互不相同均 fail closed，不能写入可用关联。目标 audience 是本地 synthetic 请求绑定，不是可信来源认证或 live-read/send 权限。所有返回权限字段继续恒 false；保持一次提交、精确读回、幂等、失效及其他 BE-07 行为。

本任务新验证预算：在 `services/backend-laravel` 下对实际修改的两份 PHP 各一次 `php -l`，修后仅复检受影响文件；`php vendor/bin/phpunit tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php` 初跑一次，失败后修复仅复跑该文件一次。通过后 `MessagingConsentPersistenceFamilyTest.php`、`PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php` 各初跑一次，因本任务变化失败仅复跑失败文件一次。不得运行其他测试、Composer、Artisan、Docker、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复或 UAC。

`summary.md` 记录精确差异、命令/结果、旧 BE-07 与本轮预算分隔、`NOT_RUN` 和非权威边界。保留无关 modified/untracked；不访问旧 `D:\EliteSync`、GitHub、`.env`、真实账号、私钥、业务行或日志；不提交/pull/push。作者完成后停 Work LEVEL 2 独立审查，不自接受、不派发 transition/live gate、endpoint、migration、writer、Flutter 或生产任务。
