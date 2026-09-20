# EliteSync v10｜IP-13I-R16-R1 Product Connection Dependency-Presence and Cross-Field Validation Contract Correction Review Result｜v0.1

Status: `REVIEW COMPLETE — PRODUCT CONNECTION DEPENDENCY-PRESENCE AND CROSS-FIELD CONTRACT CORRECTED — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Publication authority and scope

- fresh `origin/main`: `f8fc238eb7c6a764342af6de08a0db692d367c14`
- authority sole parent: `6c6e5e6c4e0fd065de9d6881a4b85853cdbcd73a`
- authority tree: `18e2ea9905453f5849bccad9dd47138bd28b689b`
- review branch: `review/next-ip-13i-r16-r1-product-connection-cross-field-validation-correction-v0-1`
- tracked scope: exactly this one added result document
- candidate commit / sole parent / tree: established by the immutable Git publication receipt; the candidate must have the fresh authority commit above as its sole parent.

The rejected R16 candidate `5494bf6835134ef1af69d5ebe32aa28ef62fc92e` was read only as the exact correction source authorized by the R16-R1 task. It was not merged or transplanted.

## 2. Fixed evidence ledger

Directly read and verified:

- `AGENTS.md`: `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R16-R1 task: `558bab72ae663b6c7883a641bd9806583b0e5b33`
- R16 task: `382a83588c638f1834f8d1e947c384c76e60e845`
- R16 independent rejection: `1e3215a4a5848a7493a9df0a8654dfa0f0d01df9`
- rejected R16 result at the exact rejected candidate: `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`
- accepted R15-R1 result: `fb064b7e290916ba7aa42d53990c9c54d289f5ba`
- R15-R1 acceptance: `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`
- Product Connection evaluator: `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority: `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A: `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`

No source outside the task-authorized read scope was used.

## 3. Correction decision

Decision:

`PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_AND_CROSS_FIELD_MATRIX_COMPLETE_WITH_NARROW_TYPED_DEPENDENCY_METADATA_CORRECTION`

Retained without contradiction:

- family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- Binding Model A;
- fact classes `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` and `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- exact 8-reason current-state vocabulary and 19-reason transition vocabulary;
- typed current-state and transition dependencies;
- full `expected_state_revision`;
- cross-type dependency identity distinctness;
- current-state-based terminality and no-reopen semantics;
- normalized dependency invalidation object;
- generic invalidation-overlay separation;
- deterministic lifecycle and correlation identities;
- IP-13A additive-family compatibility, IP-13D reference parity, IP-13E existing-operation sufficiency, and IP-13F unchanged/non-participating.

The correction adds one exact boolean to each typed dependency and fixes the complete persistence validation matrix. It creates no new domain reason, authority, permission or lifecycle rule.

## 4. Exact typed-dependency correction

Section 17 decision:

`B — TYPED_DEPENDENCY_SCHEMA_REQUIRES_MINIMAL_BINDING-SATISFACTION METADATA`

Add exactly this ordered field after `source_condition` and before `currentness` in both typed dependencies:

`protected_binding_satisfied: bool`

The current-state dependency therefore has exactly 13 ordered keys:

1. `dependency_type`
2. `state_evidence_identity`
3. `connection_identity`
4. `state`
5. `authority_owner`
6. `authority_scope`
7. `aggregate_context`
8. `source_lineage`
9. `source_revision_value`
10. `source_condition`
11. `protected_binding_satisfied`
12. `currentness`
13. `freshness`

The transition dependency therefore has exactly 15 ordered keys:

1. `dependency_type`
2. `transition_identity`
3. `connection_identity`
4. `from_state`
5. `to_state`
6. `expected_state_revision`
7. `authority_owner`
8. `authority_scope`
9. `aggregate_context`
10. `source_lineage`
11. `source_revision_value`
12. `source_condition`
13. `protected_binding_satisfied`
14. `currentness`
15. `freshness`

`protected_binding_satisfied` is a non-authoritative boolean computed by the strict builder from the complete, structurally valid source evidence, its required bindings and the Connection descriptor. It covers Common Authority exact binding equality plus the evaluator-specific descriptor binding checks. For current-state evidence it also covers equality between the evidence terminal binding and `isTerminal(state)`. It excludes source condition, currentness and freshness because those remain separately persisted fields. Transition evidence has no additional current-state terminal binding rule.

A typed dependency is fully usable exactly when all four predicates are true:

1. `protected_binding_satisfied === true`;
2. `source_condition === PRESENT`;
3. `currentness === true`;
4. `freshness === true`.

The boolean contains no raw actor, role, participant, audience, purpose or terminal binding. It does not prove source authority, grant permission, carry a bearer capability, or replace the underlying evaluator decision. Persistence uses it only to fail closed on the classification/reason matrix.

The rejected R16 schema without this field is insufficient: `source_condition`, `currentness` and `freshness` alone cannot distinguish a selected evidence item whose required bindings fail the evaluator's exact protected-use and descriptor checks.

## 5. Current-state dependency-presence matrix

### 5.1 Known ordinary current state

For classification in:

`CN_NONE | CN_PENDING | CN_ACTIVE | CN_PAUSED | CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`

the record is eligible only when all of these hold:

- `reason_categories = []`;
- `current_state = classification`;
- `current_state_dependency` is non-null;
- dependency `connection_identity` equals payload `connection_identity`;
- dependency `state` equals payload `current_state`;
- the dependency is fully usable under Section 4;
- dependency currentness and freshness are both exactly `true`;
- top-level currentness/freshness equal the dependency values and are therefore `true/true`;
- `connection_active_for_downstream_consideration` is true exactly for `CN_ACTIVE`;
- `valid_for_protected_use = true`;
- invalidation is the exact non-invalidated object;
- `terminality.current_state_terminal` is true exactly for `CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`.

A known state without the selected dependency, with an unusable dependency, or with a mismatched dependency state is ineligible for materialization.

### 5.2 Ordinary current-state `UNKNOWN` without a selected dependency

For each exact reason:

- `MISSING_CURRENT_STATE_EVIDENCE`
- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`

