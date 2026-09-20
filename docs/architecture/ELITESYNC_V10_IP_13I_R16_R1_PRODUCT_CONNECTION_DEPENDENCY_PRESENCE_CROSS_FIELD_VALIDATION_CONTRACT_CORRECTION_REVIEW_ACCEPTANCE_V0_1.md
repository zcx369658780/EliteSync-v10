# EliteSync v10｜IP-13I-R16-R1 Product Connection Dependency-Presence and Cross-Field Validation Contract Correction Review Acceptance｜v0.1

Status: `ACCEPTED — PRODUCT CONNECTION CROSS-FIELD MATRIX COMPLETE — protected_binding_satisfied ADDED AS MINIMAL NON-AUTHORITATIVE VALIDATION METADATA — R16 CORE CONTRACT RESTORED — R17 GATE RESOLVED`

Date: 2026-09-21 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R16-R1 task-publication commit:
`f8fc238eb7c6a764342af6de08a0db692d367c14`

Accepted review branch:
`review/next-ip-13i-r16-r1-product-connection-cross-field-validation-correction-v0-1`

Accepted immutable candidate:
`c678b79e485c2f538fac7b00928949aff168d00c`

Publication-reported candidate tree:
`dbc53d8a5a290d4a8818d82b07c1ebf9b53f3e0a`

Accepted result blob:
`f0da912cb3dcb1525fa36053168310f187cf58cb`

Integrated main commit:
`5e31b335f760f8ed98fa82ea79d2b8c692558e2a`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = f8fc238eb7c6a764342af6de08a0db692d367c14`;
- candidate is exactly one commit ahead / zero behind;
- exactly one authorized result document is added;
- rejected R16 candidate is not an ancestor of the accepted correction candidate;
- all ten fixed ledger objects resolve to the exact claimed blobs;
- no code/runtime action occurred;
- the exact accepted result blob was transplanted to main unchanged.

## 2. Accepted narrow schema correction

Accepted Section 17 decision:

`TYPED_DEPENDENCY_SCHEMA_REQUIRES_MINIMAL_BINDING-SATISFACTION_METADATA`

Both typed Product Connection dependencies add exactly:

`protected_binding_satisfied: bool`

after `source_condition` and before `currentness`.

This boolean is computed from:

- Common Authority exact required/source binding equality; and
- Product Connection evaluator-specific descriptor binding checks.

For current-state evidence it also covers the exact terminal-binding consistency with `isTerminal(state)`.

It deliberately excludes:

- source condition;
- currentness;
- freshness;

because those remain separately persisted and independently validated.

A retained typed dependency is fully usable exactly when:

- `protected_binding_satisfied = true`;
- `source_condition = PRESENT`;
- `currentness = true`;
- `freshness = true`.

The boolean is non-authoritative metadata. It creates no source authority, permission, authentication identity, bearer capability or state mutation.

## 3. Accepted current-state matrix

Known current-state classifications require:

- exactly one selected current-state dependency;
- dependency Connection identity = payload Connection identity;
- dependency state = payload current state;
- dependency fully usable;
- dependency and top-level currentness/freshness = `true/true`;
- reasons empty;
- `current_state = classification`;
- correct downstream-active, protected-use and terminality flags.

Known current state without a selected usable dependency is invalid.

For ordinary current-state `UNKNOWN`:

- six resolution/conflict reasons carry no selected dependency and require:
  - `current_state = null`;
  - dependency = null;
  - top-level currentness/freshness = `null/null`;
- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` requires one selected dependency and at least one fully-usable predicate false.

Invalidated current-state facts require a retained dependency and preserve the exact pre-invalidation dependency/state/currentness/freshness snapshot.

## 4. Accepted transition matrix

Transition facts now fail closed across every evaluator outcome.

Accepted rules include:

- propagated current-state `UNKNOWN` never gains a transition dependency;
- transition resolution-failure `UNKNOWN` retains one fully usable current-state dependency and no transition dependency;
- `TRANSITION_NOT_CURRENT_FRESH_BOUND` retains both dependencies, with the current dependency usable and the transition dependency failing at least one fully-usable predicate;
- `TRANSITION_CURRENT_CONTEXT_MISMATCH` retains both fully usable dependencies and requires an actual mismatch in from-state or expected-state revision;
- `ADMISSIBLE` requires both dependencies, exact current/from and proposed/to binding, exact expected-current revision equality and one allowed transition pair;
- every policy `REJECTED` result requires both dependencies and exact context binding before reason-specific policy truth is checked;
- invalidated transition facts preserve the exact pre-invalidation dependency set and context.

