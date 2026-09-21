# EliteSync v10｜APP-RUN-01-R2 Windows C-Drive Android Build Recovery Task｜v0.1

Status: `OWNER-AUTHORIZED — FRESH C-DRIVE BUILD WORKTREE — PRESERVE PROVEN DEMO SOURCE — ISOLATE ASSEMBLE / INSTALL / LAUNCH — NO PRODUCT REDESIGN`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Previous APP-RUN-01 / R1 ended without any code candidate. Current remote main before this task publication is:

`8dd538253aa6dc806f154aa8a9c1afdca6afee1c`

This task supersedes the prior requirement that a successful runtime candidate keep the original `38cbf300...` sole parent. Because no runtime candidate was ever published, this task authorizes a fresh implementation candidate whose sole parent is this R2 task-publication authority.

## 1. Objective

Remove Windows cross-volume build ambiguity and separate Android compilation from installation/runtime.

The previous work established:

- locked Flutter dependencies materialized;
- analyzer had 0 errors;
- targeted tests passed;
- Gradle Plugin Portal marker is reachable;
- Gradle configuration/help resolves successfully with official repositories;
- `flutter run` reaches Android assemble;
- initial build showed Kotlin incremental cache roots spanning `C:` Pub cache and `D:` generated host;
- disabling Kotlin incremental removed that stack trace but assemble later hung without installation.

This task therefore:

1. creates a fresh Git worktree on `C:`, the same drive as Pub cache and the task-local Gradle cache;
2. copies only the already-proven APP-RUN-01 tracked edits from the old D-drive worktree;
3. regenerates all ignored Flutter/Android host state on C:;
4. runs Gradle `:app:assembleDebug` directly with verbose diagnostics and no daemon;
5. installs the resulting APK directly with ADB;
6. launches and interacts with the app on the already-running Android emulator.

Do not change app/domain architecture unless a directly observed compile/runtime error falls within the original bounded repair scope.

## 2. Fresh-base gate

Fresh-fetch `origin/main` and require the exact R2 task-publication authority from the execution prompt.

Read that authority's `AGENTS.md` first, then this task.

Create a new worktree on C: from the R2 task-publication authority.

