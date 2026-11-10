# EliteSync v10｜Next IP-12G-V1 Core-Domain Semantic Integration Harness Immutable-Candidate Targeted Verification Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED VERIFICATION TASK — IMMUTABLE CANDIDATE ONLY — NO SOURCE/TEST EDITS AUTHORIZED`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Candidate under review: `3dadf62b31327867360abaa0b086556ca198ee72`

Candidate sole parent / original task base: `f12269e5cb6020b23f8c22aa21d66eb4a2bb22e6`

## 1. Objective

Establish or fail to establish runtime PASS for the already-published immutable IP-12G candidate after its author made one narrow static correction to the targeted test following the sole authorized failing PHPUnit attempt.

This task is verification-only. It does not authorize any source, test, result-document, manifest, lockfile, dependency, configuration, or other tracked-file modification.

## 2. Immutable candidate gate

Before any project command:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main` and record current task-publication authority.
3. Fetch candidate `3dadf62b31327867360abaa0b086556ca198ee72`.
4. Verify its sole parent is exactly `f12269e5cb6020b23f8c22aa21d66eb4a2bb22e6`.
5. Verify exact candidate tracked scope remains exactly:
   - `services/backend-laravel/app/Domain/CoreDomainSemanticIntegrationHarness.php`
   - `services/backend-laravel/tests/Unit/CoreDomainSemanticIntegrationHarnessTest.php`
   - `docs/architecture/ELITESYNC_V10_BACKEND_CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_IMPLEMENTATION_RESULT_V0_1.md`
6. Verify the final candidate blobs are exactly:
   - Harness: `3ca0e5cd5bec86b44173212ec0099a281ddb6775`
   - Test: `350b5a8d6519776a1eab41651b799af178fa813e`
   - Result: `26997f3b2fd5241a70851b9a8617141b20838acc`
7. Create or reuse an isolated worktree whose HEAD is exactly the immutable candidate commit.
8. Verify tracked and staged changes are zero before running anything.

If any identity differs, STOP without adaptation.

## 3. Vendor readiness

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

If either is absent, exactly one Composer bootstrap is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## 4. Exact verification command budget

Run exactly one targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/CoreDomainSemanticIntegrationHarnessTest.php`

No retry.

No other PHPUnit command, filter, full suite, Feature test, coverage, mutation test, Artisan, runtime, migration, generator, cache, provider, network, persistence, endpoint, client, production, real/private-data, legal, or Safety operation is authorized.

After the targeted command, run exactly one read-only working-tree status check sufficient to prove no tracked/staged modification occurred. Do not run `git diff --check`; the immutable candidate already has the original final-authoring receipt and this task performs no authoring.

## 5. Decision rule

If and only if the immutable final candidate returns exit `0` with all targeted tests passing and no unexpected warnings/errors that undermine the semantic proof, classify:

`IP-12G-V1 IMMUTABLE CANDIDATE TARGETED VERIFICATION PASS — FINAL CORRECTED IP-12G TEST BLOB RUNTIME PASS ESTABLISHED — CANDIDATE READY FOR FRESH INDEPENDENT ACCEPT/REJECT CLOSEOUT`

If exit is non-zero, classify truthfully as verification failure and report the exact failure without edits or retry.

## 6. Required report

Return in chat only:

- task-publication commit
- candidate SHA / sole parent / tree
- confirmed three blobs
- worktree HEAD
- Composer Case A/B and receipt if run
- exact targeted PHPUnit attempt count, exit, test/assertion summary, warnings/deprecations
- tracked/staged change counts after verification
- manifest/lock pre/post identities if Composer ran
- final classification

Do not create a tracked result document, commit, amend, rebase, merge, push candidate changes, or move `main`.

Then STOP for fresh independent closeout review.