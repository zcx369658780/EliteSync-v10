# EliteSync v10｜Next IP-13I-R12 Canonical Match Persistence Application Adapter Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT THREE-PATH SYNTHETIC/DEV-TEST APPLICATION-ADAPTER IMPLEMENTATION — ONE TARGETED UNIT ATTEMPT — NO HTTP / NO IP-13E / NO IP-13F CHANGES — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-parent main:
`10c47c14dd6cb0e3fefdfea73825e35374667d55`

Accepted R11 acceptance blob:
`64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c`

Accepted R10 result blob:
`0bb112750c0f6803e1d97224bf5b415763176571`

R10 acceptance blob:
`9b23e5f506030d492ef8c617108f906f12fe839d`

Accepted R9-R1 result blob:
`114eb27d2766657d9e6fb364ce83fc8fee82c66d`

R9-R1 acceptance blob:
`44f3ee11a0fedbdf80c0c27be47063f42a370cd9`

## 1. Objective

Implement only the dedicated synthetic/dev-test Canonical Match persistence application adapter accepted by R10, against the accepted R11 persistence family.

The executable chain must be:

ordinary:
`synthetic structural gate → CanonicalMatchProposalDecisionEvaluator::evaluate() exactly once → accepted Match payload/record construction → IP-13E submit exactly once → conditional exact-lineage retrieve → exact readback/materialization result`

dependency invalidation:
`synthetic structural gate → evaluate() exactly once → exact pre-invalidation binding → invalidate() exactly once → sticky-terminal Match payload/record construction → IP-13E submit exactly once → conditional exact-lineage retrieve → unusable-but-faithfully-materialized result`

This task must not change persistence contracts already accepted by R11.

No HTTP, route, controller, IP-13F family, client, provider, production or real-data work is authorized.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R12 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated implementation branch/worktree from exactly that commit.
6. Verify the three create paths in Section 4 are absent.
7. Verify every fixed input in Section 3.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r12-canonical-match-persistence-application-adapter-v0-1`

No repository enumeration or unrelated discovery.

## 3. Exact authorized read scope / fixed inputs

Read only:

1. `AGENTS.md`
2. this R12 task
3. R11 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_REFERENCE_SQLITE_IMPLEMENTATION_TASK_V0_1.md`
4. R11 implementation result:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`
5. R11 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
6. R10 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_TASK_V0_1.md`
7. accepted R10 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`
8. R10 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_ACCEPTANCE_V0_1.md`
9. accepted R9-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`
10. R9-R1 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
11. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
12. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
13. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
14. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
15. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
16. `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php` — implementation-style contrast only
17. `services/backend-laravel/tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php` — targeted-test style contrast only
18. `services/backend-laravel/phpunit.xml`
19. `services/backend-laravel/composer.json`
20. `services/backend-laravel/composer.lock`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R11 acceptance:
  `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c`
- R10 result:
  `0bb112750c0f6803e1d97224bf5b415763176571`
- R10 acceptance:
  `9b23e5f506030d492ef8c617108f906f12fe839d`
- R9-R1 result:
  `114eb27d2766657d9e6fb364ce83fc8fee82c66d`
- R9-R1 acceptance:
  `44f3ee11a0fedbdf80c0c27be47063f42a370cd9`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`
- IP-13D:
  `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`
- Runtime Readiness adapter test:
  resolve and record exact blob;
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`

No other source read is authorized.

## 4. Exact tracked write scope

Create exactly three paths:

1. `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
2. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
3. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Do NOT modify:

- Canonical Match evaluator;
- Common Authority;
- IP-13A;
- IP-13D;
- IP-13E;
- IP-13F;
- Runtime Readiness adapter/test;
- routes/controllers/Feature tests;
- migrations/config/providers/bootstrap;
- Composer manifests;
- client/provider/network code.

## 5. Exact adapter class and dependency

Create final class:

`App\Domain\CanonicalMatchPersistenceApplicationAdapter`

Constructor dependency exactly:

`PersistenceBoundaryApplicationInterfaceIntegrationContract`

No direct SQLite/PDO/IP-13A dependency.

Public synthetic marker constant exactly:

`ELITESYNC_CANONICAL_MATCH_SYNTHETIC_DEV_TEST_V1`

No authentication/session/token dependency.

## 6. Exact public operations

Expose exactly two public application operations:

### 6.1 Ordinary

`evaluateSynthetic(array $request): array`

Exact request top-level keys:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`

### 6.2 Dependency invalidation

`invalidateSynthetic(array $request): array`

Exact request top-level keys:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`
- `invalidation_request`

`invalidation_request` exact keys:

- `dependency_identity`: non-empty string
- `relation`: `CORRECTION | REVOCATION | SUPERSESSION`

