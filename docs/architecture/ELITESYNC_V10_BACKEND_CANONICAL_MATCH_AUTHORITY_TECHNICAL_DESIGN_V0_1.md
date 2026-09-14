# EliteSync v10｜Backend Canonical Match Authority Technical Design｜v0.1

Status: `TECHNICAL-DESIGN CANDIDATE — NESTED MATCH AUTHORITY DEFINED — INDEPENDENT REVIEW REQUIRED — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit: `77200cbb2c4c900e3e2da22e1b412dca6b83fa5a`

Task blob: `12ae46ae2c7ff6d7d6d13ffc3ff69035d69c5baf`

## 1. Result, purpose, and boundary

This candidate defines the transport- and storage-neutral semantic contract for the canonical Match authority consumed by `/progress/match`. It applies the accepted BA-03-RD01 nested model exactly: a participant-owned participation context and distinct Match-authority-owned two-participant proposal contexts, each with its own identity, lineage, revision, freshness, and idempotency scope.

The durable participation vocabulary is exactly:

`NOT_ENROLLED / ENROLLED / PAUSED / WITHDRAWN`

The durable proposal vocabulary is exactly:

`PENDING / MUTUALLY_ACCEPTED / DECLINED / WITHDRAWN / EXPIRED`

One-sided acceptance is current decision evidence inside `PENDING`, not a lifecycle state. Participation `WITHDRAWN` and proposal `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, and `EXPIRED` are terminal for their existing identities. A later participation lifecycle or proposal requires a fresh identity; a later proposal also requires fresh participant decisions.

This document selects no endpoint, wire format, schema, persistence model, transaction or lock, service topology, queue, clock, scheduler, deployment unit, authentication implementation, retry algorithm, or client implementation. It creates no Product Connection, Messaging Consent, Conversation, Relationship, Compatibility total-score, legal, Safety, or production authority.

## 2. Fixed authority provenance

All sources were resolved at fixed `origin/main` commit `77200cbb2c4c900e3e2da22e1b412dca6b83fa5a`.

| Key | Accepted artifact or bounded source | Fixed provenance and use |
|---|---|---|
| S1 | `ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_ACCEPTANCE_V0_1.md` | blob `bbb842ef1f50f2f898a9fde744f5ec202d174dfc`; accepts S2 and authorizes BA-03 redispatch while retaining policy seams. |
| S2 | `ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_V0_1.md` | accepted blob `64e40c6c6fa30a536a7bc4631f1fbf593400f9b1`; fixes the nested lifecycles, actors, terminality, cross-scope effects, and concurrency semantics. |
| S3 | `ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md` / accepted design | acceptance blob `565e425aa3550bb64a82c70ff08a107a896669a3`; accepted design blob `c448662bee3f452eb535f298c76388e5565717a4`; supplies binding, revision, freshness, correction, permitted-action, composition, and idempotency rules. |
| S4 | `ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md` / accepted decomposition | acceptance blob `9ac039e2d2b20e9eef3a03eeded53f5583fc9a49`; accepted result blob `a8404b3066680f37e9ff94bcfd705ed414cb8d07`; supplies the BA-03 scope and non-goals. |
| S5 | `ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md` / accepted contract | acceptance blob `72168985edbb801cce46dc0c33dae3babc2705ee`; accepted result blob `a97f97eafb09b18c604cd5785887a25db08c819d`; supplies B01-B writer/projection separation. |
| S6 | `ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_ACCEPTANCE_V0_1.md` / accepted result | acceptance blob `f85ecaefdcc819fa42964509d4b02cc4583fbad2`; accepted result blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418`; supplies accepted `MT_*`, audience, privacy, and cross-domain meanings. |
| S7 | `ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_ACCEPTANCE_V0_1.md` / accepted result | acceptance blob `2bdf77f832dafd552cac30d54debc47c42f67f79`; accepted result blob `1d99a8f681e8cbe58adab4cde4041111aa5f2087`; proves current projection vocabulary and legacy transport facts are not mutation authority. |
| S8 | `ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md` / accepted supplement | acceptance blob `063dc18309afdc8f477cc9b22a29da1842776556`; accepted design blob `b72ed9ec851d44aba7be65883186cb275fab22d1`; fixes no total score and the current one-unresolved-proposal MVP limit. |
| S9 | `ADR-013-PACING-AND-CANONICAL-MVP-INTERACTION-STATE-GOVERNANCE.md` | blob `e59e4e0a9e811aa0c51e7da762d2ee1b80a848fb`; fixes neutral meanings, non-coercive pacing, domain separation, and deferral of concrete timing values. |

No source conflict was found. Accepted projection vocabulary is reconciled below; it is not promoted to durable mutation authority.

## 3. Authority scopes and evidence contract

### 3.1 Participation context

One authenticated participant owns the participation intent for one participation-context identity. The Match authority alone authors the durable transition outcome after validating that actor intent and all current preconditions. Its lineage orders revisions only within that context.

| State | Meaning | Terminal | Permitted source transitions |
|---|---|---:|---|
| `NOT_ENROLLED` | Fresh context has no established enrollment. | No | Only to `ENROLLED` through explicit participant opt-in after current separate prerequisites pass. |
| `ENROLLED` | Participant currently permits Match participation for this context. | No | To `PAUSED` or `WITHDRAWN` by the same participant. |
| `PAUSED` | Participant has stopped new supply/acceptance activity for this context without adverse person meaning. | No | To `ENROLLED` on current-authorized resume, or `WITHDRAWN`. |
| `WITHDRAWN` | Participation is ended for this context identity. | Yes | None. Later return begins a fresh context at `NOT_ENROLLED` and requires fresh enrollment. |

### 3.2 Proposal context

Each proposal has one distinct proposal identity, exactly two bound participants, one Match-authority lineage, and one independent decision slot for each participant. Proposal identity, participant set, decision slots, revision, and idempotency scope cannot substitute for participation identity or another proposal.

| State | Meaning | Terminal | Permitted source transitions |
|---|---|---:|---|
| `PENDING` | Current proposal is open under current prerequisites; zero or one current acceptance may exist in its two decision slots. | No | To `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, or `EXPIRED` under the exact rules below. |
| `MUTUALLY_ACCEPTED` | Match authority has established two current acceptances for the same proposal and participant set. | Yes | None. Creates no downstream consent or access. |
| `DECLINED` | Either bound participant validly declined their own decision while the proposal was current `PENDING`. | Yes | None; neutral choice only. |
| `WITHDRAWN` | Match authority resolved the proposal under a separately authorized reason or required cross-scope participation effect. | Yes | None; not participant guilt or a participant-owned proposal mutation. |
| `EXPIRED` | Match authority resolved a current `PENDING` proposal under a separately accepted expiry policy. | Yes | None; no expiry may be inferred before such policy exists. |

