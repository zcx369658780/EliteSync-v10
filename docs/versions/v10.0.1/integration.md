# EliteSync-v10｜v10.0.0 + v10.0.1 已接受候选的 GitHub main 定点整合

> 执行依据：Owner 于 2026-10-13 明确授权“先整合两个已接收候选，然后规划下个版本”。  
> **目标：仅 GitHub 远端 `main` 的明确代码/测试/复现源整合；本地 `D:/EliteSync-v10` dirty root 未被网页工具触碰，未称本地完成同步。**  
> 整合前 main：`2097e27127d20e9b3f78f625a4bf193d406e1f9e`，公共原始代码父基线：`4bebc8f394248e254c1368a06fbdee5d2c883301`。本次实际整合提交以 GitHub 回执/固定链接为准，不自写提交 SHA。

## 1. 接受来源

- v10.0.0 独立验收 `ACCEPTED/CLOSED WITH OBSERVATIONS`；[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09)；唯一新增现有 Product Connection 测试的 Git Blob `5e59626a5ed640482cc786862f5e1e9c01511262`、232行/139命名测试数据集。
- v10.0.1 独立验收 `ACCEPTED/CLOSED WITH OBSERVATIONS`；[固定候选](https://github.com/zcx369658780/EliteSync-v10/commit/ffbfeca78b97262f141d69e0542bb72b43e2f186)；已精确包含前述相同测试 Blob，并额外包含有界 PHP 资格诊断与 Dart 独立只读消费者、synthetic fixtures、同次跨语言验证工具。
- v10.0.1 的合成 PHP→JSON→Dart 验证 12/930、Dart 9 PASS，选定 PHP 294/3420 PASS；全部是**之前候选执行的原始证据**，不是整合后 main 新运行。两版本验收与复盘正文保持原样。
- 整合前经 GitHub 对比确认：自公共代码父基线以来，`main` 只有治理与文档路径变化，**0 apps/services 源码变更**。三个 Domain 依赖及 BE-12 route/middleware 已分别核验仍是 candidate 预期 Blob。

## 2. 白名单定点纳入，而非合并候选历史

下列 14 个 Git Blob 均从 **v10.0.1 固定候选**的准确 Git 对象取得；不改写其字节，不 merge/cherry-pick 两个分叉分支：

| 完整路径 | 复用的 Git Blob |
|---|---|
| `apps/flutter_elitesync_module/lib/features/qualification_diagnostics/domain/qualification_diagnostic.dart` | `1d5a4cc16040d73432a0548f4cb57b85fc5bef58` |
| `apps/flutter_elitesync_module/test/features/qualification_diagnostics/qualification_diagnostic_test.dart` | `3e67da81d5844fdefddfd20b05e278a078f37d95` |
| `services/backend-laravel/app/EliteSync/ConversationLifecycle/FrozenQualificationSource.php` | `5d4f9fb8238910a3a3c0cf090799dcafff6f341d` |
| `services/backend-laravel/app/EliteSync/ConversationLifecycle/LocalTestConversationLifecycle.php` | `3fb229d8406514f295850e33e1759db362ad08f5` |
| `services/backend-laravel/app/EliteSync/ConversationQualification/ConversationQualificationSource.php` | `5939892786098f8b29a1c5e29acee6dd50c6eab2` |
| `services/backend-laravel/app/EliteSync/ConversationQualification/ConversationUsePointQualifier.php` | `2ebf5d6afb8a09c3819584936135c3aa725b55b3` |
| `services/backend-laravel/app/EliteSync/TextAuthority/ExistingEvaluatorEvidenceAdapter.php` | `c48432cbd2330cacf91e06c138868e5dc16071de` |
| `services/backend-laravel/tests/Unit/EliteSync/ConversationLifecycle/FixtureFourFamilySource.php` | `236d4be9d9aab4da9719f4883f48f7cf58ef3513` |
| `services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/DiagnosticScenarioFactory.php` | `d17169285e15969aa2a219d433e6230cad39ed86` |
| `services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php` | `77389961019e49cbf5d8a35d84b9afa3af05c4f6` |
| `services/backend-laravel/tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php` | `5e59626a5ed640482cc786862f5e1e9c01511262` |
| `docs/versions/v10.0.1/tools/validate_diagnostics.py` | `a8845ea28ed77c7009c85f4a6ee76465030ed6d7` |
| `docs/versions/v10.0.1/evidence/source-intake.json` | `69fc7e06d0bdee9e8582ee247bd5b22d5761f8e4` |
| `docs/versions/v10.0.1/phpunit.test-only.xml` | `c29386d5135eb56ec0bb9e4f1b1745f3b03be0f1` |

其中11项为既有来源、产品只读诊断、测试和 fixtures；余3项为有界回归复现脚本、source-intake 及 test-only 配置。没有将旧候选 40余项原始收据/长日志再复制到主线，它们仍可在上述**固定候选提交**完整读取。

保留原 main 的正式 `docs/versions/v10.0.0/plan.md`、`docs/versions/v10.0.1/plan.md`、双方 acceptance/retrospective、迁移记录及全部既有文档身份。main 此次整合只是代码白名单的路径替换/新建；不接触旧 `D:/EliteSync`、原本地 `D:/EliteSync-v10` 工作树、其 index/未提交代码/历史 EVIDENCE 或任何其它 worktree。

## 3. 验证等级与明确不能声称的事

- **GIT_OBJECT_INTEGRATED**：先核候选 blob、旧 main 源身份，并在发布后读回 main 每个白名单 blob、commit 变更范围及保留的历史 plan/blob。
- **POST_INTEGRATION_RUNTIME_NOT_RUN**：网页 GitHub 工具不能在本地 PHP/Flutter/Android 环境重新跑验证。之前 candidate 的 JUnit、Dart、JSON 和 SHA 证据仍有效于该 candidate 的具名技术范围；不得声称本次 main commit 本身已通过新运行。
- **LOCAL_ROOT_NOT_SYNCED**：原本地 `main` 仍属另一个脏工作树，Owner 必须通过现有 Codex 在保护 dirty/untracked 下按精确对象安全对齐，不能直接 `git pull`/`reset`/`clean`/`stash`/`rebase` 全树。
- **NO_RUNTIME_AUTHORITY**：PHP qualifier `contract-only`，Dart 仅诊断，不连接真实 Chat 权限、路由或消息 writer；原 BE-12 七条 live 私密消息路由默认 404。完整 Feature 路由测试仍 `NOT_RUN`；V57 PAUSED、H2/D0 未签发、`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED` 等不变。
- **Acceptance Status 与 Integration Status 分开**：两版 `ACCEPTED/CLOSED` 不变；在固定远端主线整合的**仅是列明的有效代码/测试/复现材料**。候选历史整体并未 merge，原证以不可变引用保存；本地源码根尚未实际整合。未来需要本地真实测试时，在明确候选/安全工作树中执行。
- 本文是 Owner 新授权下的**集成回执/事实登记**，不得追改已冻结的 v10.0.0/v10.0.1 计划与验收标准；也不为 v10.0.2 开发创造授权。

**收尾分类：`TWO_ACCEPTED_CANDIDATES_SCOPED_CODE_INTEGRATED_TO_GITHUB_MAIN — LOCAL_ROOT_PENDING_SAFE_RECONCILIATION — POST_INTEGRATION_RUNTIME_NOT_RUN`**
