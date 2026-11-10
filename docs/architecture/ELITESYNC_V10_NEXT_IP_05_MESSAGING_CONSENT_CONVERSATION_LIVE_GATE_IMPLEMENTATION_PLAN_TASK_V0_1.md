# EliteSync v10｜NEXT IP-05 Messaging Consent + Conversation Live-Gate Implementation Plan Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY IMPLEMENTATION PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `a3a01f01218b20271753b4f2129979af61c5ed7d`

## 1. Purpose and authority

Produce one technology-neutral documentary implementation plan for independent Messaging Consent authority plus the Product Conversation live read/send gate.

This task consumes accepted IP-01 Common Backend Implementation Contract, accepted IP-04 Product Connection Implementation Plan, and accepted BA-05 Messaging Consent + Conversation Live Gate technical design. It must not change their semantics.

This task does not authorize code, API, schema, database, service, queue, transaction mechanism, clock, deployment, Flutter/client work, production processing, private-data activity, legal work, Safety Operations, Conversation-history design, or runtime execution.

## 2. Required first reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the exact bounded authorities required for IP-05:

1. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`
8. accepted Post-BA01..BA07 implementation-entry review, IP-05 lane and directly dependent common sections only.

Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_IMPLEMENTATION_PLAN_V0_1.md`

## 4. Exact Messaging Consent lifecycle

Preserve exactly:

`MC_NONE / MC_PENDING / MC_ACTIVE / MC_DECLINED / MC_WITHDRAWN / MC_REVOKED`

Allowed direct transitions remain exactly:

| Source | Action | Required actor | Target |
|---|---|---|---|
| `MC_NONE` | request | Either participant in current authoritative `CN_ACTIVE` Connection context | `MC_PENDING` |
| `MC_PENDING` | accept | Bound recipient of the same current pending request | `MC_ACTIVE` |
| `MC_PENDING` | decline | Bound recipient | `MC_DECLINED` |
| `MC_PENDING` | withdraw | Bound requester | `MC_WITHDRAWN` |
| `MC_ACTIVE` | revoke | Either bound participant | `MC_REVOKED` |

Any unlisted direct transition is invalid.

There is no direct `MC_NONE -> MC_ACTIVE`.

Messaging Consent has no pause/resume/close states. Conversation pause/resume/close remain separate Product Conversation lifecycle semantics under separate authority.

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for the existing consent identity. Later attempts require a fresh consent context/request identity, fresh bindings, fresh logical intent, and a new `MC_NONE -> MC_PENDING -> MC_ACTIVE` path.

## 5. Two-input Conversation live gate

Define technology-neutral implementation responsibilities for a live-gate evaluator that consumes exactly two independently current inputs:

1. current/fresh participant-bound `CN_ACTIVE` for the exact current Product Connection aggregate/context; and
2. current/fresh participant-, Conversation-purpose-, and Connection-context-bound `MC_ACTIVE`.

The evaluator must own neither input and must not back-write either authority.

One valid input cannot repair, refresh, replace, infer, or order the other.

Live read and live send are separate decision dimensions. For the current MVP they share the same two prerequisites, but they must not be collapsed into one permanent grant.

A future separately accepted history/read authority may differ. This task creates no history authority.

## 6. Required implementation responsibility decomposition

Define technology-neutral responsibilities for at least:

- Messaging Consent request writer;
- requester/recipient binding;
- recipient accept/decline handling;
- requester withdrawal handling;
- active-grant revocation handling;
- terminal/fresh-consent-context handling;
- independent Messaging Consent revision/currentness/freshness;
- correction/revocation/supersession propagation;
- logical intent/idempotency and ambiguous transport reconciliation;
- Product Connection evidence adapter consuming only current aggregate current/fresh `CN_ACTIVE`;
- Messaging Consent evidence adapter consuming only current context current/fresh `MC_ACTIVE`;
- live-read evaluator;
- live-send evaluator;
- privacy-minimal Conversation live-access projection;
- Product Conversation lifecycle restriction adapter, without inventing Conversation mutation authority;
- downstream Home / Notification / API / persistence / client planning outputs.

## 7. Fail-closed truth matrix

Cover at minimum:

- current `CN_ACTIVE` + current `MC_ACTIVE` -> live read/send may grant separately;
- current `CN_ACTIVE` + `MC_NONE`;
- `MC_PENDING`;
- `MC_DECLINED`;
- `MC_WITHDRAWN`;
- `MC_REVOKED`;
- stale/superseded/unknown/unavailable/incomparable MC evidence;
- `CN_PENDING`;
- `CN_PAUSED`;
- `CN_CLOSED`;
- `CN_DECLINED`;
- `CN_WITHDRAWN`;
- `CN_EXPIRED`;
- historical/superseded `CN_ACTIVE`;
- `CN_ACTIVE` from wrong/historical aggregate;
- `MC_ACTIVE` bound to wrong/historical aggregate;
- participant mismatch;
- audience mismatch;
- purpose mismatch;
- projection lag/currentness unknown for either input;
- valid MC with invalid CN;
- valid CN with invalid MC;
- newer `MC_REVOKED` after old `MC_ACTIVE`;
- newer non-active Connection revision after old `CN_ACTIVE`;
- new Product Connection aggregate with old `MC_ACTIVE`;
- historical Conversation row or route attempting to substitute for authority.

Every non-positive case must deny the affected live read/send decision without inventing deletion, absence, guilt, punishment, Safety, Relationship, or history outcome.

## 8. Idempotency / concurrency / reconciliation cases

Cover at minimum:

- duplicate Messaging Consent request;
- duplicate recipient acceptance;
- accept vs decline;
- accept vs requester withdrawal;
- revoke concurrent with protected live send;
- revoke concurrent with protected live read;
- stale `MC_ACTIVE` after revoke;
- Connection pause/close concurrent with protected live use;
- changed semantic input under reused idempotency identity;
- transport timeout after consent intent may have committed;
- reordered projection delivery;
- participant/purpose/audience/aggregate mismatch;
- new consent context reusing old identity;
- new Product Connection aggregate reusing old consent evidence;
- historical `CN_ACTIVE` and `MC_ACTIVE` pair after newer evidence exists.

Resolve against authoritative current revisions and exact domain preconditions, never client arrival order.

## 9. Conversation lifecycle interaction

Preserve accepted Product Conversation vocabulary:

`CV_LOCKED / CV_PENDING_CONSENT / CV_ACTIVE / CV_PAUSED / CV_CLOSED`

This task must not invent Product Conversation mutation authority.

If a future authoritative Conversation lifecycle source establishes `CV_PAUSED` or `CV_CLOSED`, current `MC_ACTIVE` must not override that lifecycle restriction.

Messaging Consent must never adopt pause/resume/close states merely to mirror Conversation lifecycle.

## 10. Private-data boundary

No private Conversation content may be built, fetched, projected, prefetched, cached for display, or otherwise treated as live-readable before the current live-read gate passes.

No draft/send operation may be treated as authorized before the current live-send gate passes.

An existing Conversation row, unread count, cached message, draft, route, peer ID, notification identity, transport connection, Match state, legacy peer, or local client state never grants access.

This task must not define:

- historical Conversation readability;
- retention;
- export/access/portability;
- deletion/erasure;
- account-exit behavior;
- peer-visible deletion effects;
- backups/legal hold;
- rights-request workflows;
- region-specific data-right implementation.

These remain separate Track-2 / legal / material-fact seams.

## 11. Retained seams

For every retained seam, classify whether it blocks:

- IP-05 core plan itself;
- one adapter/slice only;
- later implementation execution;
- production only.

Historical Conversation access/data-rights seams must not be reclassified as live-gate blockers unless an exact current live operation genuinely depends on them.

## 12. Downstream contract

The plan must define privacy-minimal, technology-neutral outputs needed later by:

- IP-06 Home;
- IP-07 Notification;
- IP-08 API/interface planning;
- IP-09 persistence/schema planning;
- IP-10 client integration planning.

Downstream consumers must receive separate live-read and live-send decisions plus the minimum evidence needed to revalidate or explain conditions. They must not receive private Conversation content merely because the gate evaluator knows participant/context identities.

## 13. High-density validation

Include at least 240 independently checkable validation rows.

Report exactly:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary UNKNOWN or blocker; complete every independent row still evaluable.

For every retained unknown, state its affected layer and blocker class.

## 14. Explicit non-goals

Do not choose or implement:

- endpoints/protocol/wire format;
- schema/database/index/key design;
- transactions/locks/CAS;
- queue/event log/broker;
- language/framework;
- service/module/deployment topology;
- clock/scheduler;
- Flutter/client code;
- Conversation-history storage or rights implementation;
- legal conclusions;
- production/private-data processing.

## 15. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-05-messaging-consent-conversation-live-gate-implementation-plan-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, or start IP-06/IP-07/IP-08.

Expected success classification:

`MESSAGING CONSENT + CONVERSATION LIVE-GATE IMPLEMENTATION PLAN ESTABLISHED — INDEPENDENT MC WRITER / TWO-INPUT READ-SEND GATE / FAIL-CLOSED PRIVATE-DATA PLAN EXPLICIT — HISTORY SEAMS PRESERVED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
