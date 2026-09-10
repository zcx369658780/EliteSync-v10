# EliteSync v10｜Post-R7 Remaining A Materialization + Guest Identity Recheck Task v0.1

Status: `PUBLISHED TASK SHEET — REMAINING A MATERIALIZATION ONLY — NO B — NO FLUTTER-TOOLS PUB — NO M3 — NO AAR PROBE — NO M2`

## 1. Authority and goal

Current accepted main must be `a3c69b8e21cb7ddf458b15dfe20e100f00965449`.

A6 established fixed module identity by exact historical current-view match. The only remaining A work is to materialize the six already verified Owner-declared host sources into the preserved A1 Sandbox and recheck the required guest identities.

This task does not reopen source discovery, JDK capture, manifest research, B, M3, AAR, or M2.

## 2. FIRST and exact repository inputs

1. Fresh-fetch `main`; if not exactly `a3c69b8e21cb7ddf458b15dfe20e100f00965449`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read A4 result blob `8a0cfabfabe18172e7ca32b8b5d8731232465692` for Android/JDK/Git/Pub/Gradle host verification.
5. Read A6 result blob `e7c1a0173e5e5934bf598c7e7bb8f9e74ac3da56` for fixed module identity closure.

No repository-wide or directory-wide search. Do not inspect default index/protected staged state.

## 3. Fixed host sources

Only these exact host sources are authorized:

- Android SDK: `C:/Users/zcxve/AppData/Local/Android/Sdk`
- JDK: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
- Git: `C:/Program Files/Git`
- Pub cache: `C:/Users/zcxve/AppData/Local/Pub/Cache`
- Gradle cache: `D:/GradleHome`
- fixed module: `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

Host sources are read-only. Do not search alternatives.

## 4. Preserved Sandbox gate

Fresh `wsb --version` and `wsb list --raw`.

There must be exactly one running Sandbox with ID:
`0087a898-5221-41df-a33d-65045ffea69a`

If absent: `STOP — A1_SANDBOX_NO_LONGER_RUNNING`.
If not unique: `STOP — A1_SANDBOX_NOT_UNIQUELY_AVAILABLE`.

Do not create, stop, close, reset, or kill any Sandbox.

Recheck A1 substrate only as needed: SYSTEM, PowerShell 5.1, process/effective RemoteSigned, Security/system PATH, active adapter=0, default route=0, A1 evidence manifest identity, and Flutter Dart/pubspec/snapshot SHAs. Any drift => `STOP — A1_SUBSTRATE_IDENTITY_DRIFT`.

Do not redo Flutter materialization.

## 5. Host source preservation before materialization

Before sharing/copying, recheck only the already established fixed identities:

- JDK exact `bin/java.exe` SHA-256=`5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`; do not run another host `java -version`.
- Git exact `cmd/git.exe` SHA-256=`DA240FE9BC24895B3E04150A4990B8A6FF329ECABCD8F19684C2CC310DA5EF3F`; do not run another host `git --version` unless needed solely for drift detection and explicitly recorded.
- fixed module structure 527/301/3234145/0 and historical current-view TSV SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E` using the accepted A6 helper/contract.
- Android fixed objects from A4 must remain present at the same exact relative paths.
- Pub and Gradle roots must remain present.

If any established host identity drifts, STOP with the narrowest source-drift classification. Do not substitute another source.

## 6. Materialization

Only after all gates pass, materialize all six into guest-local writable destinations under the preserved Sandbox.

Preferred destinations:
- Android: `C:/M3A/tools/android`
- JDK: `C:/M3A/tools/jdk`
- Git: `C:/M3A/tools/git`
- Pub: `C:/M3A/cache/pub`
- Gradle: `C:/M3A/cache/gradle`
- module: `C:/M3A/work/apps/flutter_elitesync_module`

Use read-only host shares/source access and guest-local copy. Never allow guest writes back to host sources.

Record for each source:
- host path
- guest-visible source path/share
- guest destination
- copy/materialization method and exit result
- bounded file/byte counts where appropriate

No host source modification is allowed.

## 7. Guest identity rechecks

After materialization, in the same preserved Sandbox:

- JDK: guest `java.exe` SHA must equal host fixed SHA; run exactly one guest `java -version`, captured with native stdout/stderr redirection, and prove Temurin/OpenJDK `17.0.18+8`.
- Git: guest `git.exe` SHA must equal host fixed SHA; run exactly one guest `git --version` and prove `git version 2.53.0.windows.1`.
- fixed module: run the accepted R6-R4-R2 current-view helper/contract and require 527 files, 301 dirs, 3234145 bytes, reparse=0, TSV Length=69676, SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`.
- Android: recheck the fixed relative objects copied into guest and their recorded SHA-256 values from A4.
- Pub cache: guest root must exist and materialization must complete; do not inspect coverage/code_builder.
- Gradle cache: guest root must exist and materialization must complete; do not run Gradle resolution.

## 8. Success condition

Only if all six materializations and all required guest identity rechecks pass, conclude exactly:

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

This still does not authorize B.

## 9. Boundaries

Do not run Flutter-tools Dart pub, `flutter pub get`, module Dart pub, coverage/code_builder diagnosis, Gradle dependency resolution, M3, direct snapshot M3, AAR probe, M2, network/download/install, or product implementation.

Do not modify host SDK/cache/source, Sandbox Flutter source/pubspec/snapshot/package context, or unrelated repository state.

## 10. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_REMAINING_A_MATERIALIZATION_AND_GUEST_IDENTITY_RECHECK_RESULT_V0_1.md`

Record all six materializations, guest identity rechecks, Sandbox final state, host-write status, and all NOT_RUN items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept, update `main`, or execute B.