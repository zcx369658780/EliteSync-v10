# ADR-007: Safety Governance and Moderation Responsibility

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

Decision owner: Owner, after GPT L3 Safety-governance review

Depends on: ADR-001 through ADR-006; U-02/U-03 closeout; Phase 34 Owner-accepted Safety authority; accepted LC-02 closeout and layered advisory artifact

## Context

U-04 remains `BLOCKING`. EliteSync has accepted Safety meaning boundaries but lacks an accepted product-policy taxonomy, protection model, evidence/review semantics, case-state vocabulary, appeal/lifecycle rule, repeat-pattern boundary, external-routing authority, responsibility model, and capacity evidence.

This ADR proposes technology-neutral product governance only. It does not define Safety Operations, moderation staffing, workflow, scoring, technical architecture, processing, or implementation.

## Evidence discipline

### Observed / Accepted Authority

- The 28 Phase 34 Safety invariants remain unchanged.
- User protective action ≠ allegation ≠ evidence ≠ reviewed finding ≠ Safety restriction.
- Safety evidence never enters ordinary domains; minimum-necessary control directives may enter only as enforcement instructions.
- Case state never becomes person truth; no hidden/visible Safety-derived reputation or romantic score is permitted.
- U-02/U-03 require named-purpose, shortest-necessary, restricted, reviewed retention and correction/reversal propagation; `de-identify` and `anonymize` are distinct.

### Advisory Input

Track B is AI-assisted advisory analysis only. LC-02 Layer B is AI-assisted legal research, not formal legal opinion. Neither establishes facts, legal duties, Safety findings, or operational policy.

### Product Inference

A closed semantic and authority contract can reduce category collapse now while leaving factual, fairness, responsibility, capacity, legal, and operational questions unresolved.

### Proposed Product Decision

Adopt the recommended option below after GPT L3 and Owner review.

### Still Unknown / Requires Later Review

Trigger thresholds, finding/evidence standard, reviewer qualification, responsibility, capacity, quality targets, fairness method, legal duties, external routing, exact retention, backup, anonymization verification, response timing, notice/appeal procedure, and operations remain unknown.

## Proposed decision

### 1. Non-collapsible taxonomy

Keep distinct: user protective action; concern/report submission; allegation; system-observed event; evidence item; AI interpretation/advisory summary; reviewed finding; immediate/interim protection; Safety restriction/control; correction/reversal/supersession; appeal/contest; and unknown/insufficient information.

Each concept states what it establishes and what it cannot establish. No automatic chain `allegation → evidence → finding` exists. Classification: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.

### 2. Protection without guilt

User-self block/protective closure requires no adjudication. Separately, future immediate protection may precede adjudication only when it is reversible, minimum-necessary, purpose-bound, reviewed/expired/lifted under accepted authority, and never treated as guilt, punishment, finding, reputation, or desirability.

The product rule is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. Concrete triggers are classified `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-06 FAIRNESS`, `DEPENDS ON U-11 RESPONSIBILITY`, and `DEPENDS ON U-12 QUALITY / CAPACITY`.

### 3. Evidence and reviewed-finding boundary

User allegations prove only submission; system observation proves only the bounded event/context; AI interpretation is not verified fact; external/official material requires later authority; a reviewed finding requires separately accepted claim-specific review authority and standard. Unknown remains unknown.

Finding semantics are classified `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-11 RESPONSIBILITY`, and `DEPENDS ON U-12 QUALITY / CAPACITY`. External/legal force is classified `REQUIRES LATER LEGAL AUTHORITY`.

### 4. Neutral case-processing vocabulary

Use `submitted`, `pending review`, `insufficient information`, `actioned/protected`, `rejected/not advanced`, `unresolved`, `appealed`, `corrected/reversed/superseded`, and `closed` only as processing meanings. None implies guilt, innocence, danger, safety, truth, dishonesty, trustworthiness, character, Compatibility, or reputation.

