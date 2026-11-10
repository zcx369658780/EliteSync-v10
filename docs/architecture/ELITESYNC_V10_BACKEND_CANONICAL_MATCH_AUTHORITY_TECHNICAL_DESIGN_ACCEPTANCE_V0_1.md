# EliteSync v10｜Backend Canonical Match Authority Technical Design Acceptance｜v0.1

Status: `ACCEPTED — NESTED CANONICAL MATCH AUTHORITY ESTABLISHED — BA-06/BA-07 UPSTREAM MATCH GATE RELEASED — NO BACKEND IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-15 (Asia/Singapore)

Accepted candidate:

`55eeeb3baad719d8b022c0066766c8c75a288f41`

Accepted result blob:

`7de2c0e8aa568ff80d87dca941fa3e55a009c178`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

## 1. Independent acceptance

The BA-03 technical-design candidate is accepted for its bounded semantic-design purpose.

It correctly applies the accepted BA-03-RD01 nested Match authority model and the accepted BA-01 common evidence envelope without introducing backend implementation, API/schema/storage/service choices, clock technology, client behavior, Compatibility total score, Product Connection consent, Messaging Consent, Conversation authority, Relationship state, Safety outcome, legal conclusion, or production authority.

## 2. Accepted authority model

Canonical Match authority has two distinct semantic scopes:

1. participant-owned participation context with durable states:
   `NOT_ENROLLED`, `ENROLLED`, `PAUSED`, `WITHDRAWN`;
2. Match-authority-owned two-participant proposal context with durable states:
   `PENDING`, `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, `EXPIRED`.

One-sided acceptance remains current decision evidence inside `PENDING`; it is not a separate lifecycle state.

Participation `WITHDRAWN` and proposal `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, and `EXPIRED` are terminal for their existing identities. Later participation or proposal activity requires fresh identities; later proposals require fresh decision slots and fresh participant decisions.

## 3. Accepted lifecycle and actor semantics

The candidate correctly fixes:

- explicit participant enrollment / pause / resume / participation withdrawal;
- Match-authority/system-only proposal issuance;
- participant acceptance only in the actor's own proposal decision slot;
- mutual acceptance only when both current decision slots accept the same current proposal and participant set;
- participant decline as a terminal proposal outcome;
- Match-authority/system proposal withdrawal under separately authorized reasons/cross-scope effects;
- expiry only under a separately accepted expiry policy;
- pause/withdraw participation invalidating further acceptance of still-pending affected proposals without transferring proposal-writer authority to the participant;
- terminal identities rejecting reopen/reset/mutation; and
- fresh participation/proposal identities for later lifecycles.

## 4. Revision, idempotency, concurrency, and non-substitution

The candidate correctly preserves the BA-01 contract:

- all protected actions require current authoritative source revision, usable freshness, exact actor/role, identity, participants, audience, purpose, and prerequisite bindings;
- permitted actions are descriptive and non-self-authorizing;
- idempotency correlates logical retries but does not authenticate, authorize, order, or prove success;
- duplicate, conflicting, stale, reordered, and timeout-uncertain intents resolve against authoritative current state and revision rather than client/transport arrival order;
- projection lag cannot roll authority backward;
- transport success is not a Match outcome;
- route, candidate card, countdown, compatibility label, local/cache state, legacy DTO, notification, and one participant's action cannot substitute for Match authority.

## 5. Projection and cross-domain boundary

The privacy-minimal `/progress/match` projection may expose only current audience-authorized Match evidence, revision/currentness/freshness, actor-relevant descriptive actions, and separately authorized reason/factor evidence.

It must not create or imply:

- Product Connection consent;
- Messaging Consent;
- Conversation read/send authority;
- Relationship truth;
- a Compatibility total score;
- guilt, Safety finding, punishment, fraud, deception, or objective incompatibility.

`Match != Connection != Conversation != Relationship` remains binding.

## 6. Retained unknowns

The candidate correctly retains, without inventing values or policy:

1. proposal expiry duration;
2. clock basis/time authority;
3. expiry extension/renewal rules;
4. cooldown/re-proposal timing;
5. future multi-candidate limits beyond the current MVP one-unresolved-proposal rule;
6. concrete eligibility/readiness prerequisite contents;
7. product-authorized proposal-withdraw reason categories;
8. any future participant decision-retraction mutation distinct from decline or participation withdrawal; and
9. optional AI/personality/astrology/reference-signal allowlist/provenance policy.

These are future product/material-fact seams, not blockers to the accepted BA-03 authority contract.

## 7. Validation disposition

The candidate reports the authorized high-density matrix as:

`PASS = 81 / RETAINED_UNKNOWN = 9 / BLOCKED = 0`

Independent review finds no hidden lifecycle blocker among the retained unknowns.

## 8. Successor release state

With accepted BA-01, BA-02, BA-03, BA-04, and BA-05 technical designs now established:

- BA-06 Calm Home live read model is eligible for bounded technical design;
- BA-07 Notification domain-event / payload-generation / delivery authority is eligible for bounded technical design.

This acceptance does not authorize backend implementation, client integration, deployment, production data access, legal research, Safety Operations, or any other excluded lane.

## 9. Final classification

`BA-03 TECHNICAL DESIGN ACCEPTED — NESTED PARTICIPATION/PROPOSAL MATCH AUTHORITY ESTABLISHED — MUTUAL ACCEPTANCE / TERMINALITY / CONCURRENCY CONTRACT FIXED — POLICY SEAMS RETAINED — BA-06/BA-07 DESIGN GATES RELEASED — NO IMPLEMENTATION AUTHORITY CREATED`
