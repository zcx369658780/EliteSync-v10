# EliteSync 10.0 Owner Operational Activation Decision Execution V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `670197866d799ab04cc71b2c9718d2c47aa10b54` before this documentation execution.

Scope: Record Owner decisions `OA-01`, `OA-02`, and `OA-03` for bounded reviewer sourcing operations under `ORS-01` and the Phase 29 adjusted Pre-Alpha Owner-operated governance model. This document records activation only; it does not perform sourcing or authorize evaluation, contact, engagement, evidence transfer, or specialist review.

## 0. Activation result

The Owner has explicitly decided to activate bounded sourcing for `SRA-RM-01` and `SRA-SM-01` and to authorize sourcing-only candidate-record creation. The activation record is `RECORDED — PENDING EFFECTIVENESS`. It becomes effective only after GPT L3 review and the required Owner review of this proposed record. Until effectiveness is recorded, the 14-day clock has not begun and no search or candidate-record creation may occur.

| Stage/activity | Phase 30 state |
| --- | --- |
| Reviewer sourcing under `ORS-01` | `AUTHORIZED`; activation decision recorded |
| Operational activation | `PENDING EFFECTIVENESS AFTER GPT L3 AND OWNER REVIEW` |
| Candidate-record creation | `AUTHORIZED WHEN ACTIVATION BECOMES EFFECTIVE`; sourcing-only state |
| Candidate evaluation/qualification decision | `NOT AUTHORIZED` |
| Candidate ranking/selection/recommendation | `NOT AUTHORIZED` |
| Contact/outreach/availability request | `NONE` |
| Engagement/hiring/commissioning/spend | `NONE` |
| Evidence transfer | `NONE` |
| Specialist review | `NOT READY` |

## 1. Decision OA-01 — Sourcing window activation

- **Decision ID:** `OA-01`.
- **Owner outcome:** `ACTIVE`, subject to the effectiveness condition below.
- **Duration:** 14 calendar days.
- **Start:** The recorded timestamp at which this operational activation record becomes effective after GPT L3 review and required Owner review.
- **End:** End of the fourteenth calendar day after the effective timestamp, or earlier upon purpose completion, Owner revocation, package limit, or a stop condition.
- **Active packages:** `SRA-RM-01` Research methodology; `SRA-SM-01` Safety/moderation.
- **Deferred package:** `SRA-PL-01` Privacy/legal.
- **Responsible human sourcing lead:** Owner.
- **Access:** Owner only for candidate identity records.

No effective timestamp is supplied by this documentation execution. Time does not run from drafting, commit, push, GPT L3 review request, or silence. No extension, rollover, replacement batch, or successor window is inferred.

## 2. Decision OA-02 — Candidate-record creation

- **Decision ID:** `OA-02`.
- **Owner outcome:** Candidate-record creation `AUTHORIZED` only when `OA-01` becomes effective and only within the active package, time, count, source, information, access, and audit bounds.
- **Custodian:** Owner only.
- **Access:** Owner only.
- **Purpose:** Record minimum public professional information for a potential candidate discovered through an approved sourcing activity.

Every record must display the complete state:

`POTENTIAL CANDIDATE — UNVERIFIED — SOURCING-ONLY — NOT EVALUATED — NOT CONTACTED — NOT AUTHORIZED FOR ENGAGEMENT`.

A record must never imply qualification, suitability, endorsement, authority, willingness to participate, availability, recommendation, selection, approval, or engagement.

Minimum permitted fields after effectiveness:

```text
Candidate record ID:
Status: POTENTIAL CANDIDATE — UNVERIFIED — SOURCING-ONLY — NOT EVALUATED — NOT CONTACTED — NOT AUTHORIZED FOR ENGAGEMENT
Package: SRA-RM-01 or SRA-SM-01
Discovery timestamp:
Authorization: ORS-01 / OA-01 / OA-02
Approved source category:
Exact public source locator and access date:
Neutral search term used:
Minimum public professional identifier:
Public role or affiliation:
Neutral public professional descriptors relevant to sourcing:
Provenance state:
Information excluded or minimized:
Custodian/access: Owner only
Package count after creation:
Window state:
Retention/deletion state:
Stop events:
```

This template is not a candidate record and no instance is created during Phase 30 documentation.

## 3. Decision OA-03 — Privacy/legal deferral

