# EliteSync v10｜NEXT IP-07 Notification Implementation Plan Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY IMPLEMENTATION PLANNING ONLY — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Task-publication base: `e46039dfaca69bb1542cff5862c61472deb0db13`

## 1. Purpose and authority

Produce one technology-neutral documentary implementation plan for the accepted BA-07 four-layer Notification authority.

This task consumes accepted IP-01, accepted IP-02/IP-03/IP-04/IP-05 domain plans, accepted BA-07 technical design and accepted APP-T09 substitute provenance. It must not change those semantics.

This task does not authorize backend/client code, API, schema, database, provider/channel integration, push-token handling, queue/worker deployment, telemetry processing, private-data activity, legal work, Safety Operations, production use, or runtime execution.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_IMPLEMENTATION_PLAN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_IMPLEMENTATION_PLAN_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_IMPLEMENTATION_PLAN_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_IMPLEMENTATION_PLAN_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_IMPLEMENTATION_PLAN_V0_1.md`
9. `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_IMPLEMENTATION_PLAN_ACCEPTANCE_V0_1.md`
10. `docs/architecture/ELITESYNC_V10_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_IMPLEMENTATION_PLAN_V0_1.md`
11. `docs/architecture/ELITESYNC_V10_BACKEND_NOTIFICATION_DOMAIN_EVENT_PAYLOAD_DELIVERY_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
12. `docs/architecture/ELITESYNC_V10_BACKEND_NOTIFICATION_DOMAIN_EVENT_PAYLOAD_DELIVERY_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
13. `docs/architecture/ELITESYNC_V10_APP_T09_NOTIFICATION_PRESENTATION_PROVENANCE_RESOLUTION_ACCEPTANCE_V0_1.md`
14. `docs/architecture/ELITESYNC_V10_APP_T09_NOTIFICATION_PRESENTATION_PROVENANCE_RESOLUTION_RESULT_V0_1.md`
15. accepted post-BA01..07 implementation-entry review, IP-07 lane and directly dependent common sections only.

Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_NOTIFICATION_IMPLEMENTATION_PLAN_V0_1.md`

## 4. Preserve exact four-layer authority

Keep exactly these semantic layers separate:

1. source-domain event authority;
2. notification eligibility authority;
3. privacy-minimal payload-generation authority;
4. delivery attempt/result evidence authority.

Preserve:

- `DOMAIN EVENT != NOTIFICATION ELIGIBILITY`;
- `NOTIFICATION ELIGIBILITY != PAYLOAD`;
- `PAYLOAD != AUDIENCE / ACCESS AUTHORITY`;
- `DELIVERY SUCCESS != DOMAIN SUCCESS`;
- `OPEN / DISMISS != DOMAIN OUTCOME`;
- `ROUTE / DEEP-LINK IDENTITY != PERMISSION`;
- `TRANSPORT FAILURE != DOMAIN FAILURE`.

In-app and external/lock-screen audiences remain independently evaluated. External/lock-screen copy is generic/privacy-minimal by default.

## 5. Required technology-neutral responsibilities

Define responsibilities for:

- source-event evidence adapters for Readiness, Match, Connection and Conversation live-access;
- source-domain event-class consideration adapter;
- notification eligibility evaluator;
- preference/control policy adapter;
- audience/purpose evaluator;
- logical notification-intent/idempotency handler;
- privacy-minimal payload generator;
- in-app presentation envelope;
- external/lock-screen generic payload envelope;
- deep-link/action reference generator;
- action-time source-authority revalidator;
- delivery attempt/result evidence recorder;
- duplicate/reordered callback reconciler;
- source correction/revocation/supersession invalidation handler;
- projection-lag/stale-payload handler;
- provider/channel/push-token extension boundaries;
- downstream IP-08/IP-09/IP-10 documentary contracts.

Responsibilities are semantic only; do not allocate them to services/modules/processes/tables/queues/workers.

## 6. Source-domain input rules

For each Readiness, Match, Product Connection and Conversation live-access source:

- bind exact authority/provenance;
- exact source identity/context;
- subject/participants;
- audience/purpose;
- source-local revision/currentness;
- freshness;
- correction/revocation/supersession;
- source-local condition;
- separately accepted notification-consideration event class.

A source event is not notification eligibility merely because its shape is valid.

Concrete notification-eligible event-class allowlists remain unresolved unless separately accepted. Absence must fail closed for concrete notification production.

## 7. Notification eligibility plan

The eligibility evaluator may return eligible only when all independently required inputs are established for the exact logical notification intent and exact audience/purpose.

Unknown/stale/superseded/incomparable/unavailable/mismatched source evidence fails closed.

Missing preference/control policy must not be interpreted as opt-in, opt-out, mute, quiet-hours, frequency permission or channel permission.

