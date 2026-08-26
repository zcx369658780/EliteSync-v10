# EliteSync-v10 U-02 / U-03 Shared Rights and Lifecycle Product Policy Workshop V0.1

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

## 0. Workshop boundary and authority

This document is an Owner-decision-ready product-policy workshop for U-02 and U-03 only. It proposes technology-neutral semantics; it does not resolve either UNKNOWN, create operational policy, perform legal research, or authorize implementation.

### Observed / Accepted Authority

- ADR-001–005 are accepted. They preserve agency, purpose limitation, provenance, correction, specific consent, private-interaction protection, and separation of declarations, interpretations, hypotheses, Match, Connection, Conversation, Relationship, feedback, and Safety.
- LC-02 is `COMPLETE FOR CURRENT PRE-ALPHA PURPOSE`. Its accepted Layer B remains `AI-ASSISTED LEGAL RESEARCH — NOT FORMAL LEGAL OPINION` and supplies constraints and uncertainty, not formal legal advice.
- U-02 and U-03 remain `BLOCKING`. Drafting this workshop does not change their disposition.
- Phase 34 Safety authority preserves all 28 accepted invariants, including Block ≠ Report, Report ≠ Verified misconduct, Allegation ≠ Finding, Immediate protection ≠ Guilt or punishment, Safety evidence ≠ Compatibility evidence, Control directive ≠ Safety evidence, Unknown ≠ False/Safe, and case-processing state ≠ person truth.

### Product Inference

A single `owner` label cannot express shared-information policy. Authorship, visibility, subject-of-information interest, product custody, and lifecycle authority can belong to different actors and can change independently.

### Proposed Product Decision

Adopt the policy vocabulary and recommended options in this workshop only after explicit Owner review. Until then, every recommendation is proposed, not accepted.

### Still Unknown / Requires Later Review

Qualified legal/factual review remains necessary before operational promises for disputed shared records, another person's private information, exact retention, legal preservation, backup treatment, rights-response timing, or Safety-controlled material. U-04 remains separate and blocking.

## 1. Five independent shared-information dimensions

| Dimension | Product-policy meaning | Must not be collapsed into |
| --- | --- | --- |
| **Authorship** | Who deliberately created or submitted an expression, declaration, correction, or feedback item | Objective truth; authority over every person mentioned |
| **Visibility** | Who may presently view a representation for a named purpose and context | Reuse consent; export entitlement; lifecycle authority |
| **Subject-of-information interest** | Whose identity, privacy, rights, or legitimate interests may be affected by the content | Authorship; product custody; a single record owner |
| **Product custody** | The product's bounded responsibility to hold or mediate a record for an accepted purpose | Human meaning authority; permanent retention authority |
| **Lifecycle authority** | Who may request or decide correction, restriction, withdrawal, export, deletion, retention, or expiry for a particular purpose and interest | Sole authorship; current visibility; technical possession |

### Observed / Accepted Authority

User declaration ≠ objective truth. Visibility and technical availability do not authorize unrelated reuse. One participant cannot authorize another participant's private information. Another person's independently authored information is not erased by a first participant's preference alone.

### Product Inference

One record may require several simultaneous outcomes: an author's expression can remain attributable, another person's private details can be redacted, future platform use can stop, and a narrowly justified restricted record can remain unavailable to ordinary domains.

### Proposed Product Decision

Every shared-record decision should state all five dimensions explicitly. Product language should use `participant-local view`, `redaction`, `future-use withdrawal`, `tombstone`, `de-identification`, `record restriction`, or `retention exception` rather than the ambiguous verb `own`.

### Still Unknown / Requires Later Review

Which participant interests prevail in a specific contested record, and when disclosure or retention is legally required or prohibited, remain fact-dependent and require later review.

## 2. U-02 proposed shared-rights model

### 2.1 Authored message containing information about another person

- **Observed / Accepted Authority:** the author controls their expression as authorship; the person described may hold a distinct privacy/PI interest. Neither interest establishes objective truth.
- **Product Inference:** an all-or-nothing record action is often too coarse.
- **Proposed Product Decision:** preserve authorship provenance; allow the affected person to request correction, restriction, redaction, or review of information about them; do not silently rewrite the author's expression as agreed fact.
- **Still Unknown / Requires Later Review:** whether a disputed item must be disclosed, redacted, restricted, retained, or deleted in a particular case.

### 2.2 Mutually authored Relationship state or shared interaction record

