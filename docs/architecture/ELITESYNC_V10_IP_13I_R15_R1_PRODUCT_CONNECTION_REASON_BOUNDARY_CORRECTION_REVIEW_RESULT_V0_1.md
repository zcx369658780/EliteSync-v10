# EliteSync v10｜IP-13I-R15-R1 Product Connection Reason-Boundary Correction Review Result｜v0.1

Status: `REVIEW COMPLETE — PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN BOUNDARY CORRECTED — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Publication authority and scope

- fresh `origin/main`: `7dd4deaa8302248796e59ae118d5c69f1bac4e9e`
- authority tree: `56c360a1497a18d28481badd951a67f0e9b1be84`
- review branch: `review/next-ip-13i-r15-r1-product-connection-reason-boundary-correction-v0-1`
- rejected R15 candidate used only as authorized evidence: `96a8417138f601f7400736d8d79df9f88e3f5654`
- tracked scope: exactly this one added result document
- candidate commit / sole parent / tree: established by the immutable Git publication receipt; the candidate must have the fresh authority commit above as its sole parent.

No rejected R15 commit was merged, transplanted or made an ancestor of this correction candidate.

## 2. Fixed evidence ledger

Directly read and verified:

- `AGENTS.md`: `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R15-R1 task: `f83e6ddfdd0fdbb4d57f53e30fc377a255a9538a`
- R15 task: `024b57589b7c1a0aa5fe8584cf9cb3ef8db844a2`
- R15 independent rejection: `dc5adcdbc26468f433b3a0888be593ebd9bb1125`
- rejected R15 result at exact candidate: `675baff0963da556f66d4fa86d6bc46c3eedbeba`
- Product Connection evaluator: `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority: `e98e7db731d41269a7b89e01db12e1a81364751d`
- core-domain harness acceptance: `17eba174bccdbb688043ecc98d2eae3a9df7b3d3`
- R14 acceptance: `1b40415cb7e7362cc0696e43a4d5e7868f2683b3`

## 3. Corrected boundary decision

The Product Connection evaluator exposes 25 reachable reason literals across `evaluateCurrent()`, `evaluateTransition()` and `invalidate()`. Every literal is classified exactly once below.

The correction is narrow:

- malformed shape, type, cardinality, required-field or illegal-vocabulary input is rejected before materialization;
- a structurally valid evidence object bound to another Connection, another participant set or another evidence identity remains evaluator-owned semantic conflict;
- evaluator-owned semantic conflict produces bounded persistable domain `UNKNOWN`;
- transition policy decisions remain persistable `REJECTED`, not transport/input failures;
- dependency invalidation remains its own persisted reason category.

## 4. Exact pre-materialization structural gate

A future adapter must validate every evidence item before dispatch, rather than validate only the first item selected by duplicate resolution.

The structural gate requires:

1. Connection descriptor:
   - non-empty string `connection_identity`;
   - exactly two distinct non-empty string participants;
   - non-empty string `protected_use_scope`.
2. Every current-state evidence item:
   - an array/object with the required structural fields;
   - non-empty string state-evidence identity and Connection identity;
   - a structurally valid two-participant set;
   - `state` in the accepted `CN_*` lifecycle vocabulary;
   - structurally valid source-evidence, required-binding and source-local revision containers, including the revision fields/types required by Common Authority.
3. Every transition evidence item:
   - an array/object with the required structural fields;
   - non-empty string transition identity and Connection identity;
   - a structurally valid two-participant set;
   - structurally valid `from_state`, `to_state` and expected-state-revision fields, with lifecycle literals in the accepted vocabulary;
   - structurally valid source-evidence, required-binding and source-local revision containers.

The gate validates structure, not semantic equality. A valid non-empty Connection identity may differ from the requested Connection; a valid two-participant set may differ from the Connection participants; valid evidence identities within one resolution set may differ; a valid expected revision may differ from the selected current-state revision. Those differences proceed to the evaluator.

The six and only six evaluator reason literals classified as:

`PRE_MATERIALIZATION_REJECTION_ONLY`

are, in canonical order:

1. `CONNECTION_IDENTITY_REQUIRED`
2. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
3. `PROTECTED_USE_SCOPE_REQUIRED`
4. `INVALID_EVIDENCE_SHAPE`
5. `INVALID_CONNECTION_STATE`
6. `INVALID_TARGET_STATE`

The first three map directly to malformed Connection descriptor fields. `INVALID_EVIDENCE_SHAPE` maps to a missing/non-array evidence item or missing/invalid required nested revision shape. `INVALID_CONNECTION_STATE` and `INVALID_TARGET_STATE` map to values outside the accepted lifecycle vocabulary.

Because the adapter validates every candidate first, the evaluator branch that also returns a conflicting-identity reason when a later candidate lacks a source revision is not used to reclassify malformed input as semantic conflict. Once all candidates pass the gate, the conflicting-identity literals mean only structurally valid identity disagreement.

## 5. Persisted current-state UNKNOWN reasons

The seven literals classified as:

`PERSISTED_CURRENT_STATE_UNKNOWN_REASON`

are, in canonical order:

1. `MISSING_CURRENT_STATE_EVIDENCE`
2. `CROSS_CONNECTION_STATE_EVIDENCE`
3. `STATE_PARTICIPANT_MISMATCH`
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`

