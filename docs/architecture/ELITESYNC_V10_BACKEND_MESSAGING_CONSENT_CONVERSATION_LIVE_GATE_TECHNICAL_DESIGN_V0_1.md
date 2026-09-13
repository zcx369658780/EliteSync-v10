# EliteSync v10｜Backend Messaging Consent + Conversation Live Gate Technical Design｜v0.1

Status: `TECHNICAL-DESIGN CANDIDATE — MESSAGING CONSENT AND TWO-INPUT LIVE GATE ONLY — INDEPENDENT REVIEW REQUIRED — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit: `cb2c2d856e1aec7c3e69401f45bc3b9ccc00521a`

## 1. Purpose, authority chain, and boundary

This candidate defines only the transport- and storage-neutral semantic contract for the independent Messaging Consent authority and the Product Conversation live read/send gate. It consumes the independently accepted BA-01 common evidence envelope, the independently accepted BA-04 Product Connection design, the Owner-accepted Messaging Consent lifecycle closure, the accepted APP-T07 Conversation foundation, the Owner-accepted Conversation data-rights decisions, and the accepted BA-05/B01-D planning boundaries.

This document is not an implementation or an acceptance record. It selects no endpoint, API, wire format, schema, database, storage, service/process topology, transaction mechanism, queue, worker, deployment, clock, freshness duration, client integration, or Flutter behavior. It creates no historical Conversation authority, legal conclusion, production authority, or data-processing authority.

## 2. Authority ownership and non-substitution

The four semantic responsibilities remain separate:

| Responsibility | Owns | Must not own or back-write |
|---|---|---|
| Product Connection authority | Current participant-bound Product Connection lifecycle evidence, including current `CN_ACTIVE`, its aggregate lineage, revision, currentness, and freshness | Messaging Consent, Conversation lifecycle, live read/send grants, history, or Relationship |
| Messaging Consent authority | The `MC_*` request/grant lifecycle, actors, participants, purpose and Connection-context binding, its revision lineage, correction, and revocation | Product Connection, Conversation lifecycle, history, retention, deletion, Safety, or Relationship |
| Product Conversation live-gate evaluator/projection | A descriptive composition of two independently current inputs into separate live-read and live-send decisions | Either input, any lifecycle mutation, a global revision, permanent permission, or history authority |
| Product Conversation lifecycle/access authority | Domain-owned `CV_*` lifecycle/access evidence and any separately established lifecycle restrictions | Product Connection or Messaging Consent state, revision, correction, revocation, or consent creation |

Binding invariants are:

- `CN_ACTIVE != MC_ACTIVE`;
- `Messaging Consent != Conversation lifecycle`;
- `read grant != send grant`;
- `route identity != consent`;
- `transport success != authoritative domain outcome`;
- `state vocabulary != authority`; and
- `Match != Connection != Conversation != Relationship`.

The live-gate evaluator is a consumer/composer and writer of neither required input. Composition retains each input's owner, provenance, participants, audience, purpose, aggregate/context, lineage, revision, currentness, freshness, and failure condition. It creates no universal lifecycle and no global revision.

## 3. Messaging Consent identity and binding contract

One Messaging Consent context is one bounded request/grant lifecycle for:

- the exact participant set of one current authoritative Product Connection aggregate/context;
- one requester and the other participant as the bound recipient for the pending request;
- the accepted Product Conversation purpose;
- the intended audience and protected-use scope;
- one authority-owned revision lineage and usable-freshness rule; and
- one logical intent lineage distinct from transport retries.

Every protected evaluation or mutation requires conjunctively valid authority owner/provenance, participant set, audience, purpose, actor identity and role where actor-dependent, consent identity/context, Product Connection aggregate/context binding, revision/currentness, and usable freshness. Missing, partial, extra, stale, unavailable, superseded, incomparable, unknown, or mismatched binding fails closed.

A route, payload, peer ID, existing Conversation row, unread count, cache entry, notification identity, transport connection or acknowledgement, `eligibleMatch`, `legacyPeer`, Match capability, local/client state, or historical pairing may at most locate a possible authority query. None creates participants, audience, purpose, actor role, consent, currentness, or authority.

## 4. Exact Messaging Consent lifecycle

The complete and exact Messaging Consent vocabulary is:

`MC_NONE`, `MC_PENDING`, `MC_ACTIVE`, `MC_DECLINED`, `MC_WITHDRAWN`, `MC_REVOKED`.

The only valid direct transitions for one consent identity are:

| Source | Action | Required actor | Target | Authoritative meaning |
|---|---|---|---|---|
| `MC_NONE` | request | Either participant in the current authoritative `CN_ACTIVE` Connection context | `MC_PENDING` | Creates one distinct pending consent request and binds requester, recipient, participants, purpose, and current Connection context; grants no live access. |
| `MC_PENDING` | accept | Bound recipient of that same current pending request | `MC_ACTIVE` | Establishes mutual Messaging Consent only for the exact bound participants, Conversation purpose, and current Connection aggregate/context. |
| `MC_PENDING` | decline | Bound recipient | `MC_DECLINED` | Terminates only this request identity; creates no adverse inference. |
| `MC_PENDING` | withdraw | Bound requester | `MC_WITHDRAWN` | Terminates only this request identity; creates no adverse inference. |
| `MC_ACTIVE` | revoke | Either bound participant | `MC_REVOKED` | Withdraws the current consent grant for future live protected use within its exact scope. |

Any unlisted direct transition is invalid. There is no direct `MC_NONE -> MC_ACTIVE`. Recipient acceptance must address the same current authoritative `MC_PENDING` request. Messaging Consent has no pause, resume, or close state; those remain Product Conversation lifecycle concepts where separately authoritative.

## 5. Terminality and fresh-consent-context rule

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for their existing request/grant identity. The old identity cannot be reopened, reset, reactivated, returned to `MC_PENDING`, or mutated back to `MC_ACTIVE`.

A later consent attempt is possible only if then-current Product Connection authority establishes current authoritative `CN_ACTIVE` for the applicable current aggregate/context and all then-current product authority permits the request. The attempt must create a semantically distinct consent context with fresh:

1. request/context identity;
2. participant, requester, and recipient bindings;
3. Product Conversation purpose, audience, and current Product Connection aggregate/context bindings;
4. Messaging Consent lineage, revision, currentness, and freshness evidence; and
5. logical-intent/idempotency correlation.

It must traverse its own `MC_NONE -> MC_PENDING -> MC_ACTIVE` path, including new recipient acceptance of that same new pending request. Historical `MC_ACTIVE`, a revoked grant, old request/grant or idempotency identity, prior Conversation row or route, peer identity, cached content, historical pairing, or an older Product Connection aggregate cannot shortcut the path.

## 6. Two independent inputs and live-gate evaluation

For each protected live operation, the evaluator requires exactly these two independent current inputs:

1. Product Connection evidence from its authority owner establishing participant-bound `CN_ACTIVE` for the current Product Connection aggregate/context, with matching audience/purpose and current usable revision/freshness; and
2. Messaging Consent evidence from its authority owner establishing participant-, Product Conversation purpose-, and current Connection-context-bound `MC_ACTIVE`, with matching audience and current usable revision/freshness.

The valid decision is conjunctive: `connection_input_valid AND consent_input_valid`. One valid input cannot repair, replace, order, refresh, or infer the other. The evaluator must preserve a failure reason at the evidence-condition level without converting it into absence, deletion, guilt, Safety outcome, punishment, or Relationship meaning.

### 6.1 Required truth table

| Product Connection input | Messaging Consent input | Live read | Live send | Required interpretation |
|---|---|---:|---:|---|
| Current/fresh, correctly bound `CN_ACTIVE` for current aggregate/context | Current/fresh, correctly bound `MC_ACTIVE` for same participants, Conversation purpose, and Connection context | Grant | Grant | The sole positive live-gate case; grants remain two distinct dimensions. |
| Current/fresh, correctly bound `CN_ACTIVE` | `MC_NONE` | Deny | Deny | No current consent grant. |
| Current/fresh, correctly bound `CN_ACTIVE` | `MC_PENDING` | Deny | Deny | Mutual consent is incomplete. |
| Current/fresh, correctly bound `CN_ACTIVE` | `MC_DECLINED` | Deny | Deny | This consent identity is terminal. |
| Current/fresh, correctly bound `CN_ACTIVE` | `MC_WITHDRAWN` | Deny | Deny | This consent identity is terminal. |
| Current/fresh, correctly bound `CN_ACTIVE` | `MC_REVOKED` | Deny | Deny | New live protected use is revoked; this does not decide history or deletion. |
| Current/fresh, correctly bound `CN_ACTIVE` | Unknown, unavailable, stale, superseded, incomparable, or projection-lagged | Deny | Deny | Fail closed; do not infer a negative domain outcome. |
| `CN_PENDING`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, or `CN_EXPIRED` | Any consent evidence, including apparently valid `MC_ACTIVE` | Deny | Deny | Product Connection prerequisite fails; consent cannot repair it. |
| Historical/superseded `CN_ACTIVE` | Any consent evidence | Deny | Deny | Historical active evidence is not current authority. |
| `CN_ACTIVE` from another or historical aggregate/context | Any consent evidence | Deny | Deny | Aggregate/context mismatch. |
| Current/fresh `CN_ACTIVE` | `MC_ACTIVE` bound to another or historical Connection aggregate/context | Deny | Deny | Consent does not transfer between Connection contexts. |
| Participant mismatch in either input or between inputs | Any | Deny | Deny | Exact participant binding is conjunctive. |
| Audience mismatch in either input | Any | Deny | Deny | Technical possession or addressability is not audience authority. |
| Purpose mismatch in either input | Any | Deny | Deny | Consent for another purpose cannot authorize Conversation use. |
| Projection/currentness unknown, unavailable, stale, superseded, incomparable, or lagged for either input | Any | Deny | Deny | Both independently current usable inputs must be established. |

## 7. Separate live-read and live-send grants

The projection exposes two separate descriptive decisions: live read and live send. For this current MVP design, both have the identical two prerequisites in section 6, but equality of prerequisites does not merge their meaning or make either grant permanent.

- A live-read grant authorizes only the evaluated current protected read scope; it never silently becomes send authority.
- A live-send grant authorizes only the evaluated current protected send scope and requires re-evaluation at send time.
- Loss of current authoritative `CN_ACTIVE` removes new live-send authority and, under this MVP fail-closed gate, live-read authority.
- New authoritative `MC_REVOKED` removes new live-send authority and, under this MVP fail-closed gate, live-read authority for the revoked scope.
- A future separately accepted history/read authority may define a narrower historical decision; this document neither creates nor predicts it.

Permitted-action evidence is descriptive, actor/context/revision/freshness-bound, and non-self-authorizing. It is not a bearer capability or mutation outcome. The owning writer must independently revalidate its current revision and domain preconditions for every mutation; the live-gate evaluator must independently revalidate both inputs for each protected use.

## 8. Independent revisions, freshness, correction, and supersession

Product Connection and Messaging Consent retain independent authority owners and independent revision lineages. Same-lineage comparison must resolve to same, older, newer, incomparable, or unknown under the owning authority's rules. Cross-owner revisions are never globally ordered, and the live-gate projection creates no global or replacement revision.

- Newer Product Connection non-active or terminal evidence supersedes old `CN_ACTIVE` for live-gate use.
- Newer authority-authored `MC_REVOKED` in the same consent lineage and exact scope supersedes old `MC_ACTIVE` for live-gate use.
- A correction or revocation exists only as newer evidence authored by the authority that owns the corrected claim or revoked grant, within the same lineage and explicit scope. It cannot back-write the other authority or decide history, retention, deletion, Safety, or Relationship.
- Stale evidence is outside usable freshness or has unevaluable freshness; superseded evidence has a known newer controlling revision. Incomparable or unknown currentness is neither state and fails closed.
- Projection lag cannot promote older evidence over a known newer authoritative revision, and receipt order, cache order, local write time, UI order, or transport completion cannot establish supersession.
- A transport timeout or unknown outcome establishes neither success nor failure. The caller must reconcile authoritative current evidence using the same logical intent before deciding access or issuing a distinct intent.

## 9. Logical intent, idempotency, and concurrency

A logical intent is one actor's one semantic Messaging Consent action against one exact consent and Connection context. Its idempotency identity correlates transport retries and is bound to actor, role, action, participants, consent identity, Connection aggregate/context, purpose, intended semantic input, and relevant source revision. It does not authenticate, authorize, order, create consent, prove success, or turn changed semantic input into the same request.

All outcomes resolve against the current authoritative revision and exact domain preconditions, never client, projection, or transport arrival order.

| Case | Required authoritative resolution | Forbidden substitution/outcome |
|---|---|---|
| Duplicate same-intent consent request | Correlate retries to one intent and one consent context; reconcile the single authoritative `MC_PENDING` or later outcome. | Create a second request/context or consent from transport duplication. |
| Duplicate recipient acceptance | Preserve one `MC_ACTIVE` if already authored for the same intent; otherwise evaluate the controlling `MC_PENDING` revision and recipient role. | Create a second grant or infer acceptance from acknowledgement. |
| Accept vs decline race | Only an intent valid against the controlling `MC_PENDING` revision may author the next revision; the other becomes stale after the first authoritative outcome. | Author both outcomes or resolve by client arrival order. |
| Accept vs requester-withdraw race | Either `MC_ACTIVE` or terminal `MC_WITHDRAWN` becomes controlling under current revision rules, never both. | Let a delayed acceptance reopen a withdrawn identity. |
| Revoke concurrent with protected live send | Re-evaluate current consent and Connection evidence at the protected action boundary; controlling `MC_REVOKED` denies the send. If ordering/currentness is unresolved, deny and reconcile. | Let cached `MC_ACTIVE`, route, or transport start override revocation. |
| Stale `MC_ACTIVE` after revoke | Retain newer `MC_REVOKED` as controlling for its scope and deny live read/send. | Roll authority backward because old evidence arrived later. |
| Transport timeout after consent intent may have committed | Reconcile the owning authority with the same logical intent and current revision. | Infer failure, infer success, or silently issue a new business intent. |
| Changed semantic input under reused idempotency identity | Reject as identity misuse/ambiguity or handle only as a separately valid new intent. | Treat changed actor, action, participants, purpose, context, or input as a retry. |
| New consent context reuses old consent/idempotency identity | Reject; terminal and historical identities remain bound to their old lineage. | Reopen the old request/grant or shortcut to `MC_ACTIVE`. |
| New Product Connection aggregate reuses old `MC_ACTIVE` | Deny; require a fresh consent context and complete new path. | Transfer consent across Connection aggregates. |
| Participant, purpose, audience, actor-role, or aggregate mismatch | Reject mutation and deny protected access. | Infer a binding from payload position, route, peer ID, Match, or local state. |

## 10. New Product Connection aggregate consequence

After a historical Product Connection lifecycle reaches a terminal outcome, a later lifecycle is a distinct new aggregate/request under BA-04. It inherits no prior Messaging Consent and no Product Conversation live grant.

The new aggregate must independently establish current authoritative `CN_ACTIVE`, then create a fresh Messaging Consent context and complete a new `MC_NONE -> MC_PENDING -> MC_ACTIVE` consent path. Historical `CN_ACTIVE`, historical `MC_ACTIVE`, an old Conversation row, peer ID, stored route, unread count, cached content, or previous participant pairing grants no access in the new aggregate/context.

## 11. Product Conversation lifecycle interaction

APP-T07's Product Conversation vocabulary remains presentation/lifecycle-access semantics owned outside Messaging Consent:

`CV_LOCKED`, `CV_PENDING_CONSENT`, `CV_ACTIVE`, `CV_PAUSED`, `CV_CLOSED`.

The labels do not create authority. `CV_ACTIVE` may be represented only when both section 6 inputs pass and any separately authoritative Conversation lifecycle restriction also permits live use. `CV_PENDING_CONSENT` may describe current `CN_ACTIVE` with incomplete consent, but does not create `MC_PENDING`. `CV_LOCKED` does not prove absence, deletion, or a negative participant outcome.

If a future authoritative Product Conversation lifecycle source establishes `CV_PAUSED` or `CV_CLOSED`, that restriction remains a separate conjunctive gate. `MC_ACTIVE` alone cannot override pause or close. Messaging Consent does not adopt pause, resume, or close, and this document invents no Product Conversation mutation authority.

## 12. Fail-closed private-data construction boundary

At the semantic-design boundary:

- protected Conversation list, detail, message, draft, realtime, participant/private-preview, and unread/private data remain unavailable before the live-read gate passes;
- a protected subtree, lookup, fetch, subscription, or private projection must not be constructed or invoked before current live-read authority is established;
- stored/direct routes must re-check current live-read authority before private detail access;
- send paths must re-check current live-send authority at the protected action boundary; and
- inner read, send, draft, and realtime paths do not inherit authority merely because an outer route or earlier projection passed.

Route existence, stored rows, drafts, messages, unread counts, realtime connectivity, cache, transport success, notification payload identity, `eligibleMatch`, `legacyPeer`, Match capability, peer identity, or local/client state cannot grant access. Private Conversation remains `CONVERSATION_SHARED_PRIVATE` and unavailable by default for unrelated Match, ranking, Compatibility scoring, advertising, analytics enrichment, or model training.

These are semantic obligations only; no backend or client mechanism is selected or authorized.

## 13. Track-2, history, and legal exclusions

This live-gate design explicitly does not define:

- historical read after revoke, Connection pause/close/terminal outcome, Conversation close, Block, or account exit;
- Conversation history authority, retention schedules or jobs;
- export, access, or portability;
- deletion, erasure, or peer-visible effects;
- account-exit rights handling;
- legal hold, backups, or restoration treatment;
- rights-request verification, timelines, refusals, or appeals; or
- applicable law, launch-region conclusions, legal entity/role, age posture, lawful basis, hosting, subprocessors, or transfers.

History remains unavailable by default unless a separate accepted authority later establishes the applicable subject, audience, purpose, retention state, and jurisdictional scope. This is fail-closed access handling, not a claim that content is absent or erased. `MC_REVOKED` withdraws the live consent grant in its scope; it is not an erasure, deletion, Conversation closure, Product Connection closure, Block, Report, Finding, guilt, punishment, or Safety decision. No rights capability may be represented as available or completed without its exact backend and applicable legal/data-right authority.

## 14. Independent-review evidence checklist

An independent reviewer can verify from this candidate that:

1. Product Connection and Messaging Consent remain separate authorities and revision lineages.
2. The Messaging Consent vocabulary contains exactly six states: `MC_NONE`, `MC_PENDING`, `MC_ACTIVE`, `MC_DECLINED`, `MC_WITHDRAWN`, `MC_REVOKED`.
3. The transition/actor matrix exactly matches the Owner closure and contains no direct `MC_NONE -> MC_ACTIVE`.
4. `MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` identities cannot reopen, and a later attempt requires a fresh context and complete path.
5. A new Product Connection aggregate inherits no Messaging Consent or live grant.
6. Live read and live send remain separate dimensions, each requiring both current valid inputs under the current MVP.
7. Loss, revoke, stale, unknown, unavailable, incomparable, superseded, mismatch, projection lag, or historical-aggregate evidence fails closed.
8. Private protected data is not constructed, fetched, subscribed, or exposed before the live-read gate passes.
9. Identity, route, payload, row, cache, local state, transport, Match, legacy, and notification evidence cannot substitute for authority or consent.
10. Conversation history, retention, export, deletion, account-exit, rights, and legal matters remain excluded.
11. Product Conversation lifecycle restrictions remain independent and `MC_ACTIVE` cannot override `CV_PAUSED` or `CV_CLOSED`.
12. No endpoint, wire format, schema, storage, service topology, clock, deployment, backend implementation, or client implementation is selected.
13. Candidate scope is exactly this document and `git diff --check` passes.

## 15. Completion and stop boundary

This candidate ends at the Messaging Consent and Product Conversation live-gate technical-design boundary. It requires a fresh independent ACCEPT/REJECT review and cannot accept itself.

No backend/API/schema/storage/service/client implementation, merge, main promotion, BA-06/BA-07 start, successor-task creation, historical-access design, or legal closure is authorized by this document.

Candidate classification:

`MESSAGING CONSENT + CONVERSATION LIVE GATE TECHNICAL DESIGN ESTABLISHED — INDEPENDENT MC LIFECYCLE AND TWO-INPUT LIVE AUTHORITY EXPLICIT — HISTORY/TRACK-2 BOUNDARIES PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
