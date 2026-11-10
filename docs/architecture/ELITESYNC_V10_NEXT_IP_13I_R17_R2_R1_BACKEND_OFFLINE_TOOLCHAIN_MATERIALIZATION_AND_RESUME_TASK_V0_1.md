# EliteSync v10｜Next IP-13I-R17-R2-R1 Backend Offline Toolchain Materialization and R17-R2 Resume Task｜v0.1

Status: `OWNER-AUTHORIZED — PRESERVE EXISTING ISOLATED-WORKTREE EDITS — OFFLINE COMPOSER MATERIALIZATION + RESUME TARGETED TEST + RESULT — NO NETWORK / NO PERSISTENCE / NO APPLICATION / NO HTTP`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Current task-publication base before this task commit:

`347449705f673badcd38611bb9cc65e75af70183`

Original frozen R17-R2 execution authority remains:

`347449705f673badcd38611bb9cc65e75af70183`

Existing implementation branch/worktree reported by the prior executor:

- branch: `impl/ip-13i-r17-r2-product-connection-duplicate-resolution-order-invariance-v0-1`
- worktree: `D:\EliteSync-v10-ip13i-r17-r2-order-invariance-v0-1`
- branch HEAD: `347449705f673badcd38611bb9cc65e75af70183`

Prior R17-R2 execution stopped with:

`BLOCKED_TOOLING_UNAVAILABLE — vendor/bin/phpunit ABSENT IN ISOLATED WORKTREE — NO TEST EXECUTION — NO CANDIDATE PUBLISHED`

The executor reported uncommitted edits only to the already-authorized evaluator and existing Unit test. This task exists to preserve and resume that work without silently installing from the network or discarding local edits.

## 1. Objective

Complete the previously authorized R17-R2 engineering delivery in the same isolated worktree, if and only if the exact local state still matches the reported stop state.

This task authorizes one additional narrow tooling step before resuming R17-R2:

- materialize the backend Composer `vendor/` tree from the checked-in lock file using local Composer cache only;
- network must remain disabled;
- Composer scripts/plugins must remain disabled;
- then run the exact existing R17-R2 targeted PHPUnit command;
- repair only the two already-authorized source/test paths if the targeted test fails due to the authorized change;
- create the existing R17-R2 result document and publish one immutable candidate.

This task does not change the accepted Option A domain policy.

## 2. Fresh remote and in-flight continuation gate

Before local work:

1. Read `AGENTS.md` FIRST from the task-publication authority supplied by the execution prompt.
2. Fresh-fetch `origin/main`.
3. Require `origin/main` to equal the exact task-publication commit from the execution prompt.
4. Read this task from that exact commit and verify its blob.
5. Treat the new task-publication commit as an explicitly allowed unrelated document-only main movement.
6. Do NOT rebase or recreate the existing R17-R2 branch merely to follow this task commit.
7. The eventual R17-R2 candidate, if published, must still have sole parent:
   `347449705f673badcd38611bb9cc65e75af70183`.
8. Independent review must later compare the candidate to frozen authority `347449705...` and inspect current-main movement separately.

Any other main movement or any change to fixed source blobs stops execution.

## 3. Exact local preservation gate

Operate only in:

`D:\EliteSync-v10-ip13i-r17-r2-order-invariance-v0-1`

Require:

- current branch exactly `impl/ip-13i-r17-r2-product-connection-duplicate-resolution-order-invariance-v0-1`;
- branch HEAD exactly `347449705f673badcd38611bb9cc65e75af70183`.

Do not run whole-repository `git status`.

Authorized local Git inspection is limited to these exact paths:

1. `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
2. `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_RESULT_V0_1.md`
4. `services/backend-laravel/composer.json`
5. `services/backend-laravel/composer.lock`
6. `services/backend-laravel/phpunit.xml`
7. `services/backend-laravel/.gitignore`

Allowed path-scoped commands:

`git status --short -- <the exact seven paths above>`

and, as needed:

`git diff -- <the exact two source/test paths>`

`git diff --exit-code -- services/backend-laravel/composer.json services/backend-laravel/composer.lock services/backend-laravel/phpunit.xml services/backend-laravel/.gitignore`

Require before tooling recovery:

- evaluator and existing Unit test may be modified;
- result document may be absent/untracked only;
- composer.json, composer.lock, phpunit.xml and .gitignore must be unchanged from HEAD;
- no authorized path may be staged;
- do not inspect or modify any unrelated local path.

If the evaluator/test edits are absent, unexpectedly staged, or any support file differs, STOP rather than reconstructing or discarding work.

No reset, checkout, restore, clean, stash, pull, merge, rebase, index-wide operation or whole-worktree cleanup is authorized.

## 4. Fixed repository objects

At frozen authority `347449705...`, verify exactly:

- `AGENTS.md`:
  `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- R17-R2 task:
  `6fdab387859bb5fba13ab5f55e413c47c5fc0aed`
- accepted R17-R1 result:
  `3918eac68121c6d3a7601ac703e5b1663fe9c054`
- R17-R1 acceptance:
  `cb44607f773705c168f15ca093935be1893259b7`
- evaluator:
  `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- evaluator Unit test:
  `dc408a781d58ddf5c52f6cb0a140e642d3c30775`
- `services/backend-laravel/composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `services/backend-laravel/composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`
- `services/backend-laravel/phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`
- `services/backend-laravel/.gitignore`:
  `c7cf1fa675f65701fc1118ad21257badc7899c46`

Relevant fixed dependency facts:

- `composer.json` requires `phpunit/phpunit ^11.0.1` in `require-dev`;
- `phpunit.xml` bootstraps `vendor/autoload.php`;
- `/vendor` is ignored by backend `.gitignore`.

