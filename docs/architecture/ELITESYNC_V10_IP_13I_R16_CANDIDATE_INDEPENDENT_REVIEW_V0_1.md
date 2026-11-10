# EliteSync v10｜IP-13I-R16 Candidate Independent Review｜v0.1

Status: `REJECTED — RECORD/PROJECTION DIRECTION SOUND BUT CLASSIFICATION/REASON/DEPENDENCY CROSS-FIELD VALIDATION MATRIX INCOMPLETE — R17 NOT AUTHORIZED — R16-R1 DOCUMENT-ONLY CORRECTION REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`:
`c5fa9ce274a17fe6e772f3bc178e2ff2a6027466`

Reviewed branch:
`review/next-ip-13i-r16-product-connection-record-projection-contract-v0-1`

Reviewed candidate:
`5494bf6835134ef1af69d5ebe32aa28ef62fc92e`

Candidate sole parent:
`c5fa9ce274a17fe6e772f3bc178e2ff2a6027466`

Candidate tree:
`2498226aa6b9edaef214d2b002ca521c6acebcf6`

Candidate result blob:
`aee15cf45c75c5a8f1733f5604803fc3ee766b4b`

## 1. Independent verification

Fresh independent review confirmed:

- candidate is exactly one commit ahead / zero behind the R16 authority;
- exactly one authorized result document is added;
- all twelve fixed ledger objects resolve to the exact claimed blobs;
- no code/runtime action occurred;
- provenance/topology is clean.

The rejection is substantive and narrow.

## 2. Sound direction retained as review evidence

The following R16 directions are not rejected:

- `ADDITIVE_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_SOUND` remains plausible;
- family:
  `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- typed fact classes:
  - `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`
  - `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A:
  derivation-owned deterministic non-authoritative correlation bindings;
- fact-specific authority scopes and schema markers;
- stable lifecycle identity shared across current-state/transition facts;
- corrected 8/19 persisted reason vocabularies;
- typed current-state dependency;
- typed transition dependency;
- full `expected_state_revision` tuple;
- cross-type dependency identity distinctness;
- current-state-based generic terminal marker;
- no extra sticky-terminal field;
- normalized dependency invalidation object;
- generic projection invalidation separated from Product Connection dependency invalidation;
- three-valued currentness/freshness aggregation direction;
- deterministic record/intent/lineage/projection correlation;
- IP-13A additive repair direction;
- IP-13D parity without physical schema change;
- IP-13E existing operations sufficiency;
- IP-13F unchanged/non-participating.

These are retained evidence only until a corrected R16 contract is independently accepted.

## 3. Blocking under-specification

R16 defines payload keys and reason vocabularies, but it does not fully define the cross-field validity matrix required for persistence validation.

As written, records that cannot be produced by the accepted evaluator remain structurally admissible under the documented contract.

Examples:

### 3.1 Impossible current-state known result

The candidate permits, by its written rules:

- `classification = CN_ACTIVE`
- `current_state = CN_ACTIVE`
- empty reasons
- `current_state_dependency = null`
- `connection_active_for_downstream_consideration = true`
- `valid_for_protected_use = true`
- top-level currentness/freshness = `null/null`

But `evaluateCurrent()` can return a known state only after resolving one selected current-state evidence item and passing its protected-use/binding/currentness/freshness checks.

A known current state without a retained selected dependency cannot be a truthful evaluator-derived fact.

### 3.2 Impossible admissible/rejected transition result

The candidate does not explicitly require `ADMISSIBLE` or ordinary `REJECTED` to retain both:

- selected current-state dependency; and
- selected transition dependency.

Thus a payload could satisfy the documented classification/reason rules while one or both typed dependencies are null.

The accepted evaluator cannot produce `ADMISSIBLE` or policy `REJECTED` without first resolving both dependencies.

### 3.3 Missing exact cross-field dependency binding

The contract does not fully require:

- current-state dependency `connection_identity = payload.connection_identity`;
- current-state dependency `state = payload.current_state` where the evaluator established a known current state;
- transition dependency `connection_identity = payload.connection_identity`;
- transition dependency `from_state = payload.current_state`;
- transition dependency `to_state = payload.proposed_state`;
- for `ADMISSIBLE` / policy `REJECTED`, transition `expected_state_revision` exactly equals the retained current-state dependency source revision tuple;
- for `TRANSITION_CURRENT_CONTEXT_MISMATCH`, at least one of the from-state or expected-revision bindings is actually mismatched.

Without these rules, a family-specific IP-13A validator could accept a payload whose parts are individually well-typed but semantically cannot correspond to the evaluator result.

## 4. Why R17 cannot safely repair this later

R17 is intended to define evaluator→payload→record→IP-13E orchestration.

A strict builder in R17 could avoid constructing impossible records, but that would not make the persistence contract itself complete.

R16 is the layer that defines what IP-13A/IP-13D must validate independently.

If cross-field impossibilities are left only to the future builder:

`BUILDER_VALID != PERSISTENCE_CONTRACT_COMPLETE`

and a malformed but well-typed derived payload could still be accepted by the future persistence family.

This is inconsistent with the established family-specific fail-closed validation model used for RR03 and Canonical Match.

## 5. Required R16-R1 correction

The next review must define exact dependency-presence and cross-field binding matrices for both typed facts.

At minimum:

### Current-state matrix

For each ordinary classification/reason disposition, define exactly:

- whether current-state dependency must be null or non-null;
- whether current state must be null or known;
- whether dependency state must equal current state;
- allowed top-level currentness/freshness relation to dependency values;
- terminality/downstream-active/valid-for-protected-use consistency.

The matrix must distinguish:

- known state;
- missing/cross-participant/conflicting/incomparable/equal-conflict UNKNOWN with no selected dependency;
- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` UNKNOWN with a selected dependency;
- dependency-invalidated UNKNOWN with a retained dependency and retained pre-invalidation current state where applicable.

### Transition matrix

For each reason/classification group, define exactly whether:

- current-state dependency is required;
- transition dependency is required;
- current/proposed state is required/null;
- dependency from/to states bind to payload current/proposed state;
- expected-state-revision must equal current-state dependency revision or must mismatch it;
- currentness/freshness aggregate follows the fixed incomplete/false/null matrix;
- terminality/reopen descriptors are exact.

At minimum distinguish:

- propagated current-state UNKNOWN reasons;
- missing/cross-participant/conflicting/incomparable/equal-conflict transition UNKNOWN with current dependency only;
- `TRANSITION_NOT_CURRENT_FRESH_BOUND` with both dependencies;
- `TRANSITION_CURRENT_CONTEXT_MISMATCH` with both dependencies and an actual context mismatch;
- `ADMISSIBLE` with both dependencies and exact context match;
- policy `REJECTED` with both dependencies and exact context match;
- dependency-invalidated transition result, preserving the exact pre-invalidation dependency set/context.

## 6. Candidate disposition

Candidate:

`5494bf6835134ef1af69d5ebe32aa28ef62fc92e`

is rejected for acceptance.

It must not be merged/transplanted to main.

R17 is not authorized yet.

The next task must be:

`IP-13I-R16-R1 PRODUCT CONNECTION DEPENDENCY-PRESENCE AND CROSS-FIELD VALIDATION CONTRACT CORRECTION REVIEW — DOCUMENT ONLY`

No implementation is authorized.

## 7. Final classification

`IP-13I-R16 CANDIDATE REJECTED — ADDITIVE FAMILY / BINDING MODEL A / TYPED PAYLOADS / 8-19 REASONS / DEPENDENCY SCHEMAS / TERMINALITY / INVALIDATION / OVERLAY / DETERMINISTIC CORRELATION / IP-13A-D-E-F DIRECTIONS RETAINED AS REVIEW EVIDENCE — DEPENDENCY-PRESENCE AND CROSS-FIELD VALIDATION MATRIX INCOMPLETE, ALLOWING IMPOSSIBLE EVALUATOR-DERIVED RECORDS — R17 DEFERRED — R16-R1 DOCUMENT-ONLY CORRECTION REQUIRED`
