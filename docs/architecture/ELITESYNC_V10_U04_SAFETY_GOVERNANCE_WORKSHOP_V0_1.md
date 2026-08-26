# EliteSync-v10 U-04 Safety Governance Workshop V0.1

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

## 0. Scope, authority, and evidence discipline

This is a technology-neutral U-04 Safety-governance and product-policy workshop. It defines Owner-decision options, not Safety Operations, moderation workflow, technical architecture, processing authority, or implementation.

### Observed / Accepted Authority

- ADR-001–006 are accepted. Safety owns protection meaning and may constrain ordinary journeys, while Safety evidence remains excluded from Compatibility, romantic Ranking, desirability, public reputation, and relationship-worth.
- U-02 and U-03 are complete for the current pre-alpha product-policy purpose. Their accepted lifecycle, retention, shared-rights, correction, and control-directive boundaries remain controlling.
- Phase 34 Owner decisions establish 28 Safety invariants. Section 1 preserves them without weakening.
- LC-02 Layer A is repository-authoritative Safety authority. LC-02 Layer B remains `AI-ASSISTED LEGAL RESEARCH — NOT FORMAL LEGAL OPINION`.
- U-04 remains `BLOCKING`. This draft does not resolve it.

### Advisory Input

- The Track B report is `AI-ASSISTED ADVISORY ANALYSIS`, not verified Safety evidence, a real-case finding, legal authority, or Owner policy. Its retained concerns identify taxonomy, false-positive/false-negative, leakage, remedy, lifecycle, appeal, repeat-pattern, responsibility, and capacity questions.
- LC-02 Layer B supplies advisory privacy/purpose/correction/deletion considerations and explicit legal uncertainty. It does not establish Safety truth, a review standard, an external-routing duty, or an operational rule.

### Product Inference

U-04 can establish a bounded semantic contract now: what each Safety concept means, what it cannot mean, which reversible protections are conceptually permitted, and which decisions must stop for later authority. It cannot establish real triggers, thresholds, personnel, capacity, law, or case outcomes.

### Proposed Product Decision

Adopt the taxonomy, authority classes, lifecycle boundaries, control-directive contract, and MVP gate below, subject to explicit Owner selection in section 16.

### Still Unknown / Requires Later Review

Concrete trigger thresholds, factual finding standard, evidence threshold, reviewer qualification, jurisdictional duties, external-routing duty, exact retention, backup treatment, anonymization verification, notice detail, response timing, appeal procedure, fairness method, operating responsibility, capacity, and quality targets remain unknown.

## 1. Frozen Safety invariant register

The following 28 Owner-accepted invariants remain unchanged:

1. User protective action, allegation, evidence, reviewed finding, and Safety restriction are distinct states and must not be collapsed.
2. Block does not imply wrongdoing.
3. Block is not Report.
4. A block establishes only a protective/access-control state and does not establish misconduct, guilt, a report, or a reviewed Safety finding.
5. A report establishes only that a Safety concern or allegation was submitted.
6. Report is not verified misconduct.
7. Allegation is not Finding.
8. Immediate protection may precede adjudication.
9. Immediate protection is not guilt.
10. Immediate protection is not punishment.
11. Immediate protection is not a public reputation finding.
12. Immediate protection is not a romantic desirability judgment.
13. Safety evidence must not flow into ordinary domains.
14. Minimum-necessary Safety control directives may flow into ordinary domains only as enforcement instructions.
15. Control directive is not Safety evidence.
16. Control directive is not evidence disclosure; ordinary domains must not receive underlying report contents, allegation details, Safety evidence, AI or reviewed-case reasoning, or person-level guilt inference.
17. No report is not Safe.
18. Insufficient evidence is not a false allegation.
19. A rejected or non-advanced case does not establish that the reporter lied.
20. An actioned case is not a public guilt label.
21. Unresolved is not Guilty.
22. Unresolved is not Innocent.
23. Unknown is not False.
24. Unknown is not Safe.
25. Safety case-processing state does not automatically establish person truth, moral character, Compatibility, desirability, or public reputation.
26. No hidden or visible Safety-derived reputation, trustworthiness, bad-actor, report-count, or block-count score may be used for Compatibility, romantic Ranking, desirability, public reputation, or general relationship-worth.
27. Future bounded Safety-only operational risk assessment remains NOT DECIDED.
28. Phase 34 authorizes no Safety Operations model.

