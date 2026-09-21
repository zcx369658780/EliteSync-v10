# EliteSync v10｜APP-INT-04 Synthetic Messaging Consent + Conversation｜v0.1

Status: OWNER-AUTHORIZED — DEMO-ONLY MESSAGING CONSENT + LOCAL MOCK CONVERSATION — ANDROID READ/SEND PROOF — NO PRODUCTION CONVERSATION AUTHORITY
Date: 2026-09-21
Repository: zcx369658780/EliteSync-v10

Pre-task main:
1ce7470438f22b8daccac8242455fd6890b53801

APP-INT-03 is accepted. The demo can reach synthetic CN_ACTIVE, while Conversation correctly remains locked. This task adds an explicitly synthetic messaging-consent lifecycle and permits only local mock Conversation content after that second consent gate.

## Goal

Required Android flow:

synthetic CN_ACTIVE
-> CV_LOCKED
-> request messaging consent
-> CV_PENDING_CONSENT
-> simulate recipient accept
-> CV_ACTIVE
-> reveal local synthetic conversation list
-> open one local synthetic conversation
-> read local synthetic messages
-> send one local synthetic text message

Then make Connection non-active/closed and prove Conversation becomes locked again.

No production API, WebSocket, real participant/private data, real messaging consent, Conversation writer authority or deployment is created.

## Fresh execution

Fresh-fetch main and require the task-publication authority supplied in the execution prompt. Read AGENTS.md first, then this task.

Create a fresh C-drive worktree, e.g.:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-04-conversation

Recommended branch:
impl/app-int-04-synthetic-messaging-conversation-v0-1

Use the proven C-drive Android build recipe and a fresh task-local GRADLE_USER_HOME.

## Fixed inputs

Verify:
- AGENTS.md c9a8e192f7647a1613a195655fe9c22c56502ddb
- app_env.dart e2815fa1ae042fe05c41d39bc96326a82afc21f2
- main_demo.dart f2c48baf7bfaef207d02773d02cc1bbdeb8132bf
- product_connection_contract.dart 07b0beffb9033ea960a7c3c37daa453bc194bfeb
- connection_presentation_provider.dart 8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f
- product_conversation_contract.dart e64e5c74ebfd7a41338234487b0fc7126e1315f5
- conversation_access_state.dart f75ebffebcd8f361af654a4d9304e10b8c476d06
- conversation_access_gate.dart 8d927bac0f0e9de5fa2a8813d3e012139e189be8
- conversation_list_page.dart 6c1e4e9b3c103eecf8f3613853c14040a052a61f
- chat_remote_data_source.dart f8d526ca5c6af3294adc673e6ea50b5c4e2a9198
- chat_socket_data_source.dart afa90445767349b69c933cc37939266b200eeb31
- chat_mock.dart 907e125296eb6605ac1920f3726666161a35be2c
- chat_providers.dart 68788783eea53649056725b74f21d692fceda0a9
- chat_room_page.dart current authority path; read only unless bounded repair is required
- android_runtime_bootstrap_test.dart 5d049c102bcc7ae43b0bb4452e2581daa467d911
- pubspec.lock b56c4b2c45bab65106c12e4d75d6c5b34209aeb4

Do not access the old repository.

## Normal write set

Modify:
1. apps/flutter_elitesync_module/lib/app/config/app_env.dart
2. apps/flutter_elitesync_module/lib/main_demo.dart
3. apps/flutter_elitesync_module/lib/features/chat/domain/product_conversation_contract.dart
4. apps/flutter_elitesync_module/lib/features/chat/presentation/state/conversation_access_state.dart
5. apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart
6. apps/flutter_elitesync_module/lib/features/chat/presentation/pages/conversation_list_page.dart
7. apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_remote_data_source.dart
8. apps/flutter_elitesync_module/lib/mocks/mock_data/chat_mock.dart
9. apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart

Create:
10. apps/flutter_elitesync_module/test/synthetic_messaging_conversation_integration_test.dart
11. docs/architecture/ELITESYNC_V10_APP_INT_04_SYNTHETIC_MESSAGING_CONVERSATION_RESULT_V0_1.md

