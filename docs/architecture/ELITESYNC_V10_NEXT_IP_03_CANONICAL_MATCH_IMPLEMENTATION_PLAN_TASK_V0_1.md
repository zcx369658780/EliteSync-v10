# EliteSync v10｜NEXT IP-03 Canonical Match Implementation Plan Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY IMPLEMENTATION PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `17f50e33c5a5815458ddeb73dffd82b643f32afd`

## 1. Authorization and purpose

IP-03 is authorized only as a bounded documentary implementation-planning task because the accepted IP-01 common backend implementation contract and accepted BA-03 canonical Match authority design exist. This task creates no backend/API/schema/client implementation authority.

Define the technology-neutral implementation responsibility plan for canonical Match participation/proposal/decision handling while preserving the accepted nested Match authority model exactly.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the exact authorities required by this task:

1. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_POST_BA01_BA07_IMPLEMENTATION_ENTRY_DEPENDENCY_REVIEW_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_POST_BA01_BA07_IMPLEMENTATION_ENTRY_DEPENDENCY_REVIEW_V0_1.md`, IP-03 and direct common sections only.

Do not enumerate directories or broaden source reads.

## 3. Exact output

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_IMPLEMENTATION_PLAN_V0_1.md`

Write only that file.

## 4. Required implementation-planning content

Preserve exactly:

Participation:
`NOT_ENROLLED / ENROLLED / PAUSED / WITHDRAWN`

Proposal:
`PENDING / MUTUALLY_ACCEPTED / DECLINED / WITHDRAWN / EXPIRED`

One-sided acceptance remains participant decision evidence inside `PENDING`, not a separate lifecycle state.

Define technology-neutral responsibility boundaries for at least:

- participation-context writer responsibility;
- proposal-context writer responsibility;
- proposal issuance responsibility;
- participant decision-slot handling;
- mutual-acceptance decision boundary;
- participation pause/withdraw cross-scope invalidation of pending proposals;
- terminality and fresh-context/fresh-proposal identity handling;
- projection responsibility consumed by `/progress/match`;
- correction/revocation/supersession propagation;
- logical-intent/idempotency behavior;
- duplicate/reordered/conflicting intent reconciliation;
- ambiguous transport outcome reconciliation;
- prerequisite/policy adapters;
- expiry-policy adapter with fail-closed unresolved behavior;
- current-MVP one-unresolved-proposal constraint as accepted product input;
- downstream contracts for Home, Notification, API/interface, persistence/schema, and client planning.

## 5. Atomicity / consistency planning obligations

Classify, without choosing a mechanism, the decision boundaries required for:

- enrollment transition;
- pause/resume/participation withdrawal;
- proposal issuance;
- participant decision write;
- mutual acceptance establishment from two current decision slots;
- decline vs accept races;
- proposal-withdraw vs accept races;
- participation pause/withdraw concurrent with proposal decision;
- duplicate same-intent proposal issuance;
- duplicate same-intent acceptance;
- fresh proposal after terminal proposal;
- correction/supersession propagation.

Do not select transactions, locks, compare-and-swap, uniqueness constraints, event logs, brokers, queues or storage primitives.

## 6. Retained seams

Preserve as unresolved unless separately accepted:

- proposal expiry duration;
- clock basis/time authority;
- expiry extension/renewal;
- cooldown/re-proposal timing;
- future multi-candidate limits;
- concrete Match eligibility/readiness prerequisites;
- proposal-withdraw product-authorized reason categories;
- future participant decision-retraction mutation;
- optional AI/personality/astrology/reference-signal allowlist/provenance policy.

For each seam state whether it blocks IP-03 itself, a single adapter/slice, later execution, or production only.

## 7. Explicit non-goals

Do not select or implement:

- exact expiry/timing policy;
- ranking/Compatibility total score;
- Connection creation;
- Messaging Consent;
- Conversation authority;
- Relationship state;
- endpoint/API/wire format;
- database/schema/table/index;
- transaction/locking mechanism;
- language/framework;
- service/module/deployment topology;
- clock/scheduler;
- Flutter/client mechanism.

## 8. High-density validation

Complete at least 220 independently checkable validation rows spanning lifecycle preservation, actor/source/target rules, decision-slot semantics, terminality, fresh identity, concurrency/idempotency, projection, privacy, non-substitution, retained seams, downstream dependencies, and non-goals.

Report exactly:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary UNKNOWN or blocker; complete every independently evaluable row.

## 9. Stop boundary

Publish the candidate on a bounded review branch and STOP.

Do not merge or self-accept.
Do not start IP-04/IP-05/IP-06/IP-07/IP-08/IP-09/IP-10.
Do not implement backend/client code.

Expected success classification:

`CANONICAL MATCH IMPLEMENTATION PLAN ESTABLISHED — NESTED PARTICIPATION/PROPOSAL RESPONSIBILITY / MUTUAL-ACCEPTANCE / CONCURRENCY PLAN EXPLICIT — POLICY SEAMS RETAINED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
