# EliteSync v10｜APP-T05 Canonical Match Lifecycle Foundation Implementation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — CANONICAL MATCH LIFECYCLE FOUNDATION ONLY`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start expected `origin/main`:

`07552437dfcaff4b5085b76bd0d14b4cc6cfb067`

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

- `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md` — accepted result blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418`;
- `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md` — accepted result blob `5393438eec4204640b5be639158528bd08ec8b16`;
- `docs/architecture/ELITESYNC_V10_APP_T04_ME_PURPOSE_SURFACES_READINESS_ONBOARDING_GUARD_FOUNDATION_ACCEPTANCE_V0_1.md`;
- this task sheet.

## 2. Local-worktree safety

The original local `D:\EliteSync-v10` worktree remains known dirty and detached.

Do not modify, clean, stash, reset, checkout over, delete, move, adopt, stage, commit, or otherwise disturb it.

Use a separate fresh clean worktree based on fresh-fetched `origin/main`.

## 3. Sole objective

Establish the **canonical Match lifecycle foundation** under the Owner-approved APP-T01 contract while preserving current authority limits.

APP-T05 must move the canonical Match presentation toward these target meanings:

`MT_NOT_OPTED_IN -> MT_ACTIVE -> MT_PROPOSAL_PRESENTED -> MT_INTEREST_RECORDED -> MT_MUTUAL_INTEREST -> MT_COMPLETED`

with bounded terminal/side outcomes where authority exists:

`MT_PAUSED / MT_DECLINED / MT_EXPIRED / MT_WITHDRAWN`

However, **state vocabulary is not authority**.

If current bounded source does not establish a real enrollment, pause, resume, withdraw, decline, interest-recording, mutual-interest, or expiry action/authority, APP-T05 must not fabricate it with a local boolean, fake network result, assumed backend endpoint, or legacy semantic inheritance.

Such target states may be modeled as target-domain/presentation states only where necessary, but unavailable actions must be presented honestly as not yet connected to authoritative product state.

## 4. Required outcomes

### 4.1 Canonical Match owns Match only

The canonical path must no longer treat embedded Conversation capability as permission to open Messages/Chat directly.

Any existing canonical action equivalent to:

`Match revealed/result -> Messages`

must be removed/replaced in canonical presentation.

After a successful bounded Match outcome, canonical UI may explain that Connection is a separate next lifecycle, but APP-T05 must not implement Connection, create Connection state, or open Conversation.

### 4.2 Target state adapter

Create a clear canonical target-state boundary between the current round projection and target Match semantics.

The implementation must distinguish at minimum:

- not participating / authority not established;
- waiting/active Match participation where current canonical projection supports that conclusion;
- proposal available/presented where current result/projection supports it;
- no candidate / no round as availability/presentation conditions rather than user rejection;
- transport/load failure separately from Match domain state;
- closed/completed/expired only where current source provides sufficient bounded evidence.

Do not blindly map old enum names one-to-one to target states if meanings differ.

### 4.3 Explanation contract

Canonical Match UI must provide bounded, privacy-safe explanation content appropriate to available data:

- what current Match state means;
- what it does **not** mean;
- no single authoritative Compatibility total score;
- AI/system output is not verified relationship truth;
- Match does not create Connection;
- Match does not authorize Conversation;
- uncertainty/limited evidence where applicable.

Do not reveal another user's private Matching Inputs or Safety evidence.

### 4.4 Readiness boundary

APP-T04 readiness guard remains authoritative for route entry.

Do not:

- bypass `/me/readiness` when readiness is unknown;
- derive readiness from Profile/questionnaire/verification locally;
- make Match opt-in happen by editing setup inputs;
- change readiness guard source in APP-T05.

### 4.5 Legacy coexistence

Participant-linked legacy Match remains present for later gated cutover/removal.

APP-T05 may modify the canonical/legacy selector only as directly necessary to make the canonical path target-correct.

Do not delete legacy countdown/result/detail/notification/chat consumers in APP-T05.

Do not claim legacy compatibility is no longer required until APP-T11 cutover evidence.

## 5. Authorized source scope

APP-T05 may read the exact Match seams established by APP-T02 and may modify only the following existing product files where directly necessary:

- `apps/flutter_elitesync_module/lib/features/match/presentation/pages/match_portal_page.dart`
- `apps/flutter_elitesync_module/lib/features/match/presentation/widgets/match_round_contract_view.dart`
- `apps/flutter_elitesync_module/lib/features/match/domain/entities/match_round_projection.dart`
- `apps/flutter_elitesync_module/lib/features/match/presentation/providers/match_providers.dart`
- `apps/flutter_elitesync_module/lib/features/match/data/datasource/match_remote_data_source.dart`

APP-T05 may create new bounded canonical Match target-domain/presentation files only under:

- `apps/flutter_elitesync_module/lib/features/match/domain/`
- `apps/flutter_elitesync_module/lib/features/match/presentation/state/`
- `apps/flutter_elitesync_module/lib/features/match/presentation/widgets/`

Narrow synthetic tests may be created/modified only under:

`apps/flutter_elitesync_module/test/features/match/`

### Router/shell exception

APP-T05 must not modify router/shell files unless a concrete canonical Match route compile blocker is established. If such a blocker appears, STOP and report it rather than expanding scope.

## 6. Explicit prohibitions

Do not modify:

- `navigation_guard_provider.dart` or `navigation_snapshot.dart`;
- Me/Profile/Questionnaire/Verification source;
- Connection source or create a Connection provider/entity/controller;
- Conversation/Chat source;
- Relationship source;
- Home/Discover;
- Settings/Privacy/Notifications;
- Backend/API/database/service/module decomposition;
- build/dependency configuration.

Do not:

- invent a backend Match enrollment/pause/withdraw endpoint;
- reuse a legacy endpoint for a different target meaning without exact source evidence;
- implement Conversation consent;
- route canonical Match result directly to Messages;
- expose private candidate data beyond current bounded projection authority;
- use Safety evidence, report/block counts, Conversation content, astrology/personality/reference signals, or a total Compatibility score as Match truth;
- choose exact Match proposal expiry duration;
- perform participant/private-data inspection, telemetry/analytics, Safety Operations, new legal research, Sandbox/DEP13/B12/M2/M3;
- read README or FD02;
- start APP-T06.

## 7. Retained UNKNOWNs

Preserve all existing retained UNKNOWNs, especially:

- readiness/eligibility specifics;
- exact Match proposal expiry duration;
- optional signal allowlist;
- Connection lifecycle implementation;
- Conversation consent/retention rights.

If current projection lacks enough evidence to classify an incoming state into a target Match state, use an explicit unknown/unavailable target presentation rather than guessing.

## 8. Verification

Authorized verification:

- `dart format` on changed/new Dart files;
- `git diff --check`;
- exact-source/static contract assertions;
- narrow pure-Dart or Flutter synthetic tests for state mapping/presentation if an existing valid package graph is present;
- `flutter analyze --no-pub` only if an existing valid package graph is present.

Do not run `pub get` or dependency/network acquisition merely to create verification evidence.

If `.dart_tool/package_config.json` is absent, executable analysis/tests remain `NOT ESTABLISHED`.

## 9. Acceptance requirements

The result must establish by source evidence that:

1. canonical Match is a distinct Progress child and remains readiness-gated by APP-T04;
2. canonical Match no longer grants Conversation authority or directly opens Messages from Match result capability;
3. target Match state semantics are represented through an explicit bounded adapter/contract rather than legacy labels alone;
4. transport/load failure is not represented as decline/expiry/no-candidate truth;
5. no single authoritative Compatibility total score is introduced;
6. Match explanation states `Match != Connection != Conversation` in user-comprehensible form where relevant;
7. unsupported target actions are not fabricated;
8. legacy Match remains intact for later cutover;
9. no retained UNKNOWN is silently resolved;
10. no non-authorized domain/source area is changed.

## 10. Required result artifact

Create:

`docs/architecture/ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_RESULT_V0_1.md`

The result must report:

- exact changed files;
- current canonical round -> target Match state mapping table;
- which target actions are actually authoritative versus not yet established;
- canonical Conversation-capability decoupling;
- explanation/user-control changes;
- legacy coexistence statement;
- retained UNKNOWNs;
- verification ledger;
- blockers, if any;
- bounded APP-T06 readiness recommendation.

## 11. Candidate rules

Use a fresh candidate branch, suggested:

`review/app-t05-canonical-match-lifecycle-foundation-v0-1`

Candidate commit may contain only:

- authorized APP-T05 product-source changes;
- narrowly relevant Match tests;
- the single APP-T05 result artifact.

Do not merge to `main`.
Do not self-accept.
Do not start APP-T06.

Expected successful classification:

`APP-T05 CANONICAL MATCH LIFECYCLE FOUNDATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
