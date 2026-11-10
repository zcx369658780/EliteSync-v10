# EliteSync v10｜Next IP-13I-R7 Runtime Readiness HTTP Entry Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT FOUR-PATH SYNTHETIC/DEV-TEST HTTP IMPLEMENTATION — ONE TARGETED FEATURE ATTEMPT — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `a69d9c9db901f6cd0c013a697ab84d6b41b7952a`

Accepted R6 result blob: `5cffb288f4daba5e52e07fb84000ed8d1d5d994d`

R6 acceptance blob: `0ed30053987de03e44677819a32315ffe8899999`

## 1. Objective

Implement only the independently accepted R6 dedicated Runtime Readiness HTTP entry:

`POST /api/v2/runtime-readiness/evaluations`

The executable synthetic/dev-test chain must be:

`Laravel HTTP → exact synthetic request validation → RuntimeReadinessPersistenceApplicationAdapter → RuntimeReadinessDerivedEvaluator → RR03 → IP-13A/IP-13D sqlite::memory: → IP-13E submit + conditional retrieve → privacy-minimal HTTP response`

This task must not change the accepted domain/persistence/application contracts.

IP-13F remains unchanged and non-participating.

Controlling invariants:

- `READINESS_DERIVATION != SOURCE_AUTHORITY`
- `STORED != AUTHORITATIVE`
- `ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY`
- `APPLICATION_RESULT != SOURCE_AUTHORITY`
- `HTTP_STATUS != DOMAIN_OUTCOME`
- `READY != STORAGE_SUCCESS`
- `READY != AUTHORITATIVE_OUTCOME`
- `PROJECTION != PERMISSION`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- no global revision
- no synthetic aggregate dependency revision
- no LWW / arrival-order authority
- no authentication/session/token inference
- no real/private-data or production authority

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Require `origin/main` to equal this task-publication commit exactly.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the three create-paths in Section 4 are absent.
6. Verify the fixed-input blobs in Section 3.
7. Stop rather than adapt if base, path, blob or authority differs.

Recommended branch:

`review/next-ip-13i-r7-runtime-readiness-http-entry-v0-1`

Do not enumerate the repository.

## 3. Exact authorized read scope / fixed inputs

Read only:

1. `AGENTS.md`
2. accepted R6 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`
3. R6 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_HTTP_ENTRY_CONTRACT_REVIEW_ACCEPTANCE_V0_1.md`
4. `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`
5. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
6. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
7. `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
8. `services/backend-laravel/app/Http/Controllers/Api/V2/Contracts/TransportEnvelopeController.php`
9. `services/backend-laravel/routes/api.php`
10. `services/backend-laravel/tests/Feature/Api/V2/TransportEnvelopeTest.php`
11. `services/backend-laravel/phpunit.xml`
12. `services/backend-laravel/composer.json`
13. `services/backend-laravel/composer.lock`

Expected fixed blobs at task publication:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- accepted R6 result:
  `5cffb288f4daba5e52e07fb84000ed8d1d5d994d`
- R6 acceptance:
  `0ed30053987de03e44677819a32315ffe8899999`
- R5 Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- IP-13D:
  `a81535d174015bb0ecaa9f8caeaabb7490c4354b`
- IP-13F:
  `e70f260de92a0047e70b54827f4795edb3b74e00`
- existing generic HTTP controller:
  `e9a202533748e37c0d6199cc2219e9127a7965d6`
- routes:
  `199a0a08a9474d0bbaeb4edc5f8f20534f269c01`
- existing generic Feature test:
  `60434c0a70f7a768496e30dd937cfca4c15411b0`
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`

No other source discovery is authorized.

## 4. Exact tracked write scope

Exactly four tracked paths may change.

1. MODIFY:
   `services/backend-laravel/routes/api.php`

2. CREATE:
   `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`

3. CREATE:
   `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

4. CREATE:
   `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked path may change.

Specifically do NOT modify:

- RuntimeReadinessPersistenceApplicationAdapter;
- RuntimeReadinessDerivedEvaluator;
- IP-13A;
- IP-13D;
- IP-13E;
- IP-13F;
- TransportEnvelopeController;
- existing TransportEnvelopeTest;
- middleware;
- providers/bootstrap/config;
- Composer manifests;
- migrations/database configuration;
- client/provider/network code.

No fifth mapper/service/FormRequest file is authorized.

## 5. Exact route change

Modify `routes/api.php` only as follows:

- add exactly one import for:
  `App\Http\Controllers\Api\V2\RuntimeReadiness\RuntimeReadinessEvaluationController`;
- inside the existing `Route::prefix('v2')->middleware('secure.transport')->group(...)` add exactly:
  `Route::post('/runtime-readiness/evaluations', RuntimeReadinessEvaluationController::class);`

Do not:

- create a v1 alias;
- add `auth:sanctum`;
- add throttle/auth/session/token middleware;
- move or alter the generic application-envelope route;
- change any v1 source;
- change `secure.transport`.

The endpoint URI must resolve exactly as:

`POST /api/v2/runtime-readiness/evaluations`

## 6. Controller construction

Create final invokable:

`App\Http\Controllers\Api\V2\RuntimeReadiness\RuntimeReadinessEvaluationController`

Constructor dependency must be exactly the existing:

`RuntimeReadinessPersistenceApplicationAdapter`

Do not inject IP-13F.

Do not directly call SQLite, PDO or IP-13A.

No provider binding is required: the accepted object graph uses concrete constructor dependencies.

The controller may contain private validation/mapping helpers because no separate mapper/FormRequest file is authorized.

## 7. JSON decoding and top-level request allowlist

The controller owns transport validation.

It must distinguish malformed JSON from a valid but invalid schema.

Decode the raw request JSON in a bounded way that can fail closed as:

- malformed JSON → HTTP 400 / `MALFORMED_JSON`;
- valid JSON that is not the exact required object → HTTP 400 / `INVALID_REQUEST_SCHEMA`.

The accepted top-level object contains exactly two required keys:

- `prerequisite_set`
- `member_evidence`

No optional top-level key exists.

No request identity, idempotency key, account/user identity, actor authority, session or token field may be added.

Unknown or missing ordinary top-level fields fail before adapter dispatch.

## 8. Exact prerequisite_set contract

`prerequisite_set` must be a non-null object with exactly:

- `synthetic_fixture`
- `state`
- `set_identity`
- `required_member_ids`
- `protected_use_scope`
- `required_bindings`
- `source_evidence`
- `private_fixture_extensions`

Rules:

- `synthetic_fixture` must equal:
  `ELITESYNC_RR03_SYNTHETIC_DEV_TEST_V1`
- `state`: exact accepted R6 enum `KNOWN | UNKNOWN`
- `set_identity`: non-empty string or null
- `required_member_ids`: JSON list of unique non-empty strings
- `protected_use_scope`: non-empty string
- `required_bindings`: exact Section 10 object
- `source_evidence`: exact Section 11 object
- `private_fixture_extensions`: exact Section 12 object

Missing/wrong synthetic marker uses the synthetic-boundary mapping in Section 14.

Other schema errors use `INVALID_REQUEST_SCHEMA`.

## 9. Exact member_evidence contract

`member_evidence` must be a JSON list.

Every item is a non-null object with exactly:

- `synthetic_fixture`
- `member_identity`
- `fact_class`
- `protected_use_scope`
- `required_bindings`
- `source_evidence`
- `prerequisite_outcome`
- `private_fixture_extensions`

Rules:

- synthetic marker exact as above;
- `member_identity`: non-empty string;
- `fact_class`: `ELIGIBILITY | CHECKLIST | VERIFICATION`;
- member `protected_use_scope` must equal prerequisite-set `protected_use_scope`;
- `prerequisite_outcome`: `SATISFIED | UNSATISFIED | null`;
- exact binding/evidence/extension objects only.

Do not assign semantic meaning to member list ordering.

## 10. Exact binding object

Each `required_bindings` and each `source_evidence.bindings` object contains exactly:

- `authority_owner`
- `authority_scope`
- `actor`
- `actor_role`
- `subject`
- `participants`
- `audience`
- `purpose`
- `aggregate_context`
- `lifecycle_identity`
- `terminal`

Constraints:

- string fields are non-empty strings;
- `participants` is a JSON list of strings;
- `terminal` is boolean;
- for each prerequisite/member container, `required_bindings` must equal `source_evidence.bindings` exactly;
- each member `required_bindings.purpose` must equal request `protected_use_scope`.

These fixture values remain descriptive and non-authoritative.

## 11. Exact source_evidence and revision contract

Each `source_evidence` contains exactly:

- `record_kind = SOURCE_EVIDENCE`
- `bindings`
- `source_condition`
- `source_revision`
- `currentness`
- `freshness`
- `authoritative_outcome`

Allowed `source_condition`:

- PRESENT
- ABSENT
- UNKNOWN
- UNAVAILABLE
- STALE
- SUPERSEDED
- INCOMPARABLE

`currentness` and `freshness` are boolean or null.

Allowed `authoritative_outcome`:

- COMMITTED
- REJECTED
- UNKNOWN

`source_revision` contains exactly:

- `authority_owner`
- `authority_scope`
- `lineage`
- `aggregate_context`
- `value`

The first four are non-empty strings. `value` is integer >= 0.

Revision owner/scope/context must match the evidence bindings as required by the accepted R6 request contract.

No global/aggregate revision is created.

## 12. Exact synthetic fixture extension

`private_fixture_extensions` must contain exactly one key:

`raw_fixture`

