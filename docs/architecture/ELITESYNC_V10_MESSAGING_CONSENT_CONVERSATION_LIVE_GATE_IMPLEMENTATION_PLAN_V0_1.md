# EliteSync v10｜Messaging Consent + Conversation Live-Gate Implementation Plan｜v0.1

Status: `CANDIDATE — FRESH INDEPENDENT REVIEW REQUIRED — DOCUMENTARY IMPLEMENTATION PLANNING ONLY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task authority: `43dada35bdaba509524b7f708ce5e4fda71d079d`

Authorized artifact: `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_IMPLEMENTATION_PLAN_V0_1.md`

## 1. Outcome and authority boundary

This candidate defines a technology-neutral implementation plan for the independent Messaging Consent writer and the Product Conversation live-read/live-send gate. It consumes, without changing, the accepted IP-01 common backend implementation contract, accepted IP-04 Product Connection implementation plan, accepted BA-05 technical design, and accepted Messaging Consent Owner closure.

The plan establishes responsibilities, semantic decision boundaries, evidence contracts, fail-closed behavior, downstream documentary outputs, and future bounded-slice checkpoints. It does not implement anything and does not choose an endpoint, protocol, wire representation, schema, database, index, key, transaction, lock, compare-and-swap mechanism, queue, event log, broker, language, framework, service/module/deployment topology, clock, scheduler, provider, client mechanism, or private-data processing path.

Result classification:

`MESSAGING CONSENT + CONVERSATION LIVE-GATE IMPLEMENTATION PLAN ESTABLISHED — INDEPENDENT MC WRITER / TWO-INPUT READ-SEND GATE / FAIL-CLOSED PRIVATE-DATA PLAN EXPLICIT — HISTORY SEAMS PRESERVED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

This candidate does not self-accept, release implementation, or authorize IP-06, IP-07, IP-08, history access, legal work, Safety Operations, production use, or processing of real/private data.

## 2. Fixed authority and vocabulary

Authority precedence is: the current Owner task and accepted Owner closure; accepted BA-05 domain design; accepted IP-01 and IP-04 implementation-planning contracts; then this technology-neutral translation. A contradiction fails closed and returns to the owning authority.

Messaging Consent lifecycle vocabulary is exactly:

`MC_NONE / MC_PENDING / MC_ACTIVE / MC_DECLINED / MC_WITHDRAWN / MC_REVOKED`

Product Conversation lifecycle vocabulary is preserved only as a restriction input:

`CV_LOCKED / CV_PENDING_CONSENT / CV_ACTIVE / CV_PAUSED / CV_CLOSED`

Messaging Consent is not Product Connection, Match, Conversation lifecycle, Relationship state, a route, a notification, a transport session, a cache, or a client-local fact. Product Connection and Messaging Consent retain independent owners, identities, revisions, currentness, freshness, correction lineages, and failure conditions. No global revision or universal lifecycle is created.

## 3. Exact Messaging Consent state and transition contract

