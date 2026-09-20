# EliteSync v10｜IP-13I-R15-R1 Product Connection Reason-Boundary Correction Review Acceptance｜v0.1

Status: `ACCEPTED — PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN BOUNDARY CORRECTED — R15 CORE DIRECTION RESTORED — R16 GATE RESOLVED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R15-R1 task-publication commit:
`7dd4deaa8302248796e59ae118d5c69f1bac4e9e`

Accepted review branch:
`review/next-ip-13i-r15-r1-product-connection-reason-boundary-correction-v0-1`

Accepted immutable candidate:
`c3ae6b8d272ac4ba8be6eb0490cfc836534e112a`

Publication-reported candidate tree:
`cc831d81f89db5849b8af1c533ced79662ee31bf`

Accepted result blob:
`fb064b7e290916ba7aa42d53990c9c54d289f5ba`

Integrated main commit:
`b7e9fd91aa88f479a624f428a79990deda33c691`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = 7dd4deaa8302248796e59ae118d5c69f1bac4e9e`;
- candidate is exactly one commit ahead / zero behind;
- exactly one authorized result document is added;
- rejected R15 candidate is not an ancestor of the accepted correction candidate;
- all fixed ledger objects resolve to the exact claimed blobs;
- the evaluator's reachable reason literals are fully covered by the corrected classification;
- no code/runtime action occurred;
- the exact accepted result blob was transplanted to main unchanged.

## 2. Accepted complete reason boundary

Accepted pre-materialization-only diagnostics:

1. `CONNECTION_IDENTITY_REQUIRED`
2. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
3. `PROTECTED_USE_SCOPE_REQUIRED`
4. `INVALID_EVIDENCE_SHAPE`
5. `INVALID_CONNECTION_STATE`
6. `INVALID_TARGET_STATE`

A future adapter may reject these before record construction only after validating every supplied state/transition evidence item structurally.

Accepted current-state bounded `UNKNOWN` reasons:

1. `MISSING_CURRENT_STATE_EVIDENCE`
2. `CROSS_CONNECTION_STATE_EVIDENCE`
3. `STATE_PARTICIPANT_MISMATCH`
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`

Accepted transition-owned bounded `UNKNOWN` reasons:

1. `MISSING_TRANSITION_EVIDENCE`
2. `CROSS_CONNECTION_TRANSITION_EVIDENCE`
3. `TRANSITION_PARTICIPANT_MISMATCH`
4. `CONFLICTING_TRANSITION_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`
7. `TRANSITION_NOT_CURRENT_FRESH_BOUND`
8. `TRANSITION_CURRENT_CONTEXT_MISMATCH`

Accepted transition `REJECTED` reasons:

1. `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`
2. `DIRECT_NONE_TO_ACTIVE_REJECTED`
3. `TRANSITION_NOT_ALLOWED`

Accepted invalidation reason:

`DEPENDENCY_INVALIDATED`

It may appear in either fact class after invalidating a retained dependency.

## 3. Corrected persisted vocabularies

Current-state persisted reason vocabulary is exactly the seven current-state UNKNOWN reasons plus:

`DEPENDENCY_INVALIDATED`

for a total of eight.

Transition persisted reason vocabulary contains:

- the seven propagated current-state UNKNOWN reasons;
- the eight transition-owned UNKNOWN reasons;
- the three transition REJECTED reasons;
- `DEPENDENCY_INVALIDATED`;

for a total of nineteen.

Cross-Connection evidence, participant-set mismatch and conflicting evidence identity are semantic conflict when the supplied evidence is structurally valid. They must not be converted into transport/input rejection merely for implementation convenience.

## 4. Retained R15 decisions now accepted

With the reason-boundary defect corrected, accept the retained R15 directions:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- Model A: one additive Product Connection derived family with two typed fact classes;
- current-state-based lifecycle terminality;
- state/transition dependency identities must remain unambiguous for opaque invalidation identity;
- selected source evidence must supply nullable currentness/freshness for future persistence mapping;
- deterministic correlation must remain source-order independent;
- `IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_CONNECTION_FAMILY`;
- `IP13D_CAN_RETAIN_ADDITIVE_CONNECTION_FAMILY_WITH_REFERENCE_PARITY`;
- `IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_CONNECTION_RECORD_REPAIR`;
- `IP_13F_UNCHANGED_NON_PARTICIPATING`;
- Messaging Consent / Conversation remains downstream and blocked by Product Connection vertical-slice closure.

The rejected R15 candidate itself remains rejected and is not integrated.

## 5. Product Connection semantic boundaries

Preserve:

- `Match != Connection != Conversation != Relationship`;
- Match creates no automatic Connection;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `TRANSITION_ADMISSIBLE != CONNECTION_CREATED`;
- `TRANSITION_ADMISSIBLE != CONNECTION_ACTIVATED`;
- Connection creates no automatic messaging consent or Conversation;
- current/proposed states retained through invalidation do not create lifecycle reset or reopen authority.

## 6. R16 gate

R16 is now authorized as the next bounded document-only task:

`IP-13I-R16 PRODUCT CONNECTION RECORD/PROJECTION CONTRACT REVIEW — DOCUMENT ONLY`

It must consume the corrected persisted vocabularies above and fix the exact additive family / typed payload / dependency / terminality / invalidation / aggregation / identity / persistence-repair contract before any implementation.

No Product Connection implementation, application adapter or HTTP work is authorized by this acceptance.

## 7. Acceptance classification

`IP-13I-R15-R1 ACCEPTED — PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN BOUNDARY CORRECTED — SIX CROSS-AGGREGATE/PARTICIPANT/EVIDENCE-IDENTITY CONFLICT REASONS RETAINED AS PERSISTABLE DOMAIN UNKNOWN — CURRENT-STATE 8-REASON AND TRANSITION 19-REASON PERSISTED VOCABULARIES FIXED — R15 NEXT-DOMAIN / UNUSED-matchResult / MODEL-A / IP-13A/IP-13D/IP-13E/IP-13F DIRECTIONS ACCEPTED — R16 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED`
