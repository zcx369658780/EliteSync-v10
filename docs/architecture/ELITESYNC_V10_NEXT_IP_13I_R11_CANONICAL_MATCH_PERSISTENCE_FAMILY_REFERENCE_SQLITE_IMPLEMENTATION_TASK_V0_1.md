# EliteSync v10｜Next IP-13I-R11 Canonical Match Persistence Family Reference/SQLite Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT FOUR-PATH PERSISTENCE-FAMILY IMPLEMENTATION — ONE TARGETED UNIT ATTEMPT — NO APPLICATION ADAPTER / IP-13E / IP-13F / HTTP — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-parent main:
`e31058b5890604f8ffa7cceea8f2734c44ba8442`

Accepted R10 result blob:
`0bb112750c0f6803e1d97224bf5b415763176571`

R10 acceptance blob:
`9b23e5f506030d492ef8c617108f906f12fe839d`

Accepted R9-R1 result blob:
`114eb27d2766657d9e6fb364ce83fc8fee82c66d`

R9-R1 acceptance blob:
`44f3ee11a0fedbdf80c0c27be47063f42a370cd9`

## 1. Objective

Implement only the accepted Canonical Match derived persistence family in both accepted persistence realizations:

1. IP-13A reference:
   `InMemoryLogicalPersistenceRepositoryContract`
2. IP-13D disposable physical adapter:
   `SqliteInMemoryLogicalPersistenceAdapter`

Establish reference/SQLite behavioral equivalence for:

`CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`

This task does NOT implement:

- the Canonical Match persistence application adapter;
- evaluator orchestration;
- IP-13E changes;
- IP-13F changes;
- route/controller/HTTP behavior;
- production persistence;
- migrations or schema expansion;
- real/private-data handling.

Controlling invariants:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`
- `STORED != AUTHORITATIVE`
- invalidation != reopen
- Match != Connection != Conversation != Relationship
- no global revision
- no LWW / arrival-order / timestamp authority
- no auth/session/token authority
- no production/real-data authority

## 2. Mandatory fresh-base gate

Before any tracked write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R11 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Read this task.
6. Create one isolated implementation branch/worktree from exactly that commit.
7. Verify the create paths in Section 4 are absent.
8. Verify all fixed input blobs in Section 3.
9. Stop rather than adapt if any authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r11-canonical-match-persistence-family-v0-1`

No repository enumeration or unrelated source discovery.

## 3. Exact authorized read scope / fixed inputs

Read only:

1. `AGENTS.md`
2. this R11 task
3. R10 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_TASK_V0_1.md`
4. accepted R10 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`
5. R10 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_ACCEPTANCE_V0_1.md`
6. R9-R1 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_TASK_V0_1.md`
7. accepted R9-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`
8. R9-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
9. rejected R9 result at exact candidate
   `b03966d09e91430a31a03eecf5d3b8575602357d`:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`
   only for schema portions explicitly preserved by accepted R9-R1
10. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
11. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
12. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
13. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
14. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php` — contrast only
15. `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php` — deterministic-correlation contrast only

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R10 task:
  `7e244fe1ee1425da15300a1d41564d6d4c3ab236`
- R10 result:
  `0bb112750c0f6803e1d97224bf5b415763176571`
- R10 acceptance:
  `9b23e5f506030d492ef8c617108f906f12fe839d`
- R9-R1 task:
  `ac3b9c0bf5dad0ffada8ecd1e188935ef6a41ff7`
- R9-R1 result:
  `114eb27d2766657d9e6fb364ce83fc8fee82c66d`
- R9-R1 acceptance:
  `44f3ee11a0fedbdf80c0c27be47063f42a370cd9`
- rejected R9 result:
  `1f8394b25ee54373bf4d4e8836075b13b8efcbf1`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13D:
  `a81535d174015bb0ecaa9f8caeaabb7490c4354b`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`

No other source read is authorized.

## 4. Exact tracked write scope

Exactly four tracked paths may change.

### MODIFY

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

2. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

### CREATE

3. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php`

4. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked path may change.

Do NOT modify:

- Canonical Match evaluator;
- Common Authority;
- IP-13E;
- IP-13F;
- Runtime Readiness application adapter;
- existing Runtime Readiness controller/test;
- routes;
- migrations;
- database config;
- providers/bootstrap/config;
- Composer manifests;
- client/provider/network code.

## 5. Additive record-family constant and dispatch

Add one exact reference-family constant:

`RECORD_FAMILY_CANONICAL_MATCH = 'CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION'`

Do not rename or weaken the existing:

`RECORD_FAMILY_RR03 = 'RR03_RUNTIME_READINESS_DERIVED_PROJECTION'`

Family-specific derived payload behavior must be explicit:

- RR03 → existing RR03 validator/retention unchanged;
- Canonical Match → exact Match validator/retention defined by this task;
- every other record family with non-null `derived_projection_payload` → reject exactly as before.

Do not create a generic “any derived payload” escape hatch.

## 6. Exact Canonical Match envelope boundary

For the Match family, require:

- `record_family = CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- non-null valid Match `derived_projection_payload`;
- `bindings.authority_owner = CANONICAL_MATCH_DERIVATION`;
- `bindings.authority_scope = CANONICAL_MATCH_PROPOSAL_DECISION|<protected_use_scope>`;
- `bindings.aggregate_context = payload.proposal_identity`;
- `bindings.participants` is exactly two unique non-empty strings in lexicographic canonical order;
- `bindings.purpose = payload.protected_use_scope`;
- `bindings.terminal = payload.terminality.derived_terminal`;
- `source_revision.authority_owner = CANONICAL_MATCH_DERIVATION`;
- source revision owner/scope/context match bindings;
- `source_revision.value = 0`;
- `source_revision.lineage` is the deterministic accepted Match lineage;
- `source_condition = PRESENT`;
- `authoritative_outcome = UNKNOWN`;
- `authoritative_outcome_metadata = null`;
- `correction_metadata = null` for this first synthetic/dev-test family implementation;
- `transport_observation = AMBIGUOUS`;
- `private_fixture_extensions = []`.

Common Authority generic envelope validation remains in force.

No Match source authority is created.

## 7. Exact deterministic correlation validation

R11 must validate—not merely store—the accepted deterministic Match correlation identities.

Use the established PHP canonical digest mechanism:

`hash('sha256', serialize(canonicalize(value)))`

where:

- associative keys are recursively sorted;
- list order is preserved only where the accepted contract already requires canonical order;
- bindings participants are canonical sorted;
- reason categories and typed dependency lists must already satisfy their canonical ordering.

The exact semantic-input object contains exactly:

- `record_family`
- `bindings`
- `derived_projection_payload`
- `schema_marker = canonical-match-derived-projection-v1`

Digest this exact object.

Require:

- `logical_record_identity = canonical-match-record-v1:<digest>`
- `logical_intent.intent_identity = canonical-match-intent-v1:<digest>`
- `source_revision.lineage = canonical-match-lineage-v1:<digest>`
- `projection_metadata.projection_identity = canonical-match-projection-v1:<digest>`
- `logical_intent.semantic_input` equals the exact semantic-input object above.

Reject any changed identity/prefix/digest/semantic-input binding.

This is correlation only, not source authority.

## 8. Exact lifecycle identity validation

Construct/validate the lifecycle-basis object from exactly:

- record family;
- proposal identity;
- protected-use scope;
- subject;
- canonical sorted participants;
- audience;
- purpose;
- aggregate context.

Use the same canonical digest mechanism.

Require:

`bindings.lifecycle_identity = canonical-match-lifecycle-v1:<lifecycle-digest>`

The lifecycle identity does not include current Match classification, reason categories, dependency revision vector, invalidation relation, storage outcome, timestamp or arrival order.

Therefore:

- changed dependency revisions may create new record/lineage identities under the same lifecycle;
- sticky terminal guard applies across those records;
- no global revision is created.

## 9. Exact Match payload key set

The derived payload contains exactly eleven top-level keys:

1. `payload_kind`
2. `derived_fact_class`
3. `classification`
4. `proposal_identity`
5. `protected_use_scope`
6. `reason_categories`
7. `proposal_dependency`
8. `participation_dependencies`
9. `decision_slot_dependencies`
10. `terminality`
11. `invalidation`

Fixed:

- `payload_kind = CANONICAL_MATCH_PROPOSAL_DECISION`
- `derived_fact_class = CANONICAL_MATCH_PROPOSAL_DECISION`

Classification exactly:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

Proposal identity and protected-use scope are non-empty strings.

Reject private sentinel material recursively.

## 10. Exact persisted reason vocabulary

Require a unique list in exact canonical order drawn only from:

