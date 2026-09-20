# EliteSync v10｜IP-13I-R9-R1 Canonical Match Terminality / Invalidation and Record-Eligibility Contract Correction Review Result｜v0.1

Status: `CANDIDATE — DOCUMENT-ONLY CORRECTION REVIEW COMPLETE — MODEL A STICKY TERMINALITY SELECTED — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh authority / candidate sole parent: `f61f84d55fd9559cee881831649226a8ad90542f`

Authority sole parent / task-publication base: `24597e1b4e4ff19e4fea9438dee63566df03c622`

Authority tree: `72200a8e428bd7f09fbc90d3d1af384901fbfb6e`

Review branch: `review/next-ip-13i-r9-r1-terminal-invalidation-record-eligibility-correction-v0-1`

Candidate commit/tree and authority-relative ahead/behind are resolved externally after immutable publication because this document participates in those identities. The candidate must have the fresh authority as its sole parent and be `0 / 1` behind/ahead relative to that authority.

## 1. Decisions

`MODEL_A_STICKY_TERMINALITY_IN_MATERIALIZED_DERIVED_RECORDS`

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`

`IP13A_ENVELOPE_COMPATIBLE_AFTER_R9_R1_CORRECTION`

`IP13E_EXISTING_OPERATIONS_STILL_SUFFICIENT_AFTER_CORRECTION`

`IP_13F_UNCHANGED_NON_PARTICIPATING`

The additive family remains:

`CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`

The correction preserves dependency-scoped invalidation without reopening a terminal lifecycle. It also makes record eligibility narrower than the raw evaluator input type: malformed inputs are rejected before derived-record construction, while structurally valid semantic uncertainty remains a persistable `UNKNOWN` result.

This review authorizes no implementation.

## 2. Scope and evidence ledger

This candidate creates exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing tracked file changes.

Actual authorized inputs and blobs:

| Evidence | Blob |
|---|---|
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R9-R1 task | `ac3b9c0bf5dad0ffada8ecd1e188935ef6a41ff7` |
| R9 task | `b0208d28b3e39efb7cbafac4a871f7f485a3b1e8` |
| R9 independent rejection | `14dcd17ebc5f5dc083bdb9c7f8ee2b188ea55a36` |
| rejected R9 result, read from candidate `b03966d09e91430a31a03eecf5d3b8575602357d` | `1f8394b25ee54373bf4d4e8836075b13b8efcbf1` |
| R8 acceptance | `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8` |
| Canonical Match evaluator | `c101657187348dcafa91afbf0b889bc94f0a0bff` |
| Common Authority | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| IP-13A | `2877f5804710abf7c8eba87a9d59925ad5cc405d` |
| IP-13E | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| Runtime Readiness adapter, contrast only | `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5` |

No repository enumeration, unrelated discovery, or additional source read occurred.

## 3. Model decision

### 3.1 Selected: Model A

A derived Match lifecycle that has reached a terminal classification remains terminal after a later dependency invalidation changes the current classification to `UNKNOWN`.

The record-level terminal marker represents whether this derived lifecycle has ever reached a terminal Match classification. It is monotonic within one `lifecycle_identity`. It is not recomputed solely from the post-invalidation classification.

This model preserves all three established facts:

- the evaluator truthfully reports the invalidated current classification as `UNKNOWN`;
- the payload retains the exact invalidated dependency identity and relation;
- IP-13A never sees `bindings.terminal=true` followed by `false` under the same lifecycle.

### 3.2 Model B rejected

Generic overlay-only invalidation keeps a terminal stored record unchanged, but the current generic overlay identifies only the logical record. It does not identify the evaluator dependency. Treating that logical-record identity as the proposal, participant, or selected-slot dependency identity would be false provenance.

Model B therefore cannot preserve the accepted dependency-scoped invalidation result losslessly in the persisted terminal projection.

### 3.3 Model C not required

Model A can carry the necessary pre-invalidation classification as bounded derived context without changing source authority, introducing a global revision, or changing the generic envelope.