Any option that contradicts one of these invariants is `PROHIBITED BY ACCEPTED AUTHORITY`.

## 2. Dependency-classification vocabulary

Every material decision uses one or more of these exact classifications:

- `PRODUCT RULE CAN BE OWNER-DECIDED NOW`
- `REQUIRES LATER FACT / FORMAL REVIEW`
- `DEPENDS ON U-06 FAIRNESS`
- `DEPENDS ON U-11 RESPONSIBILITY`
- `DEPENDS ON U-12 QUALITY / CAPACITY`
- `REQUIRES LATER LEGAL AUTHORITY`
- `PROHIBITED BY ACCEPTED AUTHORITY`

## 3. Safety semantic taxonomy

### Observed / Accepted Authority

Safety concepts cannot be collapsed into a promotion chain or person-truth label.

### Advisory Input

Track B identifies category collapse as a high-priority risk; its suggested vocabulary remains advisory.

### Product Inference

A closed conceptual taxonomy reduces meaning drift without selecting a database enum or operational workflow.

### Proposed Product Decision

| Concept | Product-policy meaning | MUST NOT imply | Classification |
| --- | --- | --- | --- |
| User protective action | A participant-scoped access or contact boundary, such as block or appropriate mute/close | Report, wrongdoing, allegation, evidence, finding, guilt, punishment | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| Safety concern / report submission | A person submitted a concern for restricted handling | Truth, verified misconduct, emergency, required restriction | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| Allegation / user-authored claim | A provenance-bound claim by its author | Verified fact, evidence of truth by repetition, finding | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| System-observed event | A bounded product event was observed in its recorded context | Intent, motive, off-platform conduct, guilt, broader character | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| Evidence item | Information admitted for a defined review purpose with source and limitations | Automatic truth, finding, permission for ordinary reuse | `REQUIRES LATER FACT / FORMAL REVIEW` |
| AI/model interpretation or advisory summary | A labeled, uncertain aid derived from supplied material | Verified fact, allegation validation, finding, emergency truth, restriction authority | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; autonomous authority is `PROHIBITED BY ACCEPTED AUTHORITY` |
| Reviewed finding | A claim-specific outcome reached under a separately accepted authority and standard | Public guilt, moral character, romantic suitability, permanent truth | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Immediate/interim protection | A reversible, minimum-necessary protection pending later review where required | Guilt, punishment, finding, reputation, desirability | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; concrete trigger is `REQUIRES LATER FACT / FORMAL REVIEW` |
| Safety restriction/control decision | A purpose-bound decision constraining named product availability | Evidence disclosure, public judgment, Compatibility evidence | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; consequential duration/authority `REQUIRES LATER FACT / FORMAL REVIEW` |
| Correction/reversal/supersession | A prior record, decision, or control is corrected, replaced, or no longer controlling | Erasure of provenance, proof the reporter lied, automatic deletion of restricted history | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| Appeal/contest | A request to correct an error or re-review a contestable decision | Automatic reversal, proof the original decision was wrong | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; procedure `REQUIRES LATER FACT / FORMAL REVIEW` |
| Unknown/insufficient information | Available information cannot support the specified conclusion | False, safe, guilty, innocent, liar, trustworthy, untrustworthy | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |

### Still Unknown / Requires Later Review

Operational category criteria, admissibility, evidentiary force, finding standard, responsible authority, and quality/capacity requirements remain unknown.

## 4. Trigger and protection model

### Observed / Accepted Authority

Block and report are separate. Immediate protection may precede adjudication but is not guilt or punishment.

### Advisory Input

Track B highlights both false-positive harm and residual false-negative risk without authorizing surveillance, private-message mining, or profiling.

### Product Inference

Product policy can permit reversible protection categories without creating automatic thresholds.

### Proposed Product Decision

