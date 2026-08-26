# ADR-006: Shared Information Rights and Lifecycle Conflict Rules

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

Decision owner: Owner, after GPT L3 product-policy review

Depends on: ADR-001 through ADR-005; accepted LC-02 closeout and V0.1 layered advisory artifact; Phase 34 Owner-accepted Safety authority

## Context

U-02 and U-03 remain `BLOCKING`. Accepted authority distinguishes authorship, user declaration, private interaction, purpose-specific consent, derived outputs, shared human meaning, and Safety-controlled information, but it does not yet define a complete product-policy rule for shared-record rights conflicts or lifecycle propagation.

This ADR records a proposed option for Owner decision. It does not select technical architecture or silently resolve U-02/U-03.

## Evidence discipline

### Observed / Accepted Authority

- User declaration ≠ objective truth; AI interpretation ≠ verified fact.
- Match ≠ Connection ≠ Conversation ≠ Relationship.
- Visibility, custody, and technical availability do not create unrelated-purpose authority.
- Consent is purpose-specific and revocable for future optional use; revocation cannot promise retroactive erasure of another person's prior receipt or independent authorship.
- Private Conversation is not default analytics/model-training input.
- Safety evidence cannot enter Compatibility, romantic Ranking, desirability, public reputation, or relationship-worth.
- Block ≠ Report; Report ≠ Verified misconduct; Allegation ≠ Finding; Immediate protection ≠ Guilt/punishment.
- Case-processing state must never become person truth; later reliable factual judgment requires separate evidence and/or reviewed finding.
- LC-02 is accepted advisory research, not formal legal opinion. It supplies no exact retention period or complete multi-subject conflict rule.

### Product Inference

Shared-information policy requires separate decisions about who authored an item, who can see it, whose information interests are implicated, why the product holds it, and who can request or decide a lifecycle action. A single `owner` field or all-or-nothing action would collapse these meanings.

### Proposed Product Decision

Adopt the recommended option below after Owner review.

### Still Unknown / Requires Later Review

Contested disclosure, exact retention, legal preservation, backup treatment, anonymization standard, response timing, appeal/notice, and Safety-controlled lifecycle remain dependent on later fact/formal review. U-04 remains separate and blocking.

## Proposed decision

### 1. Five-dimensional authority model

Every material shared-record policy decision must distinguish:

1. authorship;
2. visibility;
3. subject-of-information interest;
4. product custody for a named purpose; and
5. lifecycle authority for the requested action.

No dimension automatically grants the others. Avoid a single product concept of `record owner`.

### 2. Participant-scoped and record-scoped actions

The product-policy vocabulary distinguishes participant-local view/suppression, redaction, withdrawal from future optional use, provenance-preserving correction, supersession, restriction, tombstoning, de-identification/anonymization, deletion, export/copy, expiry, and narrow retention exception.

An action must state its purpose and scope. It must not imply retroactive erasure from another participant's prior receipt, memory, device, or independently authored information.

### 3. Disputed shared information

- Correct an established product error.
- Where truth is disputed, preserve provenance and participant-specific positions rather than letting the last edit win or declaring either participant truthful.
- Mark dependent ordinary-domain outputs stale, invalid, or withdrawn until review/recomputation is authorized.
- Never use a block, report, allegation, case-processing state, or AI output as the factual judgment.

### 4. Deletion and retention conflict

On a deletion request, first stop the requester's future optional use. Then apply the narrowest appropriate participant-local deletion, redaction, de-identification, restriction, or record deletion without rewriting another person's independent authorship or promising recall of prior receipt.

Any retained exception must have a named accepted purpose, authority, minimum scope, restricted access, review/expiry, termination condition, and prohibition on ordinary-domain reuse. Speculative future value is not a retention purpose.

### 5. Export and copy

Default to a bounded, understandable copy of information attributable to or appropriately available to the requester. Redact, restrict, or route to later review when disclosure would expose another person's private information or unresolved interests. A record container does not make every included item exportable.

### 6. Lifecycle action semantics

Use distinct meanings for `correct`, `supersede`, `withdraw from future optional use`, `revoke consent`, `pause`, `reset`, `close`, `delete`, `de-identify/anonymize`, `retain under exception`, `expire`, and `export/copy`.

Each action must specify what changes, what remains, who may initiate it, the status of dependent outputs, effects on another person's independently authored information, and whether Safety-controlled information is excluded.

### 7. Safety routing

