# EliteSync v10｜IP-13I-R15 Product Connection Vertical-Slice Entry and Mapping-Readiness Review Result｜v0.1

Status: `REVIEW COMPLETE — NEXT DOMAIN = PRODUCT_CONNECTION — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Authority / candidate publication:

- fresh `origin/main`: `3fbd03e3b713d35b5087e6a129744a6f992b54dc`
- authority sole parent: `d09edcea6730d5d4cea87e90b38e9938f05bbeea`
- authority tree: `291e16e7c821ad27f6dccbc26f3dfebd791d3e53`
- review branch: `review/next-ip-13i-r15-product-connection-entry-mapping-readiness-v0-1`
- candidate commit / sole parent / tree: publication receipt to be reported from the immutable Git commit; the candidate must have the authority commit above as its sole parent and exactly this one added path.

## 1. Decision

Accepted for fresh independent review:

`NEXT_DOMAIN = PRODUCT_CONNECTION`

Canonical Match is closed through its synthetic/dev-test HTTP entry. Product Connection is the earliest remaining domain with an accepted evaluator and no unresolved upstream semantic/application authority consumed by that evaluator. Messaging Consent / Conversation remains downstream.

Persistence decision:

`MODEL_A — ONE ADDITIVE PRODUCT_CONNECTION FAMILY WITH TWO TYPED DERIVED FACT CLASSES`

Proposed family:

`PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`

Typed derived fact classes:

- `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`
- `PRODUCT_CONNECTION_TRANSITION_DERIVATION`

The two facts share one Connection lifecycle, participant set, protected-use scope and invalidation namespace. Their payload shapes and terminal meanings remain explicitly typed; no field is overloaded.

## 2. Fixed evidence ledger

Directly read and verified at the authority commit:

- `AGENTS.md`: `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R15 task: `024b57589b7c1a0aa5fe8584cf9cb3ef8db844a2`
- R8 acceptance: `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`
- R14 acceptance: `1b40415cb7e7362cc0696e43a4d5e7868f2683b3`
- core-domain harness acceptance: `17eba174bccdbb688043ecc98d2eae3a9df7b3d3`
- Product Connection evaluator: `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority: `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A: `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`
- IP-13D: `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`
- IP-13E: `aa9721dfa66fe17eb2314bc9466870d479c07644`
- IP-13F: `e70f260de92a0047e70b54827f4795edb3b74e00`
- Canonical Match application adapter, contrast only: `789e8905b2c9ee54d902d8b600100896af4f6063`

## 3. Optional Match result

Decision:

`MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`

`evaluateTransition(..., ?array $matchResult = null)` never reads `$matchResult`. Current Product Connection semantics depend only on the Connection descriptor, current-state evidence and transition evidence. The parameter creates no persisted dependency, Match authority, automatic Connection creation, or Match-to-Connection progression.

## 4. Current-state derivation

`evaluateCurrent()` returns:

- `record_kind = PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`;
- classification vocabulary `CN_NONE | CN_PENDING | CN_ACTIVE | CN_PAUSED | CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED | UNKNOWN`;
- `current_state` equal to the known classification, otherwise `null` before invalidation;
- `proposed_state = null`;
- exactly one `current_state` dependency when source evidence resolves, otherwise `null`;
- `connection_active_for_downstream_consideration = true` only for `CN_ACTIVE`;
- `valid_for_protected_use = true` for a known, usable source state and false for `UNKNOWN`.

Terminal states are exactly:

`CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`

Duplicate selection is source-local: all entries in one evidence set must share one state-evidence identity; comparable higher source revisions supersede lower ones; equal revisions must have identical semantic signatures; incomparable revisions and conflicting equal revisions resolve to bounded `UNKNOWN`. No global revision, storage order, timestamp, last-write-wins or arrival-order rule exists.

The selected current-state dependency preserves `state_evidence_identity`, Connection identity, state, source-local revision and source condition. A future privacy-minimal persisted dependency must additionally preserve exact nullable source `currentness` and `freshness`; the evaluator result alone does not currently expose those two values.

All evaluator non-authority fields remain false, including source authority, Connection creation/activation, Match substitution, messaging consent, Conversation, Relationship, Home, Notification, launch, bearer capability, ranking, Compatibility total, desirability and person-worth.

## 5. Transition derivation

`evaluateTransition()` returns:

- `record_kind = PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- classification `ADMISSIBLE | REJECTED | UNKNOWN`;
- resolved current state and, when available and structurally valid, proposed state;
- the current-state dependency and, once resolved, the transition dependency;
- `connection_active_for_downstream_consideration` derived only from the current state;
- `valid_for_protected_use = true` only for `ADMISSIBLE`.

The transition dependency preserves `transition_identity`, Connection identity, `from_state`, `to_state`, source-local revision and source condition. The exact expected-state-revision relation must also be preserved in the future transition payload because admissibility requires it to equal the selected current-state source revision. Future privacy-minimal dependency entries must preserve exact nullable source currentness/freshness without carrying raw source evidence or raw required-bindings objects.

Allowed transitions are exactly:

- `CN_NONE → CN_PENDING`
- `CN_PENDING → CN_ACTIVE | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`
- `CN_ACTIVE → CN_PAUSED | CN_CLOSED`
- `CN_PAUSED → CN_ACTIVE | CN_CLOSED`

A terminal current state rejects every attempted reopen. `CN_NONE → CN_ACTIVE` is explicitly rejected. Other unlisted transitions are rejected.

`TRANSITION_ADMISSIBLE != CONNECTION_CREATED`

`TRANSITION_ADMISSIBLE != CONNECTION_ACTIVATED`

An admissible transition to a terminal proposed state remains a descriptive decision. It does not make the persisted Connection lifecycle terminal until authoritative current-state evidence says so.

## 6. Exact reason classification

### `PRE_MATERIALIZATION_REJECTION_ONLY`

- `CONNECTION_IDENTITY_REQUIRED`
- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `PROTECTED_USE_SCOPE_REQUIRED`
- `INVALID_EVIDENCE_SHAPE`
- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `INVALID_CONNECTION_STATE`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`
- `INVALID_TARGET_STATE`

These describe malformed descriptors, evidence shapes, cross-aggregate sets, mixed identities or values outside the accepted vocabulary. They must not be persisted as derived domain facts.

### `PERSISTED_CONNECTION_REASON_CATEGORY`

- `MISSING_CURRENT_STATE_EVIDENCE`
- `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`
- `DEPENDENCY_INVALIDATED`

These are bounded valid-domain `UNKNOWN` outcomes for the current-state fact. When current-state resolution blocks transition evaluation, the same exact reason may be propagated into a transition fact.

### `TRANSITION_DECISION_REASON_CATEGORY`

- `MISSING_TRANSITION_EVIDENCE`
- `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`
- `TRANSITION_NOT_CURRENT_FRESH_BOUND`
- `TRANSITION_CURRENT_CONTEXT_MISMATCH`
- `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`
- `DIRECT_NONE_TO_ACTIVE_REJECTED`
- `TRANSITION_NOT_ALLOWED`

The first five yield a valid transition-domain `UNKNOWN`; the last three yield `REJECTED`. Neither class is an input error.

No evaluator reason remains `INSUFFICIENT_EVIDENCE` after this inventory.

## 7. Payload and dependency contract required next

The future family must retain a common privacy-minimal base:

- payload kind and exact typed fact class;
- Connection identity;
- canonical lexicographically sorted two-participant references;
- protected-use scope;
- exact classification and canonical bounded reason list;
- descriptive downstream-active flag;
- exact invalidation object;
- no raw source evidence, raw required bindings, credential/token/session, private Conversation content, provider data, or transport metadata.

Current-state payload adds the known current state or `null`, one nullable typed current-state dependency and a terminal marker derived from the preserved current state.

Transition payload adds current state, proposed state, current-state dependency, nullable transition dependency, the expected-state-revision binding, `current_state_terminal`, `proposed_state_terminal`, and `terminal_reopen_rejected`. Its common envelope terminal marker is based on authoritative current state only, never merely on an admissible proposed state.

## 8. Dependency identity, revision and invalidation

Current-state and transition dependency identities must be non-empty, type-qualified and collision-free across both types within a transition payload. The invalidation API accepts one opaque identity; allowing the same literal to identify both dependency types would make invalidation ambiguous.

Dependency order is canonical: current-state first, transition second; identity comparison is type-aware. Participant references are canonical sorted sets. Source revisions remain source-local and are compared only within the same authority owner, scope, lineage and aggregate context.

Invalidation matches only a retained current-state or transition dependency identity. It changes derived classification to `UNKNOWN`, makes downstream-active and protected-use flags false, records the exact relation/identity, and preserves current/proposed state, dependency vector, `lifecycle_reset = false` and `connection_reopened = false`.

No additional sticky classification field is required. A current-state fact retains its exact current state through invalidation. A transition fact retains both current and proposed state. Therefore a terminal current lifecycle remains identifiable after classification becomes `UNKNOWN`, while an admissible proposal to a terminal state still cannot masquerade as an authoritative terminal state. Existing IP-13A `TERMINAL_IDENTITY_REOPEN_REJECTED` must bind to the stable Connection lifecycle identity and the current-state-based terminal marker.

## 9. Currentness and freshness

The next record/projection contract must add nullable `currentness` and `freshness` to each typed dependency because the evaluator's public dependency vector omits them.

Exact aggregation:

- current-state with no uniquely selected dependency: `null / null`;
- current-state with one selected dependency: preserve that dependency's exact nullable values;
- transition with resolved current state but no uniquely selected transition dependency: `null / null` for the incomplete aggregate;
- transition with both selected dependencies: per dimension, `false` if any selected dependency is false, `true` only if both are true, otherwise `null`;
- invalidation: retain the dependency-derived snapshot aggregate; invalidation independently makes the result unusable and must not rewrite source observations as a fabricated currentness/freshness value.