1. A user block/self-protective closure applies the participant's boundary without adjudicating another person. Classification: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.
2. A report creates a restricted concern record; it does not automatically add protection beyond separately justified scope. Classification: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.
3. A system-observed concern must identify the exact observed event and cannot infer motive or guilt. Classification: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.
4. Immediate protection may be considered only for a concrete, time-relevant risk to contact or access; it must be reversible, least-broad, purpose-bound, and separated from adjudication. The category rule is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; actual trigger criteria are `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-06 FAIRNESS`, and `DEPENDS ON U-12 QUALITY / CAPACITY`.
5. Every non-user-self interim protection requires a named review/expiry/lift condition and correction route. Final responsibility `DEPENDS ON U-11 RESPONSIBILITY`.
6. Automatic guilt, punishment, public labeling, romantic penalties, or irreversible action from block/report/count/AI output are `PROHIBITED BY ACCEPTED AUTHORITY`.

### Still Unknown / Requires Later Review

No threshold, severity scale, duration, escalation trigger, reviewer, queue, SLA, or operational mechanism is selected.

## 5. Evidence and provenance model

### Observed / Accepted Authority

Allegation does not automatically become evidence of truth; AI interpretation is not verified fact; case state is not person truth.

### Advisory Input

LC-02 suggests privacy, accuracy, purpose, correction, and deletion considerations but is not formal legal opinion and establishes no finding standard.

### Product Inference

Each item needs an explicit source class, bounded proposition, context, uncertainty, purpose, and correction status before it can carry any reviewed force.

### Proposed Product Decision

| Provenance class | Allowed force | Prohibited force | Classification |
| --- | --- | --- | --- |
| User-authored allegation/concern | Proves the claim was submitted by its attributed author | Does not prove the alleged conduct | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| System-observed product event | Proves only the bounded event/context actually observed | Does not prove intent, off-platform facts, or guilt | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| External/official evidence | May be considered only after source, scope, authority, and handling are separately accepted | No assumed authenticity, admissibility, duty, or finding force | `REQUIRES LATER LEGAL AUTHORITY`; `REQUIRES LATER FACT / FORMAL REVIEW` |
| AI/model interpretation | May summarize, organize, expose contradiction/uncertainty, and generate review questions | Cannot validate allegation, create evidence, or make a finding | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; autonomous promotion is `PROHIBITED BY ACCEPTED AUTHORITY` |
| Reviewed finding | Has only claim-specific, purpose-specific force under a later accepted standard | Does not become global person truth or romantic/public reputation | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Unknown/insufficient information | Preserves uncertainty and may justify no conclusion | Does not establish falsehood or safety | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |

There is no automatic promotion chain `allegation → evidence → finding`.

### Still Unknown / Requires Later Review

Admissibility, authenticity, evidence threshold, review authority, contest standard, external-source handling, and legal duties remain unknown.

## 6. Case-processing state model

### Observed / Accepted Authority

Case-processing state describes handling of a concern, never person truth.

### Advisory Input

Track B and Phase 34 name candidate states but explicitly did not accept an operational vocabulary.

### Product Inference

A neutral vocabulary can prevent user-facing and internal semantic overclaim while remaining implementation-neutral.

### Proposed Product Decision

| State | Meaning | Explicit non-meaning |
| --- | --- | --- |
| `submitted` | Concern was received with submitted provenance | Not true, valid, emergency, or actionable |
| `pending review` | No authorized disposition has yet been recorded | Not guilty, unsafe, or likely true |
| `insufficient information` | The accepted standard cannot be satisfied on available material | Not false allegation, safe, innocent, or reporter dishonesty |
| `actioned/protected` | A named protection or restriction was applied under its authority | Not guilt, punishment, public finding, or romantic judgment |
| `rejected/not advanced` | The concern did not proceed under the applicable decision rule | Not reporter lied, allegation false, or person safe |
| `unresolved` | No supported final disposition exists | Not guilty or innocent |
| `appealed` | A contest/re-review request is active or recorded | Not automatic error or reversal |
| `corrected/reversed/superseded` | A later authorized record replaces or limits an earlier state/decision | Not deletion of provenance or proof of malicious reporting |
| `closed` | Active handling ended for a stated reason | Not public/person truth and not necessarily deletion or expiry |

