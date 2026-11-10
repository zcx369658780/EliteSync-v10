# EliteSync v10｜IP-13I-R13 Canonical Match Application Adapter → HTTP Entry Contract Review Acceptance｜v0.1

Status: `ACCEPTED — TWO DEDICATED CANONICAL MATCH HTTP ENTRIES — ALL RECOGNIZED ADAPTER-COMPLETED DOMAIN/STORAGE RESULTS REMAIN HTTP 200 — PRIVACY-MINIMAL FIVE-FIELD RESPONSE — IP-13F/RUNTIME-READINESS UNCHANGED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R13 task-publication commit:
`5b5664f303b38e50dbe8954bc0473db9602d9b78`

Accepted review branch:
`review/next-ip-13i-r13-canonical-match-http-entry-contract-v0-1`

Accepted immutable candidate:
`a9fb2ded0dd5d4da009a1774eca69ee887098a22`

Publication-reported candidate tree:
`c5827c2a3f7d6b59b15866b73c6e0ceb0af8781d`

Accepted result blob:
`66462dd36ca78a49f8891387bc00b9b9959b9bbd`

Integrated main commit:
`6b4d61948fb5437399ce18e969f73707a4b9c22c`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = 5b5664f303b38e50dbe8954bc0473db9602d9b78`;
- candidate is exactly one commit ahead / zero behind;
- exactly one authorized review-result document is added;
- all 14 fixed-input ledger objects resolve to the exact claimed blobs;
- no code/runtime operation occurred;
- the exact accepted result blob was transplanted to main unchanged.

## 2. Accepted endpoint topology

Accepted:

`ENDPOINT_TOPOLOGY = OPTION_A_TWO_DEDICATED_ENDPOINTS`

Exact synthetic/dev-test routes:

- `POST /api/v2/canonical-match/evaluations`
- `POST /api/v2/canonical-match/invalidations`

The route itself identifies the adapter operation:

- evaluations → `evaluateSynthetic()`;
- invalidations → `invalidateSynthetic()`.

No operation discriminator or second semantic envelope is introduced.

## 3. Accepted HTTP status model

Every recognized adapter-completed result returns HTTP `200`, including:

- `PENDING`;
- `MUTUALLY_ACCEPTED`;
- `DECLINED`;
- `WITHDRAWN`;
- `EXPIRED`;
- ordinary domain `UNKNOWN`;
- purpose-mismatch `UNKNOWN`;
- dependency-invalidated `UNKNOWN`;
- exact duplicate;
- incomparable coexistence with exact-lineage readback;
- storage-rejected/retrieval-skipped;
- readback-unusable/mismatched.

Preserve:

- `HTTP_STATUS != DOMAIN_OUTCOME`;
- `HTTP_STATUS != STORAGE_SUCCESS`;
- `UNKNOWN != TRANSPORT_FAILURE`;
- `PERSISTABLE != USABLE`.

Accepted status ownership:

- `400` — malformed JSON, invalid exact schema, synthetic-boundary rejection, or adapter input rejection;
- `409` — unused;
- `422` — unused;
- `426` — existing `secure.transport` middleware, pre-controller;
- `500` — unexpected adapter throwable or unrecognized returned transport mapping;
- `401/403` — unused; auth/session/token authority remains unestablished.

## 4. Accepted request contracts

