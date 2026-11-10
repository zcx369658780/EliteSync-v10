# EliteSync v10｜APP-INT-04 Synthetic Messaging Consent + Conversation Result｜v0.1

Status: COMPLETE — IMMUTABLE CANDIDATE PUBLISHED FOR INDEPENDENT REVIEW

Date: 2026-09-21
Repository: `zcx369658780/EliteSync-v10`

## 1. Authority and scope

- Authority and candidate sole parent: `4d0910369580d63503426c7bc80cb1d790c33fbb`
- `AGENTS.md` blob: `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- Task: `docs/architecture/ELITESYNC_V10_APP_INT_04_SYNTHETIC_MESSAGING_CONVERSATION_TASK_V0_1.md`
- Task blob: `728b7ea063362a393c04cdfcd9fc06e3ad61d16c`
- Branch: `impl/app-int-04-synthetic-messaging-conversation-v0-1`
- Worktree: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-04-conversation`

This delivery adds only a demo-local messaging-consent lifecycle and local synthetic Conversation content. It does not establish production Conversation authority, production API, WebSocket, RTC, real participant data, or private data access.

## 2. Synthetic messaging-consent implementation

- `AppEnv.useSyntheticConversationLifecycle` defaults to `false`; only `main_demo.dart` enables it.
- Synthetic Conversation requires both `env.isDev` and the explicit synthetic flag.
- `ConversationEvidenceAuthority.syntheticDevelopment` and `ConversationAccessSnapshot.syntheticDevelopment(...)` distinguish the local demo from authoritative evidence.
- `ProductConversationContract.transitions` was preserved and drives all local lifecycle actions.
- `ProductConversationAccessAdapter` remains strict and continues to emit only its existing authoritative or not-established outcomes.
- `ProductConversationAuthority.authoritativeActions` remains empty.
- The notifier watches the environment and Product Connection presentation. If synthetic Connection is not `CN_ACTIVE`, it immediately returns to `CV_LOCKED`, clears local consent, and hides Conversation content.
- Supported local actions are request, simulated accept/decline, withdraw, pause, resume, close, plus a separately labelled non-domain reset.

Observed lifecycle:

```text
CN_ACTIVE
-> CV_LOCKED
-> requestMessagingConsent
-> CV_PENDING_CONSENT
-> acceptMessagingConsent
-> CV_ACTIVE
```

Leaving `CN_ACTIVE` produced:

```text
CN_CLOSED -> CV_LOCKED
```

## 3. Local mock data and isolation

The visible mock identities and content are deterministic synthetic development data:

- peer user: `990000201`
- match: `990000101`
- stored conversation: `990000301`
- visible peer name: `Synthetic Demo Partner`
- visible messages explicitly identify themselves as synthetic development fake messages.

Mock conversation list, detail/messages, and plain-text send return locally before `ApiClient` use. Sending to peer `990000201` returns stored conversation `990000301`. The existing mock socket branch remains `Stream.empty()`.

Production/default access stays fail-closed. Synthetic content is visible only while the local presentation authority is `syntheticDevelopment` and the local state is `CV_ACTIVE`.

## 4. Flutter validation

Toolchain:

- Flutter `3.41.7`, stable, framework revision `cc0734ac71`.
- Dart `3.11.5`.

Dependency materialization:

```text
flutter pub get --enforce-lockfile
```

- Result: PASS.
- `pubspec.lock` remained `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`.

Analyze:

```text
flutter analyze --no-pub
```

- Attempts: 2/2.
- Attempt 1 exposed 25 compile errors in two existing Chat widget tests that still used the former provider override API, plus 18 existing lint findings.
- The two authorized bounded repair files were updated only to use the notifier provider override API without changing test authority or semantics.
- Attempt 2: 0 errors; one existing warning and 17 existing info findings remained. The command exit code was 1 solely because of that existing lint baseline.
- No further analyze execution was made.

Targeted tests:

```text
flutter test --no-pub test/android_runtime_bootstrap_test.dart test/synthetic_readiness_match_integration_test.dart test/synthetic_product_connection_lifecycle_test.dart test/synthetic_messaging_conversation_integration_test.dart test/widget_test.dart
```

- Attempts: 1/2.
- Result: 15/15 PASS.
- Coverage includes the default/demo flag, Connection prerequisite, independent consent, pending terminal branches, pause/resume/close, strict production adapter, empty authoritative actions, deterministic mock IDs, zero `ApiClient` calls, empty mock socket stream, and Connection invalidation re-lock.

## 5. Android dependency gate and assemble

The same PowerShell process used:

- `GRADLE_USER_HOME=C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-04-gradle-home`
- `JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot`
- `GRADLE_OPTS=-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2`

