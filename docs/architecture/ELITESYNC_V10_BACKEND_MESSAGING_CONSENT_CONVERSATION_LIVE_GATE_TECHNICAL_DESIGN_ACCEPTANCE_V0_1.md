# EliteSync v10｜Backend Messaging Consent + Conversation Live Gate Technical Design Acceptance｜v0.1

Status: `ACCEPTED — INDEPENDENT MESSAGING CONSENT LIFECYCLE AND TWO-INPUT CONVERSATION LIVE GATE ESTABLISHED — HISTORY/TRACK-2 BOUNDARIES PRESERVED — BA-06/07 STILL WAIT ON BA-02/03 — NO BACKEND IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-14 (Asia/Singapore)

Accepted candidate:

`e522326b8b9dd38bbc9817210809606c63730a21`

Accepted result blob:

`d35909ede0bb8c0f8891581ce69c50d7758d914d`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

## 1. Independent acceptance

The BA-05 technical-design candidate is accepted for its authorized semantic-design purpose.

It correctly preserves Product Connection, Messaging Consent, Product Conversation live-gate composition, and Product Conversation lifecycle/access as separate semantic responsibilities. It creates no endpoint, API, schema, storage, service topology, client integration, historical Conversation authority, legal conclusion, or implementation authority.

## 2. Accepted Messaging Consent lifecycle

The exact Messaging Consent vocabulary is:

`MC_NONE`, `MC_PENDING`, `MC_ACTIVE`, `MC_DECLINED`, `MC_WITHDRAWN`, `MC_REVOKED`.

Accepted direct transitions for one consent identity are:

- `MC_NONE -> MC_PENDING`: request by either participant in the current authoritative `CN_ACTIVE` Product Connection context;
- `MC_PENDING -> MC_ACTIVE`: accept by the bound recipient of the same current pending request;
- `MC_PENDING -> MC_DECLINED`: decline by the bound recipient;
- `MC_PENDING -> MC_WITHDRAWN`: withdraw by the bound requester;
- `MC_ACTIVE -> MC_REVOKED`: revoke by either bound participant.

Any unlisted direct transition is invalid. There is no direct `MC_NONE -> MC_ACTIVE` path.

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for the old consent identity. A later consent attempt requires a fresh consent context/request and a new `MC_NONE -> MC_PENDING -> MC_ACTIVE` path.

Messaging Consent has no pause/resume/close state; those remain Product Conversation lifecycle concepts under separately established authority.

## 3. Accepted two-input live gate

Product Conversation live access requires two independently current inputs:

1. current participant-bound authoritative Product Connection evidence establishing `CN_ACTIVE` for the current Product Connection aggregate/context; and
2. current participant/purpose/current-Connection-context-bound authoritative Messaging Consent evidence establishing `MC_ACTIVE`.

Both inputs must independently satisfy owner/provenance, participant, audience, purpose, revision/currentness, freshness, and context binding.

One valid input cannot repair or substitute for stale, unknown, unavailable, superseded, incomparable, mismatched, or historical evidence in the other input.

Any Product Connection state other than current valid `CN_ACTIVE`, any Messaging Consent state other than current valid `MC_ACTIVE`, any historical aggregate/context, or any participant/audience/purpose mismatch fails closed.

## 4. Read/send separation

Live read and live send are accepted as two separate grant dimensions.

For the current MVP design they share the same two authoritative prerequisites, but this does not collapse their meaning:

- read authority does not imply send authority;
- send authority must be re-evaluated at send time;
- loss of current `CN_ACTIVE` removes new live send authority and, under the current fail-closed MVP posture, live read authority;
- authoritative `MC_REVOKED` removes new live send authority and, under the current fail-closed MVP posture, live read authority within the revoked scope;
- a future separate historical/read authority may define a different bounded result, but none is created here.

## 5. Revision, revocation, concurrency, and restart acceptance

The candidate correctly preserves independent Product Connection and Messaging Consent revision lineages and creates no global revision.

It also correctly establishes:

- newer non-active/terminal Product Connection evidence supersedes historical `CN_ACTIVE` for live-gate use;
- newer `MC_REVOKED` supersedes historical `MC_ACTIVE` for the revoked scope;
- stale or incomparable evidence cannot authorize protected live access;
- projection/transport/cache/UI arrival order cannot establish authority;
- transport timeout requires authoritative reconciliation rather than inferred success/failure;
- duplicate, conflicting, and reordered consent intents resolve against authoritative current revision and domain preconditions;
- a new Product Connection aggregate inherits neither historical Messaging Consent nor historical Conversation live grants;
- the new aggregate must establish fresh `CN_ACTIVE` and then complete a fresh Messaging Consent lifecycle.

## 6. Privacy and history boundary

The fail-closed private-data construction boundary is accepted: private Conversation list/detail/message/draft/realtime protected data must not be treated as available before live-read authority passes, and send must re-check live-send authority.

This acceptance does not create or decide:

- historical Conversation read after revoke/pause/close/Block/account exit;
- retention periods or schedules;
- export/access/portability;
- deletion/erasure or peer-visible effects;
- account-exit handling;
- rights-request verification/timelines/appeals;
- legal hold/backups or region-specific data-right implementation.

Those remain separate Track-2/material-fact/legal routes.

## 7. Successor release state

BA-05 is now accepted.

Therefore:

- BA-02 Runtime Readiness authority remains `ELIGIBLE_FOR_BOUNDED_TECHNICAL_DESIGN`;
- BA-03 Canonical Match authority remains `ELIGIBLE_FOR_BOUNDED_TECHNICAL_DESIGN`;
- BA-06 Calm Home live read model remains blocked until BA-02 and BA-03 are also accepted, in addition to the already accepted BA-04/05;
- BA-07 Notification authority remains blocked until the required BA-02/03 event/evidence obligations are also accepted.

No backend implementation authority is created by this acceptance.

## 8. Final classification

`BA-05 TECHNICAL DESIGN ACCEPTED — INDEPENDENT MESSAGING CONSENT LIFECYCLE + TWO-INPUT LIVE CONVERSATION GATE ESTABLISHED — READ/SEND SEPARATION AND TRACK-2 HISTORY BOUNDARY PRESERVED — BA-02/03 REMAIN BEFORE BA-06/07 — NO IMPLEMENTATION AUTHORITY CREATED`