This is not Runtime Readiness or Canonical Match aggregation by analogy. It follows the Product Connection evaluator's one-dependency current fact and two-dependency transition fact.

## 10. Deterministic identities

The stable lifecycle basis is:

- additive Connection record family;
- Connection identity;
- protected-use scope;
- canonical participant set;
- exact subject, audience, purpose and aggregate-context descriptive bindings required by the future contract.

It excludes classification, proposed transition result, dependency revision vector, invalidation relation, storage/arrival order and timestamps.

The future logical record identity, logical intent identity, source projection lineage and projection identity must be separate fixed prefixes over the same canonical digest of:

- record family;
- typed fact class;
- canonical common bindings;
- canonical privacy-minimal typed payload;
- a fixed schema marker.

Associative keys and reason order are canonical; participants are sorted; typed dependencies have fixed positions. This produces source-order-independent correlation while retaining exact semantic differences and source-local revisions in the record digest.

## 11. Persistence and application decisions

IP-13A:

`IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_CONNECTION_FAMILY`

The generic envelope already carries bindings, source revision, currentness/freshness, intent, projection metadata and a derived payload. Current IP-13A allows non-null derived payloads only for RR03 and Canonical Match, so Product Connection requires an additive family constant plus family-specific exact validation, retention, reason ordering, terminality and invalidation rules. Generic envelope semantics need no change.

IP-13D:

`IP13D_CAN_RETAIN_ADDITIVE_CONNECTION_FAMILY_WITH_REFERENCE_PARITY`

The SQLite reference stores the generic record as payload in the existing `logical_records` layout. It needs allowlist/retention and projection/invalidation parity for the additive family, but no table, column, migration, persistent database or physical schema change.

IP-13E:

`IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_CONNECTION_RECORD_REPAIR`

Generic submission, exact-lineage/current projection retrieval and invalidation observation are sufficient once the Connection record/projection contract exists. R15 adds no Product Connection-specific IP-13E method. A later mapping review must define construction, ordering and readback equivalence before implementation.

IP-13F:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

Its five generic transport-neutral families remain unchanged. No sixth family and no Connection HTTP endpoint is selected.

## 12. Downstream gating and next task

- Messaging Consent / Conversation remains blocked by Product Connection record, persistence, application and later entry closure.
- Calm Home remains blocked by multiple upstream projections.
- Notification remains blocked by upstream state/event materialization.

Exact next task type:

`PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW — DOCUMENT ONLY`

Exact next task:

`IP-13I-R16 PRODUCT CONNECTION RECORD/PROJECTION CONTRACT REVIEW — DOCUMENT ONLY`

R16 may read only the accepted R15 result, Product Connection evaluator, Common Authority, current IP-13A/IP-13D/IP-13E, and the minimum accepted provenance documents named by its task. It must create exactly one review-result document. It must fix the additive family name, exact typed payload keys, reason allowlists, dependency fields and collision rules, terminal/invalidation validation, aggregation, deterministic identities, privacy-minimal projection and IP-13A/IP-13D repair scope. It must not modify code, tests, routes, controllers, persistence/application sources, IP-13F, or begin implementation/HTTP/downstream Messaging work.

## 13. Retained boundaries

Preserve:

- `Match != Connection != Conversation != Relationship`;
- Match creates no automatic Connection;
- Connection creates no automatic Conversation;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- `UNKNOWN != ABSENT`;
- `DEFERRED != MISSING`;
- no global revision, LWW, arrival-order or timestamp authority;
- no single authoritative Compatibility score;
- private Conversation is not default ranking/training/ads data;
- no authentication/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing.

Exactly this one result document was created. No code, route, controller, test, persistence/application/transport source or accepted artifact was modified. No Composer, PHPUnit, Artisan, `route:list`, migration, generator, server/HTTP, database probe, provider/network product, production or real/private-data operation ran.

## 14. Classification

`IP-13I-R15 REVIEW COMPLETE — NEXT DOMAIN = PRODUCT_CONNECTION — OPTIONAL matchResult UNUSED/NON-PARTICIPATING UNDER CURRENT EVALUATOR — CURRENT-STATE + TRANSITION DERIVATIONS REQUIRE EXPLICIT CONNECTION DERIVED RECORD/PROJECTION CONTRACT BEFORE APPLICATION/HTTP — TERMINALITY/INVALIDATION/DEPENDENCY IDENTITY AND SOURCE-LOCAL REVISION BOUNDARIES FIXED FOR NEXT REVIEW — IP-13E EXISTING OPERATIONS SUFFICIENT AFTER RECORD REPAIR — IP-13F UNCHANGED/NON-PARTICIPATING — DOWNSTREAM MESSAGING REMAINS BLOCKED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