## 4. Corrected terminality payload

The rejected R9 top-level eleven-key derived payload remains unchanged. Only the nested `terminality` object changes.

`terminality` now contains exactly five keys:

1. `source_proposal_terminal`
2. `derived_terminal`
3. `classification_before_invalidation`
4. `lifecycle_reset`
5. `proposal_reopened`

Rules:

- `source_proposal_terminal` equals `proposal_dependency.terminal`;
- `classification_before_invalidation` is `null` when `invalidation.invalidated=false`;
- when `invalidation.invalidated=true`, `classification_before_invalidation` is required and is exactly the bounded evaluator classification captured immediately before the accepted evaluator invalidation transition;
- its allowed non-null values are exactly `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED | UNKNOWN`;
- for a non-invalidated result, `derived_terminal=true` exactly when current `classification` is `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- for an invalidated result, `derived_terminal=true` exactly when `classification_before_invalidation` is one of those four terminal values;
- once `derived_terminal=true` for a lifecycle, every later materialized record under the same `lifecycle_identity` must retain `derived_terminal=true` and `bindings.terminal=true`;
- `bindings.terminal` always equals `terminality.derived_terminal`;
- `lifecycle_reset=false` and `proposal_reopened=false` always.

The valid combination:

```text
classification                  = UNKNOWN
invalidation.invalidated        = true
classification_before_invalidation = MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED
derived_terminal                = true
bindings.terminal               = true
proposal_reopened               = false
lifecycle_reset                 = false
```

means that the terminal result is no longer usable because a dependency was invalidated. It does not mean that the proposal or derived lifecycle reopened.

## 5. Deterministic pre-invalidation knowledge and readback

A future adapter must retain two bound states from one deterministic invalidation flow:

1. the structurally gated evaluator result before invalidation, obtained either by fresh evaluation or by exact validation of the previously materialized result being invalidated;
2. the result returned after applying the evaluator's accepted `invalidate()` transition, when a valid invalidation request exists.

The builder copies the first output's classification into `classification_before_invalidation` and the second output's classification, reasons, invalidation identity, and relation into their ordinary payload fields. It must not reconstruct the prior classification from timestamps, storage history, arrival order, or a global revision.

An already-invalidated evaluator array presented without that exactly bound pre-invalidation result is not sufficient to construct an invalidated record and is rejected before materialization. A non-terminal pre-invalidation result under a lifecycle that already has a terminal record is likewise a prohibited reopen and cannot be used to create an invalidated record. These rules prevent an adapter from guessing sticky terminality or laundering a reopen through invalidation.

Exact readback validation requires:

- non-invalidated payload: `classification_before_invalidation=null` and terminality agrees with current classification;
- invalidated payload: current `classification=UNKNOWN`, reasons exactly `[DEPENDENCY_INVALIDATED]`, a valid non-null `classification_before_invalidation`, and terminality agrees with that prior classification;
- `bindings.terminal` equals `derived_terminal`;
- invalidation relation and identity satisfy Section 7;
- lifecycle reset and proposal reopening remain false.

No additional top-level payload key is required.

## 6. Exact record-eligibility boundary

### 6.1 `PRE_MATERIALIZATION_REJECTION_ONLY`

The synthetic adapter must reject before constructing a derived record when any of these conditions holds:

- proposal input is not an object with a non-empty string `proposal_identity`;
- `participants` is not a list of exactly two unique non-empty strings;
- `protected_use_scope` is not a non-empty string;
- proposal `lifecycle_state` is outside `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- proposal, participation, or slot `required_bindings` / `source_evidence` / `source_revision` is malformed under the exact Common Authority binding, evidence, and revision shapes;
- a source revision field has a wrong type, missing field, negative value, empty owner/scope/context/lineage, or inconsistent binding to its evidence authority/context;
- participation or slot evidence is not a list of objects;
- a participation item lacks a non-empty string `participant_identity`;
- a participation `state` is outside `NOT_ENROLLED | ENROLLED | PAUSED | WITHDRAWN`;
- a slot lacks a non-empty string `slot_identity`, `proposal_identity`, or `participant_identity`;
- a slot `decision` is outside `PENDING | ACCEPTED | DECLINED | WITHDRAWN`;
- an evaluator-selected dependency is structurally incomplete;
- the selected dependency identities violate Section 8;
- an invalidated result lacks the paired pre-invalidation classification from the same evaluation flow;
- evaluator classification, reason, or invalidation literal falls outside the bounded contract.