No Product Connection domain/provider modification is authorized.

## Demo gate

Add AppEnv.useSyntheticConversationLifecycle with default false. Only main_demo.dart enables it.

Synthetic Conversation is enabled only when env.isDev and that explicit flag is true.

Production/default behavior remains fail-closed.

## Synthetic access representation

In product_conversation_contract.dart, preserve ProductConversationContract.transitions and ProductConversationAccessAdapter logic.

Extend only the access representation so a local demo state can be distinguished from authoritative state:
- ConversationEvidenceAuthority adds syntheticDevelopment;
- add ConversationAccessSnapshot.syntheticDevelopment(state);
- add a synthetic predicate if useful.

canRevealPrivateContent/canSend may be true for syntheticDevelopment + CV_ACTIVE because the only content reachable in this mode is local mock data. They must remain false for synthetic locked/pending/paused/closed.

ProductConversationAccessAdapter must continue to emit only its existing authoritative/notYetEstablished outcomes. Do not make synthetic evidence satisfy its authoritative requirements.

ProductConversationAuthority.authoritativeActions remains empty.

## Synthetic messaging-consent controller

Replace the static conversationAccessProvider with a NotifierProvider that still exposes ConversationAccessSnapshot to existing consumers.

Controller watches:
- AppEnv;
- connectionPresentationProvider.

When demo flag is disabled:
- state = notYetEstablished;
- no local actions.

When demo flag is enabled:
- if synthetic Product Connection is not CN_ACTIVE, state = syntheticDevelopment(CV_LOCKED);
- if Connection is CN_ACTIVE, state may follow the local Conversation lifecycle.

Use ProductConversationContract.transitions for state/action lookup.

Local demo interpretation of transition prerequisites:
- requiresAuthoritativeActiveConnection means synthetic CN_ACTIVE is sufficient only for this local simulation;
- it does NOT create ProductConnectionEvidence.authoritative;
- acceptMessagingConsent simulates the second participant's messaging consent and sets local consent to mutual before entering CV_ACTIVE;
- resume requires synthetic CN_ACTIVE and retained local mutual consent.

Support:
- requestMessagingConsent
- acceptMessagingConsent
- declineMessagingConsent
- withdrawMessagingConsent
- pause
- resume
- close

Invalid action => no change.

A demo reset may return to CV_LOCKED and clear local consent; label it non-domain.

If Connection stops being CN_ACTIVE, immediately fail closed to synthetic CV_LOCKED and hide content.

## Consent UI

Keep ConversationAccessGate compatibility.

For syntheticDevelopment while not active:
- visibly label Synthetic Conversation · 开发演示;
- show exact CV_* code;
- explain this is local simulation, not production messaging consent;
- show only currently applicable synthetic actions;
- labels must distinguish request and simulated recipient accept/decline;
- private conversation content remains hidden until CV_ACTIVE.

ConversationListPage should pass controller transitions/actions into the gate.

When synthetic CV_ACTIVE, the existing protected Conversation UI may render local mock content.

## Local mock conversation data

Replace the visible old chat mock identities/text with unmistakably synthetic development data.

Use deterministic positive IDs compatible with existing DTO/route parsing, aligned with the Match demo identity where useful:
- synthetic peer: 990000201
- synthetic match: 990000101
- synthetic stored conversation: 990000301
- name must contain Synthetic Demo
- messages must explicitly be fake/demo text.

At least one mock conversation must include:
- entry_kind/stored conversation identity as needed by existing routing;
- conversation_id=990000301;
- peer_user_id=990000201;
- match_id=990000101.

Keep all mock content non-sensitive.

ChatRemoteDataSource useMock branches must return before ApiClient use.

For mock send to peer 990000201, return the same deterministic stored conversation_id 990000301 so sending from the stored conversation does not force an inconsistent route identity.

Do not change non-mock behavior.

ChatSocketDataSource already returns Stream.empty() when useMockChat=true; preserve that behavior.

## Tests

Extend android_runtime_bootstrap_test.dart to prove the new demo flag true.

Create synthetic_messaging_conversation_integration_test.dart.

