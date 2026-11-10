# EliteSync v10｜Next IP-13I-R5 RR03 Additive Derived-Projection Persistence Application Adapter Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — SYNTHETIC DEV/TEST ONLY — NO HTTP / NO IP-13F CHANGE — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `b31e7c726c311eb1d22194e8672d8d2db70244b2`

## 1. Objective

Implement the independently accepted IP-13I-R4 contract repair for Runtime Readiness RR03.

The implementation must establish one bounded synthetic/dev-test bridge:

`synthetic prerequisite_set/member_evidence → RuntimeReadinessDerivedEvaluator → repaired RR03 logical record/projection → SQLite sqlite::memory: → existing IP-13E submit + conditional retrieve → RuntimeReadinessPersistenceApplicationAdapter result`

This task must NOT add HTTP, routes, controllers, middleware, IP-13F families, transport envelopes, authentication, client behavior, production persistence, or real/private-data processing.

Controlling invariants:

- `READINESS_DERIVATION != SOURCE_AUTHORITY`
- `STORED != AUTHORITATIVE`
- `ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY`
- `APPLICATION_RESULT != SOURCE_AUTHORITY`
- `READY != STORAGE_SUCCESS`
- `READY != AUTHORITATIVE_OUTCOME`
- `PROJECTION != PERMISSION`
- no global revision
- no synthetic aggregate dependency revision
- no LWW / arrival-order authority

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the three new paths below are absent.
6. Verify and record blobs for all fixed inputs in Section 3.
7. Stop rather than adapt if base, path, blob or authority differs.

Recommended branch:

`review/next-ip-13i-r5-rr03-derived-projection-persistence-adapter-v0-1`

## 3. Exact authorized read scope / fixed inputs

Read only:

1. `AGENTS.md`
2. IP-13I-R4 result
3. IP-13I-R4 acceptance
4. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
5. `services/backend-laravel/app/Domain/RuntimeReadinessDerivedEvaluator.php`
6. Runtime Readiness acceptance
7. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
8. IP-13A acceptance
9. `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
10. IP-13B acceptance
11. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
12. IP-13D acceptance
13. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
14. IP-13E acceptance
15. `services/backend-laravel/phpunit.xml`
16. `services/backend-laravel/composer.json`
17. `services/backend-laravel/composer.lock`

No repository search/discovery or directory enumeration is authorized.

## 4. Exact tracked write scope

Exactly these five paths are authorized:

1. MODIFY:
   `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

2. MODIFY:
   `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

3. CREATE:
   `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`

4. CREATE:
   `services/backend-laravel/tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php`

5. CREATE:
   `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_RR03_ADDITIVE_DERIVED_PROJECTION_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked file may change.

In particular, do NOT modify:
- Common Authority;
- Runtime Readiness evaluator;
- IP-13B source;
- IP-13E source;
- IP-13F source;
- routes/controllers/middleware;
- service providers/bootstrap/config;
- composer manifests.

## 5. RR03 family and additive field

Introduce exactly one RR03 record family constant/value:

`RR03_RUNTIME_READINESS_DERIVED_PROJECTION`

The generic logical record gains exactly one optional top-level key:

`derived_projection_payload`

Rules:

- for RR03 records, `derived_projection_payload` is REQUIRED and must match the exact Section 6 shape;
- for every other accepted record family, the field may be absent;
- if present on a non-RR03 record, it must be `null`;
- a non-null derived payload on a non-RR03 family must fail closed;
- unknown top-level record keys remain rejected;
- unknown nested RR03 payload keys remain rejected;
- the payload participates in record fingerprinting, immutable-intent correlation, exact duplicate semantics and privacy-minimal projection;
- `private_fixture_extensions` must never carry RR03 semantics and must remain excluded from projection.

Existing non-RR03 behavior must remain semantically unchanged.

## 6. Exact RR03 derived_projection_payload

The allowed payload is exactly:

`payload_kind`
- exact string: `RR03_RUNTIME_READINESS`