require:

- classification `UNKNOWN` and exactly the named single reason;
- `current_state = null`;
- `current_state_dependency = null`;
- top-level currentness/freshness `null/null`;
- downstream-active false;
- valid-for-protected-use false;
- exact non-invalidated object;
- `terminality.current_state_terminal = false`.

Selected evidence must not be substituted for these resolution failures.

### 5.3 Ordinary current-state `UNKNOWN` with a selected dependency

For `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` require:

- classification `UNKNOWN` and exactly that reason;
- `current_state = null`;
- current-state dependency non-null;
- dependency `connection_identity` equals payload `connection_identity`;
- top-level currentness/freshness equal the dependency values;
- at least one full-usability predicate from Section 4 is false;
- downstream-active false;
- valid-for-protected-use false;
- exact non-invalidated object;
- `terminality.current_state_terminal = false`.

If all four usability predicates are true, this reason is false and persistence must reject the record.

## 6. Invalidated current-state matrix

`DEPENDENCY_INVALIDATED` is eligible only from a pre-invalidation current-state fact that retained a dependency: either a known ordinary result or `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`.

Require:

- classification `UNKNOWN`;
- reasons exactly `[DEPENDENCY_INVALIDATED]`;
- current-state dependency non-null and byte-for-byte unchanged from the pre-invalidation fact;
- invalidation identity equals its `state_evidence_identity`;
- retained `current_state` equals the exact pre-invalidation value: a known state, or `null` for `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
- top-level currentness/freshness retain the dependency-derived pre-invalidation values;
- downstream-active false and valid-for-protected-use false;
- terminality remains derived from the retained current state;
- `lifecycle_reset = false` and `connection_reopened = false`.

The six ordinary no-dependency `UNKNOWN` shapes cannot be dependency-invalidated.

## 7. Transition propagated-current-state `UNKNOWN` matrix

For a transition result carrying one of the seven current-state `UNKNOWN` reasons, require classification `UNKNOWN`, `proposed_state = null`, `transition_dependency = null`, `current_state = null`, downstream-active false, valid-for-protected-use false and the exact non-invalidated object.

Dependency presence is reason-specific:

| Reason class | Current dependency | Transition dependency | Top-level currentness/freshness |
|---|---|---|---|
| first six current-state reasons in Section 5.2 | `null` | `null` | `null/null` |
| `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` | non-null and satisfies Section 5.3 | `null` | per incomplete-vector aggregation in Section 13 |

The evaluator returns before transition resolution. A transition dependency is therefore forbidden for every propagated-current-state `UNKNOWN`.

## 8. Transition resolution-failure `UNKNOWN` matrix

For each exact reason:

- `MISSING_TRANSITION_EVIDENCE`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`
- `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`

