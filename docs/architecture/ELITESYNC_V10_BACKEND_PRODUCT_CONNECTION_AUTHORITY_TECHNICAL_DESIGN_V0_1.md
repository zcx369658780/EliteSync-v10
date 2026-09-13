# EliteSync v10｜Backend Product Connection Authority Technical Design｜v0.1

Status: `CANDIDATE — BOUNDED SEMANTIC TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh technical-design base: `54a6dd4969ed4395248fa1c97796fc2bd9cf1145`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_BA_04_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_REDISPATCH_TASK_V0_1.md`

## 1. Purpose, authority chain, and boundary

This candidate defines the semantic authority contract for Product Connection. It inherits the accepted BA-01 common authority evidence envelope, preserves the accepted APP-T06 lifecycle for one Connection aggregate/request, preserves the independently accepted BA-04-SR01 terminality finding, and applies the Owner-accepted post-terminal new-aggregate rule.

The fixed lifecycle authorities are:

- APP-T06 accepted result blob `27677f6c93f330c934f787660d5f268525e2e0d6` and acceptance blob `f06a0bb94c6d567126285192294a46431dd774ec`;
- BA-04-SR01 accepted result blob `43aea0fbaf3f837ab03032c5390fd2a3af956e3c` and acceptance blob `9c48f640021a3982591a863e9fb22625ab06a1b0`; and
- Owner decision closure blob `e6f106eb21fd728de0d7bc61fbcdbfa264de9c59`.

This is a transport- and storage-neutral design contract. It creates no executable writer, endpoint, wire format, schema, persistence, service, client integration, messaging consent, Conversation authority, expiry value, or legal conclusion.

The following remain binding:

- `Match != Connection != Conversation != Relationship`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- `ROUTE IDENTITY != CONSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`; and
- current Product Connection authority can be authored only by the Product Connection authority owner under the obligations below.

## 2. Ownership, identity, participants, and aggregate semantics

### 2.1 Authority owner

The Product Connection authority owner is the semantic responsibility that validates and authors Product Connection lifecycle outcomes, same-lineage revisions, currentness, corrections, and participant-authorized read evidence. It is not a selected service, process, database, deployment unit, route, client state holder, or transport participant.

### 2.2 Aggregate/request identity

A Product Connection aggregate is one bounded consent lifecycle for one exact participant set. Its semantic identity must:

- distinguish this lifecycle from every earlier or later lifecycle involving the same participants;
- bind the request phase and every resulting state to the same aggregate lineage;
- bind the initiating request to an initiator/requester and recipient without choosing an ID syntax;
- prevent a state, revision, logical intent, permitted action, or consent outcome from being transferred to another aggregate; and
- remain distinguishable from Match, Conversation, Relationship, route, payload, peer, cache, row, notification, and transport identities.

`CN_NONE` means no Connection consent process exists in the new aggregate context. It is not a reset target for an old aggregate. Creation of a later lifecycle after a terminal outcome creates a distinct aggregate/request context; it does not mutate the old terminal aggregate into `CN_NONE`.

### 2.3 Participant, role, audience, and purpose binding

Every aggregate binds exactly the accepted participant set and the domain roles established for that lifecycle:

- the participant who submits the request is the initiator/requester;
- the other participant is the recipient;
- after `CN_ACTIVE`, both are connected participants; and
- the identity of the participant who caused `CN_PAUSED` remains authority-bound for the resume rule.

For every mutation or protected read, BA-01 subject/participant, audience, purpose, actor identity, actor role, provenance, revision, and usable-freshness obligations are conjunctive. Missing, extra, partial, mismatched, stale, unavailable, superseded, or unknown binding fails closed for the affected use. Participant membership alone establishes neither audience nor permission.

## 3. Exact eight-state contract

The Product Connection vocabulary is exactly:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