Vocabulary is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; transition authority remains later.

### 5. Review authority classes

Separate user-self protection, reversible interim protection, reviewed factual finding, longer-lived/consequential restriction, correction/reversal/supersession, appeal disposition, and external routing. These are authority capabilities, not jobs, teams, services, or workflows.

Final authority and execution `DEPENDS ON U-11 RESPONSIBILITY`; evidence/quality/capacity `DEPENDS ON U-12 QUALITY / CAPACITY`; fairness-sensitive outcomes `DEPENDS ON U-06 FAIRNESS`; external routing and applicable duties are classified `REQUIRES LATER LEGAL AUTHORITY`.

### 6. AI and repeat-pattern boundary

Future separately authorized AI may summarize, organize, expose contradiction/uncertainty, generate review questions, and provide non-binding assistance. It cannot autonomously validate allegations, create findings, establish emergency truth, determine guilt/innocence, issue moderation outcomes, make irreversible restrictions, or generate public/romantic reputation or person scores.

Reports/blocks/incidents retain separate provenance. Counts never equal guilt and cannot become a reputation/bad-actor/trustworthiness/Compatibility/Ranking/desirability score. Future Safety-only prioritization/risk remains `NOT DECIDED / REQUIRES LATER FAIRNESS + LEGAL + REVIEW AUTHORITY`.

Autonomous authority and person scoring are `PROHIBITED BY ACCEPTED AUTHORITY`.

### 7. Minimum-necessary control directives

Ordinary domains may receive only conceptual availability controls such as `contact unavailable`, `matching unavailable`, and `conversation access restricted`. They receive no report/allegation text, evidence, counts, reporter identity, hidden reasoning, reviewed-case detail, guilt inference, or person label.

Directives are reversible/correctable and carry only enforcement meaning. Baseline is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; responsibility and quality `DEPENDS ON U-11 RESPONSIBILITY` and `DEPENDS ON U-12 QUALITY / CAPACITY`.

### 8. Correction, appeal, and lifecycle

Corrected/reversed/superseded Safety authority cannot leave stale ordinary controls or adverse/reputation residue. Removing a directive does not automatically erase restricted Safety history. Reversal does not mean the reporter lied; rejected/not advanced does not mean the allegation was false.

Consequential reviewed restrictions should be contestable under later authority. Correction of product/factual error remains distinct from appeal. Notice must not over-disclose reporter/private/Safety information.

Retention requires named purpose, shortest necessity, restricted access, review/expiry, termination, and no ordinary reuse. There is no blanket Safety exception or indefinite future-value retention. `de-identify` does not establish non-reidentifiability; `anonymize` requires a later accepted verification standard.

Baseline rules are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; concrete outcomes are classified `REQUIRES LATER FACT / FORMAL REVIEW`; legal preservation/disclosure is classified `REQUIRES LATER LEGAL AUTHORITY`; responsibility/quality depend on U-11/U-12.

### 9. External-routing stop boundary

No AI or case state may establish emergency truth or an external-reporting duty. Any law-enforcement, emergency-service, regulator, or other external routing requires separately established legal/factual authority plus explicit product and operational authorization.

This `REQUIRES LATER LEGAL AUTHORITY`, `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-11 RESPONSIBILITY`, and `DEPENDS ON U-12 QUALITY / CAPACITY`. Autonomous routing is `PROHIBITED BY ACCEPTED AUTHORITY`.

### 10. MVP policy gate

Before affected MVP implementation may be separately authorized, product policy must cover user block/self-protection, report semantics, reversible immediate-protection boundary, restricted evidence/provenance, no-guilt case semantics, minimum-necessary directives, correction/reversal propagation, contest boundary for consequential reviewed decisions, and prohibition on Safety-to-Compatibility/reputation leakage.

The semantic gate is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. It does not itself authorize implementation, processing, or Safety Operations; dependent scope remains blocked by unresolved U-06/U-11/U-12/legal/factual requirements.

