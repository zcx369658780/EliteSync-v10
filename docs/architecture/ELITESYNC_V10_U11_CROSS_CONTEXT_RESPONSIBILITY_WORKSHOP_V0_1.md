# EliteSync 10.0 U-11 Cross-Context Responsibility Workshop V0.1

Status: `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`

Date: `2026-08-26`

Scope: Technology-neutral product-policy and responsibility semantics only. This document creates no processing, Safety Operations, implementation, technical architecture, staffing, or successor-work authority.

## 1. Authority and evidence discipline

### Observed / Accepted Authority

- The refinement order remains `Product Truth → Domain → Information → Architecture → Implementation`.
- ADR-004 accepts seven conceptual domains: Identity, Personality, Compatibility, Matching, Conversation, Relationship, and Safety. They are not automatically services, modules, stores, teams, or deployment units, and no domain owns the User as a whole.
- ADR-005 separates meaning, purpose, provenance, lifecycle, custody, and reconstruction authority. Technical availability or custody creates none of the others.
- ADR-006 accepts the five-dimensional shared-information authority model and conflict-aware lifecycle semantics. ADR-007 accepts the U-04 Safety-governance baseline and preserves all 28 Phase 34 Safety invariants.
- U-06 fairness and U-12 quality/capacity remain separately `BLOCKING`. U-11 itself remains `BLOCKING` until GPT L3 review, Owner decisions, and closeout.

### Prior Conceptual Exploration

The Quality Attribute Scenarios and Context Map workshop proposed context movements, restrictive-state precedence, and failure boundaries. It is input only where later accepted authority does not supersede it.

### Product Inference

Cross-context use is safe only when authority for meaning, purpose, decision, lifecycle, failure handling, and reconstruction stays attributable. A handoff transfers a bounded meaning for a named purpose; it does not transfer ownership of the source concept.

### Proposed Product Decision

Adopt the responsibility vocabulary, interaction contracts, precedence rules, propagation duties, reconstruction boundary, matrix, and MVP gate below as the U-11 product-policy baseline.

### Still Unknown / Requires Later Review

Exact legal duties, fairness methods, quality targets, operating capacity, reviewers, evidence thresholds, timing, retention periods, backup treatment, anonymization verification, and technical mechanisms remain unresolved.

## 2. Frozen upstream invariants

The proposal does not weaken these rules:

- user declaration is not objective truth; AI interpretation is not verified fact;
- Compatibility Hypothesis, Match, Connection, Conversation, and Relationship remain distinct;
- Matching cannot grant contact access; reciprocal choice is required for Connection;
- Conversation activity cannot infer Relationship state;
- Relationship Feedback cannot become public rating or silently redefine another User;
- Safety may constrain ordinary journeys, but Safety evidence cannot enter ordinary domains;
- only minimum-necessary Safety control directives may cross, and a directive is not evidence disclosure;
- case-processing state is not person truth;
- `actioned/protected` cannot collapse interim reversible protection with reviewed longer-lived restriction;
- correction, reversal, and supersession remove stale dependent ordinary effects when authority changes;
- retention is purpose-bound; `de-identify` and `anonymize` remain distinct;
- private Conversation is not default analytics or model-training input; and
- future Safety-only prioritization or risk assessment remains `NOT DECIDED`.

Dependency: `PROHIBITED BY ACCEPTED AUTHORITY` for every proposed weakening.

## 3. Responsibility vocabulary

### Observed / Accepted Authority

Owner is final product authority. Users retain authorship and relational choice within accepted boundaries. Source contexts retain source meaning; Safety retains restricted Safety meaning; custody does not confer authority.

### Prior Conceptual Exploration

Earlier context work named primary meaning authorities and safe responses but did not settle a complete responsibility grammar.

### Product Inference

One undifferentiated “owner” would collapse incompatible authorities and conceal failure responsibility.

### Proposed Product Decision

