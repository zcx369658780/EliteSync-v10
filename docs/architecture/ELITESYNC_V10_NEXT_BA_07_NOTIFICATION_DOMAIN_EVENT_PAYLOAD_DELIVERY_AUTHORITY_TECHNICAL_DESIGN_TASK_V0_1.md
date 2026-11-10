# EliteSync v10｜NEXT BA-07 Notification Domain-Event / Payload-Generation / Delivery Authority Technical Design Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — HIGH-DENSITY TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `26865749f74d2aaa36ab884de4b25b8f90d4086c`

## 1. Authorization and objective

Under the Owner-delegated bounded-governance convention, BA-07 is authorized for one bounded semantic/interface technical-design artifact because BA-01 through BA-05 event/evidence obligations are accepted and BA-07 is the remaining notification-authority design lane in the accepted decomposition DAG.

This task defines the semantic authority contract for:

1. domain-event notification eligibility;
2. privacy-minimal payload generation;
3. delivery-attempt/result evidence;
4. in-app versus external/lock-screen audience separation;
5. notification action/deep-link revalidation against current domain authority.

This task creates no endpoint, API, wire format, schema, storage, queue, worker, service, provider, platform integration, FCM/APNs choice, retry implementation, Flutter/client behavior, deployment, legal conclusion, production data-processing authority, or notification campaign authority.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only the binding/revision/freshness/outcome-vs-transport/idempotency/composition rules required here
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-07 only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-F and directly dependent common sections only
7. accepted BA-02 Runtime Readiness design/acceptance only for notification-eligible readiness evidence shape
8. accepted BA-03 Canonical Match design/acceptance only for notification-eligible Match evidence shape
9. accepted BA-04 Product Connection design/acceptance only for notification-eligible Connection evidence shape
10. accepted BA-05 Messaging Consent + Conversation Live Gate design/acceptance only for notification-eligible Conversation live-access evidence shape
11. `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_ACCEPTANCE_V0_1.md`
12. `docs/architecture/ELITESYNC_V10_APP_T09_GENERIC_NOTIFICATION_PRESENTATION_FOUNDATION_RESULT_V0_1.md`, notification presentation/audience sections only
13. `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`, notification integration boundary only
14. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only product/privacy/invariant boundaries needed here

If one exact source is missing or accepted provenance cannot be established, record that exact gap and continue all independent matrix rows that remain evaluable. Do not stop on the first ordinary source gap.

No directory enumeration. No broad repository/code search. No application-source/test read unless an exact task-bound artifact above explicitly requires it.

## 3. Exact output

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_NOTIFICATION_DOMAIN_EVENT_PAYLOAD_DELIVERY_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

## 4. Required semantic design

### 4.1 Four authority layers

Define four distinct responsibilities without selecting services:

1. **Owning domain event authority** — only the source domain may establish the domain event/outcome and whether that event class is eligible to be considered for notification.
2. **Notification eligibility/composition authority** — consumes current domain-owned event evidence plus audience/purpose/preferences where accepted; it cannot rewrite the domain outcome.
3. **Payload-generation authority** — generates only privacy-minimal, audience-appropriate notification material from already-authorized evidence.
4. **Delivery evidence authority** — records attempt/provider/OS-result evidence where knowable without converting transport state into a domain outcome.

Explicitly preserve:

- `DOMAIN EVENT != NOTIFICATION ELIGIBILITY`
- `NOTIFICATION ELIGIBILITY != PAYLOAD`
- `PAYLOAD != AUDIENCE AUTHORITY`
- `DELIVERY SUCCESS != DOMAIN SUCCESS`
- `OPEN/DISMISS != DOMAIN OUTCOME`
- `ROUTE/DEEP-LINK IDENTITY != ACCESS AUTHORITY`
- `TRANSPORT FAILURE != DOMAIN FAILURE`

### 4.2 Source-domain event evidence

For each accepted source domain—Readiness, Match, Product Connection, Conversation live access—define the minimum event/evidence obligations that may be consumed for notification evaluation.

For each, specify:

- owning authority;
- source subject/participant binding;
- event/outcome identity and lineage;
- source revision/currentness/freshness;
- audience/purpose admissibility;
- neutral/non-adverse meaning;
- what notification eligibility may consume;
- what it must never infer.

No notification system may synthesize Match acceptance, Connection consent, messaging consent, Conversation access, Readiness, Safety, guilt, Relationship, or Compatibility truth.

### 4.3 Notification eligibility contract

Define eligibility as a separate current decision over already-authorized event evidence.

