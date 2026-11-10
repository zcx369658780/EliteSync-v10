# EliteSync v10｜Next IP-13I-R13 Canonical Match Application Adapter → HTTP Entry Contract Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CANONICAL MATCH HTTP ENTRY CONTRACT REVIEW — EXACTLY ONE RESULT DOCUMENT — NO ROUTE/CONTROLLER/TEST IMPLEMENTATION — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`fdde97561a0242ac92fc697a624bcce611ca45bc`

Accepted R12 acceptance blob:
`413ee73e68d1109915e1f2d3551a541154b0420f`

Accepted Canonical Match adapter blob:
`789e8905b2c9ee54d902d8b600100896af4f6063`

Current routes blob:
`37c3cd0c193f412fef7c03526fdc1926ad8535b5`

Runtime Readiness HTTP controller blob:
`3a74ae1da7a752de61c47f055c4fab1a8b900e4c`

Runtime Readiness Feature proof blob:
`6724f9a201c4edb40702502be11612823d718c43`

IP-13F blob:
`e70f260de92a0047e70b54827f4795edb3b74e00`

## 1. Objective

Define the exact synthetic/dev-test Canonical Match transport/HTTP entry contract over the accepted R12 application adapter.

This task is REVIEW ONLY.

It must decide:

- endpoint topology;
- request JSON contracts for ordinary evaluation and dependency invalidation;
- exact JSON/object/list/type/synthetic-marker gate;
- adapter operation dispatch;
- HTTP status mapping;
- privacy-minimal response shape;
- error shape;
- `secure.transport` ownership;
- auth/session/token non-authority;
- coexistence with Runtime Readiness and the generic IP-13F endpoint;
- exact future implementation scope and targeted Feature proof.

It must not implement anything.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R13 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if any identity differs.

Recommended branch:

`review/next-ip-13i-r13-canonical-match-http-entry-contract-v0-1`

No repository enumeration or unrelated discovery is authorized.

## 3. Accepted controlling facts

Preserve the accepted R12 chain:

### Ordinary application operation

`evaluateSynthetic(array $request): array`

with exact top-level application request keys:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`

### Dependency-invalidation operation

`invalidateSynthetic(array $request): array`

with exact top-level application request keys:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`
- `invalidation_request`

Synthetic marker:

`ELITESYNC_CANONICAL_MATCH_SYNTHETIC_DEV_TEST_V1`

The adapter already owns:

- exact structural input gate;
- ordinary one-`evaluate()` flow;
- invalidation fresh-`evaluate()` + one-`invalidate()` flow;
- exact record construction;
- one IP-13E submit;
- conditional exact-lineage retrieve;
- bounded materialization condition;
- non-authority result.

The HTTP layer must not duplicate or replace domain/persistence authority.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`
2. this R13 task
3. R12 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R12_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
4. R12-R2 correction result:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`
5. accepted Canonical Match adapter:
   `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
6. accepted targeted adapter Unit test:
   `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
7. accepted R11 persistence-family acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
8. accepted Runtime Readiness HTTP contract result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`
9. Runtime Readiness HTTP acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R7_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
10. current Runtime Readiness controller:
    `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`
11. current Runtime Readiness Feature test:
    `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`
12. current routes:
    `services/backend-laravel/routes/api.php`
13. current generic transport controller:
    `services/backend-laravel/app/Http/Controllers/Api/V2/Contracts/TransportEnvelopeController.php`
14. IP-13F transport-neutral application contract:
    `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`

Expected blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R12 acceptance:
  `413ee73e68d1109915e1f2d3551a541154b0420f`
- R12-R2 result:
  `9d071154cb2d4c76158615f6ca408b5fcfc18b86`
- Canonical Match adapter:
  `789e8905b2c9ee54d902d8b600100896af4f6063`
- Canonical Match adapter Unit test:
  `c8298f5e786a47d118b56f47cef6baab7f543b60`
- R11 acceptance:
  `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c`
- Runtime Readiness HTTP contract result:
  `5cffb288f4daba5e52e07fb84000ed8d1d5d994d`
- Runtime Readiness HTTP acceptance:
  `efa900a6351d98adbe5fe9fce2d846004296b4a9`
- Runtime Readiness controller:
  `3a74ae1da7a752de61c47f055c4fab1a8b900e4c`
- Runtime Readiness Feature test:
  `6724f9a201c4edb40702502be11612823d718c43`
- routes:
  `37c3cd0c193f412fef7c03526fdc1926ad8535b5`
- generic transport controller:
  `e9a202533748e37c0d6199cc2219e9127a7965d6`
- IP-13F:
  `e70f260de92a0047e70b54827f4795edb3b74e00`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R13_CANONICAL_MATCH_APPLICATION_ADAPTER_TO_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`

No existing file may change.

No route/controller/test/code modification.

## 6. Endpoint-topology decision

Choose exactly one:

### Option A — two dedicated endpoints

Example shape:

- `POST /api/v2/canonical-match/evaluations`
- `POST /api/v2/canonical-match/invalidations`

Each route maps directly to one accepted adapter operation and introduces no operation discriminator.

