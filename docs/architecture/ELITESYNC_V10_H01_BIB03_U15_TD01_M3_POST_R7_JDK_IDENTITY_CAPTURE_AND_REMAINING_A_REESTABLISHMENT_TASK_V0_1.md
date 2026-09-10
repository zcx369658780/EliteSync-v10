# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 JDK Identity Capture + Remaining A Re-establishment Task v0.1

Status: `PUBLISHED TASK SHEET — JDK IDENTITY CAPTURE REPAIR + REMAINING A ONLY — NO B — NO M3 — NO AAR PROBE — NO M2`

## 1. Authority and purpose

Repository: `zcx369658780/EliteSync-v10`.

Required main: `d36170669bd25d33d5e336ba7e34d2cadb15b69d`.

FIRST blob: `18485c95262051e43892436fb52413132c5ee626`.

Read this task and the accepted A3 result at exact path/blob. Do not enumerate the repository.

A3 established `JDK_SOURCE_IDENTITY_NOT_PROVEN`, not a JDK mismatch. The same host JDK source remains fixed at `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`; `java.exe` SHA-256 remains expected as `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`. A3 failed because PowerShell 5.1 promoted normal `java -version` stderr output to `NativeCommandError` before the recorder captured the complete build string.

This A4 authorizes one new exactly-once JDK identity capture using a process invocation that records stdout and stderr as process streams without PowerShell native-error promotion. The goal is to prove or disprove compatibility with `Temurin/OpenJDK 17.0.18+8`.

If JDK identity is proven, continue the unexecuted remainder of A3 in the same task: Git, Pub cache, Gradle cache, fixed module verification, Android re-verification as needed, then materialize all six declared fixed inputs into the preserved Sandbox and recheck guest identities. Do not split another equivalent task unless a new hard stop occurs.

## 2. Fixed Owner sources

Only these host sources are authorized:

- Android SDK: `C:/Users/zcxve/AppData/Local/Android/Sdk`
- JDK: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
- Git: `C:/Program Files/Git`
- Pub cache: `C:/Users/zcxve/AppData/Local/Pub/Cache`
- Gradle cache: `D:/GradleHome`
- fixed module: `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module`

Do not search for replacements via PATH, registry, environment, drives, Program Files, Users, repository paths, or historical guest paths.

## 3. Preserved Sandbox gate

Fresh `wsb --version` and `wsb list --raw`.

Exactly one running Sandbox must exist and must be `0087a898-5221-41df-a33d-65045ffea69a`.

If absent: `STOP — A1_SANDBOX_NO_LONGER_RUNNING`.

If not unique: `STOP — A1_SANDBOX_NOT_UNIQUELY_AVAILABLE`.

Do not create, stop, close, reset, or kill a Sandbox.

Recheck only the bounded A1 substrate identities already used by A3: SYSTEM, PowerShell 5.1, RemoteSigned, Security/system PATH, active adapter=0, default route=0, A1 manifest SHA, and the fixed Flutter Dart/pubspec/snapshot SHAs. Do not redo Flutter materialization.

## 4. A4 JDK capture

Exact executable: `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot/bin/java.exe`.

Before invocation, verify existence and SHA-256 equals `5369CF92FC590944793E47CC9C9FEF7955CE1A68DE22BA22023CDD3513E87C2B`. If not, `STOP — JDK_SOURCE_IDENTITY_DRIFT`.

Run `java -version` exactly once under A4 using a process-capture method that separately records process stdout, process stderr, and exit code without allowing PowerShell 5.1 to transform stderr into `NativeCommandError`. The capture implementation may use `System.Diagnostics.Process` with redirected stdout/stderr and no shell execution, or an equivalent bounded native process capture.

Do not use the directory name `.8-hotspot` as identity evidence. The process output itself must establish `17.0.18+8` and Eclipse Adoptium/Temurin/OpenJDK compatibility.

If the complete build identity is not proven, stop with `JDK_SOURCE_IDENTITY_NOT_PROVEN` or, if contradictory, `JDK_SOURCE_IDENTITY_MISMATCH`.

## 5. Remaining A continuation after JDK PASS

Only after JDK PASS, continue the remaining A3 source verification using the same six Owner-declared sources and the same A3 identity rules.

Git must prove `git version 2.53.0.windows.1`.

Fixed module must match exactly: 527 files, 301 directories, 3234145 bytes, reparse=0, manifest SHA-256 `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`.

Pub and Gradle cache checks remain root-level/bounded until materialization; do not perform package-specific diagnosis. Android checks remain fixed-relative-object checks only.

Only if all six host sources pass may you materialize them to guest-local fixed paths under `C:/M3A/` using read-only host source transport and guest-local writable copies. Host sources must not be modified.

After materialization, recheck JDK/Git/module identities and bounded Android/cache-root existence.

## 6. Explicit non-authority

Do not run Flutter-tools Dart pub, `flutter pub get`, module Dart pub, coverage/code_builder diagnosis, Flutter build, direct snapshot M3, AAR probe, M2, Gradle dependency resolution, network downloads, SDK installs/updates, or product implementation.

Do not inspect or modify unrelated default index/staged state. Do not run default `git status`.

## 7. Completion and result

A success requires preserved A1 substrate + all six host sources verified + all six materialized + required guest identity rechecks + no host writes + no network + no B/M3/AAR/M2.

Only success conclusion:

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

Create only:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_JDK_IDENTITY_CAPTURE_AND_REMAINING_A_REESTABLISHMENT_RESULT_V0_1.md`

Candidate sole parent must be this A4 task commit. Then STOP. Do not self-accept, update main, or execute B.