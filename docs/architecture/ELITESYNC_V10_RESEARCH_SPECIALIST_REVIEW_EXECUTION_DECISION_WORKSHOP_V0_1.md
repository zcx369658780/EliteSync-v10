# EliteSync 10.0 Research/Specialist Review Execution Decision Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `e712b55ff9599aedfaf9218fd137fb16837d4cbd` before this documentation workshop.

Scope: Prepare bounded Owner authorization decisions for possible future specialist review execution. This workshop does not authorize or execute research, contact a specialist, collect or process data, commission external work, change an `UNKNOWN` disposition, or create technical design or implementation artifacts.

## 0. Purpose and authority boundary

Phase 16 classified `U-01` through `U-15` as `BLOCKING` because the repository contains prepared questions and package structures but no qualified specialist findings, participant evidence, Owner-authorized assumptions, or explicit scope exclusions. Phase 17 identifies which review packages could be presented for a later Owner authorization decision.

```text
Product Truth
→ Domain
→ Information
→ Architecture
```

Specialist evidence may constrain this chain. It cannot enter technical design or Implementation.

### Non-transitive authority rule

- Phase 13 authorizes bounded Research/Specialist prerequisite preparation; it does not automatically authorize external engagement, participant activity, data access, or every method described in a package.
- A candidate in this document is not an authorization.
- GPT L3 review is not Owner authorization.
- Owner authorization of one exact package does not authorize another package, a participant protocol, data collection, production access, a design track, or implementation.
- A specialist finding does not by itself change OD/ADR status, a Phase 11 gate, or an `UNKNOWN` disposition.

## 1. Classification vocabulary

| Classification | Meaning in Phase 17 |
| --- | --- |
| `SPECIALIST REVIEW CANDIDATE` | A bounded non-participant expert review package can be proposed for separate Owner authorization |
| `OWNER DECISION REQUIRED` | Owner must accept, revise, reject, or defer an exact authorization packet or later disposition; Codex and a specialist cannot substitute |
| `RESEARCH PLANNING REQUIRED` | Additional method, population, institution, ethics, consent, data, or evidence planning is required before any research execution decision |
| `REMAIN BLOCKED` | No current evidence or authorization supports resolution, exclusion, bounded assumption, research execution, technical design, or implementation |

Classifications may coexist. Every `UNKNOWN` remains `BLOCKING` until an authorized evidence process completes and GPT L3 and Owner disposition are recorded.

## 2. BLOCKING UNKNOWN classification

| UNKNOWN | Specialist review candidate | Owner decision required | Research planning required | Current result |
| --- | --- | --- | --- | --- |
| U-01 | Yes — Privacy/legal and research-method review | Yes — applicable bounded authority and later disposition | Yes — jurisdiction, launch population, purpose, institution, and source plan | `REMAIN BLOCKED` |
| U-02 | Yes — Privacy/legal, supported by operations/human review | Yes — shared-right responsibility boundary | No participant research is currently required; refine only if specialist review identifies an empirical dependency | `REMAIN BLOCKED` |
| U-03 | Yes — Privacy/legal, Safety/moderation, and operations/human review | Yes — lifecycle semantics and bounded exceptions | Yes where comprehension, institution, consent, or empirical effects become material | `REMAIN BLOCKED` |
| U-04 | Yes — Safety/moderation and operations/human review, with privacy/legal | Yes — protection, review, recourse, and accountability boundary | Yes before any real-case, participant, operational, or data-dependent evaluation | `REMAIN BLOCKED` |
| U-05 | Yes — Privacy/legal, research-method, and applicable ethics/institutional review preparation | Yes — any later participant/data activity requires an exact separate authorization | Yes — protocol, population, institution, consent, data/security, risk, and withdrawal boundaries | `REMAIN BLOCKED` |
| U-06 | Yes — Fairness and research methodology | Yes — harms, obligations, remedies, and stop rules | Yes before any group-data, sensitive-attribute, participant, model, or measurement activity | `REMAIN BLOCKED` |
| U-07 | Yes — Research methodology and fairness | Yes — evidence standard and permitted/prohibited use boundary | Yes where item validation, population transfer, comprehension, or data would be required | `REMAIN BLOCKED` |
| U-08 | Not yet an execution candidate; user-research planning package only | Yes — later protocol authorization and product disposition | Yes — launch segment, inclusion, ethics, sampling, consent, and method | `REMAIN BLOCKED` |
| U-09 | Yes — Research methodology and privacy/legal; user-research planning may follow | Yes — construct, purpose, and measurement boundary | Yes before any participant or private-interaction evidence activity | `REMAIN BLOCKED` |
| U-10 | Yes — Accessibility concept review; user-research planning remains separate | Yes — requirements and later protocol authorization | Yes — population, comprehension, accessibility, ethics, and method | `REMAIN BLOCKED` |
| U-11 | Yes — Operations/human review, Safety/moderation, and privacy/legal | Yes — accountable responsibility boundary | No participant research is currently required; planning is added only if evidence demands it | `REMAIN BLOCKED` |
| U-12 | Yes — coordinated review across all seven specialist areas | Yes — mandatory scenarios, target authority, evidence, remedies, and stop rules | Yes where a target depends on user, population, operational, accessibility, or empirical evidence | `REMAIN BLOCKED` |
| U-13 | Not yet an execution candidate; user-research/accessibility planning package only | Yes — pacing/state boundary or explicit scope exclusion | Yes — user evidence, accessibility, non-manipulation, ethics, and method | `REMAIN BLOCKED` |
| U-14 | Yes — Privacy/legal, fairness, and research methodology | Yes — explicitly exclude/reject the purpose or authorize a narrowly supported later review | Yes before any private-interaction, analytics, model, participant, or data activity | `REMAIN BLOCKED` |
| U-15 | No — technical facts and choices are outside the authorized Research/Specialist track | Yes — only for a future separately bounded track decision after prerequisites | Yes only as future technical discovery planning under separate authorization, not Phase 17 research execution | `REMAIN BLOCKED` |

