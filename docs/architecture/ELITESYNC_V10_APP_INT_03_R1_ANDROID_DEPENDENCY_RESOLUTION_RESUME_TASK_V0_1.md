# EliteSync v10｜APP-INT-03-R1 Android Dependency Resolution Resume｜v0.1

Status: OWNER-AUTHORIZED — PRESERVE APP-INT-03 SOURCE — TARGETED GRADLE DEPENDENCY RECOVERY — RESUME ANDROID RUNTIME

Date: 2026-09-21
Repository: zcx369658780/EliteSync-v10

Original APP-INT-03 execution authority:
69f29f9d31ec09d120c08c01860cf267b7de6291

Existing worktree:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-03-connection

Existing branch:
impl/app-int-03-synthetic-product-connection-v0-1

Existing branch HEAD must remain:
69f29f9d31ec09d120c08c01860cf267b7de6291

Prior state:
- no candidate published;
- flutter pub get PASS;
- flutter analyze final 0 errors;
- targeted tests 9/9 PASS;
- two assemble attempts exhausted;
- attempt 1 failed only on Google Maven TLS while resolving androidx.preference:preference:1.2.1 and androidx.fragment:fragment:1.7.1;
- attempt 2 used a new PowerShell process that did not inherit the task-local GRADLE_USER_HOME and therefore failed in plugin resolution;
- eight tracked implementation files remain uncommitted and preserved.

## 1. Goal

Resume the same APP-INT-03 implementation without changing its product semantics.

First make dependency resolution deterministic in one explicitly configured process. Only after the targeted dependency gate passes may full assemble resume.

Do not rewrite the Product Connection implementation and do not rerun already-green Flutter analyze/tests unless tracked Dart source/test changes.

## 2. Fresh remote gate

Fresh-fetch origin/main and require the exact task-publication authority supplied in the execution prompt.

Read AGENTS.md first, then this task.

This task-publication commit is an explicitly allowed document-only main movement.

Continue in the existing worktree. Do not rebase, reset, restore, clean, stash, merge or recreate it.

Candidate, if eventually published, keeps sole parent:
69f29f9d31ec09d120c08c01860cf267b7de6291

## 3. Preserve exact implementation

Require these existing local blobs before doing runtime work:

- app_env.dart e2815fa1ae042fe05c41d39bc96326a82afc21f2
- main_demo.dart f2c48baf7bfaef207d02773d02cc1bbdeb8132bf
- connection_presentation_state.dart 9d34d6ba722b1b75178975cf0a4e4b6c28314232
- connection_presentation_provider.dart 8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f
- connection_page.dart df83c4893f76b2b0413d64304edb5d69b165ff35
- connection_authority_panel.dart 619f6b8b8d15e3624c047dbd6e5541d2171355a2
- android_runtime_bootstrap_test.dart 5d049c102bcc7ae43b0bb4452e2581daa467d911
- synthetic_product_connection_lifecycle_test.dart 9eb72b360683af49f3daec8284b4338712c7293f

pubspec.lock must remain:
b56c4b2c45bab65106c12e4d75d6c5b34209aeb4

If any tracked implementation blob differs, STOP.

## 4. Process-local environment

Reuse or create a task-local Gradle home on C:, but do not touch the global Gradle cache/config.

Recommended:
C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-03-r1-gradle-home

In the SAME PowerShell process that launches Gradle, explicitly set:

$env:GRADLE_USER_HOME='<exact task-local path>'
$env:JAVA_HOME='C:\Program Files\Eclipse Adoptium\jdk-17.0.18.8-hotspot'
$env:GRADLE_OPTS='-Dhttps.protocols=TLSv1.2 -Djdk.tls.client.protocols=TLSv1.2'

Then verify the child process sees the intended Gradle home by printing only the non-sensitive path/value needed for this task.

Do not print proxy credentials or unrelated environment variables.

Generated .android/gradle.properties may keep:
kotlin.incremental=false
kotlin.compiler.execution.strategy=in-process
org.gradle.daemon=false
target=lib/main_demo.dart