No evaluator-impossible combination is valid merely because individual fields are well typed.

## 5. Accepted exact revision binding

Transition context matching uses the exact five-field tuple reconstructed from current-state dependency:

- authority owner;
- authority scope;
- source lineage;
- aggregate context;
- source revision value.

The transition dependency's `expected_state_revision` must equal that exact tuple for matched-context outcomes.

No timestamp, arrival order, partial revision, global revision or LWW rule participates.

## 6. Accepted currentness/freshness aggregation

Current-state:

- no dependency → `null`;
- selected dependency → exact dependency value.

Transition, independently per dimension:

- no current dependency → `null`;
- current=false and transition absent → `false`;
- current=true/null and transition absent → `null`;
- both present and either=false → `false`;
- both=true → `true`;
- both present, no false and at least one null → `null`.

Known current facts, `ADMISSIBLE`, `TRANSITION_CURRENT_CONTEXT_MISMATCH` and policy `REJECTED` therefore use fully usable selected dependency sets and aggregate to `true/true`.

Dependency invalidation retains the pre-invalidation aggregate and does not fabricate source observations.

## 7. R16 contract restored

With this correction, accept the retained R16 directions:

- record family:
  `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- fact classes:
  - `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`
  - `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A derivation-owned deterministic correlation bindings;
- exact 8/19 reason vocabularies;
- full typed dependencies plus `protected_binding_satisfied`;
- full `expected_state_revision` tuple;
- cross-type dependency identity distinctness;
- current-state-based terminality;
- normalized dependency invalidation;
- generic projection invalidation separated from Product Connection dependency invalidation;
- deterministic lifecycle/record/intent/lineage/projection correlation;
- IP-13A additive-family compatibility;
- IP-13D reference parity without physical schema change;
- IP-13E existing-operation sufficiency;
- IP-13F unchanged/non-participating.

The rejected original R16 candidate remains rejected and is not integrated.

## 8. R17 gate

The Product Connection persistence contract is now sufficiently fixed to review evaluator→application orchestration.

Next authorized task:

`IP-13I-R17 PRODUCT CONNECTION DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

R17 must define:

- exact synthetic structural input gates;
- exact current-state / transition / dependency-invalidation application operations;
- evaluator call counts;
- exact selected-evidence recovery;
- computation of `protected_binding_satisfied`;
- typed payload and logical-record construction;
- one IP-13E submit;
- conditional exact-lineage retrieve;
- strict readback equivalence;
- storage/materialization dispositions;
- duplicate/incomparable/terminal-reopen behavior;
- exact implementation sequencing between persistence-family repair and application-adapter implementation.

R17 does not implement code or HTTP.

## 9. Preserved non-authorities

Preserve:

- `Match != Connection != Conversation != Relationship`;
- Match creates no automatic Connection;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `TRANSITION_ADMISSIBLE != CONNECTION_CREATED`;
- `TRANSITION_ADMISSIBLE != CONNECTION_ACTIVATED`;
- Connection creates no automatic messaging consent or Conversation;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no auth/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing.

## 10. Acceptance classification

`IP-13I-R16-R1 ACCEPTED — PRODUCT CONNECTION DEPENDENCY-PRESENCE AND CROSS-FIELD MATRIX COMPLETE — protected_binding_satisfied ADDED AS MINIMAL NON-AUTHORITATIVE TYPED-DEPENDENCY METADATA — IMPOSSIBLE EVALUATOR-DERIVED RECORDS FAIL CLOSED — R16 FAMILY/BINDING/8-19-REASONS/TERMINALITY/INVALIDATION/OVERLAY/DIGEST/IP-13A-D-E-F DIRECTIONS ACCEPTED — R17 DOMAIN-TO-APPLICATION MAPPING REVIEW AUTHORIZED — NO IMPLEMENTATION OR HTTP AUTHORIZED`