### 3.3 Common envelope obligations

Every authoritative participation outcome, proposal outcome, and participant decision evidence must carry or make evaluable, without selecting a representation:

| Obligation | Participation evidence | Proposal/outcome evidence | Participant decision evidence |
|---|---|---|---|
| Authority owner/provenance | Match authority and attributable source | Match authority and attributable source | Match authority affirmation of the participant-authored intent |
| Identity/scope | Exact participation-context identity | Exact proposal identity and proposal lineage | Exact proposal identity and exact decision slot |
| Subject/participants | Exact authenticated participant | Exact two-participant set | Exact actor and the same exact two-participant set |
| Audience/purpose | Authorized viewer/use for Match participation | Authorized viewer/use for Match proposal | Authorized viewer/use for the proposal decision |
| Actor/role | Participant acting for their own context | Match authority/system for issuance/outcome; participant only for their own decision | Bound participant acting only in their own slot |
| Revision/currentness | Controlling revision within this context | Controlling revision within this proposal | Controlling decision evidence compatible with controlling proposal revision/scope |
| Freshness | Usable for the exact protected action | Usable for the exact protected action | Usable together with every conjunctive mutual-acceptance input |
| Correction/revocation | Newer Match-authority evidence in same lineage | Newer Match-authority evidence in same lineage | Newer authoritative evidence in the same decision/proposal scope |
| Permitted actions | Descriptive, actor/context/revision/freshness-bound | Descriptive, actor/context/revision/freshness-bound | Never inferred from slot membership alone |
| Logical intent/idempotency | Bound to actor, action, context, semantic input | Bound to writer action, proposal context, semantic input | Bound to actor, own slot, action, proposal, semantic input |

`CURRENT`, `SUPERSEDED`, `STALE`, `UNAVAILABLE`, and `UNKNOWN` remain distinct evidence conditions. A newer authoritative same-lineage revision may establish supersession; freshness failure establishes stale; inability to answer establishes unavailable; lack of established authority/currentness remains unknown. None automatically means absent, declined, withdrawn, expired, or failed.

Correction, revocation, or supersession is established only by newer Match-authority evidence in the same exact lineage/scope. Receipt order, UI order, cache order, local write time, countdown, or transport completion cannot order revisions. Incomparable lineage evidence cannot correct or authorize another lineage.