| Term | Technology-neutral meaning |
| --- | --- |
| Meaning authority | Defines what a product concept means and what it cannot mean. It remains with the accepted domain/user authority when a bounded meaning is consumed elsewhere. |
| Bounded decision authority | May decide one specified product question under accepted policy; it grants no wider truth, purpose, or lifecycle power. |
| Execution responsibility | Must carry out an already-authorized decision faithfully and fail safely; it cannot reinterpret or enlarge the decision. |
| Purpose-review authority | Determines whether a proposed cross-context use has an accepted named purpose, authority, minimum scope, and compatible constraints. Unknown compatibility stops use for review. |
| Lifecycle authority | May request and/or decide correction, withdrawal, expiry, deletion, retention, restriction, reversal, or supersession according to authorship, visibility, subject interest, custody purpose, and action-specific authority. |
| Failure ownership | Must ensure the safe product outcome and route unresolved conflict when a handoff is missing, stale, contradictory, duplicated, unauthorized, or partly applied. It does not imply blame or technical custody. |
| Reconstruction responsibility | Must make a consequential decision reviewable with minimum-necessary provenance, authority, time, policy, change, and restriction context without indiscriminate disclosure or retention. |
| Final product authority | Owner alone accepts, revises, rejects, or closes proposed policy. It cannot be inferred from custody, automation, AI output, or draft status. |

Each cross-context interaction has both a source failure owner for source validity and a receiving failure owner for authorized consumption. Where the boundary itself is disputed, use stops and purpose-review authority owns referral; Owner remains final authority.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; role qualifications and operating assignment are `REQUIRES LATER FACT / FORMAL REVIEW`.

### Still Unknown / Requires Later Review

Named personnel, teams, reviewer qualifications, separation of duties, capacity, timing, and tooling are not selected.

## 4. Cross-context interaction contracts

### Observed / Accepted Authority

Domain meanings, reciprocal Connection, private interaction, five-dimensional lifecycle authority, and Safety containment are accepted. A receiving context cannot infer broader authority from visibility or availability.

### Prior Conceptual Exploration

The earlier context map proposed ten movements and safe failure responses; it did not make them Owner-accepted U-11 policy.

### Product Inference

Every handoff needs a closed product contract: source meaning, permitted consumption, named purpose, minimum scope, prohibited inference, acceptance responsibility, lifecycle propagation, and failure-safe outcome.

### Proposed Product Decision

