# EliteSync v10｜Backend Product Connection Authority Technical Design Acceptance｜v0.1

Status: `ACCEPTED — PRODUCT CONNECTION AUTHORITY TECHNICAL DESIGN ESTABLISHED — COMPLETE CN LIFECYCLE INCLUDING NEW-AGGREGATE RESTART RULE FIXED — BA-05 UPSTREAM GATE RELEASED — NO BACKEND IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`0493e282d7dce06791d91b7a4189ee82a64dd809`

Accepted result blob:

`e93ab283efb6b05aa7fbc1487536c174a7280a8e`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

## 1. Independent acceptance

The BA-04 technical-design candidate is accepted for its authorized semantic-design purpose.

It preserves the accepted APP-T06 lifecycle, the independently accepted BA-04-SR01 source-resolution result, and the Owner-accepted post-terminal new-aggregate rule. It introduces no endpoint, wire format, schema, persistence, service topology, deployment, client integration, messaging-consent authority, Conversation authority, expiry value, or legal conclusion.

## 2. Accepted lifecycle contract

The exact Product Connection vocabulary remains:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

The accepted direct transitions for one aggregate/request are:

- `CN_NONE -> CN_PENDING`: request by either currently eligible candidate acting as initiator/requester;
- `CN_PENDING -> CN_ACTIVE`: accept by the bound recipient only;
- `CN_PENDING -> CN_DECLINED`: decline by the bound recipient;
- `CN_PENDING -> CN_WITHDRAWN`: withdraw by the bound initiator/requester;
- `CN_PENDING -> CN_EXPIRED`: system under an established expiry policy;
- `CN_ACTIVE -> CN_PAUSED`: pause by either connected participant;
- `CN_ACTIVE -> CN_CLOSED`: close by either connected participant;
- `CN_PAUSED -> CN_ACTIVE`: resume by the participant who caused the current pause;
- `CN_PAUSED -> CN_CLOSED`: close by either connected participant.

Any unlisted direct transition is invalid. Direct `CN_NONE -> CN_ACTIVE` remains forbidden.

## 3. Accepted terminality and restart rule

`CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED` are terminal for the existing Connection/request identity. The old identity cannot be reopened, reset, reactivated, resumed, extended, or reused.

A later Product Connection lifecycle may exist only as a semantically distinct new aggregate/request after then-current eligibility/authority permits it. That later lifecycle must establish fresh participant/role/audience/purpose/provenance/revision/freshness/logical-intent bindings, begin with its own `CN_NONE -> CN_PENDING` request, and require the new bound recipient's acceptance of that same new authoritative pending request before a new `CN_ACTIVE` may be established.

Old aggregate identity, prior `CN_ACTIVE`, prior idempotency identity, historical pairing, or old permitted-action evidence cannot shortcut the new lifecycle.

## 4. Revision, idempotency, and concurrency acceptance

The candidate correctly applies BA-01 common-envelope rules:

- mutations require current authoritative source revision and usable freshness;
- stale, superseded, incomparable, mismatched, unavailable, or unknown evidence fails closed;
- permitted actions remain descriptive and non-self-authorizing;
- idempotency identity correlates retries but does not authenticate, authorize, order, or prove success;
- duplicate and reordered intents resolve against authoritative current revision rather than client or transport arrival order;
- transport timeout does not prove mutation failure and requires authoritative reconciliation;
- conflicting accept/decline/withdraw/pause/close intents cannot author mutually incompatible outcomes against the same controlling revision;
- older projections cannot roll authority backward.

## 5. BA-05 downstream boundary

BA-05 may consume only current Product Connection evidence for the current aggregate that establishes:

- Product Connection authority owner/provenance;
- exact participant set;
- current authoritative `CN_ACTIVE`;
- independent Product Connection lineage/revision/currentness/usable freshness; and
- audience/purpose bindings appropriate to live-gate evaluation.

This is only one necessary input. It is not messaging consent, Product Conversation availability, read authority, send authority, history authority, retention/export/deletion authority, or Relationship authority.

A historical/superseded `CN_ACTIVE`, `CN_PAUSED`, `CN_PENDING`, any terminal state, or evidence from another aggregate cannot satisfy BA-05's Product Connection input.

## 6. Preserved boundaries

The acceptance preserves:

- `Match != Connection != Conversation != Relationship`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- `ROUTE IDENTITY != CONSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`;
- Match mutual acceptance does not create Product Connection authority;
- Connection authority does not create messaging consent or Conversation read/send authority;
- decline, withdrawal, expiry, pause, and close do not establish guilt, Safety findings, punishment, fraud, deception, or objective incompatibility;
- exact Product Connection expiry policy remains `UNKNOWN`;
- Track-2/material-fact/legal blockers remain unchanged.

## 7. Successor release state

The accepted BA01 decomposition required accepted BA-01 and BA-04 technical designs before BA-05 could become eligible for bounded technical design.

Those upstream design gates are now satisfied.

Therefore:

- BA-05 Messaging Consent + Conversation Live Gate: `ELIGIBLE_FOR_BOUNDED_TECHNICAL_DESIGN` under the Owner-delegated bounded-governance convention;
- BA-02 and BA-03 remain independently eligible bounded technical-design lanes;
- BA-06 and BA-07 remain blocked by their remaining upstream accepted-design requirements.

This acceptance does not authorize backend implementation.

## 8. Final classification

`BA-04 TECHNICAL DESIGN ACCEPTED — PRODUCT CONNECTION AUTHORITY CONTRACT ESTABLISHED — COMPLETE TERMINAL/NEW-AGGREGATE LIFECYCLE FIXED — BA-05 DESIGN GATE RELEASED — NO BACKEND IMPLEMENTATION AUTHORITY CREATED`