No operation accepts:
- evaluator result;
- existing payload;
- persisted projection;
- prior classification;
- HTTP request;
- actor/session/token/provider object.

## 7. Exact nested structural gate

### Proposal exact keys

- `proposal_identity`
- `participants`
- `protected_use_scope`
- `lifecycle_state`
- `at_most_one_unresolved_precondition`
- `required_bindings`
- `source_evidence`

Require:
- proposal identity/scope non-empty strings;
- participants exact JSON/PHP list of exactly two unique non-empty strings;
- lifecycle:
  `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- unresolved-precondition marker boolean;
- exact Common Authority binding/evidence/revision shape.

### Participation item exact keys

- `participant_identity`
- `state`
- `required_bindings`
- `source_evidence`

State:
`NOT_ENROLLED | ENROLLED | PAUSED | WITHDRAWN`

The list itself and each supplied item must be structurally valid.
A missing participant, duplicate supplied participant, or outsider participant remains evaluator-domain semantics when item shape itself is valid.

### Decision-slot item exact keys

- `slot_identity`
- `proposal_identity`
- `participant_identity`
- `protected_use_scope`
- `decision`
- `required_bindings`
- `source_evidence`

Decision:
`PENDING | ACCEPTED | DECLINED | WITHDRAWN`

Structurally valid cross-proposal/wrong-participant references remain evaluator-domain semantics.

### Common Authority source evidence exact keys

- `record_kind = SOURCE_EVIDENCE`
- `bindings`
- `source_condition`
- `source_revision`
- `currentness`
- `freshness`
- `authoritative_outcome`

Bindings use the exact eleven-key Common Authority shape.
Revision uses exact owner/scope/lineage/context/value shape with non-negative integer value.
Owner/scope/context must bind correctly.
Currentness/freshness are bool|null.
Authoritative outcome uses accepted Common Authority vocabulary.

Use Common Authority validation; do not weaken it.

Any structural gate rejection throws `InvalidArgumentException` and performs:
- zero evaluator calls;
- zero persistence submits;
- zero retrievals.

No adapter result object is returned for structural rejection.

## 8. Ordinary evaluator flow

`evaluateSynthetic()` performs exactly:

1. exact structural gate;
2. call `CanonicalMatchProposalDecisionEvaluator::evaluate()` exactly once;
3. do not mutate input arrays;
4. validate returned evaluator structure/non-authority fields;
5. enforce record-eligibility/collision rules;
6. reduce reasons to accepted fifteen-category canonical list;
7. build exact Match payload;
8. build exact Match record;
9. call IP-13E submit exactly once;
10. conditionally retrieve exactly once;
11. return bounded internal result.

No second evaluator call.
No invalidate call.
No retry.

## 9. Invalidation evaluator flow

`invalidateSynthetic()` performs exactly:

1. exact structural gate including invalidation request;
2. call `evaluate()` exactly once on supplied original evidence;
3. validate/bind that pre-invalidation result;
4. construct its persisted dependency identity set;
5. require requested dependency identity to resolve exactly once;
6. capture bounded pre-invalidation classification;
7. call evaluator `invalidate()` exactly once;
8. require returned:
   - classification `UNKNOWN`;
   - reasons exactly `[DEPENDENCY_INVALIDATED]`;
   - same dependency vector;
   - requested identity/relation;
   - lifecycle reset false;
   - proposal reopened false;
9. construct sticky-terminal payload;
10. construct record;
11. submit once;
12. conditionally retrieve once;
13. return bounded result.

No caller-supplied previous result.
No timestamp/history-order inference.
No generic IP-13E `observeInvalidation()` call in this dependency-scoped operation.

Repeated identical invalidation input is deterministic/idempotent correlation, not a second transition fact.

## 10. Evaluator output eligibility

Before record construction require exact accepted evaluator output shape/values.

Persistable reasons are exactly the accepted fifteen categories after suffix reduction.

Pre-materialization-only diagnostics must never reach record construction:

- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `INVALID_PROPOSAL_SHAPE`
- `INVALID_SLOT_EVIDENCE`
- `INVALID_SLOT_DECISION`

Unmapped evaluator reason → throw `InvalidArgumentException`, no submit.

Require proposal/participant/selected-slot dependency identities collision-free across types exactly as R9-R1/R11.

## 11. Exact payload construction

Construct the exact accepted R11 payload:

- `payload_kind = CANONICAL_MATCH_PROPOSAL_DECISION`
- `derived_fact_class = CANONICAL_MATCH_PROPOSAL_DECISION`
- evaluator classification
- proposal identity
- protected-use scope
- canonical bounded reasons
- proposal dependency
- canonical participation dependencies
- canonical selected-slot dependencies
- terminality
- invalidation

Copy source-local dependency owner/scope/context/lineage/revision/condition from evaluator-selected evidence.
Recover currentness/freshness only from the exactly matched supplied evidence corresponding to the selected dependency.

Do not persist raw evidence/bindings.

Canonical list ordering must match R11.

Top-level currentness/freshness must be independently aggregated exactly as accepted by R11.

## 12. Sticky terminality construction

Ordinary:
- `classification_before_invalidation=null`;
- derived terminal follows current classification.

Invalidation:
- current classification = `UNKNOWN`;
- prior classification = exact fresh pre-invalidation evaluator classification;
- derived terminal follows prior classification;
- terminal prior classification keeps `bindings.terminal=true`;
- lifecycle reset false;
- proposal reopened false.

An already-invalidated UNKNOWN cannot be reconstructed from caller input because no such input surface exists.

## 13. Exact record construction

Use accepted family:

`InMemoryLogicalPersistenceRepositoryContract::RECORD_FAMILY_CANONICAL_MATCH`

Derived bindings:
- owner `CANONICAL_MATCH_DERIVATION`
- scope `CANONICAL_MATCH_PROPOSAL_DECISION|<protected_use_scope>`
- actor / actor_role / subject / audience / purpose copied from proposal required bindings
- participants sorted lexicographically
- aggregate context = proposal identity
- deterministic lifecycle identity
- terminal = payload sticky derived terminal

Top-level:
- source condition = `PRESENT`
- authoritative outcome = `UNKNOWN`
- authoritative outcome metadata = null
- correction metadata = null
- transport observation = `AMBIGUOUS`
- private fixture extensions = []
- correlation revision value = 0

Use exactly the R11 deterministic lifecycle digest and semantic digest contracts.

Do not invent other record fields.

## 14. Exact IP-13E submit/retrieve ordering

Call `submitAuthoritativeMutation()` exactly once.

Retrievable storage outcomes:

- `STORED_NEW`
- `EXACT_DUPLICATE`
- `INCOMPARABLE_COEXISTS`

Only for those, call `retrieveCurrentProjection()` exactly once.

All others:
- skip retrieval;
- no retry.

Exact query:
- Match record family
- derived authority owner
- derived authority scope
- proposal aggregate context
- exact constructed lineage

Exact request bindings:
- viewer = derived actor
- subject
- canonical participants
- audience
- purpose
- aggregate context

No runtime/auth identity inference.

## 15. Exact readback equivalence

Readback is exact only if all hold:

- IP-13E resolution = `RESOLVED`;
- binding classification = `EXACT`;
- record family exact Match family;
- generic projection invalidated = false;
- logical record identity exact;
- logical intent identity exact;
- lifecycle identity exact;
- source projection lineage exact;
- projection identity exact;
- represented revision value = 0;
- readback Match payload present;
- direct PHP array equality `===` with constructed canonical payload;
- terminality/invalidation exact.

Digest equality alone is insufficient.

## 16. Exact materialization conditions

Internal condition exactly one of:

1. `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`
2. `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
3. `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
4. `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Condition 1:
- exact readback;
- payload not dependency-invalidated;
- usable=true;
- invalidation_required=false;
- revalidation_required=false.

