# EliteSync v10｜Post-R7 Flutter-tools Offline Context Closure + Conditional Direct-Snapshot M3 Task v0.2

Status: `PUBLISHED TASK SHEET — CORRECTED COVERAGE FACT — NO M2`

## 1. Authority and corrected fact

Current accepted main must be `bec0945a00fadbdc8a59e457647e361ca419abb3`.

Accepted B result proved the fixed Flutter-tools pubspec SHA is unchanged and the exact dependency facts are:
- `coverage: 1.15.0`
- `code_builder: 4.11.1`

The prior `coverage: 1.15.1` task assumption is superseded and must not be used.

## 2. FIRST and inputs

1. Fresh-fetch `main`; mismatch => `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B result blob `0529d37764080198bb269ed74557d48b642828af` and accepted A7 result blob `30f73d6decdbcea8943dab93e9fecd98d1115127`.

Preserved Sandbox must remain uniquely `0087a898-5221-41df-a33d-65045ffea69a`; do not create/stop/close/reset/kill.

## 3. Minimal substrate gate

Recheck SYSTEM, PowerShell 5.1, RemoteSigned, adapter=0, route=0, fixed Dart/pubspec/snapshot SHAs, and A7 guest-local Android/JDK/Git/Pub/Gradle/module roots. Do not redo materialization.

## 4. Exact dependency and cache gate

Flutter-tools pubspec:
`C:/M3A/tools/flutter/packages/flutter_tools/pubspec.yaml`

Prove exactly:
- `coverage: 1.15.0`
- `code_builder: 4.11.1`

Guest Pub cache:
`C:/M3A/cache/pub`

Check only exact hosted cache entries for:
- `coverage-1.15.0`
- `code_builder-4.11.1`

If coverage missing => `FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS` and STOP.
If code_builder missing => `FLUTTER_TOOLS_EXACT_CODE_BUILDER_CACHE_MISS` and STOP.
No network, download, package fill, alternate cache search, or unrelated package enumeration.

## 5. Single Flutter-tools offline pub

Only if both exact cache entries exist, run exactly once:

Executable:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

CWD:
`C:/M3A/tools/flutter/packages/flutter_tools`

Args:
`pub get --offline`

Record exact executable, args, cwd, timing, stdout/stderr, exit.
Network/URL/socket/DNS diagnostic => `FLUTTER_TOOLS_OFFLINE_CONTEXT_NETWORK_ATTEMPT` and STOP.
Nonzero without network diagnostic => `FLUTTER_TOOLS_OFFLINE_CONTEXT_RESOLUTION_FAILED` and STOP.
No retry.

After exit=0 verify `.dart_tool/package_config.json` exists and only confirm:
- coverage resolves to a local `file:` root under `C:/M3A/cache/pub` and corresponds to `1.15.0`;
- code_builder resolves to a local `file:` root under `C:/M3A/cache/pub` and corresponds to `4.11.1`.

Then verify snapshot SHA remains exactly:
`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`

Do not regenerate snapshot.

## 6. Unique direct-snapshot M3

Only if all package-context gates pass, run exactly once:

Executable:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

Package config:
`C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`

Snapshot:
`C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`

CWD:
`C:/M3A/work/apps/flutter_elitesync_module`

Equivalent args:
`--packages=<package_config> <snapshot> --no-version-check build aar --no-debug --no-profile --no-pub`

Do not call flutter.bat/shared.bat/doctor/precache/update-packages/upgrade/version-check bootstrap.
Record exact process evidence. No retry.
Any network diagnostic => `M3 PRECONDITION BLOCKED — DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`.
Otherwise classify nonzero exit by narrowest observed failure.

## 7. Exact AAR probe

If and only if M3 actually starts, probe exactly once:
`C:/M3A/work/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

Do not search alternate paths.
Record HIT/NON-HIT, Length/SHA if HIT.

Success requires M3 exit=0 + exact AAR HIT, then classify exactly:
`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`

This does NOT authorize M2 in this task.

## 8. Boundaries and result

Do not run module pub, Gradle dependency resolution, M2, product implementation, network/package filling, or modify host SDK/cache/source. Do not inspect default index/protected staged state or run default `git status`.

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_DIRECT_SNAPSHOT_M3_RESULT_V0_2.md`

Candidate sole parent must be this task commit. Then STOP. Do not self-accept or update `main`.