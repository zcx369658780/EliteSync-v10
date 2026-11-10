# EliteSync v10｜Post-R7 Flutter-tools Offline Context Closure + Conditional Direct-Snapshot M3 Task v0.1

Status: `PUBLISHED TASK SHEET — B AUTHORIZED AFTER A ACCEPTANCE — NO M2 — NO NETWORK FILL`

## 1. Authority and goal

Current accepted main must be `11a29b0a842b6fee326c615d6b41226d1bf65bef`.

A is complete: preserved Owner Sandbox/session, transport, Flutter, Android, JDK, Git, Pub cache, Gradle cache and fixed module are re-established and guest identities passed.

This task is B only. Its goal is to close the Flutter-tools offline package context and, only if that context is proven fully local, run exactly one direct `flutter_tools.snapshot` M3 followed by exactly one exact AAR probe.

M2 is not authorized in this task even if M3 succeeds.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if not exactly `11a29b0a842b6fee326c615d6b41226d1bf65bef`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted A7 result blob `30f73d6decdbcea8943dab93e9fecd98d1115127`.
5. Read the accepted R7 task/result objects only as needed for the direct-snapshot command shape and historical package facts already established.

Do not perform repository-wide or host-wide search. Do not inspect default index/protected staged state.

## 3. Preserved Sandbox gate

Fresh `wsb --version` and `wsb list --raw`.

Exactly one running Sandbox must exist with ID:
`0087a898-5221-41df-a33d-65045ffea69a`

If absent: `STOP — A1_SANDBOX_NO_LONGER_RUNNING`.
If not unique: `STOP — A1_SANDBOX_NOT_UNIQUELY_AVAILABLE`.

Do not create, stop, close, reset or kill any Sandbox.

Recheck only the minimal preserved A substrate required for this task: SYSTEM, PowerShell 5.1, RemoteSigned, active adapter=0, default route=0, Flutter Dart/pubspec/snapshot fixed identities, and the guest-local materialized roots from A7.

## 4. Exact Flutter-tools dependency facts

Flutter-tools root:
`C:/M3A/tools/flutter/packages/flutter_tools`

Exact pubspec:
`C:/M3A/tools/flutter/packages/flutter_tools/pubspec.yaml`

Confirm by exact parsing only:
- `coverage: 1.15.1`
- `code_builder: 4.11.1`

Do not edit pubspec.

Guest Pub cache root:
`C:/M3A/cache/pub`

Perform bounded exact-name checks only under the hosted pub cache root for:
- `coverage-1.15.1`
- `code_builder-4.11.1`

No package-wide enumeration beyond these two exact names.

If `coverage-1.15.1` is missing, STOP exactly:
`FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS`

If `code_builder-4.11.1` is missing, STOP exactly:
`FLUTTER_TOOLS_EXACT_CODE_BUILDER_CACHE_MISS`

No network, download, install, package fill or alternate cache search is authorized.

## 5. Direct Dart offline Flutter-tools context closure

Only if both exact cache directories exist:

Use bundled Dart exactly:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

CWD exactly:
`C:/M3A/tools/flutter/packages/flutter_tools`

Run exactly one:
`dart pub get --offline`

This is the only Flutter-tools pub action authorized.

Record exact executable, args, cwd, start/end/duration, stdout/stderr, exit.

Any URL/socket/DNS/network diagnostic => STOP `FLUTTER_TOOLS_OFFLINE_CONTEXT_NETWORK_ATTEMPT`.
Any nonzero exit without network diagnostic => STOP `FLUTTER_TOOLS_OFFLINE_CONTEXT_RESOLUTION_FAILED`.

After exit 0:
- verify `.dart_tool/package_config.json` exists;
- confirm the `coverage` package entry resolves to a local `file:` root under `C:/M3A/cache/pub` and version 1.15.1 context;
- confirm `code_builder` resolves locally under `C:/M3A/cache/pub` and version 4.11.1 context;
- do not inspect unrelated package contents;
- confirm `flutter_tools.snapshot` SHA remains exactly `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`.

Do not rebuild/regenerate the snapshot.

## 6. Conditional unique direct-snapshot M3

Only if §5 fully passes.

Exact Dart executable:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

Exact package config:
`C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`

Exact snapshot:
`C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`

Exact module cwd:
`C:/M3A/work/apps/flutter_elitesync_module`

Run exactly one direct-snapshot M3 with arguments equivalent to:
`--packages=<package_config> <snapshot> --no-version-check build aar --no-debug --no-profile --no-pub`

Do not call `flutter.bat`, shared.bat, doctor, precache, update-packages, upgrade, or version-check bootstrap.

Record exact executable, complete args, cwd, start/end/duration, exit, stdout/stderr.

No retry.

Any network diagnostic => `M3 PRECONDITION BLOCKED — DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`.
Nonzero exit without network diagnostic => classify with the narrowest observed direct-snapshot M3 failure.

## 7. Exact AAR probe

If and only if the unique M3 process was started, perform exactly one probe of:

`C:/M3A/work/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

No alternate-path search.

Record HIT/NON-HIT; if HIT, record Length and SHA-256.

Success requires M3 exit 0 AND exact AAR HIT.

Only then conclude:
`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`

This conclusion still does not authorize M2 in this task.

## 8. Boundaries

Do not run module `flutter pub get` or module Dart pub; A7 already established the fixed module copy.
Do not run Gradle resolution.
Do not modify host SDK/cache/source.
Do not modify Flutter source/pubspec/snapshot except normal task-owned `.dart_tool` state created by the single authorized offline pub in `packages/flutter_tools`.
Do not access network or fill missing packages.
Do not inspect unrelated repository/default index/staged state.
Do not execute M2 or product implementation.

## 9. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_DIRECT_SNAPSHOT_M3_RESULT_V0_1.md`

Record package facts, exact cache checks, offline pub evidence, package_config local roots, snapshot pre/post identity, unique M3 evidence, exact AAR probe, Sandbox final state, and all NOT_RUN items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept, update `main`, execute M2, or start product implementation.