The vocabulary is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. Criteria and transitions are `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-11 RESPONSIBILITY`, and `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Transition authority, reopening, notice, timing, service expectations, and operational state machinery remain unknown.

## 7. Review authority and decision classes

### Observed / Accepted Authority

The Owner is product authority; AI is advisory only. No staffing model or operational authority exists.

### Advisory Input

Track B identifies unresolved human-review triggers and failure ownership. This does not restore a current specialist-sourcing gate.

### Product Inference

Capability classes can define required authority without inventing staff titles or teams.

### Proposed Product Decision

| Decision class | Conceptual authority boundary | Classification |
| --- | --- | --- |
| User-self protective action | Participant may set their own contact/access boundary without adjudication | `PRODUCT RULE CAN BE OWNER-DECIDED NOW` |
| Reversible minimum-necessary protection | May be applied only under later accepted trigger/expiry/review authority | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; execution `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Reviewed factual finding | Requires claim-specific evidence standard and authorized review | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-06 FAIRNESS`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Longer-lived/consequential restriction | Requires stronger, separately accepted authority, proportionality, contest, and expiry | Same dependencies as reviewed finding; legal effects `REQUIRES LATER LEGAL AUTHORITY` |
| Correction/reversal/supersession | Must be possible under the authority that can correct product/factual error or reconsider decision | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; final responsibility `DEPENDS ON U-11 RESPONSIBILITY` |
| Appeal disposition | Requires an independent or otherwise accepted re-review authority and standard | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| External routing/escalation | Requires separately established legal/factual duty and product/operational authorization | `REQUIRES LATER LEGAL AUTHORITY`; `DEPENDS ON U-11 RESPONSIBILITY` |

### Still Unknown / Requires Later Review

Reviewer identity/qualification, separation of duties, credentials, operating owner, evidence threshold, capacity, SLA, and legal authority remain unknown.

## 8. AI authority boundary

### Observed / Accepted Authority

AI cannot autonomously determine guilt, innocence, abuse/fraud truth, emergency status, report validity, moderation outcome, irreversible restriction, public reputation, romantic suitability, or relationship worth.

### Advisory Input

Track B suggests bounded summarization, organization, contradiction detection, uncertainty exposure, review questions, and non-binding prioritization support.

### Product Inference

The allowed advisory functions are useful only if no AI output becomes a hidden gate, scalar person score, or decision substitute.

### Proposed Product Decision

Future separately authorized AI may assist with summarization, organization, contradiction detection, uncertainty exposure, review-question generation, and non-binding review support. Each output remains labeled, provenance-bound, reviewable, and non-authoritative.

Autonomous findings, allegation validation, emergency truth, guilt/innocence, moderation outcome, irreversible restriction, public/romantic reputation, relationship worth, or person-level scoring are `PROHIBITED BY ACCEPTED AUTHORITY`.

Future Safety-only prioritization/risk assessment remains `NOT DECIDED / REQUIRES LATER FAIRNESS + LEGAL + REVIEW AUTHORITY`. This workshop accepts no scoring model or autonomous/non-autonomous triage mechanism. Dependencies: `DEPENDS ON U-06 FAIRNESS`, `DEPENDS ON U-11 RESPONSIBILITY`, `DEPENDS ON U-12 QUALITY / CAPACITY`, and `REQUIRES LATER LEGAL AUTHORITY`.

### Still Unknown / Requires Later Review

Whether any non-scoring priority aid is necessary, fair, lawful, reviewable, effective, and operationally supportable remains unknown.

## 9. Minimum-necessary Safety control directive contract

### Observed / Accepted Authority

Ordinary domains may receive minimum-necessary enforcement instructions, never Safety evidence or reasoning.

### Advisory Input

Phase 34 gives conceptual examples only; they are not APIs, events, or schemas.

### Product Inference

Closed meanings prevent an availability directive from becoming an adverse person label.

### Proposed Product Decision

| Conceptual directive | Ordinary-domain meaning | Forbidden payload/inference |
| --- | --- | --- |
| `contact unavailable` | Do not permit new contact in the affected scope | No report/allegation/evidence/reason/count/guilt/person label |
| `matching unavailable` | Do not present or create affected matching opportunities | No desirability penalty, Safety score, explanation detail, or reputation inference |
| `conversation access restricted` | Enforce the named conversation access boundary | No reporter identity, allegation text, evidence, case detail, or finding reasoning |

Each directive carries only scope, current enforcement meaning, and correctable/reversible status conceptually. The contract is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; issuer, timing, failure ownership, and propagation targets `DEPENDS ON U-11 RESPONSIBILITY` and `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

