# EliteSync v10｜Product Connection Post-Terminal Lifecycle Owner Decision Closure｜v0.1

Status: `OWNER ACCEPTED — POST-TERMINAL NEW LIFECYCLE PERMITTED ONLY AS NEW AGGREGATE/REQUEST — OLD TERMINAL AGGREGATE/REQUEST NEVER REOPENED — BA-04 BLOCKER CLOSED — NO IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Decision base: `b9d2f0d281b8a8116a02daa11cda0392e9d6c7b5`

## 1. Owner decision

The Owner explicitly accepts the recommended Product Connection post-terminal lifecycle rule.

After `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, or `CN_EXPIRED`, a later Product Connection lifecycle may be initiated if the then-current product eligibility and authority conditions permit it.

However, any such later lifecycle MUST begin as a new Product Connection aggregate/request. The prior terminal Connection/request is never reopened, resumed, mutated back to a non-terminal state, or reused as the consent basis for the new lifecycle.

## 2. Binding restart rule

For an already terminal Product Connection/request:

- `CN_CLOSED` remains terminal for that Connection;
- `CN_DECLINED` remains terminal for that request;
- `CN_WITHDRAWN` remains terminal for that request;
- `CN_EXPIRED` remains terminal for that request;
- there is no transition from any of those terminal states back to `CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, or `CN_PAUSED` within the old aggregate/request;
- a later lifecycle, when allowed, starts from a distinct new aggregate/request context and follows the accepted `CN_NONE -> CN_PENDING` request path;
- recipient acceptance of that new authoritative `CN_PENDING` remains the sole consent-establishing transition to the new lifecycle's `CN_ACTIVE` state.

This decision therefore creates no `reopen`, `reactivate`, `retry-old-request`, or equivalent transition on a terminal aggregate/request.

## 3. Identity and authority consequences

The new lifecycle must be semantically distinguishable from the terminal old lifecycle. This decision requires a new aggregate/request identity at the semantic authority layer but does NOT select any concrete ID syntax, key format, schema, endpoint, database model, service boundary, sequence generator, clock, or persistence mechanism.

The old lifecycle remains historical authoritative evidence within its accepted scope. It cannot serve as:

- current Connection consent;
- a shortcut around a new recipient acceptance;
- messaging consent;
- Conversation read/send authority;
- evidence that a new request must be accepted;
- evidence of guilt, Safety finding, punishment, fraud, deception, or objective incompatibility.

## 4. Relationship to APP-T06 and BA-04-SR01

This decision supplements, and does not replace, the accepted APP-T06 lifecycle foundation.

APP-T06 remains controlling for the existing aggregate/request transitions:

- `CN_NONE -> CN_PENDING` by request;
- `CN_PENDING -> CN_ACTIVE` by recipient acceptance;
- `CN_PENDING -> CN_DECLINED` by recipient decline;
- `CN_PENDING -> CN_WITHDRAWN` by initiator withdrawal;
- `CN_PENDING -> CN_EXPIRED` by the system under an established expiry policy;
- `CN_ACTIVE -> CN_PAUSED` by either connected participant;
- `CN_ACTIVE -> CN_CLOSED` by either connected participant;
- `CN_PAUSED -> CN_ACTIVE` by the pausing participant;
- `CN_PAUSED -> CN_CLOSED` by either connected participant.

Any unlisted direct transition remains invalid for the existing aggregate/request.

BA-04-SR01 identified exactly one retained gap: whether a later lifecycle could begin after terminality and whether it must use a new aggregate/request. This Owner decision closes that gap.

## 5. Preserved boundaries

This decision preserves:

- `Match != Connection != Conversation != Relationship`;
- Match mutual acceptance does not create Connection consent;
- no direct `CN_NONE -> CN_ACTIVE`;
- recipient acceptance of the same new authoritative `CN_PENDING` remains required for every newly established `CN_ACTIVE` lifecycle;
- Connection authority remains separate from messaging consent;
- `CN_ACTIVE` remains necessary but not sufficient for Product Conversation;
- no historical Conversation authority is created;
- exact expiry duration/policy remains `UNKNOWN`;
- Track-2/legal/material-fact blockers remain unchanged;
- no backend/API/schema/storage/service/client implementation authority is created.

## 6. Delegated similar-decision convention

The Owner additionally delegates future similar decisions to ChatGPT/GPT L3 when all of the following are true:

- the decision is reversible or readily revisable;
- it is product/governance/architecture-layer only;
- it is consistent with accepted upstream authority and does not materially expand scope;
- it creates no participant/data activity, private-data access, Safety Operations, production access, processing authority, implementation authority, formal legal conclusion, irreversible external commitment, spend, contract, hiring, or deployment authority.

Within that bounded class, GPT L3 may select and record the recommended option without repeatedly requesting Owner confirmation.

This delegation does NOT waive explicit Owner gates for implementation authorization, formal legal decisions, Safety Operations, real user/data activity, production access, irreversible external actions, spend/contracts, deployment, or other material authority expansion.

## 7. BA-04 effect

The sole retained lifecycle-source blocker identified by BA-04-SR01 is closed.

BA-04 Product Connection Authority Technical Design may now be re-dispatched under a fresh exact task sheet binding:

1. accepted APP-T06 lifecycle source;
2. BA-04-SR01 result and acceptance;
3. this Owner decision closure;
4. accepted BA-01 common authority evidence envelope.

This decision does not itself perform BA-04 technical design and does not authorize backend implementation.

## 8. Final classification

`PRODUCT CONNECTION POST-TERMINAL LIFECYCLE DECISION CLOSED — FUTURE LIFECYCLE MAY BEGIN ONLY AS NEW AGGREGATE/REQUEST — OLD TERMINAL LIFECYCLE NEVER REOPENED — BA-04 MAY BE RE-DISPATCHED — NO IMPLEMENTATION AUTHORITY CREATED`