`derived_fact_class`
- exact string: `EFFECTIVE_READINESS`

`classification`
- `READY`
- `NOT_READY`
- `UNKNOWN`

`prerequisite_set_state`
- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

`prerequisite_set_identity`
- non-empty string or null

`prerequisite_set_revision`
- object or null, with exactly:
  - `authority_owner`
  - `authority_scope`
  - `aggregate_context`
  - `lineage`
  - `value`
- strings non-empty; value integer >= 0

`prerequisite_set_condition`
- PRESENT
- ABSENT
- UNKNOWN
- UNAVAILABLE
- STALE
- SUPERSEDED
- INCOMPARABLE
- null

`prerequisite_set_currentness`
- boolean or null

`prerequisite_set_freshness`
- boolean or null

`protected_use_scope`
- non-empty string or null

`reason_categories`
- ordered unique list only from:
  - UNKNOWN_PREREQUISITE_SET
  - INVALID_PREREQUISITE_SET
  - PREREQUISITE_SET_UNUSABLE
  - MISSING_REQUIRED_MEMBER
  - INVALID_REQUIRED_MEMBER
  - INCOMPARABLE_DUPLICATE_EVIDENCE
  - CONFLICTING_DUPLICATE_EVIDENCE
  - INVALID_MEMBER_FACT_CLASS
  - PROTECTED_USE_SCOPE_MISMATCH
  - MEMBER_UNUSABLE
  - UNKNOWN_MEMBER_OUTCOME
  - AUTHORITATIVE_REQUIRED_MEMBER_UNSATISFIED
  - DEPENDENCY_INVALIDATED

`dependencies`
- canonical list of entries, each containing exactly:
  - `dependency_identity`
  - `fact_class`
  - `authority_owner`
  - `authority_scope`
  - `aggregate_context`
  - `source_lineage`
  - `source_revision_value`
  - `source_condition`
  - `currentness`
  - `freshness`
  - `prerequisite_outcome`

Allowed fact classes:
- ELIGIBILITY
- CHECKLIST
- VERIFICATION

Allowed dependency source conditions:
- PRESENT
- ABSENT
- UNKNOWN
- UNAVAILABLE
- STALE
- SUPERSEDED
- INCOMPARABLE

Allowed prerequisite outcome:
- SATISFIED
- UNSATISFIED
- null

`invalidation`
- exact object:
  - `invalidated`: boolean
  - `relation`: CORRECTION | REVOCATION | SUPERSESSION | null
  - `dependency_identity`: non-empty string | null

Consistency:
- `invalidated=false` requires relation and dependency_identity null;
- `invalidated=true` requires non-null valid relation and dependency_identity.

Do not permit arbitrary nested extension keys.

## 7. Privacy boundary

The persisted/projected RR03 payload must contain NO:

- raw `source_evidence`;
- raw `required_bindings`;
- actor secrets;
- credentials/tokens;
- provider payloads;
- private profile/content;
- hidden Safety evidence;
- Conversation/message content or preview/draft;
- analytics/training/advertising signals;
- raw unselected candidate member evidence.

Only the selected privacy-minimal dependency vector and bounded reason categories may persist.

The test must use a conspicuous sentinel such as:

`MUST-NOT-LEAK-RR03-PRIVATE`

inside unpersisted/raw test fixture material and prove it is absent from:
- stored projection;
- retrieved projection;
- adapter result serialization.

## 8. Dependency canonicalization

Canonical dependency order is lexicographic by this tuple:

1. `dependency_identity`
2. `fact_class`
3. `authority_owner`
4. `authority_scope`
5. `aggregate_context`
6. `source_lineage`
7. `source_revision_value`

This ordering is only for deterministic equality/fingerprint behavior.

It creates NO:
- authority;
- precedence;
- currentness;
- recency;
- LWW;
- arrival-order meaning.

The implementation may reject duplicate canonical dependency tuples rather than silently collapse them.

## 9. Generic RR03 record revision coordinate

For RR03 only, the generic record `source_revision` is a projection-local immutable correlation coordinate.