At minimum cover:

- current eligible event;
- stale event;
- superseded event;
- unknown currentness;
- unavailable source authority;
- audience mismatch;
- purpose mismatch;
- participant mismatch;
- source correction/revocation after eligibility;
- duplicate logical notification intent;
- historical event after newer source revision;
- notification preference/control evidence only where accepted;
- external audience unavailable while in-app audience remains authorized, and vice versa.

If a preference/control policy is not accepted, retain it as an explicit seam rather than inventing mute windows, frequency caps, digesting, channel precedence, quiet hours, batching, or campaign rules.

### 4.4 In-app vs external/lock-screen audiences

Treat in-app and external/lock-screen as separate audiences/purposes.

Define:

- external copy must be generic/privacy-minimal by default;
- in-app copy may reveal only information independently authorized to the current authenticated audience;
- external eligibility never automatically creates in-app detailed disclosure;
- in-app disclosure never automatically authorizes external lock-screen detail;
- payload identity does not establish who is viewing the device;
- route/deep-link identity does not authorize detail fetch.

Explicitly preserve APP-T12-B01 boundary: legacy `status_author`-style payload/route identity cannot trigger profile-like loading without separately established audience authority.

### 4.5 Payload-generation contract

Define semantic payload obligations without wire fields.

At minimum cover:

- opaque notification identity;
- generic presentation category/copy;
- source-domain reference sufficient for revalidation but not protected content;
- authorized in-app action discriminator where accepted;
- audience/purpose binding;
- source event revision/currentness reference;
- privacy-minimality;
- no private Conversation content, message preview, draft, unread private detail, sensitive peer identity, hidden Safety evidence, Compatibility total score, analytics/training signal, or inferred desirability/person-worth.

No payload field may be treated as consent, permission, actor role, current source state, or mutation success.

### 4.6 Delivery attempt/result contract

Define delivery evidence distinctly from domain and notification eligibility evidence.

At minimum cover:

- notification logical intent;
- one or more transport attempts;
- idempotency correlation;
- accepted-for-transport;
- provider acknowledgement where knowable;
- OS/device delivery/display result where knowable;
- open;
- dismissal;
- timeout;
- unknown result;
- duplicate/reordered callbacks;
- delayed provider result after newer notification/source event;
- corrected/revoked source event after transport initiation.

Do not infer that provider success means user saw content or that open means consent/acceptance/domain completion.

### 4.7 Action / deep-link revalidation

Any notification-originated navigation/action must re-evaluate current authority at action time.

Cover at minimum:

- current source evidence still valid;
- source superseded after payload generation;
- source revoked/corrected after payload generation;
- viewer/account mismatch;
- participant mismatch;
- audience/purpose mismatch;
- stale deep link;
- reused old notification identity;
- already terminal domain state;
- Connection no longer active;
- messaging consent no longer active;
- Conversation live-send/live-read changed;
- Match proposal terminal/replaced;
- Readiness no longer current.

Notification identity can locate a revalidation path only. It cannot restore an action.

### 4.8 Correction/revocation propagation

Define how source-domain correction, revocation, supersession, or newer authority evidence affects:

- pending notification eligibility;
- not-yet-generated payload;
- generated but unsent payload;
- in-flight transport;
- delivered notification;
- app-open/deep-link action;
- cached in-app notification presentation.

Do not claim remote retraction or device-level deletion capability unless separately established. Preserve the difference between “future protected use denied” and “already rendered external copy can be recalled.”

### 4.9 Home and notification separation

BA-07 must not turn Home into a notification source authority or vice versa.

Home primary-action selection is not notification priority. Notification eligibility is not Home ranking. Neither may use the other's presentation ordering as domain authority.

### 4.10 Explicit retained seams

Retain, unless separately accepted:

- notification preferences model;
- mute/quiet-hours policy;
- frequency caps;
- batching/digest policy;
- retry limits/backoff;
- provider/channel selection;
- push token/device binding model;
- external copy localization/final wording;
- accessibility validation;
- legal/region-specific marketing/transactional classification;
- minor/age-specific notification posture;
- retention of delivery/open/dismiss telemetry;
- analytics/measurement authority;
- remote recall/retraction capability;
- exact OS/provider receipt semantics.

Do not convert these into defaults.

## 5. High-density validation matrix

The candidate must include at least **120 independently checkable validation rows**.

Every row must be classified:

- `PASS`
- `RETAINED_UNKNOWN`
- `BLOCKED`

The matrix must include, at minimum, independent rows for:

### A. Authority separation