- **Observed / Accepted Authority:** Connection and Relationship meaning require reciprocal/human meaning; activity cannot infer Relationship state.
- **Product Inference:** a shared state must retain each participant's contribution and disagreement rather than fabricate one joint truth.
- **Proposed Product Decision:** represent agreement, participant-specific declaration, disagreement, supersession, and closure as distinct meanings. A participant may withdraw their own declaration or future platform use; they may not rewrite the other's declaration.
- **Still Unknown / Requires Later Review:** exact vocabulary and conflict treatment when participants give incompatible declarations.

### 2.3 Access after closure, block, withdrawal, or state change

- **Observed / Accepted Authority:** closure, block, account withdrawal, and Relationship-state change are different. Block is a protective/access-control state, not guilt.
- **Product Inference:** future access and historical receipt are separable.
- **Proposed Product Decision:** closure stops new ordinary interaction; participant-local historical access may remain only under the applicable shared-record policy. A Safety control directive may restrict access without disclosing Safety evidence. Account withdrawal stops new product use but does not promise erasure of another participant's prior receipt.
- **Still Unknown / Requires Later Review:** access during a dispute, legal preservation, or Safety restriction; U-04 owns Safety-policy resolution.

### 2.4 Export or copy exposing another person's private information

- **Observed / Accepted Authority:** LC-02 identifies access/copy interests and another-person harm/privacy limits but no complete multi-subject conflict rule.
- **Product Inference:** full-record export is not the only product outcome.
- **Proposed Product Decision:** default to the requester's attributable content and purpose-relevant information; use redaction, participant-local extracts, or restriction when another person's private information would be exposed. Never label a redacted export as a complete mutual history.
- **Still Unknown / Requires Later Review:** contested disclosure scope and any mandatory exception require later fact/formal review.

### 2.5 Disputed correction

- **Observed / Accepted Authority:** correction must not convert one participant's declaration into objective truth or erase another's authored expression.
- **Product Inference:** correction of a shared record may require provenance-preserving supersession rather than overwrite.
- **Proposed Product Decision:** correct an objective product error where established; otherwise preserve the original provenance, append the requester's contested/corrected position, mark dependent ordinary-domain outputs stale, and route unresolved factual conflict to review.
- **Still Unknown / Requires Later Review:** the evidentiary standard for reliable factual judgment. A case-processing state itself can never supply that judgment.

### 2.6 Deletion request versus legitimate retained interest

- **Observed / Accepted Authority:** exact shared-record conflict rules and retention periods remain unknown; blanket deletion and blanket retention are both rejected.
- **Product Inference:** participant-local suppression, future-use withdrawal, redaction, de-identification, restriction, and tombstoning can separate effects.
- **Proposed Product Decision:** cease the requester's future optional use first; delete or de-identify eligible participant-local/derived material; preserve another person's independent authorship or prior receipt; retain only a narrow, named, access-restricted exception with review/expiry.
- **Still Unknown / Requires Later Review:** whether a specific retained interest is legitimate, necessary, and authorized.

### 2.7 Actions the product must never promise

1. Retroactive erasure from another person's memory, device, prior receipt, or independently authored records.
2. That one participant controls every fact or expression in a shared record.
3. That correction proves another participant lied or that disagreement establishes truth.
4. That block/report/case state proves guilt, safety, innocence, or character.
5. Immediate universal deletion despite other-person, legal, or narrowly reviewed Safety interests.
6. Indefinite retention for speculative future value.
7. Export of another person's private information merely because it shares a record container.

## 3. U-03 lifecycle action semantics

All rows are **Proposed Product Decisions**, constrained by the authority and unknowns stated below.

### Observed / Accepted Authority

Correction, revocation, pause, reset, closure, deletion, export, and retention are distinct. Derived outputs preserve provenance and purpose. Safety-controlled information never silently follows ordinary lifecycle actions.

### Product Inference

Lifecycle actions should change named purposes and representations, not pretend to undo history. Dependent outputs need explicit stale/invalid/withdrawn/review states.

