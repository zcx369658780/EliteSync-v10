# EliteSync v10｜IP-13I-R9-R1 Canonical Match Terminality / Invalidation and Record-Eligibility Contract Correction Review Acceptance｜v0.1

Status: `ACCEPTED — MODEL A STICKY TERMINALITY — STRUCTURAL INPUT REJECTION SEPARATED FROM DOMAIN UNKNOWN — TERMINAL INVALIDATION NO LONGER REOPENS LIFECYCLE — R10 GATE RESOLVED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R9-R1 task-publication commit:
`f61f84d55fd9559cee881831649226a8ad90542f`

Accepted review branch:
`review/next-ip-13i-r9-r1-terminal-invalidation-record-eligibility-correction-v0-1`

Accepted immutable candidate:
`897fbb496fd6872fc1b0d7c63e26fedac0d2f401`

Publication-reported candidate tree:
`740d989dfa5bd5e3ed2771df4b8b6c3c3ec72654`

Accepted result blob:
`114eb27d2766657d9e6fb364ce83fc8fee82c66d`

Integrated main commit:
`770f04408af0889af22e2918752db1c47dfe0508`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = f61f84d55fd9559cee881831649226a8ad90542f`;
- candidate is exactly one commit ahead / zero behind;
- candidate changes exactly one authorized result-document path;
- accepted result blob is exactly `114eb27d2766657d9e6fb364ce83fc8fee82c66d`;
- all eleven fixed evidence objects used by R9-R1 resolve to the claimed Git blobs;
- no code/runtime operation occurred;
- the exact accepted result blob was transplanted to main unchanged.

No ledger, scope or topology blocker remains.

## 2. Accepted correction model

Accepted:

`MODEL_A_STICKY_TERMINALITY_IN_MATERIALIZED_DERIVED_RECORDS`

A Canonical Match derived lifecycle that has reached a terminal classification remains terminal after later dependency invalidation changes the current classification to `UNKNOWN`.

Therefore a valid invalidated terminal payload may truthfully contain:

- current `classification = UNKNOWN`;
- `classification_before_invalidation = MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- `derived_terminal = true`;
- `bindings.terminal = true`;
- `proposal_reopened = false`;
- `lifecycle_reset = false`.

This preserves both:

- evaluator invalidation truth; and
- the accepted IP-13A terminal lifecycle guard.

Dependency invalidation is not a lifecycle reopen.

## 3. Accepted pre-invalidation binding rule

For a persisted dependency-invalidated Match result, the builder must possess an exactly bound pre-invalidation result and the evaluator-produced post-invalidation result from the same deterministic flow.

The builder must not infer the prior classification from:

- timestamps;
- arrival order;
- storage ordering;
- a global revision;
- LWW / last-received-wins semantics.

An already-invalidated `UNKNOWN` result cannot by itself serve as a fresh original pre-invalidation classification for another materialization step.

Any later R10 orchestration must either:

- begin from a fresh structurally valid evaluator result before applying invalidation; or
- exactly bind to a previously materialized pre-invalidation result whose terminality/classification context is still available and unambiguous.

R10 must not recompute sticky terminality from an already-invalidated `UNKNOWN` alone.

## 4. Accepted record-eligibility boundary

Accepted invariant:

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`

Pre-materialization rejection applies to structurally malformed or out-of-vocabulary inputs, including malformed proposal/participant/slot identities, invalid cardinality, invalid lifecycle/state/decision literals, malformed Common Authority evidence/revision shape, invalid dependency identity collisions, and invalidation requests lacking exact pre-invalidation binding.

Those failures create no persisted Match derived record.

Structurally valid but semantically unresolved/negative/conflicting evidence remains eligible for a persisted `UNKNOWN` derivation.

## 5. Accepted reason-vocabulary narrowing

Accepted pre-materialization-only categories:

- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `INVALID_PROPOSAL_SHAPE`
- `INVALID_SLOT_EVIDENCE`
- `INVALID_SLOT_DECISION`

Accepted persisted Match reason categories are exactly the fifteen bounded categories fixed by R9-R1:

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

Impossible structural categories are not retained merely for symmetry with raw evaluator diagnostics.

## 6. Accepted dependency-identity rule

For any materializable Match payload:

- proposal identity;
- both participant identities;
- all selected slot identities

must be pairwise distinct across dependency types.

The selected slot identities must also be unique across the two participants.

This is required because the accepted evaluator invalidation API carries only one untyped `dependency_identity` string.

A cross-type collision is therefore a pre-materialization rejection, not a persisted `UNKNOWN`.

No typed invalidation discriminator is required under this collision-free materialization boundary.

## 7. Accepted R9 schema disposition

The sound portions of rejected R9 remain valid only as corrected by R9-R1, including:

- additive record family:
  `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- typed proposal / participation / decision-slot dependency schemas;
- deterministic source-order-independent correlation identities;
- derived correlation revision value `0`;
- privacy-minimal payload;
- independent currentness/freshness aggregation;
- Match classification vocabulary;
- no raw source evidence in the derived payload;
- no Match/Connection/Consent/Conversation/relationship/Home/Notification/launch authority.

The rejected R9 terminality/invalidation rules are superseded by R9-R1.

The terminality object now includes:

`classification_before_invalidation`

under the exact rules accepted above.

## 8. IP-13A / IP-13E / IP-13F disposition

Accepted:

`IP13A_ENVELOPE_COMPATIBLE_AFTER_R9_R1_CORRECTION`

The future persistence implementation may extend family-specific derived-payload validation/retention without weakening the generic envelope, RR03 validator, or terminal guard.

Accepted:

`IP13E_EXISTING_OPERATIONS_STILL_SUFFICIENT_AFTER_CORRECTION`

No evaluator-orchestration method or Match-specific IP-13E family is required by the current contract.

Accepted:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

No sixth IP-13F family, Match route or HTTP contract is created.

## 9. R10 gate

R9-R1 resolves the contract blockers required before a domain-to-application mapping review.

The next bounded task may return to:

`IP-13I-R10 CANONICAL MATCH DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

That future review must define, without implementation:

- exact synthetic structural input gate;
- exact pre-invalidation / post-invalidation binding flow;
- evaluator-to-record construction;
- submit/retrieve ordering;
- exact readback comparison;
- degraded materialization dispositions;
- how repeated/already-invalidated inputs fail closed without losing sticky terminality;
- no Match source authority;
- no IP-13F participation.

This acceptance does not author or start R10.

## 10. Preserved non-authorities

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- invalidation does not reopen/reset a Match lifecycle;
- Match != Connection != Conversation != Relationship;
- Match creates no automatic Connection, Consent, Conversation, relationship, Home, Notification or launch authority;
- `UNKNOWN != ABSENT`;
- `DEFERRED != MISSING`;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no single authoritative Compatibility score;
- authentication/session/token remains unestablished;
- no production persistence/deployment authority;
- no real/private-data processing authority.

## 11. Acceptance classification

`IP-13I-R9-R1 ACCEPTED — MODEL A STICKY TERMINALITY PRESERVES TERMINAL LIFECYCLE THROUGH DEPENDENCY INVALIDATION WITHOUT REOPEN — STRUCTURAL INPUT REJECTION SEPARATED FROM PERSISTABLE DOMAIN UNKNOWN — PERSISTED REASONS NARROWED TO 15 — DEPENDENCY INVALIDATION IDENTITY COLLISION-FREE — IP-13A ENVELOPE COMPATIBLE — IP-13E EXISTING OPERATIONS SUFFICIENT — IP-13F UNCHANGED/NON-PARTICIPATING — R10 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED`
