# EliteSync v10｜Next IP-13I-R7-V1 Immutable Candidate Verification Task｜v0.1

Status: `OWNER-AUTHORIZED — VERIFICATION ONLY — EXACT FROZEN R7 CANDIDATE — ONE TARGETED FEATURE ATTEMPT — NO CODE/TEST CORRECTION — ONE RESULT DOCUMENT — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Pre-task main: `d8814d0831fd30e95806282702581278e6320e7c`

R7 task-publication commit: `bec14f195e0000f02443f13c45fa50fbff72360e`

R7 immutable candidate: `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

Reported candidate sole parent: `bec14f195e0000f02443f13c45fa50fbff72360e`

Reported candidate tree: `1079877dc5bba0813ccdd8a5d5c888de3b51a431`

R7 implementation result blob: `d596c0e1758c34b2697b59f15302a89bf4563e27`

R7 independent static review blob: `516b334626f62376cae1ad05e93f199b5fda1407`

## 1. Objective

Verify, without modifying, the exact final immutable R7 candidate after its permitted post-run static corrections.

Run exactly one targeted Feature attempt against the frozen candidate:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

This task does not authorize implementation, correction, refactoring, test edits, route edits, result edits on the candidate, or any successor work.

Possible verification outcomes are only:

- `VERIFIED_PASS`
- `VERIFIED_FAIL`
- `VERIFICATION_BLOCKED`

A pass does not self-accept or integrate the candidate. Fresh independent acceptance is still required.

## 2. Mandatory fresh-main gate

Before candidate verification:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this verification task.
4. Require `origin/main` to equal that verification-task publication commit exactly.
5. Read this verification task.
6. Read the R7 independent static review.
7. Do not move main.
8. Do not merge/cherry-pick/transplant the R7 candidate.

Stop if the main authority gate differs.

## 3. Exact authorized read scope

From the verification-task main lineage, read only:

1. `AGENTS.md`
2. this task
3. `docs/architecture/ELITESYNC_V10_IP_13I_R7_IMMUTABLE_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

From exact candidate `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`, read/verify only:

4. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_RESULT_V0_1.md`
5. `services/backend-laravel/routes/api.php`
6. `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`
7. `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`
8. `services/backend-laravel/composer.json`
9. `services/backend-laravel/composer.lock`
10. `services/backend-laravel/phpunit.xml`

No repository search/discovery or unrelated source read is authorized.

## 4. Frozen candidate identity gate

Before Composer/PHPUnit, independently prove locally:

- HEAD = `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`;
- sole parent = `bec14f195e0000f02443f13c45fa50fbff72360e`;
- tree = `1079877dc5bba0813ccdd8a5d5c888de3b51a431`.

Verify exact candidate blobs:

- routes:
  `37c3cd0c193f412fef7c03526fdc1926ad8535b5`
- controller:
  `95272cf7d63cf8cdf3db29eaf41c4c3450836f16`
- targeted Feature test:
  `2f885b61519225604c27e9fb0ed7c7b25f138612`
- implementation result:
  `d596c0e1758c34b2697b59f15302a89bf4563e27`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`

If any identity differs, classify `VERIFICATION_BLOCKED` and do not run PHPUnit.

## 5. Worktree topology

Use two isolated work areas if needed:

### A. Candidate verification worktree

Create/use an isolated detached worktree pinned exactly at:

`cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

Do not create a commit from this candidate worktree.
Do not modify any tracked candidate file.

### B. Verification-result branch/worktree

Create one review branch from the verification-task publication commit, recommended:

`review/next-ip-13i-r7-v1-immutable-candidate-verification-v0-1`

This branch may create exactly one verification result document from Section 10.

The verification result branch must not contain the R7 implementation files.

## 6. Same-worktree vendor bootstrap

Inside the detached candidate worktree, check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:

- Composer Case A;
- run no Composer command.

If either is absent, run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

This is Composer Case B.