Permitted actions are advisory descriptions of what may be requested under the bound evidence. They neither authorize nor perform a mutation. Every request is revalidated by the Match authority against current actor, identity, participants, state, revision, freshness, purpose, audience, prerequisites, and idempotency semantics at write time.

## 4. Complete actor/source/target transition contract

### 4.1 Participation transitions

| Source | Requested action | Intent actor | Match-authority validation | Target/outcome | Forbidden substitute |
|---|---|---|---|---|---|
| Fresh context `NOT_ENROLLED` | enroll/opt in | Authenticated owner participant | Exact actor/context; explicit intent; then-current separately authoritative Match eligibility/readiness prerequisites all pass; currentness/freshness/purpose/audience pass | `ENROLLED` in a new authoritative revision | Readiness alone, route visit, local toggle, cache, legacy enrollment, transport success, or historical context |
| `ENROLLED` | pause | Same authenticated participant | Current controlling participation revision; actor/context/purpose/freshness pass | `PAUSED` in a newer revision | Offline state, notification dismissal, local flag, elapsed time, or proposal state |
| `PAUSED` | resume | Same authenticated participant | Current pause revision; then-current separate Match prerequisites pass; affirmative fresh resume intent | `ENROLLED` in a newer revision | Prior enrollment, reconnect, route open, cache, or expiry of time |
| `ENROLLED` | withdraw participation | Same authenticated participant | Current revision and actor/context binding pass | Terminal `WITHDRAWN` revision | Proposal decline/withdrawal, logout, account state, transport failure, or another participant |
| `PAUSED` | withdraw participation | Same authenticated participant | Current revision and actor/context binding pass | Terminal `WITHDRAWN` revision | Proposal decline/withdrawal, logout, account state, transport failure, or another participant |
| Historical `WITHDRAWN` | reopen/reset | No actor is authorized | Terminal identity rejects all successors | No transition | Retry, old idempotency identity, route, cache, local state, or old enrollment |
| Historical `WITHDRAWN` | later participation | Same participant in a distinct new context only | Fresh context identity, fresh prerequisites, and fresh enrollment intent required | New context begins `NOT_ENROLLED`, then may independently transition to `ENROLLED` | Reusing or editing the terminal context |

The contents of eligibility/readiness prerequisites are owned elsewhere and remain unresolved here. No prerequisite is added, inferred, or weakened by this contract.

### 4.2 Proposal issuance and decisions

| Source/context | Action | Authorized actor | Match-authority validation | Target/outcome | Forbidden substitute |
|---|---|---|---|---|---|
| Both participants currently `ENROLLED`; no unresolved proposal conflicts | issue proposal | Match authority/system only | Exact two participants; then-current separately authoritative prerequisites pass; current MVP limit passes; fresh proposal identity and purpose | New `PENDING` proposal plus two undecided slots | Participant, algorithm output, candidate card, route, compatibility label, legacy DTO, notification, or transport response |
| Current `PENDING`, actor slot undecided | accept own slot | Either exact bound participant for their own slot | Actor/role, proposal, participants, controlling revision, purpose/audience, freshness, and cross-scope participation pass | Remains `PENDING` after first acceptance; may become terminal `MUTUALLY_ACCEPTED` only after both slots pass | Other participant's action, historical decision, local boolean, countdown, cache, route, or acknowledgement |
| Current `PENDING` | decline own decision | Either exact bound participant for their own slot | Actor/role, proposal/participants, controlling revision, purpose/audience, and freshness pass | Terminal `DECLINED` revision | Silence, timeout, inferred motive, compatibility meaning, or another participant's decision |
| Current `PENDING` | withdraw proposal | Match authority/system only | Controlling proposal revision and separately product-authorized reason/cross-scope cause pass | Terminal `WITHDRAWN` revision | Participant retracting a decision, participant decline, local cancel, timer, transport failure, or notification |
| Current `PENDING` | expire proposal | Match authority/system only | A separately accepted expiry policy applies and its authority/scope/currentness pass | Terminal `EXPIRED` revision | Elapsed local time, countdown, scheduler observation alone, timeout, legacy value, or stale policy |
| Any terminal proposal | reopen/reset/mutate | No actor is authorized | Terminal identity rejects all successors | No transition | Retry, cache, route, notification, old decision, or new intent |
| Any terminal proposal | issue later proposal | Match authority/system under a fresh issuance | Then-current participation/prerequisites/MVP limit pass; fresh proposal identity and fresh empty slots | A distinct new `PENDING` proposal | Reusing terminal identity, decisions, revisions, idempotency identity, or countdown |

