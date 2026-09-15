# EliteSync v10｜Product Connection Implementation Plan｜v0.1

Status: `CANDIDATE — DOCUMENTARY IMPLEMENTATION PLANNING ONLY — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task authority: `ac63afd128b7503cbbc7c20655279f50fce1c52e`

Authorized artifact: `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_V0_1.md`

## 1. Outcome and authority boundary

This candidate defines a technology-neutral implementation responsibility plan for Product Connection. It consumes the accepted IP-01 common contract, accepted BA-04 technical design and Owner-accepted post-terminal fresh-aggregate rule without changing their semantics.

It creates no code, endpoint, protocol, wire contract, schema, database, framework, service/module/deployment topology, transaction/lock/CAS mechanism, queue, event log, clock, scheduler, client mechanism, expiry policy, private-data processing or production authority.

Expected classification:

`PRODUCT CONNECTION IMPLEMENTATION PLAN ESTABLISHED — TECHNOLOGY-NEUTRAL AGGREGATE / MUTATION / PROJECTION / CONCURRENCY PLAN EXPLICIT — EXPIRY SEAM RETAINED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

## 2. Exact lifecycle vocabulary and ownership

The Product Connection lifecycle vocabulary is exactly:

`CN_NONE / CN_PENDING / CN_ACTIVE / CN_PAUSED / CN_CLOSED / CN_DECLINED / CN_WITHDRAWN / CN_EXPIRED`

The Connection aggregate writer is the sole semantic responsibility that validates and authors lifecycle outcomes, same-lineage revisions, currentness, corrections and participant-authorized projection evidence. It is not a selected service, database, process, route, UI, cache or transport.

One aggregate/request binds one exact participant set and one consent lifecycle. Request creation establishes initiator/requester and recipient roles. After `CN_ACTIVE`, both are connected participants. If paused, the identity of the participant who caused the current pause remains authority-bound for resume.

`CN_NONE` is the starting condition of a fresh aggregate context, never a reset target for an old terminal aggregate.

## 3. Exact state and transition contract