No retry.
No update.
No scripts/plugins.

After Composer, `composer.json` and `composer.lock` must still resolve to their fixed tracked blobs.

Untracked/ignored vendor material does not authorize any tracked change.

## 7. Exact runtime budget

Run exactly one PHPUnit command from the detached candidate worktree:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

No retry under any outcome.

Do not run:

- any other PHPUnit file;
- full suite;
- Unit tests;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- curl/HTTP client;
- provider/network;
- production;
- real/private-data operations.

Do not run `git diff --check` as a substitute for runtime verification; R7 already consumed its authoring check.

## 8. Absolutely no correction

After the one PHPUnit attempt:

- do not edit routes;
- do not edit controller;
- do not edit Feature test;
- do not edit R7 implementation result;
- do not edit Composer manifests;
- do not make any static correction;
- do not rerun PHPUnit.

If the attempt fails for any reason, classify `VERIFIED_FAIL` and record the exact failure.

If setup/runtime cannot start without changing tracked source, classify `VERIFICATION_BLOCKED`.

## 9. Post-run immutability checks

After the attempt, verify:

- candidate HEAD still equals `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`;
- candidate tree identity remains `1079877dc5bba0813ccdd8a5d5c888de3b51a431`;
- tracked diff path count = 0;
- staged diff path count = 0;
- the four candidate blobs remain exact.

These exact Git metadata checks are authorized for this verification task.

Do not use an unrestricted whole-repository audit to establish them.

## 10. Exact write scope

On the verification-result branch only, create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R7_V1_IMMUTABLE_CANDIDATE_VERIFICATION_RESULT_V0_1.md`

No other tracked write is authorized.

The result must record:

- verification-task publication commit;
- verification result branch/candidate commit/sole parent/tree after publication;
- frozen R7 candidate SHA/parent/tree;
- all frozen candidate blobs;
- Composer Case A/B and exact receipt;
- exactly one targeted PHPUnit command;
- exit code;
- tests/assertions;
- failures/errors;
- warnings/deprecations;
- exact failing test/assertion text if failed, bounded without dumping private fixture payload;
- post-run HEAD/tree/blob identities;
- tracked/staged path counts;
- no-correction/no-retry confirmation;
- final outcome `VERIFIED_PASS | VERIFIED_FAIL | VERIFICATION_BLOCKED`;
- fresh independent ACCEPT/REJECT requirement.

## 11. Pass criteria

Classify `VERIFIED_PASS` only if all are true:

- exact frozen candidate identity gate passes;
- Composer Case A or successful single Case B completes without manifest/lock drift;
- exactly one targeted PHPUnit attempt runs;
- exit = `0`;
- failures = `0`;
- errors = `0`;
- final candidate HEAD/tree/blobs remain unchanged;
- tracked/staged path counts remain `0 / 0`;
- no correction/retry occurred.

Warnings/deprecations must be recorded exactly. Their presence alone does not authorize a second run or correction.

Expected pass classification:

`IP-13I-R7-V1 VERIFIED_PASS — EXACT IMMUTABLE R7 CANDIDATE POST-FIX TARGETED FEATURE PASS ESTABLISHED — FROZEN FOUR-PATH BLOBS UNCHANGED — NO CORRECTION/RETRY — READY FOR FRESH INDEPENDENT ACCEPT/REJECT`

## 12. Fail/block classifications

On test failure:

`IP-13I-R7-V1 VERIFIED_FAIL — EXACT IMMUTABLE R7 CANDIDATE TARGETED FEATURE FAILURE ESTABLISHED — NO CORRECTION/RETRY — READY FOR FRESH OWNER/INDEPENDENT REVIEW`

On setup/identity blocker:

`IP-13I-R7-V1 VERIFICATION_BLOCKED — EXACT BLOCKER RECORDED — FROZEN R7 CANDIDATE NOT MODIFIED — READY FOR FRESH OWNER/INDEPENDENT REVIEW`

Then STOP.