### Classification summary

- Specialist review candidates: U-01 through U-07 and U-09 through U-12 and U-14, within the exact candidate packages below.
- Research-planning-first items: U-05, U-08, U-09, U-10, U-12, U-13, U-14, plus bounded planning dependencies stated for U-01, U-03, U-04, U-06, and U-07.
- Owner decision required: U-01 through U-15.
- Remain blocked: U-01 through U-15.

The summary does not claim that every specialist role must be engaged at once or that a review will resolve an item.

## 3. Common authorization contract

Before any candidate below can execute, an Owner authorization record must state:

```text
Authorization ID:
Owner outcome: accepted | revised | rejected | deferred
Authoritative GitHub main SHA:
Exact UNKNOWN IDs and bounded questions:
Named specialist role and competence:
Jurisdiction / institution / population / purpose:
Allowed activity:
Forbidden activity:
Information and access class:
Required sources and provenance:
Expected artifact:
Cost / commissioning / communication authority:
Privacy / ethics / consent prerequisites:
Reviewer and acceptance authority:
Expiry and revisit trigger:
Stop condition:
Downstream decisions informed:
Design authority: NONE
Implementation authority: NONE
```

Blank, `UNKNOWN`, or inferred fields do not grant authority. In particular, no candidate permits contact, commissioning, credential use, restricted-system access, or transfer of repository/private information unless the Owner explicitly authorizes that exact action and boundary.

## 4. Candidate SRX-PL-01 — Privacy/legal review execution

