# EliteSync v10｜Post-R7 Module Recreation + Conditional Direct-Snapshot M3 Task v0.1

Status: `PUBLISHED TASK SHEET — NARROWED GENERATED-STATE ALLOWLIST — ONE RECREATION — CONDITIONAL ONE M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `1799ded1b960d30f87e0411558cfbea69b324706`.

B6 accepted that the five previously missing module/common destinations are Flutter-generated, disposable IDE metadata and that the B5 product-root gate may be narrowed while product-authored state remains protected by exact before/after manifests.

This task authorizes exactly one bounded existing-module recreation on the already materialized guest-local module, then exactly one conditional direct-snapshot M3 and exact AAR probe only if all recreation safety gates pass.

M2 remains unauthorized.

## 2. FIRST and exact inputs

1. Fresh-fetch `main`; if it is not exactly `1799ded1b960d30f87e0411558cfbea69b324706`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B6 result blob `755b2073389fe0f908dfe110b7b40d416f470ac1`.
5. Read accepted B4 result blob `24693a27360cc2fbf09bbd152c022e55511dc0ce` only for the generation contract.
6. Read accepted B2 result blob `071b8b5cab38c6dc9121d3e4bf36d469f0010849` only for established package-context and direct-snapshot facts.

Do not perform repository-wide, host-wide, or alternate-module search.

## 3. Fixed guest environment

Preserved Sandbox ID:
`0087a898-5221-41df-a33d-65045ffea69a`

Flutter root:
`C:/M3A/tools/flutter`

Dart:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

Flutter-tools package config:
`C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`

Flutter-tools snapshot:
`C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`

Module root:
`C:/M3A/work/apps/flutter_elitesync_module`

Pub cache:
`C:/M3A/cache/pub`

Android SDK:
`C:/M3A/tools/android`

JDK:
`C:/M3A/tools/jdk`

Git:
`C:/M3A/tools/git`

Gradle user home:
`C:/M3A/cache/gradle`

Fresh-check that exactly one Sandbox is running and it is the fixed ID above. Do not create, stop, close, reset, or kill any Sandbox.

Recheck only the minimum established substrate: SYSTEM, Windows PowerShell 5.1, process/effective RemoteSigned, active adapter count=0, default route count=0, fixed Dart/pubspec/snapshot identities, package_config local roots for coverage 1.15.0 and code_builder 4.11.1, and the guest-local SDK/cache/module roots. Do not rerun Flutter-tools offline pub.

## 4. Narrowed generated allowlist

Allowed generated/disposable mutation paths are only:

- `.idea/libraries/Dart_SDK.xml`
- `.idea/modules.xml`
- `.idea/workspace.xml`
- `flutter_elitesync_module_android.iml`
- `flutter_elitesync_module.iml`
- `.android/**`
- `.ios/**`
- `.dart_tool/**`
- `.flutter-plugins-dependencies`
- `pubspec.lock` only when legitimately changed by the single Flutter recreation pub step
- `build/**` only after M3 starts

No other path is implicitly allowed.

`--overwrite` is prohibited.

## 5. Protected pre-state manifest

Before recreation, create one deterministic manifest over all guest module files except the generated allowlist above and `build/**`.

The protected set must therefore include, at minimum:

- `.metadata`
- `analysis_options.yaml`
- `pubspec.yaml`
- `README.md`
- `.gitignore`
- `lib/**`
- `test/**`
- `assets/**` if present
- every other current module path not explicitly in the generated allowlist

Manifest record format:
`relative_path<TAB>Length<TAB>SHA256`

Use `/` path normalization, deterministic ordinal ordering, UTF-8 without BOM, LF line endings.

Record protected record count, manifest Length, and SHA-256.

Do not interpret file contents for product meaning; read bytes only for identity.

## 6. Pre-recreation generated-state observations

Check and record existence only for:

- `.idea/libraries/Dart_SDK.xml`
- `.idea/modules.xml`
- `.idea/workspace.xml`
- `flutter_elitesync_module_android.iml`
- `flutter_elitesync_module.iml`
- `.android/settings.gradle`
- `.android/settings.gradle.kts`
- `.android/build.gradle`
- `.android/build.gradle.kts`
- `.ios`
- `.dart_tool`
- `.flutter-plugins-dependencies`
- `pubspec.lock`

Do not broadly enumerate `.android` or `.ios` before recreation.

## 7. Single supported existing-module recreation

Run exactly once, using Dart + the already established local Flutter-tools package config and snapshot, equivalent to:

`dart --packages=<flutter_tools_package_config> <flutter_tools_snapshot> --no-version-check create --template=module --offline .`

CWD:
`C:/M3A/work/apps/flutter_elitesync_module`

Required environment roots:

- `FLUTTER_ROOT=C:/M3A/tools/flutter`
- `PUB_CACHE=C:/M3A/cache/pub`
- `ANDROID_HOME=C:/M3A/tools/android`
- `ANDROID_SDK_ROOT=C:/M3A/tools/android`
- `JAVA_HOME=C:/M3A/tools/jdk`
- Git from `C:/M3A/tools/git/cmd`
- `GRADLE_USER_HOME=C:/M3A/cache/gradle`

Do not pass `--overwrite`.
Do not pass `--no-pub`.
Do not call `flutter.bat` or `shared.bat`.
Do not retry recreation.

Record exact executable, complete arguments, cwd, environment roots, start/end/duration, stdout/stderr, and exit.

Classify network only from genuine URL/socket/DNS/connection failure evidence. Static documentation URLs and package names containing `socket` are not network attempts.

If genuine network failure occurs, STOP `B7_MODULE_RECREATION_NETWORK_ATTEMPT`.

If recreation exits nonzero without genuine network failure, STOP using the narrowest observed recreation failure.

## 8. Protected post-state gate

Only if recreation exits 0:

1. Recompute the protected manifest using exactly the same rules and exclusions.
2. Require exact equality of:
   - record count
   - every relative path
   - every Length
   - every SHA-256
   - manifest Length
   - manifest SHA-256

If any protected path changed, appeared, or disappeared, STOP:
`B7_PROTECTED_NON_GENERATED_STATE_CHANGED`

No M3 is authorized after such a mismatch.

## 9. Generated-state and Android Gradle gate

After protected manifest equality passes, record generated-state observations.

The following five B6-classified IDE paths may now exist and are allowed.

For `.android`, check only these fixed Gradle sentinels:

- `.android/settings.gradle`
- `.android/settings.gradle.kts`
- `.android/build.gradle`
- `.android/build.gradle.kts`

At least one valid settings/build sentinel must exist.

If all four remain absent, STOP:
`B7_MODULE_DOT_ANDROID_GRADLE_BUILD_NOT_GENERATED`

Also record existence of `.ios`, `.dart_tool`, `.flutter-plugins-dependencies`, and `pubspec.lock`.

Reconfirm Flutter-tools snapshot SHA-256 remains exactly:
`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`

Do not regenerate/rebuild the snapshot.

## 10. Conditional unique direct-snapshot M3

Only if all prior B7 gates pass, run exactly one direct-snapshot M3.

Executable:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

Package config:
`C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`

Snapshot:
`C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`

CWD:
`C:/M3A/work/apps/flutter_elitesync_module`

Equivalent arguments:
`--packages=<package_config> <snapshot> --no-version-check build aar --no-debug --no-profile --no-pub`

Use only guest-local SDK/cache/tool roots.

Run exactly once. No retry.

Record exact executable, complete arguments, cwd, timing, stdout/stderr, exit.

Classify any failure by the narrowest observed reason. Do not run separate Gradle dependency resolution.

## 11. Exact AAR probe

If and only if the M3 process actually starts, perform exactly one probe of:

`C:/M3A/work/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

Do not search alternate paths.

Record HIT/NON-HIT, Length and SHA-256 if HIT.

Success requires both:

- M3 exit=0
- exact AAR HIT

Only then conclude exactly:

`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`

M2 remains NOT_RUN.

## 12. Explicit prohibitions

Do not run:

- another Flutter-tools pub
- another module pub
- recreation more than once
- `--overwrite`
- recreation with `--no-pub`
- manual `.android` repair
- manual template copy
- `gradlew init`
- separate Gradle dependency resolution
- network/package fill
- M2
- product implementation

Do not modify host SDK/cache/source.
Do not inspect unrelated default index/protected staged state.
Do not run default `git status`.

## 13. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_RECREATION_AND_CONDITIONAL_DIRECT_SNAPSHOT_M3_RESULT_V0_1.md`

Record:

- authority and Sandbox gate
- minimum substrate recheck
- protected pre/post manifests
- pre/post generated-state observations
- exact recreation invocation/result
- protected-state comparison
- Android Gradle sentinel result
- snapshot identity
- conditional M3 evidence
- exact AAR probe
- final Sandbox state
- all NOT_RUN / NOT_CHECKED items

Candidate sole parent must be this B7 task commit. Then STOP.
Do not self-accept, update `main`, or execute M2.