The three corrected state reasons are persistable because:

- `CROSS_CONNECTION_STATE_EVIDENCE`: the evidence may be structurally complete with a valid non-empty Connection identity that differs from the requested Connection;
- `STATE_PARTICIPANT_MISMATCH`: both participant sets may be structurally valid exact two-member sets but bind different participants;
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`: every candidate may be structurally valid while candidates in one resolution set identify different state-evidence objects.

These are cross-aggregate, binding and identity conflicts. They are not malformed input.

When `evaluateTransition()` receives a current-state result with classification `UNKNOWN`, it returns a transition `UNKNOWN` carrying the same dependency vector and exact current-state reason without resolving transition evidence. The seven literals remain classified once as current-state UNKNOWN reasons; their use in a transition payload is explicit cross-fact propagation, not a second semantic category.

## 6. Persisted transition UNKNOWN reasons

The eight transition-owned literals classified as:

`PERSISTED_TRANSITION_UNKNOWN_REASON`

are, in canonical order:

1. `MISSING_TRANSITION_EVIDENCE`
2. `CROSS_CONNECTION_TRANSITION_EVIDENCE`
3. `TRANSITION_PARTICIPANT_MISMATCH`
4. `CONFLICTING_TRANSITION_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`
7. `TRANSITION_NOT_CURRENT_FRESH_BOUND`
8. `TRANSITION_CURRENT_CONTEXT_MISMATCH`

The three corrected transition reasons are persistable because:

- `CROSS_CONNECTION_TRANSITION_EVIDENCE`: a structurally complete transition can bind another valid Connection identity;
- `TRANSITION_PARTICIPANT_MISMATCH`: a structurally valid exact participant set can differ from the Connection participant set;
- `CONFLICTING_TRANSITION_IDENTITY`: structurally valid transition candidates in one resolution set can identify different transition objects.

`TRANSITION_CURRENT_CONTEXT_MISMATCH` covers semantic inequality between a structurally valid `from_state` or expected-state revision and the selected current-state context. It is not an input error.

## 7. Persisted transition REJECTED reasons

The three literals classified as:

`PERSISTED_TRANSITION_REJECTED_REASON`

are, in canonical order:

1. `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`
2. `DIRECT_NONE_TO_ACTIVE_REJECTED`
3. `TRANSITION_NOT_ALLOWED`

All three are domain/policy decisions reached after current and transition evidence resolve. They remain persistable transition `REJECTED` results and must not become HTTP/schema/input rejection.

## 8. Dependency invalidation reason

The one literal classified as:

`PERSISTED_INVALIDATION_REASON`

is:

1. `DEPENDENCY_INVALIDATED`

It applies to either typed fact depending on which already-derived result is invalidated:

- invalidated current-state fact → persisted current-state `UNKNOWN`;
- invalidated transition fact → persisted transition `UNKNOWN`.

This is one reason category with two fact-class placements. In both cases classification becomes `UNKNOWN`, `lifecycle_reset = false`, `connection_reopened = false`, and retained `current_state` / `proposed_state` context is not erased.

## 9. Duplicate and conflict distinctions

The evaluator preserves three distinct cases for each evidence type:

1. Different evidence identity within one resolution set:
   - state: `CONFLICTING_STATE_EVIDENCE_IDENTITY`;
   - transition: `CONFLICTING_TRANSITION_IDENTITY`.
   - Under the strict gate every candidate is structurally valid, so this is persistable semantic identity conflict.
2. Same evidence identity with source revisions that differ in owner, scope, lineage or aggregate context:
   - state: `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`;
   - transition: `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`.
   - These remain persistable bounded `UNKNOWN`.
3. Same evidence identity and equal source-local revision with different semantic signatures:
   - state: `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`;
   - transition: `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`.
   - These remain persistable bounded `UNKNOWN`.

Comparable higher source-local revision selects the newer candidate; equal revision with identical semantic signature remains the same result. No global revision, storage order, timestamp, LWW or arrival-order authority is introduced.

## 10. Corrected persisted payload vocabularies

### Current-state derived payload

Canonical ordered reason vocabulary:

1. `MISSING_CURRENT_STATE_EVIDENCE`
2. `CROSS_CONNECTION_STATE_EVIDENCE`
3. `STATE_PARTICIPANT_MISMATCH`
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`
8. `DEPENDENCY_INVALIDATED`

