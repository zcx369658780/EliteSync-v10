# EliteSync v10｜Next IP-13I-R16-R1 Product Connection Dependency-Presence and Cross-Field Validation Contract Correction Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY SINGLE-DEFECT CROSS-FIELD CONTRACT CORRECTION — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`6c6e5e6c4e0fd065de9d6881a4b85853cdbcd73a`

Rejected R16 candidate:
`5494bf6835134ef1af69d5ebe32aa28ef62fc92e`

Rejected R16 result blob:
`aee15cf45c75c5a8f1733f5604803fc3ee766b4b`

R16 independent rejection blob:
`1e3215a4a5848a7493a9df0a8654dfa0f0d01df9`

## 1. Objective

Correct exactly one defect in the rejected R16 record/projection contract:

the exact dependency-presence and cross-field validation matrix was not fully fixed, allowing well-typed Product Connection records that the accepted evaluator cannot actually produce.

This task is REVIEW ONLY.

Do not reopen the following retained R16 directions unless the correction discovers a direct contradiction:

- family:
  `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- typed fact classes:
  - `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`
  - `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A:
  derivation-owned deterministic non-authoritative correlation bindings;
- exact 8/19 persisted reason vocabularies;
- typed current-state and transition dependencies;
- full `expected_state_revision` tuple;
- cross-type dependency identity distinctness;
- current-state-based terminality;
- no extra sticky-terminal field;
- normalized Product Connection dependency invalidation object;
- generic overlay separated from Product Connection dependency invalidation;
- deterministic correlation / shared lifecycle identity;
- IP-13A additive-family compatibility;
- IP-13D reference parity without physical schema change;
- IP-13E existing operations sufficiency;
- IP-13F unchanged/non-participating.

R17 remains blocked until R16-R1 is independently accepted.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R16-R1 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if any identity differs.

Recommended branch:

`review/next-ip-13i-r16-r1-product-connection-cross-field-validation-correction-v0-1`

No repository enumeration or unrelated discovery.

## 3. Controlling defect

Rejected R16 fixes field types and vocabularies but does not fully constrain valid field combinations.

The corrected contract must independently reject impossible evaluator-derived payloads such as:

- known current state with no selected current-state dependency;
- `ADMISSIBLE` transition without both selected dependencies;
- `REJECTED` policy decision without both selected dependencies;
- transition dependency `from_state` / `to_state` not matching payload current/proposed state;
- context-matched `ADMISSIBLE` whose expected-state revision differs from the current-state dependency revision;
- `TRANSITION_CURRENT_CONTEXT_MISMATCH` payload where neither from-state nor expected revision actually mismatches.

The persistence contract itself must be fail-closed.

A future strict builder is not a substitute:

`BUILDER_VALID != PERSISTENCE_CONTRACT_COMPLETE`

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R16-R1 task

3. R16 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_TASK_V0_1.md`

4. R16 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R16_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

5. rejected R16 result at exact candidate
   `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`:
   `docs/architecture/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md`

6. accepted R15-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md`

7. R15-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`

8. Product Connection evaluator:
   `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`

9. Common Authority:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

10. current IP-13A:
    `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

Expected blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R16 task:
  `382a83588c638f1834f8d1e947c384c76e60e845`
- R16 rejection:
  `1e3215a4a5848a7493a9df0a8654dfa0f0d01df9`
- rejected R16 result:
  `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`
- R15-R1 result:
  `fb064b7e290916ba7aa42d53990c9c54d289f5ba`
- R15-R1 acceptance:
  `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`
