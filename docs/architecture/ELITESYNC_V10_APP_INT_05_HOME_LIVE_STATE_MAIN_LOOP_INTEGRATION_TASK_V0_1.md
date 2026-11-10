# EliteSync v10｜APP-INT-05 Home Live-State + Main-Loop Integration｜v0.1

Status: OWNER-AUTHORIZED — HOME LIVE PRESENTATION PROJECTION — EXISTING READINESS/MATCH/CONNECTION/CONVERSATION STATES ONLY — ANDROID MAIN-LOOP PROOF
Date: 2026-09-21
Repository: zcx369658780/EliteSync-v10

Pre-task main:
87028a272cde8681a3231d4b47a05815b55a836a

APP-INT-04 is accepted. The Android synthetic demo can now exercise Readiness -> Match -> Connection -> independent Messaging consent -> Conversation. Home is still backed by the static CalmHomeProjection.current. This task makes Home a live presentation projection of those already-existing client states.

No new domain lifecycle or authority is created.

## Goal

Home must become a real Calm State Hub that updates without restart as the existing synthetic main loop changes.

Required Home summary domains:
- Readiness
- Match
- Connection
- Conversation

Required live behaviors:
- initial demo: synthetic Readiness ready, Match proposal presented, Connection CN_NONE, Conversation CV_LOCKED;
- after synthetic Connection reaches CN_ACTIVE, Home reflects CN_ACTIVE while Conversation remains CV_LOCKED;
- after messaging consent reaches CV_ACTIVE, Home reflects CV_ACTIVE;
- after Connection closes, Home immediately reflects CN_CLOSED and Conversation CV_LOCKED.

Home must show exactly one primary next-decision action derived from existing presentation state. It must not mutate lifecycle state itself.

## Fresh execution

Fresh-fetch main and require the task-publication authority supplied in the execution prompt. Read AGENTS.md first, then this task.

Create a fresh C-drive worktree, e.g.:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-05-home

Recommended branch:
impl/app-int-05-home-live-state-v0-1

## Fixed inputs

Verify:
- AGENTS.md c9a8e192f7647a1613a195655fe9c22c56502ddb
- app_env.dart 1aaa06fa238423fb4394041dd723fa420549bab1
- main_demo.dart 775a94d0bbdb886b03f04a0577d89c730455a642
- home_page.dart 09168f01ff9464934372fb017ccfb60ffe2a5bba
- calm_home_projection.dart f485ddaba2ec7cf4ba1f94d4f496d2c828397e3b
- navigation_guard_provider.dart f15eb57367349664dbc057424bae66bf5287473b
- match_providers.dart e43f3dd7529cd5476cc5de946d5e703537c1eff1
- canonical_match_lifecycle.dart 14147cce1716da38dfd2e1fdc0fea7af02d5c51f
- connection_presentation_provider.dart 8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f
- conversation_access_state.dart a652a3421408f9e59045cd1cd95a99306b405da7
- app_route_names.dart d831a56e7f8a7bb162b25f390128b3c004042e68
- android_runtime_bootstrap_test.dart 2d1cfbf5861ff983e8b6b6682c135b982e873f6b
- pubspec.lock b56c4b2c45bab65106c12e4d75d6c5b34209aeb4

No repository enumeration or old repository access.

## Normal write set

Modify:
1. apps/flutter_elitesync_module/lib/app/config/app_env.dart
2. apps/flutter_elitesync_module/lib/main_demo.dart
3. apps/flutter_elitesync_module/lib/features/home/presentation/state/calm_home_projection.dart
4. apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart
5. apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart

Create:
6. apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart
7. apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart
8. docs/architecture/ELITESYNC_V10_APP_INT_05_HOME_LIVE_STATE_MAIN_LOOP_INTEGRATION_RESULT_V0_1.md

## Demo gate

Add AppEnv.useSyntheticHomeProjection with default false. Only main_demo.dart enables it.

When disabled, Home must preserve the current static/fail-closed behavior. Do not make production/default Home start Match or other network work as a side effect of this task.

When enabled in dev, the new Home projection provider may watch:
- navigationGuardProvider
- matchRoundProjectionProvider
- connectionPresentationProvider
- conversationAccessProvider

No other source is needed.

## Projection model

Extend HomeProjectionAuthority with syntheticDevelopment while preserving authoritative / notYetEstablished / unknown semantics.

HomeStateSummary may carry an explicit state/status code for live display. The UI must visibly distinguish synthetic state, for example:
- Readiness: READY · Synthetic
- Match: MT_PROPOSAL_PRESENTED · Synthetic
- Connection: CN_NONE / CN_ACTIVE / CN_CLOSED · Synthetic
- Conversation: CV_LOCKED / CV_ACTIVE · Synthetic

Do not relabel synthetic states as authoritative.

For Match, consume the existing MatchRoundProjection and CanonicalMatchLifecycleAdapter. Do not create another Match state machine.

If the local Match provider is loading/error, Home should present loading/unknown safely rather than inventing a proposal.

## Next-decision rules

Home remains read-only. It may only navigate.

