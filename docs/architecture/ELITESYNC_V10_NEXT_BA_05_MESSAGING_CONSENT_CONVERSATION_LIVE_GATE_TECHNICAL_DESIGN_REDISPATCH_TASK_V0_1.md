# EliteSync v10｜NEXT BA-05 Messaging Consent + Conversation Live Gate Technical Design Redispatch Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `7f82926e25f453826fd19385f88eec567af874ae`

## 1. Authorization and purpose

BA-05 is re-dispatched under the Owner-delegated bounded-governance convention after the Messaging Consent lifecycle source gap was explicitly closed by:

`docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`

This task authorizes exactly one bounded semantic/interface technical-design artifact for Messaging Consent + Product Conversation live gate.

It does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client changes, legal closure, Conversation history/retention/export/deletion design, compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only binding/revision/freshness/permitted-action/idempotency/composition sections needed by BA-05
3. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`, only downstream BA-05 evidence boundary and aggregate/revision rules
5. `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_RESULT_V0_1.md`, only Product Conversation access/lifecycle foundation sections
8. `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`, especially D-02, D-03, D-08, D-10
9. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-05 section only
10. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-D only

Do not enumerate directories or broadly search the repository. If an exact path is missing or accepted provenance cannot be established, stop and report rather than inventing a substitute.

## 3. Exact output and scope

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

## 4. Required design content

### 4.1 Authority separation

Define distinct semantic owners for:

- Product Connection authority — owner of current participant-bound `CN_ACTIVE` only;
- Messaging Consent authority — owner of `MC_*` lifecycle evidence;
- Product Conversation live-gate evaluator/projection — composer/consumer of the two inputs, writer of neither;
- Product Conversation lifecycle/access evidence — domain-owned and unable to back-write Connection or Messaging Consent.

Preserve:

`CN_ACTIVE != MC_ACTIVE`

`Messaging Consent != Conversation lifecycle`

`read grant != send grant`

`route identity != consent`

`transport success != domain outcome`

### 4.2 Exact Messaging Consent lifecycle

Use exactly the Owner-accepted vocabulary:

`MC_NONE`, `MC_PENDING`, `MC_ACTIVE`, `MC_DECLINED`, `MC_WITHDRAWN`, `MC_REVOKED`.

Use exactly the accepted transitions:

| Source | Action | Actor | Target |
|---|---|---|---|
| `MC_NONE` | request | either participant in the current authoritative `CN_ACTIVE` Connection context | `MC_PENDING` |
| `MC_PENDING` | accept | bound recipient | `MC_ACTIVE` |
| `MC_PENDING` | decline | bound recipient | `MC_DECLINED` |
| `MC_PENDING` | withdraw | bound requester | `MC_WITHDRAWN` |
| `MC_ACTIVE` | revoke | either bound participant | `MC_REVOKED` |

Any unlisted direct transition is invalid for the current consent identity. There is no direct `MC_NONE -> MC_ACTIVE`.

Do not add pause/resume/close to Messaging Consent; those remain Product Conversation lifecycle semantics.

### 4.3 Messaging Consent terminality / fresh-context rule

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for their current consent request/grant identity.

A later consent attempt may occur only under then-current authoritative `CN_ACTIVE` for the current Product Connection aggregate/context and must create a fresh Messaging Consent request/context with fresh requester/recipient/purpose/revision/freshness/logical-intent bindings and a new `MC_NONE -> MC_PENDING -> MC_ACTIVE` path.

Old `MC_ACTIVE`, old idempotency identity, old request/grant identity, historical Conversation rows/routes, peer identity, or historical Product Connection aggregate may not shortcut the new consent path.

### 4.4 Two-input live-gate truth table

Define Product Conversation live read/send access using exactly two independent current inputs:

1. current authoritative Product Connection evidence establishing participant-bound `CN_ACTIVE` for the current Product Connection aggregate/context; and
2. current authoritative Messaging Consent evidence establishing participant/purpose/Connection-context-bound `MC_ACTIVE`.

At minimum include:

- current/fresh `CN_ACTIVE` + current/fresh `MC_ACTIVE`;
- current/fresh `CN_ACTIVE` + `MC_NONE`;
- current/fresh `CN_ACTIVE` + `MC_PENDING`;
- current/fresh `CN_ACTIVE` + `MC_DECLINED`;
- current/fresh `CN_ACTIVE` + `MC_WITHDRAWN`;
- current/fresh `CN_ACTIVE` + `MC_REVOKED`;
- current/fresh `CN_ACTIVE` + unknown/unavailable/stale/superseded/incomparable consent evidence;
- `CN_PENDING`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` with any consent evidence;
- historical/superseded `CN_ACTIVE`;
- `CN_ACTIVE` from another/historical aggregate;
- `MC_ACTIVE` bound to another/historical Connection aggregate/context;
- participant mismatch;
- audience mismatch;
- purpose mismatch;
- projection/currentness unknown for either input.

One valid input cannot repair the other. Any required unknown/stale/unavailable/mismatched input fails closed without asserting absence, deletion, guilt, Safety outcome, or Relationship meaning.

### 4.5 Live read vs live send

Keep live read and live send as separate grant dimensions.

For the current MVP technical design, both grants use identical current prerequisites:

- current valid `CN_ACTIVE` for the current Connection aggregate/context; and
- current valid `MC_ACTIVE` for the same participants, current Connection context, and Conversation purpose.

Do not collapse read and send into one permanent permission. A read grant never silently becomes send authority.

