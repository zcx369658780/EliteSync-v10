# EliteSync v10｜Backend Notification Domain-Event / Payload / Delivery Authority Technical Design｜v0.1

Status: `TECHNICAL-DESIGN CANDIDATE — FOUR-LAYER NOTIFICATION AUTHORITY DEFINED — APP-T09 EXACT-PATH PROVENANCE BLOCKED — INDEPENDENT REVIEW REQUIRED — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit: `69551904c2e67b507283dcc25efdde6312f9de02`

Task blob: `5c4d079ccfbe6019e9217d44bc1b70205ca42e62`

## 1. Result, scope, and blocker disposition

This candidate defines a transport-, provider-, channel-, storage-, and client-neutral semantic notification contract with exactly four authority layers:

1. source-domain event authority;
2. notification eligibility authority;
3. privacy-minimal payload-generation authority; and
4. delivery attempt/result evidence authority.

In-app and external/lock-screen presentation are separate audience/purpose evaluations across payload generation and action revalidation; they are not a fifth lifecycle authority. No later layer may write, strengthen, correct, revoke, or reinterpret an earlier source-domain outcome.

Two task-required exact paths are absent at fixed `origin/main` and therefore remain explicit blockers:

- `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_ACCEPTANCE_V0_1.md`;
- `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_RESULT_V0_1.md`.

No directory enumeration, synonym search, guessed replacement, application-source read, or test read was used to bypass those gaps. The core four-layer contract remains independently designable from the task sheet, accepted BA-01 through BA-05, accepted planning/decomposition, APP-T12-B01, and the fixed closeout invariants. The two gaps prevent only exact APP-T09 acceptance provenance and full APP-T09 presentation-detail verification; they do not authorize invention.

This document selects no endpoint, API, wire format, schema, table, index, storage, queue, worker, service, provider, channel, platform integration, FCM/APNs choice, retry algorithm, push-token model, clock, deployment, Flutter/client behavior, legal rule, production processing, or campaign authority.

## 2. Fixed authority provenance

All resolvable sources below were read from fixed `origin/main` commit `69551904c2e67b507283dcc25efdde6312f9de02`.

| Key | Exact authority | Fixed provenance / bounded use |
|---|---|---|
| S1 | BA-01 Common Authority Evidence Envelope acceptance/design | acceptance blob `565e425aa3550bb64a82c70ff08a107a896669a3`; accepted design blob `c448662bee3f452eb535f298c76388e5565717a4`; binding, revision/freshness, composition, outcome/transport, permitted-action, and idempotency rules. |
| S2 | Backend Authority Decomposition acceptance/design | acceptance blob `9ac039e2d2b20e9eef3a03eeded53f5583fc9a49`; accepted design blob `a8404b3066680f37e9ff94bcfd705ed414cb8d07`; BA-07 stages, privacy, protected-open, and non-goals. |
| S3 | Backend Authority Read-Model Planning acceptance/contract | acceptance blob `72168985edbb801cce46dc0c33dae3babc2705ee`; accepted contract blob `a97f97eafb09b18c604cd5785887a25db08c819d`; B01-F and common writer/projection separation. |
| S4 | BA-02 Runtime Readiness acceptance/design | acceptance blob `0757c322e17436d9d4c007a1ebda3ac3d38fc917`; accepted design blob `372c6b5f3d65bdb9dc19c9af33801484768c7f1a`; subject-bound projection, correction/revocation, and currentness shape. |
| S5 | BA-03 Canonical Match acceptance/design | acceptance blob `ae5b6ecec72bedfb501ec09c5c9a9aa75f5be8c8`; accepted design blob `7de2c0e8aa568ff80d87dca941fa3e55a009c178`; participation/proposal/decision evidence and neutral terminal meanings. |
| S6 | BA-04 Product Connection acceptance/design | acceptance blob `d3b6cf099009d44302925e98f9ab8dfb70a19f2f`; accepted design blob `e93ab283efb6b05aa7fbc1487536c174a7280a8e`; current aggregate/participant/role/CN-state evidence. |
| S7 | BA-05 Messaging Consent + Conversation Live Gate acceptance/design | acceptance blob `a133285b0a1923d5d2965ced989d1c8b1dbf8e49`; accepted design blob `d35909ede0bb8c0f8891581ce69c50d7758d914d`; independent live-read/live-send grant evidence and private-data fail-closed boundary. |
| S8 | APP-T12 MVP Integration Acceptance Rerun result | blob `4c00def5a94a117c8d9812996baf193de4a4aeb1`; proves APP-T12-B01 `status_author` payload/route identity fails closed and cannot load profile-like data. |
| S9 | Current-session closeout/handoff | blob `fb48743f0147fb0d25be697ba02aae63a45d07d8`; product/privacy/Safety/analytics and exact-scope invariants only. |
| B1 | Required APP-T09 acceptance | exact path missing at fixed main; acceptance provenance not established. |
| B2 | Required APP-T09 result | exact path missing at fixed main; full presentation/audience artifact cannot be read. |

APP-T12 records a bounded preservation observation about generic notification presentation, but it does not substitute for the missing APP-T09 acceptance/result objects. This candidate relies on the current task's explicit generic-external requirement and S8's exact `status_author` fail-closed evidence, not on invented APP-T09 contents.

## 3. Four-layer authority model

| Layer | Sole semantic responsibility | Required input/output evidence | Must never do |
|---|---|---|---|
| L1 — Source-domain event authority | The owning Readiness, Match, Product Connection, or Conversation live-access authority establishes the source event/outcome and whether its event class may be considered for notification. | Owner/provenance; event/outcome identity; subject/participants; audience/purpose constraints; source lineage/revision/currentness/freshness; neutral meaning; consideration-eligibility marker where separately authorized. | Create notification eligibility, payload, delivery success, consent, another domain's outcome, or a notification event-class allowlist not already accepted. |
| L2 — Notification eligibility authority | Decide whether one current source event may produce a notification for one exact audience/purpose, using only separately accepted controls/preferences. | Exact L1 reference and bindings; independently current source evidence; target audience class; accepted control evidence if any; one logical notification intent; eligible/ineligible/unknown decision with reason class. | Rewrite L1; infer a preference; create audience/access authority; batch/rank/campaign without accepted policy; treat event consideration as final eligibility. |
| L3 — Payload-generation authority | Generate only the minimum material already authorized by L2 for exactly one audience/purpose. | Opaque notification identity; generic presentation category/copy; privacy-minimal source reference for revalidation; audience/purpose binding; source revision reference; authorized in-app action discriminator where established. | Put private content/identity into external copy; turn payload fields into permission, consent, actor role, current source state, or mutation success. |
| L4 — Delivery evidence authority | Record logical-intent correlation, transport attempt, acknowledgement/result/open/dismiss evidence only where knowable. | Notification logical intent; attempt identity/correlation; accepted-for-transport/provider/OS/display/open/dismiss/timeout/unknown observations with provenance and ordering relation where established. | Change L1/L2/L3 truth; infer user saw/understood/consented; infer domain success/failure; invent provider/OS receipt semantics. |

These identities remain binding:

- `DOMAIN EVENT != DOMAIN EVENT CONSIDERATION ELIGIBILITY != NOTIFICATION ELIGIBILITY`;
- `NOTIFICATION ELIGIBILITY != PAYLOAD`;
- `PAYLOAD != AUDIENCE OR ACCESS AUTHORITY`;
- `DELIVERY SUCCESS != DOMAIN SUCCESS`;
- `OPEN OR DISMISS != DOMAIN OUTCOME`;
- `ROUTE OR DEEP-LINK IDENTITY != PERMISSION`;
- `TRANSPORT FAILURE != DOMAIN FAILURE`.

No notification layer is a source-domain writer. Evidence from separate owners retains separate lineages; there is no global revision or last-arrival authority.

## 4. Common evidence obligations

Every layer must distinguish source outcome, domain consideration eligibility, notification eligibility decision, payload material, delivery observation, and projection/lag observation as separate claim classes.

| Obligation | L1 source event | L2 eligibility | L3 payload | L4 delivery evidence |
|---|---|---|---|---|
| Owner/provenance | Exact source-domain authority | Notification eligibility authority | Payload-generation authority | Delivery observation authority/provenance |
| Identity/scope | Exact event/outcome and source lineage | Exact event reference, audience, purpose, logical notification intent | Opaque notification identity plus bounded source reference | Exact logical intent and attempt/result observation |
| Subject/participants | Exact source subject or participant set | Exact intended audience subject/participants | Only privacy-minimal audience-bound reference | No new subject/participant authority from addressability |
| Revision/currentness | Source-owned controlling revision | Revalidate L1 currentness; own eligibility decision revision if applicable | Reference evaluated source/eligibility scope without becoming currentness authority | Observation order only where knowable; cannot order source revisions |
| Freshness | Source-owned usable-freshness for notification consideration | Independently valid for exact audience/purpose | Must not outlive the evaluated authority for protected use | Does not refresh L1/L2/L3 |
| Correction/revocation | Newer source evidence in same lineage/scope | Recompute/deny affected eligibility | Suppress future use of affected payload | Record transport facts only; cannot override correction/revocation |
| Idempotency | Source event identity is not notification intent | Same semantic notification intent correlates duplicates | Repeated generation for same authorized intent creates no new authority | Multiple attempts/callbacks correlate to the same logical intent |
| Fail closed | Unknown/stale/unavailable/mismatch is not a negative outcome | No eligibility when required evidence/control is invalid | No protected payload/detail | Delivery remains unknown/failed only as transport fact |

Current, stale, superseded, unavailable, unknown, incomparable, and projection lag remain distinct. Only the owning authority establishes same-lineage supersession. Receipt time, payload generation time, delivery time, UI order, cache order, and provider callback order cannot establish source currentness.

## 5. Independent source-domain evidence contracts

Concrete notification-eligible event-class allowlists are not established for any of the four domains. Until separately accepted, source evidence may satisfy the shape below but cannot by shape alone become a real notification event.

| Domain | Owning authority and minimum consumable evidence | Neutral meaning and eligible evaluation boundary | Must never infer |
|---|---|---|---|
| Runtime Readiness | Readiness authority; authenticated subject; exact protected-use scope; event/outcome identity; separate fact class or effective-readiness conclusion; owner/provenance; lineage/revision/currentness/freshness; correction/revocation effects; Home/notification audience-purpose admissibility. | Eligibility may consume only a separately authorized notification-consideration event class and minimum actor-relevant explanation; unknown/stale/superseded evidence fails closed. | Launch eligibility, global identity truth, failed verification, adverse person meaning, Match/Connection/Conversation/Safety fact, or event class from a ready-looking label. |
| Canonical Match | Match authority; viewer and exact participants; participation/proposal identity; own-role decision or terminal outcome; source lineage/revision/currentness/freshness; audience/purpose; neutral meaning. | One-sided acceptance remains evidence inside `PENDING`; mutual acceptance/decline/withdraw/expiry are source outcomes only. Eligibility requires separately authorized event-class consideration. | Connection consent, Messaging Consent, Conversation access, Relationship, guilt, Safety, compatibility truth, total score, or expiry from countdown/unknown policy. |
| Product Connection | Product Connection authority; exact current aggregate; exact participants/roles; current CN outcome; lineage/revision/currentness/freshness; audience/purpose; terminal/new-identity distinction. | Eligibility evaluates the current aggregate only and only a separately authorized event class. `CN_PENDING`, `CN_ACTIVE`, pause/terminal outcomes retain exact source meanings. | Messaging consent, Conversation read/send, Relationship, current consent from historical `CN_ACTIVE`, guilt, Safety, or expiry from missing policy. |
| Conversation live access | BA-05 live-gate projection retaining independently current `CN_ACTIVE` and `MC_ACTIVE` inputs for same participants/purpose/current Connection context; separate live-read and live-send decisions; independent revisions/freshness. | Notification evaluation may consume only the coarse grant/condition and separately authorized event class. Read and send remain distinct and are re-evaluated independently. | Message existence/content, preview, draft, unread private detail, Relationship, history authority, consent from one input, or access from historical/mismatched evidence. |

One domain's valid evidence cannot repair another domain's stale, unknown, unavailable, superseded, or mismatched evidence. Notification eligibility never synthesizes Readiness, Match acceptance, Product Connection consent, Messaging Consent, Conversation access, Relationship, Safety, guilt, or Compatibility truth.

## 6. Notification eligibility contract

L2 is a current decision over one already-authorized L1 event and one exact audience/purpose. A source domain's “eligible to be considered” marker is necessary but not sufficient. L2 must establish:

1. accepted source owner/provenance and exact event class;
2. event/outcome identity, source lineage, controlling revision/currentness, and usable freshness;
3. exact subject/participants and actor role where relevant;
4. exact in-app or external/lock-screen audience and notification purpose;
5. source permission to disclose the minimum event category to that audience;
6. accepted notification preference/control evidence if such policy exists; and
7. logical notification intent identity bound to event, audience, purpose, and semantic content category.

| Condition | Eligibility decision | Required interpretation |
|---|---|---|
| Current event, separately authorized event class, all bindings valid | May be eligible for the exact audience/purpose, subject to any separately accepted controls. | Domain event still differs from notification decision. |
| Stale event | Deny/unknown as source contract requires. | Do not infer a newer or negative domain outcome. |
| Superseded/historical event | Deny new notification based on old event. | Newer source evidence controls its scope. |
| Unknown currentness or incomparable revision | Fail closed. | Last received is not current. |
| Source unavailable | Fail closed for new eligibility. | Transport/source unavailability is not domain failure. |
| Subject/participant mismatch | Deny and withhold protected detail. | Identifier similarity is not binding. |
| Audience mismatch | Deny that audience. | In-app and external are independent. |
| Purpose mismatch | Deny reuse. | No advertising, analytics, ranking, or training expansion. |
| Correction/revocation after eligibility | Existing eligibility becomes unusable; recompute against newer source evidence. | Cached eligibility cannot override owner evidence. |
| Duplicate same logical notification intent | Correlate to one notification intent/outcome. | Do not multiply business meaning from retries. |
| Changed semantic input with reused identity | Reject as ambiguous misuse/new intent. | Idempotency is not authorization. |
| External denied, in-app valid | Only in-app may remain eligible. | No external payload/detail. |
| In-app denied, external valid | Only generic external may remain eligible if independently authorized. | External eligibility creates no in-app disclosure. |
| Preference/control model not accepted | Do not infer opt-in/out, mute, channel, quiet hours, or frequency permission. | Retain seam and fail closed wherever the missing control is required. |

Eligibility has no campaign, engagement, desirability, urgency, priority, batching, digest, channel-precedence, or frequency-ranking authority.

## 7. Separate audience contracts

| Concern | Authenticated in-app audience | External/lock-screen audience |
|---|---|---|
| Audience establishment | Current authenticated viewer plus source-authorized disclosure for exact purpose. | Separately authorized external audience/control evidence; payload/device addressability never proves who sees the device. |
| Default detail | Minimum source-authorized in-app category and action discriminator only. | Generic/privacy-minimal category and generic instruction by default; no sensitive identity/state/content. |
| Source detail | Only after fresh source audience/purpose revalidation. | Never promoted merely because in-app detail is allowed. |
| Navigation/action | Deep link locates revalidation only; destination rechecks current authority. | Open first establishes current account/viewer, then performs the same revalidation. |
| Failure | Withhold detail/action and show only privacy-safe authority condition. | Preserve generic copy or suppress under separately accepted policy; never disclose fallback detail. |

External eligibility never creates in-app detailed disclosure. In-app authorization never creates external lock-screen detail. A shared notification identity, route, payload, account hint, participant ID, peer ID, or device address cannot bridge the audiences.

APP-T12-B01 remains binding: legacy `status_author`-style payload identity and direct-route identity cannot initiate profile-like loading, reveal existence, mark read through a protected open, or grant audience. Exact APP-T09 final copy and its acceptance provenance remain blocked by B1/B2; this contract defines only the generic semantic default.

## 8. Privacy-minimal payload-generation contract

An eligible notification may generate one audience-bound minimal payload containing or making evaluable only:

- an opaque notification identity that conveys no consent or subject truth;
- a generic presentation category and audience-appropriate generic copy;
- a source-domain/event reference sufficient only to locate fresh revalidation, without protected content;
- an authorized in-app action discriminator only where separately established;
- the exact audience/purpose binding used for generation;
- the evaluated source event lineage/revision/currentness reference; and
- provenance sufficient to distinguish generated payload evidence from source-domain evidence.

The contract selects no wire field names or encoding. It forbids:

- private Conversation content, message previews, attachments, drafts, realtime content, or private unread details;
- sensitive peer identity, payload profile/name/user identity, candidate identity, or globally public Profile enrichment;
- hidden Safety evidence, report/allegation/finding/moderation detail, restriction reason, reputation, or person-worth signal;
- Compatibility total scores, hidden rankings, raw Match inputs, inferred desirability, or Relationship meaning;
- analytics, telemetry, engagement, advertising, model-training, prediction, or unaccepted AI/personality/astrology/reference signals; and
- any field interpreted as consent, permission, actor role, audience proof, current source state, freshness proof, mutation success, or delivery success.

A generated payload becomes stale for future protected use when its referenced source evidence, eligibility, audience, or purpose is corrected, revoked, or superseded. It cannot repair itself from local/cache/legacy information.

## 9. Delivery attempt/result evidence

One logical notification intent may have zero, one, or multiple transport attempts. Attempt and result evidence remains L4 observation only.

| Observation | What may be recorded where knowable | Must not infer |
|---|---|---|
| Intent accepted for transport | L4 accepted the exact payload/intent for an attempt. | Provider receipt, OS delivery/display, user sight, source success. |
| Provider acknowledgement | Provider-specific transport acknowledgement as an observation. | Device receipt, display, audience, consent, domain outcome. |
| OS/device result | Delivery/display result only to the exact semantics separately established. | User saw/read/understood/acted. |
| Open | Open/navigation observation. | Access, consent, acceptance, mark-read, domain completion. |
| Dismissal | Dismiss observation. | Rejection, opt-out, negative interest, domain failure. |
| Timeout/unknown | Exact absence of a knowable transport result. | Failure, success, retry permission, domain state. |
| Provider/channel failure | Transport failure evidence. | Domain event failure or source rollback. |
| Duplicate/reordered callback | Correlate to same intent/attempt and preserve established ordering only where authoritative. | Second outcome, last-callback-wins source truth. |

Idempotency identity binds logical notification intent, source event, audience, purpose, semantic payload category, and intended disclosure. Multiple attempts may correlate to the same intent; reuse with changed event, audience, purpose, or content is not a retry. Idempotency does not authenticate, authorize, order source revisions, prove delivery, or permit another attempt.

No retry limit/backoff, provider/channel, delivery guarantee, OS receipt semantics, or attempt persistence mechanism is selected.

## 10. Notification-originated action/deep-link revalidation

Notification identity and deep link locate a revalidation path only. Before protected detail fetch, navigation, mark-read coupled to protected open, or domain action, the system must independently establish at action time:

1. current authenticated viewer/account;
2. exact subject/participants and actor role;
3. source owner/provenance, event/aggregate/proposal/consent context;
4. controlling source revision/currentness and usable freshness;
5. current audience and purpose authority for the destination/action;
6. current source-domain permitted action, descriptive only; and
7. every domain-specific conjunct, including separate Conversation live-read/live-send grants.

| Changed condition at open/action time | Required result |
|---|---|
| Viewer/account mismatch | Deny protected fetch/action without confirming private resource existence. |
| Participant mismatch | Deny; payload identity cannot repair the set. |
| Source stale/superseded/corrected/revoked | Deny old action and evaluate only newer evidence if independently authorized. |
| Match proposal terminal/replaced | Deny old proposal action; notification cannot reopen/reuse it. |
| Readiness no longer current | Deny stale Readiness-dependent action; do not infer adverse status. |
| Product Connection no longer current `CN_ACTIVE` | Deny Conversation-dependent access/action. |
| Messaging Consent no longer current `MC_ACTIVE` | Deny Conversation-dependent access/action. |
| Conversation live-read lost | Do not construct/fetch protected Conversation content. |
| Conversation live-send lost | Deny send even if read remains separately valid. |
| Audience/purpose mismatch | Withhold detail/action for that use. |
| Old/reused notification identity | Revalidate current source; identity restores nothing. |
| Already terminal domain state | Deny invalid mutation; show only separately authorized current explanation. |

Open/dismiss observations never become source actions. Transport or navigation success never proves the destination mutation succeeded.

## 11. Correction, revocation, and supersession propagation

| Stage when newer source evidence arrives | Required propagation | Capability not claimed |
|---|---|---|
| Pending eligibility evaluation | Discard/recompute against the new controlling source revision. | No cross-domain correction. |
| Eligible, payload not generated | Invalidate eligibility and do not generate from old evidence. | No local rewrite of source fact. |
| Payload generated but not sent | Suppress future send/use of the stale payload. | No guarantee about unspecified queues/storage. |
| Transport in flight | Deny any later protected use; record subsequent transport facts separately. | No assumed provider cancellation or remote recall. |
| Delivered/displayed externally | Revalidate on open/action; never repeat/reuse old authority. | No claim that already rendered copy can be removed. |
| App-open/deep-link action | Deny unless all current source/audience/action gates pass. | No notification-identity permission. |
| Cached in-app presentation | Remove/replace action/detail based on newer source evidence; older cache cannot override. | No deletion/erasure/history conclusion. |
| Delayed provider success after revocation | Record delivery observation only; revocation still controls future protected use. | No domain success or grant restoration. |

“Future protected use denied” is distinct from “already rendered external copy recalled.” Remote recall/retraction capability remains unknown and is not promised.

## 12. Home and notification separation

Calm Home is not a source-domain event authority, notification eligibility authority, payload generator, or delivery evidence owner. Its primary-action selection is not notification priority, urgency, event eligibility, campaign ranking, or delivery instruction.

Conversely, notification eligibility, payload order, delivery result, open, or dismissal cannot change Home's source-domain evidence, select Home's primary action, or supply a lifecycle fact. Home and notification may independently consume the same source evidence only under their own audience/purpose and freshness rules; neither presentation order is authority for the other.

## 13. High-density validation matrix

Each of the following 142 rows is independently checkable and has exactly one disposition.

| ID | Family | Independently checkable assertion | Disposition |
|---:|---|---|---|
| A001 | Authority separation | Readiness/Match/Connection/Conversation source owner remains distinct from notification authority. | `PASS` |
| A002 | Authority separation | Domain event consideration eligibility remains distinct from final notification eligibility. | `PASS` |
| A003 | Authority separation | Notification eligibility remains distinct from payload generation. | `PASS` |
| A004 | Authority separation | Payload generation remains distinct from delivery evidence. | `PASS` |
| A005 | Authority separation | Delivery evidence cannot write or reinterpret a source-domain outcome. | `PASS` |
| A006 | Authority separation | Route/deep-link identity is non-authoritative and only locates revalidation. | `PASS` |
| A007 | Authority separation | Payload identity is not audience, access, consent, or currentness authority. | `PASS` |
| A008 | Authority separation | Notification identity is opaque and non-authoritative. | `PASS` |
| A009 | Authority separation | Open and dismissal are observations, not domain outcomes. | `PASS` |
| A010 | Authority separation | Provider/OS/transport success or failure is not domain success or failure. | `PASS` |
| B011 | Readiness source | Current Readiness evidence requires owner/provenance, subject, scope, revision/currentness, freshness, audience, and purpose. | `PASS` |
| B012 | Readiness source | A stale Readiness event cannot establish notification eligibility. | `PASS` |
| B013 | Readiness source | A superseded Readiness event cannot establish notification eligibility. | `PASS` |
| B014 | Readiness source | Unknown Readiness currentness fails closed without becoming “not ready.” | `PASS` |
| B015 | Readiness source | Unavailable Readiness authority is not failed eligibility or domain failure. | `PASS` |
| B016 | Readiness source | Newer corrected Readiness evidence invalidates dependent old eligibility/payload use. | `PASS` |
| B017 | Readiness source | Newer revoked verification/readiness evidence cannot be overridden by cached notification material. | `PASS` |
| B018 | Readiness source | Readiness subject mismatch withholds notification/detail/action. | `PASS` |
| B019 | Readiness source | Readiness audience mismatch denies that notification audience. | `PASS` |
| B020 | Readiness source | Readiness purpose mismatch forbids convenience/analytics/ranking reuse. | `PASS` |
| C021 | Match source | Current participation evidence retains exact participant context and Match lineage/currentness/freshness. | `PASS` |
| C022 | Match source | Current proposal evidence retains exact proposal, participants, viewer role, revision, audience, and purpose. | `PASS` |
| C023 | Match source | One-sided acceptance remains decision evidence inside `PENDING`, never mutual acceptance. | `PASS` |
| C024 | Match source | `MUTUALLY_ACCEPTED` is consumed only as an authoritative terminal Match outcome. | `PASS` |
| C025 | Match source | `DECLINED` retains neutral terminal meaning and no adverse person inference. | `PASS` |
| C026 | Match source | Participation/proposal `WITHDRAWN` retains exact authority scope and neutral meaning. | `PASS` |
| C027 | Match source | `EXPIRED` is consumed only from authoritative Match evidence under separately accepted policy. | `PASS` |
| C028 | Match source | A terminal proposal cannot be reopened by a notification or old action discriminator. | `PASS` |
| C029 | Match source | A later proposal requires fresh identity/decisions and cannot reuse an old notification. | `PASS` |
| C030 | Match source | Stale proposal/decision evidence cannot establish notification eligibility or action. | `PASS` |
| C031 | Match source | Superseded participant decision cannot establish current proposal meaning. | `PASS` |
| C032 | Match source | Participant mismatch withholds Match notification/detail/action. | `PASS` |
| C033 | Match source | Match audience/purpose mismatch fails closed. | `PASS` |
| C034 | Match source | Newer corrected/superseding Match evidence invalidates old eligibility/payload/action. | `PASS` |
| C035 | Match source | Exact Match expiry duration/clock/extension policy remains unestablished. | `RETAINED_UNKNOWN` |
| D036 | Connection source | `CN_PENDING` is only a current source state and not consent/Conversation authority. | `PASS` |
| D037 | Connection source | Current `CN_ACTIVE` retains exact aggregate, participants, roles, revision, audience, and purpose. | `PASS` |
| D038 | Connection source | `CN_PAUSED` cannot be notified as active consent or Conversation access. | `PASS` |
| D039 | Connection source | `CN_CLOSED` remains terminal for its old aggregate and neutral in meaning. | `PASS` |
| D040 | Connection source | `CN_DECLINED` remains terminal/neutral and cannot imply guilt or incompatibility. | `PASS` |
| D041 | Connection source | `CN_WITHDRAWN` remains terminal/neutral and cannot imply guilt or incompatibility. | `PASS` |
| D042 | Connection source | `CN_EXPIRED` requires authoritative policy/evidence and is not inferred from timeout. | `PASS` |
| D043 | Connection source | Evidence from the wrong/historical aggregate is rejected. | `PASS` |
| D044 | Connection source | Historical/superseded `CN_ACTIVE` cannot establish current eligibility or access. | `PASS` |
| D045 | Connection source | Unknown Connection currentness fails closed without becoming `CN_NONE`. | `PASS` |
| D046 | Connection source | Stale Connection evidence cannot guide notification action. | `PASS` |
| D047 | Connection source | Unavailable Connection authority is not domain failure. | `PASS` |
| D048 | Connection source | Participant mismatch withholds Connection notification/detail/action. | `PASS` |
| D049 | Connection source | Newer correction/non-active/terminal revision invalidates prior eligibility/payload/action. | `PASS` |
| D050 | Connection source | Exact Product Connection expiry policy remains unestablished. | `RETAINED_UNKNOWN` |
| E051 | Conversation source | Current live-read and live-send grants are separate evidence dimensions. | `PASS` |
| E052 | Conversation source | A separately valid read-only result, if established, cannot imply send. | `PASS` |
| E053 | Conversation source | `MC_PENDING` cannot establish consent or live access. | `PASS` |
| E054 | Conversation source | `MC_ACTIVE` alone cannot repair invalid/non-active Connection evidence. | `PASS` |
| E055 | Conversation source | `MC_REVOKED` supersedes old `MC_ACTIVE` for its exact live scope. | `PASS` |
| E056 | Conversation source | Loss of current `CN_ACTIVE` invalidates the current MVP live grants. | `PASS` |
| E057 | Conversation source | Consent bound to a wrong/historical Connection aggregate is rejected. | `PASS` |
| E058 | Conversation source | Historical consent does not transfer to a new Connection aggregate. | `PASS` |
| E059 | Conversation source | Stale live-gate input fails both dependent grant evaluations. | `PASS` |
| E060 | Conversation source | Unknown live-gate input fails closed without negative domain inference. | `PASS` |
| E061 | Conversation source | Unavailable live-gate input fails closed without domain failure inference. | `PASS` |
| E062 | Conversation source | Audience/purpose/participant mismatch in either input denies the evaluated grant. | `PASS` |
| E063 | Conversation source | Correction/revocation of either gate input invalidates dependent eligibility/payload/action. | `PASS` |
| E064 | Conversation source | Private content construction remains forbidden before current live-read authority. | `PASS` |
| E065 | Conversation source | Notification design creates no historical Conversation authority. | `PASS` |
| F066 | Payload/privacy | External/lock-screen copy is generic/privacy-minimal by default. | `PASS` |
| F067 | Payload/privacy | In-app detail requires independent current authenticated audience authority. | `PASS` |
| F068 | Payload/privacy | Private message preview/content/attachment is excluded. | `PASS` |
| F069 | Payload/privacy | Conversation drafts/realtime content are excluded. | `PASS` |
| F070 | Payload/privacy | Unread private details/count-derived content are excluded. | `PASS` |
| F071 | Payload/privacy | Sensitive peer/profile/candidate identity is minimized and not external detail. | `PASS` |
| F072 | Payload/privacy | Hidden Safety/moderation/report/finding evidence is excluded. | `PASS` |
| F073 | Payload/privacy | Compatibility total scores and hidden ranking are excluded. | `PASS` |
| F074 | Payload/privacy | Analytics/training/engagement/prediction signals are excluded. | `PASS` |
| F075 | Payload/privacy | Opaque notification identity conveys no permission or subject truth. | `PASS` |
| F076 | Payload/privacy | Source reference is sufficient only to locate revalidation, not protected content. | `PASS` |
| F077 | Payload/privacy | In-app action discriminator appears only when separately authorized. | `PASS` |
| F078 | Payload/privacy | Payload binds one exact in-app or external audience. | `PASS` |
| F079 | Payload/privacy | Payload binds one exact notification purpose and cannot broaden it. | `PASS` |
| F080 | Payload/privacy | Payload references evaluated source revision/currentness without becoming authority. | `PASS` |
| F081 | Payload/privacy | Stale payload cannot authorize protected presentation/action. | `PASS` |
| F082 | Payload/privacy | Superseded source evidence invalidates future use of generated payload. | `PASS` |
| F083 | Payload/privacy | Wrong viewer/account prevents in-app protected disclosure. | `PASS` |
| F084 | Payload/privacy | In-app authorization and external authorization do not substitute for each other. | `PASS` |
| F085 | Payload/privacy | `status_author` payload/route identity cannot initiate profile-like loading or mark-read protected open. | `PASS` |
| G086 | Delivery/concurrency | Duplicate logical notification intent correlates to one semantic intent. | `PASS` |
| G087 | Delivery/concurrency | Duplicate transport attempts do not create duplicate domain or eligibility outcomes. | `PASS` |
| G088 | Delivery/concurrency | Reordered provider callbacks cannot establish source revision order. | `PASS` |
| G089 | Delivery/concurrency | Timeout after possible delivery remains unknown, not failure or retry authority. | `PASS` |
| G090 | Delivery/concurrency | Provider acknowledgement followed by source revocation restores no authority. | `PASS` |
| G091 | Delivery/concurrency | Source revocation followed by delayed provider success remains delivery-only evidence. | `PASS` |
| G092 | Delivery/concurrency | Open before receipt of updated source still triggers current action-time revalidation. | `PASS` |
| G093 | Delivery/concurrency | Dismissal after supersession creates no domain rejection/opt-out. | `PASS` |
| G094 | Delivery/concurrency | Duplicate open observations create no second action or outcome. | `PASS` |
| G095 | Delivery/concurrency | Replay of an old notification identity restores no payload/action authority. | `PASS` |
| G096 | Delivery/concurrency | Changed semantic input under reused idempotency identity is not a retry. | `PASS` |
| G097 | Delivery/concurrency | Accepted-for-transport with unknown OS result remains transport evidence only. | `PASS` |
| G098 | Delivery/concurrency | OS display evidence cannot prove the user saw or understood content. | `PASS` |
| G099 | Delivery/concurrency | Open cannot prove consent, acceptance, completion, or domain success. | `PASS` |
| G100 | Delivery/concurrency | Provider/channel failure cannot prove source-domain failure. | `PASS` |
| G101 | Delivery/concurrency | Older notification after newer source event cannot roll source authority backward. | `PASS` |
| G102 | Delivery/concurrency | Multiple channel behavior is not inferred without accepted channel policy. | `PASS` |
| G103 | Delivery/concurrency | Unknown provider/OS semantics remain unknown and cannot be strengthened. | `PASS` |
| G104 | Delivery/concurrency | Corrected delivery result changes only L4 observation, not L1/L2/L3 truth. | `PASS` |
| G105 | Delivery/concurrency | Incomparable callbacks do not resolve by last-arrival-wins. | `PASS` |
| H106 | Revalidation | Viewer identity mismatch denies protected open/action. | `PASS` |
| H107 | Revalidation | Account switch requires fresh audience/source revalidation. | `PASS` |
| H108 | Revalidation | Participant mismatch denies protected detail/action. | `PASS` |
| H109 | Revalidation | Stale route/deep link conveys no current permission. | `PASS` |
| H110 | Revalidation | Expired Match proposal denies old notification action. | `PASS` |
| H111 | Revalidation | Any terminal/replaced Match proposal denies reopen/reuse. | `PASS` |
| H112 | Revalidation | Lost current `CN_ACTIVE` denies dependent Conversation action. | `PASS` |
| H113 | Revalidation | Revoked Messaging Consent denies dependent Conversation action. | `PASS` |
| H114 | Revalidation | Lost live-read prevents protected Conversation fetch/construction. | `PASS` |
| H115 | Revalidation | Lost live-send prevents send despite old notification/payload. | `PASS` |
| H116 | Revalidation | Changed/non-current Readiness denies stale Readiness-dependent action. | `PASS` |
| H117 | Revalidation | Source correction replaces old action meaning only within corrected scope. | `PASS` |
| H118 | Revalidation | Source supersession prevents cached payload/action rollback. | `PASS` |
| H119 | Revalidation | Audience mismatch denies protected presentation/action. | `PASS` |
| H120 | Revalidation | Purpose mismatch denies action and onward use. | `PASS` |
| I121 | Retained seam | Exact notification-eligible Runtime Readiness event-class allowlist remains unestablished. | `RETAINED_UNKNOWN` |
| I122 | Retained seam | Exact notification-eligible canonical Match event-class allowlist remains unestablished. | `RETAINED_UNKNOWN` |
| I123 | Retained seam | Exact notification-eligible Product Connection event-class allowlist remains unestablished. | `RETAINED_UNKNOWN` |
| I124 | Retained seam | Exact notification-eligible Conversation live-access event-class allowlist remains unestablished. | `RETAINED_UNKNOWN` |
| I125 | Retained seam | Notification preference/control model remains unestablished. | `RETAINED_UNKNOWN` |
| I126 | Retained seam | Mute and quiet-hours policy remains unestablished. | `RETAINED_UNKNOWN` |
| I127 | Retained seam | Frequency caps remain unestablished. | `RETAINED_UNKNOWN` |
| I128 | Retained seam | Batching/digest policy remains unestablished. | `RETAINED_UNKNOWN` |
| I129 | Retained seam | Retry limits/backoff remain unestablished. | `RETAINED_UNKNOWN` |
| I130 | Retained seam | Provider/channel selection and precedence remain unestablished. | `RETAINED_UNKNOWN` |
| I131 | Retained seam | Push-token/device-binding model remains unestablished. | `RETAINED_UNKNOWN` |
| I132 | Retained seam | External copy localization and final wording remain unvalidated/unestablished. | `RETAINED_UNKNOWN` |
| I133 | Retained seam | Notification accessibility validation remains unestablished. | `RETAINED_UNKNOWN` |
| I134 | Retained seam | Legal/region-specific marketing-versus-transactional classification remains unestablished. | `RETAINED_UNKNOWN` |
| I135 | Retained seam | Minor/age-specific notification posture remains unestablished. | `RETAINED_UNKNOWN` |
| I136 | Retained seam | Delivery/open/dismiss telemetry retention remains unestablished. | `RETAINED_UNKNOWN` |
| I137 | Retained seam | Analytics/measurement authority remains unestablished. | `RETAINED_UNKNOWN` |
| I138 | Retained seam | Remote recall/retraction capability remains unestablished. | `RETAINED_UNKNOWN` |
| I139 | Retained seam | Exact OS/provider receipt semantics remain unestablished. | `RETAINED_UNKNOWN` |
| I140 | Retained seam | Historical Conversation read/access authority remains unestablished. | `RETAINED_UNKNOWN` |
| J141 | Source blocker | Required exact APP-T09 acceptance path is absent at fixed `origin/main`; acceptance provenance cannot be established. | `BLOCKED` |
| J142 | Source blocker | Required exact APP-T09 result path is absent at fixed `origin/main`; full presentation/audience detail cannot be verified. | `BLOCKED` |

Validation totals:

`PASS = 118 / RETAINED_UNKNOWN = 22 / BLOCKED = 2`

## 14. Complete retained-unknown and blocker register

Every retained unknown is listed exactly once:

1. exact notification-eligible Runtime Readiness event-class allowlist;
2. exact notification-eligible canonical Match event-class allowlist;
3. exact notification-eligible Product Connection event-class allowlist;
4. exact notification-eligible Conversation live-access event-class allowlist;
5. exact Match expiry duration/clock/extension policy;
6. exact Product Connection expiry policy;
7. notification preference/control model;
8. mute and quiet-hours policy;
9. frequency caps;
10. batching/digest policy;
11. retry limits/backoff;
12. provider/channel selection and precedence;
13. push-token/device-binding model;
14. external copy localization and final wording;
15. accessibility validation;
16. legal/region-specific marketing-versus-transactional classification;
17. minor/age-specific notification posture;
18. retention of delivery/open/dismiss telemetry;
19. analytics/measurement authority;
20. remote recall/retraction capability;
21. exact OS/provider receipt semantics; and
22. historical Conversation read/access authority.

Every blocker is listed exactly once:

1. `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_ACCEPTANCE_V0_1.md` is absent at fixed `origin/main`; exact APP-T09 acceptance provenance cannot be established.
2. `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_RESULT_V0_1.md` is absent at fixed `origin/main`; full APP-T09 notification presentation/audience details cannot be verified.

The blockers do not prevent the independently sourced core four-layer semantic design, generic-external default explicitly required by this task, or APP-T12-B01 fail-closed preservation. They do prevent claiming that the missing APP-T09 artifact itself was read, accepted, or fully reconciled.

## 15. Explicit non-goals and rejected substitutions

No notification preference, quiet hours, frequency cap, batching/digest, retry policy, provider/channel, push-token model, legal/region policy, telemetry retention, analytics/measurement, remote recall, OS receipt meaning, exact wording, event-class allowlist, or source expiry policy is invented.

Private Conversation content/previews/drafts/unread details, sensitive peer identity, hidden Safety evidence, Compatibility total scores, analytics/training signals, inferred desirability/person worth, public Profile enrichment, and unaccepted AI signals are excluded from payload generation and eligibility.

Route, deep link, payload, notification ID, cache, local state, legacy DTO, provider acknowledgement, delivery/display/open/dismiss evidence, transport success, and transport failure cannot create audience, permission, consent, actor role, currentness, source outcome, or mutation success.

## 16. Independent-review and stop boundary

Independent review must verify: all four layers and ownership; source-specific evidence matrices; audience separation; generic external default; payload allowlist/exclusions; delivery/idempotency/concurrency; every action-time revalidation case; correction/revocation propagation without remote-recall claim; Home separation; all 142 independently checkable rows and exact totals; all 22 retained unknowns; both exact blockers; exact one-file scope; and `git diff --check`.

This candidate requires fresh independent ACCEPT/REJECT review. Its author must not accept it, merge it, promote `main`, implement BA-07, start backend/client/deployment/legal/analytics work, or create a successor task.

`NOTIFICATION DOMAIN-EVENT / PAYLOAD / DELIVERY AUTHORITY TECHNICAL DESIGN ESTABLISHED — HIGH-DENSITY VALIDATION COMPLETE — PRIVACY / AUDIENCE / TRANSPORT SEPARATION EXPLICIT — APP-T09 EXACT-PATH PROVENANCE BLOCKED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