Generated `.android/gradle.properties` contained only the authorized host settings:

```properties
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart
```

Dependency gate:

```text
.\gradlew.bat :app:checkDebugAarMetadata --no-daemon --refresh-dependencies --stacktrace --info --console=plain --max-workers=2
```

- Attempts: 1/3.
- Result: PASS, `BUILD SUCCESSFUL in 30m 46s`.
- Receipt: 22 actionable tasks; 18 executed and 4 up-to-date.

Assemble:

```text
.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2
```

- Attempts: 1/2.
- Result: PASS, `BUILD SUCCESSFUL in 5m 29s`.
- Receipt: 342 actionable tasks; 320 executed and 22 up-to-date.
- Missing NDK strip tools produced non-fatal debug packaging notices; Gradle packaged the native libraries unchanged and produced the APK.

## 6. APK install and cold launch

- Emulator: `sdk_gphone64_x86_64`.
- Device ID: `emulator-5554`.
- Android API: 36.
- APK: `apps/flutter_elitesync_module/build/host/outputs/apk/debug/app-debug.apk`.
- APK size: 1,380,319,323 bytes.
- Application ID: `com.elitesync.flutter_elitesync_module.host`.
- Launcher: `com.elitesync.flutter_elitesync_module.host/.MainActivity`.
- Previous synthetic host was uninstalled for deterministic local state; streamed install returned `Success`.
- Cold launch returned `Status: ok`, `LaunchState: COLD`, `TotalTime: 2556 ms`.
- Runtime PID: `12180`; it remained alive after the complete interaction.

No app-private data was read.

## 7. Android interaction proof

The emulator was operated through the full required flow:

1. Home rendered the real four-tab AppShell.
2. Progress -> Match displayed `Synthetic Demo Partner 990000201` and `Synthetic candidate proposal · 开发演示假数据`.
3. Connection showed `Synthetic Connection · 开发演示 / CN_NONE`.
4. `本地演示：请求连接` changed the visible state to `CN_PENDING`.
5. `本地演示：模拟对方接受` changed it to `CN_ACTIVE`.
6. Messages showed `Synthetic Conversation · 开发演示 / CV_LOCKED`; no conversation identity, preview, unread count, or thread content was visible.
7. `本地演示：请求消息同意` changed it to `CV_PENDING_CONSENT`; content remained hidden.
8. `本地演示：模拟对方接受` changed it to `CV_ACTIVE` and revealed the local list.
9. The list showed only `Synthetic Demo Partner` with a synthetic development message summary.
10. Opening the item showed two local messages explicitly labelled as synthetic development fake messages.
11. Entering and sending `Synthetic hello from APP-INT-04` displayed that exact text on the page.
12. Returning to Connection and selecting close changed Connection to `CN_CLOSED`.
13. Returning to Messages showed `CV_LOCKED` again; the peer identity, list, preview, unread count, messages, and sent text were hidden.
14. Returning Home succeeded and the process remained alive without crash.

## 8. PID-scoped runtime observation

Logcat was cleared before cold launch and inspected for PID `12180` after the full interaction. The PID-scoped receipt contained 217 lines.

- Production EliteSync API observations: 0.
- Real WebSocket/chat socket observations: 0.
- LiveKit/RTC watcher/polling observations: 0.
- Fatal exception/crash/fatal signal observations: 0.
- The only URL was the local Dart VM service on `http://127.0.0.1:43813/...`.

## 9. Bounded repair and boundaries

The full two-file bounded repair allowance was used:

- `apps/flutter_elitesync_module/test/features/chat/presentation/pages/chat_room_page_test.dart`
- `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart`

Both changes only replace the former static provider override with the notifier provider build override. No route repair was needed, and `chat_room_page.dart` was not modified.

No backend, HTTP implementation, production authentication/session, Product Connection domain/provider, dependency version, production main entry, real data, real messaging consent, or Conversation writer authority was added. Generated `.android/`, `.dart_tool/`, `build/`, APK, task-local Gradle cache, logs, UI dumps, and screenshots are excluded from the candidate.

This result does not self-accept the candidate or move `main`.

## Final classification

`APP-INT-04 COMPLETE — SYNTHETIC CN_ACTIVE + INDEPENDENT MESSAGING CONSENT UNLOCK LOCAL MOCK CONVERSATION — SYNTHETIC LIST/READ/SEND VERIFIED ON ANDROID — CONNECTION INVALIDATION RELOCKS CONVERSATION — NO PRODUCTION API/SOCKET/RTC — READY FOR HOME LIVE-STATE + MAIN-LOOP INTEGRATION`