There is no participant-owned “withdraw my proposal decision” mutation. While current `PENDING`, a participant may accept or decline their own slot, or separately withdraw participation. Any future decision-retraction mutation distinct from those actions requires new accepted product authority.

### 4.3 Participation effects on a pending proposal

When a proposal participant's participation becomes `PAUSED` or `WITHDRAWN`, the associated still-`PENDING` proposal immediately fails its further-acceptance precondition. The participant-authored participation action is input evidence only; it does not transfer proposal-writer authority.

The Match authority must evaluate that newer participation evidence and author a newer proposal revision resolving the affected proposal to terminal proposal `WITHDRAWN`. Until this authoritative proposal revision is established, no further acceptance or mutual-acceptance outcome may be authorized; consumers must represent the proposal authority condition as unknown/unavailable/lagged as applicable, not fabricate withdrawal locally.

This cross-scope consequence conveys no motive, guilt, fraud, deception, Safety finding, punishment, incompatibility, undesirability, or other adverse person meaning. It does not rewrite the other participant's independent history or rights.

## 5. Mutual-acceptance conjunction

The Match authority may author `PENDING -> MUTUALLY_ACCEPTED` only if all of the following are simultaneously established:

1. the exact current proposal identity;
2. the exact two-participant set bound to that proposal;
3. one current acceptance in each participant's independent decision slot;
4. both actor identities and each actor's role as the owner of their own slot;
5. the controlling proposal lineage, revision, scope, and currentness;
6. the controlling decision revisions/currentness compatible with that proposal revision and scope;
7. usable freshness for the proposal and both decisions;
8. the exact Match audience and proposal purpose for the protected evaluation; and
9. a new Match-authority outcome revision binding the resulting terminal `MUTUALLY_ACCEPTED` transition.

Decision arrival order is irrelevant. The first acceptance remains unilateral evidence inside `PENDING`. If participants, scope, revision, freshness, participation authority, or another conjunct changes before the second acceptance is validated, the old decision cannot complete mutual acceptance.

Proposal identity alone, one acceptance, candidate card, route, countdown, Compatibility factor/label, cached projection, notification identity, legacy DTO, local boolean, or transport success is insufficient. No authoritative Compatibility total score exists.

`MUTUALLY_ACCEPTED` establishes only the terminal Match proposal outcome. It creates no Product Connection request or consent, Messaging Consent, Conversation live-read or live-send grant, Relationship state, Safety finding, guilt, verified truth, or public person meaning.

## 6. Logical intent, idempotency, and concurrency

A logical intent is one actor's one semantic action against one exact Match scope. Multiple transport attempts may carry the same intent. An idempotency identity remains bound to actor, role, action meaning, participation/proposal identity, decision slot where applicable, and semantic input. Reuse with changed semantic input is rejected as ambiguous misuse; it is never treated as a safe retry.

Duplicate delivery creates no second context, proposal, decision, or terminal outcome. Transport timeout or failure cannot prove mutation failure; transport acknowledgement cannot prove a domain outcome. An unknown result requires reconciliation with current authoritative evidence before a new business intent is issued. All races resolve against the controlling authoritative revision and domain preconditions, never client arrival, receipt, UI, cache, or transport-completion order alone.

## 7. Canonical `/progress/match` projection

The canonical projection is a privacy-minimal, participant-authorized read model. It is derived evidence, not a writer, capability token, or mutation result. It exposes only fields needed for the entitled viewer and exact Match purpose:

| Projection field class | Required semantics |
|---|---|
| Viewer binding | Exact authenticated viewer and viewer role; identity alone grants neither another participant's evidence nor action. |
| Participation evidence | Current participation-context identity/state plus Match provenance, independent lineage/revision/currentness/freshness, or explicit authority condition. |
| Proposal evidence | Current proposal identity/state where applicable, exact viewer-authorized participant binding, independent lineage/revision/currentness/freshness, or explicit authority condition. |
| Decision evidence | Viewer-appropriate minimum evidence: own slot and only the minimum other-slot/outcome fact needed to explain current proposal state; never another participant's private raw reason. |
| Mutual outcome | Presented only from authoritative terminal `MUTUALLY_ACCEPTED` evidence satisfying the full conjunction. |
| Permitted actions | Actor-appropriate descriptive actions with bound context/revision/freshness; writer must revalidate. |
| Reasons/factors | Only separately product-authorized reason/factor category, provenance, uncertainty, and purpose-minimal explanation; no raw private inputs or total score. |
| Authority condition | Distinguish `UNKNOWN`, `UNAVAILABLE`, `STALE`, `SUPERSEDED`, `INCOMPARABLE`, and projection lag without converting them to lifecycle states. |

