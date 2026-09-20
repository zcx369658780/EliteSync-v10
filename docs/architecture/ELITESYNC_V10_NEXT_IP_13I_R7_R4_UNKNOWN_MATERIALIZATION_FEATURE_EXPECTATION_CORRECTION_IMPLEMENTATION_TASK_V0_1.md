# EliteSync v10｜Next IP-13I-R7-R4 UNKNOWN Materialization Feature-Expectation Correction Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT TWO-PATH TEST-EXPECTATION CORRECTION ON R7-R3 CANDIDATE — ONE TARGETED FEATURE ATTEMPT — NO CONTROLLER/ROUTE CHANGE — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication main:
`e8468024f133eb3841af2fd6ed943b42f1c8a4ab`

R7-R3 targeted-failure root-cause review blob:
`29c5936fa7bde8d88b2d8f1d108057f3d7eb2e2b`

Frozen R7-R3 candidate:
`47d5d474e361d5c6694ecfc453734d7df855c8c9`

Frozen R7-R3 tree:
`c752807871d8365ce5cb0085f915da50608e6ae7`

## 1. Objective

Correct only the Feature-test expectation that incorrectly requires:

`materialized_projection_usable = true`

for the `UNKNOWN_PREREQUISITE_SET` scenario.

Do not change production behavior.

The accepted expected HTTP/domain behavior is:

### READY

- HTTP `200`
- `readiness_classification = READY`
- `materialized_projection_usable = true`
- `condition = EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

### NOT_READY

- HTTP `200`
- `readiness_classification = NOT_READY`
- `materialized_projection_usable = true`
- `condition = EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

### UNKNOWN from `UNKNOWN_PREREQUISITE_SET`

- HTTP `200`
- `readiness_classification = UNKNOWN`
- `materialized_projection_usable = false`
- `condition = RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`
- `reason_categories` contains the bounded unknown-prerequisite-set reason from the accepted R5 result.

This preserves:

`HTTP_STATUS != DOMAIN_OUTCOME`

`UNKNOWN != TRANSPORT_FAILURE`

`UNKNOWN != MATERIALIZED_USABLE`

`READY != STORAGE_SUCCESS`

## 2. Mandatory authority and topology gates

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this task.
4. Require `origin/main` to equal that task-publication commit exactly.
5. Read this task.
6. Read the R7-R3 targeted-failure independent root-cause review.
7. Do not merge/transplant R7-R3 candidate to main.
8. Create one isolated correction branch/worktree from exactly:
   `47d5d474e361d5c6694ecfc453734d7df855c8c9`
9. Verify:
   - HEAD = `47d5d474e361d5c6694ecfc453734d7df855c8c9`
   - sole parent = `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`
   - tree = `c752807871d8365ce5cb0085f915da50608e6ae7`
10. Verify all fixed blobs in Section 3.
11. Verify the new result path is absent.
12. Stop rather than adapt if any identity differs.

Recommended correction branch:

`review/next-ip-13i-r7-r4-unknown-materialization-feature-expectation-v0-1`

The correction candidate's sole parent must remain:

`47d5d474e361d5c6694ecfc453734d7df855c8c9`

## 3. Exact authorized read scope / fixed inputs

From task-publication main, read only:

1. `AGENTS.md`
2. this R7-R4 task
3. `docs/architecture/ELITESYNC_V10_IP_13I_R7_R3_TARGETED_FAILURE_INDEPENDENT_ROOT_CAUSE_REVIEW_V0_1.md`
4. accepted R6 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`

From exact R7-R3 candidate `47d5d474e361d5c6694ecfc453734d7df855c8c9`, read only:

5. `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`
6. `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`
7. `services/backend-laravel/routes/api.php`
8. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_REQUEST_STATE_VOCABULARY_CONTRACT_REPAIR_IMPLEMENTATION_RESULT_V0_1.md`
9. `services/backend-laravel/composer.json`
10. `services/backend-laravel/composer.lock`
11. `services/backend-laravel/phpunit.xml`

Expected blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R7-R3 root-cause review:
  `29c5936fa7bde8d88b2d8f1d108057f3d7eb2e2b`
- accepted R6 result:
  `5cffb288f4daba5e52e07fb84000ed8d1d5d994d`
- frozen controller:
  `3a74ae1da7a752de61c47f055c4fab1a8b900e4c`
- frozen Feature test:
  `feb20e1df1fc4a17db60f0adf1adf3e46ecf8c09`
- frozen route:
  `37c3cd0c193f412fef7c03526fdc1926ad8535b5`
- frozen R7-R3 result:
  `293dfa4cd94d5b894253bf38f74850f2621c5ae5`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`

No repository enumeration/search or unrelated source read is authorized.

## 4. Exact tracked write scope

Relative to R7-R3 candidate `47d5d474…`, exactly two tracked paths may change.

1. MODIFY:
   `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

