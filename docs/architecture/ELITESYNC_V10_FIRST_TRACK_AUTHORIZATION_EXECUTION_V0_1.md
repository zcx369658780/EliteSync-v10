# EliteSync 10.0 First Track Authorization Execution V0.1

Status: PROPOSED — AWAITING GPT L3 AND OWNER REVIEW

Date: 2026-08-24

Authority snapshot: GitHub `main` at `5619a395155dbf5b4f246c13e317d60a08dc8610` before this documentation closeout.

Scope: Record the explicit Owner authorization of Research/Specialist prerequisite work as the first authorized track. This authorization is for bounded research preparation and specialist review only; it does not authorize technical design or implementation.

## 0. Governing boundary

```text
Product Truth
→ Domain
→ Information
→ Architecture
```

The authorized work must remain within this boundary. It may clarify evidence and responsibility needed by Architecture, but it cannot enter technical design or Implementation.

## 1. Authority and input audit

### Repository evidence

- Fresh fetch completed before documentation changes.
- Local branch: `main`.
- Starting local `HEAD`: `3088983b89a34d9d99ae0decb07f157973263030`, the unpushed Phase 13 documentation commit being corrected.
- Starting `origin/main`: `5619a395155dbf5b4f246c13e317d60a08dc8610`.
- Starting worktree: clean.

### Accepted upstream authority

- OD-01 through OD-06 are recorded as accepted.
- ADR-001 through ADR-005 are recorded as `ACCEPTED`.
- Phase 11 defines authorization gates.
- Phase 12 recommends Research/Specialist prerequisite work as the first authorization candidate and distinguishes recommendation from authorization.

### Owner clarification

Owner confirmed that the earlier statement:

> 另外我确认授权：Research/Specialist prerequisite work

is an explicit authorization. Owner subsequently directed Phase 13 to record the outcome as `accepted` and supplied the authorization scope, allowed and forbidden activities, expected artifacts, and authority boundary reproduced below.

This clarification supersedes the prior Phase 13 statement that the Owner outcome was not provided.

## 2. Owner authorization record

| Field | Recorded decision |
| --- | --- |
| Decision ID | `TD-01 — First Future Authorization Track` |
| Owner outcome | `accepted` |
| Authorized track | Research/Specialist prerequisite work |
| Decision date | 2026-08-24 |
| Research authority | Granted within the exact bounded scope below |
| Technical design authority | `NONE` |
| Implementation authority | `NONE` |

### Exact authorization statement

> Authorized Track:
>
> Research/Specialist prerequisite work
>
> Scope:
>
> Resolve architecture-blocking UNKNOWN items through bounded research and specialist review.
>
> Allowed:
>
> - privacy/legal review preparation
> - Safety/moderation review preparation
> - fairness review preparation
> - user research planning
> - accessibility review
> - research methodology refinement
> - operations/human-review responsibility clarification
>
> Forbidden:
>
> - database design
> - API design
> - Backend design
> - Flutter design
> - implementation planning
> - code
> - data collection execution without separate authorization
> - external production changes
>
> Expected artifacts:
>
> - research questions
> - specialist review records
> - evidence summaries
> - updated UNKNOWN register
> - decision impact analysis
>
> Authority:
>
> Research authorization only.
> No design or implementation authority.

### Rationale

No separate Owner rationale was supplied. Phase 12's recommendation remains contextual evidence, but the exact Owner authorization statement above is the decision authority.

## 3. Exact scope

The authorized scope is:

> Resolve architecture-blocking UNKNOWN items through bounded research and specialist review.

The work may clarify whether an `UNKNOWN` remains blocking, has evidence sufficient for an Owner decision, requires a narrower question, or needs additional specialist input. Research and specialist findings do not change OD/ADR status, Phase 11 gate status, or design eligibility until reviewed and explicitly recorded by the proper authority.

The authorization does not silently include every retained `UNKNOWN`. Each future work item must name the bounded question, relevant accepted authority, evidence source, specialist role, affected track, and terminal stop condition.

## 4. Allowed activities

Only the following activity categories are authorized:

- privacy/legal review preparation;
- Safety/moderation review preparation;
- fairness review preparation;
- user research planning;
- accessibility review;
- research methodology refinement;
- operations/human-review responsibility clarification.

“Preparation,” “planning,” “review,” “refinement,” and “clarification” are documentation and analysis activities. They do not authorize participant contact, data collection, production access, technical design, or execution unless a later Owner task explicitly grants that permission.

## 5. Forbidden activities

The following remain forbidden:

- database design;
- API design;
- Backend design;
- Flutter design;
- implementation planning;
- code;
- data collection execution without separate authorization;
- external production changes.

The authorization also does not permit schema, API contract, service/module decomposition, prototype, migration, infrastructure, deployment, credential use, production/staging access, participant recruitment, external commissioning, or personal/sensitive-data processing unless a later explicit authorization states otherwise.

## 6. Specialist roles and authority limits

The authorized preparation work may define or obtain review records from the following roles only where relevant to a bounded question:

- privacy/legal specialist;
- Safety/moderation specialist;
- fairness specialist;
- user-research specialist;
- accessibility specialist;
- research-methodology specialist;
- operations and authorized human-review specialist.