| # | Interaction and named purpose | Minimum permitted crossing and acceptance responsibility | Must not cross or be inferred | Propagation and failure-safe responsibility |
| --- | --- | --- | --- | --- |
| 1 | Identity → Personality, optional user-requested reflection | Current purpose-permitted declaration plus provenance; Personality accepts only for the requested reflection | diagnosis, destiny, fixed identity, unrelated Profile data | Identity declares correction/withdrawal; Personality invalidates dependent reflection. Missing/stale/unauthorized input means no new reflection. |
| 2 | Identity/Personality → Compatibility, bounded hypothesis formation | Only classified, permitted, time-relevant signals/reflections with provenance, uncertainty, and lifecycle state; Compatibility accepts eligibility | raw unrelated/private material, hidden sensitive inference, personality truth, human-worth meaning | Sources declare change; Compatibility identifies and withdraws stale hypotheses. Conflict or unknown authority stops that input/use. |
| 3 | Compatibility → Matching, explainable opportunity support | Minimum hypothesis/explanation meaning, uncertainty, freshness, and contest status; Matching accepts only under accepted eligibility/purpose | restricted raw evidence, guarantee, Safety clearance, universal score, consent | Compatibility owns hypothesis correction; Matching removes stale presentation/effect. Missing or contradictory authority means no affected presentation. |
| 4 | Matching → Relationship, reciprocal Connection formation | A bounded opportunity plus two independent valid choices; Relationship alone recognizes Connection meaning | automatic contact, affection, Relationship state, permanent consent | Matching owns opportunity validity; Relationship owns Connection validity. Absent, stale, or contradictory reciprocal choice means no Connection. |
| 5 | Relationship → Conversation, valid reciprocal access | Minimum valid-Connection/access meaning and current restrictions; Conversation accepts and enforces only communication availability | Relationship interpretation, affection, unrestricted history, contact authority beyond current scope | Relationship declares closure/revocation; Conversation removes future access. Unknown/stale authority does not create permission. |
| 6 | Conversation/Relationship Feedback → allowed ordinary consumers, user-chosen reflection/correction/pacing only | Purpose-classified, minimized user-authored meaning or occurrence where expressly permitted; each receiver purpose-reviews acceptance | default message content, private-message mining, public ratings, another User rewrite, unified desirability signal | Origin records correction/withdrawal; receiver removes stale effects. Ambiguous purpose means keep private or omit. |
| 7 | Ordinary context → Safety, concern/report handling | Minimized relevant concern, provenance, context, and requested protective action; Safety accepts into restricted handling | romantic inference, guilt, verified misconduct, public reputation, general ordinary-domain reuse | Origin preserves source provenance; Safety owns restricted case meaning. Missing detail stays unknown and cannot block self-protection that accepted policy permits. |
| 8 | Safety → Matching/Relationship/Conversation, minimum-necessary control | Only current control meaning, affected scope, authority class, lifecycle/reversal status, and what ordinary execution must stop/allow; ordinary receivers enforce | allegation, evidence, reasoning, person score, guilt, case narrative, reporter identity except separately authorized | Safety authorizes/reverses directive; each receiver removes/replaces stale control. Unverifiable, stale, or malformed control fails restrictive and routes for authorized review without evidence access. |
| 9 | Any source → dependent ordinary context, correction/reversal/supersession cleanup | Source-change identity, authority, effective scope, and affected meaning; receiver identifies affected active outputs | broader content than needed, silent truth promotion, retroactive rewriting of human history | Source declares change; each dependent meaning authority invalidates/withdraws stale effect and decides if new use is permitted. Partial propagation keeps affected value stopped. |
| 10 | User-rights/lifecycle request → multiple contexts, bounded request fulfillment | Request identity, action semantics, affected purpose/scope, five-dimensional interests, and decided exceptions; each context applies only its authorized part | universal “owner” assumption, impossible erasure promise, Safety evidence, another person's independent authorship | Coordinating purpose-review responsibility ensures complete disposition without acquiring domain truth. Unresolved conflicts stop the affected optional use and route to later formal review. |

Dependencies: core semantics are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; concrete contested disclosure/retention is `REQUIRES LATER FACT / FORMAL REVIEW` and may be `REQUIRES LATER LEGAL AUTHORITY`; fairness-sensitive consumption `DEPENDS ON U-06 FAIRNESS`; measurable execution acceptance `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Exact data fields, interfaces, delivery mechanisms, timing, review roles, retention, legal exceptions, and operational recovery are outside this decision.

## 5. Connection authority

### Observed / Accepted Authority

Relationship owns Connection meaning. Matching presents opportunities only; reciprocal user choice is required. Conversation depends on valid Connection or other separately accepted authority. Closure, revocation, block, or Safety restriction may stop future access without rewriting human history.

### Prior Conceptual Exploration

Earlier work proposed this division but left exact interaction responsibility unresolved.

### Product Inference

Connection is an authorized reciprocal product state, not a prediction, delivery result, message activity, or inferred affection.

### Proposed Product Decision

- Matching may know whether an opportunity is currently presentable, not whether a Relationship exists.
- Relationship may recognize only the minimum reciprocal choices and governing restrictions required for Connection; it may not infer affection, permanence, or off-product meaning.
- Conversation may know only whether current communication access is permitted and why a bounded control applies; it must not infer Connection history into Relationship truth.
- Safety may direct minimum-necessary access control but does not own Connection's relational meaning.
- Ending future access preserves provenance that an interaction occurred where retention remains authorized; it does not preserve unauthorized active access or recast closure as wrongdoing.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; timing and evidence targets `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Exact choice-expiry, reconnection, notification, evidence depth, and legally required retention remain unresolved.

