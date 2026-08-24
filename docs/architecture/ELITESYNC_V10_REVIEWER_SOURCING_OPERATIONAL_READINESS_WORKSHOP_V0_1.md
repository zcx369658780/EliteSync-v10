# EliteSync 10.0 Reviewer Sourcing Operational Readiness Workshop V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `d5bc4fc61853b32be8f7750be25186f4aaf7ea5c` before this documentation execution.

Scope: Define fail-closed operational readiness requirements that must be satisfied before the reviewer sourcing authorized by Owner decision `ORS-01` may begin for `SRA-RM-01`, `SRA-PL-01`, and `SRA-SM-01`. This document neither supplies missing Owner inputs nor performs sourcing.

## 0. Workshop result

`ORS-01` remains `AUTHORIZED` for reviewer sourcing only. Operational verdict: `AUTHORIZED BUT NOT OPERATIONALLY READY — DO NOT SEARCH`.

No human sourcing lead or candidate-record custodian, exact system/directory, search-term rule, candidate-count bound, time bound, access list, retention schedule, or operational audit owner was supplied. These values must not be invented or inferred. Every required field remains `OWNER INPUT REQUIRED BEFORE SEARCH` until explicitly completed and reviewed.

| Stage/activity | Current state |
| --- | --- |
| Reviewer sourcing authorization | `AUTHORIZED` within `ORS-01` |
| Operational sourcing readiness | `NOT READY — DO NOT SEARCH` |
| Candidate evaluation/ranking/selection | `NOT AUTHORIZED` |
| Contact/outreach | `NONE` |
| Engagement/commissioning/spend | `NONE` |
| Evidence transfer | `NONE` |
| Specialist review execution | `NOT READY` |

Authorization is not readiness and is not transitive to any later stage.

## 1. Readiness matrix

All nine rows are mandatory. A partial completion cannot authorize a search.

| Required field | Required Owner-controlled record | Current value | Ready condition | Fail-closed result |
| --- | --- | --- | --- | --- |
| 1. Human sourcing lead | Named, accountable human; package scope; sourcing-only duties; independence/conflict attestation; assignment and review/expiry dates | `OWNER INPUT REQUIRED BEFORE SEARCH` | Assignment is explicit, current, and bounded to `ORS-01` | `NOT READY / STOP` |
| 2. Candidate-record custodian | Named, accountable human; custody, access, necessity review, retention, correction, and deletion duties | `OWNER INPUT REQUIRED BEFORE SEARCH` | Separate assignment exists, or Owner explicitly records one human holding both roles | `NOT READY / STOP` |
| 3. Approved systems/directories | Exact system/directory name and public locator; category; access mode; package; approval date | `OWNER INPUT REQUIRED BEFORE SEARCH` | Every source is individually listed and within an authorized public channel category | `NOT READY / STOP` |
| 4. Search-term rule | Exact permitted terms or explicit `NO-SEARCH-TERM RULE`, package linkage, approver, and change control | `OWNER INPUT REQUIRED BEFORE SEARCH` | Rule is explicit and cannot be expanded by the lead, custodian, or AI | `NOT READY / STOP` |
| 5. Candidate/time bounds | Maximum candidate-record count; start/end or duration; exhaustion rule; expiry/review date | `OWNER INPUT REQUIRED BEFORE SEARCH` | Both finite count and time limits are recorded | `NOT READY / STOP` |
| 6. Access control | Named access list, role, purpose, least-privilege rights, grant/revoke dates, and access-log custodian | `OWNER INPUT REQUIRED BEFORE SEARCH` | Only approved humans have minimum required access | `NOT READY / STOP` |
| 7. Retention/deletion | Purpose-limited retention period/review trigger, deletion triggers, derived-copy handling, and minimal deletion audit | `OWNER INPUT REQUIRED BEFORE SEARCH` | No indefinite retention; accountable custodian and triggers are explicit | `NOT READY / STOP` |
| 8. Stop conditions | Operational stop/escalation owner and triggers in Section 8 | `OWNER INPUT REQUIRED BEFORE SEARCH` | Lead and custodian attest they can stop and escalate without continuing activity | `NOT READY / STOP` |
| 9. Audit record | Approved audit template, storage location, custodian, access, event fields, verification cadence | `OWNER INPUT REQUIRED BEFORE SEARCH` | Audit controls exist before any activity | `NOT READY / STOP` |

