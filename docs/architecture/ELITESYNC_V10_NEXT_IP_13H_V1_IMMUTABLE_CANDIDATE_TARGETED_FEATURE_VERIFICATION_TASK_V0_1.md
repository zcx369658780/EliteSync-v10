# EliteSync v10｜Next IP-13H-V1 Immutable Candidate Targeted Feature Verification Task｜v0.1

Status: `OWNER-AUTHORIZED — VERIFICATION ONLY — IMMUTABLE CANDIDATE — NO AUTHORING / NO RETRY / FRESH INDEPENDENT CLOSEOUT REQUIRED`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Verification target candidate: `8820d2cb4050b231449248ff7beba56647be0c51`

Expected candidate sole parent: `b8b453e41ff30479a5da9ad7f37ddcf2208eae07`

Expected candidate tree: `abe5ddec140baff0ded2e26fb79b1c67ef16c34d`

Expected final blobs:

- routes/api.php: `199a0a08a9474d0bbaeb4edc5f8f20534f269c01`
- controller: `e9a202533748e37c0d6199cc2219e9127a7965d6`
- test: `60434c0a70f7a768496e30dd937cfca4c15411b0`
- result: `a1620f2003eda0e9d615d3a9ad70e13c80a6d4a8`

## Objective

Establish runtime evidence for the final statically corrected immutable IP-13H candidate only.

The original IP-13H task authorized exactly one targeted Feature PHPUnit attempt. That attempt exited `1` with two failures caused by Laravel route-level controller instance caching after test-only container rebinding. The final immutable test blob statically corrected only the test harness by flushing the cached controller through Laravel's public `Route::flushController()` after each permitted test-only IP-13F instance binding.

No production route/controller/source behavior changed for that correction.

This task authorizes exactly one fresh targeted verification attempt against the frozen candidate and forbids all authoring.

## Mandatory gates

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main` and confirm this verification task exists on current main.
3. Fetch candidate `8820d2cb4050b231449248ff7beba56647be0c51`.
4. Verify sole parent, tree, and all four expected final blobs exactly.
5. Use an isolated worktree with HEAD exactly at the immutable candidate.
6. Verify tracked/staged changes are zero before execution.
7. Verify the final test blob contains the test-only `Route::flushController()` correction.
8. Stop rather than adapt if any identity differs.

## Vendor bootstrap

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist: Composer Case A, do not run Composer.

Otherwise exactly one Composer attempt from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## Exact runtime verification budget

Run exactly once:

`vendor/bin/phpunit tests/Feature/Api/V2/TransportEnvelopeTest.php`

No retry.

Do not run:

- any other PHPUnit command;
- full suite;
- other Feature tests;
- Unit tests;
- coverage;
- mutation tests;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server/provider/network commands;
- client work;
- production work;
- real/private-data processing;
- legal/Safety operations.

Do not run `git diff --check`; this verification performs no authoring.

Do not modify any tracked file.

## Required verification receipt

Return:

- verification task-publication commit;
- candidate SHA / sole parent / tree;
- confirmed four final blobs;
- worktree HEAD;
- explicit confirmation final test blob contains test-only `Route::flushController()`;
- Composer Case A/B and exact receipt if run;
- targeted Feature PHPUnit attempt count;
- exit code;
- tests/assertions/failures;
- warnings/deprecations;
- tracked/staged changes after verification;
- manifest/lock pre/post identities if Composer ran;
- explicit statement that no prohibited command/action ran.

If the targeted Feature attempt exits `0` with all targeted tests passing, classify exactly:

`IP-13H-V1 IMMUTABLE CANDIDATE TARGETED FEATURE VERIFICATION PASS — FINAL STATICALLY CORRECTED IP-13H TEST BLOB RUNTIME PASS ESTABLISHED — CANDIDATE READY FOR FRESH INDEPENDENT ACCEPT/REJECT CLOSEOUT`

Otherwise report the exact failure and STOP.

Do not commit, amend, rebase, merge, push candidate changes, move `main`, or start a successor.