| State | Meaning | Same-aggregate successors | Terminal/boundary |
|---|---|---|---|
| `CN_NONE` | No Connection consent process exists in this fresh aggregate context. | `CN_PENDING` | Not consent and not a reset target. |
| `CN_PENDING` | Initiator's authoritative request awaits the bound recipient's independent decision. | `CN_ACTIVE`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` | Not mutual consent. |
| `CN_ACTIVE` | Bound recipient accepted that same current pending request. | `CN_PAUSED`, `CN_CLOSED` | Necessary but insufficient for Conversation. |
| `CN_PAUSED` | Current Connection was paused by an identified participant. | `CN_ACTIVE`, `CN_CLOSED` | Not active consent for live gate and not terminal. |
| `CN_CLOSED` | Active/paused Connection was closed. | None | Terminal for this aggregate. |
| `CN_DECLINED` | Recipient declined this pending request. | None | Terminal for this request. |
| `CN_WITHDRAWN` | Initiator withdrew this pending request. | None | Terminal for this request. |
| `CN_EXPIRED` | Pending request expired under separately established authoritative policy. | None | Terminal; not inferred from time or transport. |

Allowed direct transitions and actors:

| Source | Action | Required actor | Target | Required semantic decision |
|---|---|---|---|---|
| `CN_NONE` | request | Either currently eligible candidate as initiator/requester | `CN_PENDING` | Fresh aggregate; exact participants/roles; then-current eligibility/authority; current revision/freshness; audience/purpose. |
| `CN_PENDING` | accept | Bound recipient only | `CN_ACTIVE` | Same authoritative pending request and unchanged aggregate/participants/roles. Recipient acceptance alone establishes active consent. |
| `CN_PENDING` | decline | Bound recipient only | `CN_DECLINED` | Same current request and recipient role. |
| `CN_PENDING` | withdraw | Bound initiator/requester only | `CN_WITHDRAWN` | Same current request and initiator role. |
| `CN_PENDING` | expire | Product Connection authority under established expiry policy | `CN_EXPIRED` | Same current request and independently authoritative policy applicability. |
| `CN_ACTIVE` | pause | Either connected participant | `CN_PAUSED` | Same current aggregate; outcome binds pausing participant. |
| `CN_ACTIVE` | close | Either connected participant | `CN_CLOSED` | Same current active aggregate. |
| `CN_PAUSED` | resume | Participant who caused the current pause | `CN_ACTIVE` | Same current pause evidence identifies that actor. |
| `CN_PAUSED` | close | Either connected participant | `CN_CLOSED` | Same current paused aggregate. |

Every row also requires current authoritative revision, usable freshness, exact actor/role, participant, audience, purpose and aggregate bindings. Any unlisted transition is invalid. Direct `CN_NONE -> CN_ACTIVE` is forbidden.

## 4. Technology-neutral responsibility decomposition

These are semantic responsibilities, not selected implementation units.

| Responsibility | Required obligation | Must not do |
|---|---|---|
| Connection aggregate writer | Validate one listed transition against controlling aggregate revision and author exactly one outcome. | Infer state from route, local data, transport, Match or Conversation. |
| Request issuance | Create one fresh aggregate request and `CN_PENDING` evidence after current eligibility/authority passes. | Create `CN_ACTIVE`, reuse a terminal aggregate or infer recipient consent. |
| Role-binding handler | Preserve exact initiator, recipient, connected-participant and current pausing-participant roles. | Infer role from payload position, identifier similarity or membership alone. |
| Recipient-decision handler | Validate recipient-only accept/decline against the same current request. | Let initiator accept, infer acceptance from silence or transport. |
| Requester-withdraw handler | Validate initiator-only withdrawal while current `CN_PENDING`. | Let recipient withdraw the request or revive terminal state. |
| Pause/resume/close handler | Enforce either-participant pause/close and pausing-participant-only resume. | Treat connectivity, messaging, route or stale active evidence as a transition. |
| Expiry adapter | Supply applicable authoritative expiry evidence when separate policy exists. | Choose duration/clock/policy or infer expiry. |
| Terminal/fresh-aggregate handler | Reject all successors on terminal identity and require full new request/acceptance path for later lifecycle. | Reset, reopen, reactivate or reuse old identity/intent/evidence. |
| Projection handler | Provide privacy-minimal participant-authorized current evidence. | Become a writer or public Connection/profile source. |
| Invalidation propagation | Make newer correction/revocation/supersession displace old evidence and dependent grants. | Create another domain outcome or reopen terminal identity. |
| Intent/reconciliation handler | Correlate immutable intents, exact duplicates, conflicts and ambiguous outcomes. | Treat idempotency or delivery as authority. |
| Downstream evidence adapter | Expose only the accepted current-`CN_ACTIVE` evidence contract to authorized consumers. | Create Messaging Consent, Conversation access or Relationship. |

## 5. Common mutation and authoritative-outcome plan

Every request, accept, decline, withdraw, expire, pause, resume or close intent must:

1. be evaluated by Product Connection authority as mutation intent, not projection/transport observation;
2. bind authenticated actor and the exact role required by section 3;
3. bind exact aggregate/request and participant set;
4. bind one immutable logical intent to action and semantic input;
5. bind expected revision and compare it with the controlling same-lineage revision;
6. evaluate currentness and usable freshness independently;
7. bind accepted audience and purpose;
8. satisfy the exact source/action/actor/target row and current domain prerequisites;
9. decide revision validation and authoritative outcome as `SINGLE_AUTHORITY_DECISION_BOUNDARY_REQUIRED`; and
10. expose source outcome/rejection/unknown semantics sufficient for projection and invalidation.

Stale, superseded, incomparable, mismatched, unavailable or unknown required evidence fails closed. There is no implicit rebase. Transport receipt, response, timeout, cache or optimistic UI is not the outcome.

## 6. Request, recipient decision and active lifecycle details

### 6.1 Request issuance

A request establishes one fresh aggregate, exact participants, requester and recipient roles, exact Product Connection purpose, then-current eligibility/authority evidence, new logical intent and new `CN_PENDING` revision. The requester's action supplies their intent only; it does not supply recipient acceptance.

An exact duplicate request reconciles to the same aggregate/request and authoritative outcome. Changed participants, roles, purpose, eligibility context or aggregate under the same idempotency identity is malformed reuse.

### 6.2 Recipient acceptance and decline

Only the bound recipient may act on the current pending request:

- acceptance alone establishes the same aggregate's `CN_ACTIVE`;
- decline establishes terminal `CN_DECLINED`;
- initiator action, Match mutual acceptance, route entry, existing chat, notification, optimistic UI or transport success cannot substitute;
- concurrent accept/decline resolves against the controlling `CN_PENDING` revision and can establish only one outcome.

### 6.3 Withdrawal and expiry

Only the bound requester may withdraw current `CN_PENDING`, establishing terminal `CN_WITHDRAWN`.

Only Product Connection authority applying a separately established current expiry policy may establish `CN_EXPIRED`. Unknown policy, duration, clock basis or extension semantics make the expiry action unavailable; countdown, scheduler observation, elapsed local time, nonresponse and transport timeout are insufficient.

### 6.4 Pause, resume and close

Either connected participant may pause current `CN_ACTIVE`; the outcome binds the pausing participant. Only that participant may resume the same current `CN_PAUSED`. Either participant may close from current `CN_ACTIVE` or `CN_PAUSED`.

Pause immediately makes prior `CN_ACTIVE` evidence unusable for the Conversation live gate. A live-gate or send/access consumer observing stale active evidence must revalidate and fail closed; it cannot wait for UI or cache convergence to preserve access.

## 7. Terminal and fresh-aggregate rule

`CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN` and `CN_EXPIRED` are terminal for their existing aggregate/request identities.

The old identity cannot transition to `CN_NONE`, `CN_PENDING`, `CN_ACTIVE` or `CN_PAUSED`; cannot be reopened, reset, resumed, reactivated, extended or retried; and cannot reuse old idempotency, revision, recipient decision, `CN_ACTIVE` or permitted-action evidence.

A later lifecycle, if then-current product eligibility/authority permits it, must:

1. create a semantically distinct aggregate/request;
2. bind fresh participants/roles/audience/purpose/provenance/revision/freshness;
3. use a fresh logical intent;
4. begin at its own `CN_NONE`;
5. establish its own `CN_NONE -> CN_PENDING` request; and
6. require that new aggregate's bound recipient acceptance before establishing new `CN_ACTIVE`.

A correction or supersession is evidence replacement within exact authority scope, not a terminal-to-nonterminal transition or shortcut around the new aggregate.

## 8. Idempotency, concurrency and ambiguous transport

A logical intent is one actor's one semantic action against one exact aggregate and input. It cannot authenticate, authorize, order revisions or prove success.

| Case | Required authoritative resolution |
|---|---|
| Duplicate request | One aggregate/request and one authoritative pending/later outcome. |
| Duplicate recipient acceptance | One `CN_ACTIVE` outcome if that intent committed; otherwise evaluate current revision. |
| Accept vs decline | Exactly one current-revision outcome: `CN_ACTIVE` or `CN_DECLINED`. |
| Accept vs requester withdrawal | Exactly one current-revision outcome: `CN_ACTIVE` or `CN_WITHDRAWN`. |
| Accept vs expiry | Exactly one current-revision outcome: `CN_ACTIVE` or `CN_EXPIRED`; expiry cannot compete without accepted policy. |
| Pause vs close | If close controls, pause is stale; if pause controls, later close re-evaluates current `CN_PAUSED`. |
| Pause vs stale live/send observation | New pause makes old active evidence unusable; consumer revalidates and fails closed. |
| Resume vs close | If close controls, resume is stale; if resume controls, a later close must freshly evaluate `CN_ACTIVE`. |
| Duplicate pause/resume/close | Reconcile to one transition/outcome; duplicate delivery creates no additional lifecycle change. |
| Stale revision mutation | Reject/fail closed; do not apply because it was valid against an older revision. |
| Old aggregate replay | Reject old identity, intent, revision and decisions after a fresh aggregate exists. |
| Changed semantic input under reused identity | Reject as malformed/ambiguous reuse or require a new valid intent. |
| Timeout after possible commit | Reconcile the same intent against current authority; infer neither success nor failure. |
| Reordered projection | Preserve newer authority; never last-received-wins. |
| Participant/aggregate/role mismatch | Reject mutation/protected read; do not infer role from route or payload. |
| Historical `CN_ACTIVE` after newer non-active state | Treat as superseded/historical and unusable for Connection or Conversation gate. |

Every conflict is resolved by authoritative current revision and domain preconditions, never client arrival or transport order. No transaction, lock, CAS, uniqueness constraint, queue, event log or broker is selected.

## 9. Correction, revocation, supersession and lag

Only newer Product Connection authority evidence in the same exact aggregate lineage/scope may establish correction, revocation or supersession. Incomparable aggregate lineages cannot correct one another.

The plan requires:

- displaced evidence is unusable for protected action and live-gate consumption;
- a corrected actor/participant/purpose binding invalidates mismatched dependent evidence;
- a newer `CN_PAUSED`, `CN_CLOSED` or other non-active outcome invalidates prior active consent evidence;
- projection lag never rolls current authority backward;
- consumers fail closed when currentness is unknown;
- currentness and freshness remain separate; and
- correction/revocation does not imply deletion, guilt, Safety, punishment, fraud or another domain outcome.

Projection propagation may be `EVENTUALLY_PROJECTABLE_AFTER_AUTHORITATIVE_OUTCOME`, but old evidence cannot authorize once displacement is known or currentness is not established.

## 10. Participant-authorized projection plan

The projection is privacy-minimal, Product-Connection-owned and read-only. It binds authenticated viewer, participant role, exact aggregate, participant set, audience/purpose, provenance, source-local revision/currentness and freshness.

| Projection class | Minimum semantics | Boundary |
|---|---|---|
| Aggregate | Exact current lifecycle context distinguishable from earlier/later aggregates. | No concrete identifier representation selected. |
| Participants/roles | Viewer-authorized initiator/recipient/connected/pausing-participant view. | Membership alone grants no audience or action. |
| Current CN state | Exactly one current authority-authored state, or explicit non-domain condition. | Loading/offline/timeout are not states. |
| Revision/freshness | Lineage, controlling revision relation, currentness, usable freshness and supersession condition. | No global revision or last-received-wins. |
| Permitted actions | Descriptive actor/role/aggregate/revision/freshness-bound actions. | Non-self-authorizing; writer revalidates. |
| Terminal history | Minimum separately authorized historical extent, with old identity explicit. | No current consent or restart/live-gate authority. |
| Explanation | Minimum state/actor-category/non-meaning needed for the Product Connection purpose. | No other participant's private raw reason. |

The projection distinguishes current, unknown, unavailable, stale, superseded, incomparable, projection lag and participant/audience/purpose mismatch. Any unusable required evidence fails closed for protected action. Absence of a projected action does not prove a terminal state.

## 11. IP-05 Messaging Consent / Conversation live-gate evidence contract

IP-05 may consume Product Connection evidence only if all of the following are independently established for the current aggregate/context:

- Product Connection authority owner and provenance;
- exact participant set;
- exact current aggregate identity;
- current authoritative `CN_ACTIVE`;
- Product Connection lineage and controlling revision/currentness;
- usable freshness for the exact live-gate evaluation;
- audience and Conversation-purpose binding; and
- no controlling correction, revocation, pause, closure, terminal state or supersession.

This evidence is necessary but insufficient. IP-05 must independently establish current participant/purpose/Connection-context-bound `MC_ACTIVE`. Live read and live send remain separate grant dimensions.

The following never satisfy the Product Connection conjunct:

- historical or superseded `CN_ACTIVE`;
- `CN_ACTIVE` from another aggregate;
- `CN_PENDING`;
- `CN_PAUSED`;
- `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN` or `CN_EXPIRED`;
- unknown, unavailable, stale, incomparable, mismatched or projection-lagged evidence.

One valid `MC_ACTIVE` cannot repair invalid Connection evidence; one valid `CN_ACTIVE` cannot repair invalid Messaging Consent. A later new aggregate's `CN_ACTIVE` inherits no historical `MC_ACTIVE`.

## 12. Expiry and policy adapter contract

An expiry adapter is a semantic input boundary, not a scheduler/provider/module. It may make expiry eligible only when separately accepted authority establishes policy identity, applicability scope, currentness, duration/time semantics and any extension/renewal rule required for the exact pending request.

Until then:

- `CN_PENDING -> CN_EXPIRED` is unavailable;
- no duration or deadline is inferred;
- no local/server/client clock is selected;
- no scheduler observation establishes expiry;
- no nonresponse, retry exhaustion or transport timeout establishes expiry;
- no extension, renewal or reset is permitted; and
- other independently valid pending transitions remain evaluated normally.

Policy absence fails closed for expiry only and does not block the rest of this IP-04 plan.

## 13. Downstream documentary contracts

Acceptance of this plan would supply only the following Product Connection semantics. It starts no downstream task.

| Downstream lane | Connection contract supplied after acceptance | Still excluded |
|---|---|---|
| IP-05 | Current-aggregate, participant-bound, audience/purpose-valid, current/fresh authoritative `CN_ACTIVE` evidence as one conjunct; independent `MC_ACTIVE` still required. | Messaging Consent lifecycle, live-gate implementation, Conversation history/read/send authority. |
| IP-06 Home | Privacy-minimal current aggregate/state, independent revision/freshness/condition and descriptive action semantics. | Home writer, precedence, ranking, private reasons or UI. |
| IP-07 Notification | Privacy-minimal source-event/evidence semantics, currentness/freshness, terminality and action-time revalidation. | Event allowlist, eligibility, payload, provider, delivery or notification implementation. |
| IP-08 API/interface | Semantic responsibilities for request/mutations/reconciliation/projection/live-gate evidence and conditions. | Endpoint, protocol, wire field, status code or executable specification. |
| IP-09 persistence/schema | Logical obligations for aggregate identity, participant/role binding, lineage, immutable intent, revision, terminality, pause actor and invalidation relations. | Database, schema, table, index, key, migration or transaction mechanism. |
| IP-10 client | Exact lifecycle/presentation/role/action/condition semantics and fail-closed reconciliation. | Flutter code, routes, state management, generated clients, dependencies or runtime work. |

DAG:

`accepted IP-04 -> IP-05`

`accepted IP-02 + accepted IP-03 + accepted IP-04 + accepted IP-05 -> IP-06 and IP-07 -> IP-08 -> IP-09 -> IP-10`

Every arrow remains an acceptance dependency plus fresh explicit task, not automatic dispatch.

## 14. Future bounded-slice checkpoints

These are future acceptance obligations, not current execution authority.

| Slice | Documentary prerequisite | Future checkpoint |
|---|---|---|
| C1 Aggregate/role foundation | Accepted IP-01 and IP-04 plan | Exact participant/requester/recipient/pause-actor bindings and eight-state vocabulary preserved. |
| C2 Request/recipient decision | C1 plus accepted eligibility input | Request creates only `CN_PENDING`; recipient-only accept/decline and all request races pass. |
| C3 Active pause/resume/close | C1-C2 | Either-participant pause/close, pausing-participant-only resume and current-revision races pass. |
| C4 Terminal/fresh aggregate | C1-C3 | Four terminal states reject reopen; later lifecycle passes full fresh request/accept path. |
| C5 Expiry adapter | Separate accepted expiry authority | Only current pending request may expire; no timer/transport substitution. |
| C6 Projection | C1-C5 as applicable | Privacy-minimal participant projection and condition distinctions pass. |
| C7 IP-05 evidence adapter | C1-C6 plus accepted audience/purpose | Only current-aggregate `CN_ACTIVE` is emitted; necessary/insufficient boundary passes. |
| C8 Reconciliation/invalidation | C1-C7 | Duplicate/race/timeout/reorder/correction cases preserve authoritative state. |
| C9 Downstream handoff | Independent acceptance of relevant upstream plans | Only section 13 semantics released; no downstream writer authority transfers. |

No slice is authorized to start here.

## 15. High-density validation matrix

Each row is independently checkable. `PASS` establishes a documentary obligation only.

| ID | Area | Independently checkable assertion | Evidence/basis | Disposition | Impact |
|---|---|---|---|---|---|
| IP04-001 | Lifecycle vocabulary | CN_NONE is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-002 | Lifecycle vocabulary | CN_PENDING is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-003 | Lifecycle vocabulary | CN_ACTIVE is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-004 | Lifecycle vocabulary | CN_PAUSED is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-005 | Lifecycle vocabulary | CN_CLOSED is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-006 | Lifecycle vocabulary | CN_DECLINED is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-007 | Lifecycle vocabulary | CN_WITHDRAWN is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-008 | Lifecycle vocabulary | CN_EXPIRED is preserved as an exact Connection state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-009 | Lifecycle vocabulary | Transport/loading/offline conditions are not CN states. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-010 | Lifecycle vocabulary | No additional CN state is introduced. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-011 | Aggregate ownership and identity | Product Connection authority alone authors lifecycle outcomes. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-012 | Aggregate ownership and identity | One aggregate binds one exact participant set. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-013 | Aggregate ownership and identity | One aggregate has one independent same-lineage revision order. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-014 | Aggregate ownership and identity | Request phase and later states remain in the same aggregate lineage. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-015 | Aggregate ownership and identity | A later lifecycle is distinguishable from every historical aggregate. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-016 | Aggregate ownership and identity | Aggregate identity is distinct from Match identity. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-017 | Aggregate ownership and identity | Aggregate identity is distinct from Conversation identity. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-018 | Aggregate ownership and identity | Aggregate identity is distinct from route/cache/transport identity. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-019 | Aggregate ownership and identity | CN_NONE exists only in a fresh aggregate context. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-020 | Aggregate ownership and identity | No universal cross-aggregate revision is created. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-021 | Request issuance | Request source is fresh CN_NONE. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-022 | Request issuance | Either currently eligible candidate may act as requester. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-023 | Request issuance | Request binds the requester as initiator. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-024 | Request issuance | Request binds the other participant as recipient. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-025 | Request issuance | Request binds exact participants and Product Connection purpose. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-026 | Request issuance | Request evaluates then-current eligibility/authority. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-027 | Request issuance | Request evaluates controlling revision/currentness and freshness. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-028 | Request issuance | Request establishes CN_PENDING only. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-029 | Request issuance | Requester intent does not establish recipient acceptance. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-030 | Request issuance | Direct CN_NONE to CN_ACTIVE is forbidden. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-031 | Recipient decisions | Only the bound recipient may accept CN_PENDING. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-032 | Recipient decisions | Acceptance binds the same authoritative pending request. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-033 | Recipient decisions | Acceptance binds unchanged participants and roles. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-034 | Recipient decisions | Recipient acceptance alone establishes CN_ACTIVE. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-035 | Recipient decisions | Initiator cannot accept their own request as recipient. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-036 | Recipient decisions | Only the bound recipient may decline CN_PENDING. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-037 | Recipient decisions | Decline establishes terminal CN_DECLINED. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-038 | Recipient decisions | Silence cannot establish decline. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-039 | Recipient decisions | Notification dismissal cannot establish decline. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-040 | Recipient decisions | Transport success cannot establish acceptance. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-041 | Withdrawal and expiry | Only bound requester may withdraw current CN_PENDING. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-042 | Withdrawal and expiry | Requester withdrawal establishes terminal CN_WITHDRAWN. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-043 | Withdrawal and expiry | Recipient cannot perform requester withdrawal. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-044 | Withdrawal and expiry | Route exit cannot establish withdrawal. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-045 | Withdrawal and expiry | Only Product Connection authority may establish expiry. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-046 | Withdrawal and expiry | Only current CN_PENDING is expiry-eligible. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-047 | Withdrawal and expiry | Expiry requires separately accepted applicable policy. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-048 | Withdrawal and expiry | Expiry establishes terminal CN_EXPIRED. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-049 | Withdrawal and expiry | Nonresponse cannot establish expiry. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-050 | Withdrawal and expiry | Transport timeout cannot establish expiry. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-051 | Pause/resume/close | Either connected participant may pause CN_ACTIVE. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-052 | Pause/resume/close | Pause establishes CN_PAUSED. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-053 | Pause/resume/close | Pause evidence binds the pausing participant. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-054 | Pause/resume/close | Only the current pausing participant may resume. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-055 | Pause/resume/close | Resume transitions current CN_PAUSED to CN_ACTIVE. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-056 | Pause/resume/close | The other participant cannot resume that pause. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-057 | Pause/resume/close | Either participant may close current CN_ACTIVE. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-058 | Pause/resume/close | Either participant may close current CN_PAUSED. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-059 | Pause/resume/close | Close establishes terminal CN_CLOSED. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-060 | Pause/resume/close | Connectivity or messaging state cannot pause/resume/close Connection. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-061 | Terminality | CN_CLOSED is terminal for its aggregate. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-062 | Terminality | CN_DECLINED is terminal for its request. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-063 | Terminality | CN_WITHDRAWN is terminal for its request. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-064 | Terminality | CN_EXPIRED is terminal for its request. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-065 | Terminality | Terminal identity cannot transition to CN_NONE. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-066 | Terminality | Terminal identity cannot transition to CN_PENDING. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-067 | Terminality | Terminal identity cannot transition to CN_ACTIVE. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-068 | Terminality | Terminal identity cannot transition to CN_PAUSED. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-069 | Terminality | Terminal identity cannot be reopened/reset/reactivated. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-070 | Terminality | Correction cannot serve as terminal-to-nonterminal transition. | BA-04/Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-071 | Fresh aggregate rule | Later lifecycle requires then-current eligibility/authority. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-072 | Fresh aggregate rule | Later lifecycle requires distinct aggregate identity. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-073 | Fresh aggregate rule | Later lifecycle requires fresh participant/role bindings. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-074 | Fresh aggregate rule | Later lifecycle requires fresh audience/purpose/provenance bindings. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-075 | Fresh aggregate rule | Later lifecycle begins at its own CN_NONE. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-076 | Fresh aggregate rule | Later lifecycle requires new CN_NONE to CN_PENDING request. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-077 | Fresh aggregate rule | Later lifecycle requires new recipient acceptance. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-078 | Fresh aggregate rule | Old CN_ACTIVE cannot shortcut the new lifecycle. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-079 | Fresh aggregate rule | Old idempotency identity cannot be reused. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-080 | Fresh aggregate rule | Historical pairing cannot compel or imply acceptance. | Owner closure | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-081 | Mutation binding | Every mutation binds Product Connection authority owner. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-082 | Mutation binding | Every mutation binds authenticated actor. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-083 | Mutation binding | Every mutation validates exact actor role. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-084 | Mutation binding | Every mutation binds exact aggregate/request. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-085 | Mutation binding | Every mutation binds exact participant set. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-086 | Mutation binding | Every mutation binds expected controlling revision. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-087 | Mutation binding | Every mutation evaluates currentness and freshness separately. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-088 | Mutation binding | Every mutation binds accepted audience and purpose. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-089 | Mutation binding | Every mutation validates listed source/action/target. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-090 | Mutation binding | Unlisted transition fails closed. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-091 | Logical intent/idempotency | Logical intent binds one actor and one action. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-092 | Logical intent/idempotency | Logical intent binds one aggregate and participant set. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-093 | Logical intent/idempotency | Logical intent binds immutable semantic input. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-094 | Logical intent/idempotency | Exact duplicate request creates no second aggregate. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-095 | Logical intent/idempotency | Exact duplicate acceptance creates no second consent outcome. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-096 | Logical intent/idempotency | Exact duplicate pause creates no stacked pause. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-097 | Logical intent/idempotency | Exact duplicate close creates no second closure. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-098 | Logical intent/idempotency | Changed actor is not an exact duplicate. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-099 | Logical intent/idempotency | Changed aggregate is not an exact duplicate. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-100 | Logical intent/idempotency | Idempotency identity grants no consent or authority. | IP-01/BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-101 | Concurrency cases | Accept versus decline establishes only one current-revision outcome. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-102 | Concurrency cases | Accept versus requester withdrawal establishes only one outcome. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-103 | Concurrency cases | Accept versus expiry establishes only one outcome. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-104 | Concurrency cases | Expiry cannot compete without established policy. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-105 | Concurrency cases | Pause versus close resolves against controlling revision. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-106 | Concurrency cases | Resume versus close resolves against controlling revision. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-107 | Concurrency cases | Pause versus stale live-gate observation invalidates old active evidence. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-108 | Concurrency cases | Stale revision mutation is rejected without implicit rebase. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-109 | Concurrency cases | Old aggregate replay is rejected after fresh aggregate exists. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-110 | Concurrency cases | Client arrival order never chooses the domain winner. | BA-04/task | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-111 | Ambiguous transport | Transport timeout leaves authoritative outcome unknown. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-112 | Ambiguous transport | Broken response does not establish mutation failure. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-113 | Ambiguous transport | Transport acknowledgement does not establish mutation success. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-114 | Ambiguous transport | Reconciliation uses the same immutable logical intent. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-115 | Ambiguous transport | Reconciliation uses the same aggregate and actor context. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-116 | Ambiguous transport | Reconciliation may establish committed outcome. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-117 | Ambiguous transport | Reconciliation may establish authoritative rejection. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-118 | Ambiguous transport | Reconciliation may remain unknown. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-119 | Ambiguous transport | Reconciliation does not silently create a new intent. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-120 | Ambiguous transport | Unknown transport outcome is not a negative participant fact. | IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-121 | Correction/revocation/supersession | Only newer authority evidence may correct Connection evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-122 | Correction/revocation/supersession | Only newer authority evidence may revoke Connection evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-123 | Correction/revocation/supersession | Only newer authority evidence may supersede Connection evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-124 | Correction/revocation/supersession | Correction is scoped to the exact aggregate lineage. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-125 | Correction/revocation/supersession | Incomparable aggregates cannot correct each other. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-126 | Correction/revocation/supersession | Newer CN_PAUSED invalidates prior CN_ACTIVE for live use. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-127 | Correction/revocation/supersession | Newer CN_CLOSED invalidates prior CN_ACTIVE for live use. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-128 | Correction/revocation/supersession | Superseded projection cannot roll authority backward. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-129 | Correction/revocation/supersession | Currentness unknown fails closed for protected use. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-130 | Correction/revocation/supersession | Correction/revocation creates no Safety or adverse person meaning. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-131 | Projection responsibility | Projection is Product-Connection-owned and read-only. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-132 | Projection responsibility | Projection binds authenticated viewer. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-133 | Projection responsibility | Projection validates viewer participant role. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-134 | Projection responsibility | Projection binds exact aggregate and participant set. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-135 | Projection responsibility | Projection binds accepted audience and purpose. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-136 | Projection responsibility | Projection presents one current authoritative CN state or condition. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-137 | Projection responsibility | Projection preserves lineage/revision/currentness/freshness. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-138 | Projection responsibility | Projection actions are descriptive and non-self-authorizing. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-139 | Projection responsibility | Writer revalidates every projected action. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-140 | Projection responsibility | Projection does not expose another participant's private raw reason. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-141 | Projection conditions | Projection distinguishes current evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-142 | Projection conditions | Projection distinguishes unknown currentness. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-143 | Projection conditions | Projection distinguishes authority unavailable. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-144 | Projection conditions | Projection distinguishes stale evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-145 | Projection conditions | Projection distinguishes superseded evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-146 | Projection conditions | Projection distinguishes incomparable evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-147 | Projection conditions | Projection distinguishes projection lag. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-148 | Projection conditions | Audience mismatch withholds protected evidence. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-149 | Projection conditions | Participant mismatch rejects protected projection. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-150 | Projection conditions | Absence of action does not prove terminal state. | BA-04/IP-01 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-151 | IP-05 Connection conjunct | IP-05 input names Product Connection authority/provenance. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-152 | IP-05 Connection conjunct | IP-05 input binds exact current aggregate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-153 | IP-05 Connection conjunct | IP-05 input binds exact participant set. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-154 | IP-05 Connection conjunct | IP-05 input requires current authoritative CN_ACTIVE. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-155 | IP-05 Connection conjunct | IP-05 input requires controlling revision/currentness. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-156 | IP-05 Connection conjunct | IP-05 input requires usable freshness. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-157 | IP-05 Connection conjunct | IP-05 input requires Conversation-purpose/audience binding. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-158 | IP-05 Connection conjunct | Historical CN_ACTIVE cannot satisfy live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-159 | IP-05 Connection conjunct | CN_ACTIVE from another aggregate cannot satisfy live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-160 | IP-05 Connection conjunct | CN_ACTIVE is necessary but insufficient without current MC_ACTIVE. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-161 | Live-gate negative cases | CN_PENDING cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-162 | Live-gate negative cases | CN_PAUSED cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-163 | Live-gate negative cases | CN_CLOSED cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-164 | Live-gate negative cases | CN_DECLINED cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-165 | Live-gate negative cases | CN_WITHDRAWN cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-166 | Live-gate negative cases | CN_EXPIRED cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-167 | Live-gate negative cases | Superseded CN_ACTIVE cannot satisfy Conversation live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-168 | Live-gate negative cases | Stale or incomparable Connection evidence fails the live gate. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-169 | Live-gate negative cases | Valid MC_ACTIVE cannot repair invalid Connection evidence. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-170 | Live-gate negative cases | A new aggregate CN_ACTIVE inherits no historical MC_ACTIVE. | BA-04/BA-05 boundary | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-171 | Expiry adapter fail-closed | Expiry adapter selects no duration. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-172 | Expiry adapter fail-closed | Expiry adapter selects no policy trigger. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-173 | Expiry adapter fail-closed | Expiry adapter selects no clock basis. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-174 | Expiry adapter fail-closed | Expiry adapter selects no scheduler. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-175 | Expiry adapter fail-closed | Expiry adapter selects no extension rule. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-176 | Expiry adapter fail-closed | Unknown expiry policy makes expiry transition unavailable. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-177 | Expiry adapter fail-closed | Countdown cannot establish policy applicability. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-178 | Expiry adapter fail-closed | Scheduler observation cannot establish policy applicability. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-179 | Expiry adapter fail-closed | Retry exhaustion cannot establish expiry. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-180 | Expiry adapter fail-closed | Other valid CN_PENDING transitions remain independently evaluable. | BA-04 retained seam | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-181 | Cross-domain/non-substitution | Match mutual acceptance cannot create Connection. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-182 | Cross-domain/non-substitution | Connection cannot create Messaging Consent. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-183 | Cross-domain/non-substitution | Connection cannot create Conversation live read grant. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-184 | Cross-domain/non-substitution | Connection cannot create Conversation live send grant. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-185 | Cross-domain/non-substitution | Connection cannot create Conversation history authority. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-186 | Cross-domain/non-substitution | Connection cannot create Relationship state. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-187 | Cross-domain/non-substitution | Route/deep-link identity cannot create consent. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-188 | Cross-domain/non-substitution | Legacy peer/chat/cache/local state cannot create consent. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-189 | Cross-domain/non-substitution | Notification identity cannot create Connection authority. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-190 | Cross-domain/non-substitution | Pause/close/decline/withdraw/expiry creates no guilt or Safety finding. | BA-04 | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-191 | Downstream/non-goals | Home receives only privacy-minimal current Connection semantics. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-192 | Downstream/non-goals | Notification receives source evidence separately from notification eligibility. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-193 | Downstream/non-goals | IP-08 receives semantic interface responsibilities without endpoints. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-194 | Downstream/non-goals | IP-09 receives logical aggregate obligations without schema. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-195 | Downstream/non-goals | IP-10 receives lifecycle/action semantics without client implementation. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-196 | Downstream/non-goals | No transaction, lock or CAS is selected. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-197 | Downstream/non-goals | No queue, event log, database or schema is selected. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-198 | Downstream/non-goals | No language/framework or service topology is selected. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-199 | Downstream/non-goals | No clock/scheduler or client mechanism is selected. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-200 | Downstream/non-goals | Candidate publication starts no downstream task. | Task/DAG | `PASS` | Establishes IP-04 documentary obligation; creates no implementation or successor authority. |
| IP04-201 | Atomicity | Request validation and CN_PENDING outcome share one authoritative decision boundary. | IP-01/BA-04 | `PASS` | Semantic obligation only. |
| IP04-202 | Atomicity | Recipient acceptance validation and CN_ACTIVE outcome share one authoritative decision boundary. | IP-01/BA-04 | `PASS` | Semantic obligation only. |
| IP04-203 | Atomicity | Each pause/resume/close validates controlling revision with its outcome. | IP-01/BA-04 | `PASS` | Semantic obligation only. |
| IP04-204 | Atomicity | Accept/decline/withdraw/expiry races can establish only one successor revision. | IP-01/BA-04 | `PASS` | No mechanism selected. |
| IP04-205 | Consistency | Projection may lag only while displaced evidence cannot authorize protected use. | IP-01 | `PASS` | Preserves eventual projection boundary. |
| IP04-206 | Consistency | IP-05 conjunctive evaluation preserves independent CN and MC revisions. | IP-01/BA-05 | `PASS` | No global transaction/revision implied. |
| IP04-207 | Auditability | Intent/outcome evidence is privacy-minimal and excludes telemetry expansion. | IP-01 | `PASS` | Reconciliation only. |
| IP04-208 | Release gate | Independent IP-04 acceptance and a fresh task are required before IP-05 dispatch. | Task/DAG | `PASS` | Publication alone releases nothing. |
| IP04-209 | Expiry duration | Exact pending-request expiry duration remains unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: expiry adapter; blocks IP-04 itself: No; blocks one adapter/slice: Yes — expiry adapter only; blocks later implementation execution: Yes, CN_EXPIRED cannot be executed from a duration until accepted; blocks production only: No — blocks adapter before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-210 | Expiry policy/applicability | Exact expiry policy trigger and applicability rule remain unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: expiry adapter; blocks IP-04 itself: No; blocks one adapter/slice: Yes — expiry adapter only; blocks later implementation execution: Yes, authoritative expiry execution is blocked; blocks production only: No — blocks adapter before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-211 | Clock basis/time authority | Exact clock basis and time authority remain unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: expiry timing adapter; blocks IP-04 itself: No; blocks one adapter/slice: Yes — expiry timing slice only; blocks later implementation execution: Yes, expiry timing execution is blocked; blocks production only: No — blocks adapter before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-212 | Expiry extension/renewal | Extension, renewal and deadline-change rules remain unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: future expiry extension slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — future expiry slice only; blocks later implementation execution: Yes if extension/renewal is later pursued; blocks production only: No — old terminal request cannot be extended meanwhile; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-213 | Connection eligibility | Exact eligibility/authority criteria for request or later lifecycle remain scope-specific and unresolved here. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: request prerequisite adapter; blocks IP-04 itself: No; blocks one adapter/slice: Yes — request eligibility adapter only; blocks later implementation execution: Yes for real request issuance lacking accepted criteria; blocks production only: No — not solely production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-214 | Language/framework | Backend language and framework remain unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Implementation technology authority; affected lane: later Connection code execution; blocks IP-04 itself: No; blocks one adapter/slice: No — cross-cutting choice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-215 | API/wire | Endpoint, protocol, wire representation and status mapping remain unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: IP-08/interface authority; affected lane: Connection interface slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — interface slice only; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-216 | Database/schema | Database, schema, table, index and key design remain unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: IP-09/persistence authority; affected lane: Connection persistence slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — persistence slice only; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-217 | Transaction/lock/CAS | Concrete atomicity and concurrency mechanism remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Implementation authority; affected lane: Connection writer slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — consistency realization slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-218 | Queue/event log | Queue, broker and event-log mechanisms remain unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Implementation authority; affected lane: propagation/reconciliation slice if chosen; blocks IP-04 itself: No; blocks one adapter/slice: Yes — propagation mechanism slice; blocks later implementation execution: Yes if that realization is selected; blocks production only: No — this plan requires no such mechanism; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-219 | Service/module topology | Service, module and process allocation remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Architecture implementation authority; affected lane: Connection backend allocation; blocks IP-04 itself: No; blocks one adapter/slice: No — cross-cutting choice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-220 | Deployment topology | Deployment units and hosting topology remain unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Architecture/production authority; affected lane: Connection deployment; blocks IP-04 itself: No; blocks one adapter/slice: Yes — deployment slice; blocks later implementation execution: Yes for deployment; blocks production only: No — blocks deployment before production operation; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-221 | Revision representation | Concrete revision token/order representation remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: IP-08/IP-09 implementation authority; affected lane: revision-aware interface/persistence slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — revision representation slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-222 | Idempotency representation | Concrete intent/idempotency identity representation remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: IP-08/IP-09 implementation authority; affected lane: intent correlation slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — intent representation slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-223 | Concurrency realization | Mechanism that enforces conflicting single-successor decisions remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Implementation authority; affected lane: writer concurrency slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — concurrency slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-224 | Projection realization | Concrete read projection/cache/update mechanism remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: IP-08/IP-09 implementation authority; affected lane: Connection projection slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — projection slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-225 | Authentication mechanism | Concrete actor authentication and subject-establishment mechanism remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Security/interface implementation authority; affected lane: writer/projection integration slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — authentication integration slice; blocks later implementation execution: Yes; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-226 | Timer/scheduler mechanism | Concrete timer/scheduler mechanism remains unselected even if expiry policy is later accepted. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Implementation authority; affected lane: expiry implementation slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — expiry implementation slice; blocks later implementation execution: Yes after policy acceptance; blocks production only: No — blocks execution before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-227 | Transport retry/backoff | Concrete retry cadence/backoff/timeout policy remains unselected. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Interface/transport authority; affected lane: transport handling slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — transport slice only; blocks later implementation execution: Yes for concrete transport behavior; blocks production only: No — semantic reconciliation is already defined; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-228 | Connection notification allowlist | Concrete Connection event allowlist for Notification remains unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/product authority; affected lane: later IP-07 Connection eligibility adapter; blocks IP-04 itself: No; blocks one adapter/slice: Yes — Notification adapter only; blocks later implementation execution: Yes for concrete Connection notifications; blocks production only: No — Connection core is unaffected; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-229 | Conversation history/rights | Historical Conversation access, retention, export and deletion remain unresolved and outside Connection. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/legal/product authority; affected lane: separate Conversation history/rights lane; blocks IP-04 itself: No; blocks one adapter/slice: Yes — separate history/rights slice; blocks later implementation execution: Yes for that separate lane; blocks production only: No — not a Connection implementation prerequisite; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-230 | Regional legal policy | Region-specific consent/rights/processing conclusions remain unresolved. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/legal authority; affected lane: affected regional processing slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — regional adapter only; blocks later implementation execution: Yes where required; blocks production only: No — may block before production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-231 | Audit retention | Retention of explanatory Connection evidence remains unselected beyond minimum semantic auditability. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/legal/processing authority; affected lane: audit retention slice; blocks IP-04 itself: No; blocks one adapter/slice: Yes — audit retention slice only; blocks later implementation execution: Yes for durable retention implementation; blocks production only: No — not solely production; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-232 | Real/private-data processing | Authority to process real participant/private evidence remains absent. | Accepted retained seam | `RETAINED_UNKNOWN` | Owner/seam: Owner/legal/processing authority; affected lane: real-data Connection execution; blocks IP-04 itself: No; blocks one adapter/slice: No — production/real-data gate; blocks later implementation execution: No for synthetic planning; Yes for real-data execution; blocks production only: Yes — production/real-user processing only; fail-closed sufficient for current IP-04 planning: Yes. |
| IP04-233 | IP-05 | Messaging Consent and Conversation live-gate planning awaits accepted IP-04 and fresh task. | Accepted DAG | `DEFERRED` | Not started; only Connection evidence input is documented. |
| IP04-234 | IP-06 | Home planning awaits accepted IP-02 through IP-05. | Accepted DAG | `DEFERRED` | Not started; only Connection projection semantics supplied. |
| IP04-235 | IP-07 | Notification planning awaits accepted IP-02 through IP-05. | Accepted DAG | `DEFERRED` | Not started; eligibility/payload/delivery remain separate. |
| IP04-236 | IP-08 | Concrete API/interface planning awaits accepted domain plans. | Accepted DAG | `DEFERRED` | Deferred; no endpoint/wire artifact created. |
| IP04-237 | IP-09 | Concrete persistence/schema planning awaits accepted interfaces. | Accepted DAG | `DEFERRED` | Deferred; no database/schema artifact created. |
| IP04-238 | IP-10 | Client planning awaits backend/interface/persistence contracts. | Accepted DAG | `DEFERRED` | Deferred; no client mechanism created. |
| IP04-239 | Implementation/build | Source implementation and build/runtime validation require separate authority/tooling evidence. | Governance/tooling gate | `DEFERRED` | Deferred; IP-04 documentary completeness unaffected. |
| IP04-240 | Production | Deployment/private-data processing/production require separate Owner/legal/Safety/processing/tooling gates. | Production gate | `DEFERRED` | Deferred; no production authority created. |

## 16. Validation totals and retained-seam disposition

`PASS = 208 / RETAINED_UNKNOWN = 24 / BLOCKED = 0 / DEFERRED = 8`

Matrix cardinality: `240` independently checkable rows.

All 24 `RETAINED_UNKNOWN` rows identify owner/seam, affected lane, whether the gap blocks IP-04 itself, one adapter/slice, later execution or production only, and whether fail-closed behavior is sufficient for current IP-04 planning.

No retained seam blocks this documentary plan. The four expiry seams remain explicit and block only expiry-related behavior; other policy, technology, legal and processing seams remain attached to their named slices. None is converted into a default.

There are no `BLOCKED` semantic prerequisite rows for IP-04. This does not resolve any retained seam or create implementation/production permission.

The eight `DEFERRED` rows remain outside this candidate and create no automatic successor authority.

## 17. Review and stop boundary

This candidate requires fresh independent ACCEPT/REJECT review and cannot accept itself. If accepted, it supplies only section 13 documentary contracts. IP-05 and every later lane still require all accepted predecessors and a fresh explicit task.

No backend/API/schema/database/framework/service/client implementation, test/build/runtime execution, private-data processing, legal/Safety conclusion, merge, main promotion or successor task is authorized or performed.