## 2. Human role readiness

### 2.1 Human sourcing lead

The Owner must name an accountable human sourcing lead. The assignment must identify the three authorized packages, the exact sourcing-only authority, prohibited later-stage activities, conflict/independence requirements, start date, and expiry/review condition. The lead may discover potential candidates only after all readiness fields pass. The lead may not evaluate, rank, select, approve, contact, engage, disclose materials, spend, or execute a review.

### 2.2 Candidate-record custodian

The Owner must name an accountable human custodian before any candidate record can exist. The custodian controls record creation, access, correction, necessity review, retention, deletion, and minimal deletion audit. One human may hold both roles only through an explicit Owner-recorded dual assignment; silence does not combine the roles.

Either missing assignment, unclear responsibility, unresolved conflict, or authority beyond sourcing-only produces `NOT READY / STOP`.

## 3. Approved sourcing systems and directories

An allowed channel category is not an approved operational system. Before use, the Owner must record each exact system/directory and public locator.

Potentially approvable categories under `ORS-01` are limited to:

- recognized professional bodies and their public professional directories;
- public professional pages of research institutions;
- public professional pages/directories of standards organizations;
- professional directories separately approved by the Owner;
- an exact Owner-approved referral or nomination, without contacting any person.

No unlisted source is permitted. Login, paid/subscription access, acceptance of new terms, scraping, automated enrichment, data-broker sources, private/social accounts, or external contact requires authority not present here and therefore triggers stop. This document approves no particular system or directory.

## 4. Search-term readiness

Default rule: `NO SEARCH UNTIL OWNER RECORDS EXACT PERMITTED TERMS OR AN EXPLICIT NO-SEARCH-TERM RULE`.

Any later permitted terms must be neutral, public-professional, package-specific relevance descriptors. They must not contain candidate names, sensitive or protected traits, allegations, case identifiers, private attributes, jurisdiction assumptions, or selection/ranking criteria. The sourcing lead, custodian, or AI may not generate, broaden, substitute, or optimize terms without explicit human approval and audit.

Package boundaries:

- `SRA-RM-01`: methodology, evidence quality, validity, measurement, evidence synthesis, uncertainty, or research design descriptors only; no competence decision, participant research, data/experiment/model execution, or metric approval.
- `SRA-PL-01`: privacy, information rights, or data-governance descriptors only; no jurisdiction selection/inference, legal opinion, or compliance claim.
- `SRA-SM-01`: Safety/moderation, responsibility boundaries, escalation, recourse, or human-review descriptors only; no case review, guilt/reputation judgment, person-level risk scoring, moderation action, or Safety decision.

## 5. Candidate-count and time bounds

Before first search, the Owner must record a finite maximum number of candidate records and a finite search window, including start/end conditions and expiry/review date. Reaching either bound requires immediate stop and Owner review. No unused capacity, rollover, extension, new batch, or successor authorization may be inferred. No bound is supplied by this workshop.

## 6. Access control

Least privilege applies. Default eligible access is limited to the assigned sourcing lead, assigned custodian, Owner, and any explicitly named governance verifier. The access record must specify each human, purpose, rights, grant/revoke dates, and audit responsibility.

Candidates, specialists, external parties, technical teams, AI services, and later-stage roles have no default access. Access to a sourcing record never grants evaluation, contact, engagement, disclosure, or review authority. Candidate records remain confidential project-governance records even when based on public sources.

## 7. Retention and deletion

Retention must be minimum necessary and purpose-limited while `ORS-01` and its exact sourcing purpose remain active. Indefinite archiving is prohibited. The custodian must review necessity, provenance, access, accuracy, and expiry at the Owner-recorded cadence.

Delete the record and derived copies upon authorization expiry/revocation, purpose completion, necessity ending, failed provenance, unresolved stop condition, or Owner direction. Retain only a minimal deletion event: record ID, date, responsible human, and reason category. It must not preserve unnecessary candidate information.

## 8. Stop conditions

Stop before or during any sourcing operation if:

- any readiness-matrix field is incomplete, expired, unclear, or unverified;
- a responsible human lead or custodian is unavailable or exceeds role authority;
- the exact system/directory or search-term rule is absent or the count/time bound is reached;
- a source requires login, payment, new terms, scraping, enrichment, private access, or contact;
- provenance, necessity, confidentiality, access, retention, deletion, package linkage, or authorization becomes unclear;
- personal data beyond minimum necessity, sensitive/private-interaction/Safety/participant data, confidential project material, or evidence transfer would be involved;
- evaluation, verification as a qualification decision, comparison, scoring, ranking, recommendation, selection, contact, availability request, engagement, spend, or specialist review becomes necessary;
- an AI tool would discover candidates, verify qualifications, rank, decide, or represent Owner authority.

On stop: perform no further search or record creation, preserve only the minimum authorized audit event, contain access where required, and escalate to the Owner. Do not infer repair, continuation, or a later stage.

## 9. Audit record requirements

The audit mechanism must exist before sourcing begins. Each authorized event must record:

- actor, accountable human role, timestamp, and authorization ID `ORS-01`;
- package and exact approved system/directory/public locator;
- exact approved search-term or no-search-term rule;
- applicable candidate-count/time bound and remaining state;
- candidate record ID, provenance, access/change/correction/deletion event, and retention state, if a record is later authorized to be created operationally;
- stop/escalation event and resolution authority;
- human verification state and attestation that no evaluation or contact occurred;
- any AI preparation metadata required by Phase 20B, without promoting AI output to evidence or authority.

The audit must not contain private information, unnecessary personal data, qualification conclusions, rankings, or contact content. Every potential-candidate record, if later created under a ready operation, must remain labeled:

`POTENTIAL CANDIDATE — UNVERIFIED — SOURCING-ONLY — NOT EVALUATED — NOT CONTACTED — NOT AUTHORIZED FOR ENGAGEMENT`.

## 10. Operational readiness checklist

The Owner or explicitly authorized governance verifier must record each item as `PASS`; blank, partial, proposed, or inferred values are failures.

```text
Authorization ID: ORS-01
Packages: SRA-RM-01 / SRA-PL-01 / SRA-SM-01

[ ] Named human sourcing lead assigned and bounded
[ ] Named candidate-record custodian assigned and bounded
[ ] Exact approved systems/directories and public locators recorded
[ ] Exact permitted search terms or explicit NO-SEARCH-TERM RULE recorded
[ ] Finite candidate-record count bound recorded
[ ] Finite time window, expiry, and review conditions recorded
[ ] Least-privilege named access list and access log ready
[ ] Retention, necessity review, derived-copy deletion, and minimal deletion audit ready
[ ] Stop/escalation owner, triggers, and procedure acknowledged
[ ] Audit template, storage, custodian, access, and verification cadence ready
[ ] Package overlays and forbidden activities acknowledged
[ ] Independent GPT L3 and explicit Owner review outcome recorded

Readiness verdict: NOT READY — DO NOT SEARCH
Owner outcome/date:
GPT L3 review/date:
Governance verifier/date:
```

No checklist item is satisfied by this proposed workshop document itself.

## 11. AI boundary

AI may assist only with blank readiness templates, checklists, formatting, consistency checks, and documentation. AI may not search for or discover candidates, create operational candidate records, verify qualifications, rank or recommend candidates, decide sourcing actions, contact anyone, or represent Owner authority. AI/tool output remains `AI-assisted research preparation`, not source evidence, specialist finding, or Owner decision.

## 12. Downstream impact and validation

| Area | Phase 27 result |
| --- | --- |
| `ORS-01` sourcing authorization | Remains `AUTHORIZED` |
| Operational sourcing | `NOT READY — DO NOT SEARCH`; not performed |
| Candidate records/identities | None created or identified |
| Candidate evaluation/contact | `NOT AUTHORIZED` / `NONE`; not performed |
| Engagement/commissioning/spend | `NONE`; not performed |
| Evidence transfer/review execution | `NONE` / `NOT READY`; not performed |
| U-01 through U-15 | Remain `BLOCKING` |
| OD-01 through OD-06 | No change |
| ADR-001 through ADR-005 | No change |
| Phase 11 gates | No change |
| Technical design/implementation | Not authorized; no artifacts created |

Validation must confirm all nine readiness fields and the fail-closed checklist are present; missing operational inputs are not invented; all three packages remain within their sourcing-only overlays; AI is preparation support only; and no sourcing, search, candidate identification/record activity, evaluation, contact, engagement, spending, evidence transfer, review execution, technical design, implementation planning, or code occurred.

Stop after documentation completion. Wait for GPT L3 independent review and explicit Owner review before any sourcing/search/candidate activity.
