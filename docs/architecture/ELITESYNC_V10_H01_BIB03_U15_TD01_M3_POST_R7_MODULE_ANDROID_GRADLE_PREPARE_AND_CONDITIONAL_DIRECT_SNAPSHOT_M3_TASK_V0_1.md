# EliteSync v10｜Post-R7 Module Android Gradle Prepare + Conditional Direct-Snapshot M3 Task v0.1

Status: `PUBLISHED TASK SHEET — MODULE EPHEMERAL ANDROID PREPARE ONLY — CONDITIONAL M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `09bcb564b5f297a1ed8195f0cb58233604907afa`.

Accepted B2 facts: Flutter-tools offline package context is established; `coverage 1.15.0` and `code_builder 4.11.1` resolve locally; snapshot SHA remains `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`; the unique direct-snapshot `build aar --no-pub` reached Gradle and failed only because module `.android` did not contain a Gradle build.

This task may prepare the module's guest-local ephemeral `.android` only through one Flutter-tools module-level offline pub action, then conditionally run one direct-snapshot M3. No host source modification and no M2.

## 2. Exact inputs

Fresh-fetch main; read FIRST blob `18485c95262051e43892436fb52413132c5ee626`; read this task and accepted B2 result blob `071b8b5cab38c6dc9121d3e4bf36d469f0010849`.

Preserved Sandbox must remain uniquely `0087a898-5221-41df-a33d-65045ffea69a`.

Guest fixed paths:
- Flutter root `C:/M3A/tools/flutter`
- Dart `C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`
- Flutter-tools package config `C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`
- snapshot `C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`
- module `C:/M3A/work/apps/flutter_elitesync_module`
- Pub cache `C:/M3A/cache/pub`
- Android `C:/M3A/tools/android`
- JDK `C:/M3A/tools/jdk`
- Git `C:/M3A/tools/git`
- Gradle home `C:/M3A/cache/gradle`

## 3. Pre-gates

Recheck minimal A/B2 substrate: SYSTEM, PowerShell 5.1, RemoteSigned, adapter=0, route=0, exact Dart/pubspec/snapshot SHA, package_config exists and still maps coverage 1.15.0 + code_builder 4.11.1 to local Pub cache.

Before any prepare action, check only these fixed `.android` Gradle sentinels under the guest module:
- `.android/settings.gradle`
- `.android/settings.gradle.kts`
- `.android/build.gradle`
- `.android/build.gradle.kts`

Do not enumerate `.android` broadly. Record presence/absence.

If a valid settings/build sentinel already exists, do not run module pub; proceed to conditional M3.

## 4. Single module-level offline Flutter-tools pub prepare

Only if no fixed Gradle sentinel exists, authorize exactly one direct Flutter-tools module pub invocation using Dart + existing package_config + snapshot, equivalent to:

`dart --packages=<flutter_tools_package_config> <flutter_tools_snapshot> --no-version-check pub get --offline`

CWD must be the guest module root.

Environment must point only to guest-local copies, including `PUB_CACHE=C:/M3A/cache/pub`, Android SDK, JDK, Git and Gradle home. No host source writes.

Record exact executable, args, cwd, environment roots, start/end/duration, stdout/stderr, exit. No retry.

Any genuine URL/socket/DNS/connection failure diagnostic => `MODULE_OFFLINE_FLUTTER_PUB_NETWORK_ATTEMPT` and STOP.

Nonzero without genuine network diagnostic => `MODULE_OFFLINE_FLUTTER_PUB_FAILED` and STOP.

After exit 0, recheck only the four fixed Gradle sentinels above. If none exists => `MODULE_DOT_ANDROID_GRADLE_BUILD_STILL_NOT_PRESENT_AFTER_OFFLINE_PUB` and STOP.

Do not run `flutter create`, `gradlew init`, manual file creation, template copying, or alternate source restore in this task.

## 5. Conditional unique direct-snapshot M3

Only when a fixed `.android` Gradle sentinel is present, run exactly one direct-snapshot M3:

`dart --packages=<flutter_tools_package_config> <flutter_tools_snapshot> --no-version-check build aar --no-debug --no-profile --no-pub`

CWD = guest module root. Use only guest-local SDK/cache/tool roots. No retry.

Record exact process evidence and narrowest failure classification. Static documentation URLs are not network attempts; classify network only from genuine connection/socket/DNS failure evidence.

If M3 starts, perform exactly one probe of:

`C:/M3A/work/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

No alternate path search.

Success requires M3 exit=0 and exact AAR HIT, then classify exactly:

`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`

M2 remains NOT_RUN.

## 6. Boundaries and result

Do not modify host SDK/cache/module source. Do not run network fill/download/install, separately invoked Gradle resolution, `flutter create`, manual `.android` repair, M2, or product implementation. Do not inspect default index/protected staged state or run default `git status`.

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_ANDROID_GRADLE_PREPARE_AND_CONDITIONAL_DIRECT_SNAPSHOT_M3_RESULT_V0_1.md`

Candidate sole parent must be this task commit. Then STOP; do not self-accept or update main.