# EliteSync v10｜IP-13I-R15 Candidate Independent Review｜v0.1

Status: `REJECTED — NEXT-DOMAIN / MODEL-A DIRECTION RETAINED BUT REASON-BOUNDARY CLASSIFICATION CONVERTS VALID DOMAIN UNKNOWN INTO PRE-MATERIALIZATION ERROR — R16 NOT YET AUTHORIZED — R15-R1 DOCUMENT-ONLY CORRECTION REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`:
`3fbd03e3b713d35b5087e6a129744a6f992b54dc`

Reviewed branch:
`review/next-ip-13i-r15-product-connection-entry-mapping-readiness-v0-1`

Reviewed candidate:
`96a8417138f601f7400736d8d79df9f88e3f5654`

Candidate sole parent:
`3fbd03e3b713d35b5087e6a129744a6f992b54dc`

Candidate tree:
`38d5ebc80db460cd2408a575bc98278fe6257c73`

Candidate result blob:
`675baff0963da556f66d4fa86d6bc46c3eedbeba`

## 1. Retained sound direction

The following directions are not rejected:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- one additive Product Connection derived family with typed current-state and transition fact classes remains plausible;
- current-state and transition derivations require an explicit record/projection contract before application/HTTP;
- cross-type state/transition dependency identity collision must be addressed because invalidation accepts one opaque identity;
- currentness/freshness must be recovered from the selected source evidence because the evaluator dependency vector omits them;
- current-state-based terminality and no-reopen semantics remain the correct basis;
- `IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_CONNECTION_FAMILY` remains plausible;
- `IP13D_CAN_RETAIN_ADDITIVE_CONNECTION_FAMILY_WITH_REFERENCE_PARITY` remains plausible;
- `IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_CONNECTION_RECORD_REPAIR` remains plausible;
- `IP_13F_UNCHANGED_NON_PARTICIPATING`;
- downstream Messaging/Conversation remains blocked by Product Connection vertical-slice closure.

These remain review evidence, not accepted R15 contract.

## 2. Blocking reason-boundary defect

R15 task explicitly requires:

- distinguish malformed structural input from valid domain `UNKNOWN`;
- do not convert valid domain `UNKNOWN` or transition `REJECTED` into input errors.

The candidate classifies the following as `PRE_MATERIALIZATION_REJECTION_ONLY`:

- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`

However the accepted evaluator produces these only after the outer Connection descriptor can be evaluated and while resolving a structurally present evidence list.

They are not equivalent to malformed shape/illegal literal diagnostics such as:

- `CONNECTION_IDENTITY_REQUIRED`
- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `PROTECTED_USE_SCOPE_REQUIRED`
- `INVALID_EVIDENCE_SHAPE`
- `INVALID_CONNECTION_STATE`
- `INVALID_TARGET_STATE`.

Specifically:

- cross-Connection evidence has a valid evidence object but binds another Connection identity;
- participant mismatch has a valid evidence object but the evidence participant set does not match the Connection participant set;
- conflicting evidence identity occurs when multiple structurally present candidates identify different state/transition evidence objects in one resolution set.

The evaluator returns a bounded `UNKNOWN` result for these cases rather than a malformed result object.

This is analogous to the already accepted distinction elsewhere in the architecture between structural rejection and bounded semantic mismatch/conflict.

If R16 inherited the candidate classification, a future adapter would reject these cases before persistence and the derived record family would fail to represent all accepted bounded Product Connection `UNKNOWN` outcomes.

## 3. Required corrected classification

R15-R1 must independently confirm the exact boundary, but the evidence currently supports:

### Pre-materialization rejection only

- `CONNECTION_IDENTITY_REQUIRED`
- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `PROTECTED_USE_SCOPE_REQUIRED`
- `INVALID_EVIDENCE_SHAPE`
- `INVALID_CONNECTION_STATE`
- `INVALID_TARGET_STATE`

### Persistable current-state/domain UNKNOWN candidates

- `MISSING_CURRENT_STATE_EVIDENCE`
- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
- `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`
- `DEPENDENCY_INVALIDATED`

### Persistable transition UNKNOWN / decision candidates

- propagated current-state bounded UNKNOWN reasons above where transition evaluation is blocked by current-state resolution;
- `MISSING_TRANSITION_EVIDENCE`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`
- `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`
- `TRANSITION_NOT_CURRENT_FRESH_BOUND`
- `TRANSITION_CURRENT_CONTEXT_MISMATCH`
- `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`
- `DIRECT_NONE_TO_ACTIVE_REJECTED`
- `TRANSITION_NOT_ALLOWED`
- `DEPENDENCY_INVALIDATED` when a retained transition/current-state dependency is invalidated.

R15-R1 must distinguish which of these map to `UNKNOWN` versus `REJECTED` without changing evaluator semantics.

## 4. Candidate disposition

Candidate:

`96a8417138f601f7400736d8d79df9f88e3f5654`

is not authorized for integration.

R16 must not yet be issued because its persisted reason vocabulary depends directly on this unresolved boundary.

The next task must be:

`IP-13I-R15-R1 PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN REASON-BOUNDARY CORRECTION REVIEW — DOCUMENT ONLY`

No implementation is authorized.

## 5. Final classification

`IP-13I-R15 CANDIDATE REJECTED — PRODUCT CONNECTION REMAINS NEXT DOMAIN AND MODEL-A/UNUSED-matchResult/PERSISTENCE-STACK DIRECTIONS RETAINED AS REVIEW EVIDENCE — SIX CROSS-AGGREGATE/PARTICIPANT/IDENTITY-CONFLICT REASONS WERE INCORRECTLY CLASSIFIED AS PRE-MATERIALIZATION REJECTION DESPITE EVALUATOR RETURNING BOUNDED DOMAIN UNKNOWN — R16 DEFERRED — R15-R1 DOCUMENT-ONLY REASON-BOUNDARY CORRECTION REQUIRED`