require:

- classification `UNKNOWN` and exactly the named single reason;
- known non-null current state;
- non-null, fully usable current-state dependency;
- current dependency state equals payload current state;
- current dependency Connection identity equals payload Connection identity;
- `transition_dependency = null` and `proposed_state = null`;
- top-level currentness/freshness follow the incomplete-vector rule and are `null/null` because the usable current dependency is `true/true` while transition dependency is absent;
- downstream-active equals whether current state is `CN_ACTIVE`;
- valid-for-protected-use false;
- exact non-invalidated object;
- generic terminal and `terminality.current_state_terminal` are based on current state.

## 9. Selected-dependency transition `UNKNOWN` matrix

### 9.1 `TRANSITION_NOT_CURRENT_FRESH_BOUND`

Require:

- both dependencies non-null and cross-type identities distinct;
- known current state equals current dependency state;
- proposed state equals transition dependency `to_state`;
- both dependency Connection identities equal payload Connection identity;
- current dependency is fully usable;
- transition dependency fails at least one full-usability predicate from Section 4;
- classification `UNKNOWN`, exact reason, valid-for-protected-use false and exact non-invalidated object;
- downstream-active equals whether current state is `CN_ACTIVE`;
- terminal descriptors are derived from retained current and proposed states;
- top-level currentness/freshness use the complete two-dependency aggregate.

Because transition usability is tested before transition-context equality, `from_state` and `expected_state_revision` may each match or mismatch the current context in this reason class. Their structural types remain valid. If the transition dependency is fully usable, this reason is false and persistence must reject it.

### 9.2 `TRANSITION_CURRENT_CONTEXT_MISMATCH`

Require:

- both dependencies non-null, fully usable and cross-type identities distinct;
- known current state equals current dependency state;
- proposed state equals transition dependency `to_state`;
- both dependency Connection identities equal payload Connection identity;
- at least one exact mismatch is true:
  - transition dependency `from_state != payload.current_state`; or
  - transition dependency `expected_state_revision !=` the exact tuple produced by Section 12;
- classification `UNKNOWN`, exact reason, valid-for-protected-use false and exact non-invalidated object;
- top-level currentness/freshness `true/true`;
- downstream-active equals whether current state is `CN_ACTIVE`;
- terminal descriptors are derived from retained current and proposed states.

If both context bindings match, the claimed context-mismatch result is impossible and persistence must reject it.

## 10. `ADMISSIBLE` transition matrix

Require exactly:

- classification `ADMISSIBLE` and reasons empty;
- both dependencies non-null, fully usable and cross-type identities distinct;
- both dependency Connection identities equal payload Connection identity;
- current state equals current dependency state;
- proposed state equals transition dependency `to_state`;
- transition dependency `from_state` equals current state;
- transition dependency `expected_state_revision` equals the exact current dependency tuple from Section 12;
- current state is non-terminal;
- the pair is exactly one of:
  - `CN_NONE -> CN_PENDING`
  - `CN_PENDING -> CN_ACTIVE`
  - `CN_PENDING -> CN_DECLINED`
  - `CN_PENDING -> CN_WITHDRAWN`
  - `CN_PENDING -> CN_EXPIRED`
  - `CN_ACTIVE -> CN_PAUSED`
  - `CN_ACTIVE -> CN_CLOSED`
  - `CN_PAUSED -> CN_ACTIVE`
  - `CN_PAUSED -> CN_CLOSED`
- top-level currentness/freshness `true/true`;
- downstream-active equals whether current state is `CN_ACTIVE`;
- valid-for-protected-use true;
- exact non-invalidated object;
- generic terminal and `terminality.current_state_terminal` are based only on current state; proposed terminality remains descriptive.

No `ADMISSIBLE` record may omit either dependency or rely on proposed state for generic terminality.

## 11. `REJECTED` transition matrix

Every policy `REJECTED` record requires:

- both dependencies non-null, fully usable and cross-type identities distinct;
- both dependency Connection identities equal payload Connection identity;
- current state equals current dependency state;
- proposed state equals transition dependency `to_state`;
- transition dependency `from_state` equals current state;
- transition dependency `expected_state_revision` equals the exact current dependency tuple from Section 12;
- top-level currentness/freshness `true/true`;
- downstream-active equals whether current state is `CN_ACTIVE`;
- valid-for-protected-use false and exact non-invalidated object.

Reason-specific truth is then mandatory:

### 11.1 `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`

- current state is exactly `CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`;
- `terminality.current_state_terminal = true`;
- `terminality.terminal_reopen_rejected = true`;
- generic terminal true.

### 11.2 `DIRECT_NONE_TO_ACTIVE_REJECTED`

- current state `CN_NONE` and proposed state `CN_ACTIVE`;
- current-state terminal false;
- `terminality.terminal_reopen_rejected = false`;
- generic terminal false.

### 11.3 `TRANSITION_NOT_ALLOWED`

- current state is non-terminal;
- the exact current/proposed pair is absent from the nine-pair allowed matrix in Section 10;
- the pair is not `CN_NONE -> CN_ACTIVE`;
- `terminality.terminal_reopen_rejected = false`.

The terminal reason takes precedence over pair admissibility, and the direct-none reason takes precedence over the general not-allowed reason.

## 12. Exact source-revision binding helper

The canonical current-dependency conversion has exactly:

| Expected-state revision field | Current-state dependency source |
|---|---|
| `authority_owner` | `authority_owner` |
| `authority_scope` | `authority_scope` |
| `lineage` | `source_lineage` |
| `aggregate_context` | `aggregate_context` |
| `value` | `source_revision_value` |

Matched context means structural and value equality of this complete five-key tuple. No timestamp, storage order, arrival order, global revision or partial revision comparison participates.

## 13. Currentness/freshness consistency

The same independent three-valued aggregation applies to each dimension.

Current-state fact:

- dependency null → top-level `null`;
- dependency non-null → its exact `true | false | null` value.

Transition fact:

- no current dependency → `null`;
- current `false` plus transition absent → `false`;
- current `true` or `null` plus transition absent → `null`;
- both dependencies present and either value false → `false`;
- both dependencies present and both values true → `true`;
- both present, neither false and at least one null → `null`.

Consequences across the fixed matrix:

- known current and every resolved transition decision use a fully usable selected dependency set and therefore aggregate to `true/true`;
- no-dependency current or propagated transition resolution yields `null/null`;
- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` mirrors the selected current dependency values even when the failure is binding or source condition;
- resolved-current transition failures with no transition dependency aggregate to `null/null`;
- `TRANSITION_NOT_CURRENT_FRESH_BOUND` aggregates the two selected dependency values even when its failure is binding or source condition;
- `TRANSITION_CURRENT_CONTEXT_MISMATCH`, `ADMISSIBLE` and every `REJECTED` reason aggregate to `true/true`;
- dependency invalidation retains the pre-invalidation aggregate and does not fabricate currentness or freshness.

## 14. Invalidated transition matrix

Evaluator behavior permits invalidation of any transition fact retaining at least one dependency. Therefore the legal pre-invalidation shapes are:

- propagated `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` with only current dependency;
- any Section 8 transition resolution failure with only current dependency;
- either Section 9 selected-dependency `UNKNOWN` with both dependencies;
- `ADMISSIBLE` with both dependencies;
- any policy `REJECTED` result with both dependencies.

The first six propagated-current `UNKNOWN` shapes retain no dependency and cannot be dependency-invalidated.

For every valid invalidated transition require:

- classification `UNKNOWN` and reasons exactly `[DEPENDENCY_INVALIDATED]`;
- dependency set exactly retained from the pre-invalidation fact;
- invalidation identity matches exactly one retained dependency identity;
- when both exist, current/transition identities remain distinct;
- current and proposed states remain unchanged;
- any transition dependency `from_state`, `to_state` and `expected_state_revision` remain unchanged;
- top-level currentness/freshness retain the pre-invalidation aggregate;
- downstream-active false and valid-for-protected-use false;
- current-state-based generic terminal and terminal descriptors retained;
- `terminal_reopen_rejected` retained from the pre-invalidation result;
- `lifecycle_reset = false` and `connection_reopened = false`.

Invalidation changes usability and classification; it does not rewrite dependency evidence, context, terminality or lifecycle.

## 15. Generic-overlay separation and no-reopen

The accepted invariant remains:

`GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`

Generic `observeInvalidation(logical_record_identity, relation)` may update only generic projection invalidation fields. It must not mutate Product Connection payload dependencies, synthesize Product Connection dependency invalidation, or substitute logical record identity for a typed dependency identity.

Terminal states remain exactly:

`CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`

Generic terminal equals retained current-state terminality for both fact classes. Invalidated terminal facts retain their current state and stay terminal. Shared lifecycle identity continues to make a later non-terminal record ineligible after a terminal record; no extra sticky-terminal field is introduced and no authoritative state change is inferred.

## 16. R16 supersession boundary

This result supersedes the rejected R16 result only as follows:

- rejected Section 8 classification/reason consistency is replaced by Sections 5–11 and 14 of this result;
- rejected Sections 9 and 10 dependency key sets gain exactly `protected_binding_satisfied` as fixed in Section 4;
- rejected Sections 6–10 and 16 are supplemented or replaced wherever their dependency-presence, cross-field or aggregate combinations were incomplete;
- rejected final classification is replaced by Section 19 below.

Retained unchanged as review evidence unless the corrected matrix above states the narrow addition:

- exact family, payload kinds and typed fact classes;
- Binding Model A constants and generic envelope bindings;
- exact payload key sets and 8/19 reason vocabularies;
- dependency types and full `expected_state_revision` representation;
- cross-type dependency identity distinctness;
- lifecycle basis, current-state terminality and no-reopen semantics;
- normalized dependency invalidation object;
- generic-overlay separation;
- schema markers, canonical digests, deterministic record/intent/lineage/projection identities and derived correlation revision;
- privacy-minimal projection;
- IP-13A/IP-13D repair directions, IP-13E operation sufficiency and IP-13F unchanged/non-participating disposition.

No direct contradiction requires reopening any retained direction.

## 17. Persistence-stack and non-authority dispositions

- IP-13A remains compatible through one additive family validator and projection branch that enforce this corrected fail-closed matrix without weakening the generic envelope.
- IP-13D must mirror the same validator and projection behavior under `sqlite::memory:` without physical schema change.
- IP-13E remains sufficient through existing submit/retrieve operations after the future IP-13A/IP-13D repair.
- IP-13F remains unchanged and non-participating.
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING` remains controlling.
- `Match != Connection != Conversation != Relationship`.
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`.
- Derived bindings and `protected_binding_satisfied` create no Connection source authority, state mutation, permission, authentication, session, token or downstream Messaging authority.
- No raw required bindings, source payload, account identity, headers, runtime metadata, timestamps or private data are added to the projection.

## 18. R17 gate and execution receipt

The matrix is complete and no new contract blocker remains. After fresh independent acceptance of this candidate, the exact next bounded task is:

`IP-13I-R17 PRODUCT CONNECTION DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

R17 must consume this corrected matrix as fixed input. This branch does not author R17 and authorizes no Product Connection implementation or HTTP work.

Execution receipt:

- exactly one result document created;
- no code, test, persistence/application source, route, controller, IP-13F or HTTP file modified;
- no Composer, PHPUnit, Artisan, `route:list`, migration, generator, server/HTTP command, database probe, provider/network product operation, production operation, or real/private-data operation ran;
- no self-acceptance, merge, main movement, R17 authoring or implementation occurred.

Fresh independent ACCEPT/REJECT review is required before any successor authorization.

## 19. Classification

`IP-13I-R16-R1 REVIEW COMPLETE — PRODUCT CONNECTION DEPENDENCY-PRESENCE / CLASSIFICATION-REASON / STATE-DEPENDENCY / EXPECTED-REVISION CROSS-FIELD VALIDATION MATRIX FIXED — IMPOSSIBLE EVALUATOR-DERIVED RECORDS FAIL CLOSED — RETAINED R16 FAMILY/BINDING/TERMINALITY/INVALIDATION/OVERLAY/DIGEST/PERSISTENCE DIRECTIONS PRESERVED OR NARROWLY CORRECTED — R17 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
