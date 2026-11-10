# EliteSync v10｜APP-T07 Conversation Availability / Messaging Consent Foundation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — CONVERSATION AVAILABILITY / CONSENT FOUNDATION ONLY`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start expected `origin/main`:

`44f94e1c8249f1bee27055c03223795b4a2afc78`

Read FIRST:

`AGENTS.md`

Then read:

- `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`;
- `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md`;
- `docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_ACCEPTANCE_V0_1.md`;
- this task sheet.

Accepted APP-T06 result blob:

`27677f6c93f330c934f787660d5f268525e2e0d6`

## 2. Sole objective

Establish the target Conversation availability and separate messaging-consent foundation while preserving:

`Match != Connection != Conversation != Relationship`

Conversation must require both:

1. authoritative Product Connection state `CN_ACTIVE`; and
2. separate mutual messaging consent.

Neither Match nor Connection alone authorizes message content.

## 3. Critical current authority boundary

APP-T06 established the Product Connection contract but also established that no authoritative runtime Product Connection snapshot source or mutation authority is currently connected.

Therefore APP-T07 must fail closed by default.

Do not fabricate `CN_ACTIVE`, messaging consent, Conversation availability, or persistence using:

- local booleans;
- route tokens;
- existing Conversation rows;
- `eligibleMatch` or `legacyPeer` route kinds;
- transport `chatConnectionProvider` / `ConnectionStatusBanner`;
- Match `conversationCapability`;
- unread state;
- presence of an existing message thread;
- legacy chat behavior.

## 4. Target Conversation contract

Represent at minimum:

- `CV_LOCKED` — required Connection and/or messaging-consent authority is absent;
- `CV_PENDING_CONSENT` — authoritative active Connection exists but mutual messaging consent is not yet complete;
- `CV_ACTIVE` — authoritative active Connection plus separate mutual messaging consent;
- `CV_PAUSED` — Conversation activity paused under authoritative domain state;
- `CV_CLOSED` — Conversation lifecycle ended.

You may model `AVAILABLE_TO_ENABLE` or `READ_ONLY` only as bounded presentation conditions if needed; do not claim new domain authority beyond the accepted APP-T01 contract.

State vocabulary is not authority.

## 5. Required outcomes

1. Create an explicit Product Conversation lifecycle/access contract separate from Product Connection and transport connectivity.
2. Create a bounded access snapshot/adapter that requires explicit evidence of `CN_ACTIVE` plus separate messaging consent before `CV_ACTIVE`.
3. Default current production presentation to locked/not-established when those authorities are unavailable.
4. The top-level Messages surface must not load/reveal Conversation rows or previews when Conversation authority is not established.
5. Direct ChatRoom entry must be guarded before private content loading. Route identity is not consent.
6. Existing `eligibleMatch` and `legacyPeer` route kinds must not be treated as permission to read/send. They may remain compatibility identifiers for later APP-T11 retirement but must be gated.
7. User-facing explanation must state:
   - Connection requires separate messaging consent;
   - Connection alone does not open Conversation;
   - Match does not open Conversation;
   - lock/pending states reveal no message content;
   - Block and Report remain separate controls and are not consent/lifecycle truth.
8. Unsupported consent actions must be visibly unavailable / `NOT YET ESTABLISHED`; do not simulate success.
9. Do not implement Conversation retention/export/deletion policy; keep it UNKNOWN.
10. Do not implement Relationship.

## 6. Privacy requirement

When Conversation access is not authoritative:

- do not query/load message bodies;
- do not expose last-message previews;
- do not reveal peer/message/thread existence beyond the minimum privacy-safe route/gate explanation;
- do not inspect populated private Conversation data during implementation or verification.

Private Conversation remains:

`CONVERSATION_SHARED_PRIVATE`

and is not default Match/ranking/training data.

## 7. Authorized source scope

APP-T07 may modify only these existing files where directly necessary:

- `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart`
- `apps/flutter_elitesync_module/lib/features/chat/domain/entities/conversation_entity.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/pages/chat_room_page.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/providers/chat_providers.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart`

APP-T07 may create new bounded files only under:

- `apps/flutter_elitesync_module/lib/features/chat/domain/`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/state/`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/`

Narrow synthetic tests may be created/modified only under:

`apps/flutter_elitesync_module/test/features/chat/`

### Connection read-only exception

APP-T07 may import/read the accepted Product Connection contract types needed to express the `CN_ACTIVE` prerequisite.

Do not modify APP-T06 Connection files. If an actual Connection-source change appears necessary, STOP and report the exact blocker rather than expanding scope.

## 8. Explicit prohibitions

Do not modify:

- APP-T06 Product Connection contract/presentation files;
- Match source;
- readiness/navigation guard source;
- Me/Profile/Questionnaire/Verification;
- Relationship source;
- Home/Discover;
- Settings/Privacy/Notifications except existing Block/Report UI must remain semantically distinct;
- backend/API/database/service decomposition;
- build/dependency configuration.

Do not:

- invent messaging-consent backend endpoints;
- invent Conversation state persistence;
- infer `CN_ACTIVE` from current chats, peer IDs, Match IDs, transport connectivity, route existence, or messages;
- infer messaging consent from an existing thread;
- enable send when consent authority is unavailable;
- read private participant/message content for evidence;
- perform telemetry/analytics;
- perform Safety Operations;
- perform new legal research;
- resolve retention/export/deletion UNKNOWNs;
- resume Sandbox/DEP13/B12/M2/M3;
- repair Browser/model/notify global configuration;
- read README or FD02;
- start APP-T08.

## 9. Verification

Authorized verification:

- `dart format`;
- `git diff --check`;
- exact static/source assertions;
- narrow synthetic Chat/Conversation tests if a valid existing package graph is present;
- `flutter analyze --no-pub` only if a valid existing package graph is present.

Do not run `pub get` merely to make verification executable.

If `.dart_tool/package_config.json` is absent, executable analysis/tests remain `NOT ESTABLISHED`.

Do not create/populate private Conversation fixtures containing real participant/message content. Synthetic identifiers and synthetic non-sensitive lifecycle states are permitted.

## 10. Acceptance requirements

The result must establish by source evidence that:

1. Conversation access is explicitly distinct from Connection and Match;
2. `CV_*` lifecycle/access vocabulary is explicit;
3. `CV_ACTIVE` requires authoritative `CN_ACTIVE` plus separate messaging consent;
4. default current authority is fail-closed/not-established;
5. Messages does not load/reveal private Conversation rows when authority is absent;
6. ChatRoom is gated before message loading/sending;
7. `eligibleMatch`/`legacyPeer` are not consent authority;
8. no consent/persistence authority is fabricated;
9. Block and Report remain separate from lifecycle consent;
10. retention/export/deletion remain UNKNOWN;
11. no private-data inspection or unauthorized source area is used;
12. only authorized source/test/result files change.

## 11. Required result artifact

Create:

`docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_RESULT_V0_1.md`

Report:

- exact changed files;
- Conversation state/access table;
- Connection prerequisite and messaging-consent authority table;
- Messages fail-closed behavior;
- ChatRoom pre-load gate behavior;
- treatment of `eligibleMatch` / `legacyPeer`;
- authoritative vs not-yet-established actions;
- retained UNKNOWNs;
- verification ledger;
- blockers;
- bounded APP-T08 readiness recommendation.

## 12. Candidate rules

Suggested branch:

`review/app-t07-conversation-availability-messaging-consent-foundation-v0-1`

Candidate commit may contain only:

- authorized APP-T07 source changes;
- narrow synthetic Chat/Conversation tests;
- the single APP-T07 result artifact.

Do not merge to `main`.
Do not self-accept.
Do not start APP-T08.

Expected successful classification:

`APP-T07 CONVERSATION AVAILABILITY / MESSAGING CONSENT FOUNDATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
