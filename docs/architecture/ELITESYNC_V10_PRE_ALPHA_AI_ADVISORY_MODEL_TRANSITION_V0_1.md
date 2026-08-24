# EliteSync 10.0 Pre-Alpha AI Advisory Model Transition V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-25

Authority snapshot: GitHub `main` at `fa0402e242bf4d7003b332a160dcfe06bdbbf6f1` before this Phase 32 documentation execution.

Scope: Record the Owner-directed transition from active or deferred human-reviewer sourcing to a bounded AI advisory model for the current pre-alpha stage. This is a governance transition only. It closes the current human sourcing window and defines advisory, evidence, review, and re-entry boundaries; it does not perform advisory research, legal analysis, specialist review, technical design, implementation planning, or code.

## 0. Owner decision and project reality

- **Exact Owner decision:** `AI-ADVISORY-PRE-ALPHA-MODEL — ACCEPTED`.
- **Decision ID:** `AI-ADVISORY-PRE-ALPHA-MODEL`.
- **Owner outcome:** `ACCEPTED`.
- **Exact effectiveness timestamp:** `NOT SEPARATELY PROVIDED`; it must not be inferred from drafting, commit, push, or silence.
- **Stage:** Current pre-alpha stage only.
- **Decision effect:** Bounded AI advisory research functions may be used under this document, and continued human-specialist sourcing is suspended for the current pre-alpha stage.

The Owner records the following current project reality:

- EliteSync-v10 has not reached internal testing.
- The Owner is currently the only human participant in the project.
- Human specialist participation is not realistically available at this stage.
- Continued mandatory human-specialist sourcing would create disproportionate process overhead without corresponding product value.

The model change is proportional to the present maturity and risk context. It does not state that human expertise lacks value, waive later human review, or convert an AI system into a human specialist or professional authority.

DeepSeek, ChatGPT, Codex, and OpenCode-supported AI workflows may be used as primary bounded advisory tools. Tool identity, model identity where disclosed, purpose, supplied context, source inputs, limitations, verification state, and accountable human review must be recorded proportionately for material retained outputs.

The Owner decision is accepted within its exact scope. This Phase 32 record remains `PROPOSED — AWAITING GPT L3 AND OWNER REVIEW`; its review status does not turn AI output into accepted evidence, specialist findings, Owner dispositions, or architecture decisions.

## 1. Authority classification

Every AI advisory output under this model must be classified as:

`AI-ASSISTED ADVISORY ANALYSIS`

Where legal or compliance issues are involved, it must additionally be classified as:

`AI-ASSISTED LEGAL RESEARCH — NOT FORMAL LEGAL OPINION`

These are Phase 32 presentation and authority labels layered on the existing Phase 20B provenance class `AI-assisted preparation`. The earlier class and its provenance, limitation, verification, and non-authority requirements remain applicable; the new labels do not promote AI output into evidence or professional authority.

AI output is not automatically any of the following:

- a specialist finding or professional review;
- a verified fact or controlling source;
- legal advice, formal legal opinion, or compliance determination;
- Safety authority, real-case adjudication, or emergency authority;
- an Owner decision or inferred Owner intent;
- ADR authority, architecture acceptance, or implementation authorization.

Fluency, citations, model confidence, repeated generation, tool branding, or agreement among AI systems does not change this classification. AI systems do not inherit the credentials, duties, independence, or authority of human specialists.

## 2. Human reviewer sourcing transition

The current sourcing window is closed by explicit Owner governance-model change. The closure is not a sourcing failure, candidate rejection, inability finding, or negative conclusion about any person.