- **Decision ID:** `OA-03`.
- **Package:** `SRA-PL-01`.
- **Owner outcome:** `DEFERRED`.
- **Candidate limit:** 0.
- **Operational effect:** No privacy/legal specialist sourcing, search, candidate identification, or candidate-record creation.

Deferral remains until all of the following are sufficiently established and explicitly reviewed by the Owner:

- a company entity exists;
- operating jurisdiction is clearer;
- product/data scope is established.

No condition is treated as satisfied here. AI-assisted legal research preparation remains allowed under Phase 20B. It is not sourcing, legal opinion, compliance conclusion, specialist finding, or legal-specialist authority.

## 4. Mandatory pre-sourcing verification

The Owner must verify and record all rows immediately before the first effective sourcing activity. Any failed, blank, expired, or contradictory row triggers stop.

| Verification item | Required value | Phase 30 recorded value |
| --- | --- | --- |
| Human sourcing lead | Owner | Owner |
| Candidate-record custodian | Owner | Owner |
| `SRA-RM-01` source categories | Research institutions; academic/professional methodology organizations; evidence quality organizations; public professional directories | Recorded |
| `SRA-SM-01` source categories | Trust & Safety organizations; moderation professional communities; safety governance organizations; public professional directories | Recorded |
| `SRA-RM-01` terms | `research methodology`; `evidence quality`; `validity`; `measurement`; `research design` | Recorded |
| `SRA-SM-01` terms | `trust safety`; `moderation`; `human review`; `safety governance` | Recorded |
| `SRA-RM-01` limit | Maximum 5 records | Recorded |
| `SRA-SM-01` limit | Maximum 5 records | Recorded |
| Time window | 14 calendar days from effectiveness | Recorded; not started |
| Candidate-record access | Owner only | Recorded |
| Retention | Maximum 90 days after sourcing closure, subject to earlier deletion | Recorded |
| Audit owner | Owner | Recorded |
| Activation effectiveness | GPT L3 review and required Owner review complete; effective timestamp recorded | `PENDING` |

The package limits are independent. A record linked to both active packages counts against both. `SRA-PL-01` has no search terms, source categories, or capacity.

## 5. Approved sourcing and search boundary

After activation becomes effective, the Owner may:

- search approved public professional sources within the relevant active-package category;
- use only the approved neutral package descriptors;
- identify potential candidates without evaluating them;
- record minimum necessary public professional information;
- create sourcing-only candidate records under `OA-02`;
- record exact public source locators, provenance, counts, lifecycle events, and stop events.

Approved categories for `SRA-RM-01`:

- research institutions;
- academic/professional methodology organizations;
- evidence quality organizations;
- public professional directories.

Approved categories for `SRA-SM-01`:

- Trust & Safety organizations;
- moderation professional communities;
- safety governance organizations;
- public professional directories.

Only public professional sources are permitted. Login, payment/subscription, acceptance of new terms, scraping, automated enrichment, bulk harvesting, data brokers, private/social accounts, confidential sources, or external requests are not authorized. The exact public locator used must be captured in the Owner-controlled audit.

## 6. Search-term boundary

Only the recorded neutral descriptors may be used:

- `SRA-RM-01`: `research methodology`, `evidence quality`, `validity`, `measurement`, `research design`.
- `SRA-SM-01`: `trust safety`, `moderation`, `human review`, `safety governance`.

Forbidden terms or intent include `best expert`, comparisons, rankings, fame/popularity, sensitive attributes, inferred personal traits, allegations, cases, personal-name targeting, suitability, availability, or contact intent. A needed term outside the explicit list triggers stop and Owner review; it is not inferred from a category.

## 7. Information, confidentiality, retention, and audit

Only minimum necessary public professional identity, public role/affiliation, and neutral public professional descriptors relevant to package sourcing may be recorded. Public availability does not remove purpose, necessity, provenance, accuracy, confidentiality, access, retention, or deletion duties.

Forbidden content includes private contact details; personal data beyond necessity; sensitive, protected, health, political, biometric, financial, private-interaction, Safety, participant, real-case, allegation, emergency, credential, production, or confidential information; inferred traits; evaluation or ranking content; and project-private material.

Candidate identity records are confidential and accessible only to the Owner. GPT L3 receives governance records, aggregate counts, and stop/compliance state only; candidate identities are excluded by default.