2. CREATE:
   `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_UNKNOWN_MATERIALIZATION_FEATURE_EXPECTATION_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked path may change.

Controller must remain blob-identical:

`3a74ae1da7a752de61c47f055c4fab1a8b900e4c`

Route must remain blob-identical:

`37c3cd0c193f412fef7c03526fdc1926ad8535b5`

R7-R3 result must remain blob-identical:

`293dfa4cd94d5b894253bf38f74850f2621c5ae5`

## 5. Exact Feature-test correction

Modify the existing test:

`test_ready_not_ready_and_unknown_remain_domain_only_privacy_minimal_200_results`

Do not weaken the HTTP 200 or classification assertions.

The test must use classification-specific expected materialization:

### READY

Require:

- usable `true`
- condition `EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

### NOT_READY

Require:

- usable `true`
- condition `EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

### UNKNOWN

Require:

- usable `false`
- condition `RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`
- `reason_categories` contains exactly the existing bounded unknown-set reason expected from this fixture:
  `UNKNOWN_PREREQUISITE_SET`

Do not transform UNKNOWN into an error.

Do not change the request fixture to force materialization.

Do not change controller behavior.

## 6. Preserve all other Feature coverage

All other R7-R3 Feature obligations must remain intact, including:

- exact dedicated route;
- `secure.transport`;
- no v1 alias;
- no `auth:sanctum`;
- generic endpoint unchanged;
- IP-13F five families only;
- exact R5 request-state literals;
- legacy `KNOWN` / `UNKNOWN` fail closed as 400 / `INVALID_REQUEST_SCHEMA`;
- exact request allowlist;
- malformed/synthetic-boundary handling;
- sentinel privacy non-leakage;
- storage rejection degraded HTTP 200;
- unusable/missing/stale/superseded/incomparable/invalidated/binding/payload mismatch degraded HTTP 200;
- unexpected application failure 500;
- unrecognized mapping 500;
- insecure transport 426;
- header/query/IP/user-agent non-authority;
- single dispatch/no retry;
- input non-mutation;
- synthetic fixtures only.

Do not add a second test file.

## 7. Production-source freeze

Do not modify:

- Runtime Readiness controller;
- route;
- R5 adapter/evaluator;
- IP-13A/IP-13D/IP-13E/IP-13F;
- generic HTTP controller/test;
- middleware/providers/bootstrap/config;
- Composer manifests;
- migrations;
- client/provider/network;
- auth/session/token;
- legal/Safety;
- production/real-private-data surfaces.

This is a test-expectation correction, not a product behavior change.

## 8. Same-worktree vendor bootstrap

In the R7-R3-derived correction worktree, check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:

- Composer Case A;
- run no Composer command.

Otherwise run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Composer Case B.

No retry.
No update.
No scripts/plugins.

Manifest/lock must remain tracked/blob-identical.

## 9. Exact runtime command budget

Run exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

No retry.

Do NOT run:

- any other PHPUnit file;
- full suite;
- Unit tests;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP client/curl;
- database probe;
- provider/network;
- production;
- real/private-data operation.

After final authoring, run exactly one:

`git diff --check`

No other project runtime command is authorized.

## 10. Failure handling

If the one targeted PHPUnit attempt fails:

- do not rerun;
- do not broaden or weaken expectations after the run;
- no post-run production/test correction is authorized by R7-R4;
- publish the exact failure in the result document;
- classify `VERIFIED_FAIL / NOT ACCEPTABLE` or equivalent bounded failure.

If a failure demonstrates a new defect outside this exact expectation correction:

- STOP;
- record the exact new evidence;
- do not expand scope.

## 11. Result document

Create exactly:

`docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_UNKNOWN_MATERIALIZATION_FEATURE_EXPECTATION_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

Record:

- task-publication main;
- R7-R3 frozen base SHA/parent/tree;
- correction branch;
- candidate SHA / sole parent / tree / ahead-behind after publication;
- exact two-path diff;
- fixed input blobs;
- pre/post Feature-test blob;
- unchanged controller/route/R7-R3 result blobs;
- exact UNKNOWN expectation correction;
- confirmation no production behavior changed;
- Composer Case A/B receipt;
- exact one targeted PHPUnit receipt;
- tests/assertions/failures/errors;
- warnings/deprecations;
- manifest/lock identities;
- one `git diff --check` receipt;
- tracked/staged counts;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R7-R4 UNKNOWN MATERIALIZATION FEATURE EXPECTATION CORRECTED — READY/NOT_READY REMAIN EXACT-MATERIALIZED — UNKNOWN_PREREQUISITE_SET REMAINS HTTP 200 WITH UNKNOWN CLASSIFICATION AND UNUSABLE MATERIALIZATION — CONTROLLER/ROUTE/R5/IP-13F UNCHANGED — EXACT TWO-PATH SCOPE — TARGETED FEATURE PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