Its value must be a synthetic string beginning with:

`MUST-NOT-LEAK-RR03-PRIVATE`

This value must never appear in:

- success response;
- error response;
- controller-owned error detail;
- result document payload examples copied from runtime.

No general-purpose private extension channel is authorized.

## 13. Adapter dispatch

For a request that passes controller-owned structural/allowlist validation:

- call `RuntimeReadinessPersistenceApplicationAdapter::evaluateSynthetic()` exactly once;
- pass only decoded `prerequisite_set` and `member_evidence`;
- no retry;
- no second adapter call;
- no IP-13F call.

If the R5 adapter throws `InvalidArgumentException` because an input still violates the accepted synthetic boundary, map it to:

HTTP 400 / `SYNTHETIC_BOUNDARY_REJECTED`

Do not return the exception text.

Any other unexpected throwable maps to:

HTTP 500 / `INTERNAL_APPLICATION_FAILURE`

with no domain classification invented.

## 14. Exact 400 error precedence

Use:

- malformed raw JSON → `MALFORMED_JSON`;
- missing/wrong `synthetic_fixture` marker at prerequisite/member boundary → `SYNTHETIC_BOUNDARY_REJECTED`;
- other missing/extra/wrong-type/illegal-null/nested-structure errors → `INVALID_REQUEST_SCHEMA`;
- deeper R5 `InvalidArgumentException` synthetic-boundary rejection → `SYNTHETIC_BOUNDARY_REJECTED`.

All are HTTP 400.

Do not use 401, 403 or 422.

The error body is exactly two top-level keys:

`error`
`synthetic_dev_test_only`

The `error` object contains exactly:

- `code`
- `message`

Use the accepted generic fixed message:

`Request rejected by the bounded synthetic Runtime Readiness HTTP contract.`

for 400 contract rejections.

Do not echo request values.

## 15. Exact success response

If the adapter returns a recognized R5 result normally, return HTTP 200 with exactly:

- `readiness_classification`
- `reason_categories`
- `materialized_projection_usable`
- `condition`
- `synthetic_dev_test_only`

Allowed readiness classification:

- READY
- NOT_READY
- UNKNOWN

Allowed `condition`:

- `EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`
- `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
- `RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

`reason_categories` is copied only from the bounded R5 RR03 reason list.

`synthetic_dev_test_only` must be true.

Do not expose the full RR03 payload.

Do not expose logical identities, source revisions, storage dispositions, projection read dispositions, authoritative outcome, internal non-authority flags, reconciliation/invalidation/revalidation internals or IP-13E receipts.

READY / NOT_READY / UNKNOWN do not select HTTP status.

## 16. Unknown result mapping

Before producing a success response, fail closed if the adapter result does not satisfy the accepted public mapping.

Examples:

- unrecognized `condition`;
- invalid readiness classification;
- malformed/missing bounded reason list;
- invalid materialized-projection flag;
- missing/false `synthetic_dev_test_only`.

Map such controller-owned mapping failure to:

HTTP 500 / `UNRECOGNIZED_TRANSPORT_MAPPING`

Do not invent a domain result.

A private controller mapping helper may be exercised through bounded reflection in the targeted Feature test to establish this fail-closed behavior.

## 17. 426 secure.transport behavior

The new route must remain inside the existing v2 `secure.transport` group.

Existing insecure-transport rejection remains framework/middleware-owned and returns 426 before controller/adapter dispatch.

The task does not authorize changing that middleware or its response body.

The targeted test must prove:

- insecure request → 426;
- adapter/persistence dispatch count remains zero;
- prohibited sentinel does not leak;
- 426 creates no authentication/identity/source-authority meaning.

## 18. Storage/materialization semantics

Preserve the adapter classification exactly.

When the R5 adapter returns:

- usable exact projection → HTTP 200 with usable true;
- storage rejected / retrieval skipped → HTTP 200 with usable false and exact storage-rejected condition;
- missing/stale/superseded/incomparable/invalidated/binding-mismatch/payload-mismatch readback → HTTP 200 with usable false and exact readback-unusable condition.

Do not reveal raw storage/read disposition.

Do not retry.

Do not change readiness classification after persistence/materialization behavior.

Unexpected lower-layer exception before a valid adapter result exists remains HTTP 500.

## 19. Authentication / authority boundary

Do not infer authority from:

- route;
- method;
- headers;
- cookies;
- query string;
- IP;
- user-agent;
- Laravel Request identity;
- middleware presence/passage;
- controller/container binding;
- HTTP status.

No auth/session/token code is authorized.

Synthetic `actor` and `actor_role` remain untrusted descriptive fixture strings.

## 20. IP-13F preservation

Do not modify IP-13F.

The exact accepted five families remain:

1. `AUTHORITATIVE_MUTATION_SUBMISSION`
2. `AUTHORITATIVE_OUTCOME_RECONCILIATION`
3. `CURRENT_PROJECTION_RETRIEVAL`
4. `PROTECTED_ACTION_REVALIDATION`
5. `INVALIDATION_OBSERVATION`

The generic endpoint remains:

`POST /api/v2/contracts/application-envelope`

The new Runtime Readiness controller must not instantiate, inject, call, wrap or alias `TransportNeutralApplicationRequestResponseContract`.

No sixth family.

## 21. Exact targeted Feature test

Create exactly:

`services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

The single file must establish at least:

1. exact POST route exists under v2 `secure.transport`;
2. no v1 alias;
3. no `auth:sanctum`;
4. generic application-envelope route still exists unchanged;
5. IP-13F remains exactly five families / no Runtime Readiness sixth family;
6. valid synthetic READY → HTTP 200 exact five-key response;
7. NOT_READY → HTTP 200 without status reinterpretation;
8. UNKNOWN → HTTP 200 without status reinterpretation;
9. exact top-level two-key request allowlist;
10. missing/extra ordinary fields rejected before adapter dispatch;
11. wrong/missing synthetic marker → 400 `SYNTHETIC_BOUNDARY_REJECTED`;
12. malformed JSON → 400 `MALFORMED_JSON`;
13. malformed nested binding/evidence/revision/list/type/null → 400;
14. prohibited sentinel absent from every response;
15. all internal-only R5 fields absent from success response;
16. storage rejection preserves classification and returns degraded 200;
17. unusable/missing/stale/superseded/incomparable/invalidated readback preserves classification and returns degraded 200;
18. binding mismatch / payload mismatch preserves classification and returns degraded 200;
19. unexpected adapter/application failure → 500 `INTERNAL_APPLICATION_FAILURE`;
20. unrecognized controller mapping → 500 `UNRECOGNIZED_TRANSPORT_MAPPING`;
21. insecure transport → 426 before dispatch;
22. headers/query/IP/user-agent differences do not alter semantic request;
23. no authentication/session/token/permission/source-authority claim;
24. exactly one adapter dispatch per structurally accepted request;
25. no retry;
26. inputs are not mutated;
27. synthetic fixtures only.

Permitted test-only seams:

- container-bind one preconstructed `RuntimeReadinessPersistenceApplicationAdapter` / IP-13E / SQLite graph;
- flush only the exact new route's cached controller after a test binding;
- precondition that same in-memory object graph for invalidation/terminal/materialization cases;
- bounded reflection in the test file for deterministic readback mismatch, unexpected-failure or private controller-mapping evidence.

Do not create a test helper file.

## 22. Same-worktree vendor bootstrap

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:

- Composer Case A;
- do not run Composer.

Otherwise run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry.
No update.
No scripts/plugins.

`composer.json` and `composer.lock` must remain blob-identical.

## 23. Exact runtime command budget

Run exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

No retry.

Do NOT run:

- full suite;
- any other Unit/Feature file;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migration/generator;
- server;
- curl/HTTP client;
- provider/network;
- production;
- real/private-data operation.

After final authoring run exactly one:

`git diff --check`

No other project runtime command is authorized.

## 24. Failure handling

If the single targeted PHPUnit attempt fails:

- do not rerun;
- static correction after the consumed run is allowed only within the exact four-path write scope;
- do not claim runtime PASS after a post-run correction;
- publish the immutable candidate with runtime status `RETAINED_UNKNOWN`;
- fresh independent review may authorize a verification-only rerun.

If correction requires a fifth path or modification of a protected accepted source:

- STOP;
- record the exact blocker;
- do not expand scope.

## 25. Result document

The result document must record:

- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact four-path diff;
- all fixed input blobs;
- route/controller identities;
- exact request validator behavior;
- exact success/error response shapes;
- exact privacy exclusions;
- 200/400/426/500 mapping;
- adapter single-dispatch/no-retry evidence;
- IP-13F five-family preservation;
- generic endpoint unchanged;
- synthetic-only boundary;
- Composer Case A/B receipt;
- exact targeted PHPUnit receipt;
- warnings/deprecations;
- manifest/lock identities;
- `git diff --check`;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R7 RUNTIME READINESS HTTP ENTRY IMPLEMENTED — POST /api/v2/runtime-readiness/evaluations ESTABLISHES SYNTHETIC HTTP→EVALUATOR→RR03→SQLITE :memory:→IP-13E→R5 ADAPTER→PRIVACY-MINIMAL HTTP RUNTIME PROOF — READY/NOT_READY/UNKNOWN REMAIN DOMAIN-ONLY — IP-13F REMAINS UNCHANGED FIVE-FAMILY GENERIC CONTRACT — EXACT FOUR-PATH SCOPE — TARGETED FEATURE PASS — NO AUTH/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