These failures produce no Match derived record and no persisted Match reason payload. In particular, the raw evaluator reasons `EXACTLY_TWO_PARTICIPANTS_REQUIRED`, `INVALID_PROPOSAL_SHAPE`, `INVALID_SLOT_EVIDENCE`, and `INVALID_SLOT_DECISION` describe inputs excluded by this gate.

The gate checks structure and bounded vocabularies. It does not convert semantically valid negative or uncertain evidence into an input error.

### 6.2 `PERSISTABLE_DOMAIN_UNKNOWN_DERIVATION`

After the structural gate passes, the following evaluator outcomes are valid domain `UNKNOWN` derivations and remain losslessly persistable:

- proposal evidence is structurally valid but currentness, freshness, source condition, source authority, or exact required-binding satisfaction is not established;
- the bounded unresolved-proposal precondition is not established;
- the structurally valid participation evidence set contains an extra participant or duplicate participant entry;
- required participation evidence is missing;
- structurally valid participation evidence is not usable;
- a valid participation state prevents acceptance;
- a structurally valid slot references another proposal or a participant outside the proposal pair;
- a required decision slot is missing;
- duplicate slot evidence has distinct slot identities, incomparable revisions, or conflicting semantics at equal source-local revision;
- a selected slot is structurally valid but currentness, freshness, source condition, or exact binding is not established;
- two valid selected slots contain conflicting terminal decisions;
- a uniquely identified persisted dependency is invalidated under Section 7.

