# EliteSync v10｜APP-INT-01 Synthetic App Shell Integration Result｜v0.1

Status: `COMPLETE — REAL FOUR-TAB APPSHELL VERIFIED ON ANDROID WITH SYNTHETIC LOCAL SESSION`

Date: 2026-09-21 (Asia/Shanghai).

## Authority and publication

- authority / candidate sole parent: `d9187c39a292319af5afc6d8525bdecbde5d0515`
- task blob: `a331d4d5a0360f0c0ee7b788db2adc501cd9cf61`
- `AGENTS.md` blob: `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- branch: `impl/app-int-01-synthetic-app-shell-v0-1`
- worktree: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-01-shell`
- candidate and tree: the immutable commit containing this result; exact hashes are reported in the publication receipt after commit and remote verification.

## Tracked implementation

The demo entry now starts at `/home` and seeds only an unmistakably synthetic local session before launching the existing application. The seed uses reserved profile ID `-13001`, synthetic phone/name values, normal user role, a token labelled `SYNTHETIC_DEMO` and `NOT_AUTHORITY`, no refresh token, and demo-only completed onboarding state.

The environment remains dev/synthetic with `apiBaseUrl=http://127.0.0.1:9/`, all existing mock providers enabled, and `useLiveKitRtc=false`. No real authentication, session authority, participant data, Connection writer, messaging consent, backend contract, or production entry was added.

Normal task files:

- `apps/flutter_elitesync_module/lib/main_demo.dart`
- `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`
- this result document

One bounded repair file was required:

- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`

The first runtime log showed `RTC_INVITE_PROVIDER_SCAN` every two seconds despite `useLiveKitRtc=false`. The AppShell watcher-enable provider previously returned unconditional `true`; it now reads `appEnvProvider.useLiveKitRtc`. The targeted bootstrap test fixes the synthetic false value as a regression assertion. No second bounded repair file was used.

## Tooling and static verification

- Flutter: `3.41.7` stable, framework revision `cc0734ac71`
- Dart: `3.11.5`
- dependency command: `flutter pub get --enforce-lockfile` — PASS
- `pubspec.lock` before/after blob: `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`
- dependency upgrade: none
- analyze command: `flutter analyze --no-pub`
- analyze executions: `2 / 2`; initial execution reported zero errors and 21 existing info/warning diagnostics, with no finding in the task files; the correction execution completed after the bounded repair without a new blocker
- targeted test command: `flutter test --no-pub test/android_runtime_bootstrap_test.dart test/widget_test.dart`
- targeted test executions: `2 / 2`; both executions passed `3 tests`, `0 failures`; the second execution includes the RTC watcher-disable regression assertion

## Android build, installation, and launch

- emulator: `sdk gphone64 x86 64`
- device ID: `emulator-5554`
- Android: 16 / API 36
- task-local `GRADLE_USER_HOME`: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-01-gradle-home`
- Java: Eclipse Adoptium JDK `17.0.18`

Generated `.android/gradle.properties`:

```properties
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart
```

Exact build command from generated `.android/`:

`\.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2`

Executions: `2 / 2`.

1. Initial tracked implementation: PASS, `BUILD SUCCESSFUL in 27m 39s`; 342 actionable tasks, 337 executed and 5 up-to-date.
2. After the bounded RTC watcher repair: PASS, `BUILD SUCCESSFUL in 47s`; 342 actionable tasks, 21 executed and 321 up-to-date.

APK: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-01-shell\apps\flutter_elitesync_module\build\host\outputs\apk\debug\app-debug.apk`.

Generated application ID and launcher:

- `com.elitesync.flutter_elitesync_module.host`
- `com.elitesync.flutter_elitesync_module.host.MainActivity`

The final APK install returned `Success`. A cold launch with the exact generated component returned `Status: ok`, `LaunchState: COLD`; final process PID was `7662`.

## Final Android interaction proof

All observations below were repeated after the bounded repair and final APK installation:

1. **Home** — real Home shell rendered with four bottom destinations `首页 / 进展 / 消息 / 我的`; current-state summary showed readiness and Connection as not established and Match/Conversation permissions as not established.
2. **Progress** — tapping `进展` opened the real Progress page with separate Match and Connection entries.
3. **Connection** — tapping Connection showed `连接状态尚未建立` and `NOT YET ESTABLISHED`; the page explicitly stated that no authoritative Product Connection snapshot or writer was connected.
4. **Match → Readiness** — after returning to Progress, tapping Match was intercepted by the existing guard and opened `Readiness · 准备状态`; it showed `准备状态尚未确定` and did not display a fabricated match.
5. **Messages** — tapping `消息` showed `消息权限尚未建立` and `NOT YET ESTABLISHED`; protected identity, previews, unread counts, and private thread details remained hidden.
6. **Me** — tapping `我的` opened the real purpose-separated Me landing page.
7. **Readiness** — tapping `Readiness · 准备状态` again showed `准备状态尚未确定`; readiness remained `UNKNOWN`.
8. **Return Home** — Android back returned to Me, then tapping Home returned to the same real Home summary.

The process remained PID `7662` throughout the final sequence and did not crash.

## Network and RTC observation

The final PID-scoped log contained 92 lines across launch and the complete interaction sequence:

- `RTC_INVITE_PROVIDER` build/start/scan lines: `0`
- production EliteSync API URL lines: `0`
- fatal/crash indicators: `0`
- HTTP URL lines: one, solely the Flutter debug VM service on `http://127.0.0.1:<ephemeral>/`

No production API request, LiveKit connection, RTC polling, private conversation content, or real-data access was observed.

Generated `.dart_tool/`, `.android/`, `build/`, `.flutter-plugins-dependencies`, APK, screenshots, UI dumps, PID logs, and the task-local Gradle cache are excluded from the candidate.

Remaining blocker: none within APP-INT-01.

## Final classification

`APP-INT-01 COMPLETE — REAL FOUR-TAB APPSHELL RUNNING ON ANDROID — SYNTHETIC SESSION BOOTSTRAP ACTIVE — HOME/PROGRESS/MESSAGES/ME INTERACTION VERIFIED — READINESS/MATCH/CONNECTION/CONVERSATION FAIL-CLOSED BOUNDARIES VISIBLE — NO PRODUCTION API/RTC — READY FOR READINESS + MATCH SYNTHETIC STATE INTEGRATION`