Specialists may provide sourced findings, constraints, options, uncertainties, and professional judgments within their competence. They do not:

- replace Owner product authority;
- accept or revise an ADR;
- authorize a technical design track;
- select implementation architecture;
- convert an unresolved matter into accepted product truth without Owner review.

## 7. Research questions

The authorized work may formulate bounded research questions within the exact scope, including:

1. Which privacy/legal constraints must be resolved before a named architecture-blocking `UNKNOWN` can receive an Owner disposition?
2. Which Safety/moderation responsibilities, review boundaries, or unresolved protections block a named future design track?
3. Which fairness risks, evidence requirements, and stop conditions must be clarified before the relevant decision can proceed?
4. Which user-research and accessibility questions must be planned before user-visible terminology, explanation, control, or exception assumptions can be accepted?
5. Which research-method limitations, source standards, and evidence-strength rules apply to a named unresolved claim?
6. Which operations and authorized human-review responsibilities must be clarified before failure, contest, remedy, or reconstruction authority is considered sufficient?

Every question must trace to a retained `UNKNOWN`, an accepted OD/ADR boundary, and an affected Phase 11 gate. The work may report that evidence is insufficient; it must not force a resolution.

## 8. Expected artifacts

The authorized track may produce only:

- research questions;
- specialist review records;
- evidence summaries;
- an updated `UNKNOWN` register;
- decision impact analysis.

Each artifact must state:

- question and scope;
- provenance and sources;
- author/reviewer role and authority limit;
- applicable jurisdiction/population where relevant;
- observed evidence, inference, assumption, and `UNKNOWN` separately;
- limitations, confidence, dissent, expiry/revisit conditions, and decision-reversing evidence;
- affected OD/ADR boundary and Phase 11 gate;
- what remains blocked;
- whether Owner action is requested.

These are research and review artifacts, not technical designs or implementation plans.

## 9. Validation requirements

Before an artifact may be presented for Owner disposition:

1. Verify repository authority and the exact upstream document versions used.
2. Check that the artifact stays within one bounded authorized question or explicitly approved packet.
3. Validate source provenance, scope, jurisdiction/population, date, limitations, and specialist attribution.
4. Separate evidence, professional judgment, inference, assumption, recommendation, and unresolved fact.
5. Confirm privacy, ethics, consent, security, and minimization boundaries before any proposed human-participant or sensitive-information activity.
6. Confirm no forbidden technical design, implementation, external production change, or unauthorized data collection occurred.
7. Map findings to the updated `UNKNOWN` register and decision impact analysis without self-changing a gate or ADR status.
8. Obtain GPT L3 review of evidence-to-architecture reasoning and overclaim risk.
9. Obtain Owner decision for any proposed `RESOLVED`, `EXCLUDED FROM SCOPE`, `BOUNDED ASSUMPTION AUTHORIZED BY OWNER`, or continuing `BLOCKING` disposition.
10. Complete downstream consistency review before any later design-track eligibility or authorization decision.

## 10. Stop condition

The authorized track must stop when any of the following occurs:

- the bounded research question and expected artifacts are completed;
- work would exceed the listed allowed activities;
- participant contact, data collection execution, personal/sensitive-data handling, external commissioning, or production access becomes necessary without separate authorization;
- work would select or create Database, API, Backend, Flutter, implementation-planning, infrastructure, migration, deployment, or code artifacts;
- evidence cannot support a conclusion within the stated scope;
- specialist authority, provenance, jurisdiction, method, privacy/ethics boundary, or affected Owner decision is unclear;
- a new material `UNKNOWN` or architecture choice requires Owner direction;
- GPT L3 or Owner review identifies a material inconsistency.

Completion of the research track does not automatically authorize a design track. A separate Owner decision is required.

## 11. Downstream authorization state

| Track | State after this Owner decision |
| --- | --- |
| Research/Specialist prerequisite work | `ACCEPTED — BOUNDED RESEARCH AUTHORIZATION` |
| Database Design | `NOT AUTHORIZED` |
| API Design | `NOT AUTHORIZED` |
| Backend Design | `NOT AUTHORIZED` |
| Flutter Design | `NOT AUTHORIZED` |
| Implementation Planning | `NOT AUTHORIZED` |
| Implementation | `NOT AUTHORIZED` |

No finding or artifact from the authorized track changes a downstream state without a separately recorded Owner decision.

## 12. No new ADR decision

No new ADR is created in Phase 13. This authorization selects a bounded prerequisite research track, not a technical architecture choice.

## 13. Validation and review stop

Review must confirm:

- Owner outcome is recorded as `accepted`;
- the exact authorized track, scope, allowed and forbidden activities, specialist roles, research questions, expected artifacts, validation, and stop condition are explicit;
- Research/Specialist prerequisite work is distinct from Database, API, Backend, Flutter, Implementation Planning, and Implementation;
- Product Truth → Domain → Information → Architecture remains intact;
- no database schema, API contract, Backend architecture, Flutter architecture, implementation plan, code, migration, infrastructure, deployment, unauthorized data collection, or external production change was created.

Stop after documentation completion and wait for GPT L3 final review.