## 6. Purpose-review boundary

### Observed / Accepted Authority

Purpose limitation, provenance, minimum necessity, time relevance, lifecycle authority, and no unrelated reuse are accepted.

### Prior Conceptual Exploration

The context map proposed stopping unclear new purposes rather than allowing convenience-based reuse.

### Product Inference

A receiving context needs affirmative consumption authority; absence of a prohibition is not permission.

### Proposed Product Decision

Before cross-context use, the receiver must establish: named purpose; source provenance; accepted consumption authority; minimum-necessary scope; time relevance/freshness; current lifecycle status; and no unrelated reuse. Unclear purpose compatibility, contradictory authority, or missing lifecycle status stops the proposed use and routes it to purpose review. “Available in storage,” “already visible,” operational convenience, broad consent, or prior use is never sufficient authority.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; novel legal compatibility `REQUIRES LATER LEGAL AUTHORITY`; evidentiary sufficiency `REQUIRES LATER FACT / FORMAL REVIEW`.

### Still Unknown / Requires Later Review

The exact purpose catalog, formal reviewer qualifications, evidence threshold, and legal compatibility tests remain unresolved.

## 7. Cross-context failure taxonomy

### Observed / Accepted Authority

Correct cessation and denial are valid product outcomes. Unknown or stale authority cannot create permission. Privacy, Safety, and User Control constrain ordinary value.

### Prior Conceptual Exploration

Earlier scenarios identified stale state, partial failure, and reconstruction gaps without accepting an exhaustive taxonomy.

### Product Inference

Failure ownership should attach to the meaning at risk, not to technical custody or delivery success.

### Proposed Product Decision

| Failure class | Safe product outcome | Owning responsibility class |
| --- | --- | --- |
| Stale authority/state | Stop affected new use/access or apply the current known restrictive state; seek current authority | source lifecycle authority + receiving failure owner |
| Missing handoff | Do not invent permission or meaning; omit/deny affected value | receiving failure owner; source verifies whether authority exists |
| Contradictory state | Apply the more restrictive effective state; preserve distinct causes; route conflict | relevant meaning/lifecycle authorities + purpose review |
| Duplicate/replayed meaning | No duplicate semantic effect; verify current authority and provenance | receiving execution/failure responsibility |
| Unauthorized purpose expansion | Stop new use and preserve evidence of the attempted boundary decision | purpose-review authority |
| Partial propagation | Keep affected dependent value stopped until all required meanings have a trustworthy disposition | source lifecycle authority + every dependent failure owner |
| Late correction/reversal | Remove stale active effect promptly; preserve provenance without treating delay as continuing authority | source change authority + dependent lifecycle/failure owners |
| Unavailable responsibility owner | Do not transfer authority to custody, AI, or an adjacent context; stop and escalate to Owner/formal review | purpose-review boundary; Owner final authority |
| Reconstruction gap | Do not claim the consequential outcome trustworthy or resolved; limit continued effect as later policy requires | reconstruction responsibility + relevant decision authority |
| Privacy/Safety boundary leak | Stop affected use/disclosure, contain ordinary-domain effect, and route for authorized review without wider repetition | source boundary authority + receiving failure owner |

Dependencies: taxonomy and fail-safe rules are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; response targets and capacity `DEPENDS ON U-12 QUALITY / CAPACITY`; incident/legal obligations `REQUIRES LATER LEGAL AUTHORITY` and `REQUIRES LATER FACT / FORMAL REVIEW`.

### Still Unknown / Requires Later Review

Severity, timing, operational response, technical detection, and legal notification are not selected.

## 8. Restrictive-state precedence

### Observed / Accepted Authority

Effective block, closure, revocation, pause, lifecycle restriction, or Safety control may require ordinary value to stop. Accepted Safety policy distinguishes self-protection, interim protection, and reviewed restriction.

