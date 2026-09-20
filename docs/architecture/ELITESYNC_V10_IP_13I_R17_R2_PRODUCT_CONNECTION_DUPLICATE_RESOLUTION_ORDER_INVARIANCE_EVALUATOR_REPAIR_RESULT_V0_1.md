# EliteSync v10｜IP-13I-R17-R2 Product Connection Duplicate-Resolution Order-Invariance Evaluator Repair Result｜v0.1

Status: `IMPLEMENTATION COMPLETE — TARGETED TEST PASS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority, continuation and publication

- original frozen R17-R2 execution authority: `347449705f673badcd38611bb9cc65e75af70183`;
- original R17-R2 task blob: `6fdab387859bb5fba13ab5f55e413c47c5fc0aed`;
- R17-R2-R1 resume task-publication commit: `be075f2d806276df1969cd3b38613da69d0bb65e`;
- R17-R2-R1 resume task blob: `1e583aa508404b0f815215e91f12be098d6622c8`;
- branch: `impl/ip-13i-r17-r2-product-connection-duplicate-resolution-order-invariance-v0-1`;
- candidate: `THIS_COMMIT`, fixed by the immutable publication receipt returned with this result;
- sole parent: `347449705f673badcd38611bb9cc65e75af70183`;
- candidate tree: fixed by the immutable publication receipt returned with this result.

The existing isolated worktree `D:\EliteSync-v10-ip13i-r17-r2-order-invariance-v0-1` and its uncommitted evaluator/test edits were preserved and resumed. They were not reset, restored, stashed, recreated, rebased or adapted to current main. The move of current main to the resume-task publication commit was consumed only as the explicitly authorized document-only in-flight exception.

## 2. Exact tracked scope and blobs

The candidate contains exactly:

1. modified `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`;
2. modified `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`;
3. new `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_RESULT_V0_1.md`.

Blob ledger:

- evaluator before: `35a889ee5460e5c374a5a99bd93bebae49718c5b`;
- evaluator after: `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`;
- evaluator test before: `dc408a781d58ddf5c52f6cb0a140e642d3c30775`;
- evaluator test after: `c68f82adf44af65ca80e51d7fc73bf1522b81980`;
- this result blob: fixed by the immutable publication receipt returned with this result;
- accepted R17-R1 result: `3918eac68121c6d3a7601ac703e5b1663fe9c054`;
- R17-R1 acceptance: `cb44607f773705c168f15ca093935be1893259b7`.

`composer.json`, `composer.lock`, `phpunit.xml` and backend `.gitignore` remained unchanged. Ignored `vendor/` was not staged or committed.

## 3. Implemented Option A algorithm

The shared private duplicate resolver now evaluates each structurally valid non-empty evidence multiset as follows:

1. validate one common evidence identity across the full set, preserving the existing identity-conflict reason;
2. verify every source revision is comparable with the common source-local namespace, preserving the existing incomparable reason;
3. compute the mathematical maximal comparable source-local revision independently of input order;
4. collect every candidate at that maximal revision;
5. compare only the existing complete semantic signatures of those maximal candidates;
6. return the existing equal-revision conflict reason when maximal signatures differ;
7. otherwise return one maximal candidate carrying the common maximal semantic signature.

Strictly older comparable candidates remain input history but do not participate in the current equal-revision semantic-conflict decision. The implementation adds no reason, global revision, LWW, timestamp, sorting authority, representative-index authority, state mutation, permission or source authority.

The caller sequence remains unchanged: empty evidence, cross-Connection checks and participant checks still precede duplicate resolution; usability, current-context, target-state, terminal and allowed-transition checks still follow it. Their existing precedence and reason vocabulary remain unchanged.

## 4. State and transition permutation coverage

The existing evaluator Unit test was extended in place with reusable permutation helpers and regressions for:

- the original state R17-F1 multiset across all 6 permutations;
- the corresponding state shape where the unique higher revision matches the other lower semantic variant;
- identical maximal state ties;
- conflicting maximal state ties with no current dependency;
- the retained equal-revision state conflict without a higher candidate;
- a four-item comparable state chain across all 24 permutations;
- incomparable state namespaces and different state evidence identities in both orders;
- newer unusable state evidence controlling selection before the existing usability failure;
- the direct transition analogue of R17-F1 across all 6 permutations;
- maximal transition ties differing in expected-state revision;
- maximal transition ties differing in from/to semantics;
- dominated lower transition differences in expected revision/from/to across all 24 permutations;
- incomparable transition namespaces and different transition identities in both orders;
- all pre-existing evaluator contract regressions in the same test file.

Every permutation assertion compares the complete evaluator result, so dependency vectors, classification, states, reasons and bounded authority flags must also be order invariant.

## 5. Tooling recovery receipt

Prior R17-R2 stopped as:

`BLOCKED_TOOLING_UNAVAILABLE — vendor/bin/phpunit ABSENT IN ISOLATED WORKTREE — NO TEST EXECUTION — NO CANDIDATE PUBLISHED`

The preserved shell evidence was:

`/usr/bin/bash: line 1: vendor/bin/phpunit: No such file or directory`

Current preflight:

- `php -v`: `PHP 8.5.3 (cli) (built: Feb 10 2026 18:43:53) (NTS Visual C++ 2022 x64)` with Zend Engine v4.5.3 and OPcache v8.5.3;
- `composer --version`: `Composer version 2.9.5 2026-01-29 11:40:53`, using PHP 8.5.3 at `C:\tools\php85\php.exe`.

Because `vendor/bin/phpunit` was absent, exactly one offline materialization attempt ran:

`COMPOSER_DISABLE_NETWORK=1 composer install --no-interaction --prefer-dist --no-progress --no-scripts --no-plugins`

Receipt:

- Composer attempt count: `1`;
- result: success, `114 installs, 0 updates, 0 removals` from the locked dependency set;
- network explicitly disabled through `COMPOSER_DISABLE_NETWORK=1`;
- Composer scripts and plugins disabled;
- `vendor/autoload.php`: present after materialization;
- `vendor/bin/phpunit`: present after materialization;
- no Composer retry, update, audit, cache inspection, source checkout, lock/config edit or network download was performed.

## 6. Targeted PHPUnit receipt

Exact command, from `services/backend-laravel`:

`vendor/bin/phpunit tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`

- real PHPUnit process execution count in the resumed task: `1`;
- PHPUnit: `11.5.55`;
- runtime: PHP `8.5.3`;
- tests: `53`;
- assertions: `261`;
- failures: `0`;
- errors: `0`;
- skips: `0`;
- PHPUnit deprecations reported: `2`;
- result: `OK, but there were issues!` solely because of the reported deprecations; the targeted suite passed completely;
- elapsed time: `00:00.018`;
- memory: `12.00 MB`.

No second PHPUnit execution was made after the passing first run.

## 7. Boundaries and disposition

No Common Authority, persistence, application, route/controller, HTTP, client/Flutter, roadmap, CURRENT_CONTEXT, AGENTS, Composer/config or downstream domain file was modified. No Artisan, server/HTTP, database, migration/generator, formatter, static analysis, coverage, Flutter/Dart/Gradle/Java/Android, production or real/private-data operation ran.

R17 remains rejected. This candidate does not author or accept a fresh mapping review, R18, persistence/application/HTTP implementation, or Messaging/Conversation work.

The candidate author has performed only the authorized implementation and self-check. A fresh independent reviewer must compare this immutable candidate to frozen authority `347449705f673badcd38611bb9cc65e75af70183` and issue one ACCEPT/REJECT before any mapping re-review.

## 8. Final classification

`IP-13I-R17-R2 IMPLEMENTATION COMPLETE — OPTION-A MAXIMAL-REVISION DUPLICATE RESOLUTION IMPLEMENTED — STATE + TRANSITION PERMUTATION REGRESSION COVERAGE ESTABLISHED — EXISTING EVALUATOR CONTRACT REGRESSION PASSES — OFFLINE LOCKED TOOLCHAIN MATERIALIZED WITHOUT NETWORK — READY FOR FRESH INDEPENDENT REVIEW BEFORE MAPPING RE-REVIEW`