### Option B — one dedicated operation endpoint

One route plus one exact operation discriminator maps to the two adapter operations.

If selected, define the exact discriminator and prove it does not create a second semantic envelope or conflict with adapter request shapes.

### Option C — blocked

Choose if no transport topology can preserve the accepted adapter contract without ambiguity.

The review should prefer the smallest topology that avoids duplicating application semantics.

Do not involve IP-13F in either Option A or B.

## 7. Exact ordinary HTTP request contract

Define the exact decoded JSON object for ordinary evaluation.

It must preserve the accepted adapter input fields and synthetic marker.

At minimum define exact JSON constraints for:

- top-level object;
- `synthetic_fixture`;
- `proposal`;
- `participation_evidence` list;
- `decision_slot_evidence` list;
- nested proposal object;
- nested participation items;
- nested slot items;
- Common Authority binding object;
- source-evidence object;
- source-revision object.

The HTTP controller may perform bounded transport/schema checks before calling the adapter.

It must not normalize semantic source values such as purpose, participants, lifecycle or decisions.

Unknown/missing fields fail closed.

## 8. Exact invalidation HTTP request contract

Define the exact decoded JSON object for dependency invalidation.

It must preserve all ordinary fields plus:

`invalidation_request`

with exact:

- `dependency_identity`: non-empty string;
- `relation`: `CORRECTION | REVOCATION | SUPERSESSION`.

The HTTP layer must not accept:

- caller-supplied prior evaluator result;
- prior classification;
- derived Match payload;
- persisted projection;
- logical record identity as a substitute dependency identity;
- generic invalidation request.

## 9. Raw JSON and schema precedence

Define exact precedence among at least:

1. malformed JSON;
2. top-level JSON not an object;
3. wrong top-level keys/types;
4. synthetic marker mismatch;
5. nested structural/schema mismatch;
6. adapter `InvalidArgumentException`;
7. unexpected adapter exception;
8. adapter result with unrecognized transport mapping.

The result must choose bounded error codes for each transport-owned class.

Do not leak exception text.

## 10. Adapter dispatch rule

For structurally accepted HTTP requests:

- ordinary HTTP entry calls `evaluateSynthetic()` exactly once;
- invalidation HTTP entry calls `invalidateSynthetic()` exactly once;
- no retry;
- no direct evaluator/IP-13A/IP-13D/IP-13E/IP-13F call from controller;
- no generic invalidation call.

The controller constructor dependency should be the accepted Canonical Match adapter only, unless the review proves another dependency is necessary.

## 11. HTTP 200/domain outcome decision

Explicitly decide whether every successfully completed adapter result returns HTTP `200`, including:

- `PENDING`;
- `MUTUALLY_ACCEPTED`;
- `DECLINED`;
- `WITHDRAWN`;
- `EXPIRED`;
- ordinary semantic `UNKNOWN`;
- purpose-mismatch `UNKNOWN` with non-usable materialization;
- dependency-invalidated `UNKNOWN`;
- exact duplicate;
- incomparable-coexisting exact-lineage result;
- storage-rejected/retrieval-skipped result;
- readback-unusable/mismatched result.

Strong existing precedent is:

`HTTP_STATUS != DOMAIN_OUTCOME`

and:

`HTTP_STATUS != STORAGE_SUCCESS`.

If any adapter-completed result maps to 409/422/5xx, the review must identify the exact transport-owned reason without converting domain/storage state into transport failure.

## 12. 400 / 409 / 422 decision

Explicitly decide:

- malformed JSON/status;
- invalid exact request schema/status;
- synthetic boundary rejection/status;
- whether any `409` is justified;
- whether any `422` is justified.

There is no accepted HTTP request identity/idempotency key in the Canonical Match adapter.

Do not copy the generic IP-13F request-identity 409 rule unless a real equivalent exists.

## 13. 500 decision

Define fail-closed `500` handling for:

- unexpected adapter `Throwable`;
- recognized call returning an unrecognized adapter result/condition/schema.

Do not expose exception text or internal identifiers.

## 14. secure.transport / 426

The current v2 routes use:

`secure.transport`

The review must decide whether Canonical Match dedicated entry/entries join that existing group.

If yes:

- insecure transport rejection remains middleware-owned;
- expected status remains `426`;
- controller must not duplicate transport-security logic.

Do not infer TLS/authentication identity from the middleware.

## 15. Authentication/session/token boundary

Authentication/session/token authority remains unestablished for this synthetic/dev-test entry.

Explicitly decide whether the contract has:

- no `auth:sanctum`;
- no 401 mapping;
- no 403 mapping;
- no account/user/session/token identity field.

Descriptive source `actor` and `actor_role` remain source evidence only.

They must not become authenticated HTTP identity.

## 16. Privacy-minimal success response

Define the exact successful HTTP response key set.

The review must minimize from the 39-key adapter result.

Preferred candidate shape to independently accept/reject:

- `match_classification`
- `reason_categories`
- `materialized_projection_usable`
- `condition`
- `synthetic_dev_test_only`

If operation identity is necessary, justify it. The route itself may already identify the operation.