### Prior Conceptual Exploration

Earlier quality scenarios proposed that restrictive state governs during partial failure.

### Product Inference

Precedence is purpose- and scope-specific, not a universal ranking of people or accounts.

### Proposed Product Decision

For the affected purpose and scope, apply the current effective state that permits the least new access/use until authorized review resolves conflict:

1. a user-self protective action controls that User's future exposure/access without adjudicating another person;
2. ordinary pause, closure, revocation, deletion, or restriction stops only the governed future use/effect;
3. Safety interim protection is reversible, minimum necessary, and not guilt, punishment, or finding;
4. reviewed longer-lived Safety restriction remains distinct and requires its accepted authority;
5. stale or unknown authority creates no new permission and routes to review.

Distinct causes must remain distinguishable; they must not collapse into a generic account status. Correction or reversal removes stale controls and adverse/reputation residue without implying reporter dishonesty or allegation falsity.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; exact triggers/durations and evidence standards `REQUIRES LATER FACT / FORMAL REVIEW`; measurable cessation `DEPENDS ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Trigger thresholds, durations, finding/evidence standards, notices, appeals, and timing remain unresolved.

## 9. Change propagation ownership

### Observed / Accepted Authority

Corrections preserve provenance; revocation stops future optional use; reversal/supersession removes stale ordinary effects; history cannot justify unauthorized active effect.

### Prior Conceptual Exploration

Prior work required affected outputs to be withdrawn, invalidated, refreshed, or handled under a narrowly approved exception.

### Product Inference

The source cannot alone know every dependent product meaning, and the consumer cannot redefine the source change. Responsibility must be joint but non-collapsing.

### Proposed Product Decision

- Source meaning/lifecycle authority declares the change, effective scope, provenance, and governing authority.
- Every consuming meaning authority identifies its dependent meanings and invalidates or withdraws stale active output.
- The receiving purpose authority decides whether recomputation or renewed consumption is permitted; correction never automatically authorizes reuse.
- Safety owns authorization/reversal of its directive; ordinary consumers own removal/replacement of its stale enforcement effect.
- Reconstruction responsibility preserves minimum-necessary history and distinguishes prior valid action from current authority.
- Unresolved conflicts stop affected optional use and route to formal review.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; completion targets `DEPENDS ON U-12 QUALITY / CAPACITY`; retention/exceptions may be `REQUIRES LATER LEGAL AUTHORITY`.

### Still Unknown / Requires Later Review

Exact dependency inventories, timing, review evidence, backups, and technical propagation are unresolved.

## 10. Safety-to-ordinary responsibility boundary

### Observed / Accepted Authority

ADR-007 controls. Safety evidence remains restricted; ordinary domains receive only minimum-necessary control meaning. AI is advisory only, and case state is not person truth.

### Prior Conceptual Exploration

The context map showed protective directions crossing while evidence flow to ordinary Ranking/reputation was forbidden.

### Product Inference

Ordinary contexts can enforce a control without learning or evaluating its allegation, evidence, reasoning, or finding basis.

### Proposed Product Decision

Safety meaning/decision authority generates or authorizes the directive and its authority class, scope, current lifecycle, and reversal meaning. Matching, Relationship, and Conversation consume only the enforcement meaning needed for their product action, refuse evidence/reasoning leakage, and cannot reinterpret the directive as guilt or person quality. Safety declares correction/reversal/supersession; each ordinary receiver removes stale controls and residue. Authorized reconstruction joins restricted Safety-side evidence with ordinary execution evidence only within review, without disclosing protected Safety content to ordinary contexts.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; concrete Safety operations `REQUIRES LATER FACT / FORMAL REVIEW`; legal/external duties `REQUIRES LATER LEGAL AUTHORITY`; Safety scoring or evidence leakage is `PROHIBITED BY ACCEPTED AUTHORITY`.

### Still Unknown / Requires Later Review

Safety Operations, reviewer authority, evidence standard, thresholds, duration, external routing, retention, and appeal procedure remain unresolved.

## 11. Review and reconstruction contract

### Observed / Accepted Authority

Consequential uses must be reconstructable without broad access or indefinite retention. Declarations, observations, interpretations, AI language, findings, and case states remain distinct.

### Prior Conceptual Exploration

The auditability scenario proposed reconstructing contested outputs under minimum-necessary exposure.

### Product Inference

Reconstruction is a bounded product obligation, not a license to aggregate all private or Safety information.

### Proposed Product Decision

For Compatibility explanations, Match presentation/eligibility, Connection/Conversation access changes, lifecycle restrictions, Safety directives/restrictions, and corrections/reversals, authorized review must be able to distinguish: source and provenance; declaration/observation/interpretation/AI language; named purpose; policy/version context; time relevance; bounded decision authority; lifecycle changes; restrictions; consuming action; and available contest/correction route. Each context supplies only its minimum necessary review slice. The reviewing function may correlate those slices for the accepted review purpose but does not acquire their domain meaning or future reuse authority.

Dependencies: contract semantics are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; exact evidence, access, retention, reviewer and timing are `REQUIRES LATER FACT / FORMAL REVIEW`, may `REQUIRE LATER LEGAL AUTHORITY`, and targets `DEPEND ON U-12 QUALITY / CAPACITY`.

### Still Unknown / Requires Later Review

Logs, storage, access roles, retention, review SLA, tooling, reviewer qualification, and evidentiary sufficiency remain unresolved.

## 12. AI and analytics boundary

### Observed / Accepted Authority

AI and analytics are supporting capabilities, not domain-truth owners. Private Conversation and Safety evidence restrictions remain controlling.

### Prior Conceptual Exploration

Earlier work allowed bounded assistance/measurement only under consuming-context authority and separate purpose review.

### Product Inference

Generated or aggregated output cannot bootstrap authority that its inputs and purpose lack.

### Proposed Product Decision

AI may consume only explicitly permitted minimum context for a named purpose and remains labeled, uncertain, correctable, and subordinate to the consuming domain. It cannot create consent, truth, guilt, Connection, Relationship state, Safety finding, or cross-context authority. Analytics cannot silently create domain truth or new Ranking, Compatibility, Safety, reputation, trustworthiness, or relationship-worth signals. Any future new purpose stops for separate review. Private-interaction or Safety evidence use remains forbidden unless separately accepted authority explicitly permits the precise purpose; no such authority is created here.

Dependencies: `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; fairness-sensitive use `DEPENDS ON U-06 FAIRNESS`; evaluation targets `DEPENDS ON U-12 QUALITY / CAPACITY`; prohibited truth/authority creation is `PROHIBITED BY ACCEPTED AUTHORITY`.

