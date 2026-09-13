# EliteSync v10｜Conversation Data-Rights Decision-Closure Owner Acceptance｜v0.1

Status: `OWNER ACCEPTED — COMMON PRODUCT SEMANTICS CLOSED — REGION-SPECIFIC LEGAL AUTHORITY STILL REQUIRED — NO IMPLEMENTATION AUTHORIZED`

Repository: `zcx369658780/EliteSync-v10`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`adc6f67ab706fade4413ccf104b3a27e8512b3db`

Accepted result blob:

`1e2ac839f5627cef25fd8a5a1fd73331522fa679`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_CANDIDATE_V0_1.md`

## 1. Owner decision

The Owner accepts D-01 through D-10 using the independent-review recommendations recorded after review of the candidate.

This acceptance closes only the common product-semantic layer. It does not establish applicable law, production legal readiness, backend authority, implementation authority, launch regions, legal entity/role, age model, hosting/transfer posture, lawful bases, exact retention periods, statutory timelines, or regional exceptions.

## 2. Accepted decisions

### D-01 — Semantic separation

Accepted.

`Hide from my view`, `Mute`, `Pause Conversation`, `Close Conversation`, `Block`, `Report`, `Export`, deletion request, service erasure, and revoke remain distinct product actions and authorities.

No single ambiguous `Delete chat` authority is accepted.

### D-02 — Future authority effect

Accepted.

When authoritative mutual messaging consent is revoked, or authoritative `CN_ACTIVE` is absent, new live send authority is denied. Existing route identity, cached rows, unread counts, transport connectivity, or legacy chat behavior cannot restore live messaging consent.

### D-03 — Historical-access posture

Accepted using the conservative posture.

Read-only Conversation history is NOT enabled by default after revoke, pause, or close. It remains unavailable unless a separate, explicit history-access authority is later established for the applicable subject, audience, purpose, retention state, and jurisdiction.

This is a fail-closed product default, not a claim that historical content is absent or erased.

### D-04 — Peer visibility posture

Accepted using the conservative posture.

A deletion request does not alter the other participant's view by default. Peer-visible content changes only when an authoritative deletion outcome explicitly covers the peer-visible copy and applicable rights/constraints permit that effect.

Where peer-visible content is authoritatively removed, the product should use a neutral removal/tombstone state rather than imply that the content or prior interaction never existed.

### D-05 — Export product scope

Accepted.

EliteSync adopts a scoped export model. No voluntary comprehensive export beyond applicable minimum legal/access/portability requirements is promised at this stage.

Information classes, inclusion, redaction, peer-content treatment, metadata, derived information, and Safety/operational restrictions remain subject to later jurisdiction-specific authority.

### D-06 — Account-exit posture

Accepted.

Account closure is distinct from a data deletion request. Limited rights-request or separately authorized history handling may remain available through a restricted process if later legal/backend authority establishes it.

### D-07 — Retention governance

Accepted.

Before implementation, every retained data class must have at least:

- named purpose;
- accountable owner;
- retention start/end trigger;
- review trigger;
- deletion, de-identification, or other accepted terminal outcome.

No universal Conversation retention duration is established by this acceptance.

### D-08 — Private-content purpose boundary

Accepted.

Private Conversation remains `CONVERSATION_SHARED_PRIVATE` and is unavailable by default for unrelated Match, ranking, Compatibility scoring, advertising, analytics enrichment, or model training.

### D-09 — Regional dispatch inputs

Accepted.

Before production legal/data-right closure, later tasks must establish the material facts required for qualified jurisdiction-specific review, including as applicable:

- launch region(s);
- establishment/targeting facts;
- accountable legal entity and role map;
- age/eligibility model;
- purpose inventory and lawful-basis questions;
- hosting/subprocessor/cross-border transfer facts.

Until established, these remain `UNKNOWN` / `REGION-SPECIFIC AUTHORITY REQUIRED` as recorded in the accepted candidate.

### D-10 — No fake capabilities

Accepted.

Privacy Control Center and Conversation surfaces must not represent export, delete, revoke, historical-access, retention, or related rights as available/completed unless both the necessary backend authority and applicable legal/data-right authority are established for that exact capability.

## 3. Preserved legal boundary

The candidate's authoritative-source analysis remains bounded by jurisdiction and applicability. Acceptance of product semantics does not convert any cited GDPR, UK ICO, PRC PIPL, California CCPA/CPRA, or other source into a finding that the regime applies to EliteSync.

Future UK-specific review must fresh-check then-current ICO guidance and relevant legislation rather than treating the 2026-09-13 guidance snapshot as permanent production authority.

## 4. Preserved runtime boundary

Track 1 B01-D remains unchanged:

`CV_ACTIVE` requires both:

1. authoritative `CN_ACTIVE`; and
2. separate authoritative mutual messaging consent.

This acceptance creates no backend source, consent ledger, history authority, retention engine, export service, deletion service, or UI control.

## 5. Track status

Track 1: accepted.

Track 2 common product-semantic decision layer: accepted.

Region-specific legal/data-right closure: still separate and deferred until material launch facts exist.

Track 3 Flutter tooling/package-graph evidence restoration may now be separately dispatched under the Owner-approved `Track 1 -> Track 2 -> Track 3` sequence.

## 6. Classification

`CONVERSATION DATA-RIGHTS COMMON PRODUCT SEMANTICS OWNER-ACCEPTED — D-01 THROUGH D-10 CLOSED — REGION-SPECIFIC LEGAL AUTHORITY PRESERVED — NO IMPLEMENTATION AUTHORIZED — TRACK 3 MAY BE DISPATCHED`
