# v10.0.11 K09 安全产品集成与本地连续基线｜冻结长任务单

**2026-10-18 — K09_FROZEN_INTEGRATION_TASK / OWNER_MANUAL_DISPATCH_PENDING / NO_PRODUCT_MERGE_YET**

本文件是 v10.0.11 已经 Astra ACCEPTED_WITH_OBSERVATIONS 后的独立集成任务单。发布本文仅冻结任务范围，不等于已向本地 Codex 派发，也不授权本文发布前的任何产品集成操作。Owner 必须将本文完整转交本地 Codex，之后本任务才获得一次性执行授权。

## 1. Authority、已接受候选与唯一目标

- Owner：最终方向、重大不可逆决策与产品发布 authority。
- Astra：本版独立验收已完成；负责限定范围审议与后续验收。
- Codex：在本任务获 Owner 手动派发后，自主执行一次安全产品集成、静态验证、保护检查和集中交付。
- 不恢复微审批、不要求 Owner 逐条复制中间日志；普通工程错误在本任务内自主诊断、修复和重测。

正式冻结功能计划：[`plan.md`](plan.md)，Blob `eb6de5a0ef6cdbd0cc8aa2fd35826a22b88b63d9`。

正式 Astra 验收记录：[候选分支 acceptance.md](https://github.com/zcx369658780/EliteSync-v10/blob/codex/v10.0.11-dynamic-relationship-charts/docs/versions/v10.0.11/acceptance.md)。

接受状态：`ACCEPTED_WITH_OBSERVATIONS`，仅限冻结范围。

固定产品源码锚：
- Commit `78ab7827b258cb649920e5121f24d506dae2a93c`
- Tree `6f3edd909f37a3a0b8ecaf3fa8da1af02a47f186`
- apps Tree `fc925bd85ed9c5ced157ae7dc3cad2b0aabe62c7`
- services Tree `29cedff599411c7c246ba32e62d53b5d63e28f3f`

Codex 交付 Commit/Tree：`2d7e96c315a3c19345a4b9d5af3969ddcff4e0ea` / `7ec351844db5c9d989cfd033093df57caee8d306`。

验收记录后追加的文档 Commit：`513d7c3adbf49a59decad8f3c8d82510e28da8de`；这不是产品源码锚。集成必须显式选用上面的已接受产品对象，不得把报告、验收文档或临时审阅目录一起带入产品树。

派发时 main 固定基线（仅在本文发布时核验）：`f4b547f11ced66065a53ffae816db34c210f7009`，Tree `19c7e225a20975c08d1452e09147b90dc29ae7c4`。执行时须重新读取 live main。若 main 已前进，必须先比较并发差异、保留新内容，不能覆盖回本文基线。

## 2. 集成边界：只选择接受的产品对象

仅集成下面 21 个产品/测试路径，按固定源码锚的精确 blob/object 选择。产品源码不得编辑或“顺手修复”；如集成发现接受源码缺陷，暂停受影响集成并报告 Astra，不能把代码修复混进 K09。

### Android / Flutter（6）

- `apps/android/app/build.gradle.kts` — `6d50b295eb8aaf423b1fdcbf17c2ed80236e8480`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart` — `2b54d5edec20b29baa9dd55fb941ae5bd576220a`
- `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_landing_page.dart` — `6186d80b97ea24a847cc8e519b451946daeaee4c`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/dynamic_chart_page.dart` — `5a7673b704a354746e889a35cc733fb198efed17`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/widgets/dynamic_chart_wheel.dart` — `1b0c79aa178626da96b0146f9b35fc56ea2ba748`
- `apps/flutter_elitesync_module/lib/main_prod.dart` — `03a10479df3bb571815fc37d5f9663baf2e648e3`
- `apps/flutter_elitesync_module/test/features/profile/dynamic_chart_page_test.dart` — `4dff19867ec94b641a2657d78f300b227e716359`

### Laravel / Python / profile / tests（14）

- `services/backend-laravel/app/Http/Controllers/Api/V1/DynamicChartController.php` — `a371e7a39b2c3b0376ca5c66788a96f64be76dd6`
- `services/backend-laravel/app/Http/Middleware/PrivateDynamicCharts.php` — `c58ffbb1a2504e34686679b802a4a22bd5b30b27`
- `services/backend-laravel/app/Models/UserDynamicChart.php` — `6f443de74684c0cfb9db216d88aa0dbd71282287`
- `services/backend-laravel/app/Services/DynamicChartService.php` — `dc2d36fa8386b169d8e9a70dc30ae790b56e0210`
- `services/backend-laravel/bootstrap/app.php` — `460bc9bf926a141d740c2e3654303e0053ab8ef2`
- `services/backend-laravel/config/dynamic_charts.php` — `123e9905a85d154c0fc77a94c00867a203ecc70c`
- `services/backend-laravel/database/migrations/2026_10_18_100011_create_user_dynamic_charts_table.php` — `7aeb5f23cd0f5971758dea42e7b54d76f64cc2b2`
- `services/backend-laravel/resources/natal/dynamic-profile-registry.json` — `d9d3781ec1b9e78b453b8808896003cd63fbca32`
- `services/backend-laravel/routes/api.php` — `6ef864bf8405e80c973afb60198c6e73167b48c7`
- `services/backend-laravel/tests/Feature/V1011DynamicChartApiTest.php` — `9104b05bca7c8677a88455d6bcf9c8560b4cc899`
- `services/backend-laravel/tests/Unit/V1011DynamicInputTest.php` — `c917435d0c30b5b0a30d4a94ea74fcd9705d1a71`
- `services/backend-laravel/tools/natal/dynamic.py` — `28c82b377bf50c0960fa8d7b723fa86cd459d0f1`
- `services/backend-laravel/tools/natal/oracle/dynamic_reference.py` — `7083afd8cc71569504716f4ccd90c0b551268185`
- `services/backend-laravel/tools/natal/tests/test_dynamic_reference.py` — `5c981355e7fda6e8ee5c708c115a65178072aac6`

Before changing any path, verify that the exact accepted object exists and that the path inventory matches the accepted source. If the actual source tree has a different blob than this list, STOP that path and report the mismatch; do not silently substitute a current branch version.

## 3. Safe integration protocol

1. Read live main SHA/tree and relevant product subtree trees. Confirm main ancestry from the known task baseline or document all concurrent movement since it. Never force-push.
2. Inspect local worktree identities, worktrees, status, index, untracked/ignored state and existing backups. Use the existing dedicated clean worktree only after confirming its identity; do not operate in `D:/EliteSync-v10` dirty root.
3. Create/reuse a dedicated clean branch `codex/k09-v1011-integration` from the latest live main. The candidate implementation branch is a source object, not a branch to merge wholesale.
4. Confirm each of the 21 accepted product path blob IDs and build exact target product subtrees. Preserve all unrelated product objects if they have not changed; if any relevant subtree has concurrent changes, compare and reconcile without overwriting those changes. No blanket replacement of apps/services based solely on old subtree identity.
5. Preserve all existing owner decisions, frozen plans, acceptance records, historical failures, privacy/licence evidence and unrelated version documentation byte-for-byte. Do not copy `docs/_temporary_review/`, APK/AAR, LOCAL_ONLY artifacts, credentials, private inputs, database files or screenshots into product paths.
6. Run only bounded static/object verification for integration: exact path/blob inventory, full apps/services tree comparison against the accepted source where no concurrent changes exist, PHP syntax on changed PHP files, Python AST on changed Python files, JSON/manifest parse, dependency lock identity, no conflict stages, whitespace/diff inspection, and source/target object hash verification. Do not rerun full suites, rebuild/install APP, start API/DB/AVD or RTC; those are not part of this integration task and already have their own acceptance evidence.
7. Update only necessary activity/status documents to record K09 integration and the accepted-with-observations state. Preserve existing historical prose; prepend a concise current status rather than rewriting the document. Do not change the frozen plan or acceptance record.
8. Commit using normal ancestry, publish only by ordinary non-force push, then independently read back remote main Commit/Tree and exact apps/services subtrees. If main moves before push, stop and rebase the task plan onto the new safe baseline without losing concurrent changes. No force, lease overwrite, reset, clean, prune or destructive branch/volume cleanup.
9. Final report should record accepted source identity, actual pre-integration main, final integration Commit/Tree, exact changed product paths, subtree identity comparison, static checks, preserved non-product docs, worktree/dirty-root protection, publication/readback and all NOT_RUN. Do not claim live runtime was re-tested.

## 4. Protected assets and prohibited actions

- Never modify or clean the original `D:/EliteSync-v10` dirty root, its index, untracked/ignored files, other worktrees, backups or historic evidence.
- No product code edits, scope expansion, new algorithm, new dependency, licence purchase, new public endpoint, production release, real user data export, historical SQL import, destructive DB/volume/media action, device-global SDK/JDK/Gradle changes, real phone operations, RTC, UAC/firewall changes or mailbox operations.
- Preserve the temporary review branch and its 42-file review package. Do not delete it in K09. Review object retention is separate from product integration; branch deletion requires a separately scoped, explicitly authorized cleanup task.
- Do not change accepted observations to PASS or remove historical failures because static integration checks succeed.

## 5. Frozen acceptance criteria K09-01..K09-07

- **K09-01 Source integrity:** all 21 path/blob identities verified against the accepted source; no unexpected product path.
- **K09-02 Main concurrency:** actual main baseline and ancestry recorded; all concurrent changes preserved; no force update.
- **K09-03 Product tree:** integrated apps/services equal the accepted subtrees, except only if a documented concurrent change must be retained; any deviation is itemized and cannot silently overwrite accepted behavior.
- **K09-04 Documentation protection:** frozen plan, acceptance record, historical reports and unrelated source files preserved; only minimal current status additions.
- **K09-05 Static verification:** PHP/Python/JSON/lock/object checks complete, all outcomes and failures retained.
- **K09-06 Local protection:** original dirty root and backups unchanged within the verifiable identity/status checks; do not overclaim full ignored/untracked byte verification when no pre-run manifest exists.
- **K09-07 Delivery:** one integration report with exact final commit/tree, ordinary push/readback and explicit NOT_RUN boundaries. Exit as `K09_INTEGRATION_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_INTEGRATION_ACCEPTANCE`; Codex cannot self-accept.

## 6. Task authorization and stop conditions

This is a frozen task order only. It has **not** been manually dispatched and does not itself authorize local writes, product integration or main updates beyond publishing this document.

After Owner manually dispatches this complete task to local Codex, the above bounded integration operations are authorized once. If accepted source identity mismatches, main has a relevant concurrent product change, protected paths are uncertain, or any unexpected write/asset is detected, stop only the affected integration path, preserve evidence and report. Do not improvise a destructive workaround.

K09 completion will require Astra's independent integration acceptance. No automatic next product version, K10, production release or review-branch cleanup follows.