Condition 2:
- exact readback;
- payload dependency-invalidated;
- usable=false;
- invalidation_required=true;
- revalidation_required=true.

Condition 3:
- storage not retrievable;
- usable=false;
- read disposition null;
- revalidation_required=true.

Condition 4:
- retrieval attempted but exact equivalence failed or generic projection invalidated;
- usable=false;
- revalidation_required=true.

Match classification is always evaluator output and never rewritten by these conditions.

## 17. Exact adapter result key set

For structurally accepted operations return exactly the 39 keys fixed by R10:

1. `record_kind`
2. `operation`
3. `match_classification`
4. `reason_categories`
5. `match_payload`
6. `logical_record_identity`
7. `logical_intent_identity`
8. `lifecycle_identity`
9. `source_projection_lineage`
10. `derived_correlation_revision`
11. `storage_disposition`
12. `projection_read_disposition`
13. `binding_classification`
14. `materialized_projection_usable`
15. `authoritative_outcome`
16. `reconciliation_required`
17. `invalidation_required`
18. `revalidation_required`
19. `condition`
20. `synthetic_dev_test_only`
21. `source_local_revision_only`
22. `global_revision`
23. `last_write_wins`
24. `last_received_wins`
25. `transport_disposition`
26. `http_status`
27. `source_authority`
28. `match_authority`
29. `connection_authority`
30. `consent_authority`
31. `conversation_authority`
32. `relationship_authority`
33. `home_action_authority`
34. `notification_delivery_authority`
35. `launch_authority`
36. `permission`
37. `bearer_capability`
38. `production_ready`
39. `real_data_authorized`

Fixed:
- record kind `CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_RESULT`
- operation `EVALUATE | INVALIDATE`
- synthetic marker result = true
- source-local-revision-only = true
- transport disposition/http status = null
- keys 22–24 and 27–39 = false