At minimum prove:
1. default flag false / demo flag true;
2. without synthetic CN_ACTIVE, Conversation remains CV_LOCKED and cannot reveal/send;
3. after Connection request+accept => CN_ACTIVE, Conversation is still CV_LOCKED;
4. request messaging consent => CV_PENDING_CONSENT;
5. accept messaging consent => CV_ACTIVE;
6. synthetic CV_ACTIVE can reveal/send local mock content but is not authoritative;
7. ProductConversationAuthority.authoritativeActions remains empty;
8. ProductConversationAccessAdapter remains strict: notYet/insufficient authoritative evidence does not become active;
9. decline and withdraw from fresh pending return to locked;
10. pause/resume and close follow ProductConversationContract.transitions;
11. making Connection non-active after CV_ACTIVE re-locks Conversation;
12. mock conversation has expected synthetic IDs;
13. mock list/messages/send make zero ApiClient requests;
14. mock socket stream produces no network events.

Do not use real credentials/data.

## Validation

Run:
flutter pub get --enforce-lockfile
flutter analyze --no-pub
flutter test --no-pub test/android_runtime_bootstrap_test.dart test/synthetic_readiness_match_integration_test.dart test/synthetic_product_connection_lifecycle_test.dart test/synthetic_messaging_conversation_integration_test.dart test/widget_test.dart

Analyze/tests: initial plus max one correction rerun.

Use fresh C-drive task-local Gradle home. In the same PowerShell process explicitly set:
GRADLE_USER_HOME
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot
GRADLE_OPTS=-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2

Generated ignored flags:
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart

First run targeted dependency gate:
.\gradlew.bat :app:checkDebugAarMetadata --no-daemon --refresh-dependencies --stacktrace --info --console=plain --max-workers=2

Max 3 dependency-gate attempts for official TLS/cache warming only.

After PASS:
.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2

Max 2 assemble attempts.

Install fresh APK on the current Android emulator. Uninstall the previous generated synthetic host if needed for storage/deterministic local state. Do not read app-private data.

## Required Android proof

1. Home starts.
2. Progress -> Match still shows synthetic proposal.
3. Connection: request then simulated accept -> CN_ACTIVE.
4. Open Messages: show Synthetic Conversation · 开发演示 / CV_LOCKED; no conversation content.
5. request messaging consent -> CV_PENDING_CONSENT.
6. simulate recipient accept -> CV_ACTIVE.
7. conversation list now reveals only local synthetic conversation data.
8. open Synthetic Demo Partner conversation and show local synthetic messages.
9. send one plain-text synthetic message such as "Synthetic hello from APP-INT-04"; it must appear without production API or socket.
10. return to Connection and close or otherwise leave CN_ACTIVE.
11. return to Messages: Conversation must be locked again and private/mock content hidden.
12. return Home without crash.

PID/log requirements:
- production EliteSync API = 0
- WebSocket/real chat socket = 0
- RTC watcher/polling = 0
- fatal/crash = 0

## Bounded repair

At most two extra Flutter tracked files may be modified only for concrete analyzer/compiler/runtime blockers in this exact flow.

A discovered route bug in the send path may be repaired if it is triggered by the required synthetic send and the repair uses the canonical AppRouteNames.chatRoom path without changing Conversation authority.

No backend/HTTP implementation, no production auth/session change, no dependency-version change, no real data.

## Publication

Publish one immutable candidate only after final analyze/tests/build/install/runtime proof passes.

Candidate sole parent = task-publication authority.

Normal scope = 11 paths; max 13 with bounded repairs.

Generated host/caches/APK/screenshots/logs are not committed.

Success classification:

APP-INT-04 COMPLETE — SYNTHETIC CN_ACTIVE + INDEPENDENT MESSAGING CONSENT UNLOCK LOCAL MOCK CONVERSATION — SYNTHETIC LIST/READ/SEND VERIFIED ON ANDROID — CONNECTION INVALIDATION RELOCKS CONVERSATION — NO PRODUCTION API/SOCKET/RTC — READY FOR HOME LIVE-STATE + MAIN-LOOP INTEGRATION

Candidate author cannot self-accept or move main. Then STOP.