### Still Unknown / Requires Later Review

Permitted future analytics purposes, fairness method, quality evidence, model selection, and implementation remain unresolved.

## 13. Seven-domain responsibility matrix

This is a product-semantics matrix, not an org RACI or technical decomposition.

| Domain/capability | Meaning and initiating authority | Permitted consumers | Lifecycle/failure/reconstruction responsibility | Prohibited inference/reuse | Dependencies |
| --- | --- | --- | --- | --- | --- |
| Identity | User-authored Identity/Profile meaning; User initiates corrections/visibility choices | Personality, Compatibility, other expressly authorized contexts | Identity declares source lifecycle; consumers remove stale effects; bounded provenance supports review | objective truth, diagnosis, consent for another, Safety finding | later legal/factual rights detail |
| Personality | Optional correctable reflection meaning; User controls acceptance/dismissal | Compatibility only where purpose-permitted; User reflection | Personality owns reflection freshness and withdrawal; consumers cannot promote it | diagnosis, destiny, fixed identity, human-worth Ranking | U-06 for fairness-sensitive use |
| Compatibility | Hypothesis, uncertainty, explanation, contest lifecycle | Matching; User-facing bounded explanation | Compatibility withdraws stale hypotheses and reconstructs permitted evidence/interpretation split | truth, guarantee, Safety clearance, consent, universal score | U-06; U-12 evidence/targets |
| Matching | Bounded opportunity, eligibility/pacing under accepted policy | Relationship receives only valid opportunity/choices | Matching owns opportunity lifecycle and stale presentation failure | Connection, Conversation, affection, worth, permanent access | U-06; U-12 |
| Relationship | Connection meaning, user-declared progression/closure, classified feedback | Conversation access; expressly allowed bounded consumers | Relationship owns Connection lifecycle; consumers remove access/stale feedback effects | activity-based relationship inference, public rating, Safety finding | shared conflicts; legal/factual review |
| Conversation | Private communication context and interaction occurrence under valid access | Users; bounded requested assistance; Safety route when invoked/authorized | Conversation enforces current access, protects private boundary, supplies minimum review slice | Relationship state, affection, default analytics/training, report adjudication | U-12; legal/privacy review |
| Safety | Concern, allegation, observation, evidence, case state, protection, finding/restriction classes under ADR-007 | Ordinary domains receive directives only; authorized review gets restricted slice | Safety owns directive lifecycle/reversal; ordinary receivers own enforcement cleanup | Compatibility, desirability, guilt by case state, public reputation, person scoring | Safety Operations, legal, U-12; risk remains undecided |
| Purpose review | Compatibility of named cross-context use; no domain truth | Allows/denies bounded receiving use | Owns stop/referral when purpose authority is unclear; reconstructs decision basis | availability-as-authority, broad-purpose expansion | formal/legal review where required |
| AI/analytics | Supporting output/measurement under consuming authority | Named purpose only | Consumer owns outcome; source/consumer retain lifecycle and review duties | truth, consent, guilt, Connection, new domain authority/signals | U-06, U-12; later explicit purpose |
| Owner | Final product decision/acceptance | All policy proposals through governance | Final acceptance, revision, rejection, closeout | authority inferred from silence, custody, draft, or automation | qualified evidence/review as applicable |