- Product Connection evaluator:
  `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing file may change.

No code/test/persistence/application/route/HTTP modification.

## 6. Current-state dependency-presence matrix

Define an exact matrix for every valid current-state payload class.

### 6.1 Known ordinary current state

For classification in:

- `CN_NONE`
- `CN_PENDING`
- `CN_ACTIVE`
- `CN_PAUSED`
- `CN_CLOSED`
- `CN_DECLINED`
- `CN_WITHDRAWN`
- `CN_EXPIRED`

require at minimum:

- reasons empty;
- `current_state = classification`;
- `current_state_dependency` non-null;
- dependency Connection identity equals payload Connection identity;
- dependency state equals payload current state;
- currentness/freshness equal exact dependency values;
- under the current evaluator, both dependency currentness and freshness must be true for an ordinary known result;
- downstream-active true exactly for `CN_ACTIVE`;
- valid-for-protected-use true;
- invalidation false;
- terminality matches retained current state.

No known state may be materialized without a selected dependency.

## 7. Ordinary current-state UNKNOWN matrix

Define exact dependency/state rules for each accepted ordinary UNKNOWN reason.

At minimum distinguish:

### No selected dependency required / allowed

- `MISSING_CURRENT_STATE_EVIDENCE`
- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`

For these, require:

- classification `UNKNOWN`;
- exact one reason;
- `current_state = null`;
- `current_state_dependency = null`;
- top-level currentness/freshness = `null/null`;
- downstream-active false;
- valid-for-protected-use false;
- invalidation false;
- terminal false.

### Selected dependency required

`CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`

Require:

- classification `UNKNOWN`;
- exact reason;
- `current_state = null`;
- current-state dependency non-null;
- dependency Connection identity equals payload Connection identity;
- top-level currentness/freshness equal dependency values;
- the dependency must fail at least one accepted protected-use/current/fresh/binding requirement so that the reason is truthful;
- downstream-active false;
- valid-for-protected-use false;
- invalidation false;
- terminal false.

The correction must decide how persistence can validate the final bullet without storing raw bindings. If the typed dependency lacks enough information, classify the retained R16 dependency schema as requiring a narrow correction and specify exact added privacy-minimal fields.

Do not wave this requirement away.

## 8. Invalidated current-state matrix

For `DEPENDENCY_INVALIDATED` require:

- classification `UNKNOWN`;
- reason exactly `[DEPENDENCY_INVALIDATED]`;
- current-state dependency non-null;
- invalidation identity equals the dependency's state-evidence identity;
- current state is the exact retained pre-invalidation current state, which may be:
  - a known state; or
  - `null` if the pre-invalidation result was `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
- dependency object unchanged from pre-invalidation fact;
- top-level currentness/freshness unchanged from dependency-derived pre-invalidation aggregate;
- downstream-active false;
- valid-for-protected-use false;
- terminality derived from retained current state;
- lifecycle reset false;
- connection reopened false.

## 9. Transition propagated-current-state UNKNOWN matrix

For transition payloads whose reason is one of the seven current-state UNKNOWN reasons:

- classification `UNKNOWN`;
- proposed state = `null`;
- transition dependency = `null`;
- current state = `null`;
- current dependency presence follows the corrected current-state reason matrix:
  - null for the first six reasons;
  - non-null for `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
- top-level currentness/freshness follow the transition incomplete-vector aggregation rule;
- downstream-active false;
- valid-for-protected-use false;
- invalidation false.

Do not evaluate or persist a transition dependency because the evaluator returns before transition resolution.

## 10. Transition resolution-failure UNKNOWN matrix

For:

- `MISSING_TRANSITION_EVIDENCE`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`
- `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`

require:

- classification `UNKNOWN`;
- current state known and non-null;
- current-state dependency non-null;
- dependency state = payload current state;
- transition dependency = `null`;
- proposed state = `null`;
- current dependency Connection identity equals payload Connection identity;
- top-level currentness/freshness follow the fixed incomplete transition matrix;
- downstream-active equals whether current state is `CN_ACTIVE`;
- valid-for-protected-use false;
- invalidation false;
- generic terminal marker based on current state.

## 11. Transition selected-dependency UNKNOWN matrix

For:

### `TRANSITION_NOT_CURRENT_FRESH_BOUND`

require:

- both dependencies non-null;
- current state known and non-null;
- proposed state non-null and equals transition dependency `to_state`;
- transition dependency `from_state` is structurally valid;
- transition dependency Connection identity equals payload Connection identity;
- current dependency Connection identity equals payload Connection identity;
- transition dependency must fail at least one accepted protected-use/current/fresh/binding requirement;
- classification `UNKNOWN`;
- valid-for-protected-use false.

As in Section 7, decide whether the retained typed dependency schema contains enough privacy-minimal information for persistence to validate that failure. If not, specify the exact narrow schema correction.

### `TRANSITION_CURRENT_CONTEXT_MISMATCH`

require:

- both dependencies non-null;
- current state known and equals current dependency state;
- proposed state non-null and equals transition dependency `to_state`;
- at least one is true:
  - transition dependency `from_state != payload.current_state`;
  - transition dependency `expected_state_revision != exact current-state dependency source revision tuple`;
- classification `UNKNOWN`;
- reason exact;
- valid-for-protected-use false.

A payload where both bindings match must be rejected as an impossible context-mismatch result.

## 12. ADMISSIBLE transition matrix

Require exactly:

- classification `ADMISSIBLE`;
- reasons empty;
- both dependencies non-null;
- current state known and equals current dependency state;
- proposed state known and equals transition dependency to-state;
- transition dependency from-state equals current state;
- expected-state revision equals exact current-state dependency source revision tuple;
- both dependencies bind the payload Connection identity;
- proposed transition is in the evaluator's exact allowed-transition matrix;
- current state is non-terminal;
- downstream-active equals whether current state is `CN_ACTIVE`;
- valid-for-protected-use true;
- invalidation false;
- generic terminal marker based on current state only.

No `ADMISSIBLE` record may omit either dependency.

## 13. REJECTED transition matrix

All policy `REJECTED` records require:

- both dependencies non-null;
- current state equals current dependency state;
- proposed state equals transition dependency to-state;
- transition dependency from-state equals current state;
- expected-state revision equals exact current-state dependency revision;
- both dependencies bind the payload Connection identity;
- invalidation false;
- valid-for-protected-use false.

Then require reason-specific truth:

### `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`

- current state is one of the four terminal states;
- terminal-reopen-rejected true;
- generic terminal true.

### `DIRECT_NONE_TO_ACTIVE_REJECTED`

- current state = `CN_NONE`;
- proposed state = `CN_ACTIVE`;
- current state non-terminal;
- terminal-reopen-rejected false.

### `TRANSITION_NOT_ALLOWED`

- current state non-terminal;
- from/to pair is not in the exact allowed matrix;
- pair is not `CN_NONE -> CN_ACTIVE`;
- terminal-reopen-rejected false.

## 14. Invalidated transition matrix

For `DEPENDENCY_INVALIDATED` require:

- classification `UNKNOWN`;
- exact reason;
- dependency set exactly retained from the pre-invalidation transition result;
- invalidation identity matches exactly one retained dependency;
- cross-type identities remain distinct;
- current/proposed states retained unchanged;
- any transition dependency from/to and expected revision remain unchanged;
- top-level currentness/freshness retained from the pre-invalidation aggregate;
- downstream-active false;
- valid-for-protected-use false;
- current-state-based terminal marker retained;
- terminal-reopen-rejected retained from pre-invalidation result;
- lifecycle reset false;
- connection reopened false.

The corrected contract must state which pre-invalidation transition shapes can legally be invalidated:
- any fact with at least one retained dependency; or
- a narrower set, if required by evaluator behavior.

## 15. Exact source-revision binding helper

Define one canonical conversion from current-state typed dependency to the source-revision tuple used for transition context comparison:

- authority owner
- authority scope
- source lineage → revision lineage
- aggregate context
- source revision value → revision value

This canonical tuple is what transition `expected_state_revision` must equal for matched context.

No timestamp/global revision.

## 16. Dependency currentness/freshness matrix

Reconfirm the retained aggregation only after the dependency-presence matrix is fixed.

Current-state:
- dependency null → null;
- dependency non-null → exact value.

Transition per dimension:
- no current dependency → null;
- current=false + transition absent → false;
- current=true/null + transition absent → null;
- both present, any false → false;
- both true → true;
- both present, no false, at least one null → null.

Then verify each reason/classification matrix above is consistent with this aggregate.

## 17. Protected-use/binding failure validation problem

R16-R1 must resolve whether future persistence can independently validate:

- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
- `TRANSITION_NOT_CURRENT_FRESH_BOUND`

without raw required-bindings/source-evidence objects.

Choose exactly one:

### A
`EXISTING_TYPED_DEPENDENCY_FIELDS_SUFFICIENT_FOR_FAIL-CLOSED VALIDATION`

Explain exactly how the persistence validator proves the reason.

### B
`TYPED_DEPENDENCY_SCHEMA_REQUIRES_MINIMAL_BINDING-SATISFACTION METADATA`

Define the exact privacy-minimal field(s), such as an evaluator/builder-derived bounded boolean/category, sufficient to validate the reason without persisting raw bindings.

The field must not become source authority.

### C
`PERSISTENCE_VALIDATES SHAPE/RELATION ONLY; BUILDER-ORCHESTRATION OWNS BINDING-SATISFACTION PROOF`

Select only if this split is consistent with existing RR03/Canonical Match fail-closed architecture and cannot admit impossible derived records.

### D
`BLOCKED`

Do not silently leave this unresolved.

## 18. R16 supersession boundary

State exactly what from rejected R16 remains retained and what is superseded.

Expected narrow correction:

- add/replace classification/reason/dependency presence matrix;
- add exact cross-field binding rules;
- if needed, narrowly add privacy-minimal dependency metadata under Section 17.

Do not silently reopen:
- family;
- fact classes;
- Binding Model A constants;
- lifecycle basis;
- terminality basis;
- invalidation object;
- overlay separation;
- schema markers/digests;
- IP-13A/IP-13D/IP-13E/IP-13F direction.

If any must change, explain exact contradiction.

## 19. R17 gate

If the matrix is complete and no new blocker remains, authorize next:

`IP-13I-R17 PRODUCT CONNECTION DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

