# EliteSync 10.0 Owner Operational Input Provision V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `acddd01621993c5229b2bf7e90bf30f6608ad83a` before this documentation execution.

Scope: Record the Owner-provided operational inputs for the adjusted Pre-Alpha Owner-operated reviewer sourcing model under `ORS-01`. This document provisions inputs for `SRA-RM-01` and `SRA-SM-01`, defers `SRA-PL-01`, and does not perform sourcing or authorize any later stage.

## 0. Owner decision record

- **Owner decision ID:** `OSOI-02` — Adjusted Pre-Alpha Owner Operational Input Provision.
- **Related authority:** `ORS-01`, reviewer sourcing in principle.
- **Owner outcome:** Operational inputs provided for Owner-operated sourcing of `SRA-RM-01` and `SRA-SM-01`; `SRA-PL-01` deferred.
- **Current effect:** Inputs are `PROVISIONED — NOT YET EFFECTIVE`. No sourcing window begins and no search may occur until this document receives GPT L3 review and explicit Owner operational approval.
- **Responsible human:** Owner, acting as both human sourcing lead and candidate-record custodian.
- **Model:** Proportionate Pre-Alpha governance with Owner-only candidate-record access and bounded public-source discovery.
- **Expiry:** For each active package, 14 calendar days from the recorded operational approval timestamp, unless stopped or revoked earlier. No approval timestamp exists in this proposed document.

## 1. Package state

| Package | Owner state | Purpose | Candidate limit | Operational effect |
| --- | --- | --- | --- | --- |
| `SRA-RM-01` | `ACTIVE` | Research methodology reviewer sourcing | Maximum 5 potential candidates | Provisioned, pending operational approval |
| `SRA-SM-01` | `ACTIVE` | Safety/moderation reviewer sourcing | Maximum 5 potential candidates | Provisioned, pending operational approval |
| `SRA-PL-01` | `DEFERRED` | Formal privacy/legal specialist sourcing | 0 | No sourcing |

`SRA-PL-01` remains deferred until a company entity exists, operating jurisdiction is clearer, and product/data scope is established. All three conditions require later Owner review; none is treated as satisfied here. AI-assisted legal research preparation remains allowed under Phase 20B, but it is not legal opinion, compliance conclusion, specialist authority, or sourcing.

## 2. Operational roles and access

| Role/access item | Owner input | Scope |
| --- | --- | --- |
| Human sourcing lead | Owner | Sourcing-only activity for the two active packages after operational approval |
| Candidate-record custodian | Owner | Creation, custody, access, correction, necessity review, retention, and deletion |
| Candidate-record access | Owner only | Least-privilege access to candidate identity records |
| GPT L3 | Governance review only | No candidate identity records by default |

The Owner explicitly holds both operational roles in this adjusted model. Role combination does not broaden authority. GPT L3 may review authorization, controls, aggregate counts, lifecycle compliance, and stop events without receiving candidate identities. Any identity disclosure requires separate explicit authority and necessity.

## 3. Approved sourcing categories and source rule

For the adjusted Pre-Alpha model, the Owner adopts a category-level allowlist rather than pre-approving named directories. This is an explicit proportional adjustment to Phase 27's exact-system readiness requirement. Each public source actually used must be within the relevant category and its exact locator must be recorded in the Owner-controlled audit at first use. This does not authorize an unlisted category.

### 3.1 SRA-RM-01

Allowed categories:

- public research institution pages;
- academic or professional methodology organizations;
- public professional directories;
- evidence or research quality organizations.

### 3.2 SRA-SM-01

Allowed categories:

- Trust & Safety organizations;
- moderation professional communities;
- public safety governance organizations;
- relevant professional directories.

### 3.3 SRA-PL-01

No category, system, directory, source, or search is authorized while deferred.

All sources must be public professional sources. Login, paid/subscription access, acceptance of new terms, scraping, bulk harvesting, automated enrichment, data brokers, private/social accounts, external requests, referrals requiring contact, or confidential sources are not authorized.