### Evidence labels for the matrix

- **Observed / Accepted Authority:** the domain separations and upstream prohibitions.
- **Prior Conceptual Exploration:** supporting capabilities and context movements in the prior workshop.
- **Product Inference:** assigning non-collapsing responsibility classes to each meaning.
- **Proposed Product Decision:** adopt the matrix as the U-11 responsibility baseline.
- **Still Unknown / Requires Later Review:** operational assignments, technical components, targets, fairness/legal determinations, and evidence thresholds.

## 14. Affected-MVP responsibility gate

### Observed / Accepted Authority

Implementation is not authorized; accepted upstream policy already requires the affected semantics not to be improvised later.

### Prior Conceptual Exploration

Earlier work identified context interaction and failure ownership as blockers but did not define a minimum gate.

### Product Inference

An affected MVP cannot safely defer responsibility for who may create, consume, stop, correct, or reconstruct cross-context meaning.

### Proposed Product Decision

Before any affected MVP implementation is separately authorized, Owner-accepted semantics must cover:

1. Compatibility → Matching handoff;
2. reciprocal Connection authority;
3. Relationship → Conversation access;
4. lifecycle correction/revocation propagation;
5. block/closure/restrictive-state precedence;
6. Safety minimum-necessary directives;
7. correction/reversal cleanup;
8. contest/reconstruction responsibility; and
9. cross-context purpose review.

May be deferred: advanced cross-context explanations, automated conflict suggestions, configurable review views, and optional analytics, provided deferral removes the affected promise/use rather than hiding an unresolved responsibility.

Remain prohibited: automatic Connection or Relationship inference; private-message mining; Safety evidence leakage; public/person reputation or desirability scoring; AI truth/guilt/consent authority; purpose expansion by availability; and generic state collapse.

Remain gated: fairness-sensitive purposes by U-06; measurable quality, capacity, timing, and acceptance by U-12; contested disclosure/retention, legal preservation, and external routing by later factual/legal authority; Safety Operations and all implementation/processing by separate authorization.