| Source | Action | Required actor and preconditions | Target | Semantic decision boundary |
|---|---|---|---|---|
| `MC_NONE` | request | Either participant in the exact current authoritative `CN_ACTIVE` Connection context; actor, both participants, Conversation purpose, Connection aggregate/context, expected MC revision and immutable logical intent are bound. | `MC_PENDING` | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` |
| `MC_PENDING` | accept | Bound recipient of the same current pending request; exact requester, recipient, participants, purpose, Connection context, request identity and controlling MC revision match. | `MC_ACTIVE` | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` |
| `MC_PENDING` | decline | Bound recipient of that request with the same bindings and controlling revision. | `MC_DECLINED` | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` |
| `MC_PENDING` | withdraw | Bound requester of that request with the same bindings and controlling revision. | `MC_WITHDRAWN` | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` |
| `MC_ACTIVE` | revoke | Either bound participant for the exact active consent identity and controlling revision. | `MC_REVOKED` | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` |

Every unlisted direct transition is invalid. There is no direct `MC_NONE -> MC_ACTIVE`. Messaging Consent has no pause, resume, or close state; these terms belong only to separately owned Product Conversation lifecycle semantics.

The writer owns authoritative MC mutation outcomes and its source-local revision lineage. It MUST NOT write Product Connection or Conversation lifecycle state. Request handling binds requester and recipient directionally; the same two identities are not interchangeable for accept, decline, or withdraw. Revoke is the only listed action available to either participant once the consent is `MC_ACTIVE`.

## 4. Terminality and fresh-consent-context handling

`MC_DECLINED`, `MC_WITHDRAWN`, and `MC_REVOKED` are terminal for their existing consent identity. A terminal identity cannot reopen, return to `MC_PENDING`, or become `MC_ACTIVE` through correction, retry, route reuse, client state, or a new Product Connection aggregate.

A later consent attempt requires all of the following independently:

1. a fresh consent context and request identity;
2. fresh requester/recipient/participant, Conversation-purpose, and current Connection-context bindings;
3. a fresh logical intent that does not reuse the old terminal intent identity;
4. independently current/fresh authoritative `CN_ACTIVE` evidence for the exact then-current Connection aggregate/context; and
5. the complete new `MC_NONE -> MC_PENDING -> MC_ACTIVE` path.

A new Product Connection aggregate never inherits an old aggregate's `MC_ACTIVE`. Historical or superseded consent is descriptive history only where separately authorized; it cannot authorize live access.

## 5. Technology-neutral responsibility decomposition

| Responsibility | Required behavior | Explicit non-authority |
|---|---|---|
| Messaging Consent request writer | Validate actor participation in exact current `CN_ACTIVE`, immutable intent, bindings, source state and expected MC revision; establish `MC_PENDING` or an authoritative rejection/unknown. | Connection evidence, transport receipt, route or retry key cannot itself create consent. |
| Requester/recipient binder | Preserve directional requester and recipient plus complete participant set, Conversation purpose and exact Connection aggregate/context. | Participant adjacency or symmetric display identity cannot erase roles. |
| Recipient decision handler | Permit only the bound recipient to accept or decline the same current pending request. | Requester, notification opener, device, or peer identifier cannot substitute. |
| Requester withdrawal handler | Permit only the bound requester to withdraw the same current pending request. | Recipient or transport cancellation cannot establish withdrawal. |
| Active-grant revocation handler | Permit either bound participant to revoke the exact current `MC_ACTIVE`; invalidate dependent live grants. | Delivery failure, logout, silence, route closure, or Connection change is not an MC revocation mutation. |
| Terminal/fresh-context handler | Reject reopening and require fresh identity, intent and full lifecycle for a later attempt. | Correction and idempotency are not reopening mechanisms. |
| MC evidence owner/projection | Expose privacy-minimal MC state, identity/bindings, source revision/currentness, use-specific freshness and condition. | Projection is not a second writer or bearer permission. |
| Product Connection evidence adapter | Consume only current/fresh participant-bound `CN_ACTIVE` for the exact current aggregate/context. | It cannot infer, repair or refresh Connection authority. |
| Messaging Consent evidence adapter | Consume only current/fresh participant-, Conversation-purpose-, Connection-context-bound `MC_ACTIVE`. | It cannot infer, repair or refresh Consent authority. |
| Live-read evaluator | Evaluate both independent inputs plus applicable Conversation restriction for the exact live-read use. | It owns neither input and cannot authorize history. |
| Live-send evaluator | Separately evaluate both independent inputs plus applicable Conversation restriction at protected send time. | A read grant, draft, displayed composer or earlier send grant cannot authorize send. |
| Live-access projection | Return separate privacy-minimal read/send decisions, evaluated source identities/revisions and coarse conditions. | It returns no private content and is not a permanent grant. |
| Conversation lifecycle restriction adapter | Consume an authoritative `CV_*` restriction if/when separately established; deny when it forbids the live operation. | It defines no Conversation transition or writer. |
| Reconciliation responsibility | Resolve ambiguous MC intent outcomes from the MC authority using the same immutable intent/context. | Retrying, notification receipt or client arrival order does not decide outcome. |
| Downstream contract publisher | Supply documentary semantic obligations for IP-06/07/08/09/10 after independent acceptance and Owner dispatch. | It creates no successor or implementation authority. |

## 6. Revision, currentness, freshness, and invalidation

MC currentness and freshness are separate. Currentness asks whether evidence is the controlling source-local revision for the exact consent identity/context. Freshness asks whether that current evidence remains usable for the exact protected use under source-owned rules. Neither implies the other.

Every authority-dependent use MUST bind authority/source, exact participants, directional roles where applicable, audience, Conversation purpose, Connection aggregate/context, actor/role for mutations, source-local revision/currentness, use-specific freshness, and provenance. Missing, mismatched, stale, unknown, unavailable, superseded, incomparable, revoked, terminal, or projection-lag evidence fails closed for the affected live operation.

Only newer authoritative evidence can establish correction, revocation, or supersession. Such evidence invalidates dependent prior live-read and live-send decisions. A consumer that sees an old `MC_ACTIVE` after a newer `MC_REVOKED`, or an old `CN_ACTIVE` after a newer non-active Connection revision, MUST deny/unknown the relevant grant rather than use last-received-wins. A correction may correct facts; it cannot legalize an unlisted transition or reopen a terminal identity.

Independent sources are never globally ordered. A derived gate result is bound to the exact CN revision and MC revision evaluated. At protected action time, both inputs and applicable Conversation restriction are revalidated; a previously returned result is descriptive evidence, not a reusable permission token.

## 7. Logical intent, idempotency, concurrency, and reconciliation

One logical-intent identity binds one immutable semantic MC input: action, actor/role, consent identity/request, requester, recipient, participant set, Conversation purpose, Connection aggregate/context, expected MC revision, and target transition. Reuse with changed input is `MALFORMED_OR_AMBIGUOUS_INTENT_REUSE` and fails closed. The identity correlates; it never authorizes.

An exact duplicate request or decision reconciles to the same authoritative outcome when established and does not create another mutation. Accept-versus-decline and accept-versus-withdraw conflicts are decided against the controlling `MC_PENDING` revision within one `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED`; at most one listed target can become authoritative. Arrival order, client timestamp, response order, transport success, and projection delivery order are not authority.

If a timeout or broken transport occurs after submission, the result is `UNKNOWN_AUTHORITATIVE_OUTCOME_AFTER_TRANSPORT_FAILURE` until the MC authority reconciles that same intent as committed, rejected, or still unknown. Blindly issuing a new semantic mutation is not reconciliation.

Revoke concurrent with live read/send, and Connection pause/close concurrent with live use, require action-time `CONJUNCTIVE_SNAPSHOT_EVALUATION_REQUIRED`. A protected use may proceed only on a coherent decision bound to both currently usable input revisions and the applicable restriction; otherwise it fails closed. This obligation does not select a transaction, lock, CAS, queue, event log, or distributed transaction.

## 8. Independent evidence adapters

### 8.1 Product Connection evidence adapter

The adapter requests the exact current Connection aggregate/context and participant set for the Conversation use. It accepts only source-authoritative, audience/purpose-valid, current and fresh `CN_ACTIVE`. `CN_NONE`, `CN_PENDING`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`, historical/superseded `CN_ACTIVE`, a different aggregate, mismatch, unknown, unavailable, stale, incomparable, or lag is unusable.

Its output preserves source identity, Connection aggregate/context identity, complete participants, audience/purpose applicability, state, source-local revision, currentness, freshness and condition. It neither back-writes Connection nor converts a non-active state into MC revocation.

### 8.2 Messaging Consent evidence adapter