No event/API shape, transport, timing, retry, persistence, service owner, or operational directive catalogue is defined.

## 10. Correction, reversal, and supersession propagation

### Observed / Accepted Authority

Corrected, reversed, or superseded Safety states must not leave stale ordinary-domain adverse/control effects. Removal of a control does not automatically erase restricted history.

### Advisory Input

LC-02 identifies accuracy, purpose, correction, deletion, and preservation questions but does not settle retention or legal duties.

### Product Inference

Active enforcement and restricted historical/audit records require different lifecycle meanings.

### Proposed Product Decision

1. Superseded directives cease to authorize ordinary-domain enforcement; stale downstream controls must be removed or replaced. `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.
2. No Safety-derived reputation, hidden penalty, Compatibility feature, explanation residue, or relationship-worth effect may remain. `PROHIBITED BY ACCEPTED AUTHORITY`.
3. Removing a directive does not automatically delete evidence/history. Any retained record requires named purpose, shortest necessity, restricted access, review/expiry, termination condition, and no ordinary reuse. `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; exact retention `REQUIRES LATER FACT / FORMAL REVIEW` and may be classified `REQUIRES LATER LEGAL AUTHORITY`.
4. Reversal does not imply reporter dishonesty; rejected/non-advanced does not imply allegation false. `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.
5. Propagation responsibility `DEPENDS ON U-11 RESPONSIBILITY`; reliability/latency/verification `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Exact propagation targets, timing, failure handling, audit record, deletion, backup, and legal preservation remain unknown.

## 11. Appeal, contest, and notice semantics

### Observed / Accepted Authority

Appeal is not automatic reversal. Safety information remains restricted; shared/private interests and provenance remain protected.

### Advisory Input

Track B identifies appeal/correction gaps. LC-02 supplies no complete disclosure or appeal rule.

### Product Inference

Consequential reviewed restrictions should have a contest boundary, while immediate user-self protection need not be adjudicated against the protecting participant.

### Proposed Product Decision

- Correcting a factual/product error is distinct from appealing a reviewed decision.
- Longer-lived or materially consequential reviewed restrictions should be contestable under later accepted authority; user-self block/contact refusal is not an allegation to adjudicate or override.
- Notice may communicate the affected product control, its scope, whether contest is available, and minimum correction information. It must not expose reporter identity, private information, evidence, allegation details, or protected reasoning beyond separately authorized scope.
- Correction/reversal must propagate under section 10.