Preferred root:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-run-01-r2-c-drive`

If that exact path already exists, choose a new sibling with a numeric suffix. Never delete/reuse an existing directory.

Recommended branch:

`impl/app-run-01-r2-c-drive-android-runtime-v0-1`

Do not modify or clean the prior D-drive worktree.

## 3. Exact source carry-forward from prior worktree

Source worktree:

`D:\EliteSync-v10-app-run-01-android-runtime-v0-1`

Copy exactly these five tracked files from the old worktree into the fresh C-drive worktree:

1. `apps/flutter_elitesync_module/lib/main_demo.dart`
   - required local Git blob: `3d983548fbb6e880e04c2c8ec9804523b9e4654c`
2. `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart`
   - required local Git blob: `8d85959ea355213820881015ea822eeebf1b6007`
3. `apps/flutter_elitesync_module/lib/app/app.dart`
   - required local Git blob: `400d7bdf243f4ae7d0e05cc135547d3951dba075`
4. `apps/flutter_elitesync_module/test/android_runtime_bootstrap_test.dart`
   - required local Git blob: `9fa5d2c186394565602c566a2f360ecc8184609e`
5. `docs/architecture/ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_RESULT_V0_1.md`
   - required local Git blob: `ee52777e4279a9f33f54475bb808406c5be629c4`

Before copy, use path-scoped local checks only. After copy, verify each file with `git hash-object <path>` equals the required blob.

If any source file/blob differs, STOP. Do not reconstruct from memory.

The old D-drive worktree remains untouched.

## 4. Fixed tracked repository inputs

At the R2 authority, verify unchanged:

- `AGENTS.md` blob `c9a8e192f7647a1613a195655fe9c22c56502ddb`
- `apps/flutter_elitesync_module/pubspec.yaml` blob `1b807ccdcced1e3166fd6e5378865ecb5bba4708`
- `apps/flutter_elitesync_module/pubspec.lock` blob `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`
- `apps/flutter_elitesync_module/.metadata` blob `cc507644250f1d2715da7323c3116ebf33ff31d8`
- `apps/flutter_elitesync_module/.gitignore` blob `5f448afb104bb897175df7373c8f6d835dd115bc`

No dependency/version update is authorized.

## 5. Clean C-drive generated state

From the fresh C-drive worktree:

1. run `flutter pub get --enforce-lockfile`;
2. require `pubspec.lock` to remain byte-identical;
3. let Flutter regenerate ignored `.dart_tool/`, `.android/`, `build/`, `.flutter-plugins-dependencies`.

Use a fresh C-drive task-local Gradle home:

`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-run-01-r2-gradle-home`

or a new suffixed sibling if it already exists.

Do not copy generated state from D:.

## 6. Generated Android host settings

The generated `.android/` host is temporary/ignored and may be adjusted only for build diagnosis.

Add to generated `.android/gradle.properties` before the direct assemble:

`kotlin.incremental=false`

`kotlin.compiler.execution.strategy=in-process`

`org.gradle.daemon=false`

These settings are process/build-stability scaffolding only and must never be committed.

If generated host/build output proves Android Gradle Plugin 9+ / built-in Kotlin migration flags are required, Flutter's official add-to-app guidance permits the generated host to additionally use:

`android.builtInKotlin=false`

`android.newDsl=false`

Only add those two when direct generated-host evidence shows they are relevant; do not assume or change AGP/Kotlin versions.

Do not use unofficial repositories or mirrors.

## 7. Tool/JVM/device

Use:

- installed Flutter already reported: 3.41.7;
- Dart 3.11.5;
- Java 17 already proven usable:
  `C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot\bin\java.exe`
  unless `flutter doctor -v` on this run explicitly selects a different already-installed compatible Java;
- current running Android emulator from `flutter devices`, expected `emulator-5554`.

No physical device.

No SDK/Flutter/Gradle/Kotlin/AGP/JDK upgrade or global configuration change.

## 8. Direct Android assemble diagnostic

Do not begin with `flutter run`.

From the C-drive module's generated `.android` directory, with task-local `GRADLE_USER_HOME`, run exactly:

`.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2`

Capture the last active Gradle task and relevant error if it fails/hangs.

Attempt budget:

- initial direct assemble: 1;
- one retry only after a directly justified generated-host/process-local correction;
- maximum direct assemble attempts: 2.

If the process produces no new output and no meaningful CPU/disk progress for a sustained period, collect non-sensitive process/task evidence and terminate rather than waiting indefinitely. Record the last Gradle task observed.

Do not use Gradle build scan upload.

## 9. Cross-drive decision

If direct assemble succeeds on C:, the prior D-drive condition is classified as a Windows/generated-host build-environment issue and no product source correction is needed.

If C-drive direct assemble still hangs, the task may inspect only the named failing/last-active generated Gradle/plugin task and standard process information. It may not expand into arbitrary machine forensics.

If a specific tracked Flutter source compile error appears, the original APP-RUN-01 bounded repair allowance remains: at most two extra tracked `lib/` or `test/` files, directly named by the compiler/runtime error, with no domain/authority/dependency-version change.

## 10. Install without rebuilding

After direct assemble PASS:

1. locate the generated debug APK under the generated host's normal `app/build/outputs/apk/debug/` output;
2. determine the generated host application ID / launcher activity from generated host config/manifest;
3. install with:
   `adb -s <EMULATOR_ID> install -r <EXACT_APK_PATH>`
4. start the launcher using the exact generated application/activity identity, or an equivalent package-targeted ADB launch that does not rebuild.

Do not invoke `flutter run` after a successful direct assemble unless direct ADB install/launch is impossible for a precisely recorded generated-host reason. If needed, one fallback `flutter run --debug --no-pub -t lib/main_demo.dart -d <EMULATOR_ID>` is authorized, but it counts as the single fallback runtime build attempt.

## 11. Runtime proof

Success requires direct observation of:

- installed package/app process;
- visible Flutter first frame;
- local synthetic/dev visual fixture, not production login;
- no observed request to production EliteSync API;
- no RTC invite polling;
- one visible user interaction (tap/scroll/back) that responds without crash.

Codex may directly operate Android Studio/emulator or use ADB for screen/input/log observation against the selected emulator only.

Do not inspect app-private files/data.

## 12. Validation carry-forward

Because the copied tracked demo source/test blobs are exact and were already analyzed/tested:

- do not rerun analyzer;
- do not rerun Flutter unit tests.

If this R2 task changes any tracked Dart source/test beyond the exact copied blobs under the bounded repair allowance, rerun:

`flutter analyze --no-pub`

and:

`flutter test --no-pub test/android_runtime_bootstrap_test.dart test/widget_test.dart`

once after the final tracked change. No confidence rerun.

## 13. Publication

On runtime success, update/finalize the same result document:

`docs/architecture/ELITESYNC_V10_APP_RUN_01_ANDROID_SYNTHETIC_RUNTIME_PROOF_RESULT_V0_1.md`

and publish one immutable candidate from the fresh C-drive branch.

Candidate sole parent must be the R2 task-publication authority supplied in the execution prompt.

Expected normal tracked scope remains exactly the five carried-forward APP-RUN-01 paths. Any extra tracked repair path must be explicitly justified and remains subject to the original maximum of two.

Do not commit generated `.android/`, `.dart_tool/`, `build/`, `.flutter-plugins-dependencies`, APKs, task-local Gradle cache or emulator artifacts.

Record:

- R2 authority/task blob;
- exact carry-forward blobs;
- C-drive worktree and Gradle home;
- lockfile result;
- generated host flags used;
- direct assemble attempts/result and last active task;
- APK path/size if built;
- install result;
- launch/activity result;
- first visible surface;
- direct interaction;
- production API/RTC observations;
- any bounded tracked repair;
- exact changed paths/blobs/candidate/tree.

Successful classification:

`APP-RUN-01 COMPLETE — C-DRIVE GENERATED ANDROID HOST ASSEMBLED — DEBUG APK INSTALLED — ANDROID EMULATOR FIRST FRAME + INTERACTION VERIFIED — LOCAL SYNTHETIC/DEV ENTRY ISOLATED FROM PRODUCTION API/RTC — READY FOR CLIENT INTEGRATION WORK`

If direct C-drive assemble remains blocked, do not publish a code candidate; return the exact last-active Gradle task/blocker and preserve both worktrees.

Then STOP.