Accepted presentation reconciliation:

| Presentation | Authoritative source when usable | Boundary |
|---|---|---|
| `MT_NOT_OPTED_IN` | Participation `NOT_ENROLLED` | Does not infer ineligibility or withdrawal. |
| `MT_ACTIVE` | Participation `ENROLLED` with no more specific current proposal presentation | Does not prove a candidate, acceptance, or downstream consent. |
| `MT_PAUSED` | Participation `PAUSED` | Does not imply punishment or terminality. |
| `MT_PROPOSAL_PRESENTED` | Current proposal `PENDING` without viewer-side current acceptance | Presentation only. |
| `MT_INTEREST_RECORDED` | Current proposal still `PENDING` with viewer-side current acceptance | One-sided evidence remains non-mutual. |
| `MT_MUTUAL_INTEREST` | Current proposal `MUTUALLY_ACCEPTED` | Creates no Connection or Conversation authority. |
| `MT_DECLINED` | Proposal `DECLINED` | Neutral terminal choice, no adverse meaning. |
| `MT_EXPIRED` | Authoritative proposal `EXPIRED` | Cannot be derived from countdown or elapsed local time. |
| `MT_WITHDRAWN` | Participation or proposal `WITHDRAWN`, only with the authority scope explicitly distinguished | Label alone is insufficient and cannot collapse the two domains. |
| `MT_COMPLETED` | Separately authoritative bounded presentation evidence only | Not a new mutation state; cannot reopen or strengthen `MUTUALLY_ACCEPTED`. |

No-candidate, no-round, loading, offline, timeout, unavailable, stale, retryable error, projection lag, service failure, and transport failure are presentation/authority conditions, never Match lifecycle states. Reordered projection delivery cannot roll authority back; a stale or superseded projection cannot authorize a protected action.

## 8. Cross-domain and non-substitution proof

Match authority cannot be created, strengthened, refreshed, corrected, or widened by a route/deep link, candidate card, countdown/client timer, Compatibility factor/label, any total score, local boolean/client enum, cache, stale projection, legacy DTO/state, notification payload/identity, transport acknowledgement/success, Home card/action label, Product Connection state, Conversation state, or Relationship state.

The same rule applies in reverse: another domain's state cannot establish Match participation, proposal issuance, participant decision, mutual acceptance, expiry, correction, currentness, audience, or purpose. Matching factors may appear only when separately authorized with provenance and uncertainty; they are not decisions, eligibility, authority, or a total score.

Neutral decline, withdrawal, pause, expiry, missingness, and authority conditions establish no guilt, Safety finding, punishment, fraud, deception, low worth, objective incompatibility, or Relationship failure. Private Conversation and Safety evidence are not ordinary Match inputs.

## 9. High-density validation matrix

Each row is independently checkable and has exactly one disposition.