The baseline is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. Disclosure, jurisdictional notice, response time, reviewer procedure, and appeal standard are classified `REQUIRES LATER FACT / FORMAL REVIEW`; some are also classified `REQUIRES LATER LEGAL AUTHORITY`; responsibility `DEPENDS ON U-11 RESPONSIBILITY`; quality/capacity `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Exact contestable decisions, notice content, reporter protections, procedure, timing, evidence access, standard, and authority remain unknown.

## 12. Repeat-pattern treatment

### Observed / Accepted Authority

Counts do not equal guilt; missing reports do not mean safe; reports/blocks cannot become reputation, Compatibility, Ranking, desirability, or relationship-worth signals.

### Advisory Input

Track B flags hidden report-count/block-count/bad-actor scoring and false-positive/false-negative risks.

### Product Inference

Repeated records may justify later human review of the records themselves, but cannot be compressed into person truth or a hidden person score.

### Proposed Product Decision

- Preserve each record's provenance, context, uncertainty, and disposition separately.
- Do not aggregate counts into guilt, trustworthiness, bad-actor, reputation, desirability, Compatibility, or romantic Ranking. Such use is `PROHIBITED BY ACCEPTED AUTHORITY`.
- A future review-priority signal remains `NOT DECIDED`; it cannot be a factual finding or person score and `DEPENDS ON U-06 FAIRNESS`, `DEPENDS ON U-11 RESPONSIBILITY`, `DEPENDS ON U-12 QUALITY / CAPACITY`, and `REQUIRES LATER LEGAL AUTHORITY`.
- No absence-of-record signal may be interpreted as Safety clearance. `PRODUCT RULE CAN BE OWNER-DECIDED NOW`.

### Still Unknown / Requires Later Review

No threshold, weighting, lookback, deduplication, priority method, fairness scope, or operating capacity is selected.

## 13. Safety lifecycle and retention framework

### Observed / Accepted Authority

Safety lifecycle is purpose-bound. No blanket Safety exception, speculative indefinite retention, or ordinary reuse is accepted. `de-identify` and `anonymize` remain separate.

### Advisory Input

LC-02 supports shortest-necessary and deletion/correction review as advisory legal research but supplies no exact EliteSync period or complete rule.

### Product Inference

Active decision state and restricted historical/audit record can have distinct purposes and lifecycles.

### Proposed Product Decision

Potential named purposes for later acceptance are limited to: handling an active concern; enforcing a currently authorized protection/restriction; resolving a correction/contest/appeal; preserving minimum provenance needed to explain a consequential decision; and complying with a separately established legal duty.

Every retained class requires named purpose, minimum scope, shortest necessity, restricted access, review/expiry, termination condition, and no ordinary-domain reuse. When purpose ends, eligible material must be deleted, restricted, de-identified, or anonymized only under its distinct accepted meaning and later authority.

`de-identify` reduces/removes direct linkage but does not establish non-reidentifiability or remove person-linked constraints. `anonymize` may be claimed only after a later accepted standard establishes that reasonable re-identification is not possible.

The framework is `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. Exact periods, legal preservation, backup, deletion refusal, access/export, anonymization verification, and jurisdictional duty are classified `REQUIRES LATER FACT / FORMAL REVIEW` and may also be classified `REQUIRES LATER LEGAL AUTHORITY`.

### Still Unknown / Requires Later Review

All concrete schedules, backup treatment, preservation duties, anonymization standard, access/export detail, and Safety-specific deletion outcomes remain unknown.

## 14. External routing and emergency boundary

### Observed / Accepted Authority

No AI or case state may establish emergency truth or an external-reporting duty.

### Advisory Input

Track B routes legal questions outward and authorizes no emergency decision or external implementation.

### Product Inference

Only a stop boundary is safe before jurisdiction, duty, factual threshold, accountable authority, notice/privacy, and operations are established.

### Proposed Product Decision

- Law-enforcement, emergency-service, regulator, or other external routing requires separately established legal and factual authority plus explicit product and operational authorization.
- AI may organize facts/questions but cannot decide emergency truth, reporting duty, or routing outcome.
- Before design, establish jurisdiction/population, applicable duty, triggering fact standard, source verification, responsible authority, urgency/availability assumptions, privacy/disclosure constraints, documentation, contest/correction, and failure responsibility.

This boundary `REQUIRES LATER LEGAL AUTHORITY`, `REQUIRES LATER FACT / FORMAL REVIEW`, `DEPENDS ON U-11 RESPONSIBILITY`, and `DEPENDS ON U-12 QUALITY / CAPACITY`. Autonomous routing is `PROHIBITED BY ACCEPTED AUTHORITY`.

### Still Unknown / Requires Later Review

All external-routing duties, triggers, recipients, procedures, timing, capacity, and failure handling remain unknown.

## 15. Responsibility and MVP boundary

### 15.1 Conceptual responsibility classes

### Observed / Accepted Authority

Safety owns protection/restriction meaning; Moderation Operations may later execute accepted policy but does not define human value. No operating role is authorized.

### Advisory Input

Track B identifies cross-context failure ownership and capacity as unresolved.

### Product Inference

Responsibility capabilities can be named without selecting teams, services, reviewers, or staffing.

### Proposed Product Decision