- **UNKNOWN IDs:** U-01, U-02, U-03, and U-14; may identify constraints relevant to U-05, U-09, U-10, and U-11 without resolving them.
- **Reason for review:** Applicable authority, shared-information rights, lifecycle exceptions, and private-interaction secondary use cannot be inferred from accepted architecture principles.
- **Required authority:** Owner acceptance of an exact jurisdiction-, population-, purpose-, source-, and reviewer-bounded packet; separate approval for any external contact, commissioning, confidential disclosure, or restricted source.
- **Allowed activity if authorized:** A named qualified reviewer examines supplied conceptual questions and current official sources; records applicable, not-applicable, conflicting, and unresolved constraints; maps findings to accepted OD/ADR language.
- **Forbidden activity:** Legal advice by Codex; compliance declaration; participant contact; personal/Safety/private-interaction data access; production access; drafting schema, API, Backend, Flutter, implementation, migration, or deployment artifacts.
- **Required evidence:** Current official authority with locator/version/check date; reviewer identity, competence, jurisdiction and authority limit; exact purpose and population; issue-by-issue reasoning; limitations, conflicts, dissent, expiry, and decision-reversing evidence.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — PRIVACY/LEGAL — NOT AN OWNER DECISION`, plus evidence summary and proposed `UNKNOWN` impact.
- **Stop condition:** Missing or changing jurisdiction/population/purpose; unverified source; question exceeds reviewer competence; personal/restricted data or external action becomes necessary; a legal conclusion cannot be supported; scope enters design or implementation.
- **Owner decision impact:** May support a later Owner disposition for U-01/U-02/U-03/U-14 and constraints on P-03 through P-05; it does not change them automatically.

## 5. Candidate SRX-SM-01 — Safety/moderation review execution

- **UNKNOWN IDs:** U-03, U-04, U-11, and U-12.
- **Reason for review:** Protection, allegation, restriction, finding, review, recourse, retention, notification, repeat-pattern, and external-routing responsibilities remain unresolved.
- **Required authority:** Owner acceptance of bounded conceptual scenarios, named qualified Safety/moderation reviewer, applicable jurisdiction/product scope, and explicit no-case/no-data boundary.
- **Allowed activity if authorized:** Review hypothetical conceptual scenarios; distinguish immediate protection, allegation, evidence, finding, remedy, appeal, closure, and accountability; state options, limitations, and unresolved duties.
- **Forbidden activity:** Real-case review; emergency judgment; moderation action; guilt finding; risk scoring of a person; specialist or participant contact beyond separately authorized engagement; Safety data access; autonomous AI authority; design or implementation.
- **Required evidence:** Qualified specialist reasoning; current official/authoritative sources where applicable; harm-aware scenario analysis; false-positive/false-negative and recourse analysis; role and capacity constraints; provenance and scope limits.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — SAFETY/MODERATION — CONCEPTUAL ONLY`, with responsibility options, evidence gaps, and proposed `UNKNOWN` impact.
- **Stop condition:** A real person/case, emergency, report, allegation, restricted information, operational action, external routing, or jurisdictional determination requires authority not supplied.
- **Owner decision impact:** May support later decisions on U-03/U-04/U-11/U-12, Safety responsibility, and P-03 through P-05; cannot turn Safety information into Ranking, reputation, or guilt authority.

## 6. Candidate SRX-FA-01 — Fairness review execution

- **UNKNOWN IDs:** U-06, U-07, U-12, and U-14.
- **Reason for review:** Purpose-specific harms, proxies, missingness, feedback loops, evaluation choices, remedies, and the risk of measurement itself are not established.
- **Required authority:** Owner acceptance of exact purposes, non-data conceptual scope, named fairness specialist, population limits, and source standard.
- **Allowed activity if authorized:** Review conceptual harm models and candidate evaluation approaches; identify evidence requirements, transfer limits, conflicts, remedies, and stop-rule options without analyzing people or model outputs.
- **Forbidden activity:** Collecting or inferring protected/sensitive attributes; group profiling; dataset/model/signal analysis; selecting a universal fairness score or threshold; certifying fairness; design or implementation.
- **Required evidence:** Purpose-specific harm analysis; authoritative or peer-reviewed sources with population/transfer limits; methodological alternatives; measurement risks; residual uncertainty and decision-reversing evidence.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — FAIRNESS — NO CERTIFICATION`, with harm/proxy/missingness register and Owner options.
- **Stop condition:** Review requires unauthorized data, sensitive inference, a population assumption, model output, participant activity, or an unsupported numeric threshold.
- **Owner decision impact:** May support later dispositions for U-06/U-07/U-12/U-14 and P-03 through P-05; no finding approves a signal, model, data collection, or design.

## 7. Candidate SRX-RM-01 — Research-methodology review execution

- **UNKNOWN IDs:** U-01, U-05, U-06, U-07, U-09, U-12, and U-14.
- **Reason for review:** Claim strength, source quality, construct definition, transfer, validity, missingness, minimum evidence, uncertainty, and stop rules require a coherent method review before later evidence is interpreted.
- **Required authority:** Owner acceptance of bounded questions and source-review activity; named research-method specialist; explicit no-data/no-participant/no-model boundary.
- **Allowed activity if authorized:** Review source and method standards; distinguish exploratory, descriptive, predictive, causal, and confirmatory claims; propose evidence-quality and non-inference rules.
- **Forbidden activity:** Dataset access; participant execution; statistical analysis of user/private/Safety data; creation of a score, weighting, model, signal allowlist, experiment, or accepted numeric target; design or implementation.
- **Required evidence:** Direct or systematic sources suited to each claim; construct/estimand and population; validity threats; transfer and recency limits; correction/retraction status; dissent and evidence-strength mapping.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — RESEARCH METHODOLOGY`, with claim-strength rules, validity threats, evidence gaps, and proposed stop conditions.
- **Stop condition:** Required source is inaccessible or unverified; question requires data/participant execution; claim cannot be bound to evidence; reviewer scope or population transfer is unclear.
- **Owner decision impact:** May support later evidence thresholds and dispositions for named UNKNOWNs, especially U-07/U-09/U-12; cannot itself accept a quality target or research protocol.