| State | Exact authority meaning | Allowed successor(s) in the same aggregate/request | Terminality and non-meaning |
|---|---|---|---|
| `CN_NONE` | No Connection consent process exists in this new aggregate context. | `CN_PENDING` | Not consent, not Match outcome, and never reached by resetting a terminal aggregate. |
| `CN_PENDING` | The initiator's distinct request awaits the bound recipient's independent choice. | `CN_ACTIVE`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` | Not mutual Connection consent. |
| `CN_ACTIVE` | The bound recipient accepted the same authoritative pending request, establishing mutual Product Connection consent for this aggregate. | `CN_PAUSED`, `CN_CLOSED` | Necessary but not sufficient for Product Conversation; not messaging consent or Relationship. |
| `CN_PAUSED` | This Connection is paused by an identified connected participant. | `CN_ACTIVE`, `CN_CLOSED` | Not closure; does not rewrite Conversation or Relationship facts. |
| `CN_CLOSED` | This active/paused Connection was closed. | None for this Connection. | Terminal for this aggregate; not guilt, Safety finding, punishment, fraud, deception, or incompatibility. |
| `CN_DECLINED` | The recipient declined this pending request. | None for this request. | Terminal for this request; no adverse person meaning. |
| `CN_WITHDRAWN` | The initiator withdrew this pending request. | None for this request. | Terminal for this request; no Connection was formed. |
| `CN_EXPIRED` | The pending request expired under an established authority-owned policy. | None for this request. | Terminal for this request; not a decline. Exact expiry policy remains `UNKNOWN`. |

Transport, offline, timeout, loading, cache, unavailable-authority, and projection-lag conditions are not CN states.

## 4. Complete source/action/actor/target matrix

Each allowed transition requires the exact aggregate and participants, the stated actor role, current authoritative source revision, usable freshness, accepted audience/purpose, and all domain preconditions. “Resulting evidence” means a newer Product Connection authority-authored outcome in the same lineage; it is not a transport acknowledgement.

| Source | Action | Required actor | Target | Required authoritative preconditions | Resulting evidence | Forbidden substitutes |
|---|---|---|---|---|---|---|
| `CN_NONE` | request | either currently eligible candidate acting as initiator/requester | `CN_PENDING` | Distinct aggregate context; exact participants/roles; then-current eligibility/authority; current source revision | Pending request evidence binding aggregate, participants, initiator, recipient, purpose, and new revision | Match acceptance, candidate identity, route, Home action, local boolean |
| `CN_PENDING` | accept | bound recipient | `CN_ACTIVE` | Same authoritative pending request; unchanged participant/role binding; current revision/freshness | Active consent evidence identifying recipient acceptance of that request | Initiator action, Match mutual interest, optimistic UI, transport success |
| `CN_PENDING` | decline | bound recipient | `CN_DECLINED` | Same current pending request and recipient role | Neutral terminal decline evidence for this request | Notification dismissal, nonresponse, Safety/Compatibility inference |
| `CN_PENDING` | withdraw | bound initiator/requester | `CN_WITHDRAWN` | Same current pending request and initiator role | Neutral terminal withdrawal evidence for this request | Recipient action, route exit, cache deletion, local state |
| `CN_PENDING` | expire | Product Connection authority under an established expiry policy | `CN_EXPIRED` | Same current pending request; authority establishes policy applicability without this design choosing its value | Neutral terminal expiry evidence for this request | Client timer, receipt time, transport timeout, Match expiry |
| `CN_ACTIVE` | pause | either bound connected participant | `CN_PAUSED` | Same current active aggregate; actor is a participant; current revision/freshness | Paused evidence binding the pausing participant and new revision | Messaging state, unread count, connectivity, local toggle |
| `CN_ACTIVE` | close | either bound connected participant | `CN_CLOSED` | Same current active aggregate; actor is a participant; current revision/freshness | Neutral terminal closure evidence for this Connection | Chat row deletion, block/report, Relationship state, route exit |
| `CN_PAUSED` | resume | the bound participant who caused the current pause | `CN_ACTIVE` | Same current paused aggregate; current pause evidence identifies the same actor; current revision/freshness | New active evidence for this same non-terminal aggregate | Other participant, prior active snapshot, client cache, transport retry |
| `CN_PAUSED` | close | either bound connected participant | `CN_CLOSED` | Same current paused aggregate; actor is a participant; current revision/freshness | Neutral terminal closure evidence for this Connection | Resume assumption, Conversation state, notification identity |

Any unlisted direct transition is invalid for the aggregate/request. In particular, direct `CN_NONE -> CN_ACTIVE` is forbidden.

## 5. Terminality and later-new-lifecycle contract

### 5.1 Old aggregate/request is immutable as terminal authority

For `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED`, all attempts to transition the old aggregate/request are forbidden:

| Old terminal source | Forbidden target/action in that identity | Required disposition |
|---|---|---|
| `CN_CLOSED` | `CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`; reopen/reactivate/reset/reuse | Reject against current terminal revision; retain terminal evidence. |
| `CN_DECLINED` | any successor; accept/retry-old-request/reset | Reject against current terminal revision; a delayed acceptance cannot revive it. |
| `CN_WITHDRAWN` | any successor; accept/reissue/reset | Reject against current terminal revision; a reordered recipient response cannot revive it. |
| `CN_EXPIRED` | any successor; accept/extend/retry-old-request/reset | Reject against current terminal revision; an old request cannot be extended or accepted by this design. |

A prior `CN_ACTIVE` revision from a now-closed aggregate is superseded historical evidence, not current consent.

### 5.2 A later lifecycle is a new aggregate/request

A later Product Connection lifecycle may be initiated only if then-current product eligibility and authority permit it. It must:

1. create a semantically distinct aggregate/request context;
2. establish its own exact participant, initiator, recipient, audience, purpose, provenance, revision, freshness, and logical-intent bindings;
3. begin through its own `CN_NONE -> CN_PENDING` request;
4. require the new bound recipient's acceptance of that same new authoritative `CN_PENDING`; and
5. establish `CN_ACTIVE` only for that new aggregate after the acceptance in step 4.

The old terminal identity, old idempotency identity, old permitted-action evidence, old `CN_ACTIVE`, or historical participant pairing cannot authorize or shortcut the new lifecycle.

## 6. Mutation contract

Every request, accept, decline, withdraw, expire, pause, resume, or close intent must satisfy all of the following before the Product Connection authority may author an outcome:

1. **Claim and owner:** the input is a mutation intent, not a projection or transport observation, and is evaluated by the Product Connection authority owner.
2. **Actor and role:** actor identity is independently established and matches the role required by section 4.
3. **Aggregate and participants:** the exact aggregate/request and participant set match; no identity is borrowed from another lifecycle.
4. **Current revision:** the intent names or otherwise binds to the authoritative source revision required for its transition; stale, superseded, incomparable, or unknown currentness fails closed.
5. **Usable freshness:** authority, actor/role, audience, purpose, and transition evidence are current enough for this action. Freshness cannot override a known newer revision.
6. **Domain preconditions:** the source/action/actor/target row is allowed and all then-current product conditions pass.
7. **Logical intent:** the authority distinguishes a retry of the same semantic intent from a distinct new intent.
8. **Outcome:** success exists only when the authority authors a new revision carrying the transition outcome. Transport acceptance, response, timeout, or retry is not that outcome.

Correction or revocation within Product Connection scope must be newer authority-authored evidence in the same lineage with explicit corrected/revoked scope. It may supersede an erroneous Connection claim or withdraw a Product Connection grant within that scope, but it cannot rewrite another domain, erase history, reopen terminal identity, manufacture a new aggregate, or decide messaging consent, Conversation history, Relationship, Safety, guilt, retention, export, or deletion.

## 7. Logical intent and idempotency

An idempotency identity correlates transport attempts to one actor's one semantic action against one aggregate/request and intended semantic input. It does not authenticate, authorize, order, or prove success.

- Repeating the same logical intent cannot create a second request, acceptance, decline, withdrawal, expiry, pause, resume, or close outcome.
- A changed actor, action, aggregate, participant set, target, or semantic input is a distinct intent and cannot reuse the prior identity as a safe retry.
- An idempotency identity bound to an old terminal aggregate/request cannot be reused for a later lifecycle.
- A later lifecycle requires new logical-intent correlation in the distinct new aggregate/request context.
- If a transport timeout leaves the prior outcome unknown, the caller must reconcile authoritative current evidence; it must not silently create another intent.
- Duplicate and reordered intents resolve against current authoritative revision and domain preconditions, never receipt order.

This contract selects no identifier/key syntax, generation algorithm, TTL, storage, transaction, locking, sequencing, queue, endpoint, or transport mechanism.

## 8. Concurrency and idempotency truth cases

| Case | Required authoritative resolution | Must not happen |
|---|---|---|
| Duplicate same-intent request | Correlate to one intent and one aggregate; return/reconcile the single authoritative pending or later outcome. | Create a second aggregate/request from a retry. |
| Duplicate recipient acceptance | If already authored for the same intent, preserve the single `CN_ACTIVE` outcome; otherwise evaluate current revision. | Create another consent outcome or treat transport duplication as consent. |
| Accept vs decline race | Only an intent valid against the controlling `CN_PENDING` revision may author the next revision; the other fails currentness after the first outcome. | Resolve by arrival order at a client or create both outcomes. |
| Accept vs initiator-withdrawal race | Same current-revision rule; either accepted `CN_ACTIVE` or terminal `CN_WITHDRAWN` becomes controlling, never both. | Allow a delayed acceptance to revive a withdrawn request. |
| Pause vs close race | One current-revision transition controls. If close controls, pause is rejected; if pause controls, any later close requires fresh evaluation against `CN_PAUSED`. | Auto-rebase a stale pause/close intent. |
| Pause vs resume/close sequencing | Resume exists only after authoritative pause and only for the pausing participant; close remains actor-valid from active or paused but must independently match the current revision. | Resume before pause, resume by the other participant, or apply reordered stale intent. |
| Stale client mutation | Reject/fail closed and refresh authority evidence. | Apply because the action would have been valid at an older revision. |
| Reordered projections | Retain the newer controlling revision; older delivery cannot roll state back. | Last-received-wins. |
| Transport timeout after possible commit | Reconcile authoritative evidence using the same logical intent. | Infer failure or issue a distinct business intent silently. |
| Changed semantic input with reused idempotency identity | Reject as ambiguous/misused identity or treat only under a separately valid new intent. | Call it the same retry. |
| Actor or participant mismatch | Reject the mutation and withhold protected evidence. | Infer role from payload position, route, peer ID, or participant membership alone. |
| Mutation of terminal old identity | Reject against terminal current revision. | Reopen, reset, resume, reactivate, accept, or extend the old lifecycle. |
| New lifecycle reusing old identity | Reject; old aggregate/request and intent identities remain historical. | Treat old consent or old `CN_NONE` as the new lifecycle. |
| Valid later lifecycle | Create a distinct context after then-current eligibility/authority passes; require new request and recipient acceptance. | Shortcut directly to `CN_ACTIVE`. |
| Route/legacy/cache/local substitution | Treat as non-authoritative observation only and query Product Connection authority. | Create lifecycle state, actor role, audience, permitted action, or consent. |

## 9. Participant-authorized read projection

A Product Connection read projection is a privacy-minimal, domain-owned projection of authoritative evidence. It is not a writer and must expose only what the requesting participant is authorized to evaluate for the accepted Product Connection purpose.

| Projection concept | Obligation |
|---|---|
| Aggregate/request reference | Identify the exact lifecycle context sufficiently to distinguish it from all prior/later aggregates without selecting an ID format. |
| Participant and role view | Bind the requester to the exact participant set and expose only the actor-role view appropriate to that participant; retain initiator/recipient and current pausing-participant semantics where needed. |
| Exact CN state | Present exactly one authority-authored current CN state for this lineage, or an explicit non-domain condition when current state cannot be established. |
| Revision/currentness/freshness | Carry owner, lineage, revision relation, usable-freshness result, and supersession status sufficient for the requested read or action evaluation. |
| Permitted actions | Descriptive, actor/role/aggregate/revision/freshness-bound evidence only. The writer must revalidate every mutation. |
| Terminal/new identity distinction | Preserve that terminal evidence belongs to the old identity and cannot be presented as current consent or as a permitted action on a new identity. |
| Transition/outcome explanation | Reveal only the minimum Product Connection state/actor category/non-meaning required by accepted semantics; do not expose another participant's private reason. |

Fail-closed projection handling:

| Condition | Required handling | Must not infer |
|---|---|---|
| Authority unavailable | Withhold protected details/actions and present unavailable as an authority-access condition. | Negative lifecycle outcome. |
| Authority/currentness unknown | Retain `UNKNOWN` and withhold protected use. | `CN_NONE`, absence, rejection, or permission. |
| Stale evidence | Deny new protected action; any bounded display remains subject to current audience/purpose authority. | Current permission. |
| Superseded evidence | Do not use it for a new action; prefer newer evidence only when independently valid. | Rollback, deletion, or reset. |
| Audience mismatch | Withhold protected state and actions. | Public Connection authority. |
| Participant mismatch | Reject the projection for that viewer. | Participation or consent from identifier similarity. |
| Projection lag | Preserve authoritative-outcome vs projection distinction; do not fabricate missing details or overwrite a known newer revision. | Outcome rollback or authority for an older projection. |
| Historical terminal identity | May be identified only to the minimum separately authorized Product Connection extent; expose no action that mutates it. | Current consent, restart authority, or Conversation gate. |

Absence of a projected action does not prove a terminal state; it may mean privacy minimization, stale/unknown/unavailable authority, mismatch, or lag.

## 10. BA-05 downstream evidence boundary

BA-05 may later consume only Product Connection evidence that independently establishes all of the following for the **current aggregate**:

- authority owner and provenance;
- exact participant set;
- current authoritative `CN_ACTIVE` outcome;
- Product Connection lineage/revision, currentness, and usable freshness; and
- audience and purpose bindings for the proposed live-gate evaluation.

This evidence is one necessary input only. BA-05 must separately establish current participant/purpose-bound mutual messaging consent under its own authority and revision. One valid input cannot repair the other when stale, unavailable, unknown, superseded, revoked, or mismatched.

| Product Connection evidence | BA-05 consequence |
|---|---|
| Current, fresh, participant/audience/purpose-bound `CN_ACTIVE` for the current aggregate | Eligible to be evaluated as the Product Connection input; still insufficient without separate messaging consent. |
| `CN_PENDING`, `CN_PAUSED`, or any terminal state | No live Product Connection input for Product Conversation. |
| Historical `CN_ACTIVE` superseded by pause/close/other controlling revision | Cannot authorize Conversation read or send. |
| `CN_ACTIVE` belonging to a different or historical aggregate | Cannot be substituted for the current aggregate. |
| Unknown, unavailable, stale, superseded, participant-mismatched, audience-mismatched, purpose-mismatched, or projection-lagged evidence | Fail closed for the live gate; do not infer absence or deletion. |

Connection authority never creates messaging consent, Product Conversation availability, read/send authority, history authority, retention/export/deletion rights, or Relationship. A later new lifecycle's `CN_ACTIVE` is a distinct authority outcome and inherits no messaging consent or Conversation authority from any historical lifecycle. BA-05 remains a separate technical-design, independent-review, and Owner gate.

## 11. Explicit non-substitution assertions

None of the following, alone or combined, creates Product Connection authority, establishes a CN state, proves audience/consent, or authorizes a transition:

| Non-authoritative material | Explicit rejection |
|---|---|
| Match mutual acceptance | Does not create a Connection request or active Connection. |
| Match proposal, candidate, or compatibility identity | Locates no Product Connection authority and creates no consent. |
| Route or deep-link identity | Addressability is not participant, audience, role, or consent evidence. |
| `eligibleMatch`, `legacyPeer`, or stored peer identity | Legacy/local identity cannot author Product Connection truth. |
| Local boolean or local mutual-consent truth | Client possession or computation is not authoritative evidence. |
| Optimistic UI success | Presentation state cannot establish a transition outcome. |
| Existing chat/Conversation row | Conversation storage/presence cannot create Connection. |
| Unread count or transport connectivity | Transport/projection observations are not lifecycle outcomes. |
| Notification payload identity | Delivery/payload identity creates neither audience nor authority. |
| Transport success or acknowledgement | Does not prove that the Product Connection writer authored an outcome. |
| Legacy chat behavior | Historical behavior does not own the Product Connection lifecycle. |
| Home card or action label | A composed read surface is not a writer or permission token. |
| Prior terminal Connection/request identity | Historical identity cannot be reopened or reused for a later lifecycle. |
| Prior `CN_ACTIVE` from a closed historical lifecycle | Superseded consent evidence cannot authorize current Connection or Conversation. |

## 12. Preserved blockers and explicit non-goals

This design does not decide or define:

- Product Connection backend/API/schema/storage/service implementation or runtime truth;
- endpoint, wire format, persistence model, transaction/locking mechanism, queue, worker, cache, clock, service topology, deployment, authentication implementation, identity/key syntax, or migration;
- exact Product Connection expiry duration, extension, calculation, or policy, which remains `UNKNOWN`;
- messaging-consent authority or Product Conversation live-gate implementation;
- Conversation history, retention, export, deletion, account exit, peer-visible deletion effects, rights workflows, legal holds, backups, or region-specific rights;
- Match expiry/policy, Readiness policy, Relationship state, or Safety guilt/finding/punishment semantics;
- launch regions, accountable entity roles, age model, hosting/transfers, lawful basis, vendors, or deployment facts;
- Flutter/client integration, compatibility-debt retirement, analyzer cleanup, Phase 2, or Sandbox/DEP13/B12/M2/M3.

Decline, withdrawal, expiry, pause, and close remain bounded Product Connection outcomes. They do not establish guilt, Safety findings, punishment, fraud, deception, objective incompatibility, absence of a person, or another domain outcome.

## 13. Independent-review evidence checklist

An independent reviewer can verify from this artifact and its fixed authorities that:

1. exactly eight CN states are used and no universal state is added;
2. all nine APP-T06 actor/source/target transitions are preserved unchanged;
3. every unlisted direct transition is invalid;
4. terminal old aggregate/request identities have no successor and cannot reopen or reset;
5. any later lifecycle is a distinct new aggregate/request with independent bindings;
6. every new `CN_ACTIVE` requires recipient acceptance of that new authoritative `CN_PENDING`;
7. no direct `CN_NONE -> CN_ACTIVE` exists;
8. revisions, freshness, logical intents, retries, and concurrency fail closed against authoritative current state;
9. permitted actions are descriptive and non-self-authorizing;
10. BA-05 receives only current participant/audience/purpose-bound `CN_ACTIVE` evidence and never messaging consent;
11. all required Match/route/legacy/local/transport/notification/Home/historical substitutions are rejected;
12. expiry value, implementation mechanism, legal conclusion, and region-specific facts remain unselected;
13. candidate scope is exactly this artifact and `git diff --check` passes.

## 14. Completion and stop boundary

This candidate performs technical design only. It modifies no backend, API, schema, database, service, client, Flutter, test, dependency, lockfile, generated, configuration, legal, Safety, or runtime artifact.

`PRODUCT CONNECTION AUTHORITY TECHNICAL DESIGN ESTABLISHED — COMPLETE ACCEPTED CN LIFECYCLE INCLUDING NEW-AGGREGATE RESTART RULE EXPLICIT — BA-05 DOWNSTREAM EVIDENCE BOUNDARY PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

Publication is terminal. It does not authorize implementation, merge, self-acceptance, BA-05, BA-02, BA-03, or any client integration.
