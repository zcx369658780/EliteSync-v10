# BE-05 作者候选回执｜待 Work LEVEL 2 独立审查

本地 `D:\EliteSync-v10`，`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。以 BE-04 被 REJECT 的未提交候选差异为起点，只修改本任务允许的内存 repository、新 MC Unit test 和本回执；SQLite adapter 本任务未改。保留全部无关 modified/untracked，未提交或推送。

## 精确修复

- `MC_CURRENT_STATE` 的 `current_state` 现在始终必须等于单份 MC 来源 dependency 的 `state`，包括 `classification=UNKNOWN`；缺失 CN 或未知/不新鲜来源仍可保存为非权限 `UNKNOWN` 相关性。
- repository-only 的 `MC_TRANSITION` 只接受 `classification=UNKNOWN`。自报 `ADMISSIBLE` 或 `REJECTED` 均拒绝；不在 repository 调用或替代 `evaluateTransition`。原有 from/to、expected MC source revision、actor 属于精确参与者且与来源 binding actor 一致的形状校验继续生效。
- MC 测试增加来源状态矛盾、转移仅 UNKNOWN 正例、自报可用分类、非法 actor、直接 `MC_NONE→MC_ACTIVE` 与旧终态重开等负例，均覆盖内存和 SQLite。

## 验证及预算

在 `services/backend-laravel` 执行。对本任务实际修改的两个 PHP 文件各运行一次 `php -l`，均无语法错误。新预算中，`php vendor/bin/phpunit tests/Unit/MessagingConsentPersistenceFamilyTest.php` 首跑 **PASS，8 tests/103 assertions**，未复跑。其后五个既有定向文件各首跑一次且均 PASS：`ProductConnectionPersistenceFamilyTest.php` 5/62；`CanonicalMatchPersistenceFamilyTest.php` 8/123；`LogicalPersistenceAdapterConformanceContractTest.php` 19/248；`InMemoryLogicalPersistenceRepositoryContractTest.php` 24/127；`SqliteInMemoryLogicalPersistenceAdapterTest.php` 11/1294。合计六文件 75 tests/1957 assertions PASS。`git diff --check` 对两处 repository 源码无输出。

此为 **BE-05 新预算**；BE-04 新测试初跑 2 failures、唯一复跑 1 failure，旧预算已耗尽且未重置。BE-04 修夹具后的状态当时仍 `NOT_VERIFIED`，现由 BE-05 的 8 项首跑建立新验证回执。

当前 SHA-256：内存 repository `3B7A808FEE6D4DAE22424F3AA9D74E2888B9CEBE06F12F68AFC5AA19C24DB58E`；SQLite adapter（本任务未改）`39CDD2B47FB5D9F6F0C3466A73230C218E0007E27B6560964C432E67191906BD`；MC Unit test `ACA2F9F8480C5CBEDFC0F89278E05C8D299AB69D4CF1E17FAB61EB10EEB64ED7`。

`NOT_RUN`：其他测试、Composer、Artisan、Docker、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复、UAC、Git commit/pull/push。未访问 `.env`、私钥、真实账号、业务行、日志、GitHub 或旧 `D:\EliteSync`。

## 权限边界与停点

所有 MC 记录仅为 synthetic/dev-test 的非权威来源相关性。`MC_CURRENT_STATE` 不等于真实当前许可；`MC_TRANSITION=UNKNOWN` 不签发转移结果；投影、存储成功、transport 观察都不授予 live-read/live-send。真实 evaluator 输出绑定、使用点复核、MC writer、auth/session、生产 DB 和账号仍需独立任务及风险门。作者现在停在 Work LEVEL 2 独立审查，不自接受、不派发后继。