## 8. Candidate SRX-OH-01 — Operations/human-review responsibility review

- **UNKNOWN IDs:** U-03, U-04, U-11, and U-12.
- **Reason for review:** Conceptual accountability for triage, protection, evidence access, contest, remedy, appeal, communication, closure, lifecycle conflicts, reconstruction, capacity, and failure is incomplete.
- **Required authority:** Owner acceptance of hypothetical responsibility scenarios, named operations/human-review specialist, and explicit no-system/no-case boundary.
- **Allowed activity if authorized:** Analyze accountable-role and segregation-of-duty alternatives at conceptual responsibility level; identify capacity assumptions, access limits, escalation conditions, and failure responsibilities.
- **Forbidden activity:** Service/module decomposition; staffing or implementation plan; real-case handling; user/Safety data access; operational change; production access; interface, storage, workflow-system, or deployment design.
- **Required evidence:** Reviewer role/competence; scenario-by-scenario responsibility reasoning; access/minimization constraints; capacity and failure evidence; conflicts, recusal, escalation, and audit limitations.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — OPERATIONS/HUMAN REVIEW — CONCEPTUAL RESPONSIBILITY ONLY`.
- **Stop condition:** Analysis requires a real case, staffing commitment, operational execution, restricted information, technical workflow, service boundary, or unsupported capacity target.
- **Owner decision impact:** May support later U-03/U-04/U-11/U-12 dispositions and P-03 through P-05; cannot convert conceptual contexts into services or implementation responsibilities.

## 9. Candidate SRX-AX-01 — Accessibility concept review execution

- **UNKNOWN IDs:** U-10, U-12, and U-13; informs U-05 prerequisites.
- **Reason for review:** Conceptual meaning, uncertainty, control, restriction, closure, appeal, and Safety communication may create cognitive, language, visual, motor, hearing, literacy, or situational access barriers.
- **Required authority:** Owner acceptance of concept-only scope, named accessibility specialist, target platform/population assumptions or explicit `UNKNOWN` limits, and no-prototype/no-participant boundary.
- **Allowed activity if authorized:** Review concepts and candidate requirement language against authoritative accessibility sources; identify risks, evidence gaps, and future validation options.
- **Forbidden activity:** Claiming compliance; UI/UX, screen, flow, component, prototype, Flutter, API, or Backend design; assistive-technology testing; participant activity or data collection.
- **Required evidence:** Current authoritative sources with version/application limits; qualified specialist rationale; affected-user analysis; concept-to-risk traceability; unresolved platform/population dependencies.
- **Expected artifact:** `SPECIALIST REVIEW RECORD — ACCESSIBILITY — CONCEPT REVIEW ONLY`, with risk and requirement summary.
- **Stop condition:** A conclusion requires a UI/prototype, platform selection, participant test, unverified standard application, or design decision.
- **Owner decision impact:** May constrain later U-10/U-12/U-13 dispositions and Explainability/User Control obligations; does not validate usability, accessibility, or a client design.

## 10. Candidate SRP-UR-01 — User research planning refinement

- **UNKNOWN IDs:** U-05, U-08, U-09, U-10, and U-13.
- **Reason for review:** Planning must address launch segment, inclusion, Match Readiness, desirability, meaningful conversation, comprehension, accessibility, pacing, and state language before any empirical activity can be considered; no participant protocol or execution authority exists.
- **Required authority:** Current Phase 13 authority permits planning only. Any external user-research specialist engagement or participant-facing execution requires a later exact Owner authorization plus applicable institution/ethics determination.
- **Allowed activity now:** Refine non-participant research objectives, non-objectives, questions, method alternatives, sampling risks, ethics dependencies, evidence standards, analysis-plan outline, and authority gaps. Any participant-facing example remains `DRAFT — NOT APPROVED — DO NOT USE`.
- **Forbidden activity:** Recruitment; contact; screening; interviews; surveys; observation; experiment; recording; prototype testing; compensation; consent administration; participant or personal/sensitive/private-interaction data collection or processing; external commissioning; design or implementation.
- **Required evidence before any execution decision:** Jurisdiction, institution, population, protocol, ethics determination, consent/assent and withdrawal boundaries, recruitment and compensation materials, data/security/access/retention plan, risk register, method review, accessibility review, and exact Owner authorization.
- **Expected artifact now:** `RESEARCH PLANNING RECORD — NO PARTICIPANT EXECUTION`, with question-to-decision map, authority gaps, risks, methods, and stop conditions.
- **Stop condition:** Work approaches participant-facing finalization, contact, collection, prototype creation, sensitive information, external engagement, or any activity beyond documentation planning.
- **Owner decision impact:** May prepare a later accept/revise/reject/defer decision on a bounded research protocol; it cannot supply user evidence or change U-05/U-08/U-09/U-10/U-13.

## 11. No Phase 17 execution candidate for U-15

U-15 concerns future technical requirements, architecture choices, interfaces, storage, services/modules, infrastructure, deployment, migration, cost, capacity, and recovery. These are not specialist-review execution under the currently authorized Research/Specialist prerequisite track.

- **Current classification:** `OWNER DECISION REQUIRED` and `REMAIN BLOCKED`.
- **Allowed Phase 17 activity:** Preserve the question inventory and dependencies only.
- **Forbidden activity:** Technical discovery execution, Database/API/Backend/Flutter design, Implementation Planning, code, migration, infrastructure, or deployment.
- **Future authority:** A separately bounded Owner authorization after applicable Phase 11 prerequisites; no such authorization is prepared as accepted here.

## 12. Proposed Owner decision sequence

This sequence is a review recommendation, not authorization:

1. Review the common authorization contract and decide whether external contact/commissioning is excluded or separately bounded.
2. Consider `SRX-PL-01` first because U-01–U-03 constrain the applicability and information boundary of later packages.
3. Consider `SRX-SM-01` and `SRX-OH-01` together for Safety/operations responsibility without merging their authority.
4. Consider `SRX-RM-01` before relying on evidence-strength, signal, measurement, or quality-target proposals.
5. Consider `SRX-FA-01` after purpose/population/method limits are explicit.
6. Consider `SRX-AX-01` at concept level; keep any platform or participant validation separately blocked.
7. Continue `SRP-UR-01` as planning only; decide on participant research only through a later protocol-specific workshop.
8. Reassess U-12 only after applicable package findings are available and independently reviewed.
9. Keep U-15 outside this track.

Parallel review may be proposed later, but shared assumptions, source conflicts, and authority boundaries must be reconciled before an Owner disposition.

## 13. Owner outcome vocabulary

For each candidate packet, the Owner may record only:

- `accepted` — authorize the exact packet and nothing broader;
- `revised` — authorize only the Owner's exact revised wording;
- `rejected` — do not execute the packet;
- `deferred` — retain the candidate and blockers without execution.

Until an explicit outcome is recorded, every candidate is `NOT AUTHORIZED`. Silence, recommendation, package completeness, specialist availability, or an earlier research-preparation authorization is not acceptance.

## 14. Downstream decision impact

| Area | Phase 17 result |
| --- | --- |
| U-01 through U-15 | All remain `BLOCKING` |
| OD-01 through OD-06 | No status or wording change |
| ADR-001 through ADR-005 | Remain `ACCEPTED`; no new ADR and no status change |
| Phase 11 P-03 through P-06 | No gate changes; proposed reviews may later supply evidence only |
| Research/Specialist track | Planning remains bounded; no specialist engagement or research execution is authorized by this document |
| Database/API/Backend/Flutter Design | `NOT AUTHORIZED` |
| Implementation Planning and Implementation | `NOT AUTHORIZED` |

## 15. No new ADR decision

No ADR is created. Selecting whether to authorize a bounded evidence-gathering or specialist-review packet is an authority decision, not yet a durable architecture alternative. A later genuine architecture choice must follow its own ADR lifecycle.

## 16. Validation and stop

Review must confirm:

- all 15 `BLOCKING` UNKNOWN items are classified against the four required Phase 17 categories;
- every proposed candidate states UNKNOWN ID, reason, required authority, allowed activity, forbidden activity, required evidence, expected artifact, stop condition, and Owner decision impact;
- candidate, authorization, execution, specialist finding, GPT L3 review, Owner disposition, gate change, design authority, and implementation authority remain distinct;
- no specialist was contacted, engaged, commissioned, or represented as having reviewed the package;
- no research was executed and no participant was recruited, contacted, interviewed, surveyed, observed, tested, recorded, compensated, or otherwise involved;
- no user, participant, personal, sensitive, private-interaction, or Safety data was collected, accessed, transferred, or processed;
- no Database schema/design, API contract/design, Backend architecture/design, Flutter architecture/design, Implementation Planning, code, migration, infrastructure, deployment, production access, or external production change was created.

Stop after documentation completion. Wait for GPT L3 independent review and explicit Owner decisions.
