# EliteSync v10｜APP-T06 Connection Mutual-Consent Lifecycle Foundation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — CONNECTION LIFECYCLE FOUNDATION ONLY`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start expected `origin/main`:

`975f89cce8387090a11514a15ef3ecf9f885db3e`

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

- accepted APP-T01 target contract result;
- accepted APP-T02 source/migration inventory result;
- APP-T05 acceptance;
- this task sheet.

Accepted APP-T05 result blob:

`1d99a8f681e8cbe58adab4cde4041111aa5f2087`

## 2. Local-worktree safety

The original `D:\EliteSync-v10` worktree remains known dirty and detached.

Do not modify, clean, stash, reset, checkout over, delete, move, adopt, stage, commit, or otherwise disturb it.

Use a separate fresh clean worktree from fresh-fetched `origin/main`.

## 3. Sole objective

Establish the separate Product Connection lifecycle foundation under the accepted invariant:

`Match != Connection != Conversation != Relationship`

Target Connection vocabulary:

`CN_NONE -> CN_PENDING -> CN_ACTIVE -> CN_PAUSED / CN_CLOSED`

with bounded terminal request outcomes:

`CN_DECLINED / CN_WITHDRAWN / CN_EXPIRED`

Connection is mutual consent. Match must not auto-create it. Connection must not auto-authorize Conversation.

## 4. Critical authority rule

APP-T02 established:

`EXISTING PRODUCT CONNECTION REPRESENTATION = UNKNOWN / NOT LOCATED WITHIN AUTHORIZED SCOPE`

Therefore APP-T06 must not adopt transport connectivity (`chatConnectionProvider`, `ConnectionStatusBanner`) as Product Connection.

Likewise APP-T06 must not treat raw Match `conversationCapability`, legacy Match result/chat behavior, or `eligibleMatch` chat entry as Connection authority.

If no accepted backend/API mutation authority exists for Connection request/accept/decline/pause/close, do not invent endpoints or fake persistence. It is acceptable to establish a target domain/presentation contract with unavailable actions explicitly marked `NOT YET ESTABLISHED`.

## 5. Required outcomes

1. Create a clear Product Connection state/authority contract separate from transport connectivity.
2. Provide a Progress-owned Connection surface or entry foundation that can represent at minimum:
   - no Connection process established;
   - pending mutual consent;
   - active Connection;
   - paused Connection;
   - closed/terminal request states where authoritative evidence exists.
3. Explain in user-comprehensible form:
   - Match/mutual interest does not create Connection;
   - Connection requires separate mutual consent;
   - Connection does not authorize Conversation;
   - decline/withdraw/expiry do not imply guilt, incompatibility truth, or Safety finding.
4. Keep unsupported mutation actions visibly unavailable/not connected rather than simulating success.
5. Do not alter canonical Match state authority except for a minimal, explicitly authorized handoff/entry link if necessary.
6. Do not implement Conversation consent, Chat gating, or message availability; those belong to APP-T07.
7. Do not implement Relationship.

## 6. Authorized source scope

APP-T06 may modify the minimum Progress/Connection presentation and target domain files necessary.

Existing files allowed where directly necessary:

- `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart`

APP-T06 may create new files only under:

- `apps/flutter_elitesync_module/lib/features/connection/domain/`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/state/`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/pages/`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/widgets/`

Narrow synthetic tests may be added/modified only under:

`apps/flutter_elitesync_module/test/features/connection/`

### Match exception

Do not modify Match files unless a concrete compile/routing blocker requires one minimal handoff change. If broader Match modification appears necessary, STOP and report rather than expanding scope.

## 7. Explicit prohibitions

Do not modify:

- `chatConnectionProvider` or transport connection banner semantics;
- Chat/Conversation entities/providers/pages/routes except no changes are expected in APP-T06;
- APP-T04 readiness guard/snapshot;
- Profile/Me/Questionnaire/Verification;
- Relationship source;
- Home/Discover;
- Settings/Privacy/Notifications;
- backend/API/database/service decomposition;
- build/dependency configuration.

Do not:

- invent Connection backend endpoints;
- use a local boolean as persisted mutual consent truth;
- auto-create Connection from Match;
- auto-open Messages/Chat from Connection;
- treat Connection as Conversation permission;
- treat transport connectivity as Product Connection;
- infer Relationship from Connection;
- resolve retained UNKNOWNs;
- perform private/participant-data inspection, telemetry, Safety Operations, new legal research, Sandbox/DEP13/B12/M2/M3;
- read README or FD02;
- start APP-T07.

## 8. Retained UNKNOWNs

Preserve:

- exact Connection request expiry policy/duration unless source authority already establishes it;
- persistence/backend mutation authority if not established;
- Conversation consent and retention/export/deletion rights;
- exact Relationship tools;
- readiness/identity-assurance specifics;
- optional signal allowlist.

`UNKNOWN != ABSENT` and `STATE VOCABULARY != AUTHORITY` remain binding.

## 9. Verification

Authorized verification:

- `dart format`;
- `git diff --check`;
- exact static/source contract assertions;
- narrow synthetic Connection tests if an existing valid package graph is present;
- `flutter analyze --no-pub` only if an existing valid package graph is present.

Do not run `pub get` merely to create verification evidence.

If `.dart_tool/package_config.json` is absent, executable analysis/tests remain `NOT ESTABLISHED`.

## 10. Acceptance requirements

The result must establish by source evidence that:

1. Product Connection is represented distinctly from Match, Conversation, Relationship and transport connectivity;
2. target `CN_*` vocabulary/authority is explicit;
3. no unsupported mutation authority is fabricated;
4. Match does not auto-create Connection;
5. Connection does not auto-authorize/open Conversation;
6. decline/withdraw/expiry are non-guilt/non-Safety/non-Compatibility-truth outcomes;
7. Progress can expose Connection as its own lifecycle area without collapsing it into Match;
8. no Chat/Conversation consent implementation is smuggled into APP-T06;
9. retained UNKNOWNs stay unresolved;
10. only authorized source/test/result files change.

## 11. Required result artifact

Create:

`docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_RESULT_V0_1.md`

Report:

- exact changed files;
- target Connection state mapping/authority table;
- authoritative vs not-yet-established actions;
- Progress integration;
- explicit separation from transport connection and Conversation;
- retained UNKNOWNs;
- verification ledger;
- blockers;
- bounded APP-T07 readiness recommendation.

## 12. Candidate rules

Suggested branch:

`review/app-t06-connection-mutual-consent-lifecycle-foundation-v0-1`

Candidate commit may contain only:

- authorized APP-T06 source changes;
- narrow Connection tests;
- the single APP-T06 result artifact.

Do not merge to `main`.
Do not self-accept.
Do not start APP-T07.

Expected successful classification:

`APP-T06 CONNECTION MUTUAL-CONSENT LIFECYCLE FOUNDATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