Do not invent urgency, campaign priority, engagement ranking, batching, digest or channel precedence.

## 8. Payload-generation and privacy plan

Payload generation consumes only an already-authorized eligibility result for one exact audience/purpose.

External/lock-screen payload MUST remain generic/privacy-minimal by default.

Do not include:

- private Conversation message content;
- message previews;
- drafts;
- private unread detail;
- private peer reasoning;
- hidden Safety evidence;
- Compatibility totals/factors;
- analytics/training signals;
- inferred desirability/person worth;
- unaccepted AI/personality/astrology/reference-signal data.

Raw title/body/payload identity is not private-detail authority.

In-app richer detail remains delegated to the owning surface and its current access gate.

## 9. Delivery-evidence plan

Delivery evidence records only transport/delivery observations that are actually knowable.

Differentiate at minimum:

- logical notification intent;
- delivery attempt identity;
- accepted-for-transport observation;
- provider/OS callback observation where semantics are established;
- displayed/open/dismiss observation where established;
- timeout/failure/unknown transport state.

None of these may mutate or strengthen L1/L2/L3 authority.

Exact OS/provider receipt semantics remain unresolved unless separately established.

## 10. Action/deep-link revalidation

Every notification-originated navigation or protected action must revalidate current source authority at action time.

Old/stale notification payload, route, deep link, displayed copy, open/dismiss event, delivery success, cached source revision or notification identity cannot authorize current protected access or mutation.

If source authority changed, destination handling fails closed or redirects according to the owning source semantics; Notification itself does not invent a new domain outcome.

## 11. Correction/revocation/supersession and stale-payload handling

Newer source evidence may invalidate future notification eligibility and protected use of prior payloads.

The plan must distinguish:

- stopping future eligibility;
- suppressing future payload use;
- inability to remotely recall an already delivered payload unless separately established;
- action-time revalidation after an old notification is opened;
- no rollback to an older source state due to callback/order lag.

Remote recall/retraction capability remains unresolved unless separately accepted.

## 12. Concurrency / idempotency cases

Cover at minimum:

- duplicate same logical notification intent;
- changed semantic content under reused intent identity;
- source correction vs eligibility decision;
- source correction after payload generation but before delivery;
- source correction after delivery but before open/action;
- duplicate delivery attempts;
- reordered provider callbacks;
- timeout after possible provider acceptance;
- external denied / in-app allowed;
- in-app denied / external allowed;
- preference change concurrent with eligibility evaluation, when preference authority exists;
- source audience/purpose mismatch;
- participant/account switch after payload creation;
- stale deep link after source-domain state change;
- superseded notification payload after newer source event;
- route identity without current authorization;
- open/dismiss callback after source revocation;
- notification duplication across retries;
- unknown provider semantics;
- projection lag against newer source authority.

Resolve using source authority and exact current bindings, never client arrival order or delivery order.

## 13. Retained seams

Preserve all existing BA-07 retained seams, including:

- notification-eligible event-class allowlists;
- Match expiry timing seams;
- Connection expiry policy;
- preference/control model;
- mute/quiet hours;
- frequency caps;
- batching/digest;
- retry/backoff;
- provider/channel selection and precedence;
- push-token/device-binding model;
- external copy localization/final wording;
- accessibility validation;
- legal/region marketing-versus-transactional classification;
- minor/age posture;
- delivery/open/dismiss telemetry retention;
- analytics/measurement authority;
- remote recall/retraction capability;
- exact provider/OS receipt semantics;
- historical Conversation read/access authority.

For every retained seam, classify whether it blocks:

- IP-07 core;
- one adapter/slice;
- later implementation execution;
- production only.

Do not silently default any seam.

## 14. High-density validation

Include at least 260 independently checkable validation rows.

Report exactly:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary unknown or blocker; complete every independently evaluable row.

## 15. Explicit non-goals

Do not select or implement:

- API/endpoints/protocol/wire representation;
- schema/database/index/key design;
- transactions/locks/CAS;
- queue/event log/broker/worker;
- language/framework;
- service/module/deployment topology;
- provider/channel/platform;
- push-token model;
- retry/backoff;
- clock/scheduler;
- notification preference model;
- telemetry/analytics/measurement;
- legal or regional policy;
- Flutter/client code;
- production/private-data processing.

## 16. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-07-notification-implementation-plan-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, or start IP-08/IP-09/IP-10.

Expected success classification:

`NOTIFICATION IMPLEMENTATION PLAN ESTABLISHED — FOUR-LAYER SOURCE / ELIGIBILITY / PAYLOAD / DELIVERY RESPONSIBILITY PLAN EXPLICIT — GENERIC EXTERNAL PRIVACY BOUNDARY AND ACTION-TIME REVALIDATION FIXED — RETAINED POLICY/PROVIDER SEAMS PRESERVED — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
