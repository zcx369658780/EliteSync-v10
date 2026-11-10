# EliteSync v10｜APP-INT-03 Synthetic Product Connection Lifecycle｜v0.1

Status: OWNER-AUTHORIZED — DEMO-ONLY PRODUCT CONNECTION LIFECYCLE — ANDROID RUNTIME — CONVERSATION REMAINS LOCKED
Date: 2026-09-21
Repository: zcx369658780/EliteSync-v10

Pre-task main: e2e4a85bcbf082452479b2c30ba21a7950d98926

## Goal

Extend the accepted Android synthetic demo from Readiness + read-only Match into an interactive local Product Connection lifecycle driven by the existing eight-state contract.

Required visible sequence:

CN_NONE -> CN_PENDING -> CN_ACTIVE -> CN_PAUSED -> CN_ACTIVE -> CN_CLOSED

This is local development simulation only. It must not become authoritative Connection state, must not create Connection HTTP/writer authority, and must not unlock Conversation.

## Fresh gate

Fresh-fetch main and require the task-publication authority supplied by the execution prompt. Read AGENTS.md first, then this task. Create a fresh C-drive worktree and branch from that authority.

Recommended:
- worktree: C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-03-connection
- branch: impl/app-int-03-synthetic-product-connection-v0-1

Use the proven C-drive Android build recipe.

## Fixed inputs

Verify:
- AGENTS.md c9a8e192f7647a1613a195655fe9c22c56502ddb
- app_env.dart ecee2b1d68195e004a88ec5d1d8301b9ab95a382
- main_demo.dart 1aea683e09c69dbdad73fa95b8178cd91d553b12
- product_connection_contract.dart 07b0beffb9033ea960a7c3c37daa453bc194bfeb
- connection_presentation_state.dart 7213a811ab0e85358860abe5a3ac4520e4ad6354
- connection_page.dart 71a05388dcb6846c7a0f868a02d98dd47ac3f387
- connection_authority_panel.dart 6fc97fe4f9c460d48faed852c329a81a64ac18bf
- conversation_access_state.dart f75ebffebcd8f361af654a4d9304e10b8c476d06
- android_runtime_bootstrap_test.dart b71a70812c61c075feac0031aee90477ab1ddf1d
- pubspec.lock b56c4b2c45bab65106c12e4d75d6c5b34209aeb4

Do not modify product_connection_contract.dart or conversation_access_state.dart.

## Normal write set

Modify:
1. apps/flutter_elitesync_module/lib/app/config/app_env.dart
2. apps/flutter_elitesync_module/lib/main_demo.dart
3. apps/flutter_elitesync_module/lib/features/connection/presentation/state/connection_presentation_state.dart
4. apps/flutter_elitesync_module/lib/features/connection/presentation/pages/connection_page.dart
5. apps/flutter_elitesync_module/lib/features/connection/presentation/widgets/connection_authority_panel.dart
6. apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart

Create:
7. apps/flutter_elitesync_module/lib/features/connection/presentation/providers/connection_presentation_provider.dart
8. apps/flutter_elitesync_module/test/synthetic_product_connection_lifecycle_test.dart
9. docs/architecture/ELITESYNC_V10_APP_INT_03_SYNTHETIC_PRODUCT_CONNECTION_LIFECYCLE_RESULT_V0_1.md

## Implementation contract

Add AppEnv.useSyntheticConnectionLifecycle with default false. Only main_demo.dart enables it.

Extend presentation authority with a distinct syntheticDevelopment value. Add ConnectionPresentationState.syntheticDevelopment(state). hasAuthoritativeState must remain true only for authoritative state.

Create a Riverpod controller/provider:
- non-demo => notYetEstablished, no local mutation;
- dev + explicit synthetic flag => starts syntheticDevelopment(CN_NONE);
- transitions must be resolved from ProductConnectionContract.transitions by current state + action;
- invalid action => no state change;
- direct CN_NONE -> CN_ACTIVE must remain impossible;
- optional dev-only reset may return to CN_NONE and must be labelled as demo reset, not a domain transition.

Do not persist synthetic Connection as a real fact.

Connection UI in synthetic mode must visibly say:
Synthetic Connection · 开发演示
and explain that the state is local simulation, not server/production authority.

Show only currently applicable local synthetic actions derived from ProductConnectionContract.transitions. Actor-sensitive labels should be explicit, e.g. 模拟对方接受/谢绝. Keep ProductConnectionAuthority.authoritativeActions unchanged and empty.

When synthetic mode is disabled, keep the existing NOT YET ESTABLISHED/locked behavior.

Messages must remain fail-closed even at synthetic CN_ACTIVE. Do not modify Conversation authority/provider.

## Tests

Extend android_runtime_bootstrap_test.dart to prove the new demo flag is true.

Create synthetic_product_connection_lifecycle_test.dart and verify:
- default flag false; demo flag true;
- initial synthetic CN_NONE;
- request => CN_PENDING;
- accept => CN_ACTIVE;
- pause => CN_PAUSED;
- resume => CN_ACTIVE;
- close => CN_CLOSED;
- ProductConnectionContract has no none->active transition;
- fresh pending branches reach DECLINED / WITHDRAWN / EXPIRED;
- ProductConnectionAuthority.authoritativeActions remains empty;
- synthetic CN_ACTIVE does not make conversationAccessProvider reveal private content.

## Validation

Run:
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub test/android_runtime_bootstrap_test.dart test/synthetic_readiness_match_integration_test.dart test/synthetic_product_connection_lifecycle_test.dart test/widget_test.dart

Analyze/tests: initial plus max one correction rerun.

Use fresh C-drive GRADLE_USER_HOME and generated ignored flags:
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart

Build:
.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2

Initial plus max one transient/generated-host retry. Install and cold-launch on the running Android emulator.

## Android proof

Verify directly:
1. Home starts;
2. Progress -> Match still shows the synthetic proposal;
3. Progress -> Connection shows Synthetic Connection · 开发演示 and CN_NONE;
4. request => CN_PENDING;
5. simulated recipient accept => CN_ACTIVE;
6. open Messages: still NOT YET ESTABLISHED, private content hidden;
7. return Connection; pause => CN_PAUSED;
8. resume => CN_ACTIVE;
9. close => CN_CLOSED;
10. return Home without crash.

Logs:
- production EliteSync API = 0
- RTC watcher/polling = 0
- fatal/crash = 0

## Bounded repair

At most two additional Flutter tracked files may be changed only for concrete analyzer/compiler/runtime blockers in this flow. No backend/HTTP, production auth/session change, Match mutation authority, Conversation authority or dependency-version change.

## Publication

Publish one immutable candidate only after final analyze/tests/build/install/runtime proof passes.

Candidate sole parent = task-publication authority.
Normal scope = 9 paths; max 11 with bounded repair.
Generated host/caches/APK/screenshots/logs are not committed.

Success:
APP-INT-03 COMPLETE — PRODUCT CONNECTION CONTRACT DRIVES LOCAL SYNTHETIC LIFECYCLE — CN_NONE/PENDING/ACTIVE/PAUSED/CLOSED INTERACTION VERIFIED — TERMINAL REQUEST OUTCOMES TESTED — CONVERSATION REMAINS LOCKED — NO PRODUCTION API/RTC — READY FOR SYNTHETIC MESSAGING CONSENT + CONVERSATION INTEGRATION

Candidate author cannot self-accept or move main. Then STOP.