The adapter requests the exact consent context for the same participant set, Conversation purpose, and current Connection aggregate/context. It accepts only source-authoritative, binding-valid, audience/purpose-valid, current and fresh `MC_ACTIVE`. All other MC states and all stale, unknown, unavailable, superseded, incomparable, mismatched, historical or lagged evidence are unusable.

Its output preserves MC source/identity, request/context identity, requester/recipient and participants, Conversation purpose, Connection context, state, source-local revision, currentness, freshness and condition. It neither back-writes MC nor uses valid CN evidence to repair MC evidence.

Both adapters are `INDEPENDENT_SOURCE_COMPOSITION_NO_GLOBAL_ATOMICITY`. One valid output cannot repair, refresh, infer, replace, order, or make authoritative the other.

## 9. Separate live-read and live-send evaluators

For each decision dimension, positive evaluation requires exactly:

1. current/fresh authoritative participant-bound `CN_ACTIVE` for the exact current Connection aggregate/context;
2. current/fresh authoritative participant-, Conversation-purpose-, Connection-context-bound `MC_ACTIVE` for that same context; and
3. no separately authoritative Product Conversation lifecycle restriction forbidding the requested live operation.

The accepted current MVP gives live read and live send the same two positive authority prerequisites, but each evaluator produces its own decision, conditions and action-time revalidation. A read grant cannot be presented as a send grant, and a send grant cannot be presented as a read/history grant. Future prerequisite divergence requires separately accepted authority.

| CN input | MC input | Restriction input | Live-read result | Live-send result |
|---|---|---|---|---|
| Valid current/fresh exact-context `CN_ACTIVE` | Valid current/fresh exact-context `MC_ACTIVE` | No authoritative prohibition | May grant after separate evaluation | May grant after separate evaluation |
| Any unusable CN condition | Valid MC | Any | Deny/unknown according to CN condition | Deny/unknown according to CN condition |
| Valid CN | Any unusable MC condition | Any | Deny/unknown according to MC condition | Deny/unknown according to MC condition |
| Any unusable CN condition | Any unusable MC condition | Any | Deny/unknown; preserve both conditions | Deny/unknown; preserve both conditions |
| Valid CN | Valid MC | Authoritative `CV_PAUSED` or `CV_CLOSED` restriction | Deny affected live read | Deny affected live send |
| Valid CN | Valid MC | Restriction required but unknown/unavailable/stale | Fail closed for affected operation | Fail closed for affected operation |

Denial or unknown does not invent deletion, content absence, guilt, punishment, Safety status, Relationship state, Connection mutation, MC mutation, Conversation history result, or legal conclusion.

## 10. Privacy-minimal live-access projection and construction gate

The projection MAY expose only what the authorized participant/audience/purpose needs to understand and revalidate current live access: separate live-read and live-send decisions; coarse per-input condition class; exact context binding reference sufficient for revalidation; evaluated source-local revision references; and whether a separately authoritative Conversation restriction affected the decision. It MUST NOT expose private messages, previews, drafts, private unread details, hidden Safety evidence, compatibility scores, analytics/training signals, inferred desirability, or person-worth.

No private Conversation content may be built, fetched, projected, prefetched, subscribed, cached for display, or otherwise treated as live-readable before the current live-read evaluator grants. The content lookup/construction boundary therefore occurs after, and is conditional on, live-read revalidation. A denied or unknown result MUST short-circuit private-content construction.

No draft/send operation may be treated as authorized before current live-send revalidation grants. Existing Conversation rows, unread counts, cached messages, drafts, routes, peer IDs, notifications, transport connections, Match state, legacy peer/chat identities, local client state, or earlier grant results never substitute for either source input.

Privacy-minimal auditability records only semantic evidence necessary to establish authority source, bounded identities/roles, action or evaluation class, source revisions/conditions, logical-intent correlation, and authoritative outcome/deny category. It does not authorize message-content logging, broad telemetry, behavior analytics, model training, new retention, or production data processing.

## 11. Product Conversation lifecycle restriction adapter

This plan does not define Product Conversation writer or transition authority. The restriction adapter can consume only a separately authoritative lifecycle source. If such a source establishes `CV_PAUSED` or `CV_CLOSED`, current `MC_ACTIVE` cannot override the restriction. If a restriction is required for the exact live operation but cannot be established as current/fresh and binding-valid, the affected live evaluator fails closed.

The adapter does not map `CV_PAUSED` to an MC pause state, `CV_CLOSED` to `MC_REVOKED`, or resumption to a consent transition. It cannot reopen an MC terminal identity. `CV_LOCKED`, `CV_PENDING_CONSENT`, and `CV_ACTIVE` likewise do not create, infer, or repair MC authority. Exact Conversation mutation actor/source/target rules remain outside IP-05.

## 12. Common condition and consistency obligations

The plan uses the accepted IP-01 semantic conditions: `AUTHORITATIVE_DOMAIN_OUTCOME`, `DOMAIN_VALIDATION_REJECTION`, `AUTHORITY_BINDING_MISMATCH`, `AUDIENCE_PURPOSE_MISMATCH`, `ACTOR_ROLE_MISMATCH`, `REVISION_CONFLICT_OR_STALE_INTENT`, `UNKNOWN_AUTHORITATIVE_OUTCOME_AFTER_TRANSPORT_FAILURE`, `AUTHORITY_UNAVAILABLE`, `EVIDENCE_STALE`, `EVIDENCE_SUPERSEDED`, `REVISION_INCOMPARABLE_OR_CURRENTNESS_UNKNOWN`, `PROJECTION_LAG`, `TRANSPORT_TIMEOUT_OR_FAILURE`, `MALFORMED_OR_AMBIGUOUS_INTENT_REUSE`, and `RETAINED_POLICY_PREREQUISITE_UNESTABLISHED`.