## 4. Search-term rule

Only neutral package descriptors may be used.

For `SRA-RM-01`, permitted examples are:

- `research methodology`;
- `evidence quality`;
- `validity`;
- `measurement`;
- `research design`.

For `SRA-SM-01`, permitted examples are:

- `trust safety`;
- `moderation`;
- `human review`;
- `safety governance`.

The examples define the neutral descriptor boundary; exact terms used and package linkage must be recorded in the audit. Neutral variants may not introduce evaluation, ranking, popularity, sensitive attributes, inferred traits, allegations, cases, personal names, or contact intent. If a proposed term is not clearly within the recorded boundary, stop and obtain Owner review before use.

Forbidden terms and intent include `best expert`, ranking language, fame/popularity language, sensitive-attribute terms, inferred personal traits, or any query designed to compare, score, select, or investigate a person. `SRA-PL-01` has no permitted search terms.

## 5. Candidate-count and time bounds

- `SRA-RM-01`: maximum 5 potential candidate records.
- `SRA-SM-01`: maximum 5 potential candidate records.
- `SRA-PL-01`: 0; deferred.
- Common sourcing window: 14 calendar days beginning only at the timestamp of explicit operational approval after GPT L3 and Owner review.

The limits are per package. A record linked to both active packages counts against both limits. Reaching a package limit stops sourcing for that package. The window closes at the end of day 14 or earlier on a stop condition, Owner revocation, or purpose completion. No unused capacity, extension, rollover, replacement batch, or successor window is inferred.

## 6. Candidate-record and confidentiality boundary

If operational approval later becomes effective, each record must remain:

`POTENTIAL CANDIDATE — UNVERIFIED — SOURCING-ONLY — NOT EVALUATED — NOT CONTACTED — NOT AUTHORIZED FOR ENGAGEMENT`.

The minimum record may contain only public professional identity, public role/affiliation, neutral public qualification descriptors relevant to sourcing, package linkage, exact public source locator, access date, term used, provenance, lifecycle timestamps, and the required status label.

Candidate identity records are confidential Owner-controlled governance records. They must not be provided to GPT L3 by default, published, shared externally, disclosed to a candidate, transferred into an evidence corpus, or reused for another purpose.

Forbidden content includes private contact details; personal data beyond necessity; sensitive, protected, health, political, biometric, financial, private-interaction, Safety, participant, real-case, allegation, emergency, credential, production, or confidential information; inferred traits; suitability conclusions; rankings; recommendations; and project-private material.

## 7. Retention and deletion

Candidate records may be retained for no more than 90 calendar days after sourcing decision closure. In this document, `sourcing decision closure` means the Owner-recorded closure of the bounded sourcing activity; it does not mean candidate evaluation, selection, or engagement.

Delete candidate records and derived identity-bearing copies earlier when:

- the sourcing purpose ends;
- authorization expires or is revoked;
- the Owner requests deletion;
- necessity no longer exists;
- provenance or confidentiality fails;
- a stop condition requires deletion.

The 90-day period is a maximum, not a default minimum. After deletion, retain only a minimal deletion audit event: record ID, package, deletion date, Owner as responsible human, and reason category, without residual candidate identity data.

## 8. Audit owner and mechanism

- **Audit owner:** Owner.
- **Audit scope:** sourcing authorization, approved channels, candidate-record lifecycle, and stop conditions.
- **Mechanism:** an Owner-controlled, access-restricted lifecycle log maintained alongside the candidate records. This document defines the minimum event schema; it does not create the log or any candidate record.

For each sourcing event, the audit must record:

- `ORS-01` and `OSOI-02`;
- active package;
- timestamp and Owner as actor;
- approved source category and exact public locator;
- neutral search term used;
- candidate record ID, without copying identity into governance-only summaries;
- package count before/after and sourcing-window state;
- record creation, access, correction, retention review, closure, deletion, or stop event;
- provenance and confidentiality check;
- attestation that no evaluation, ranking, selection, contact, engagement, spend, evidence transfer, or review occurred;
- any AI assistance disclosure required by Phase 20B.

