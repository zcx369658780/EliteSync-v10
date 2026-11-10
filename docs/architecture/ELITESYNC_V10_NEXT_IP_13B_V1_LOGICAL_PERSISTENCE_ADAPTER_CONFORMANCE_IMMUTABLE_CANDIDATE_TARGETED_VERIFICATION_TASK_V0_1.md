# EliteSync v10｜Next IP-13B-V1 Logical Persistence Adapter Conformance Immutable Candidate Targeted Verification Task｜v0.1

Status: `OWNER-AUTHORIZED — VERIFICATION ONLY — IMMUTABLE CANDIDATE — NO AUTHORING / NO RETRY / FRESH INDEPENDENT CLOSEOUT REQUIRED`

Date: 2026-09-17 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Verification target candidate: `9fab1acd3251d5808662e8358521160a4f5608f2`

Expected candidate sole parent: `d9e4ec5aa26332b0adeec6f74c41f9cd9ac45e48`

Expected candidate tree: `c3148576f56eb53e03ee4057c5c6d6dbcd985df2`

Expected blobs:

- source: `70ef19db69ebc7304b292dbad72675c9ee66f2d8`
- test: `71d7db2507b3f8579533aaa80d967f7b351c4acd`
- result: `bf33dc1e3ee59280e80e7691a23deb69ffee40aa`

## Objective

Establish runtime evidence for the final statically corrected immutable IP-13B candidate only.

The original implementation task allowed exactly one targeted PHPUnit attempt. That attempt exited `1` before a narrow static correction to candidate-shape classification. The correction was intentionally not rerun under the original no-retry rule. This verification task therefore authorizes one fresh targeted verification attempt against the frozen candidate blobs without modifying them.

No implementation, diagnosis-driven authoring, repair, amendment, rebase, merge, promotion, or successor work is authorized.

## Mandatory gates

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main` and confirm this verification task exists on current main.
3. Fetch candidate `9fab1acd3251d5808662e8358521160a4f5608f2`.
4. Verify sole parent, tree, and all three expected blobs exactly.
5. Use an isolated worktree with HEAD exactly at the immutable candidate.
6. Verify tracked/staged changes are zero before execution.
7. Stop rather than adapt if any identity differs.

## Vendor bootstrap

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, Composer Case A: do not run Composer.

Otherwise exactly one Composer attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry, no update, no scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## Exact runtime verification budget

Run exactly once:

`vendor/bin/phpunit tests/Unit/LogicalPersistenceAdapterConformanceContractTest.php`

No retry.

Do not run any other PHPUnit command, full suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, runtime/provider/network commands, client work, real/private-data processing, legal/Safety work, or production operations.

Do not run `git diff --check`; no authoring is occurring.

Do not modify any tracked file.

## Required receipt

Return:

- verification task-publication commit;
- candidate SHA / sole parent / tree;
- confirmed source/test/result blobs;
- worktree HEAD;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit attempt count, exit code, test/assertion counts, warnings/deprecations;
- tracked/staged changes after verification;
- manifest/lock identities if Composer ran;
- explicit statement that no prohibited command/action ran.

If the targeted PHPUnit attempt exits `0` with all targeted tests passing, classify exactly:

`IP-13B-V1 IMMUTABLE CANDIDATE TARGETED VERIFICATION PASS — FINAL CORRECTED IP-13B SOURCE/TEST BLOBS RUNTIME PASS ESTABLISHED — CANDIDATE READY FOR FRESH INDEPENDENT ACCEPT/REJECT CLOSEOUT`

Otherwise report the exact failure and STOP.

Do not commit, amend, rebase, merge, push candidate changes, move `main`, or start IP-13C.
