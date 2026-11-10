# BE-04 作者候选回执（待 Work LEVEL 2 独立审查）

本地 `D:\EliteSync-v10`，`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。任务为 `ISSUED` 给本 Codex 会话；本回执只交 synthetic/dev-test repository-only 候选，不作 ACCEPT。未提交、推送或改动无关的既有工作区内容。

## 差异

- `app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`：增加独立 `MESSAGING_CONSENT_STATE_TRANSITION_DERIVED_PROJECTION` family、严格顶层/typed payload/dependency 形状与身份校验、来源 condition/currentness/freshness 聚合、稳定 identity 与本地 lineage 映射；原有存储机制处理幂等、同 revision 冲突、不可比、乱序、终态旧 identity 重开和失效。MC typed payload 在保护性读回时保留；终态检查限定于同 family/purpose，避免跨 family 拦截。缺失 CN dependency 可保留为 `UNKNOWN` 的非权限相关性。
- `app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`：MC 加入存储和读回的 typed payload 保留清单。
- `tests/Unit/MessagingConsentPersistenceFamilyTest.php`：新增内存/SQLite 同形矩阵，覆盖单份来源当前态、严格形状/上下文、缺失 CN、UNKNOWN/STALE、同 identity 改输入、等 revision、乱序/不可比、终态重开、失效和非权限投影。

## 验证与预算

在 `services/backend-laravel` 执行。`php -l` 对上述三个 PHP 文件初检各 1 次，均无语法错误；修正测试夹具后仅对该测试文件复检 1 次，仍无语法错误。

以下均用 `php vendor/bin/phpunit tests/Unit/<file>`。六个文件初跑各 1 次：`ProductConnectionPersistenceFamilyTest.php` 5 tests/62 assertions PASS；`CanonicalMatchPersistenceFamilyTest.php` 8/123 PASS；`LogicalPersistenceAdapterConformanceContractTest.php` 19/248 PASS；`InMemoryLogicalPersistenceRepositoryContractTest.php` 24/127 PASS；`SqliteInMemoryLogicalPersistenceAdapterTest.php` 11/1294 PASS。新 `MessagingConsentPersistenceFamilyTest.php` 初跑 6 tests/75 assertions、2 failures；允许的唯一复跑为 6 tests/78 assertions、1 failure，故 **新文件没有 PHPUnit PASS 回执**。

剩余失败是夹具将 `CN=PRESENT`、`MC=STALE` 的混合来源条件误写为顶层 `STALE`；BE-03 要求 `UNKNOWN`。复跑后已将夹具修为顶层 `UNKNOWN` 并复检语法，但新文件 PHPUnit 复跑预算已用尽（初跑 1/1、失败文件复跑 1/1），**修正后的行为 NOT_VERIFIED**，不得报告 73 tests PASS。转移 classification/actor 角色的完整正负矩阵也尚未验证，独立审查应据此决定 REJECT 或另发有预算的修复任务；不得由本候选推断该分支已正确。

当前 SHA-256：内存 repository `3FA195500CD33061CE31417CF443F1775E2F9D0F860008486A5C923D6D182228`；SQLite adapter `39CDD2B47FB5D9F6F0C3466A73230C218E0007E27B6560964C432E67191906BD`；新 Unit test `A7E65FACDC972B34E7BD57090E7460152E79708143CFBE91027A3DAB3BE8760B`。

`NOT_RUN`：Composer、Artisan、Docker、全套测试、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复、UAC、Git commit/pull/push。未访问 `.env`、密钥、业务行、日志、GitHub 或旧 `D:\EliteSync`。

## 权限边界与停点

MC 记录只是来源携带的 synthetic 关联，不调用不存在的 `evaluateCurrent`，不执行 transition/live-gate 求值，不签发真实 MC writer 或 live-read/live-send 权限。即使投影出现 `MC_ACTIVE`，也不构成真实许可、账号或生产 DB 证明。若审查拒绝，回退为不接入新 MC family，旧 RR03、Canonical Match、Product Connection 的本轮定向测试保持已通过状态。现在停在 Work LEVEL 2 独立审查；不自接受、不启动 application adapter、endpoint、migration、writer、Flutter、真实账号或生产动作。
