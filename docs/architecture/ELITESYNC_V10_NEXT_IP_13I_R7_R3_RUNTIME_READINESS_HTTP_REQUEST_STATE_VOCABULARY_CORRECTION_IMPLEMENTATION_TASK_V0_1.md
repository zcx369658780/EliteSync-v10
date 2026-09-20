# EliteSync v10｜Next IP-13I-R7-R3 Runtime Readiness HTTP Request-State Vocabulary Correction Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT THREE-PATH CORRECTION ON FROZEN R7 CANDIDATE — ONE TARGETED FEATURE ATTEMPT — NO ROUTE CHANGE — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication main: `269323eec422505f1e26d59af2e5d744ee8b0f72`

Accepted R7-R2 result blob:
`29b007b2cb1a2e38ef28c762fee86b5a2354f641`

Accepted R7-R2 acceptance blob:
`2b974acb30b60f7e07701efb23252be651ba85dc`

Frozen rejected R7 candidate:
`cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

Frozen candidate tree:
`1079877dc5bba0813ccdd8a5d5c888de3b51a431`

## 1. Objective

Correct only the accepted request-state vocabulary defect on top of the exact frozen R7 candidate.

The corrected HTTP request field:

`prerequisite_set.state`

must accept only:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

The controller must pass the decoded value unchanged to the existing accepted R5 adapter.

No transport→domain mapping, normalization, alias or compatibility translation is permitted.

The old shorthand values:

- `KNOWN`
- `UNKNOWN`

must fail before adapter dispatch with:

HTTP `400 / INVALID_REQUEST_SCHEMA`.

All other R6/R7 behavior remains frozen.

## 2. Mandatory authority and topology gates

Before any implementation write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Read this task.
6. Read the accepted R7-R2 result and acceptance.
7. Do NOT merge or transplant the frozen R7 candidate to main.
8. Create one isolated correction branch/worktree from exactly:
   `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`
9. Verify that correction-worktree HEAD/parent/tree are exactly:
   - HEAD: `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`
   - sole parent: `bec14f195e0000f02443f13c45fa50fbff72360e`
   - tree: `1079877dc5bba0813ccdd8a5d5c888de3b51a431`
10. Verify all frozen blobs in Section 3.
11. Verify the new correction-result path is absent on that frozen candidate.
12. Stop rather than adapt if any identity differs.

Recommended correction branch:

`review/next-ip-13i-r7-r3-request-state-vocabulary-correction-v0-1`

The correction candidate's sole parent must remain the frozen R7 candidate:
`cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

It is intentionally not parented by current main.

## 3. Exact authorized read scope / frozen inputs

From task-publication main, read only:

1. `AGENTS.md`
2. this R7-R3 task
3. accepted R7-R2 result
4. accepted R7-R2 acceptance

From frozen R7 candidate `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`, read only:

5. `services/backend-laravel/routes/api.php`
6. `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`
7. `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`
8. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_RESULT_V0_1.md`
9. `services/backend-laravel/composer.json`
10. `services/backend-laravel/composer.lock`
11. `services/backend-laravel/phpunit.xml`

Expected frozen blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- accepted R7-R2 result:
  `29b007b2cb1a2e38ef28c762fee86b5a2354f641`
- R7-R2 acceptance:
  `2b974acb30b60f7e07701efb23252be651ba85dc`
- frozen route:
  `37c3cd0c193f412fef7c03526fdc1926ad8535b5`
- frozen controller:
  `95272cf7d63cf8cdf3db29eaf41c4c3450836f16`
- frozen Feature test:
  `2f885b61519225604c27e9fb0ed7c7b25f138612`
- frozen R7 implementation result:
  `d596c0e1758c34b2697b59f15302a89bf4563e27`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`

No repository search/discovery or unrelated source read is authorized.

## 4. Exact tracked write scope

Relative to frozen R7 candidate `cf8f0fda…`, exactly three tracked paths may change.

1. MODIFY:
   `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`

2. MODIFY:
   `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

3. CREATE:
   `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_REQUEST_STATE_VOCABULARY_CONTRACT_REPAIR_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked path may change.

The route must remain byte/blob-identical:

`services/backend-laravel/routes/api.php = 37c3cd0c193f412fef7c03526fdc1926ad8535b5`

The prior R7 implementation result must also remain unchanged.

Do NOT modify:

- R5 adapter/evaluator;
- IP-13A/IP-13D/IP-13E/IP-13F;
- generic HTTP controller/test;
- route;
- middleware/providers/bootstrap/config;
- Composer manifests;
- migrations;
- client/provider/network;
- auth/session/token;
- legal/Safety;
- production/real-private-data surfaces.

## 5. Exact controller correction

In `RuntimeReadinessEvaluationController`, change only the prerequisite-set state allowlist semantics.

