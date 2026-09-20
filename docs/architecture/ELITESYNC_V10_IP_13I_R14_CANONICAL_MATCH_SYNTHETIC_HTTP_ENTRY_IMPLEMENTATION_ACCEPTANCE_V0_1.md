# EliteSync v10｜IP-13I-R14 Canonical Match Synthetic HTTP Entry Implementation Acceptance｜v0.1

Status: `ACCEPTED — TWO DEDICATED secure.transport CANONICAL MATCH POST ROUTES VERIFIED — FIVE-FIELD PRIVACY-MINIMAL HTTP RESPONSE — ALL RECOGNIZED ADAPTER-COMPLETED DOMAIN/STORAGE STATES REMAIN HTTP 200 — IP-13F/RUNTIME-READINESS UNCHANGED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R14 task-publication commit:
`c51e182dac23e4ae4ab7d183f512adc52b11658c`

Accepted implementation branch:
`review/next-ip-13i-r14-canonical-match-synthetic-http-entry-v0-1`

Accepted immutable candidate:
`5d6e51d94fdd6e9416510eb09de229381f88dcfc`

Accepted candidate tree:
`60f7e064264ba54b32f5dd98fd8367cf6a2314b2`

Accepted result blob:
`d081cdfc1218aa225639fb9495d19b419b4d0446`

Final main integration chain:

- routes:
  `1053378668dce4f2519b5e9489afcd9b6a2e991a`
- controller:
  `3d00e27c3cd5111c792515dae242f95039e02a9e`
- targeted Feature test:
  `06a85c0de2396d7d68ad7128a9ba442f9373012e`
- implementation result:
  `54e49a682e8ba058790e8ecf31b76ae0ac9d1c4c`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = c51e182dac23e4ae4ab7d183f512adc52b11658c`;
- candidate is exactly one commit ahead / zero behind;
- exactly the four authorized paths differ;
- final candidate blobs match the reported identities;
- protected Canonical Match adapter/persistence/IP-13E/IP-13F and Runtime Readiness blobs remain unchanged;
- controller source contains exactly one `evaluateSynthetic()` call site and one `invalidateSynthetic()` call site;
- controller contains no direct evaluator/IP-13E/IP-13F dispatch;
- exact four accepted blobs were transplanted to main unchanged.

## 2. Accepted routes

Accepted dedicated synthetic/dev-test entries:

- `POST /api/v2/canonical-match/evaluations`
- `POST /api/v2/canonical-match/invalidations`

Both are inside the existing:

`Route::prefix('v2')->middleware('secure.transport')`

group.

No v1 alias, no `auth:sanctum`, no new throttle and no IP-13F family were added.

## 3. Accepted controller boundary

Accepted controller:

`App\Http\Controllers\Api\V2\CanonicalMatch\CanonicalMatchEntryController`

Constructor dependency only:

`CanonicalMatchPersistenceApplicationAdapter`

Route operations:

- `evaluate(Request $request): JsonResponse`
- `invalidate(Request $request): JsonResponse`

Transport validates bounded JSON/schema structure, preserves source-purpose mismatch, normalizes only after object/list distinction is established, and dispatches exactly once to the corresponding adapter operation.

## 4. Accepted HTTP mapping

All recognized adapter-completed results return HTTP `200`.

This includes:

- PENDING;
- MUTUALLY_ACCEPTED;
- DECLINED;
- WITHDRAWN;
- EXPIRED;
- ordinary semantic UNKNOWN;
- purpose-mismatch UNKNOWN;
- dependency-invalidated UNKNOWN;
- exact duplicate;
- incomparable exact-lineage result;
- storage-rejected/retrieval-skipped;
- readback-unusable/mismatched.

Preserve:

- `HTTP_STATUS != DOMAIN_OUTCOME`
- `HTTP_STATUS != STORAGE_SUCCESS`
- `UNKNOWN != TRANSPORT_FAILURE`
- `PERSISTABLE != USABLE`

Accepted transport-owned statuses:

- `400`: malformed JSON, invalid exact schema, synthetic-boundary rejection, adapter-input rejection;
- `426`: existing `secure.transport` middleware;
- `500`: unexpected adapter failure or unrecognized/inconsistent mapping;
- no controller-owned `409`, `422`, `401`, or `403`.

