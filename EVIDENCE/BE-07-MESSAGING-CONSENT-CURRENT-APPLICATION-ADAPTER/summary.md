# BE-07 作者候选回执｜待 Work LEVEL 2 独立审查

本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。仅新增本任务允许的 adapter、同名 Unit test 和本回执。保留既有无关 modified/untracked；未提交或推送。

## 差异与边界

- 新 `services/backend-laravel/app/Domain/MessagingConsentPersistenceApplicationAdapter.php`：仅接受一份 synthetic CN state evidence、一份同 context/purpose 的 MC state evidence 和恰两位参与者/requester/recipient；按 BE-05 的严格 `MC_CURRENT_STATE` 形状构造来源携带的非权威记录。调用现有 application boundary **一次** `submitAuthoritativeMutation`，由其内部 repository 校验；仅在 `STORED_NEW/EXACT_DUPLICATE` 后按 family/identity/intent/lineage/context/participants/purpose/typed payload、未失效状态精确读取。不可比、冲突、缺失/未知/不新鲜与失效均不给可用关联。`invalidateCurrentSynthetic` 只对精确已选 CN/MC evidence identity 做 correction/revocation/supersession 观察，不重开 consent。所有返回的 `source_authority`、`permission`、`live_read_allowed`、`live_send_allowed`、`message_sent` 恒为 false。
- 新 `services/backend-laravel/tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php`：验证单份来源、幂等、缺失/UNKNOWN/STALE、跨 Connection/participants/purpose/来源 owner、changed-input identity、同 revision 冲突、不可比 lineage、精确失效及非权限返回。

现有 application boundary 构造器只接收 `SqliteInMemoryLogicalPersistenceAdapter`，所以本新增 adapter 的真实集成测试仅覆盖 SQLite；BE-05 repository family 的独立内存/SQLite 同形测试在本任务预算中另行运行。`transport_observation='AMBIGUOUS'` 是 BE-05 MC 记录合同的固定非权威标记，不被解释为提交成功或具体 timeout；本 adapter 不接收外部 transport timeout 字段，额外字段输入被拒为不可用。没有调用不存在的 MC `evaluateCurrent`，没有从 projection 重建来源、调用 transition/live gate 或发送消息。

## 验证与预算

在 `services/backend-laravel`：两份新增 PHP 各一次 `php -l` 均无语法错误。`php vendor/bin/phpunit tests/Unit/MessagingConsentPersistenceApplicationAdapterTest.php` 初跑 **4 tests/92 assertions PASS**；`MessagingConsentPersistenceFamilyTest.php` 初跑 **8/103 PASS**；`PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php` 初跑 **9/709 PASS**。三文件合计 21 tests/904 assertions PASS；未使用失败复跑预算。未运行其他测试。

SHA-256：新 adapter `A001371D7BC9BA0C9E9E23EC517016E17B38E8137DAB8CCE1C5F512DA0680A43`；新 Unit test `B4D9015D4C29B87AB1C836A5C76565170F19F86A6513DBA0EC2AED0663B34F6E`。

`NOT_RUN`：Composer、Artisan、Docker、全套测试、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复、UAC、Git commit/pull/push。未访问旧 `D:\EliteSync`、GitHub、`.env`、真实账号、私钥、业务行或日志。

## 停点与回退

`correlation_usable=true` 仅说明这份 synthetic 关联与精确读回一致，**不**建立当前真实 MC authority 或 live-read/live-send grant。`CN_ACTIVE`、MC projection、storage disposition 和 transport 均不替代使用点双输入求值；真实 writer、transition、live gate、endpoint、migration、账号和生产 DB 仍 `NOT_READY`。若 Work 审查拒绝本候选，回退为不接入新增 adapter；BE-05 已接受 repository family 与既有 application boundary 保持原状。作者现在停在 Work LEVEL 2 独立审查，不自接受、不派发后继。