No raw source evidence in result.

## 18. Exact targeted Unit test

Create:

`services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

Single file must cover at minimum:

1. ordinary PENDING exact materialization;
2. MUTUALLY_ACCEPTED exact materialization and sticky terminal lifecycle;
3. DECLINED/WITHDRAWN terminal behavior;
4. semantic UNKNOWN remains domain classification and may materialize exactly when record current/fresh aggregates permit;
5. structural malformed proposal rejected before evaluator/persistence;
6. malformed participation/slot/evidence rejected before persistence;
7. valid missing participation persists bounded UNKNOWN;
8. valid missing slot persists bounded UNKNOWN;
9. cross-proposal/wrong-participant slot persists bounded UNKNOWN;
10. duplicate slot incomparable/conflict reason reduction;
11. reason suffixes reduced without leaking identity/condition text into reason categories;
12. input arrays not mutated;
13. invalidation operation does fresh evaluate once + invalidate once semantically;
14. terminal MUTUALLY_ACCEPTED → invalidated UNKNOWN retains sticky terminal=true;
15. non-terminal invalidation remains terminal=false;
16. invalidation target collision/unknown target rejected before submit;
17. repeated identical invalidation yields exact duplicate correlation;
18. exact duplicate ordinary input yields exact duplicate correlation;
19. changed dependency revision vector creates distinct identity/lineage and can retrieve exact incomparable lineage;
20. terminal lifecycle followed by non-terminal fresh evaluation is storage rejected and retrieval skipped;
21. generic overlay invalidation causes readback unusable without changing evaluator classification;
22. dependency-invalidated exact projection is faithfully materialized but usable=false;
23. storage rejection condition;
24. exact readback mismatch/family/identity/payload mismatch fail closed;
25. request binding mismatch fail closed;
26. authoritative outcome remains UNKNOWN;
27. all mandatory non-authority fields remain false;
28. no raw evidence/private sentinel in adapter result;
29. no IP-13F dependency/reference;
30. no transport/http semantics;
31. exactly one submit source location per operation path and no retry;
32. accepted R11 Match family is used; no RR03 alias.

Bounded reflection/test seam is permitted inside this test file to exercise private readback/result mapping mismatch cases without modifying production dependencies.

No helper file.
No second test file.

## 19. Composer bootstrap

Check only:
- `vendor/autoload.php`
- `vendor/bin/phpunit`

If both exist: Case A, no Composer.

Otherwise exactly once:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry/update/scripts/plugins.
Manifest/lock unchanged.

## 20. Runtime command budget

Exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

No retry.

No other Unit/Feature/full-suite/coverage/mutation/Artisan/route/migration/generator/server/HTTP/database external probe/provider/network/production/real-data command.

After final authoring run exactly one:

`git diff --check`

## 21. Failure handling

If the one PHPUnit attempt fails:

- no rerun;
- static correction after the consumed run is permitted only inside the exact three-path write scope;
- after any post-run correction, runtime status becomes `RETAINED_UNKNOWN`;
- publish immutable candidate and stop for fresh independent review/possible verification-only authorization.

If a fix needs:
- IP-13A/IP-13D change;
- IP-13E/IP-13F change;
- evaluator/Common Authority change;
- fourth tracked path;
- HTTP work;

STOP and record blocker.

## 22. Result document

Create:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

Record:
- task authority;
- branch/candidate/sole parent/tree/ahead-behind;
- exact three-path scope;
- all fixed input blobs;
- new adapter/test/result blobs;
- ordinary/invalidation operation behavior;
- structural gate;
- evaluator call counts;
- sticky terminality behavior;
- deterministic record construction;
- IP-13E submit/retrieve ordering;
- readback equivalence;
- materialization conditions;
- duplicate/incomparable/reopen behavior;
- privacy/non-authority proof;
- Composer receipt;
- exact PHPUnit receipt;
- warnings/deprecations;
- manifest/lock blobs;
- one diff-check receipt;
- tracked/staged counts;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R12 CANONICAL MATCH PERSISTENCE APPLICATION ADAPTER IMPLEMENTED — ORDINARY AND STICKY-INVALIDATION SYNTHETIC FLOWS ESTABLISHED — EXACT MATCH RECORD CONSTRUCTION + ONE IP-13E SUBMIT + CONDITIONAL EXACT-LINEAGE READBACK VERIFIED — DEPENDENCY-INVALIDATED PROJECTION FAITHFULLY MATERIALIZED BUT UNUSABLE — DUPLICATE/INCOMPARABLE/TERMINAL-REOPEN/PRIVACY/NON-AUTHORITY BOUNDARIES TARGETED PASS — IP-13F/HTTP UNCHANGED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