Ordinary-domain policy may consume only a minimum-necessary Safety control directive. Safety evidence and its lifecycle remain restricted and route to U-04/formal review. This ADR does not create a Safety retention exception or Safety Operations policy.

### 8. MVP policy gate

Before implementation can be separately authorized for affected scope, Owner-accepted policy must cover participant-local visibility/future-use withdrawal, provenance-preserving correction/supersession, dependent-output invalidation, pause/reset/closure/expiry, bounded export/deletion requests, conflict stop-and-review, purpose-specific retention, and Safety exclusion/routing.

Advanced mutual-history export, configurable tombstones, negotiated shared states, and automated conflict suggestions may be deferred. Ad hoc conflict handling, private-message mining, general training, public reputation, Safety leakage, truth adjudication, impossible erasure promises, and indefinite retention remain prohibited.

## Recommended option

Adopt the five-dimensional, conflict-aware policy above.

Reasons:

- it preserves accepted provenance, consent, private-interaction, and Safety boundaries;
- it separates future platform use from historical receipt and independent authorship;
- it provides deterministic product semantics without pretending missing legal/factual answers are known;
- it gives later technical work a product contract without choosing schema, API, service, or storage behavior.

### Rejection or exit conditions

Revise or stop this option if GPT L3 identifies a contradiction with accepted ADR-001–005, if Owner rejects participant-local decomposition, if qualified later review requires a different contested-record boundary, or if MVP explicitly excludes shared Conversation/Relationship information. Do not implement the option before those conditions and the Owner Decision Packet are resolved.

## Viable alternative

Exclude shared Conversation and mutually authored Relationship information from MVP beyond basic delivery and closure, and defer export, redaction, shared correction, and lifecycle-conflict features.

### When to prefer the alternative

Prefer it if Owner wants the smallest safe MVP and accepts that the product will not promise the affected shared-right controls until later policy review.

### Alternative rejection conditions

Reject it if MVP still presents shared state, retains shared information beyond delivery, offers export/deletion controls, or creates derived outputs that require correction/revocation propagation. In those cases, deferral would hide rather than remove the policy need.

## Alternatives rejected

### A. Single record owner

Rejected because authorship, visibility, subject interest, custody, and lifecycle authority are not interchangeable.

### B. Last edit wins

Rejected because it destroys provenance and converts product sequence into truth authority.

### C. Delete all on either request

Rejected as a universal promise because another person's independent authorship/receipt and narrow reviewed exceptions may remain relevant.

### D. Retain all when either participant objects

Rejected because objection alone does not establish a necessary or authorized retention purpose.

### E. Resolve conflicts through Safety case state or AI

Rejected because neither is person truth or autonomous adjudication authority.

## Consequences if accepted

### Positive

- Shared controls become understandable and purpose-specific.
- Corrections preserve provenance and prevent stale derived effects.
- Deletion/export conflicts stop for review instead of producing overbroad promises.
- Safety evidence remains separated from ordinary-domain lifecycle decisions.
- Later architecture receives a technology-neutral semantic contract.

### Costs and constraints

- Some requests cannot complete automatically.
- Participant-local and shared effects require distinct user explanations.
- Exact operational timing, retention, backup, appeal, and disputed disclosure remain unavailable until later review.
- MVP scope may need reduction if the minimum policy gate is not accepted.

## Unknowns retained

- U-02: `BLOCKING — NOT RESOLVED BY THIS PROPOSAL`.
- U-03: `BLOCKING — NOT RESOLVED BY THIS PROPOSAL`.
- U-04 and all other existing BLOCKING UNKNOWNs remain unchanged.
- No exact legal/operational retention period is selected.
- No final disputed-record decision authority, reviewer role, evidence threshold, response time, appeal, notice, backup rule, or anonymization standard is selected.

## Owner decision dependency

Owner must decide the numbered packet in `docs/architecture/ELITESYNC_V10_U02_U03_SHARED_RIGHTS_AND_LIFECYCLE_WORKSHOP_V0_1.md`. GPT L3 reviews consistency, options, rejection conditions, retained unknowns, and MVP boundary first.

Until explicit Owner acceptance:

- this ADR remains `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`;
- U-02/U-03 remain blocking;
- no database, schema, API, backend, Flutter, service, event, storage, infrastructure, retention timer, deletion workflow, consent mechanism, Safety Operations, or code is authorized;
- LC-03, LC-04, and Phase 36 remain unauthorized.