| Package | Previous state | Phase 32 state | Transition effect |
| --- | --- | --- | --- |
| `SRA-RM-01` — Research methodology | `ACTIVE — ROUND 1`; candidate count `0/5` | `HUMAN SOURCING SUSPENDED FOR PRE-ALPHA` | The active human sourcing window is closed. No further search or candidate-record creation is permitted under the previous window. No candidate records exist, so no candidate-record migration is required. |
| `SRA-SM-01` — Safety/moderation | `QUEUED / DEFERRED ACTIVATION` | `HUMAN SOURCING SUSPENDED FOR PRE-ALPHA` | Deferred activation is not advanced; no Safety/moderation human sourcing begins. |
| `SRA-PL-01` — Privacy/legal | `DEFERRED FOR CURRENT CYCLE` | `FORMAL HUMAN LEGAL REVIEW DEFERRED` | No human legal sourcing or formal legal opinion is initiated at the current maturity stage. |

The exact closure timestamp was not separately provided and is not inferred from this document's commit or push time. The scheduled `OA-01` endpoint of `2026-09-07T21:03:18+08:00` no longer permits sourcing activity after this Owner-directed closure. Unused capacity does not roll over, transfer to another package, create replacement capacity, or authorize a later round. `ORS-01`, `OA-01`, and related historical records remain provenance for the earlier model; they do not reactivate sourcing after this transition.

No candidate identity or candidate record exists. No identity is migrated, published, inferred, or supplied to GPT L3.

## 3. Pre-alpha AI advisory tracks

### 3.1 Track A — Research Methodology

- **Priority:** `FIRST`.
- **State:** `AVAILABLE FOR BOUNDED AI ADVISORY WORK`.

AI may assist with:

- research methodology and research-design analysis;
- evidence-quality and evidence-hierarchy analysis;
- measurement and validity reasoning;
- uncertainty identification;
- identifying unsupported inference;
- distinguishing correlation, inference, declaration, and verified evidence.

Outputs remain advisory and source-bounded. They do not approve a methodology, dataset, experiment, model, metric, threshold, signal, finding, or UNKNOWN disposition.

### 3.2 Track B — Safety / Moderation

- **Priority:** `SECOND`.
- **State:** `AVAILABLE FOR BOUNDED CONCEPTUAL AI ADVISORY WORK`.

AI may assist with:

- conceptual Safety scenarios and moderation principles;
- false-positive and false-negative analysis;
- escalation-model analysis;
- human-review and appeal principles;
- responsibility-boundary analysis.

AI may not become or act as:

- autonomous Safety authority;
- a real-case adjudicator;
- guilt, abuse, allegation, reputation, or truth authority;
- an emergency decision-maker;
- a person-level risk scorer or moderation-action authority.

This track does not authorize real Safety data, private conversations, reports, allegations, emergencies, production cases, or operational moderation decisions.

### 3.3 Track C — Legal / Compliance Research

- **Priority:** `AS NEEDED`.
- **State:** `AVAILABLE FOR BOUNDED AI-ASSISTED LEGAL RESEARCH PREPARATION`.
- **Preferred assistant:** DeepSeek for future legal/compliance research preparation.

DeepSeek remains a research tool, not counsel, legal authority, compliance authority, or source of controlling law. For every material Mainland China legal or compliance analysis, the prompt must require DeepSeek to base its answer on applicable primary official legal sources and to identify those sources. Model memory alone is insufficient.

Track C does not itself determine the applicable jurisdiction, establish that a listed law applies to EliteSync, or produce a formal legal opinion.

## 4. Mandatory Mainland China official-primary-source rule

Future material Mainland China legal or compliance research must identify and use the relevant original authoritative legal text. Depending on the issue, candidate sources may include:

- the Constitution and statutes published through official National People's Congress or NPC Standing Committee sources;
- `中华人民共和国民法典`;
- `中华人民共和国个人信息保护法`;
- `中华人民共和国数据安全法`;
- the applicable current `中华人民共和国网络安全法`;
- applicable State Council administrative regulations;
- `网络数据安全管理条例`;
- applicable judicial interpretations issued by the Supreme People's Court or Supreme People's Procuratorate;
- applicable rules, measures, regulations, and official normative documents issued by competent authorities such as the Cyberspace Administration of China when legally relevant.