Requirements:

- authority owner: exact constant `RUNTIME_READINESS_DERIVATION`
- authority scope: deterministic opaque/non-empty value bound to EFFECTIVE_READINESS and the exact protected-use scope
- aggregate context: exact generic binding aggregate context
- lineage: exact generated RR03 lineage identity
- value: exactly integer `0`

This source revision MUST NOT be interpreted as:
- prerequisite source revision;
- aggregate dependency revision;
- global revision;
- ordering/recency;
- source authority.

Different dependency vectors must generate different lineages and coexist.

Existing generic revision comparison behavior must not silently cause one distinct RR03 dependency vector to replace another.

## 10. Generic source condition/currentness/freshness for RR03

For RR03:

- generic `source_condition = PRESENT` means only the immutable derived-projection record is materially present;
- it does NOT mean prerequisites are satisfied or READY.

Generic record currentness:
- true only when all required selected dependencies are established current and projection not invalidated;
- false only when a required selected dependency is affirmatively not current;
- null where exact completeness/currentness is unknown.

Generic record freshness follows the same rule independently.

These summary fields must never replace per-dependency fields inside the payload.

## 11. Authoritative outcome

For this first synthetic slice:

- `authoritative_outcome = UNKNOWN`
- `authoritative_outcome_metadata = null`

Readiness classification must NEVER be encoded as:
- COMMITTED/REJECTED;
- source_condition;
- storage_outcome;
- transport_observation;
- projection lag;
- generic record family.

Storage success cannot upgrade authoritative outcome.

## 12. Identity / intent model

Use deterministic opaque SHA-256 correlation identities over canonical privacy-minimal semantic input.

Required namespaces:

- logical record identity: `rr03-record-v1:<digest>`
- logical intent identity: `rr03-intent-v1:<digest>`
- source/projection lineage: `rr03-lineage-v1:<digest>`
- projection identity: `rr03-projection-v1:<digest>`
- lifecycle identity: `rr03-lifecycle-v1:<digest>`

The main digest must include at least:
- record family;
- exact generic subject/participants/audience/purpose/context bindings;
- lifecycle basis;
- exact RR03 payload before invalidation overlay.

Lifecycle digest basis:
- prerequisite-set identity;
- protected-use scope;
- exact generic subject/participants/audience/purpose/context;
- excludes readiness classification;
- excludes dependency revision values.

Rules:
- digest = equality/correlation only;
- not authentication, permission, authority, secrecy or bearer capability;
- exact duplicate only for exact canonical semantic identity;
- changed semantic input under reused identity fails closed;
- same set with different dependency revisions/conditions/currentness/freshness/outcomes creates distinct record/intent/lineage;
- distinct vectors coexist;
- no timestamp/rowid/request-order component.

## 13. Projection behavior

IP-13A and IP-13D privacy-minimal projections for RR03 must include:

`derived_projection_payload`

with the validated immutable RR03 payload plus current invalidation overlay.

Projection invalidation overlay:
- does not mutate stored payload;
- if repository invalidation exists, emitted payload `invalidation` must reflect:
  - invalidated=true
  - relation
  - dependency/logical reference where deterministically available under accepted invalidation representation;
- projection becomes unusable/current-resolution INVALIDATED according to existing semantics;
- lifecycle_reset=false;
- reopened=false;
- no new aggregate;
- no synthetic transition.

Do not invent dependency-wide invalidation lookup outside current authorized scope. The adapter-level test may drive invalidation through the RR03 logical record identity unless exact existing APIs support finer dependency mapping without expanding source scope.

If exact dependency→dependent-record invalidation cannot be implemented within the two authorized persistence-source changes, report that retained limitation precisely rather than expanding scope.

## 14. IP-13B conformance

Do NOT modify IP-13B.

Existing six families remain:

- STORE
- READ_EXACT
- RESOLVE_CURRENT
- READ_HISTORY
- OBSERVE_INVALIDATION
- PRIVACY_MINIMAL_PROJECTION

