# EliteSync v10｜Messaging Consent Lifecycle Owner Decision Closure｜v0.1

Status: `OWNER-DELEGATED PRODUCT DECISION ACCEPTED — INDEPENDENT MESSAGING CONSENT LIFECYCLE FIXED — BA-05 SOURCE GAP CLOSED — NO IMPLEMENTATION AUTHORITY CREATED`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Decision base: `5c04a8b42dc00bf16823534dee3287164c9609c3`

## 1. Authority and reason for decision

Under the Owner-delegated bounded-governance convention, this document closes the retained Product Messaging Consent lifecycle gap identified when BA-05 stopped on incomplete accepted source authority.

The accepted APP-T07 foundation establishes Product Conversation `CV_*` access/lifecycle semantics but explicitly leaves Messaging Consent read source and all Messaging Consent mutation authority `NOT YET ESTABLISHED`. It therefore does not provide a complete independent Messaging Consent lifecycle matrix.

This closure is a reversible product/governance-layer decision only. It creates no backend/API/database/schema/service/client implementation authority, no legal conclusion, no production/data-processing authority, and no Conversation-history authority.

## 2. Separation decision

Messaging Consent is a domain authority distinct from Product Connection and Product Conversation lifecycle state.

Binding separations:

- `CN_ACTIVE != messaging consent`;
- `Messaging Consent != Product Conversation lifecycle`;
- Conversation `pause`, `resume`, and `close` remain Conversation lifecycle actions and are not Messaging Consent states;
- a Messaging Consent revoke removes the current messaging-consent grant but does not itself close Product Connection, erase Conversation history, create a Safety finding, or establish guilt/punishment;
- `read grant != send grant`, even where current live prerequisites are identical.

## 3. Exact Messaging Consent vocabulary

The accepted Messaging Consent product vocabulary is exactly:

- `MC_NONE` — no Messaging Consent request exists in the current consent context;
- `MC_PENDING` — one participant has requested messaging consent and the other participant has not yet independently accepted or declined that request;
- `MC_ACTIVE` — the bound recipient accepted the same current `MC_PENDING` request, establishing mutual Messaging Consent for the bound participant set, Product Connection aggregate/context, and Conversation purpose;
- `MC_DECLINED` — the bound recipient declined the current pending request;
- `MC_WITHDRAWN` — the requester withdrew the current pending request;
- `MC_REVOKED` — either participant revoked an existing active Messaging Consent grant.

No pause/resume/close state exists in Messaging Consent. Those concepts remain Product Conversation lifecycle semantics where separately authoritative.

## 4. Exact actor / transition matrix

| Source | Action | Required actor | Target | Product meaning |
|---|---|---|---|---|
| `MC_NONE` | request | either participant in the current authoritative `CN_ACTIVE` Connection context | `MC_PENDING` | Starts a distinct messaging-consent request; does not yet grant Conversation access. |
| `MC_PENDING` | accept | bound recipient of the same pending request | `MC_ACTIVE` | Establishes mutual Messaging Consent for the exact participants, current Connection aggregate/context, and Conversation purpose. |
| `MC_PENDING` | decline | bound recipient | `MC_DECLINED` | Ends only this consent request; no guilt/Safety/incompatibility meaning. |
| `MC_PENDING` | withdraw | bound requester | `MC_WITHDRAWN` | Ends only this consent request; no adverse inference. |
| `MC_ACTIVE` | revoke | either bound participant | `MC_REVOKED` | Withdraws the current Messaging Consent grant for future live protected use. |

Any unlisted direct transition is invalid for the current Messaging Consent request/grant identity.

There is no direct `MC_NONE -> MC_ACTIVE` transition. Mutual consent requires recipient acceptance of the same authoritative `MC_PENDING` request.

## 5. Terminality and fresh-consent-context rule

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for the existing Messaging Consent request/grant identity. That old identity must not be reopened, reset, reactivated, or mutated back to `MC_PENDING` or `MC_ACTIVE`.

A later Messaging Consent attempt may be made only if then-current Product Connection authority still establishes the same participants in a current authoritative `CN_ACTIVE` Connection context and all then-current product authority permits another request.

Any such later attempt must create a semantically distinct Messaging Consent request/context:

1. fresh consent-request identity/context;
2. fresh participant/requester/recipient bindings;
3. fresh purpose and current Product Connection aggregate/context binding;
4. fresh revision/freshness/logical-intent lineage;
5. its own `MC_NONE -> MC_PENDING` request; and
6. new recipient acceptance of that same new pending request before `MC_ACTIVE` exists.

Historical `MC_ACTIVE`, a revoked grant, an old request identity, prior Conversation rows, prior route identity, peer identity, cached content, or an older Product Connection aggregate cannot shortcut this path.

## 6. Product Connection aggregate binding

Messaging Consent is bound to the current authoritative Product Connection aggregate/context in which it is established.

If a Product Connection lifecycle terminates and a later Product Connection lifecycle is created as a new aggregate/request under the accepted BA-04 rule, no prior Messaging Consent grant transfers automatically. The new Product Connection aggregate requires a fresh Messaging Consent context and fresh independent mutual-consent path before BA-05 may establish live Conversation grants.

Loss of current authoritative `CN_ACTIVE` invalidates live use of any Messaging Consent evidence bound to that Connection aggregate, even if the consent evidence remains historical evidence.

## 7. Revoke effect boundary

Authoritative `MC_REVOKED` removes new live send authority immediately for the revoked scope and also removes any BA-05 live read authority whose current prerequisite requires active mutual Messaging Consent.

This is a live-gate product decision only. It does not decide:

- whether historical Conversation content exists;
- whether history remains readable through a future separate authority;
- retention, export, access/portability, deletion/erasure, peer-visible deletion effect, account exit, legal hold, backups, or rights-request workflows;
- Product Connection closure;
- Relationship state;
- Block, Report, Finding, guilt, punishment, or Safety outcomes.

Those remain under their existing Track-2 / region-specific / separate-authority boundaries.

## 8. BA-05 consequence

BA-05 may now technically design the live gate using two independent current inputs:

1. current authoritative participant-bound `CN_ACTIVE` for the current Product Connection aggregate/context; and
2. current authoritative participant/purpose/Connection-context-bound `MC_ACTIVE`.

Current live read and send grants require both inputs unless a later separately accepted authority explicitly establishes a narrower read distinction. For the current MVP, read and send remain separate grant dimensions with identical current prerequisites; neither dimension silently authorizes the other.

Any stale, superseded, historical-aggregate, unknown, unavailable, revoked, audience-mismatched, purpose-mismatched, or participant-mismatched required input fails closed for new live protected use.

## 9. Preserved boundaries

This decision preserves:

- `Match != Connection != Conversation != Relationship`;
- `UNKNOWN != ABSENT`;
- `ROUTE IDENTITY != CONSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`;
- Product Connection and Messaging Consent have independent authority owners and revision lineages;
- Messaging Consent does not create Product Connection;
- Conversation lifecycle does not create or revive Messaging Consent;
- private Conversation is not default Match/ranking/training/advertising input;
- historical Conversation access remains unavailable by default absent separately accepted history authority;
- no fake rights capability may be shown.

## 10. Final classification

`MESSAGING CONSENT LIFECYCLE OWNER DECISION CLOSED — MC_NONE/PENDING/ACTIVE/DECLINED/WITHDRAWN/REVOKED AUTHORITY FIXED — REVOKE AND FRESH-CONSENT-CONTEXT RULE EXPLICIT — BA-05 MAY BE REDISPATCHED — NO IMPLEMENTATION AUTHORITY CREATED`