1. `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`
2. `UNRESOLVED_PROPOSAL_PRECONDITION_NOT_ESTABLISHED`
3. `INVALID_PARTICIPATION_EVIDENCE_SET`
4. `MISSING_PARTICIPATION`
5. `PARTICIPATION_NOT_USABLE`
6. `PARTICIPATION_PREVENTS_ACCEPTANCE`
7. `CROSS_PROPOSAL_SLOT`
8. `WRONG_PARTICIPANT_SLOT`
9. `MISSING_DECISION_SLOT`
10. `CONFLICTING_SLOT_IDENTITY`
11. `INCOMPARABLE_DUPLICATE_SLOT`
12. `CONFLICTING_EQUAL_REVISION_SLOT`
13. `DECISION_SLOT_NOT_CURRENT_FRESH_BOUND`
14. `CONFLICTING_TERMINAL_SLOT_DECISIONS`
15. `DEPENDENCY_INVALIDATED`

Reject the four pre-materialization-only categories if supplied in a persisted Match payload:

- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `INVALID_PROPOSAL_SHAPE`
- `INVALID_SLOT_EVIDENCE`
- `INVALID_SLOT_DECISION`

Do not accept unknown categories.

## 11. Proposal dependency validator

`proposal_dependency` contains exactly:

- `proposal_identity`
- `lifecycle_state`
- `terminal`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

Require:

- proposal identity equals payload proposal identity;
- lifecycle state in:
  `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- terminal boolean equals lifecycle state != PENDING;
- owner/scope/context/lineage are non-empty strings;
- revision value integer >= 0;
- source condition is exact Common Authority source-condition vocabulary;
- currentness/freshness are boolean or null.

## 12. Participation dependency validator

Each item contains exactly:

- `participant_identity`
- `state`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

Require:

- non-empty participant identity;
- state exactly:
  `NOT_ENROLLED | ENROLLED | PAUSED | WITHDRAWN`;
- owner/scope/context/lineage non-empty;
- revision integer >= 0;
- valid source condition;
- currentness/freshness boolean or null;
- at most one item per participant identity;
- participant identities are members of generic `bindings.participants`.

Canonical list ordering:

participant identity → owner → scope → context → lineage → revision.

Any noncanonical order rejects.

## 13. Decision-slot dependency validator

Each item contains exactly:

- `slot_identity`
- `proposal_identity`
- `participant_identity`
- `decision`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

Require:

- non-empty slot/proposal/participant identities;
- proposal identity equals payload proposal identity;
- participant identity belongs to generic binding participants;
- decision exactly:
  `PENDING | ACCEPTED | DECLINED | WITHDRAWN`;
- source fields valid as above;
- at most one selected slot per participant;
- slot identities unique across selected dependencies.

Canonical ordering:

participant identity → slot identity → owner → scope → context → lineage → revision.

Any noncanonical order rejects.

## 14. Cross-type dependency identity collision

For every valid Match payload, require pairwise distinct identities across:

- proposal identity;
- both generic binding participant identities;
- every selected slot identity.

A collision rejects the Match record.

No typed invalidation discriminator is added.

## 15. Exact dependency completeness and currentness/freshness

Recompute top-level `currentness` and `freshness` independently from the persisted typed dependency vector.

### Terminal source proposal

If `proposal_dependency.terminal=true`:

- participation dependencies must be empty;
- decision-slot dependencies must be empty;
- complete required vector = proposal dependency only.

### Pending source proposal

If `proposal_dependency.terminal=false`:

- an evaluator result may have a partial dependency vector for a persistable early `UNKNOWN`;
- a complete vector is:
  - proposal dependency;
  - exactly two participation dependencies covering both binding participants;
  - exactly two selected-slot dependencies covering both binding participants.

For each aggregate independently:

1. any stored dependency value false → false;
2. else incomplete required vector or any required dependency value null → null;
3. else true.

Require record top-level currentness/freshness to equal these recomputed aggregates.

Do not infer either aggregate from classification.

## 16. Exact terminality validator

`terminality` contains exactly:

1. `source_proposal_terminal`
2. `derived_terminal`
3. `classification_before_invalidation`
4. `lifecycle_reset`
5. `proposal_reopened`

Require:

- source proposal terminal equals `proposal_dependency.terminal`;
- lifecycle reset = false;
- proposal reopened = false;
- bindings.terminal equals derived terminal.

### Non-invalidated payload

Require:

- `classification_before_invalidation = null`;
- derived terminal = true exactly when current classification is:
  `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`.

### Invalidated payload

Require:

- current classification = `UNKNOWN`;
- classification-before-invalidation is non-null and one of:
  `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED | UNKNOWN`;
- reason categories exactly `[DEPENDENCY_INVALIDATED]`;
- derived terminal = true exactly when classification-before-invalidation is:
  `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`.

Thus terminal invalidation may validly have:

`classification=UNKNOWN` and `bindings.terminal=true`.

Do not weaken the generic IP-13A terminal lifecycle guard.

## 17. Exact Match dependency invalidation validator

Match payload `invalidation` contains exactly:

- `invalidated`
- `relation`
- `dependency_identity`
- `lifecycle_reset`
- `proposal_reopened`

Non-invalidated:

- invalidated=false;
- relation=null;
- dependency identity=null;
- lifecycle reset=false;
- proposal reopened=false.

Invalidated:

- invalidated=true;
- relation exactly:
  `CORRECTION | REVOCATION | SUPERSESSION`;
- dependency identity is a non-empty string matching exactly one persisted proposal/participant/selected-slot dependency identity;
- lifecycle reset=false;
- proposal reopened=false;
- terminality/classification/reasons obey Section 16.

## 18. Generic invalidation-overlay separation

This is a mandatory R11 behavior.

The current generic projection code mutates any non-null derived payload when a generic logical-record invalidation exists.

Preserve the existing RR03 behavior unchanged.

For the Canonical Match family:

- generic `observeInvalidation(logical_record_identity, relation)` must set generic projection fields such as:
  - `projection_invalidated=true`
  - `invalidation_relation=<relation>`
- it must NOT rewrite, replace or synthesize the Match payload's domain dependency `invalidation` object;
- it must NOT substitute the logical record identity as Match `dependency_identity`;
- the stored/read Match `derived_projection_payload` remains byte/array-identical to the original Match payload under a generic overlay.

Generic overlay invalidation and Match dependency invalidation are separate truths.

Either may make a later application readback unusable, but generic overlay creates no Match dependency provenance.

Implement this identically in IP-13A and IP-13D projection logic.

## 19. Exact Match semantic identity and projection metadata checks

For Match records require:

- exact semantic digest identities from Sections 7–8;
- `source_revision.value=0`;
- `projection_metadata.represented_source_revision_value=0`;
- projection currentness equals record currentness;
- lag classification:
  - currentness=true → `CURRENT`
  - currentness=false → `LAGGED`
  - currentness=null → `UNKNOWN`.

Do not use freshness to select projection lag.

## 20. IP-13A stored-record retention

When a valid Match record is stored, retain its exact Match `derived_projection_payload` in the internal stored record.

Privacy-minimal projection may expose that exact payload internally to IP-13E, alongside existing generic projection fields.

Do not expose raw source evidence or required bindings inside the payload.

RR03 retention behavior remains unchanged.

## 21. IP-13D storage parity

After the reference validator accepts a valid Match record:

- IP-13D must retain the Match derived payload exactly;
- do not unset it merely because the family is non-RR03;
- preserve existing JSON payload storage;
- preserve the same two SQLite tables;
- preserve `sqlite::memory:`;
- no schema/migration/table/column change;
- all duplicate/conflict/incomparable/terminal guards remain behaviorally equivalent to IP-13A.

Derived payload retention is family-specific:

- RR03 retained;
- Canonical Match retained;
- other generic families continue without arbitrary derived payload support.

## 22. Exact targeted Unit test

Create exactly:

`services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php`

The single test file must prove, at minimum:

1. valid ordinary Match record accepted by both reference and SQLite;
2. exact Match payload retained and read back identically;
3. privacy-minimal projection parity between reference and SQLite;
4. source-order-independent canonical identity fixture is accepted;
5. wrong record/intent/lineage/projection digest or semantic input is rejected;
6. invalid Match record-family authority owner/scope/context/revision boundary is rejected;
7. invalid reason category is rejected;
8. pre-materialization-only reason category in a persisted payload is rejected;
9. duplicate/out-of-order reason list is rejected;
10. malformed proposal dependency rejected;
11. malformed/noncanonical participation dependency list rejected;
12. malformed/noncanonical selected-slot list rejected;
13. cross-type proposal/participant/slot identity collision rejected;
14. invalid classification/terminality combination rejected;
15. non-invalidated payload requires null prior classification;
16. sticky terminal invalidated payload with current UNKNOWN + prior terminal classification + terminal=true is accepted;
17. invalidated payload with terminal prior classification but terminal=false is rejected;
18. invalidated payload requires exact dependency identity and accepted relation;
19. top-level currentness/freshness mismatch against dependency aggregate is rejected;
20. terminal source proposal requires empty participation/slot dependency lists;
21. pending complete vector requires exact participant coverage for materialized true aggregates;
22. exact duplicate remains idempotent correlation;
23. distinct dependency revision vector creates distinct identity/lineage and may coexist as incomparable without arrival-order choice;
24. exact-lineage resolution selects only the requested lineage;
25. same lifecycle terminal then non-terminal record is rejected by existing terminal guard;
26. terminal then sticky-invalidated terminal record does not trigger reopen guard;
27. generic record-overlay invalidation marks projection invalidated while leaving Match payload invalidation object byte/array-identical;
28. Match dependency-invalidated payload remains distinct from generic overlay invalidation;
29. reference/SQLite parity for store/readExact/resolveCurrent/readHistory/privacyMinimalProjection/observeInvalidation;
30. RR03 derived payload storage/projection behavior remains unchanged;
31. a non-RR03/non-Match generic family still cannot smuggle a non-null derived payload;
32. SQLite physical facts remain:
    - `dsn=sqlite::memory:`
    - exactly `logical_invalidations`, `logical_records`
    - no production persistence/row-order authority.

Use synthetic/dev-test fixtures only.

No second test file.

## 23. Existing-family non-regression

The implementation must not weaken or rename:

- RR03 family;
- RR03 payload/reason/dependency validators;
- generic envelope key set;
- Common Authority validation;
- duplicate/intent conflict semantics;
- source-local revision comparison;
- terminal lifecycle guard;
- generic query contract;
- existing non-authority flags.

The targeted Match Unit test must contain bounded RR03 non-regression coverage, but no existing test file may be modified or run separately.

## 24. Same-worktree vendor bootstrap

Check only:

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

`composer.json` and `composer.lock` must remain unchanged.

## 25. Exact runtime command budget

Run exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceFamilyTest.php`