R17 must consume the corrected cross-field matrix as fixed contract input.

Do not author R17 from the correction branch.

## 20. Review-only prohibition

Do not run:
- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server/HTTP;
- database probes;
- provider/network product operations;
- production;
- real/private-data operations.

Do not modify code.

## 21. Result requirements

Record:
- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all fixed blobs;
- exact current-state matrix;
- exact transition propagated-UNKNOWN matrix;
- exact transition resolution-failure matrix;
- exact selected-dependency UNKNOWN matrix;
- exact ADMISSIBLE matrix;
- exact REJECTED matrices;
- exact invalidated current-state/transition matrices;
- source-revision binding helper;
- currentness/freshness consistency;
- Section 17 A/B/C/D decision;
- exact schema correction if any;
- R16 retained/superseded sections;
- whether Binding Model A/family/terminality/overlay/persistence-stack directions remain intact;
- R17 gate;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape:

`IP-13I-R16-R1 REVIEW COMPLETE — PRODUCT CONNECTION DEPENDENCY-PRESENCE / CLASSIFICATION-REASON / STATE-DEPENDENCY / EXPECTED-REVISION CROSS-FIELD VALIDATION MATRIX FIXED — IMPOSSIBLE EVALUATOR-DERIVED RECORDS FAIL CLOSED — RETAINED R16 FAMILY/BINDING/TERMINALITY/INVALIDATION/OVERLAY/DIGEST/PERSISTENCE DIRECTIONS PRESERVED OR NARROWLY CORRECTED — R17 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