Candidate records may be retained for no more than 90 calendar days after the Owner-recorded closure of sourcing. Delete earlier when purpose ends, authorization expires or is revoked, the Owner requests deletion, necessity ends, provenance/confidentiality fails, or a stop condition requires deletion. Retain only a minimal non-identity deletion event after deletion.

The Owner is audit owner. Each effective sourcing event must record authorization IDs, package, timestamp, source category, exact public locator, approved term, candidate-record ID, package count, window state, lifecycle event, provenance/confidentiality check, stop event if any, and attestation that no forbidden later-stage activity occurred.

## 8. Forbidden activities

Activation does not authorize:

- candidate evaluation or a qualification decision;
- comparison, scoring, ranking, selection, recommendation, approval, rejection, or endorsement;
- contact, outreach, availability request, reference request, interview, or opinion request;
- engagement, hiring, commissioning, contracting, compensation, reimbursement, subscription/procurement spend, or any financial commitment;
- project-material disclosure, evidence transfer, corpus access, specialist review, legal opinion, compliance conclusion, Safety decision, case review, or participant/data activity;
- technical design, implementation planning, database/API/Backend/Flutter work, infrastructure, deployment, production access, or code.

Discovery relevance is not qualification or suitability. A candidate record is not consent, willingness, availability, authority, or endorsement.

## 9. AI boundary

AI tools may assist with organizing human-controlled source notes, formatting records, checklist preparation, and consistency checking.

AI may not autonomously search for and select candidates; discover identities outside an Owner-directed approved search; choose, rank, score, recommend, approve, reject, or select candidates; verify qualification or specialist authority; decide suitability; contact anyone; make sourcing decisions; act as custodian; or represent Owner authority.

DeepSeek/OpenCode legal usage remains `AI-assisted legal research preparation` only. It is not legal opinion, compliance conclusion, legal-specialist authority, or permission to source `SRA-PL-01`.

## 10. Stop conditions

Stop before or during sourcing if:

- the activation effective timestamp is absent, the required reviews are incomplete, or authorization is unclear, revised, rejected, deferred, expired, or revoked;
- the 14-day window is not active or has ended, or a package reaches 5 records;
- activity concerns `SRA-PL-01`;
- source category, exact public locator, provenance, or approved search term is missing or outside scope;
- Owner-only access, confidentiality, minimum-information, retention, deletion, or audit control cannot be maintained;
- private, sensitive, Safety, participant, restricted, confidential, or unnecessary personal information would be involved;
- evaluation, qualification decision, ranking, selection, recommendation, contact, availability request, engagement, spend, evidence transfer, or specialist review becomes necessary;
- AI would act autonomously, verify qualification, choose, rank, decide suitability, contact, or represent Owner authority.

On stop, cease search and record creation, record the minimum stop event, restrict access, delete records when required, and seek explicit Owner direction. No repair, continuation, extension, or later-stage authorization is inferred.

## 11. Downstream state and validation

| Area | Phase 30 result |
| --- | --- |
| `OA-01` | Owner activation decision recorded; pending effectiveness after review |
| `OA-02` | Sourcing-only record creation authorized when activation is effective |
| `OA-03` | `SRA-PL-01` deferred |
| `SRA-RM-01` | Active package; maximum 5 records |
| `SRA-SM-01` | Active package; maximum 5 records |
| `SRA-PL-01` | Deferred; 0 records |
| Sourcing/search during documentation | None performed |
| Candidate identities/records | None identified or created |
| Candidate evaluation/ranking/selection | `NOT AUTHORIZED` |
| Contact | `NONE` |
| Engagement/commissioning/spend | `NONE` |
| Evidence transfer | `NONE` |
| Specialist review | `NOT READY` |
| U-01 through U-15 | Remain `BLOCKING` |
| OD-01 through OD-06 | No change |
| ADR-001 through ADR-005 | No change |
| Phase 11 gates | No change |

Validation must confirm that `OA-01` through `OA-03`, all nine pre-sourcing inputs, the active/deferred package split, exact limits, delayed window start, candidate-record label, Owner-only access, retention, audit, AI boundary, forbidden stages, and stop conditions are present. It must also confirm that no sourcing, search, candidate identification/record creation, evaluation, ranking, selection, contact, engagement, hiring, commissioning, spending, evidence transfer, specialist review, technical design, implementation planning, or code occurred during this documentation execution.

Stop after documentation completion. Wait for GPT L3 review and required Owner review. No sourcing window has begun.