Do NOT expose by default:

- Match payload;
- proposal identity;
- participant references;
- slot identities;
- logical record/intent/lifecycle identities;
- lineage/revision;
- storage disposition;
- projection read disposition;
- binding classification;
- authoritative outcome;
- source evidence;
- required bindings;
- raw purpose mismatch;
- invalidation dependency identity;
- private fixture material;
- permission/authentication fields.

## 17. Privacy-minimal error response

Define one exact bounded error body.

Preferred shape to independently accept/reject:

- `error.code`
- `error.message`
- `synthetic_dev_test_only`

No raw request echo.
No validation-path detail containing identities.
No exception text.
No persistence/internal identifiers.

## 18. Condition allowlist

The controller must recognize only the four accepted application conditions:

- `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`
- `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
- `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
- `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Any other condition returned from the adapter must fail closed as an internal/unrecognized mapping error, not pass through.

## 19. Match classification / reason allowlists

Define exact HTTP-output allowlists:

Classification exactly:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

Reason categories must be a unique list drawn only from the accepted fifteen persisted Canonical Match reason categories.

Do not expose suffix-bearing evaluator diagnostics.

## 20. Header/query/runtime metadata non-authority

Explicitly decide that:

- headers;
- query parameters;
- IP address;
- user agent;
- request arrival time/order;
- route order;
- framework request metadata

cannot become Match evidence, actor authority, idempotency identity, revision, decision priority, permission or terminality input.

The controller may ignore/reject unsupported semantic fields but must not silently use runtime metadata.

## 21. IP-13F coexistence

Must remain:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

The generic endpoint remains:

`POST /api/v2/contracts/application-envelope`

The Canonical Match dedicated entry must not:

- become a sixth IP-13F family;
- alias the generic envelope;
- dispatch through IP-13F;
- reinterpret generic request identity;
- duplicate generic transport authority.

## 22. Runtime Readiness coexistence

The accepted Runtime Readiness endpoint remains unchanged:

`POST /api/v2/runtime-readiness/evaluations`

The Match contract must not modify its route/controller/test or semantics.

No shared “universal derived-domain” HTTP envelope is authorized by R13.

## 23. Exact future implementation scope

If the HTTP contract is sound, define the exact next implementation task.

The result must decide:

- exact route path(s);
- controller class/path(s);
- whether one or two controllers are used;
- exact one Feature test path;
- exact result-document path;
- exact routes diff;
- exact protected blobs that must remain unchanged.

The implementation must remain bounded to dedicated Canonical Match HTTP entry work only.

No IP-13F, persistence, adapter, evaluator or Common Authority source change.

## 24. Targeted Feature proof requirements

Define the future single Feature test obligations.

At minimum require proof for:

- route identity and no v1 alias;
- `secure.transport` / 426 pre-dispatch;
- no `auth:sanctum` inference;
- ordinary valid PENDING 200;
- terminal classifications 200;
- ordinary semantic UNKNOWN 200;
- purpose-mismatch UNKNOWN 200 with unusable materialization;
- dependency-invalidated UNKNOWN 200 with invalidated-materialized-unusable condition;
- storage-rejected/retrieval-skipped still adapter-completed according to accepted HTTP mapping;
- exact five-field/minimal success body if selected;
- privacy non-leakage;
- malformed JSON 400;
- invalid schema 400;
- synthetic marker/boundary rejection 400;
- unexpected adapter failure 500;
- unrecognized mapping 500;
- header/query/IP/UA non-authority;
- exactly one adapter dispatch and no retry;
- IP-13F five-family endpoint unchanged;
- Runtime Readiness endpoint unchanged.

No full suite requirement in this review.

## 25. Review-only prohibition

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- HTTP/client commands;
- database runtime probes;
- provider/network product operations;
- production operations;
- real/private-data operations.

Do not modify code.

## 26. Result requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all read input blobs;
- endpoint topology Option A/B/C;
- exact route path(s);
- exact request contracts;
- raw JSON/schema precedence;
- adapter dispatch;
- 200/400/409/422/426/500 decisions;
- exact success/error response shapes;
- classification/reason/condition allowlists;
- privacy exclusions;
- secure.transport/auth boundary;
- runtime metadata non-authority;
- IP-13F coexistence;
- Runtime Readiness coexistence;
- exact next implementation task and write scope;
- future targeted Feature obligations;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape:

`IP-13I-R13 REVIEW COMPLETE — DEDICATED CANONICAL MATCH HTTP ENTRY CONTRACT SOUND — ORDINARY/INVALIDATION ROUTE TOPOLOGY + EXACT SYNTHETIC REQUEST GATES + PRIVACY-MINIMAL RESPONSE + HTTP STATUS MAPPING FIXED — ALL ADAPTER-COMPLETED DOMAIN/STORAGE STATES REMAIN SEPARATE FROM TRANSPORT STATUS AS ACCEPTED — secure.transport OWNERSHIP PRESERVED — IP-13F/RUNTIME-READINESS UNCHANGED — EXACT NEXT HTTP IMPLEMENTATION SCOPE FIXED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