| ID | Group | Independently checkable assertion | Disposition |
|---:|---|---|---|
| A01 | Authority/provenance | The authoritative owner of durable participation/proposal outcomes is Match authority, while participant intent retains attributable actor provenance. | `PASS` |
| A02 | Authority/provenance | A participation-context identity cannot substitute for a proposal identity. | `PASS` |
| A03 | Authority/provenance | One proposal identity cannot substitute for another proposal or participation context. | `PASS` |
| A04 | Authority/provenance | Proposal and decision evidence binds exactly two participants and rejects partial, extra, or different sets. | `PASS` |
| A05 | Authority/provenance | Evidence disclosure/use requires its exact authorized audience. | `PASS` |
| A06 | Authority/provenance | Evidence use requires the authored Match participation/proposal purpose. | `PASS` |
| A07 | Authority/provenance | Participant, slot-owner, and Match-authority/system actor roles are explicit and non-interchangeable. | `PASS` |
| A08 | Authority/provenance | Revision ordering is valid only inside one exact Match-owned lineage/scope. | `PASS` |
| A09 | Authority/provenance | Every protected evaluation requires usable freshness; stale/unknown/unavailable/superseded/incomparable evidence fails closed. | `PASS` |
| A10 | Authority/provenance | Permitted actions are descriptive, bound, non-self-authorizing, and revalidated by the writer. | `PASS` |
| B11 | Participation | Fresh `NOT_ENROLLED -> ENROLLED` requires the authenticated participant's explicit opt-in and then-current separate prerequisites. | `PASS` |
| B12 | Participation | `ENROLLED -> PAUSED` is requested only by the same authenticated participant. | `PASS` |
| B13 | Participation | `PAUSED -> ENROLLED` requires the same participant, fresh resume intent, and then-current separate prerequisites. | `PASS` |
| B14 | Participation | `ENROLLED -> WITHDRAWN` is a same-participant terminal transition for that context. | `PASS` |
| B15 | Participation | `PAUSED -> WITHDRAWN` is a same-participant terminal transition for that context. | `PASS` |
| B16 | Participation | Historical participation `WITHDRAWN` has no successor in the same identity. | `PASS` |
| B17 | Participation | Later participation starts with a fresh context identity at `NOT_ENROLLED` and requires fresh enrollment. | `PASS` |
| B18 | Participation | Concrete eligibility/readiness prerequisite contents are not invented or treated as Match-owned facts. | `PASS` |
| C19 | Proposal | Proposal issuance is Match-authority/system only, after both exact participants are current `ENROLLED` and separate prerequisites pass. | `PASS` |
| C20 | Proposal | A fresh proposal has exactly two independent initially undecided participant slots. | `PASS` |
| C21 | Proposal | First valid acceptance records one slot and leaves lifecycle state `PENDING`. | `PASS` |
| C22 | Proposal | Second valid current acceptance establishes `MUTUALLY_ACCEPTED` only through a new Match-authority outcome revision. | `PASS` |
| C23 | Proposal | Either bound participant may decline their own decision on current `PENDING`, producing terminal `DECLINED`. | `PASS` |
| C24 | Proposal | Proposal withdrawal is authored only by Match authority/system under a separately authorized reason or cross-scope cause. | `PASS` |
| C25 | Proposal | `EXPIRED` is representable only as `PENDING -> EXPIRED` under a separately authoritative future expiry policy. | `PASS` |
| C26 | Proposal | Every terminal proposal identity rejects reopen/reset to `PENDING`. | `PASS` |
| C27 | Proposal | A later proposal requires a fresh proposal identity, lineage, empty slots, and fresh participant decisions. | `PASS` |
| C28 | Proposal | Current MVP enforces at most one unresolved proposal per participant. | `PASS` |
| C29 | Proposal | Any future multi-candidate or higher active/unresolved-proposal limit is not established. | `RETAINED_UNKNOWN` |
| D30 | Cross-scope | A participation pause makes every affected current pending proposal ineligible for further acceptance. | `PASS` |
| D31 | Cross-scope | A participation withdrawal makes every affected current pending proposal ineligible for further acceptance. | `PASS` |
| D32 | Cross-scope | Match authority, not the participant, authors the newer terminal proposal `WITHDRAWN` revision for the cross-scope effect. | `PASS` |
| D33 | Cross-scope | Participation action/revision/idempotency identity never becomes proposal-writer or proposal-revision authority. | `PASS` |
| E34 | Mutual acceptance | Both decisions bind the same exact proposal identity. | `PASS` |
| E35 | Mutual acceptance | Both decisions bind the proposal's same exact two participants. | `PASS` |
| E36 | Mutual acceptance | Each current acceptance is authored by the correct participant for their own slot. | `PASS` |
| E37 | Mutual acceptance | Proposal and decision evidence bind compatible controlling revision, scope, and currentness. | `PASS` |
| E38 | Mutual acceptance | Proposal and both decisions satisfy usable freshness, audience, and purpose. | `PASS` |
| E39 | Mutual acceptance | One-sided or historical acceptance is insufficient and remains non-mutual evidence. | `PASS` |
| E40 | Mutual acceptance | `MUTUALLY_ACCEPTED` creates no Connection request/consent, Messaging Consent, Conversation access, or Relationship state. | `PASS` |
| F41 | Idempotency/concurrency | Duplicate enrollment intent correlates to one `ENROLLED` outcome in one participation context. | `PASS` |
| F42 | Idempotency/concurrency | Duplicate pause intent correlates to one `PAUSED` outcome and creates no stacked pause. | `PASS` |
| F43 | Idempotency/concurrency | Duplicate resume intent correlates to one `ENROLLED` outcome after prerequisites are revalidated. | `PASS` |
| F44 | Idempotency/concurrency | Duplicate participation-withdraw intent correlates to one terminal `WITHDRAWN` outcome. | `PASS` |
| F45 | Idempotency/concurrency | Duplicate proposal-issue intent creates one proposal identity and one `PENDING` outcome. | `PASS` |
| F46 | Idempotency/concurrency | Duplicate one-sided accept preserves one decision in that actor's slot and cannot count as both slots. | `PASS` |
| F47 | Idempotency/concurrency | Duplicate delivery of the second acceptance cannot create a second mutual outcome. | `PASS` |
| F48 | Idempotency/concurrency | Accept versus decline resolves against the controlling `PENDING` revision; only one terminal outcome can control. | `PASS` |
| F49 | Idempotency/concurrency | Accept versus proposal-withdraw resolves against current revision; withdrawal before mutual completion rejects stale accept. | `PASS` |
| F50 | Idempotency/concurrency | Accept versus participation pause revalidates participation; controlling pause prevents further acceptance and causes authority-authored proposal withdrawal. | `PASS` |
| F51 | Idempotency/concurrency | Accept versus participation withdrawal revalidates participation; controlling withdrawal prevents acceptance and causes authority-authored proposal withdrawal. | `PASS` |
| F52 | Idempotency/concurrency | Pause versus participation withdrawal resolves sequentially against current revision; terminal withdrawal cannot reopen. | `PASS` |
| F53 | Idempotency/concurrency | Expiry versus accept, once expiry policy exists, resolves against controlling revision; only one terminal outcome controls. | `PASS` |
| F54 | Idempotency/concurrency | Two participant decisions arriving in either order have identical semantics; arrival order grants no authority. | `PASS` |
| F55 | Idempotency/concurrency | Delayed old acceptance after `DECLINED` is stale and rejected. | `PASS` |
| F56 | Idempotency/concurrency | Delayed old acceptance after proposal `WITHDRAWN` is stale and rejected. | `PASS` |
| F57 | Idempotency/concurrency | Delayed old acceptance after `EXPIRED` is stale and rejected. | `PASS` |
| F58 | Idempotency/concurrency | A client acting on an older proposal revision fails closed and cannot mutate current authority. | `PASS` |
| F59 | Idempotency/concurrency | Reordered projection delivery cannot roll back the controlling authoritative revision. | `PASS` |
| F60 | Idempotency/concurrency | Transport timeout after a mutation may have committed; outcome remains unknown pending authoritative reconciliation. | `PASS` |
| F61 | Idempotency/concurrency | Reused idempotency identity with changed semantic input is rejected and is not a retry. | `PASS` |
| F62 | Idempotency/concurrency | Actor mismatch rejects the intent despite valid route, identity, or transport. | `PASS` |
| F63 | Idempotency/concurrency | Participant-set mismatch rejects the intent and cannot establish mutual acceptance. | `PASS` |
| F64 | Idempotency/concurrency | Proposal mismatch rejects a decision even if actor and action names otherwise match. | `PASS` |
| F65 | Idempotency/concurrency | Participation-context mismatch rejects enrollment/pause/resume/withdraw intent. | `PASS` |
| F66 | Idempotency/concurrency | Route/countdown/cache/legacy/notification substitution attempts create no authority or outcome. | `PASS` |
| F67 | Idempotency/concurrency | A new proposal cannot reuse a terminal proposal identity, decision, revision, or idempotency identity. | `PASS` |
| F68 | Idempotency/concurrency | A new participation context cannot reuse the historical withdrawn context identity, enrollment, revision, or idempotency identity. | `PASS` |
| G69 | Projection/non-substitution | `MT_NOT_OPTED_IN` maps only from usable participation `NOT_ENROLLED` evidence. | `PASS` |
| G70 | Projection/non-substitution | `MT_ACTIVE` maps only from usable participation `ENROLLED` absent a more specific current proposal presentation. | `PASS` |
| G71 | Projection/non-substitution | `MT_PAUSED` maps only from usable participation `PAUSED`. | `PASS` |
| G72 | Projection/non-substitution | `MT_PROPOSAL_PRESENTED` maps to current `PENDING` without viewer-side current acceptance. | `PASS` |
| G73 | Projection/non-substitution | `MT_INTEREST_RECORDED` maps to current `PENDING` with viewer-side current acceptance, not mutuality. | `PASS` |
| G74 | Projection/non-substitution | `MT_MUTUAL_INTEREST` maps only from authoritative `MUTUALLY_ACCEPTED`. | `PASS` |
| G75 | Projection/non-substitution | `MT_DECLINED` maps only from authoritative proposal `DECLINED`. | `PASS` |
| G76 | Projection/non-substitution | `MT_EXPIRED` maps only from authoritative proposal `EXPIRED`, never a countdown. | `PASS` |
| G77 | Projection/non-substitution | `MT_WITHDRAWN` must expose whether participation or proposal authority owns the state. | `PASS` |
| G78 | Projection/non-substitution | `MT_COMPLETED` remains bounded presentation evidence and is not an added mutation state. | `PASS` |
| G79 | Projection/non-substitution | Projection state, permitted-action labels, and Home cards are not Match mutation authority. | `PASS` |
| G80 | Projection/non-substitution | No-candidate/loading/offline/timeout/unavailable/stale/lag/service failure are not lifecycle states. | `PASS` |
| G81 | Projection/non-substitution | No authoritative Compatibility total score exists; factor/label evidence cannot substitute for decisions or authority. | `PASS` |
| G82 | Projection/non-substitution | Route, card, timer, local enum/boolean, cache, legacy DTO, notification, transport, Connection, Conversation, and Relationship state cannot substitute for Match authority. | `PASS` |
| H83 | Retained seam | Exact proposal expiry duration is not established. | `RETAINED_UNKNOWN` |
| H84 | Retained seam | Exact clock basis and time authority are not established. | `RETAINED_UNKNOWN` |
| H85 | Retained seam | Expiry extension and renewal rules are not established. | `RETAINED_UNKNOWN` |
| H86 | Retained seam | Cooldown and re-proposal timing are not established. | `RETAINED_UNKNOWN` |
| H87 | Retained seam | Concrete enrollment/proposal eligibility and readiness prerequisite contents are not established here. | `RETAINED_UNKNOWN` |
| H88 | Retained seam | Product-authorized proposal-withdraw reason categories are not established. | `RETAINED_UNKNOWN` |
| H89 | Retained seam | A future participant decision-retraction mutation distinct from decline/participation withdrawal is not established. | `RETAINED_UNKNOWN` |
| H90 | Retained seam | Optional AI/personality/astrology/reference-signal allowlist and provenance policy are not established. | `RETAINED_UNKNOWN` |