Loss of current authoritative `CN_ACTIVE` or authoritative `MC_REVOKED` removes new live send authority. Under the current MVP fail-closed live-gate design, those same losses also remove live read authority unless a future separately accepted history/read authority explicitly says otherwise.

### 4.6 Revision/freshness/supersession composition

Define independent revision lineages for Product Connection and Messaging Consent.

The live-gate evaluator creates no global revision that replaces either owner.

Cover:

- newer Connection non-active/terminal evidence supersedes old `CN_ACTIVE` for live-gate use;
- newer `MC_REVOKED` supersedes old `MC_ACTIVE` for live-gate use;
- stale/incomparable/unknown currentness fails closed;
- projection lag cannot promote older evidence over known newer evidence;
- transport timeout/unknown outcome requires authoritative reconciliation, not inferred access/failure;
- correction/revocation acts only within the owning authority's scope.

### 4.7 Product Connection new-aggregate consequence

A new Product Connection aggregate after a historical terminal lifecycle inherits no previous Messaging Consent or Product Conversation live grant.

The new aggregate must independently establish:

- current `CN_ACTIVE`; and
- a fresh Messaging Consent context culminating in new `MC_ACTIVE`.

Historical `CN_ACTIVE`, historical `MC_ACTIVE`, old Conversation row, peer ID, stored route, unread count, cached content, or previous participant pairing grants no access to the new aggregate/context.

### 4.8 Product Conversation lifecycle interaction

APP-T07 `CV_*` vocabulary remains Product Conversation lifecycle/access presentation semantics:

`CV_LOCKED`, `CV_PENDING_CONSENT`, `CV_ACTIVE`, `CV_PAUSED`, `CV_CLOSED`.

Messaging Consent does not adopt `pause`, `resume`, or `close` states.

Where Product Conversation lifecycle itself is paused or closed by a future authoritative Conversation lifecycle source, BA-05 must preserve that lifecycle restriction separately from Messaging Consent. `MC_ACTIVE` alone must not override a Conversation lifecycle pause/close.

Do not invent new Conversation lifecycle mutation authority in this task.

### 4.9 Fail-closed private-data boundary

Preserve at semantic-design level:

- protected Conversation list/detail/message/draft/realtime data is unavailable before live read gate passes;
- stored/direct routes must re-check current live read authority before private detail access;
- send paths must re-check current live send authority;
- route existence, stored Conversation rows, drafts, messages, unread counts, realtime connection, cache, transport success, notification payload identity, `eligibleMatch`, `legacyPeer`, Match capability, or peer identity do not grant access.

No Flutter/client implementation changes are authorized.

### 4.10 Track-2 / historical-access exclusion

Explicitly exclude:

- historical read after revoke, Connection pause/close/terminal outcome, Conversation close, Block, or account exit;
- retention schedules;
- export/access/portability;
- deletion/erasure and peer-visible effect;
- account-exit rights handling;
- legal hold/backups;
- rights-request verification/timelines/refusals/appeals;
- region-specific legal conclusions.

History remains unavailable by default absent separate accepted authority. `MC_REVOKED` is not an erasure/deletion decision.

### 4.11 Concurrency / idempotency truth cases

Include at minimum:

- duplicate same-intent Messaging Consent request;
- duplicate recipient acceptance;
- accept vs decline race;
- accept vs requester-withdraw race;
- revoke concurrent with protected live send attempt;
- stale `MC_ACTIVE` after revoke;
- transport timeout after consent intent may have committed;
- changed semantic input under reused idempotency identity;
- new consent context attempting reuse of old consent identity;
- new Product Connection aggregate attempting reuse of old `MC_ACTIVE`;
- mismatched participant/purpose/aggregate bindings.

Resolve against current authoritative revision and exact domain preconditions, never client arrival order.

## 5. Acceptance evidence required in candidate

The candidate must allow independent verification that:

1. `CN_ACTIVE` and `MC_ACTIVE` remain separate authorities;
2. Messaging Consent vocabulary and transitions exactly match the Owner closure;
3. no direct `MC_NONE -> MC_ACTIVE` exists;
4. terminal consent identities cannot be reopened;
5. fresh consent attempts use fresh contexts;
6. new Product Connection aggregates inherit no prior Messaging Consent;
7. live read and send remain separate grant dimensions;
8. both current valid inputs are required for each live grant under current MVP;
9. revoke/loss/stale/unknown/mismatch fail closed;
10. private protected data is not constructed/fetched before read gate;
11. history/retention/export/delete/legal rights remain excluded;
12. no backend/client implementation mechanism is selected;
13. exact scope is one document and `git diff --check` passes.

## 6. Write and execution boundary

Recommended branch:

`review/next-ba-05-messaging-consent-conversation-live-gate-technical-design-rerun-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

No Flutter/Dart/Gradle/backend runtime/network/private-data/telemetry/Safety/legal-research execution is required or authorized.

## 7. Stop boundary

After publishing the single technical-design candidate:

- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check`;
- STOP.

Do not merge or self-accept.
Do not implement BA-05.
Do not start BA-06/BA-07.
Do not create backend implementation/client-integration tasks.

Expected terminal classification:

`MESSAGING CONSENT + CONVERSATION LIVE GATE TECHNICAL DESIGN ESTABLISHED — INDEPENDENT MC LIFECYCLE AND TWO-INPUT LIVE AUTHORITY EXPLICIT — HISTORY/TRACK-2 BOUNDARIES PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