No dependency, Gradle, AGP, Kotlin, JDK, SDK or Flutter version change.

## 5. Exact official endpoint checks

Before Gradle retry, HEAD-check these exact official Google Maven artifacts:

https://dl.google.com/dl/android/maven2/androidx/preference/preference/1.2.1/preference-1.2.1.pom
https://dl.google.com/dl/android/maven2/androidx/fragment/fragment/1.7.1/fragment-1.7.1.pom

Also recheck the known Gradle Plugin Portal marker only if plugin resolution is again implicated.

Official repositories only. No unofficial mirror.

A transient HEAD failure may be retried once per endpoint.

## 6. Targeted Gradle dependency gate

From generated .android, in the same process-local environment, run:

.\gradlew.bat :app:checkDebugAarMetadata --no-daemon --refresh-dependencies --stacktrace --info --console=plain --max-workers=2

Maximum targeted dependency-gate executions: 3.

A retry is allowed only for:
- TLS/connection termination against an official repository;
- task-local cache warming;
- directly justified generated-host/process-local correction.

Do not edit tracked product code to fix repository connectivity.

If the targeted gate does not PASS within budget, STOP and return the exact artifact/endpoint/error.

## 7. Full assemble resume

Only after Section 6 PASS, run:

.\gradlew.bat :app:assembleDebug --no-daemon --stacktrace --info --console=plain --max-workers=2

Maximum assemble executions in this R1 task: 2.

Use the same process-local GRADLE_USER_HOME/JAVA_HOME/GRADLE_OPTS.

If assemble fails due a new specific tracked Dart/Flutter compile error, the original APP-INT-03 bounded repair allowance remains available: at most two extra tracked Flutter files total, only for this Connection flow and with no authority/dependency change.

If no tracked source/test changes, do not rerun analyzer or Flutter tests.

If tracked source/test changes, rerun the original APP-INT-03 exact analyze/test commands once after final edit.

## 8. Install and runtime proof

After assemble PASS:

- install the generated debug APK on emulator-5554 (or the currently reported Android emulator if the ID changed);
- cold launch the generated host;
- do not read app-private data.

Repeat the original APP-INT-03 interaction proof:

1. Home starts;
2. Progress -> Match still shows synthetic proposal;
3. Connection shows Synthetic Connection · 开发演示 / CN_NONE;
4. request -> CN_PENDING;
5. simulated recipient accept -> CN_ACTIVE;
6. Messages still NOT YET ESTABLISHED with private content hidden;
7. Connection pause -> CN_PAUSED;
8. resume -> CN_ACTIVE;
9. close -> CN_CLOSED;
10. return Home without crash.

Log requirements:
- production EliteSync API = 0
- RTC watcher/polling = 0
- fatal/crash = 0

## 9. Publication

On success, create/finalize:
docs/architecture/ELITESYNC_V10_APP_INT_03_SYNTHETIC_PRODUCT_CONNECTION_LIFECYCLE_RESULT_V0_1.md

Publish one immutable candidate with sole parent 69f29f9d31ec09d120c08c01860cf267b7de6291.

Normal tracked candidate scope:
- the existing eight implementation/test files
- the result document

Generated .android/.dart_tool/build/APK/cache/log/screenshot artifacts are not committed.

Candidate author cannot self-accept or move main.

Success classification:

APP-INT-03 COMPLETE — PRODUCT CONNECTION CONTRACT DRIVES LOCAL SYNTHETIC LIFECYCLE — CN_NONE/PENDING/ACTIVE/PAUSED/CLOSED INTERACTION VERIFIED — TERMINAL REQUEST OUTCOMES TESTED — CONVERSATION REMAINS LOCKED — ANDROID DEPENDENCY RESOLUTION RECOVERED — NO PRODUCTION API/RTC — READY FOR SYNTHETIC MESSAGING CONSENT + CONVERSATION INTEGRATION

Then STOP.