1. source event owner distinct from notification authority
2. notification eligibility distinct from payload generation
3. payload generation distinct from delivery evidence
4. delivery evidence distinct from source outcome
5. route identity non-authoritative
6. payload identity non-authoritative
7. notification ID non-authoritative
8. open non-authoritative
9. dismissal non-authoritative
10. provider success non-authoritative

### B. Readiness source cases

11-20. current/stale/superseded/unknown/unavailable/corrected/revoked/subject-mismatch/audience-mismatch/purpose-mismatch

### C. Match source cases

21-35. participation/proposal currentness, one-sided acceptance, mutual acceptance, decline, withdrawal, expiry, terminal proposal, fresh proposal, stale proposal, superseded decision, participant mismatch, audience mismatch, purpose mismatch, corrected evidence, unknown expiry policy

### D. Connection source cases

36-50. CN pending/active/paused/closed/declined/withdrawn/expired, wrong aggregate, historical active, currentness unknown, stale, unavailable, participant mismatch, corrected/revoked evidence, expiry-policy seam

### E. Conversation live-access source cases

51-65. current read+send, read-only distinction if separately valid, MC pending/active/revoked, lost CN_ACTIVE, wrong Connection aggregate, historical consent, stale/unknown/unavailable inputs, audience/purpose/participant mismatch, correction/revocation, history authority exclusion

### F. Payload/privacy cases

66-85. generic external copy, in-app detailed audience, message preview exclusion, draft exclusion, unread private detail exclusion, peer identity minimization, Safety evidence exclusion, Compatibility total exclusion, analytics/training exclusion, opaque identity, source reference, action discriminator, audience binding, purpose binding, currentness reference, stale payload, superseded source, wrong viewer, external-vs-in-app divergence, legacy status_author boundary

### G. Delivery/idempotency/concurrency

86-105. duplicate intent, duplicate transport attempt, reordered provider callbacks, timeout after possible delivery, provider ack then source revocation, source revocation then delayed provider success, open-before-updated-source, dismissal-after-supersession, duplicate open, old notification replay, changed semantic input with reused idempotency identity, transport accepted but OS unknown, OS displayed but user unseen, open not domain success, provider failure not domain failure, stale notification after newer domain event, multiple channels unknown policy, unknown provider semantics, delivery-result correction, incomparable callbacks

### H. Deep-link/action revalidation

106-120. viewer mismatch, account switch, participant mismatch, stale route, expired Match proposal, terminal Match proposal, lost Connection active, revoked Messaging Consent, Conversation read lost, Conversation send lost, Readiness changed, source correction, source supersession, audience mismatch, purpose mismatch

### I. Retained seams and stop behavior

At least 10 additional rows for the retained seams in §4.10.

The candidate must report exact totals:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

and list every retained unknown and blocker.

Do **not** stop after the first ordinary retained unknown or blocker. Complete every independent row still evaluable. Stop early only if the fixed repository/task authority gate itself fails such that further source evaluation would be unauthorized.

## 6. Acceptance requirements

Independent review must be able to verify:

1. notification never writes a source-domain outcome;
2. domain-event eligibility and notification eligibility remain distinct;
3. payload identity/route/deep link never becomes audience/access authority;
4. in-app and external audiences are separately evaluated;
5. external copy is privacy-minimal by default;
6. private Conversation content never appears in notification payload design;
7. delivery/open/dismiss facts remain transport/presentation facts;
8. correction/revocation cannot be overridden by cached payload or transport success;
9. action/deep-link revalidation uses fresh current source authority;
10. no notification preference/retry/provider/legal policy is invented;
11. no endpoint/schema/service/queue/client implementation is selected;
12. high-density matrix is complete;
13. exact scope is one file;
14. `git diff --check` passes.

## 7. Execution boundary

Recommended branch:

`review/next-ba-07-notification-domain-event-payload-delivery-authority-technical-design-v0-1`

Publish exactly the single candidate file, push the branch, report branch/candidate/sole parent/tree/blob/scope/diff-check/matrix totals, then STOP.

Do not merge or self-accept.
Do not implement BA-07.
Do not start backend implementation, Flutter integration, deployment, legal work, analytics, or production notification work.

Expected classification:

`NOTIFICATION DOMAIN-EVENT / PAYLOAD / DELIVERY AUTHORITY TECHNICAL DESIGN ESTABLISHED — HIGH-DENSITY VALIDATION COMPLETE — PRIVACY / AUDIENCE / TRANSPORT SEPARATION EXPLICIT — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
