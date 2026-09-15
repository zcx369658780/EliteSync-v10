# EliteSync v10｜NEXT IP-04 Product Connection Implementation Plan Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY IMPLEMENTATION PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `9be6c5049302de55fd24fe0b9438b9b52b4f96e4`

## 1. Purpose and authority

Produce one technology-neutral documentary implementation plan for Product Connection. This task consumes accepted IP-01 and accepted BA-04 without changing their semantics.

This task does not authorize code, API, schema, database, service, queue, transaction mechanism, clock, scheduler, deployment, Flutter/client work, production processing, private-data activity, legal work, Safety Operations, or runtime execution.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_POST_TERMINAL_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`
6. accepted post-BA01..07 implementation-entry review, IP-04 lane and directly dependent common sections only.

Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_V0_1.md`

## 4. Required plan content

Preserve exactly the accepted Product Connection lifecycle:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

Preserve the direct transition rules and actor roles already accepted, including:

- request creates `CN_PENDING`;
- recipient acceptance alone establishes `CN_ACTIVE`;
- recipient decline -> `CN_DECLINED`;
- requester withdrawal -> `CN_WITHDRAWN`;
- authority-governed expiry -> `CN_EXPIRED` only under an established expiry policy;
- `CN_ACTIVE` pause -> `CN_PAUSED` by either connected participant;
- `CN_ACTIVE` close -> `CN_CLOSED` by either participant;
- `CN_PAUSED` resume -> `CN_ACTIVE` by the pausing participant;
- `CN_PAUSED` close -> `CN_CLOSED` by either participant.

Any unlisted transition is invalid for the existing aggregate/request.

Terminal identities remain terminal. Later Connection attempts, where separately permitted, require a fresh aggregate/request, fresh bindings and fresh recipient acceptance. Old terminal identity/revision/idempotency evidence cannot be reopened or reused.

Define technology-neutral implementation responsibilities for:

- Connection aggregate writer;
- request issuance and initiator/recipient role binding;
- recipient acceptance decision boundary;
- pause/resume/close handlers;
- decline/withdraw/expiry handlers;
- terminal/fresh-aggregate handler;
- projection/read responsibility;
- correction/revocation/supersession propagation;
- logical intent/idempotency;
- concurrency/conflict resolution;
- ambiguous transport reconciliation;
- expiry policy adapter;
- downstream BA-05/IP-05 live-gate evidence contract;
- Home / Notification / API / persistence / client planning outputs.

## 5. Concurrency / idempotency cases

Cover at minimum:

- duplicate request;
- duplicate recipient acceptance;
- accept vs decline;
- accept vs requester-withdraw;
- accept vs expiry;
- pause vs close;
- pause vs stale send/access consumer observation;
- resume vs close;
- duplicate pause/resume/close;
- stale revision mutation;
- old aggregate replay after fresh aggregate exists;
- changed semantic input with reused idempotency identity;
- transport timeout after possible commit;
- reordered projection delivery;
- participant/aggregate/role mismatch;
- stale historical `CN_ACTIVE` after newer non-active state.

Resolve against authoritative current revision/domain preconditions, never client arrival order.

## 6. Downstream BA-05 / IP-05 evidence boundary

The plan must make explicit that downstream Conversation live-gate planning may consume only current participant-bound `CN_ACTIVE` evidence for the current aggregate/context with provenance, participant set, lineage/revision/currentness/freshness, audience/purpose and exact aggregate binding.

Historical/superseded `CN_ACTIVE`, `CN_PAUSED`, pending or terminal states, or another aggregate cannot satisfy the live gate.

`CN_ACTIVE` remains necessary but insufficient for Conversation; separate current `MC_ACTIVE` remains required by BA-05.

## 7. Retained seams

Connection expiry duration/policy/clock/extension remains unresolved unless a separately accepted authority establishes it.

Do not invent timing defaults, scheduler semantics or retry behavior.

For every retained seam, classify whether it blocks:

- IP-04 itself;
- one adapter/slice only;
- later implementation execution;
- production only.

## 8. High-density validation

Include at least 220 independently checkable validation rows.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary unknown or blocker; complete every independent row still evaluable.

## 9. Explicit non-goals

Do not choose or implement:

- endpoints/protocol/wire format;
- schema/database/index/key design;
- transactions/locks/CAS;
- queue/event-log/broker;
- language/framework;
- service/module/deployment topology;
- clock/scheduler;
- expiry duration or policy;
- messaging consent;
- Conversation history;
- Flutter/client code.

## 10. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-04-product-connection-implementation-plan-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, or start IP-05.

Expected success classification:

`PRODUCT CONNECTION IMPLEMENTATION PLAN ESTABLISHED — TECHNOLOGY-NEUTRAL AGGREGATE / MUTATION / PROJECTION / CONCURRENCY PLAN EXPLICIT — EXPIRY SEAM RETAINED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