| Boundary | Required obligation class | Consequence |
|---|---|---|
| One MC mutation | `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED` | Validate controlling revision and establish one authoritative target together. |
| Live-read evaluation | `CONJUNCTIVE_SNAPSHOT_EVALUATION_REQUIRED` | Bind both independent source evaluations and restriction status to one descriptive read decision. |
| Live-send evaluation | `CONJUNCTIVE_SNAPSHOT_EVALUATION_REQUIRED` | Revalidate both independent sources and restriction at the send action boundary. |
| CN/MC composition | `INDEPENDENT_SOURCE_COMPOSITION_NO_GLOBAL_ATOMICITY` | Preserve lineages and per-source failures; do not assume distributed commit/global order. |
| Projection | `EVENTUALLY_PROJECTABLE_AFTER_AUTHORITATIVE_OUTCOME` | Lag never authorizes continued use of displaced evidence. |
| Correction/revocation | `DEPENDENT_INVALIDATION_PROPAGATION_REQUIRED` | Newer authority evidence invalidates dependent old live decisions. |
| Transport attempt/result | `TRANSPORT_OBSERVATION_ONLY` | It cannot establish consent or live access. |

## 13. Downstream documentary contracts

| Consumer | Minimum technology-neutral output | Required boundary |
|---|---|---|
| IP-06 Home | Separate coarse live-read and live-send decisions, per-source usability categories, exact current context binding, and evaluated CN/MC revisions. | Home remains read-only, receives no private content, owns no writer, and revalidates any protected action. |
| IP-07 Notification | Privacy-minimal source event/evidence references and separate current live-access conditions where an independently accepted event class needs them. | Notification eligibility/payload/delivery do not grant access; no message preview/private unread detail; action-time revalidation required. |
| IP-08 API/interface planning | Semantic request/response obligations for MC mutation, reconciliation, evidence retrieval, separate live-read/live-send evaluation, and coarse conditions. | No endpoint, protocol, wire payload, generated specification, or status-code choice is made here. |
| IP-09 persistence/schema planning | Logical identities, bindings, lineage, revision, intent correlation, terminality, decision boundaries, projection and invalidation obligations. | No schema, table, key, index, database, transaction or event-log mechanism is selected here. |
| IP-10 client integration planning | Separate descriptive read/send states, fail-closed condition handling, action-time revalidation, and no-content-before-read-grant sequencing. | Client state, routes, caches, notifications and optimism never become authority; no client code is authorized. |

Each downstream plan requires its own fresh independent review and explicit Owner dispatch. This artifact creates none of those tasks.

## 14. Future bounded-slice checkpoints

A later implementation-execution task, if separately authorized, must prove at least: exact path allowlist; accepted API/persistence contracts; MC transition/role conformance; terminal fresh-context enforcement; independent CN and MC adapter conditions; separate read/send evaluation; action-time race handling; ambiguous outcome reconciliation; invalidation propagation; no private-content construction before read grant; privacy-minimal audit fields; fake/non-private test-data authority; and tooling/build evidence. Passing this document does not satisfy any execution checkpoint.

The smallest implementation slices remain separable: MC writer semantics; MC reconciliation/projection; CN evidence adapter; MC evidence adapter; live-read evaluator and construction guard; live-send evaluator and send guard; Conversation restriction adapter; downstream projections. Slice separation is planning structure, not a choice of modules, services, processes, repositories, or deployment units.

## 15. High-density validation matrix

Every row is independently checkable. `PASS` means this plan states the accepted obligation without resolving an excluded seam. `RETAINED_UNKNOWN` means the named authority or mechanism remains unavailable and fail-closed. `DEFERRED` means a future capability is explicitly outside this lane. No row authorizes implementation.