For synthetic demo, use this priority:
1. readiness not ready => 前往准备状态 -> meReadiness
2. Match not yet proposal/available => 查看匹配 -> progressMatch
3. Connection not active => 查看连接 -> progressConnection
4. Connection active and Conversation not active => 前往消息同意 -> messages
5. Conversation active => 查看消息 -> messages

If Connection becomes closed/paused/non-active after Conversation had been active, Home should return to the Connection-oriented next decision because Conversation will already be fail-closed by its existing provider.

The next-decision description must explain why the route is suggested. It must not claim that Home itself grants authority.

## Home UI

Convert HomePage to ConsumerWidget and read the live projection provider.

Keep the existing low-density three-area layout:
- Current state
- Next decision
- Optional support

Do not redesign the whole Home screen.

Current state must update live when providers change.

Next-decision text must come from the projection rather than the old hard-coded “not enough authority” sentence.

Exactly one primary action remains.

## Tests

Extend android_runtime_bootstrap_test.dart to prove demo synthetic Home flag true.

Create synthetic_home_main_loop_integration_test.dart.

At minimum prove:
1. default flag false / demo true;
2. disabled mode returns existing static fail-closed projection without watching/depending on synthetic state;
3. demo initial projection contains synthetic Readiness ready + Match proposal + CN_NONE + CV_LOCKED;
4. next decision initially points to Connection;
5. after Connection request+accept -> CN_ACTIVE, Home updates and next decision points to Messages consent;
6. after Conversation request+accept -> CV_ACTIVE, Home shows CV_ACTIVE and next decision remains Messages;
7. closing Connection -> CN_CLOSED and Conversation CV_LOCKED; Home updates and next decision returns to Connection;
8. no Home projection action mutates upstream providers;
9. Match summary uses CanonicalMatchLifecycleAdapter result.

Use ProviderContainer overrides as needed. Keep all data synthetic.

## Validation

Run:
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub test/android_runtime_bootstrap_test.dart test/synthetic_readiness_match_integration_test.dart test/synthetic_product_connection_lifecycle_test.dart test/synthetic_messaging_conversation_integration_test.dart test/synthetic_home_main_loop_integration_test.dart test/widget_test.dart

Analyze/tests: initial plus max one correction rerun.

### Reusable project Gradle cache

To reduce repeated artifact downloads, this and future compatible client-integration tasks may reuse the already isolated EliteSync cache:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-04-gradle-home

If it is absent/unusable, create:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-android-gradle-home-v1

This is project build cache only, not the user's global Gradle cache. Do not inspect unrelated cache content or credentials.

In the same PowerShell process set:
GRADLE_USER_HOME=<selected project cache>
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot
GRADLE_OPTS=-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2

Generated ignored flags:
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart

First dependency gate WITHOUT refresh:
.\gradlew.bat :app:checkDebugAarMetadata --no-daemon --stacktrace --info --console=plain --max-workers=2

If it fails only because an official dependency is missing/stale or TLS interrupted, one retry with --refresh-dependencies is authorized. Maximum dependency-gate executions: 2.

After PASS:
.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2

Maximum assemble executions: 2.

No dependency/version change.

Install the debug APK and cold-launch the running Android emulator. Uninstall the previous generated host only if needed for storage/deterministic demo state. Do not read app-private data.

## Required Android proof

1. Cold launch Home.
2. Home current-state area visibly shows synthetic Readiness/Match/CN_NONE/CV_LOCKED.
3. Home primary action routes to Connection.
4. Request + simulated accept -> CN_ACTIVE.
5. Return Home: Connection summary now CN_ACTIVE, Conversation CV_LOCKED, primary action routes to Messages.
6. Complete messaging consent -> CV_ACTIVE.
7. Return Home: Conversation summary now CV_ACTIVE and primary action routes to Messages/list.
8. Return Connection and close -> CN_CLOSED.
9. Return Home: Connection CN_CLOSED, Conversation CV_LOCKED, primary action returns to Connection.
10. Return/remaining navigation works without crash.

PID/log:
- production EliteSync API = 0
- real WebSocket = 0
- RTC/LiveKit = 0
- fatal/crash = 0

## Bounded repair

At most two additional Flutter tracked files may be modified only for concrete analyzer/compiler/runtime blockers in this exact Home main-loop flow. No new lifecycle authority, backend/HTTP implementation, production auth/session change or dependency version change.

## Publication

Publish one immutable candidate only after final analyze/tests/build/install/runtime proof passes.

Candidate sole parent = task-publication authority.
Normal scope = 8 paths; max 10 with bounded repair.
Generated host/cache/APK/screenshots/logs are not committed.

Success classification:

APP-INT-05 COMPLETE — HOME CALM STATE HUB CONSUMES LIVE SYNTHETIC READINESS/MATCH/CONNECTION/CONVERSATION PRESENTATION — NEXT DECISION UPDATES THROUGH MAIN LOOP — CONNECTION INVALIDATION REFLECTED IMMEDIATELY — ANDROID MAIN-LOOP PROOF PASS — NO PRODUCTION API/SOCKET/RTC — READY FOR MAIN-LOOP PERSISTENCE + RECOVERY HARDENING

Candidate author cannot self-accept or move main. Then STOP.