Validation totals:

`PASS = 81 / RETAINED_UNKNOWN = 9 / BLOCKED = 0`

## 10. Complete retained-unknown and blocker register

Every `RETAINED_UNKNOWN` is listed here exactly once as a policy/material-fact seam:

1. exact proposal expiry duration;
2. exact clock basis and time authority;
3. expiry extension and renewal rules;
4. cooldown and re-proposal timing;
5. future multi-candidate or higher active/unresolved-proposal limits (current MVP remains at most one unresolved proposal per participant);
6. concrete enrollment/proposal eligibility and readiness prerequisite contents;
7. product-authorized proposal-withdraw reason categories;
8. a future participant decision-retraction mutation distinct from decline or participation withdrawal; and
9. optional AI/personality/astrology/reference-signal allowlist and provenance policy.

Every related concrete timeout, cadence, reminder, queue, operational value, or future policy derived from these seams remains unresolved unless separately accepted. No legacy countdown, implementation convenience, placeholder, or local timer fills a seam.

Blockers: `NONE`.

The retained unknowns do not block this duration-independent semantic design because it represents expiry and prerequisite inputs without asserting their content or triggering conditions. They do block any production behavior that requires selecting those missing facts.

## 11. Design consequences and explicit non-goals

- The two authority scopes remain independently correctable and supersedable; there is no universal Match/global revision.
- Historical evidence may explain history only when audience/purpose permits; it cannot authorize a current protected action or populate fresh decisions.
- A projection can lag an authoritative outcome without reversing it, and authority can be unavailable without creating a negative lifecycle outcome.
- The current one-unresolved-proposal limit is a bounded MVP product rule, not a storage uniqueness mechanism or future supply policy.
- Expiry is a valid terminal vocabulary member, but authoring it remains unavailable until separate expiry policy authority exists.
- Match neutral meanings and domain boundaries survive correction, retry, reordering, and transport failure.

This candidate does not define or implement eligibility prerequisites, cooldowns, clocks, Compatibility total scores, Connection consent, Messaging Consent, Conversation authority/history/retention/access, Relationship state, Safety/legal conclusions, API/schema/storage/service/client mechanisms, deployment, or future work.

## 12. Verification and stop boundary

Independent review must verify the exact state sets, full actor/source/target matrices, mutual-acceptance conjunction, terminal/fresh-identity rules, all 28 idempotency/concurrency cases, privacy-minimal projection, non-substitution proof, the 90-row totals, complete retained/blocker lists, exact one-file scope, and `git diff --check`.

This candidate requires fresh independent ACCEPT/REJECT review. Its author must not accept it, merge it, promote `main`, implement BA-03, or start BA-06/BA-07.

`CANONICAL MATCH AUTHORITY TECHNICAL DESIGN ESTABLISHED — NESTED PARTICIPATION/PROPOSAL AUTHORITY + MUTUAL ACCEPTANCE + REVISION/IDEMPOTENCY CONTRACT EXPLICIT — HIGH-DENSITY VALIDATION COMPLETE — EXPIRY/TIMING POLICY RETAINED UNKNOWN — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