Evaluation request body exactly preserves the accepted application request shape:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`

Invalidation body adds exactly:

- `invalidation_request`

with:

- non-empty `dependency_identity`;
- relation exactly `CORRECTION | REVOCATION | SUPERSESSION`.

The controller must not normalize source semantic values, including source-purpose mismatch.

No request identity, idempotency key, account/user/session/token identity, prior evaluator result, prior classification, derived Match payload, stored projection, or generic invalidation envelope is accepted.

## 5. Accepted dispatch boundary

For structurally accepted requests:

- evaluation controller path calls `evaluateSynthetic()` exactly once;
- invalidation controller path calls `invalidateSynthetic()` exactly once;
- no retry;
- no fallback between operations;
- no direct evaluator/IP-13A/IP-13D/IP-13E/IP-13F access;
- no generic invalidation call.

The future controller has exactly one domain dependency:

`CanonicalMatchPersistenceApplicationAdapter`.

## 6. Accepted success response

HTTP `200` body contains exactly five fields:

- `match_classification`
- `reason_categories`
- `materialized_projection_usable`
- `condition`
- `synthetic_dev_test_only`

The operation is not exposed because route identity already provides it.

Classification allowlist:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

Reason categories are the canonical unique subset of the accepted fifteen Match categories.

Condition allowlist:

- `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`
- `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
- `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
- `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Unknown/inconsistent adapter mapping fails closed as HTTP 500.

## 7. Accepted privacy boundary

Successful HTTP responses do not expose:

- Match payload;
- proposal/participant/slot identities;
- invalidation dependency identity/relation;
- logical record/intent/lifecycle identities;
- lineage/revision;
- storage/read disposition;
- binding classification;
- authoritative outcome;
- reconciliation/invalidation/revalidation workflow fields;
- source evidence or required bindings;
- raw purpose mismatch;
- adapter operation;
- authority/permission/authentication flags.

Errors expose only bounded code/message plus `synthetic_dev_test_only=true`.

No exception text, request echo or internal identifier crosses the boundary.

## 8. secure.transport and auth boundary

Both routes belong to the existing:

`Route::prefix('v2')->middleware('secure.transport')`

group.

`426` remains middleware-owned.

No `auth:sanctum` is added.

Source `actor` / `actor_role` remain descriptive source evidence only and do not become authenticated HTTP identity.

Headers, cookies, query parameters, IP address, user agent, request time/order and route order do not become Match evidence, permission, revision, idempotency identity or terminality input.

## 9. IP-13F and Runtime Readiness coexistence

Accepted:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

The generic endpoint remains:

`POST /api/v2/contracts/application-envelope`

with exactly its accepted five families.

Runtime Readiness remains:

`POST /api/v2/runtime-readiness/evaluations`

with its current route/controller/Feature-test semantics unchanged.

No universal derived-domain HTTP envelope is authorized.

## 10. Accepted next implementation scope

Next task:

`IP-13I-R14 CANONICAL MATCH SYNTHETIC HTTP ENTRY IMPLEMENTATION`

Exact tracked write scope:

1. MODIFY:
   `services/backend-laravel/routes/api.php`

2. CREATE:
   `services/backend-laravel/app/Http/Controllers/Api/V2/CanonicalMatch/CanonicalMatchEntryController.php`

3. CREATE:
   `services/backend-laravel/tests/Feature/Api/V2/CanonicalMatchEntryTest.php`

4. CREATE:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_HTTP_ENTRY_IMPLEMENTATION_RESULT_V0_1.md`

No persistence, IP-13E, IP-13F, adapter, evaluator or Common Authority change is authorized.

## 11. Preserved invariants

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- `HTTP_STATUS != DOMAIN_OUTCOME`;
- `HTTP_STATUS != STORAGE_SUCCESS`;
- `PROJECTION != PERMISSION`;
- Match != Connection != Consent != Conversation != Relationship;
- invalidation != reopen;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no auth/session/token/account authority;
- no production persistence/deployment authority;
- no real/private-data processing.

## 12. Acceptance classification

`IP-13I-R13 ACCEPTED — TWO DEDICATED CANONICAL MATCH HTTP ENTRIES FIXED — ALL RECOGNIZED ADAPTER-COMPLETED DOMAIN/STORAGE STATES RETURN HTTP 200 — EXACT 400/426/500 OWNERSHIP AND NO 409/422/401/403 ESTABLISHED — FIVE-FIELD PRIVACY-MINIMAL SUCCESS RESPONSE ACCEPTED — secure.transport PRESERVED — IP-13F/RUNTIME-READINESS UNCHANGED — NEXT = IP-13I-R14 BOUNDED HTTP IMPLEMENTATION`
