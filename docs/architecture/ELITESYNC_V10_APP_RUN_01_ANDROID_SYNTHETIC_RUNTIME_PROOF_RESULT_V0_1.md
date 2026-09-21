# EliteSync v10｜APP-RUN-01 Android Synthetic Runtime Proof Result｜v0.1

Status: `COMPLETE — C-DRIVE GENERATED ANDROID HOST ASSEMBLED — DEBUG APK INSTALLED — ANDROID EMULATOR FIRST FRAME + INTERACTION VERIFIED`

Date: 2026-09-21 (Asia/Shanghai).

## Authority and publication

- R2 authority / candidate sole parent: `6b7cef6d2a002db08f26c6c4c97a397c477d409c`
- R2 task blob: `4ebd674a465704ce7317dd35656b93708c708984`
- branch: `impl/app-run-01-r2-c-drive-android-runtime-v0-1`
- worktree: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-run-01-r2-c-drive`
- candidate and tree: the immutable commit containing this result; exact hashes are reported in the publication receipt after commit and remote verification.

The prior D-drive worktree was neither modified nor cleaned. This R2 execution used the five required uncommitted files from that worktree as its only carry-forward source.

## Exact tracked scope and carry-forward receipt

The local Git blobs matched before copy and again after copy:

| Path | Authority blob | Carried-forward blob |
|---|---|---|
| `apps/flutter_elitesync_module/lib/main_demo.dart` | absent | `3d983548fbb6e880e04c2c8ec9804523b9e4654c` |
| `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart` | `bc74a0dd5bac9515d9c3a565602b4dc0b915d654` | `8d85959ea355213820881015ea822eeebf1b6007` |
| `apps/flutter_elitesync_module/lib/app/app.dart` | `2a07c20f2c484e3609c64a5e7f64baa3cbe53014` | `400d7bdf243f4ae7d0e05cc135547d3951dba075` |
| `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart` | absent | `9fa5d2c186394565602c566a2f360ecc8184609e` |
| `docs/architecture/ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_RESULT_V0_1.md` | absent | finalized by this R2 execution |

No bounded tracked repair was used. No tracked Dart source or test changed after exact carry-forward, so analyzer and Flutter unit tests were not repeated, as required by the R2 task.

## Dependency and generated-host receipt

Command: `flutter pub get --enforce-lockfile`

- result: PASS, exit 0;
- `pubspec.lock` before and after blob: `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`;
- dependency upgrade: none;
- generated state was created fresh on C: and not copied from D:.

Task-local `GRADLE_USER_HOME`:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-run-01-r2-gradle-home`

Generated `.android/gradle.properties` flags used:

```properties
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart
```

The first three are the task-required build-stability settings. The generated-host `target` correction was added after attempt 1 explicitly showed `-dTargetFile=lib/main.dart`; attempt 2's depfile includes `lib/main_demo.dart`. Java/JBR used was the installed Java 17 at `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe`. Attempt 2 additionally used process-local `GRADLE_OPTS=-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2`. No global cache/configuration or dependency version was changed, and no unofficial mirror was used.

Generated ignored state included `.dart_tool/`, `.android/`, `build/`, `.flutter-plugins-dependencies`, the APK, and the task-local Gradle cache. None is part of the candidate.

## Direct Android assemble

Exact command, run from generated `.android/`:

`.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2`

Executions: `2 / 2`.

1. Attempt 1: FAIL at `:app:checkDebugAarMetadata`. Download of the official Google Maven artifact `androidx.lifecycle:lifecycle-common:2.7.0` ended in a TLS handshake termination. The build ended after 14m 29s with 160 actionable tasks: 155 executed and 5 up-to-date. A subsequent exact artifact endpoint HEAD check returned HTTP 200.
2. Attempt 2: PASS, `BUILD SUCCESSFUL in 3m 38s`, 342 actionable tasks: 187 executed and 155 up-to-date. Last active and terminal Gradle task: `:app:assembleDebug`.

The C-drive assemble success classifies the prior D-drive condition as a Windows/generated-host build-environment issue. No product source correction was needed.

## APK, installation, and launch

- APK: `C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-run-01-r2-c-drive\apps\flutter_elitesync_module\build\host\outputs\apk\debug\app-debug.apk`
- APK size: `1,380,302,167 bytes`.
- generated application ID: `com.elitesync.flutter_elitesync_module.host`.
- generated launcher activity: `com.elitesync.flutter_elitesync_module.host.MainActivity`.
- emulator: `sdk gphone64 x86 64`, device ID `emulator-5554`, Android 16 / API 36, ABI `x86_64`.

The first `adb -s emulator-5554 install -r <APK>` returned `INSTALL_FAILED_INSUFFICIENT_STORAGE`. The existing package with the same generated-host application ID was confirmed and uninstalled; emulator `/data` free space rose from 2.7G to 4.1G. Repeating the same install command then returned success. No app-private data was read.

Launch command:

`adb -s emulator-5554 shell am start -n com.elitesync.flutter_elitesync_module.host/com.elitesync.flutter_elitesync_module.host.MainActivity`

Launch succeeded and the application process PID was `6392`.

## Runtime proof

The directly observed Flutter first frame displayed:

- `8.1 本地视觉预览`;
- `本地视觉预览 · DEBUG ONLY`;
- `local-only`;
- `dev/internal`;
- `deterministic sample data`;
- an explicit statement that the page does not call the backend, read an account, or run message persistence.

This was the local synthetic/dev fixture and not the production login flow.

One real emulator interaction was performed:

`adb -s emulator-5554 shell input swipe 720 2500 720 700 650`

The UI visibly scrolled to Bazi / Ziwei fixture content, PID remained `6392`, and no crash occurred. A Flutter debug `BOTTOM OVERFLOWED BY 31 PIXELS` indicator was visible before and after scrolling. It did not block the first frame or interaction; it is recorded as a presentation limitation and was not changed because the R2 bounded repair rule permits tracked changes only for a concrete compile error.

The synthetic configuration used `apiBaseUrl=http://127.0.0.1:9/`, `useMockData=true`, `useLiveKitRtc=false`, with mock auth/home/match/chat/profile/admin enabled. PID-scoped log observation found no production EliteSync API, LiveKit, RTC, Android fatal exception, or crash request/error. The only URL match was the local Dart VM service on `127.0.0.1`.

No real account, credential, token, private participant/Conversation data, production API, LiveKit/RTC session, backend implementation, deployment, or store publication was used.

## Final classification

`APP-RUN-01 COMPLETE — C-DRIVE GENERATED ANDROID HOST ASSEMBLED — DEBUG APK INSTALLED — ANDROID EMULATOR FIRST FRAME + INTERACTION VERIFIED — LOCAL SYNTHETIC/DEV ENTRY ISOLATED FROM PRODUCTION API/RTC — READY FOR CLIENT INTEGRATION WORK`