## 5. Accepted success/error boundary

Successful response contains exactly:

- `match_classification`
- `reason_categories`
- `materialized_projection_usable`
- `condition`
- `synthetic_dev_test_only`

No Match payload, source evidence, source purpose, dependency identity, logical identities, revision, storage/read/binding disposition, authority/permission flags or exception information is exposed.

Controller-owned errors contain only bounded:

- `error.code`
- `error.message`
- `synthetic_dev_test_only`

The middleware-owned 426 body remains unchanged.

## 6. Accepted targeted runtime receipt

Composer Case B:

- exactly one attempt;
- exit `0`;
- `114 installs / 0 updates / 0 removals`;
- scripts/plugins disabled;
- manifest/lock unchanged.

Targeted Feature attempt:

`vendor/bin/phpunit tests/Feature/Api/V2/CanonicalMatchEntryTest.php`

Receipt:

- exactly one attempt;
- exit `0`;
- `6 tests / 556 assertions`;
- failures `0`;
- errors `0`;
- warnings `0`;
- deprecations `2`;
- no retry;
- no post-run route/controller/Feature correction.

One authorized `git diff --check` passed.

## 7. Accepted request-boundary semantics

The HTTP layer preserves domain/application ownership.

In particular:

- source-purpose mismatch is not normalized or rejected by transport;
- structurally valid missing/duplicate/outsider/cross-proposal evidence remains adapter/evaluator semantics where accepted;
- headers/query/IP/user-agent/arrival order are not semantic input;
- no request identity/idempotency key/global revision is created;
- no runtime metadata becomes actor/account authority or permission.

## 8. Accepted purpose-mismatch and invalidation behavior

Purpose mismatch:

- remains HTTP 200;
- classification `UNKNOWN`;
- reason `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- materialized projection unusable under the accepted incomplete dependency-vector semantics;
- raw source purpose remains private.

Dependency invalidation:

- remains HTTP 200;
- classification `UNKNOWN`;
- reason `DEPENDENCY_INVALIDATED`;
- exact materialization remains unusable;
- no generic invalidation identity leaks across HTTP.

## 9. IP-13F / Runtime Readiness preservation

IP-13F remains unchanged with exactly five accepted families.

The generic route remains:

`POST /api/v2/contracts/application-envelope`

Runtime Readiness remains unchanged:

`POST /api/v2/runtime-readiness/evaluations`

No universal derived-domain HTTP envelope is created.

## 10. Canonical Match vertical-slice status

The Canonical Match synthetic/dev-test vertical slice is now accepted end-to-end:

`HTTP`
→ strict transport/schema gate
→ Canonical Match application adapter
→ Canonical Match evaluator
→ Canonical Match derived record/projection
→ IP-13A reference semantics
→ IP-13D sqlite::memory:
→ IP-13E submit + conditional exact-lineage retrieval
→ privacy-minimal HTTP result.

This creates no Match source authority or automatic downstream Product Connection authority.

## 11. Next gate

The next bounded task should return to the remaining dependency order and evaluate Product Connection as the next vertical slice.

A document-only Product Connection vertical-slice entry/mapping-readiness review is required before any Product Connection persistence/application/HTTP implementation.

## 12. Preserved non-authorities

Preserve:

- Match != Connection != Conversation != Relationship;
- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- `HTTP_STATUS != DOMAIN_OUTCOME`;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no auth/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing;
- no single authoritative Compatibility score.

## 13. Acceptance classification

`IP-13I-R14 ACCEPTED — CANONICAL MATCH SYNTHETIC DOMAIN→PERSISTENCE→APPLICATION→HTTP VERTICAL SLICE VERIFIED END-TO-END — TWO DEDICATED secure.transport POST ROUTES ACCEPTED — FIVE-FIELD PRIVACY-MINIMAL RESPONSE — ALL RECOGNIZED DOMAIN/STORAGE RESULTS REMAIN HTTP 200 — 6 TESTS / 556 ASSERTIONS / 0 FAILURES / 0 ERRORS — IP-13F/RUNTIME-READINESS UNCHANGED — NEXT DOMAIN ENTRY REVIEW = PRODUCT CONNECTION`