Aggregate governance review may report counts, compliance state, and stop events without candidate identities.

## 9. AI boundary

OpenCode, DeepSeek, and ChatGPT may assist with criteria organization, summaries of public sources supplied within the authorized workflow, checklist preparation, formatting, and documentation.

AI may not choose, rank, score, recommend, approve, reject, or select candidates; verify specialist authority alone; discover candidates autonomously; contact anyone; make sourcing decisions; act as sourcing lead/custodian; or represent Owner authority. The Owner remains accountable for every search and record.

DeepSeek legal usage is classified only as `AI-assisted legal research preparation`. It is not legal opinion, compliance conclusion, source evidence by default, or a legal specialist.

## 10. Stop conditions

Stop before or during sourcing if:

- GPT L3 review and explicit Owner operational approval are absent, unclear, revised, rejected, deferred, expired, or revoked;
- the 14-day window has not begun or has ended, or a package count reaches its limit;
- activity concerns deferred `SRA-PL-01`;
- a source falls outside the approved category or exact locator/provenance cannot be recorded;
- a term falls outside the neutral descriptor boundary;
- Owner-only access or confidentiality cannot be maintained;
- information exceeds minimum necessary public professional information or involves sensitive/private/Safety/participant/confidential data;
- evaluation, qualification verification as a decision, comparison, ranking, recommendation, selection, contact, availability request, engagement, commissioning, spend, evidence transfer, or specialist review becomes necessary;
- an AI tool would choose, rank, verify authority alone, contact, decide, or operate autonomously;
- lifecycle audit, retention, deletion, purpose, necessity, authorization, or package linkage becomes unclear.

On stop, cease search and record creation immediately, record the minimum stop event, restrict access, delete records when required, and obtain explicit Owner direction. No continuation or later-stage authority is inferred.

## 11. Readiness and downstream state

| Area | Phase 29 result |
| --- | --- |
| `ORS-01` | Remains `AUTHORIZED` in principle |
| `SRA-RM-01` | `ACTIVE`; operational inputs provisioned, pending approval |
| `SRA-SM-01` | `ACTIVE`; operational inputs provisioned, pending approval |
| `SRA-PL-01` | `DEFERRED`; candidate limit 0; no sourcing |
| Operational sourcing/search | Not started; no window active until GPT L3 and Owner approval |
| Candidate records/identities | None created or identified |
| Candidate evaluation/ranking/selection | `NOT AUTHORIZED` |
| Contact | `NONE` |
| Engagement/hiring/commissioning/spend | `NONE` |
| Evidence transfer | `NONE` |
| Specialist review | `NOT READY` |
| U-01 through U-15 | Remain `BLOCKING` |
| OD-01 through OD-06 | No change |
| ADR-001 through ADR-005 | No change |
| Phase 11 gates | No change |
| Technical design/implementation | Not authorized; no artifacts created |

## 12. Validation and stop

Validation must confirm:

- Owner is recorded as sourcing lead, custodian, sole candidate-record accessor, and audit owner;
- `SRA-RM-01` and `SRA-SM-01` are active with separate limits of 5, while `SRA-PL-01` is deferred with limit 0;
- the 14-day window begins only after recorded operational approval;
- the adjusted category-level allowlist, neutral-term rule, exact-locator audit, confidentiality boundary, 90-day maximum retention, deletion triggers, and audit mechanism are present;
- GPT L3 is governance-only and receives no candidate identities by default;
- AI remains assistance only and DeepSeek legal use remains AI-assisted legal research preparation;
- all later stages retain their exact unauthorized states;
- no sourcing, search, candidate identification/record creation, evaluation, ranking, selection, contact, engagement, commissioning, spending, evidence transfer, specialist review, technical design, implementation planning, or code occurred.

Stop after documentation completion. Wait for GPT L3 review and explicit Owner operational approval. No sourcing window has begun.