### Transition derived payload

Canonical ordered reason vocabulary:

1. `MISSING_CURRENT_STATE_EVIDENCE`
2. `CROSS_CONNECTION_STATE_EVIDENCE`
3. `STATE_PARTICIPANT_MISMATCH`
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`
8. `MISSING_TRANSITION_EVIDENCE`
9. `CROSS_CONNECTION_TRANSITION_EVIDENCE`
10. `TRANSITION_PARTICIPANT_MISMATCH`
11. `CONFLICTING_TRANSITION_IDENTITY`
12. `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`
13. `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`
14. `TRANSITION_NOT_CURRENT_FRESH_BOUND`
15. `TRANSITION_CURRENT_CONTEXT_MISMATCH`
16. `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`
17. `DIRECT_NONE_TO_ACTIVE_REJECTED`
18. `TRANSITION_NOT_ALLOWED`
19. `DEPENDENCY_INVALIDATED`

Entries 1–7 are current-state UNKNOWN reasons propagated before transition-evidence resolution. Entries 8–15 are transition-owned UNKNOWN reasons. Entries 16–18 are transition REJECTED reasons. Entry 19 is used only after dependency invalidation. The six pre-materialization diagnostics are excluded from both persisted vocabularies. No new reason literal is invented.

## 11. R15 supersession boundary

Rejected R15 Section 6 is superseded in full by Sections 3–10 of this result.

Rejected R15 Section 7 remains retained as review evidence except that its `exact classification and canonical bounded reason list` must use the corrected vocabularies in Section 10 above. No other payload requirement changes.

Rejected R15 Sections 1–5 and 8–13 remain retained unchanged as review evidence. In particular, no direct contradiction was found and these directions remain intact:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- Model A, one additive Connection family with current-state and transition typed fact classes;
- current-state-based terminality and retained no-reopen context;
- cross-type dependency identity collision avoidance;
- currentness/freshness recovery from selected source evidence;
- deterministic identity basis;
- `IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_CONNECTION_FAMILY`;
- `IP13D_CAN_RETAIN_ADDITIVE_CONNECTION_FAMILY_WITH_REFERENCE_PARITY`;
- `IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_CONNECTION_RECORD_REPAIR`;
- `IP_13F_UNCHANGED_NON_PARTICIPATING`;
- downstream Messaging remains blocked.

Rejected R15 Section 14 was the rejected candidate's publication classification. It is replaced only by this result's corrected classification; its retained directional clauses are not otherwise reopened.

## 12. R16 gate and retained boundaries

No new blocker was exposed. The next task after fresh independent acceptance of this candidate is:

`IP-13I-R16 PRODUCT CONNECTION RECORD/PROJECTION CONTRACT REVIEW — DOCUMENT ONLY`

R16 must consume the corrected canonical persisted vocabularies above as fixed input. This result does not author R16 and creates no implementation authority.

Preserve:

- `Match != Connection != Conversation != Relationship`;
- Match creates no automatic Connection;
- Connection creates no automatic Conversation;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- no global revision, LWW, arrival-order or timestamp authority;
- no authentication/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing.

Exactly this one result document was created. No code, test, persistence/application source, route, controller, IP-13F or HTTP file changed. No Composer, PHPUnit, Artisan, `route:list`, migration, generator, HTTP/server, database probe, provider/network product, production or real/private-data operation ran.

## 13. Classification

`IP-13I-R15-R1 REVIEW COMPLETE — PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN BOUNDARY CORRECTED — CROSS-CONNECTION / PARTICIPANT-MISMATCH / EVIDENCE-IDENTITY-CONFLICT REASONS RETAINED AS BOUNDED PERSISTABLE DOMAIN UNKNOWN WHERE STRUCTURALLY VALID — TRANSITION UNKNOWN VS REJECTED VOCABULARIES FIXED — R15 NEXT-DOMAIN / UNUSED-matchResult / MODEL-A / PERSISTENCE-STACK DIRECTIONS RETAINED — R16 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
