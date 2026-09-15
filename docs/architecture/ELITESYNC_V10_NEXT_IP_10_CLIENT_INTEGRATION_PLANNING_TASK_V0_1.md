# EliteSync v10｜NEXT IP-10 Client Integration Planning Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — DOCUMENTARY CLIENT-INTEGRATION PLANNING ONLY — NO CLIENT IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `3e7ecc8a45ac76c8d9e991c2a7fd67e7ae627311`

## 1. Purpose and authority

Produce one technology-neutral documentary client-integration plan consuming accepted IP-01 through IP-09 contracts without changing their semantics.

This task does not authorize Flutter/Dart code, generated clients, dependency changes, runtime/build activity, backend/API/schema implementation, production access, private-data processing, legal work, Safety Operations, telemetry/analytics expansion, or any deployment action.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. accepted IP-01 common backend implementation contract acceptance/result;
2. accepted IP-02 Runtime Readiness implementation-plan acceptance/result;
3. accepted IP-03 Canonical Match implementation-plan acceptance/result;
4. accepted IP-04 Product Connection implementation-plan acceptance/result;
5. accepted IP-05 Messaging Consent + Conversation live-gate implementation-plan acceptance/result;
6. accepted IP-06 Calm Home implementation-plan acceptance/result;
7. accepted IP-07 Notification implementation-plan acceptance/result;
8. accepted IP-08 Cross-Domain API / Interface plan acceptance/result;
9. accepted IP-09 Logical Persistence / Schema plan acceptance/result;
10. accepted post-BA01..BA07 implementation-entry review, IP-10 lane and directly dependent common boundaries only.

Do not enumerate directories or broaden discovery.

## 3. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_CLIENT_INTEGRATION_PLAN_V0_1.md`

## 4. Required plan content

Define technology-neutral client integration responsibilities for:

- authenticated viewer/actor binding;
- domain-specific screen/view-model consumption without source-authority promotion;
- projection retrieval and explicit source-condition handling;
- descriptive permitted-action rendering;
- protected-action revalidation before every mutation/protected read/send;
- expected revision/currentness/freshness binding;
- immutable logical-intent correlation and retry UX semantics;
- unknown authoritative outcome after transport failure;
- stale/superseded/incomparable/projection-lag UX behavior;
- correction/revocation/supersession invalidation handling;
- route/deep-link/navigation non-authority;
- optimistic UI restrictions;
- offline/cache restrictions;
- Runtime Readiness integration;
- Canonical Match participation/proposal/decision integration;
- Product Connection integration;
- Messaging Consent integration;
- separate Conversation live-read/live-send integration;
- Calm Home three-section integration and fail-closed primary-action presentation;
- Notification open/action revalidation and generic-external-to-owning-surface transition;
- privacy-minimal client state;
- API/interface contract consumption from IP-08;
- logical persistence identity/revision semantics consumed from IP-09 without assuming backend physical storage;
- tooling/build-validation readiness boundaries from IP-11/current governance.

## 5. Mandatory invariants

Preserve exactly:

- client state is never source authority;
- route/deep-link/payload identity is never permission;
- cached projection is never current authority by itself;
- descriptive permitted action is never a bearer capability;
- transport success is never domain success;
- timeout/failure can leave authoritative outcome unknown;
- no implicit retry with changed semantic input;
- no implicit rebase from stale expected revision to newer revision;
- terminal identities never reopen client-side;
- fresh Match/Connection/Consent identities remain fresh;
- one-sided Match acceptance remains inside `PENDING`;
- `CN_ACTIVE` alone never grants Conversation;
- live read and live send remain separate;
- no private Conversation content before current live-read gate passes;
- Home is zero-writer and multi-candidate primary selection remains fail-closed;
- Notification open/action always revalidates current source authority;
- external/lock-screen copy remains generic/privacy-minimal by default;
- `UNKNOWN != ABSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`.

## 6. Interaction / UX state planning

For each relevant domain, plan only technology-neutral client-visible state classes such as:

- loading/pending transport;
- authoritative current result;
- stale/superseded evidence;
- unknown authoritative outcome;
- unavailable authority;
- projection lag/updating;
- revision conflict/stale intent;
- binding/role/audience/purpose mismatch;
- retained policy prerequisite unestablished;
- terminal outcome/history where separately display-authorized.

Do not convert these presentation conditions into domain lifecycle states.

## 7. Retained seams

Preserve and classify unresolved seams including but not limited to:

- Readiness launch/identity/age/legal/vendor seams;
- Match expiry/clock/cooldown/future multi-candidate/signals seams;
- Connection expiry seam;
- Conversation history/retention/export/deletion/account-exit/legal/data-rights seams;
- Home optional-support catalog and precedence seam;
- Notification event allowlists/preferences/quiet-hours/frequency/batching/retry/provider/channel/token/localization/accessibility/legal/minor/telemetry/analytics/remote-recall/provider-receipt seams;
- concrete API/wire/schema/storage technology choices;
- client framework/package/toolchain/build-validation facts.

For every retained seam classify whether it blocks:

- IP-10 core;
- one client slice only;
- later client implementation execution;
- build/runtime validation only;
- production only.

## 8. High-density validation

Include at least 340 independently checkable validation rows covering common boundaries and every domain/client interaction family.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N / DEFERRED = N`

Do not stop after the first ordinary unknown or blocker; complete all independently evaluable rows.

## 9. Explicit non-goals

Do not choose or implement:

- Flutter widgets/routes/providers/state-management packages;
- Dart models/classes;
- generated API clients;
- HTTP/RPC/GraphQL/event mechanisms;
- endpoint paths/wire fields/serialization;
- local DB/cache package;
- background services/push SDK;
- package/dependency versions;
- concrete retry/backoff timers;
- build scripts/Gradle changes;
- platform-specific notification implementation;
- analytics/telemetry SDK;
- private Conversation history processing;
- production configuration.

## 10. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-10-client-integration-planning-v0-1`

Publish only the exact output file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, implement, run Flutter/Dart/Gradle/build/tests, or start implementation execution.

Expected success classification:

`CLIENT INTEGRATION PLAN ESTABLISHED — TECHNOLOGY-NEUTRAL PROJECTION / REVALIDATION / STALE-CONFLICT / FAIL-CLOSED UX CONTRACT EXPLICIT — TOOLING AND IMPLEMENTATION SEAMS RETAINED — NO CLIENT IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