| Capability | Conceptual responsibility | Dependency |
| --- | --- | --- |
| Accept a concern | Preserve submitted provenance and restricted intake meaning | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; accountable owner `DEPENDS ON U-11 RESPONSIBILITY` |
| Apply immediate protection | Apply only reversible minimum-necessary scope under accepted authority | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Hold restricted Safety evidence | Preserve purpose, access, provenance, correction, and lifecycle separation | `DEPENDS ON U-11 RESPONSIBILITY`; legal scope `REQUIRES LATER LEGAL AUTHORITY` |
| Request/review a finding | Keep allegation/evidence/finding distinct under accepted standard | `REQUIRES LATER FACT / FORMAL REVIEW`; `DEPENDS ON U-06 FAIRNESS`; `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Issue/remove directives | Send only minimum-necessary control meaning and reverse stale controls | `DEPENDS ON U-11 RESPONSIBILITY`; `DEPENDS ON U-12 QUALITY / CAPACITY` |
| Record correction/reversal | Preserve provenance while removing stale authority/effects | `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; final owner `DEPENDS ON U-11 RESPONSIBILITY` |
| Receive appeal/contest | Preserve a distinct request without implying reversal | Baseline `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; disposition authority remains later |
| Require formal/legal review | Stop when fact, legal duty, disclosure, preservation, or external routing exceeds accepted product rule | `REQUIRES LATER FACT / FORMAL REVIEW`; `REQUIRES LATER LEGAL AUTHORITY` |

### Still Unknown / Requires Later Review

Accountable roles, staff, operations, separation of duties, capacity, service targets, and escalation ownership remain unresolved under U-11/U-12.

### 15.2 MVP Safety product-policy boundary

Minimum semantics required before affected MVP implementation may be separately authorized:

1. user block/self-protection without guilt inference;
2. report-submission semantics;
3. reversible, minimum-necessary immediate-protection boundary;
4. restricted Safety evidence/provenance handling;
5. no-guilt/no-person-truth case semantics;
6. minimum-necessary control directives;
7. correction/reversal propagation without reputation residue;
8. contest/appeal boundary for consequential reviewed decisions; and
9. prohibition on Safety-to-Compatibility/reputation leakage.

These minimum product semantics are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`. Actual affected implementation remains blocked until required U-06/U-11/U-12/legal/factual dependencies are accepted.

May be deferred: advanced evidence challenge, external-source handling, sophisticated notice choices, non-scoring review support, and external routing, provided MVP excludes dependent functions.

Must remain prohibited: Safety-derived romantic/public reputation; autonomous findings/triage/outcomes; covert surveillance; private-message mining; person scoring; automatic guilt; irreversible AI restrictions; ordinary-domain evidence leakage; speculative indefinite retention.

Must remain gated: reviewed findings, consequential/long-lived restrictions, evidence thresholds, repeat-pattern priority, external routing, exact retention, appeal procedure, anonymization verification, quality/capacity targets, and operations.

## 16. Owner Decision Packet

The Owner may select, revise, or defer each item independently. No recommendation is accepted until explicitly recorded.

1. **Safety taxonomy and case-state vocabulary**
   - A: use generic `report/action` labels only.
   - B: adopt sections 3 and 6 with explicit non-meanings and no person-truth inference.
   - C: defer all Safety semantics.
   - **Recommendation:** B.
   - **Rejection/exit conditions:** reject B if any term is treated as guilt, a technical workflow, or a closed evidentiary standard.
   - **Retained unknowns:** criteria, transitions, finding standard, authority, timing.

2. **Protection model**
   - A: protection only after final finding.
   - B: user-self protection plus reversible, minimum-necessary interim protection before adjudication under later accepted triggers/review/expiry.
   - C: automatic protection from any report/count/AI output.
   - **Recommendation:** B; A under-protects, C is overbroad and conflicts with accepted authority.
   - **Rejection/exit conditions:** stop if reversibility, minimum scope, review, expiry, and correction cannot be supported.
   - **Retained unknowns:** concrete triggers, duration, evidence threshold, responsibility, capacity.

3. **Evidence/provenance and finding force**
   - A: allow allegation/system observation/AI output to promote automatically.
   - B: adopt section 5; require separately accepted review authority and standard for findings.
   - C: prohibit any future reviewed finding.
   - **Recommendation:** B.
   - **Rejection/exit conditions:** reject any implementation that lacks source, bounded proposition, purpose, uncertainty, correction, and contest.
   - **Retained unknowns:** admissibility, evidence threshold, review standard, external evidence, legal authority.

4. **Review authority classes**
   - A: one undifferentiated moderation authority.
   - B: adopt the capability/decision classes in sections 7 and 15 without selecting staff or operations.
   - C: let AI own review decisions.
   - **Recommendation:** B; C is prohibited.
   - **Rejection/exit conditions:** revise if classes collapse self-protection, interim protection, finding, restriction, appeal, or external routing.
   - **Retained unknowns:** accountable roles, qualification, separation, capacity, SLA, failure ownership.