| ID | Independently checkable assertion | Status | Evidence/plan disposition |
|---|---|---|---|
| A01 | MC vocabulary contains exactly six named states. | PASS | §2. |
| A02 | `MC_NONE` is the only request source state. | PASS | §3. |
| A03 | Request targets only `MC_PENDING`. | PASS | §3. |
| A04 | Either participant may request only inside exact current authoritative `CN_ACTIVE`. | PASS | §3. |
| A05 | Request binds requester directionally. | PASS | §§3,5. |
| A06 | Request binds recipient directionally. | PASS | §§3,5. |
| A07 | Accept source is only `MC_PENDING`. | PASS | §3. |
| A08 | Accept actor is only the bound recipient. | PASS | §3. |
| A09 | Accept targets only `MC_ACTIVE`. | PASS | §3. |
| A10 | Decline actor is only the bound recipient. | PASS | §3. |
| A11 | Decline targets only `MC_DECLINED`. | PASS | §3. |
| A12 | Withdraw actor is only the bound requester. | PASS | §3. |
| A13 | Withdraw targets only `MC_WITHDRAWN`. | PASS | §3. |
| A14 | Revoke source is only `MC_ACTIVE`. | PASS | §3. |
| A15 | Either bound participant may revoke. | PASS | §3. |
| A16 | Revoke targets only `MC_REVOKED`. | PASS | §3. |
| A17 | Direct `MC_NONE -> MC_ACTIVE` is invalid. | PASS | §3. |
| A18 | Every unlisted direct transition is invalid. | PASS | §3. |
| A19 | MC has no pause/resume/close state. | PASS | §§2,3. |
| A20 | Each MC mutation uses one source-owned semantic decision boundary. | PASS | §§3,12. |
| B01 | `MC_DECLINED` is terminal for its identity. | PASS | §4. |
| B02 | `MC_WITHDRAWN` is terminal for its identity. | PASS | §4. |
| B03 | `MC_REVOKED` is terminal for its identity. | PASS | §4. |
| B04 | Retry cannot reopen a terminal identity. | PASS | §4. |
| B05 | Correction cannot reopen a terminal identity. | PASS | §4. |
| B06 | A later attempt requires a fresh consent context. | PASS | §4. |
| B07 | A later attempt requires a fresh request identity. | PASS | §4. |
| B08 | A later attempt requires fresh requester/recipient bindings. | PASS | §4. |
| B09 | A later attempt requires fresh participant binding. | PASS | §4. |
| B10 | A later attempt requires fresh Conversation-purpose binding. | PASS | §4. |
| B11 | A later attempt requires fresh current-Connection-context binding. | PASS | §4. |
| B12 | A later attempt requires a fresh logical intent. | PASS | §4. |
| B13 | A later attempt restarts at `MC_NONE`. | PASS | §4. |
| B14 | A later activation traverses `MC_PENDING`. | PASS | §4. |
| B15 | Old `MC_ACTIVE` never transfers to a new Connection aggregate. | PASS | §4. |
| B16 | Historical consent cannot authorize live access. | PASS | §4. |
| B17 | Route reuse cannot reopen consent. | PASS | §4. |
| B18 | Client-local state cannot reopen consent. | PASS | §4. |
| B19 | Terminal old intent identity cannot represent a new attempt. | PASS | §4. |
| B20 | Fresh consent still independently requires current/fresh exact-context `CN_ACTIVE`. | PASS | §4. |
| C01 | MC evidence binds its accepted authority source. | PASS | §6. |
| C02 | MC evidence binds the complete participant set. | PASS | §6. |
| C03 | Mutation evidence binds actor and role. | PASS | §6. |
| C04 | MC evidence binds audience. | PASS | §6. |
| C05 | MC evidence binds Conversation purpose. | PASS | §6. |
| C06 | MC evidence binds exact Connection aggregate/context. | PASS | §6. |
| C07 | MC evidence exposes source-local revision. | PASS | §6. |
| C08 | Currentness is evaluated independently from freshness. | PASS | §6. |
| C09 | Freshness is use-specific and source-owned. | PASS | §6. |
| C10 | Unknown MC evidence fails closed. | PASS | §6. |
| C11 | Unavailable MC evidence fails closed. | PASS | §6. |
| C12 | Stale MC evidence fails closed. | PASS | §6. |
| C13 | Superseded MC evidence fails closed. | PASS | §6. |
| C14 | Incomparable MC revisions fail closed. | PASS | §6. |
| C15 | Projection lag fails closed for live authority. | PASS | §6. |
| C16 | Participant mismatch fails closed. | PASS | §6. |
| C17 | Audience mismatch fails closed. | PASS | §6. |
| C18 | Purpose mismatch fails closed. | PASS | §6. |
| C19 | Aggregate/context mismatch fails closed. | PASS | §6. |
| C20 | No cross-domain global revision is introduced. | PASS | §6. |
| D01 | Only newer authoritative evidence establishes correction. | PASS | §6. |
| D02 | Only newer authoritative evidence establishes revocation. | PASS | §6. |
| D03 | Only newer authoritative evidence establishes supersession. | PASS | §6. |
| D04 | Newer `MC_REVOKED` invalidates older `MC_ACTIVE` live grants. | PASS | §6. |
| D05 | Newer non-active CN revision invalidates older `CN_ACTIVE` live grants. | PASS | §6. |
| D06 | Reordered projection delivery never invokes last-received-wins. | PASS | §§6,7. |
| D07 | Correction cannot legalize an unlisted transition. | PASS | §6. |
| D08 | Derived gate evidence binds the evaluated CN revision. | PASS | §6. |
| D09 | Derived gate evidence binds the evaluated MC revision. | PASS | §6. |
| D10 | Protected use revalidates both revisions at action time. | PASS | §6. |
| D11 | One logical intent has immutable action. | PASS | §7. |
| D12 | One logical intent has immutable actor/role. | PASS | §7. |
| D13 | One logical intent has immutable consent/request identity. | PASS | §7. |
| D14 | One logical intent has immutable participant bindings. | PASS | §7. |
| D15 | One logical intent has immutable purpose and Connection context. | PASS | §7. |
| D16 | One logical intent has immutable expected revision and target. | PASS | §7. |
| D17 | Changed-input identity reuse fails closed. | PASS | §7. |
| D18 | Idempotency identity correlates but does not authorize. | PASS | §7. |
| D19 | Exact duplicate request reconciles to one semantic outcome. | PASS | §7. |
| D20 | Exact duplicate acceptance reconciles to one semantic outcome. | PASS | §7. |
| E01 | Accept-versus-decline resolves against controlling `MC_PENDING`. | PASS | §7. |
| E02 | Accept-versus-withdraw resolves against controlling `MC_PENDING`. | PASS | §7. |
| E03 | At most one conflicting listed target becomes authoritative. | PASS | §7. |
| E04 | Transport arrival order is not conflict authority. | PASS | §7. |
| E05 | Client timestamp is not conflict authority. | PASS | §7. |
| E06 | Response order is not conflict authority. | PASS | §7. |
| E07 | Transport success is not domain authority. | PASS | §7. |
| E08 | Timeout after submission yields unknown authoritative outcome. | PASS | §7. |
| E09 | Reconciliation uses the same immutable intent/context. | PASS | §7. |
| E10 | Blind new mutation is not reconciliation. | PASS | §7. |
| E11 | Reconciliation distinguishes commit, rejection and still-unknown. | PASS | §7. |
| E12 | Revoke concurrent with read requires action-time evaluation. | PASS | §7. |
| E13 | Revoke concurrent with send requires action-time evaluation. | PASS | §7. |
| E14 | Connection pause concurrent with live use requires action-time evaluation. | PASS | §7. |
| E15 | Connection close concurrent with live use requires action-time evaluation. | PASS | §7. |
| E16 | Race obligations do not choose transactions. | PASS | §7. |
| E17 | Race obligations do not choose locks or CAS. | PASS | §7. |
| E18 | Race obligations do not choose queues or event logs. | PASS | §7. |
| E19 | MC writer does not mutate Connection. | PASS | §5. |
| E20 | MC writer does not mutate Conversation lifecycle. | PASS | §5. |
| F01 | CN adapter accepts current/fresh exact-context `CN_ACTIVE`. | PASS | §8.1. |
| F02 | CN adapter rejects `CN_NONE`. | PASS | §8.1. |
| F03 | CN adapter rejects `CN_PENDING`. | PASS | §8.1. |
| F04 | CN adapter rejects `CN_PAUSED`. | PASS | §8.1. |
| F05 | CN adapter rejects `CN_CLOSED`. | PASS | §8.1. |
| F06 | CN adapter rejects `CN_DECLINED`. | PASS | §8.1. |
| F07 | CN adapter rejects `CN_WITHDRAWN`. | PASS | §8.1. |
| F08 | CN adapter rejects `CN_EXPIRED`. | PASS | §8.1. |
| F09 | CN adapter rejects historical `CN_ACTIVE`. | PASS | §8.1. |
| F10 | CN adapter rejects superseded `CN_ACTIVE`. | PASS | §8.1. |
| F11 | CN adapter rejects `CN_ACTIVE` from another aggregate. | PASS | §8.1. |
| F12 | CN adapter rejects participant mismatch. | PASS | §8.1. |
| F13 | CN adapter rejects audience mismatch. | PASS | §8.1. |
| F14 | CN adapter rejects purpose mismatch. | PASS | §8.1. |
| F15 | CN adapter rejects unknown currentness. | PASS | §8.1. |
| F16 | CN adapter rejects source unavailability. | PASS | §8.1. |
| F17 | CN adapter rejects stale evidence. | PASS | §8.1. |
| F18 | CN adapter rejects incomparable revision evidence. | PASS | §8.1. |
| F19 | CN projection lag cannot authorize live use. | PASS | §8.1. |
| F20 | CN adapter never back-writes Connection or MC. | PASS | §8.1. |
| G01 | MC adapter accepts current/fresh exact-context `MC_ACTIVE`. | PASS | §8.2. |
| G02 | MC adapter rejects `MC_NONE`. | PASS | §8.2. |
| G03 | MC adapter rejects `MC_PENDING`. | PASS | §8.2. |
| G04 | MC adapter rejects `MC_DECLINED`. | PASS | §8.2. |
| G05 | MC adapter rejects `MC_WITHDRAWN`. | PASS | §8.2. |
| G06 | MC adapter rejects `MC_REVOKED`. | PASS | §8.2. |
| G07 | MC adapter rejects historical `MC_ACTIVE`. | PASS | §8.2. |
| G08 | MC adapter rejects superseded `MC_ACTIVE`. | PASS | §8.2. |
| G09 | MC adapter rejects `MC_ACTIVE` bound to another Connection aggregate. | PASS | §8.2. |
| G10 | MC adapter rejects participant mismatch. | PASS | §8.2. |
| G11 | MC adapter rejects audience mismatch. | PASS | §8.2. |
| G12 | MC adapter rejects Conversation-purpose mismatch. | PASS | §8.2. |
| G13 | MC adapter rejects unknown currentness. | PASS | §8.2. |
| G14 | MC adapter rejects source unavailability. | PASS | §8.2. |
| G15 | MC adapter rejects stale evidence. | PASS | §8.2. |
| G16 | MC adapter rejects incomparable revision evidence. | PASS | §8.2. |
| G17 | MC projection lag cannot authorize live use. | PASS | §8.2. |
| G18 | Valid CN cannot repair invalid MC. | PASS | §8.2. |
| G19 | Valid MC cannot repair invalid CN. | PASS | §8. |
| G20 | MC adapter never back-writes either authority. | PASS | §8.2. |
| H01 | Live read requires valid current/fresh exact-context CN. | PASS | §9. |
| H02 | Live read requires valid current/fresh exact-context MC. | PASS | §9. |
| H03 | Live send requires valid current/fresh exact-context CN. | PASS | §9. |
| H04 | Live send requires valid current/fresh exact-context MC. | PASS | §9. |
| H05 | Read and send evaluators are separate. | PASS | §9. |
| H06 | Read grant cannot grant send. | PASS | §9. |
| H07 | Send grant cannot grant read. | PASS | §9. |
| H08 | Send grant cannot grant history. | PASS | §9. |
| H09 | Current MVP prerequisites may match without merging decisions. | PASS | §9. |
| H10 | Both invalid inputs preserve both conditions. | PASS | §9. |
| H11 | One invalid conjunct denies/unknowns live read. | PASS | §9. |
| H12 | One invalid conjunct denies/unknowns live send. | PASS | §9. |
| H13 | Restriction prohibition denies affected read. | PASS | §9. |
| H14 | Restriction prohibition denies affected send. | PASS | §9. |
| H15 | Required unknown restriction fails closed. | PASS | §9. |
| H16 | Gate evaluator owns neither CN nor MC. | PASS | §§5,9. |
| H17 | Gate evaluator never back-writes CN. | PASS | §§5,9. |
| H18 | Gate evaluator never back-writes MC. | PASS | §§5,9. |
| H19 | Gate denial does not invent a domain lifecycle outcome. | PASS | §9. |
| H20 | Future prerequisite divergence requires accepted authority. | PASS | §9. |
| I01 | Live projection exposes separate read/send decisions. | PASS | §10. |
| I02 | Live projection preserves coarse per-input conditions. | PASS | §10. |
| I03 | Live projection preserves context binding for revalidation. | PASS | §10. |
| I04 | Live projection preserves evaluated source revisions. | PASS | §10. |
| I05 | Projection result is descriptive, not permanent permission. | PASS | §§6,10. |
| I06 | No private content is built before read grant. | PASS | §10. |
| I07 | No private content is fetched before read grant. | PASS | §10. |
| I08 | No private content is projected before read grant. | PASS | §10. |
| I09 | No private content is prefetched before read grant. | PASS | §10. |
| I10 | No private content is subscribed before read grant. | PASS | §10. |
| I11 | No private content is cached for display before read grant. | PASS | §10. |
| I12 | Deny/unknown short-circuits content construction. | PASS | §10. |
| I13 | No draft operation is authorized before send grant. | PASS | §10. |
| I14 | No send operation is authorized before send grant. | PASS | §10. |
| I15 | Conversation row/unread/cache/draft cannot grant access. | PASS | §10. |
| I16 | Route/peer/notification/transport cannot grant access. | PASS | §10. |
| I17 | Match/legacy/local state cannot grant access. | PASS | §10. |
| I18 | Projection excludes message previews and private unread details. | PASS | §10. |
| I19 | Projection excludes hidden Safety, scores and inferred worth. | PASS | §10. |
| I20 | Auditability does not expand telemetry or content logging. | PASS | §10. |
| J01 | Restriction adapter consumes only separate authoritative CV evidence. | PASS | §11. |
| J02 | Restriction adapter defines no Conversation writer. | PASS | §11. |
| J03 | `CV_PAUSED` cannot be overridden by `MC_ACTIVE`. | PASS | §11. |
| J04 | `CV_CLOSED` cannot be overridden by `MC_ACTIVE`. | PASS | §11. |
| J05 | `CV_PAUSED` does not create an MC pause state. | PASS | §11. |
| J06 | `CV_CLOSED` does not create `MC_REVOKED`. | PASS | §11. |
| J07 | Conversation resumption is not an MC transition. | PASS | §11. |
| J08 | `CV_LOCKED` cannot create or repair MC authority. | PASS | §11. |
| J09 | `CV_PENDING_CONSENT` cannot create or repair MC authority. | PASS | §11. |
| J10 | `CV_ACTIVE` cannot create or repair MC authority. | PASS | §11. |
| J11 | Home output remains privacy-minimal and read-only. | PASS | §13. |
| J12 | Notification output is not notification eligibility or permission. | PASS | §13. |
| J13 | Notification-originated action requires current revalidation. | PASS | §13. |
| J14 | API planning receives semantics but no endpoint choice. | PASS | §13. |
| J15 | Persistence planning receives logical obligations but no schema choice. | PASS | §13. |
| J16 | Client planning cannot turn display state into authority. | PASS | §13. |
| J17 | Downstream consumers receive no private content from the evaluator. | PASS | §13. |
| J18 | Projection is eventually projectable only after authority outcome. | PASS | §12. |
| J19 | Projection lag never preserves a displaced grant. | PASS | §12. |
| J20 | Transport evidence remains observation only. | PASS | §12. |
| K01 | Historical Conversation read/access authority is unestablished. | RETAINED_UNKNOWN | Owner/seam: Owner material fact; affected layer: separate history/read-after-revoke-or-close lane; blocks IP-05 core: no; blocks one adapter/slice: yes, history adapter; blocks later implementation execution: yes, history only; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K02 | Conversation retention rules are unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: retention schedules/jobs/claims; blocks IP-05 core: no; blocks one adapter/slice: yes, retention; blocks later implementation execution: yes, retention only; blocks production only: yes for production retention; fail-closed sufficient for current IP-05 planning: yes. |
| K03 | Export/access/portability rules are unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: rights API/UI/workflow; blocks IP-05 core: no; blocks one adapter/slice: yes, export/portability; blocks later implementation execution: yes, rights slice; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K04 | Deletion/erasure rules are unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: deletion behavior; blocks IP-05 core: no; blocks one adapter/slice: yes, deletion; blocks later implementation execution: yes, deletion slice; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K05 | Account-exit Conversation behavior is unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: post-exit access/retention/deletion; blocks IP-05 core: no; blocks one adapter/slice: yes, account exit; blocks later implementation execution: yes, exit slice; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K06 | Peer-visible deletion effects are unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal and product authority; affected layer: peer effects; blocks IP-05 core: no; blocks one adapter/slice: yes, deletion peer effects; blocks later implementation execution: yes, that slice; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K07 | Backup/legal-hold treatment is unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: retention/deletion exceptions; blocks IP-05 core: no; blocks one adapter/slice: yes, backup/legal hold; blocks later implementation execution: yes, that slice; blocks production only: yes for production guarantees; fail-closed sufficient for current IP-05 planning: yes. |
| K08 | Rights-request verification/timeline/refusal/appeal is unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: rights workflow; blocks IP-05 core: no; blocks one adapter/slice: yes, rights workflow; blocks later implementation execution: yes, that slice; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K09 | Region-specific data-right implementation is unestablished. | RETAINED_UNKNOWN | Owner/seam: region-specific legal authority; affected layer: jurisdiction adapter; blocks IP-05 core: no; blocks one adapter/slice: yes, regional adapter; blocks later implementation execution: yes, regional slice; blocks production only: yes for regional production; fail-closed sufficient for current IP-05 planning: yes. |
| K10 | Exact Product Conversation mutation actor/source/target rules are unestablished here. | RETAINED_UNKNOWN | Owner/seam: separate Owner product authority; affected layer: Conversation lifecycle writer; blocks IP-05 core: no, restriction consumption suffices; blocks one adapter/slice: yes, Conversation mutation writer; blocks later implementation execution: yes, that writer; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K11 | Endpoint/protocol/wire representation is unselected. | RETAINED_UNKNOWN | Owner/seam: later IP-08 technology/interface authority; affected layer: interface representation; blocks IP-05 core: no; blocks one adapter/slice: yes, concrete interface; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K12 | Schema/database/index/key representation is unselected. | RETAINED_UNKNOWN | Owner/seam: later IP-09 persistence authority; affected layer: persistence representation; blocks IP-05 core: no; blocks one adapter/slice: yes, persistence; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K13 | Transaction/lock/CAS mechanism is unselected. | RETAINED_UNKNOWN | Owner/seam: later implementation technology authority; affected layer: atomicity realization; blocks IP-05 core: no; blocks one adapter/slice: yes, writer/race mechanism; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K14 | Queue/event-log/broker mechanism is unselected. | RETAINED_UNKNOWN | Owner/seam: later implementation technology authority; affected layer: propagation/transport mechanism if used; blocks IP-05 core: no; blocks one adapter/slice: no because none is required; blocks later implementation execution: only if selected design depends on it; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K15 | Language/framework is unselected. | RETAINED_UNKNOWN | Owner/seam: later implementation technology authority; affected layer: executable realization; blocks IP-05 core: no; blocks one adapter/slice: no; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K16 | Service/module/deployment topology is unselected. | RETAINED_UNKNOWN | Owner/seam: later architecture/deployment authority; affected layer: ownership placement and deployment; blocks IP-05 core: no; blocks one adapter/slice: no; blocks later implementation execution: yes for concrete allocation; blocks production only: yes for deployment; fail-closed sufficient for current IP-05 planning: yes. |
| K17 | Clock/scheduler mechanism is unselected. | RETAINED_UNKNOWN | Owner/seam: source-owned freshness plus later technology authority; affected layer: concrete freshness/timed work realization; blocks IP-05 core: no; blocks one adapter/slice: yes only if a source rule needs time; blocks later implementation execution: yes for that adapter; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K18 | Revision and idempotency physical representation is unselected. | RETAINED_UNKNOWN | Owner/seam: later interface/persistence authority; affected layer: concurrency and reconciliation representation; blocks IP-05 core: no; blocks one adapter/slice: yes, concrete writer/interface; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K19 | Authentication/identity-establishment mechanism is unselected. | RETAINED_UNKNOWN | Owner/seam: separate identity/security technology authority; affected layer: actor/participant establishment adapter; blocks IP-05 core: no; blocks one adapter/slice: yes, authentication adapter; blocks later implementation execution: yes; blocks production only: no; fail-closed sufficient for current IP-05 planning: yes. |
| K20 | Real/private-data processing authority is absent. | RETAINED_UNKNOWN | Owner/seam: processing/real-data authority; affected layer: runtime content and production validation; blocks IP-05 core: no; blocks one adapter/slice: yes, any real-data slice; blocks later implementation execution: yes for real/private data; blocks production only: yes for production; fail-closed sufficient for current IP-05 planning: yes. |
| L01 | The plan defines a technology-neutral MC writer responsibility. | PASS | §§3,5. |
| L02 | The plan defines separate CN and MC adapters. | PASS | §8. |
| L03 | The plan defines separate live-read and live-send evaluators. | PASS | §9. |
| L04 | The plan defines a pre-content live-read guard. | PASS | §10. |
| L05 | The plan defines a pre-send live-send guard. | PASS | §10. |
| L06 | The plan defines correction/revocation invalidation. | PASS | §§6,12. |
| L07 | The plan defines ambiguous-outcome reconciliation. | PASS | §7. |
| L08 | The plan defines privacy-minimal downstream outputs. | PASS | §13. |
| L09 | The plan selects no API or persistence technology. | PASS | §§1,13. |
| L10 | The plan performs no backend/client/runtime implementation. | PASS | §§1,14. |
| L11 | Every successor still requires independent acceptance and Owner dispatch. | PASS | §13. |
| L12 | This candidate creates no implementation authority. | PASS | §§1,16. |
| L13 | A future Conversation-history authority lane is outside IP-05. | DEFERRED | No history grant is inferred. |
| L14 | Any future divergence of live-read prerequisites is outside IP-05. | DEFERRED | Requires separately accepted authority. |
| L15 | Any future divergence of live-send prerequisites is outside IP-05. | DEFERRED | Requires separately accepted authority. |
| L16 | A Product Conversation mutation-writer plan is outside IP-05. | DEFERRED | Only restriction consumption is planned. |
| L17 | Concrete API/generated-interface artifacts are outside IP-05. | DEFERRED | Reserved for separately authorized later work. |
| L18 | Concrete persistence/schema/migration artifacts are outside IP-05. | DEFERRED | Reserved for separately authorized later work. |
| L19 | Flutter/client implementation is outside IP-05. | DEFERRED | Only future documentary client obligations are supplied. |
| L20 | Production/private-data release is outside IP-05. | DEFERRED | Separate processing, legal, Safety, tooling and Owner gates remain closed. |