| Action | What changes | What does not change | Who may initiate | Dependent-output effect | Other-person information | Safety boundary |
| --- | --- | --- | --- | --- | --- | --- |
| `correct` | Authoritative declaration or established product error; contested position may be appended | Prior provenance and another person's expression | Subject/author; authorized review for product error | Active dependents become stale and require refresh/review | Not rewritten automatically | Safety facts/findings route to U-04/review |
| `supersede` | New version becomes current for a named purpose | Historical provenance; unrelated purposes | Meaning authority or authorized policy actor | Old dependents invalid/withdrawn; recompute only if purpose remains allowed | Independent authorship remains | Safety outcome supersession is U-04-dependent |
| `withdraw from future optional use` | New optional use and new dependent outputs stop | Prior receipt; mandatory/narrow retained record; other purposes | Participant whose information/use authority applies | Optional outputs withdrawn or invalidated | Other person's independent data remains | Does not withdraw Safety evidence |
| `revoke consent` | Consent-based future processing stops for that purpose | Processing under another valid authority is not assumed or erased; history remains | Consent-giver | Consent-dependent outputs invalid/withdrawn; later handling needs authority | Cannot revoke for another person | Safety/legal authority is not invented; review required |
| `pause` | Temporarily stops new presentation/use for a named ordinary purpose | Identity, account, prior receipt, and unrelated purposes | Participant; minimum-necessary Safety directive may restrict access | No new outputs; existing time-sensitive outputs may expire | No automatic effect | Directive may restrict; evidence stays in Safety |
| `reset` | Retires selected learning/reflection state and begins from explicitly retained inputs | Account, other-person records, Safety records, historical provenance | Participant for their learning state | Hypotheses/explanations become invalid and may be recomputed only with permission | Independent authorship unaffected | Safety excluded |
| `close` | Ends a Connection/Conversation/Relationship product context for future ordinary interaction | Human history, prior receipt, block/report meaning | Either participant for participation; mutual meaning remains separate | Active interaction outputs close/expire; feedback remains purpose-classified | Other participant retains own records subject to policy | Safety restriction may coexist but is distinct |
| `delete` | Eligible information and dependent artifacts are removed or made unavailable | Another person's independent authorship/receipt; authorized exception | Subject/author/requester; final conflict outcome may require review | Dependents deleted/invalidated; no silent regeneration | Apply redaction/local deletion/conflict rule | Safety-controlled material excluded pending U-04/formal review |
| `de-identify / anonymize` | Identifiability and person linkage are removed to an accepted standard | Must not be claimed if re-identification remains reasonably available | Authorized lifecycle authority after review | Person-specific dependents become invalid | Shared expression may remain only if no person linkage/private harm | Safety utility/authority cannot be assumed |
| `retain under exception` | Record remains for one named narrow purpose under restricted access | Ordinary use, Ranking, Compatibility, future-value reuse | Authorized formal decision, not model or convenience | Ordinary outputs remain unavailable; exception reviewed/expired | Interests remain protected and minimized | Safety exception requires U-04/formal authority |
| `expire` | Time relevance or approved purpose ends; item no longer drives active outputs | Historical provenance only if separately justified | Policy clock or review decision; exact timing unknown | Active dependents expire/review; no automatic regeneration | No new authority over another's data | Safety expiry unresolved in U-04 |
| `export / copy` | Requester receives an understandable bounded copy | Does not transfer meaning authority or disclose restricted other-person/Safety material | Entitled participant/requester after verification | No ordinary-output change solely from export | Redact/restrict or review conflicts | Safety evidence excluded unless separately authorized |

### Still Unknown / Requires Later Review

Exact initiation authority, response timing, consent renewal, anonymization standard, backup effects, appeal/notice, retention period, legal preservation, contested-export scope, and all Safety-specific lifecycle rules remain unknown. No row authorizes implementation.

## 4. Lifecycle propagation matrix

Legend: `refresh` = dependent ordinary output becomes stale and must be reviewed/recomputed; `stop` = no new use for that purpose; `local` = participant-scoped effect; `review` = later fact/formal review; `U-04` = Safety governance dependency.