## Recommended option

Adopt the bounded semantic-governance model above and the detailed Owner Decision Packet in `docs/architecture/ELITESYNC_V10_U04_SAFETY_GOVERNANCE_WORKSHOP_V0_1.md`.

Reasons:

- preserves all 28 accepted Safety invariants;
- separates protection from adjudication and case state from person truth;
- permits only minimum-necessary ordinary-domain controls;
- prevents Safety evidence, counts, AI output, and correction residue from becoming reputation or romantic meaning;
- gives later review a product contract without inventing law, fairness, responsibility, capacity, operations, or technology.

### Rejection or exit conditions

Reject or revise this option if it weakens any accepted invariant, permits Safety evidence leakage/person scoring/autonomous adjudication, collapses self-protection with findings, or is treated as operational or implementation authority. Stop affected MVP scope when later factual/legal/fairness/responsibility/quality prerequisites are absent.

## Viable alternative

Limit MVP to user-self block/closure and report submission semantics, and exclude policy-imposed findings, consequential restrictions, repeat-pattern assessment, external routing, and advanced appeals until later authority exists.

### When to prefer the alternative

Prefer it if the Owner wants the narrowest pre-alpha Safety surface and explicitly removes dependent product promises and journeys.

### Alternative rejection conditions

Reject this alternative if MVP still applies platform-imposed protection/restriction, represents case outcomes, retains Safety evidence for reviewed use, promises appeal, or routes externally. Those functions require the fuller policy boundary.

## Alternatives rejected

### A. Ad hoc moderation during implementation

Rejected because technical convenience would silently define guilt, protection, evidence, lifecycle, and responsibility semantics.

### B. Report/block/count-based person scoring

Rejected as `PROHIBITED BY ACCEPTED AUTHORITY`.

### C. Autonomous AI triage, findings, or restrictions

Rejected as `PROHIBITED BY ACCEPTED AUTHORITY`.

### D. Safety evidence in ordinary domains

Rejected; only minimum-necessary control directives may cross the boundary.

### E. Blanket indefinite Safety retention or universal immediate deletion

Rejected because both erase purpose-specific, multi-interest, correction, review, and legal/factual distinctions.

## Consequences if accepted

### Positive

- Stable semantic separation for future product review.
- Reversible protection without guilt inference.
- Explicit evidence/provenance and case-state limits.
- Cross-domain isolation and correction propagation.
- Visible dependencies instead of invented operational certainty.

### Costs and constraints

- Many consequential decisions remain manual/later-authority gated.
- MVP may require scope reduction if responsibility/capacity/fairness/legal prerequisites remain absent.
- Exact notice, appeal, retention, finding, and routing promises remain unavailable.
- No operations or implementation readiness follows from acceptance.

## Unknowns retained

- U-04: `BLOCKING — NOT RESOLVED BY THIS PROPOSAL`.
- U-06, U-11, U-12, and every other separately unresolved `BLOCKING UNKNOWN` remain unchanged.
- No trigger threshold, finding/evidence standard, reviewer qualification, fairness method, responsible operating role, capacity/SLA, quality target, legal duty, external route, exact retention, backup rule, anonymization verification, response time, notice/appeal procedure, Safety Operations policy, processing authority, or technical design is selected.

## Owner decision dependency

Owner must decide the numbered packet in the U-04 workshop after GPT L3 reviews Safety semantics, provenance, authority, lifecycle, isolation, dependencies, and MVP boundaries.

Until explicit Owner acceptance and final closeout:

- ADR-007 remains `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`;
- U-04 remains blocking;
- no DeepSeek, new legal research, real Safety case/user data, Safety Operations, workforce/queue/SLA design, Safety scoring/risk model, autonomous triage, external-routing implementation, LC-03, LC-04, Phase 36, processing, database/schema/API/backend/Flutter/services/events/queues/storage/infrastructure/code, or implementation is authorized.