The targeted test must submit RR03 reference/SQLite results to IP-13B and prove equivalent RR03 scenarios are CONFORMANT across applicable operation families.

At minimum prove:
- exact RR03 projection payload equality is compared;
- changed classification or dependency semantics becomes NON_CONFORMANT where reference/candidate shapes are complete;
- incomplete/missing payload evidence becomes UNKNOWN;
- private material or synthesized authority remains NON_CONFORMANT.

If current IP-13B code cannot satisfy required proof without source modification, STOP and report blocker. Do not modify IP-13B.

## 15. IP-13D physical behavior

Do NOT change:
- DSN `sqlite::memory:`;
- table count;
- schema/columns;
- migration behavior.

Modify only as necessary so validated RR03 `derived_projection_payload` survives:
- storage JSON;
- readExact;
- resolveCurrent;
- readHistory;
- privacyMinimalProjection;
- invalidation projection overlay.

No second physical representation.

## 16. RuntimeReadinessPersistenceApplicationAdapter

Create exactly:

`App\Domain\RuntimeReadinessPersistenceApplicationAdapter`

It depends on one existing:

`PersistenceBoundaryApplicationInterfaceIntegrationContract`

It must not call SQLite/PDO/repository directly.

Public operation may be named:

`evaluateSynthetic(array $prerequisiteSet, array $memberEvidence): array`

No other public domain operation is needed.

Exact sequence:

1. reject malformed/non-synthetic input before persistence;
2. invoke `RuntimeReadinessDerivedEvaluator::derive()` exactly once;
3. transform only privacy-minimal evaluator output/dependency metadata into the accepted RR03 payload;
4. construct deterministic RR03 logical record;
5. call IP-13E `submitAuthoritativeMutation()` exactly once;
6. only when persistence reports `STORED_NEW` or `EXACT_DUPLICATE`, call IP-13E `retrieveCurrentProjection()` exactly once;
7. exact-compare returned RR03 payload to built payload;
8. return domain-adapter result.

If storage rejects:
- skip retrieval;
- preserve evaluator classification;
- materialized projection unusable=false.

If retrieval is MISSING/UNKNOWN/STALE/SUPERSEDED/INCOMPARABLE/INVALIDATED/binding mismatch/payload mismatch:
- preserve evaluator classification;
- materialized projection usable=false;
- fail composition condition closed.

No retry.

## 17. Exact adapter result boundary

Return one deterministic result that separates:

- `record_kind = RUNTIME_READINESS_PERSISTENCE_APPLICATION_ADAPTER_RESULT`
- `readiness_classification`
- `rr03_payload`
- `logical_record_identity`
- `storage_disposition`
- `projection_read_disposition`
- `materialized_projection_usable`
- `authoritative_outcome`
- `reconciliation_required`
- `invalidation_required`
- `revalidation_required`
- `transport_disposition = null`
- `http_status = null`
- bounded explanation/condition
- explicit non-authority fields.

Mandatory false/non-authority fields at minimum:

- source_authority
- domain_writer_authority
- authoritative_mutation_success
- permission
- permission_token
- bearer_capability
- authentication_authority
- transport_execution_authority
- http_semantics
- controller_authority
- route_authority
- production_ready
- deployable
- real_data_authorized
- match_authority
- connection_authority
- consent_authority
- conversation_authority
- relationship_authority
- launch_authority

`readiness_classification` must be independent from all of them.

## 18. Synthetic-input boundary

R5 is synthetic/dev-test only.

The adapter must fail closed unless fixture/input marks are conspicuously synthetic according to one deterministic bounded convention defined in the test/implementation.

Do not infer real user identity.

No:
- HTTP metadata;
- auth principal;
- IP;
- user-agent;
- session;
- token;
- provider result;
- production prerequisite-set source.

The exact product prerequisite set remains unestablished.

## 19. Mandatory targeted test obligations

Create exactly:

`services/backend-laravel/tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php`

The one targeted test file must prove at least:

1. READY survives evaluator→record→SQLite→IP-13E submit/retrieve→adapter result.
2. NOT_READY survives.
3. UNKNOWN survives.
4. UNKNOWN_PREREQUISITE_SET remains distinct from known empty set.
5. exact RR03 payload keys only.
6. bounded reason categories only, with no identity suffix leakage.
7. canonical dependency ordering.
8. each dependency owner/scope/context/lineage/revision/condition/currentness/freshness/outcome preserved.
9. generic record revision value exactly 0 and not used as dependency/global revision.
10. distinct dependency vectors create distinct coexisting record/intent/lineage identities.
11. exact duplicate returns correlation-compatible storage semantics without authority upgrade.
12. changed-input identity reuse fails closed where exercised.
13. authoritative outcome remains UNKNOWN.
14. storage success does not imply READY or authoritative mutation success.
15. retrieval success does not change readiness classification.
16. storage rejection skips retrieval.
17. projection mismatch/unusable readback fails materialized projection closed without changing evaluator classification.
18. RR03 derived payload appears in IP-13A and SQLite projections.
19. non-RR03 records retain prior behavior when derived payload absent.
20. non-RR03 non-null derived payload rejected.
21. malformed/extra nested RR03 payload keys rejected.
22. prohibited private sentinel never appears in stored/retrieved/adapter result.
23. invalidation makes projection unusable without lifecycle reopen/reset.
24. IP-13B classifies equivalent RR03 reference/SQLite outputs CONFORMANT across all applicable six operation families.
25. deliberate RR03 semantic mutation becomes NON_CONFORMANT.
26. incomplete candidate/reference RR03 evidence becomes UNKNOWN where applicable.
27. IP-13D schema/DSN/table count unchanged.
28. no HTTP/IP-13F behavior or fields are introduced.
29. all mandatory adapter non-authority fields remain false.
30. inputs are not mutated.

Use conspicuous synthetic fixtures only.

## 20. Same-worktree vendor bootstrap

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
Manifest/lock must remain byte/blob identical.

## 21. Exact runtime command budget

Run exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php`

No retry.

Do NOT run:
- full suite;
- any other Unit/Feature test;
- coverage;
- mutation;
- Artisan;
- route:list;
- migrations;
- generators;
- server;
- provider/network;
- HTTP/client;
- production;
- real/private-data operations.

After final authoring run exactly once:

`git diff --check`

## 22. Failure handling

If the single targeted PHPUnit attempt fails:

- do not retry;
- static correction after the consumed run is permitted only within the exact five-path write scope;
- do not claim runtime PASS after a post-run static correction;
- publish the final immutable candidate with runtime status `RETAINED_UNKNOWN`;
- fresh independent review may authorize a verification-only rerun task.

If fixing the issue requires any path outside the exact write scope:
- STOP;
- report blocker;
- do not expand scope.

## 23. Result document

Record:

- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact five-path scope;
- pre/post blobs for modified IP-13A/IP-13D;
- source/test/result blobs;
- all fixed input blobs;
- exact RR03 additive record/projection implementation;
- exact validation/privacy rules;
- identity/intent/revision behavior;
- IP-13B conformance receipts;
- IP-13D schema/DSN unchanged proof;
- adapter sequence and result boundary;
- synthetic-only guard;
- Composer Case A/B receipt;
- targeted PHPUnit receipt;
- warnings/deprecations;
- manifest/lock identities;
- `git diff --check`;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R5 RR03 ADDITIVE DERIVED-PROJECTION PERSISTENCE APPLICATION ADAPTER IMPLEMENTED — RUNTIME READINESS EVALUATOR OUTPUT LOSSLESSLY MATERIALIZED THROUGH ACCEPTED IP-13A/IP-13D AND COMPOSED THROUGH EXISTING IP-13E SUBMIT+RETRIEVE — EXISTING SIX IP-13B FAMILIES RETAINED — IP-13F/HTTP UNCHANGED — TARGETED UNIT TEST PASS — SYNTHETIC DEV/TEST ONLY — NO AUTH/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