| Information class | Correction | Revocation | Reset | Closure | Deletion | Expiry | Export/copy | Retention exception |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Identity / Profile declaration | Correct declaration; refresh dependents | Stop consent-based use | Reset selected projections only | Visibility/use may stop | Delete eligible author data | Review time relevance | Export own declaration | Narrow review only |
| Relationship Preference | Correct; refresh Matching/Compatibility | Stop future optional use | Retire preference learning | Stop new shared use | Delete eligible preference | Expire when no longer current | Export own preference | No speculative retention |
| Personality / AI interpretation | Correct source; regenerate/dismiss interpretation | Stop optional generation/use | Retire interpretation state | No automatic truth change | Delete eligible source/derived item | Expire/version | Export with AI label/provenance | Narrow review only |
| Compatibility Signal / Hypothesis | Correct source; invalidate hypothesis | Stop purpose use | Retire hypotheses | No Relationship inference | Delete eligible derived outputs | Expire with relevance | Export bounded explanation, not other-person private data | No indefinite future-value retention |
| Match Explanation | Refresh/withdraw | Stop new explanation | Retire | Close with Match/Connection context | Delete eligible copy | Short-lived; exact period unknown | Bounded user-facing copy | Exception ordinarily unjustified; review |
| Connection state | Correct product error; preserve event provenance | Not a consent substitute | Does not recreate consent | Ends future reciprocal access | Request affects eligible local data | Closed state may remain only if justified | Bounded state history | Review; no human-meaning inference |
| Conversation content | Preserve authorship; append dispute/redact as appropriate | Stop new optional platform use | Not deleted by reset | Stop new messages/access per policy | Local/redact/de-identify/review shared conflict | Exact expiry unknown | Redacted/participant-local/review | Named narrow purpose only |
| Shared / mutually authored Relationship information | Preserve participant-specific declarations/disagreement | Stop requester's future optional use | Retire requester's learning, not joint history | Mark closed without fabricating shared truth | Local/redact/tombstone/review | Exact expiry unknown | Participant-local/redacted/review | Narrow reviewed interest only |
| Relationship Feedback | Correct author's classification/content | Stop optional learning | Retire learning effect | Remains private/purpose-bound if justified | Delete eligible author feedback | Expire by purpose | Export author's feedback only | Safety concern exits to U-04 |
| Safety-controlled information | U-04/review; no ordinary overwrite | U-04/formal authority | Excluded | Access directive may apply | U-04/formal authority | U-04 | Restricted; not ordinary export | U-04/formal authority; no blanket exception |
| Consent / purpose records | Correct product error; preserve audit provenance | Record revocation and stop purpose | Reset is not consent | Close named purpose where applicable | Retain/delete only as necessary for accountability | Review/expire | Explain requester choices | Narrow accountability purpose |
| Audit / provenance evidence | Append correction/supersession; do not rewrite history | No new optional use | Preserve only necessary trace | Close active trail | Minimize/restrict; review deletion | Expire under policy | Bounded understandable account | Narrow, access-restricted, reviewed |

### Proposed Product Decision

Adopt this matrix as the semantic review baseline, not an implementation cascade. Every future technical proposal must show that it preserves these distinctions.

### Still Unknown / Requires Later Review

Exact periods, backup semantics, operational propagation order, failure recovery, notification, appeal, and evidence thresholds remain outside this workshop.

## 5. Retention policy framework

### Observed / Accepted Authority

Retention is purpose-limited and shortest-necessary. LC-02 establishes no exact EliteSync period. Legal/Safety preservation is not a blanket exception. Private Conversation is not default analytics or training input.

### Product Inference

A defensible exception needs a named record class, purpose, authority, access restriction, review date, exit condition, and prohibition on ordinary-domain use.

### Proposed Product Decision

Permissible purpose categories for later Owner selection are limited to:

1. delivering an active user-requested product context;
2. completing a user-rights request or resolving a documented shared-right conflict;
3. preserving minimum provenance needed to explain a consequential change or restriction;
4. complying with a separately established legal preservation duty;
5. a separately authorized, bounded Safety purpose routed through U-04.

For each retained class, require: purpose start/termination, shortest-necessary review, restricted access, no unrelated reuse, review/expiry, and deletion/de-identification when the purpose ends. Prohibit indefinite retention for speculative future analytics, model improvement, convenience, possible disputes, or unspecified Safety value.

### Still Unknown / Requires Later Review

Exact periods; jurisdictional/legal duties; Safety needs; backup/technical-deletion treatment; notice; appeal; reviewer role; and evidence showing necessity.

## 6. Conflict-resolution principles

| Conflict | Proposed product treatment | Classification |
| --- | --- | --- |
| One participant requests deletion; another requests retention/access | Stop requester's future optional use; separate participant-local view; redact/de-identify where possible; preserve independent authorship/receipt; review any retained exception | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` for decomposition; `REQUIRES LATER FACT / FORMAL REVIEW` for final contested disclosure/retention |
| One participant disputes/corrects a factual field | Correct established product error; otherwise preserve provenance and disagreement, invalidate dependent outputs, do not declare either participant truthful | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; reliable factual judgment requires later evidence/review |
| One participant revokes optional processing for shared data | Stop new optional use attributable to that participant; do not treat the other person's consent as substitute; do not promise retroactive erasure | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; other lawful authority remains review-dependent |
| Closure/block restricts access while historical copies exist | Stop future ordinary interaction; distinguish closure from block; acknowledge prior receipt cannot be recalled; accept only minimum-necessary Safety directives | Ordinary closure rule `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; block/Safety details `ROUTE TO U-04 SAFETY GOVERNANCE` |
| Correction/reversal invalidates ordinary outputs | Mark dependent hypotheses/explanations stale or withdrawn; prevent Safety-derived adverse effects from persisting | Ordinary propagation `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; Safety outcome lifecycle `ROUTE TO U-04 SAFETY GOVERNANCE` |
| Shared record combines one person's PI and another's expression | Preserve authorship; use participant-local view/redaction/restriction; do not export the other's private information by container association | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; contested scope `REQUIRES LATER FACT / FORMAL REVIEW` |