No retry.

Do NOT run:

- full suite;
- any other Unit or Feature test;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- HTTP/client;
- database external probe;
- provider/network product operation;
- production;
- real/private-data operation.

After final authoring run exactly one:

`git diff --check`

No other project runtime command is authorized.

## 26. Failure handling

If the single targeted PHPUnit attempt fails:

- do not rerun;
- static correction after the consumed run is allowed only inside the exact four-path write scope;
- do not claim runtime PASS after a post-run correction;
- publish immutable candidate with runtime status `RETAINED_UNKNOWN`;
- fresh independent review may authorize verification-only rerun.

If correction requires:

- a fifth tracked path;
- IP-13E/IP-13F change;
- evaluator/Common Authority change;
- migration/schema/config/provider change;
- application adapter implementation;

STOP and record the blocker.

## 27. Implementation result document

Create exactly:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`

Record:

- task-publication authority;
- branch/candidate/sole parent/tree/ahead-behind;
- exact four-path diff;
- all fixed input blobs;
- pre/post IP-13A/IP-13D blobs;
- new test blob;
- exact Match family constant;
- exact payload/dependency/reason/terminality/invalidation behavior;
- deterministic identity validation;
- generic-overlay separation;
- reference/SQLite parity;
- RR03/generic non-regression;
- physical SQLite facts;
- Composer Case A/B receipt;
- exact targeted PHPUnit receipt;
- tests/assertions/failures/errors;
- warnings/deprecations;
- manifest/lock unchanged;
- one `git diff --check` receipt;
- tracked/staged counts;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R11 CANONICAL MATCH PERSISTENCE FAMILY IMPLEMENTED — IP-13A/IP-13D ACCEPT EXACT CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION WITH STICKY TERMINALITY / 15 REASONS / COLLISION-FREE DEPENDENCIES / DETERMINISTIC CORRELATION — GENERIC OVERLAY INVALIDATION DOES NOT OVERWRITE MATCH DEPENDENCY INVALIDATION — REFERENCE/SQLITE PARITY TARGETED PASS — RR03/GENERIC BEHAVIOR PRESERVED — NO APPLICATION ADAPTER / IP-13E / IP-13F / HTTP AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