Missing evidence is allowed as a semantic fact only when the containing input list and all supplied items are structurally valid. Structural absence inside a supplied evidence object is rejected.

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`

## 7. Corrected persisted reason vocabulary

### 7.1 `PRE_MATERIALIZATION_REJECTION_ONLY`

These rejected-R9 categories are removed from the persisted payload vocabulary:

1. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
2. `INVALID_PROPOSAL_SHAPE`
3. `INVALID_SLOT_EVIDENCE`
4. `INVALID_SLOT_DECISION`

They may remain evaluator diagnostics before the adapter's structural gate is implemented, but no eligible Match record may persist them.

### 7.2 `PERSISTED_MATCH_REASON_CATEGORY`

The exact persisted vocabulary, in canonical order, is:

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

Reasons are unique and emitted in this fixed order.

Exact suffix reduction:

- remove participant identity suffixes from `MISSING_PARTICIPATION:*`, `PARTICIPATION_NOT_USABLE:*`, `PARTICIPATION_PREVENTS_ACCEPTANCE:*`, and `MISSING_DECISION_SLOT:*`;
- remove the participant identity and source-condition suffixes from `DECISION_SLOT_NOT_CURRENT_FRESH_BOUND:*:*`;
- remove participant suffixes from `CONFLICTING_SLOT_IDENTITY:*`, `INCOMPARABLE_DUPLICATE_SLOT:*`, and `CONFLICTING_EQUAL_REVISION_SLOT:*`;
- all other retained reasons map by exact whole literal;
- an unmapped reason rejects record construction.

For an invalidated result, the persisted reason list is exactly `[DEPENDENCY_INVALIDATED]`.

## 8. Dependency identity uniqueness and collision rules

The persisted invalidation discriminator remains the single opaque `dependency_identity` string. A typed discriminator is unnecessary only because record eligibility now requires one collision-free identity namespace.

For every materializable payload:

- the proposal dependency identity is a non-empty string;
- the two proposal participant identities are unique non-empty strings;
- at most one selected participation dependency exists per participant identity;
- at most one selected decision-slot dependency exists per participant identity;
- every selected slot identity is a non-empty string;
- selected slot identities are unique across the two participants;
- the proposal identity, both participant identities, and every selected slot identity are pairwise distinct;
- every invalidation `dependency_identity` matches exactly one identity present in the persisted proposal, participation, or selected decision-slot dependency set.

Raw duplicate slot candidates may share the same slot identity for source-local duplicate resolution. Only the selected winner enters the dependency identity set. When duplicate resolution returns no winner, no raw candidate identity is fabricated as a persisted dependency.

A selected dependency collision is a pre-materialization record-eligibility rejection. It is not converted into `UNKNOWN`, because the evaluator invalidation API has no dependency type with which to disambiguate the collision.

## 9. Corrected invalidation contract

The top-level `invalidation` object retains exactly:

- `invalidated`
- `relation`
- `dependency_identity`
- `lifecycle_reset`
- `proposal_reopened`

For a non-invalidated evaluator result:

- `invalidated=false`;
- `relation=null`;
- `dependency_identity=null`;
- `lifecycle_reset=false`;
- `proposal_reopened=false`.

For an invalidated evaluator result:

- `invalidated=true`;
- `relation` is exactly `CORRECTION | REVOCATION | SUPERSESSION`;
- `dependency_identity` resolves uniquely under Section 8;
- current `classification=UNKNOWN`;
- reasons are exactly `[DEPENDENCY_INVALIDATED]`;
- `classification_before_invalidation` records the prior bounded classification;
- sticky terminality follows Section 4;
- lifecycle reset and proposal reopening remain false.

Payload invalidation remains permitted for both terminal and non-terminal derived records. Generic IP-13A invalidation overlay remains a separate record-level observation. It may mark a projection unusable by logical-record identity, but it must not overwrite or masquerade as the Match dependency identity. Either invalidation mode makes the affected projection unusable; only the Match payload proves dependency-scoped provenance.

## 10. Preserved R9 contract

The following rejected-R9 decisions are preserved unchanged:

- Section 1 additive family direction, record family, non-authority boundaries, and no implementation authority;
- Section 3 generic logical-record envelope fields, derived correlation revision value `0`, and projection metadata semantics;
- Section 4 exact eleven-key top-level payload and its fixed payload/fact literals;
- Section 5 classification, proposal lifecycle, participation-state, decision-slot, source-condition, and invalidation-relation vocabularies;
- Section 7 proposal, participation, and decision-slot dependency field shapes and canonical ordering, subject to the eligibility and collision narrowing in Sections 6 and 8 here;
- Section 10 independent currentness/freshness aggregation and dependency completeness rules;
- Section 11 deterministic source-order-independent SHA-256 identity/correlation rules;
- Section 12 privacy-minimal projection exclusions and internal-only participant references;
- Section 15 IP-13F non-participation;
- Section 17 retained non-authorities.

The following are superseded:

- rejected-R9 Section 8 rule deriving terminality only from current classification;
- rejected-R9 Section 9 terminal invalidation rule insofar as it would force `derived_terminal=false` after classification becomes `UNKNOWN`.

The following are narrowed:

- rejected-R9 Section 6 reason vocabulary is reduced from nineteen to fifteen persistable categories;
- rejected-R9 Section 7 dependency rules now require collision-free cross-type invalidation identities;
- rejected-R9 Sections 4 and 8 gain the exact nested `classification_before_invalidation` field inside `terminality`;
- rejected-R9 Section 9 now separates Match dependency invalidation provenance from generic record-overlay invalidation;
- rejected-R9 Sections 13 and 14 are rechecked below rather than inherited without analysis.

All other R9 identity, privacy, source-local revision, currentness/freshness, IP-13E, and non-authority semantics remain unchanged unless explicitly corrected above.

## 11. IP-13A compatibility

`IP13A_ENVELOPE_COMPATIBLE_AFTER_R9_R1_CORRECTION`

For a terminal invalidation, the new record has the same `lifecycle_identity` and retains `bindings.terminal=true`. IP-13A therefore does not see a terminal-to-nonterminal transition and does not trigger:

`TERMINAL_IDENTITY_REOPEN_REJECTED`

The invalidated result receives its own deterministic logical record, intent, lineage, and projection identities from the corrected payload. These identities remain correlation facts, not global revisions or ordering authority.

Compatibility still requires a future authorized IP-13A implementation to add exact family-specific Match payload validation and retention. That validator must enforce Sections 4–9 and must keep generic overlay invalidation distinct from Match dependency invalidation. No generic envelope field, terminal guard, Common Authority shape, or existing RR03 validator semantics needs to be weakened.

## 12. IP-13E sufficiency

`IP13E_EXISTING_OPERATIONS_STILL_SUFFICIENT_AFTER_CORRECTION`

After an authorized persistence implementation accepts the corrected family:

- `submitAuthoritativeMutation()` can store/correlate the derived record while preserving `authoritative_outcome=UNKNOWN`;
- `retrieveCurrentProjection()` can return exact binding-checked privacy-minimal readback;
- `observeInvalidation()` remains available for generic logical-record invalidation without claiming domain dependency provenance;
- dependency-scoped invalidation is represented by the corrected Match payload submitted through the existing operation set;
- reconciliation and protected revalidation remain available under existing non-authority semantics.

No evaluator-orchestration method or IP-13E contract repair is required. Exact orchestration and degraded materialization behavior remain decisions for the document-only R10 mapping review.

## 13. IP-13F disposition

`IP_13F_UNCHANGED_NON_PARTICIPATING`

The correction creates no sixth family, Match route, HTTP contract, transport mapping, Connection, Consent, or Conversation authority.

## 14. R10 gate and exact next task

The R9-R1 contract fixes:

- terminality/invalidation without reopen;
- the exact materializable-input boundary;
- the persisted reason subset;
- unambiguous dependency invalidation identity;
- IP-13A compatibility;
- IP-13E sufficiency.

Subject to fresh independent acceptance of this candidate, the next bounded task returns to:

`IP-13I-R10 CANONICAL MATCH DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