This list is illustrative, not an applicability determination. It does not state that every listed authority governs every EliteSync question. Applicability, hierarchy, territorial and personal scope, effective date, amendment state, definitions, exceptions, and conflicts must be analyzed issue by issue.

### 4.1 Source hierarchy

For material legal research, use the following order of preference:

1. Official current legal text from the competent issuing authority.
2. Official amendment, repeal, transition, and effective-date materials.
3. Applicable official judicial interpretations or implementing regulations.
4. Official regulator guidance where relevant.
5. Secondary commentary only as supplementary context.

Secondary sources never replace controlling official text. Do not rely solely on blogs, law-firm marketing articles, news summaries, social-media posts, AI memory, or unsourced web summaries.

## 5. Mandatory DeepSeek legal task requirements

Every future material legal or compliance task sent to DeepSeek must require an output that states:

1. the issue being analyzed;
2. the jurisdiction assumption;
3. the applicable official primary legal sources;
4. each exact law, regulation, interpretation, measure, or official document name;
5. relevant article numbers where available;
6. current effective status, amendment status, or uncertainty about status;
7. a clear separation among direct statutory text, interpretation, inference, and uncertainty;
8. conflicting or ambiguous provisions, materials, or interpretations if present;
9. what cannot be concluded from the cited authority;
10. whether later human legal review should be required before a real-world decision.

Every such output must explicitly state:

`This is AI-assisted legal research preparation and not formal legal advice.`

The task must not ask DeepSeek to manufacture a citation, assume that a remembered provision is current, select a jurisdiction without an explicit assumption, or make a final product, compliance, or legal decision.

## 6. Legal source verification

DeepSeek-supplied citations and reasoning must not be accepted solely because DeepSeek supplied them. For every material legal conclusion, and before it is retained as decision support or informs a real-world decision:

- verify that each cited primary source exists;
- verify the relevant wording against an official source;
- verify issuer, hierarchy, amendment, repeal, transition, and effective status when material;
- preserve exact source locators and access dates;
- separate quotation from interpretation and inference;
- identify unresolved ambiguity, conflict, scope limits, and unavailable materials;
- record what the cited authority does not establish.

A verified source is the evidence; the AI summary remains advisory analysis. GPT L3 may independently challenge or reject the reasoning, citation selection, applicability analysis, or proposed conclusion. The Owner retains final bounded pre-alpha product and governance authority. No AI system receives formal legal authority.

Formal human legal review remains expected before a real-world decision when the issue, project maturity, materiality, uncertainty, irreversibility, exposure, or need for a formal opinion makes it proportionate.

## 7. Advisory evidence ladder

The authority ladder is:

`Official / source evidence`

↓

`AI-assisted advisory analysis`

↓

`GPT L3 critique / governance review`

↓

`Owner bounded decision`

AI output must not skip or collapse levels. Source evidence does not become AI authority; AI analysis does not become GPT L3 acceptance; GPT L3 review does not become Owner authority; and none of these becomes an ADR or implementation authorization without the separately required recorded decision.

## 8. UNKNOWN register

U-01 through U-15 remain `BLOCKING`. AI advisory analysis does not automatically resolve, close, accept, reject, defer, or otherwise dispose any UNKNOWN.

Bounded AI advisory work may:

- refine an UNKNOWN;
- identify potential evidence and verification needs;
- reduce uncertainty within a recorded scope;
- recommend a bounded assumption for later review;
- identify a later human-review trigger.

Any UNKNOWN disposition change requires explicit downstream review and recorded authority. Phase 32 changes neither OD-01 through OD-06 nor ADR-001 through ADR-005 and does not change Phase 11 gates.

## 9. Human specialist re-entry

Human specialist review is suspended or deferred, not permanently prohibited. It may be reintroduced through a later explicit Owner-controlled decision when proportional to project maturity and material risk, including when one or more of the following becomes real or imminent:

- company or entity formation;
- internal or external testing involving real people;
- collection of meaningful personal information;
- collection or processing of sensitive personal information;
- production Safety or moderation workflows;
- contracts, payments, compensation, or financial commitments;
- regulatory filing or material regulatory exposure;
- real moderation cases, allegations, appeals, or emergency handling;
- a need for formal legal opinion;
- high-impact or irreversible product decisions.

Human review is not reintroduced automatically because a prior sourcing phase existed, a scheduled window elapsed, an AI analysis completed, or a maturity trigger was mentioned. Re-entry requires a fresh recorded scope, authority, review need, information boundary, and operational decision.

## 10. Proportional governance

Current pre-alpha AI research activities are primarily development and research artifacts. Proportionate records and review are required, but unnecessary enterprise-grade gates must not be created around:

- ordinary AI prompts;
- research using public legal sources;
- non-sensitive design notes;
- disposable research drafts.

Stricter controls remain appropriate when real personal data, sensitive personal information, Safety data, private conversations, production credentials, financial commitments, regulated operations, or other materially restricted information or actions are introduced.

Proportionality does not waive source verification, confidentiality, data minimization, tool-use boundaries, explicit authority, or review requirements that are material to the actual task.

## 11. Unchanged technical and execution boundary

Phase 32 does not authorize:

- database or schema design;
- API design;
- Backend or Flutter implementation;
- infrastructure or deployment;
- production access;
- migration;
- technical implementation planning;
- code.

It also does not authorize candidate evaluation, contact, outreach, availability requests, engagement, hiring, commissioning, spend, evidence transfer, specialist review, or a successor phase.

## 12. Phase 32 execution record

| Validation item | Result |
| --- | --- |
| Owner model decision recorded | `AI-ADVISORY-PRE-ALPHA-MODEL — ACCEPTED` |
| `SRA-RM-01` | `HUMAN SOURCING SUSPENDED FOR PRE-ALPHA`; previous count retained as historical `0/5` |
| `SRA-SM-01` | `HUMAN SOURCING SUSPENDED FOR PRE-ALPHA` |
| `SRA-PL-01` | `FORMAL HUMAN LEGAL REVIEW DEFERRED` |
| Track A | `FIRST`; bounded research-methodology advisory work |
| Track B | `SECOND`; bounded conceptual Safety/moderation advisory work |
| Track C | `AS NEEDED`; bounded legal/compliance research preparation |
| Reviewer search or candidate identification | None performed |
| Candidate records | None created; count remains 0 |
| Contact, outreach, engagement, hiring, commissioning, or spend | None performed |
| Specialist review | None performed |
| Substantive legal analysis or legal conclusion | None performed or produced |
| UNKNOWN dispositions | No change; U-01 through U-15 remain `BLOCKING` |
| OD-01 through OD-06 | No change |
| ADR-001 through ADR-005 | No change |
| Phase 11 gates | No change |
| Technical design, implementation planning, or code | Not authorized and not performed |

This document contains governance requirements and examples only. Its references to laws and regulators are not a substantive legal analysis, applicability conclusion, compliance determination, or legal opinion.

## 13. Validation and stop

Validation must confirm that:

- the Owner decision, project-reality rationale, and exact pre-alpha scope are recorded;
- the previous human sourcing window is closed because of the governance-model change rather than sourcing failure;
- RM, SM, and PL states and the zero-record history are accurate;
- the three advisory tracks retain their priority, allowed functions, and prohibited authority;
- legal outputs retain the required classification, primary-source hierarchy, prompt fields, verification requirements, and disclaimer;
- the evidence ladder cannot be skipped;
- U-01 through U-15, OD-01 through OD-06, ADR-001 through ADR-005, and Phase 11 gates remain unchanged;
- no candidate search, identification, record creation, contact, engagement, spend, evidence transfer, specialist review, substantive legal conclusion, technical design, implementation planning, or code occurred;
- only the intended Phase 32 documentation artifact is changed.

Stop after documentation completion. Wait for GPT L3 and Owner review. Do not infer a successor phase.