The controller must accept exactly:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

It must reject:

- `KNOWN`
- `UNKNOWN`
- every other value

as ordinary request schema failure:

HTTP `400 / INVALID_REQUEST_SCHEMA`

before adapter dispatch.

Do not map the values.

Do not normalize them.

Do not add constants, aliases or compatibility translations unless doing so is only a local literal-reference cleanup that preserves the exact accepted public values and adds no alternate input vocabulary.

All other controller behavior must remain semantically unchanged.

## 6. Exact Feature-test correction

Modify only the existing:

`services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

Required corrections:

1. Valid known-set fixtures must emit:
   `KNOWN_PREREQUISITE_SET`

2. Valid unknown-set fixtures must emit:
   `UNKNOWN_PREREQUISITE_SET`

3. Add explicit coverage proving legacy shorthand:
   - `KNOWN`
   - `UNKNOWN`

   both return:

   HTTP `400 / INVALID_REQUEST_SCHEMA`

4. For both shorthand rejections prove dispatch does not occur. Use only the existing bounded in-memory graph/test seams; do not add a helper file.

5. Preserve every existing R7 Feature obligation:
   - route identity;
   - secure.transport;
   - no v1 alias;
   - no auth inference;
   - IP-13F five-family preservation;
   - READY / NOT_READY / UNKNOWN HTTP 200 separation;
   - exact five-field success response;
   - privacy/sentinel non-leakage;
   - malformed JSON/schema/synthetic-boundary handling;
   - storage/materialization degradation;
   - unexpected failure / unrecognized mapping fail-closed behavior;
   - headers/query/IP/user-agent non-authority;
   - single dispatch/no retry.

No second test file.

## 7. Response and privacy freeze

Do not change the accepted success body:

- `readiness_classification`
- `reason_categories`
- `materialized_projection_usable`
- `condition`
- `synthetic_dev_test_only`

Do not change the existing 200/400/426/500 mapping except that old shorthand states are explicitly confirmed as ordinary 400 schema failures.

Do not expose any new internal field.

## 8. IP-13F and route freeze

IP-13F remains unchanged and non-participating.

Generic endpoint remains:

`POST /api/v2/contracts/application-envelope`

Dedicated endpoint remains:

`POST /api/v2/runtime-readiness/evaluations`

No route change is permitted in R7-R3.

No sixth IP-13F family.

## 9. Same-worktree vendor bootstrap

In the frozen-candidate-derived correction worktree, check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:

- Composer Case A;
- do not run Composer.

Otherwise run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Composer Case B.

No retry.
No update.
No scripts/plugins.

`composer.json` and `composer.lock` must remain tracked/blob-identical.

## 10. Exact runtime command budget

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
- provider/network;
- production;
- real/private-data operation.

After final authoring run exactly once:

`git diff --check`

No other project runtime command is authorized.

## 11. Failure handling

If the single targeted PHPUnit attempt fails:

- do not rerun;
- static correction after the consumed run is permitted only within the exact three-path write scope;
- do not claim runtime PASS after a post-run static correction;
- publish the immutable correction candidate with runtime status `RETAINED_UNKNOWN`;
- fresh independent review may authorize verification-only rerun.

If correction requires route modification, a fourth path, or any protected source change:

- STOP;
- record the exact blocker;
- do not expand scope.

## 12. Correction result document

Create exactly:

`docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_REQUEST_STATE_VOCABULARY_CONTRACT_REPAIR_IMPLEMENTATION_RESULT_V0_1.md`

Record:

- task-publication main;
- correction candidate branch;
- correction candidate SHA / sole parent / tree / ahead-behind relative frozen R7 base;
- exact three-path diff;
- all fixed input blobs;
- pre/post controller/test blobs;
- frozen route identity;
- exact state-vocabulary correction;
- explicit absence of transport→domain mapping;
- old shorthand rejection proof;
- preservation of all other R7 semantics;
- Composer Case A/B receipt;
- targeted PHPUnit receipt;
- warnings/deprecations;
- manifest/lock identities;
- one `git diff --check` receipt;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R7-R3 REQUEST-STATE VOCABULARY CORRECTION IMPLEMENTED — EXACT R5 LITERALS KNOWN_PREREQUISITE_SET|UNKNOWN_PREREQUISITE_SET ACCEPTED AT HTTP BOUNDARY — OLD KNOWN|UNKNOWN SHORTHAND FAILS CLOSED BEFORE DISPATCH — FROZEN ROUTE UNCHANGED — EXACT THREE-PATH CORRECTION — TARGETED FEATURE PASS — NO TRANSPORT→DOMAIN TRANSLATION — IP-13F/R5/PRIVACY/AUTHORITY BOUNDARIES PRESERVED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