Its purpose and one-result write boundary remain those stated by rejected-R9 Section 16, amended to use the accepted R9-R1 chain and corrected contract. R10 must define synthetic/dev-test input gating, evaluator/pre-invalidation capture, evaluator-to-record construction, submit/retrieve ordering, exact readback, and degraded materialization dispositions. It must not author implementation or transport behavior.

R10 is not authored or started by this candidate.

## 15. Retained non-authorities and execution boundary

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- invalidation does not reopen or reset a Match lifecycle;
- Match creates no Connection, Consent, Conversation, relationship, Home, Notification, or launch authority;
- `UNKNOWN != ABSENT` and `DEFERRED != MISSING`;
- no global revision, LWW, arrival-order, timestamp, or storage-order authority;
- no single authoritative Compatibility score;
- no authentication/session/token authority;
- no production persistence/deployment or real/private-data authority.

No Composer, PHPUnit, Artisan, `route:list`, migration, generator, server, HTTP/client command, database runtime probe, provider/network work, production action, real/private-data operation, legal research, or Safety Operation ran.

No code, persistence/application source, route, controller, test, R9 artifact, or accepted artifact changed. The rejected R9 candidate was not merged or transplanted. R10 and implementation were not begun.

Fresh independent ACCEPT/REJECT review is required.

Final classification:

`IP-13I-R9-R1 REVIEW COMPLETE — CANONICAL MATCH TERMINALITY/INVALIDATION CONTRACT REPAIRED WITHOUT REOPEN — MATERIALIZABLE INPUT BOUNDARY AND PERSISTED UNKNOWN REASONS FIXED — DEPENDENCY INVALIDATION IDENTITY UNAMBIGUOUS — IP-13A/IP-13E/IP-13F DISPOSITIONS RECONFIRMED — R10 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