5. **AI and repeat-pattern boundary**
   - A: permit hidden Safety scoring/prioritization now.
   - B: keep Safety-only prioritization/risk `NOT DECIDED`; prohibit person scores and autonomous triage; route later assessment to U-06/U-11/U-12/legal review.
   - C: prohibit even bounded future advisory assistance.
   - **Recommendation:** B.
   - **Rejection/exit conditions:** reject any aid that gates outcomes, obscures uncertainty, becomes a person score, or leaks to ordinary domains.
   - **Retained unknowns:** necessity, fairness method, evidence, threshold, review, law, capacity.

6. **Control directives and reversal propagation**
   - A: send Safety evidence/reasoning to ordinary domains.
   - B: send only minimum-necessary control meaning and require correction/reversal of stale controls with no reputation residue.
   - C: prohibit Safety from constraining ordinary journeys.
   - **Recommendation:** B; A is prohibited and C conflicts with accepted Safety precedence.
   - **Rejection/exit conditions:** stop if evidence isolation or reliable reversal cannot be preserved.
   - **Retained unknowns:** responsibility, quality targets, propagation timing, failure handling.

7. **Appeal/notice boundary**
   - A: no contest for any consequential decision.
   - B: distinguish correction from appeal; make consequential reviewed restrictions contestable under later authority while protecting reporter/private/Safety information.
   - C: disclose full evidence and reporter identity by default.
   - **Recommendation:** B.
   - **Rejection/exit conditions:** revise if notice over-discloses or contest overrides user-self protection.
   - **Retained unknowns:** contestable set, procedure, timing, standard, reviewer, disclosure duty.

8. **Safety lifecycle/retention**
   - A: blanket indefinite Safety retention.
   - B: named purpose, shortest necessity, restricted access, review/expiry, termination, no ordinary reuse, separate de-identify/anonymize meanings.
   - C: universal immediate deletion.
   - **Recommendation:** B.
   - **Rejection/exit conditions:** reject unspecified purpose, speculative value, blanket exception, or conflated anonymization claim.
   - **Retained unknowns:** periods, backup, preservation law, deletion outcomes, access/export, anonymization verification.

9. **External routing boundary**
   - A: AI/case state routes externally automatically.
   - B: require separate legal/factual/product/operational authority before any external route.
   - C: promise external routing will never occur.
   - **Recommendation:** B; A is prohibited and C makes an unsupported universal promise.
   - **Rejection/exit conditions:** no design until jurisdiction, duty, trigger facts, authority, privacy, correction, availability, and failure ownership are established.
   - **Retained unknowns:** all duties, triggers, recipients, timing, procedures, capacity.

10. **MVP U-04 boundary and disposition**
   - A: accept the nine minimum product semantics in section 15.2 as a prerequisite for affected MVP scope; retain U-04 `BLOCKING` pending GPT L3/Owner decision and recorded closeout.
   - B: handle Safety conflicts ad hoc during implementation.
   - C: remove all affected Safety/report/protection scope from MVP.
   - **Recommendation:** A; reject B. C is viable only as explicit scope removal and does not negate user-self protection needs.
   - **Rejection/exit conditions:** stop affected MVP scope if required semantics or U-06/U-11/U-12/legal/factual dependencies are absent.
   - **Retained unknowns:** operations, implementation, thresholds, staffing, quality/capacity, fairness, legal duties.

## 17. Stop and review state

- U-04: `BLOCKING — NOT SILENTLY RESOLVED`.
- U-06, U-11, U-12, and every other separately unresolved `BLOCKING UNKNOWN`: unchanged.
- ADR-007 remains proposed.
- DeepSeek calls: `0`.
- No new legal research, real case/user data, Safety Operations, workforce/queue/SLA design, scoring/risk model, autonomous triage, external-routing implementation, LC-03, LC-04, Phase 36, processing, database/schema/API/backend/Flutter/service/event/queue/storage/infrastructure/code, or implementation is authorized or performed.

Stop for GPT L3 and Owner review of the numbered packet.