## 7. MVP product-policy boundary

### Minimum before MVP implementation can be authorized

1. Distinct authorship, visibility, subject interest, custody, and lifecycle authority.
2. Participant-local visibility and future-use withdrawal semantics.
3. Correction/supersession with provenance and dependent-output invalidation.
4. Pause, reset, closure, expiry, export-request, and deletion-request meanings that do not promise impossible erasure.
5. Shared-record conflict intake that can stop automated action and route unresolved cases to review.
6. Purpose-specific retention framework with no indefinite default.
7. Explicit exclusion/routing of Safety-controlled information to U-04.

### May be deferred

- Full mutual-history export; advanced redaction options; configurable tombstones; participant-negotiated shared state; portability beyond bounded copy; automated conflict suggestions.

### Must remain prohibited

- Private-message mining, general model training, public reputation, Safety-to-Compatibility leakage, cross-user scoring, retroactive-erasure promises, unreviewed truth adjudication, one broad consent, and speculative indefinite retention.

### Must remain gated

- Safety record lifecycle; disputed another-person disclosure; exact retention periods; legal preservation; backup deletion; anonymization standard; response times; appeal/notice; and any operational policy relying on unresolved U-01/U-04/U-10/U-11/U-12/U-14 facts.

## 8. Owner Decision Packet

The Owner may choose, revise, or defer each item independently. No recommendation below is accepted until the Owner records a decision.

1. **Shared-rights model**
   - A: single record owner controls all actions.
   - B: five independent dimensions with participant-local and conflict-aware actions.
   - C: defer all shared-record behavior.
   - **Recommendation:** B. Reject A because it collapses distinct authority; reject C because MVP cannot safely promise shared controls without a baseline.

2. **Disputed correction**
   - A: last participant edit wins.
   - B: correct established product errors; otherwise preserve provenance, disagreement, and stale dependent outputs pending review.
   - C: prohibit all correction of shared records.
   - **Recommendation:** B.

3. **Deletion conflict**
   - A: immediate whole-record deletion on either request.
   - B: decompose future use, local view, redaction/de-identification, independent authorship, and narrow reviewed retention.
   - C: retain whole record whenever either participant objects.
   - **Recommendation:** B; A and C make overbroad promises.

4. **Export/copy conflict**
   - A: export the entire shared container.
   - B: bounded participant-attributable copy with redaction/restriction and formal review for contested scope.
   - C: no shared-record export.
   - **Recommendation:** B.

5. **Lifecycle action vocabulary**
   - A: use only update/delete.
   - B: adopt the 12 distinct actions in section 3.
   - C: defer vocabulary until technical design.
   - **Recommendation:** B; technical design must follow product meaning, not define it.

6. **Retention exceptions**
   - A: retain whenever future value is plausible.
   - B: named purpose, shortest necessary, restricted access, review/expiry, no ordinary reuse.
   - C: promise immediate universal deletion.
   - **Recommendation:** B; exact periods remain unknown.

7. **Safety-controlled information**
   - A: include it in ordinary shared-right rules.
   - B: allow only minimum-necessary Safety directives in ordinary domains; route evidence and lifecycle decisions to U-04/formal review.
   - C: ignore Safety dependencies.
   - **Recommendation:** B.

8. **MVP boundary**
   - A: require the seven minimum behaviors in section 7 before implementation authorization.
   - B: defer shared-right/lifecycle policy and handle conflicts ad hoc.
   - C: exclude all shared Conversation/Relationship information from MVP.
   - **Recommendation:** A, unless Owner explicitly chooses C as a scope reduction. Reject B.

9. **U-02/U-03 disposition after this draft**
   - A: mark both resolved now.
   - B: retain `BLOCKING` until GPT L3 review and explicit Owner decisions on Packet 1–8; then record the bounded resolved/retained-unknown portions.
   - C: discard the workshop.
   - **Recommendation:** B.

## 9. Stop and review state

- U-02: `BLOCKING — NOT SILENTLY RESOLVED`.
- U-03: `BLOCKING — NOT SILENTLY RESOLVED`.
- U-04: unchanged and not resolved here.
- ADR-006 remains proposed.
- No DeepSeek, new legal research, LC-03, LC-04, Phase 36, implementation, processing, Safety Operations, schema, API, backend, Flutter, infrastructure, or code is authorized or performed.

Stop for GPT L3 review and Owner decisions on the packet above.