Dependencies: minimum semantics are `PRODUCT RULE CAN BE OWNER-DECIDED NOW`; the retained items carry the classifications stated above.

### Still Unknown / Requires Later Review

Whether Owner accepts the gate, whether affected scope stays in MVP, and all technical/operational realization remain unresolved.

## 15. Owner Decision Packet

For each item, choosing B retains U-11 as blocking for that item. No choice authorizes implementation or processing.

1. **Responsibility grammar.** A: accept the eight-term non-collapsing vocabulary and dual source/receiver failure ownership (**recommended**). B: retain U-11 blocking. Reject/exit A if a term transfers source meaning through custody or obscures final Owner authority. Unknowns: operational assignment and qualifications.
2. **Ten interaction contracts.** A: accept the closed handoff semantics in Section 4 (**recommended**). B: remove affected interactions from MVP pending later policy. Reject/exit A if any handoff requires prohibited inference or cannot fail closed. Unknowns: technical mechanism, timing, legal exceptions.
3. **Connection authority.** A: accept Relationship meaning authority, reciprocal choice, and bounded access knowledge (**recommended**). B: omit Connection/Conversation progression from affected MVP. Reject/exit A if Matching or activity can create Connection/Relationship meaning. Unknowns: expiry/reconnection details.
4. **Purpose-review boundary.** A: require affirmative named-purpose authority and stop unknown compatibility (**recommended**). B: prohibit all cross-context reuse beyond already accepted cases. Reject/exit A if storage/visibility can count as authority. Unknowns: purpose catalog and reviewer standard.
5. **Failure taxonomy and restrictive precedence.** A: accept the taxonomy and least-permissive affected outcome while preserving distinct causes (**recommended**). B: retain affected journeys blocked. Reject/exit A if “fail safe” becomes guilt, punishment, or a generic person/account state. Unknowns: severity, timing, capacity.
6. **Change propagation ownership.** A: accept joint source-declaration/consumer-cleanup responsibility and separate renewed-use review (**recommended**). B: omit derived/cross-context uses that cannot satisfy it. Reject/exit A if provenance retention preserves unauthorized active effect. Unknowns: dependency evidence and legal retention.
7. **Safety-to-ordinary boundary.** A: accept directive-only crossing, ordinary enforcement responsibility, and reversal cleanup (**recommended**). B: stop the affected ordinary function when a safe directive-only contract cannot be maintained. Reject/exit A if evidence/reasoning or person judgment enters ordinary domains. Unknowns: Safety Operations, thresholds, review authority.
8. **Reconstruction contract.** A: accept bounded multi-context reconstruction without authority transfer (**recommended**). B: exclude consequential functions that cannot later meet the contract. Reject/exit A if it requires broad access or indefinite retention. Unknowns: evidence depth, roles, retention, timing.
9. **AI/analytics boundary.** A: accept supporting-only, named-purpose, no-new-authority rules (**recommended**). B: exclude AI/analytics from cross-context uses. Reject/exit A if outputs create truth, consent, guilt, Connection, Relationship, or new signals by convenience. Unknowns: U-06/U-12 and future purpose evidence.
10. **Affected-MVP gate and U-11 disposition.** A: accept the nine minimum semantics as the affected-MVP product-policy gate, then retain U-11 `BLOCKING` pending GPT L3/Owner closeout (**recommended**). B: keep U-11 blocking and remove affected MVP scope. Reject/exit A if any prerequisite is deferred while its affected product promise remains. Unknowns: all U-06/U-12/legal/factual/operational and implementation dependencies.

## 16. Stop state

U-11 remains `BLOCKING`. ADR-008 remains proposed. DeepSeek calls: `0`. No U-06, U-12, LC-03, LC-04, Phase 36, Safety Operations, processing, technical architecture, or implementation work is authorized or inferred. Stop for GPT L3 and Owner review.
