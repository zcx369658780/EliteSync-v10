# EliteSync v10｜IP-13I-R10 Canonical Match Domain-to-Application Mapping Review Acceptance｜v0.1

Status: `ACCEPTED — DEDICATED CANONICAL MATCH PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — PERSISTENCE FAMILY IMPLEMENTATION FIRST — IP-13E SUFFICIENT — IP-13F UNCHANGED/NON-PARTICIPATING`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R10 task-publication commit:
`20e0ab5bbc01c310d9375784eabbb8cb365f8f54`

Accepted review branch:
`review/next-ip-13i-r10-canonical-match-domain-to-application-mapping-v0-1`

Accepted immutable candidate:
`6c6d886eec8f0ee0ccd3cd0fddc893b1100be4d8`

Publication-reported candidate tree:
`4e8a9112d0069f2cbc83a03b9412c3f5990264c4`

Accepted result blob:
`0bb112750c0f6803e1d97224bf5b415763176571`

Integrated main commit:
`16bec9d85fef2dadfae3153fdd8ce929f9669fa9`

## 1. Independent acceptance

Fresh review established:

- pre-integration `origin/main = 20e0ab5bbc01c310d9375784eabbb8cb365f8f54`;
- candidate is exactly one commit ahead / zero behind;
- candidate adds exactly one authorized review-result document;
- all fixed ledger objects used by the result resolve to the exact claimed blobs;
- no code/runtime operation occurred;
- the exact accepted result blob was transplanted to main unchanged.

## 2. Accepted top-level mapping

Accepted:

`DEDICATED_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND`

A later synthetic/dev-test adapter may truthfully orchestrate:

`structural gate → CanonicalMatchProposalDecisionEvaluator::evaluate() → optional invalidate() → accepted Match derived record → one IP-13E submit → conditional exact-lineage retrieve → exact readback/materialization disposition`

This acceptance creates no Match source authority and no HTTP/transport contract.

## 3. Accepted operation split

The later adapter must expose two internal operations:

1. ordinary evaluation/materialization;
2. dependency invalidation/materialization.

Ordinary evaluation:

- structural gate first;
- exactly one evaluator `evaluate()` call;
- no invalidate call;
- no retry.

Dependency invalidation:

- same structural gate plus exact invalidation request;
- exactly one fresh evaluator `evaluate()`;
- capture exact pre-invalidation classification;
- exactly one evaluator `invalidate()`;
- no already-invalidated `UNKNOWN` may be supplied or reused as a fresh pre-invalidation source;
- no prior classification may be inferred from timestamp, storage order, arrival order, LWW or global revision.

Sticky terminality from R9-R1 remains controlling.

## 4. Accepted persistence ordering

After record construction:

1. call current IP-13E `submitAuthoritativeMutation()` exactly once;
2. inspect persistence storage disposition;
3. perform one exact-lineage retrieval only for:
   - `STORED_NEW`
   - `EXACT_DUPLICATE`
   - `INCOMPARABLE_COEXISTS`
4. skip retrieval for all rejected/unknown storage dispositions;
5. no retry.

`INCOMPARABLE_COEXISTS` is accepted as retrievable because IP-13A/IP-13D retain the record and exact-lineage resolution selects only the constructed lineage without choosing among incomparable lineages by arrival order.

## 5. Accepted readback equivalence

A Match projection is exactly equivalent only when all required generic identities/bindings and the Match payload are exact.

At minimum:

- IP-13E resolution = `RESOLVED`;
- binding classification = `EXACT`;
- exact Match record family;
- generic projection not invalidated;
- record / intent / lifecycle / lineage / projection identities match;
- represented correlation revision matches;
- derived payload passes exact Match family validation;
- canonical payload direct PHP array equality `===`;
- sticky terminality and invalidation provenance agree.

Digest equality alone is not sufficient.

## 6. Accepted materialization states

Accepted bounded internal conditions:

- `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`
- `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
- `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
- `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Match classification remains evaluator output and must not be rewritten by storage/application outcomes.

A dependency-invalidated projection may be exactly materialized while still being unusable for protected use.

## 7. Accepted sequence decision

Accepted:

`PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`

This is required because current IP-13A validates non-null derived payload only for RR03, and current IP-13D removes `derived_projection_payload` for every non-RR03 family.

Therefore the Match application adapter must not be implemented first.

The next implementation must establish the accepted Match family in both:

- IP-13A reference repository;
- IP-13D sqlite::memory: adapter.

Reference/SQLite behavioral equivalence must be proven before the Match application adapter implementation is authorized.

## 8. IP-13E / IP-13F disposition

Accepted:

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

No Match-specific IP-13E method is required.

Accepted:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

No sixth IP-13F family, Match route or HTTP contract is authorized.

## 9. Accepted next task

Next task:

`IP-13I-R11 CANONICAL MATCH PERSISTENCE FAMILY REFERENCE/SQLITE IMPLEMENTATION TASK`

It may modify exactly:

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
2. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

and create exactly:

3. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php`
4. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`

No Match application adapter, IP-13E, IP-13F, route, controller or HTTP work is authorized by this acceptance.

## 10. Preserved invariants

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- Match != Connection != Conversation != Relationship;
- invalidation != reopen;
- `UNKNOWN != ABSENT`;
- `DEFERRED != MISSING`;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no single authoritative Compatibility score;
- no authentication/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing;
- private Conversation is not default ranking/training/ads data.

## 11. Acceptance classification

`IP-13I-R10 ACCEPTED — DEDICATED CANONICAL MATCH PERSISTENCE APPLICATION MAPPING SOUND — FRESH EVALUATE + SINGLE INVALIDATE STICKY-TERMINAL FLOW FIXED — ONE IP-13E SUBMIT + CONDITIONAL EXACT-LINEAGE RETRIEVE + STRICT READBACK EQUIVALENCE ACCEPTED — PERSISTENCE FAMILY IMPLEMENTATION FIRST — IP-13E SUFFICIENT — IP-13F UNCHANGED/NON-PARTICIPATING — NEXT = IP-13I-R11 PERSISTENCE FAMILY IMPLEMENTATION — NO HTTP AUTHORIZED`