## 16. Totals, retained-seam disposition, and stop boundary

The matrix contains exactly 240 independently checkable rows:

`PASS = 212 / RETAINED_UNKNOWN = 20 / BLOCKED = 0 / DEFERRED = 8`

Every retained unknown is classified in K01–K20 by affected layer and whether it blocks IP-05 core, one adapter/slice, later implementation execution, or production only. None blocks this documentary core because the accepted live-only contract is complete and each absent authority can remain explicit and fail closed. This does not imply that later execution or production is ready.

Historical Conversation access, retention, export/access/portability, deletion/erasure, account exit, peer-visible effects, backups/legal hold, rights workflows, and regional rights remain separate Track-2/legal/material-fact seams. No denial here implies content deletion, content absence, loss of legal rights, or a history decision.

Required release sequence is: publish this single candidate; obtain a fresh independent ACCEPT/REJECT review; then require an explicit Owner gate for any successor. This candidate does not self-accept, merge, promote `main`, implement, or start IP-06, IP-07, IP-08, IP-09, or IP-10.

`NO IMPLEMENTATION AUTHORITY, PRIVATE-DATA PROCESSING AUTHORITY, CONVERSATION-HISTORY AUTHORITY, LEGAL AUTHORITY, SAFETY AUTHORITY, OR PRODUCTION AUTHORITY WAS CREATED.`