Do not edit any of the four dependency/config files.

## 5. Tooling preflight

From:

`D:\EliteSync-v10-ip13i-r17-r2-order-invariance-v0-1\services\backend-laravel`

run only:

1. `php -v`
2. `composer --version`

These are environment-observation commands only.

If PHP or Composer is unavailable, STOP and report exact output.

Do not search PATH, registries, caches, user directories or alternate installations manually.

## 6. Offline Composer materialization

Only if `vendor/bin/phpunit` is still absent after the preservation gate, authorize exactly one Composer install attempt:

Git Bash:

`COMPOSER_DISABLE_NETWORK=1 composer install --no-interaction --prefer-dist --no-progress --no-scripts --no-plugins`

Purpose:

- consume the exact checked-in `composer.lock`;
- use only packages already available through the local Composer cache;
- materialize ignored `vendor/` inside this isolated worktree;
- create the autoloader needed by the existing `phpunit.xml`.

Network access is explicitly NOT authorized.

Do not remove `COMPOSER_DISABLE_NETWORK=1`.
Do not use `composer update`.
Do not alter the lock file.
Do not run Composer scripts/plugins.
Do not run Composer audit.
Do not change package versions.
Do not copy `vendor/` from another worktree.
Do not inspect Composer cache manually.

Composer install attempt budget: exactly 1.

If offline Composer reports a missing package/archive/cache entry or otherwise cannot complete, STOP. Record the exact first actionable missing dependency/error from Composer output. Do not retry, enable network, change preferred-install mode, use source checkout, or repair Composer configuration.

If it succeeds, verify only that:

- `vendor/autoload.php` exists;
- `vendor/bin/phpunit` exists.

No broader vendor inventory is authorized.

## 7. Resume original R17-R2 implementation scope

After successful tooling materialization, continue the existing uncommitted evaluator/test changes under the original R17-R2 contract.

The accepted Option A algorithm and all R17-R2 functional/test requirements remain unchanged.

Authorized tracked write set remains exactly:

1. modify `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`;
2. modify `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`;
3. create `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_RESULT_V0_1.md`.

Do not modify Composer/config files or any other tracked path.

## 8. Targeted PHPUnit command and fresh budget

After `vendor/bin/phpunit` exists, run exactly:

`vendor/bin/phpunit tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`

For this resumed task, PHPUnit process attempt budget is:

- initial real PHPUnit run: at most 1;
- if it fails due to the authorized evaluator/test change, at most 2 correction reruns;
- total real PHPUnit process executions: maximum 3.

The prior shell failure:

`/usr/bin/bash: line 1: vendor/bin/phpunit: No such file or directory`

does not count as a PHPUnit process execution, but must be recorded in the final result as the reason R17-R2 originally stopped.

Do not run any other PHPUnit/test command.

Do not run Composer again after the single offline materialization attempt.

## 9. Runtime prohibitions

Except Sections 5, 6 and 8, do not run:

- Composer commands;
- arbitrary PHP scripts;
- Artisan;
- server/HTTP;
- database;
- migrations/generators;
- code formatters;
- static-analysis suites;
- coverage;
- package installation/update;
- network downloads;
- Flutter/Dart/Gradle/Java/Android;
- production or real/private-data operations.

No network authority is created by this task.

## 10. Publication rule

If tooling materialization succeeds and targeted tests pass:

1. create the exact R17-R2 result document;
2. ensure only the two tracked source/test files plus result document differ from frozen authority;
3. stage/commit only those exact three paths;
4. publish one immutable candidate on the existing implementation branch;
5. candidate sole parent must remain `347449705f673badcd38611bb9cc65e75af70183`;
6. remote branch must point exactly to that candidate.

The ignored `vendor/` directory must not be staged or committed.

If Composer/tooling remains blocked or PHPUnit never actually runs, do NOT publish an implementation candidate.

## 11. Result document additions

In addition to original R17-R2 result requirements, record:

- prior blocked classification and exact missing-phpunit shell evidence;
- current task-publication commit/blob;
- confirmation that existing isolated worktree edits were preserved rather than recreated;
- `php -v` and `composer --version` outputs;
- whether offline Composer materialization ran;
- exact Composer command;
- Composer attempt count and success/failure;
- explicit confirmation `COMPOSER_DISABLE_NETWORK=1`;
- whether `vendor/autoload.php` and `vendor/bin/phpunit` became available;
- real PHPUnit process execution count;
- exact test result;
- confirmation composer.json/lock/phpunit.xml/.gitignore remained unchanged;
- confirmation ignored vendor was not committed.

Successful final classification remains:

`IP-13I-R17-R2 IMPLEMENTATION COMPLETE — OPTION-A MAXIMAL-REVISION DUPLICATE RESOLUTION IMPLEMENTED — STATE + TRANSITION PERMUTATION REGRESSION COVERAGE ESTABLISHED — EXISTING EVALUATOR CONTRACT REGRESSION PASSES — OFFLINE LOCKED TOOLCHAIN MATERIALIZED WITHOUT NETWORK — READY FOR FRESH INDEPENDENT REVIEW BEFORE MAPPING RE-REVIEW`

Then STOP.

## 12. Independent review requirement

Candidate author cannot self-accept.

A fresh independent reviewer must:

- fresh-fetch current main;
- treat this task-publication commit as unrelated document-only movement after the frozen R17-R2 base;
- compare the candidate against frozen authority `347449705...`;
- verify exactly the three tracked candidate paths;
- inspect evaluator/test diff and the tooling/test receipt;
- ACCEPT or REJECT;
- integrate only after acceptance.

No fresh mapping review, R18, persistence/application/HTTP or Messaging task may be authored before R17-R2 acceptance.
