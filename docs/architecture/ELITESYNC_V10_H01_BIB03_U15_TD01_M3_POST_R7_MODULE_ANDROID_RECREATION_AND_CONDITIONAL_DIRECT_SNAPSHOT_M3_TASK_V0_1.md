# EliteSync v10｜Post-R7 Module Android Recreation + Conditional Direct-Snapshot M3 Task v0.1

Status: `PUBLISHED TASK SHEET — BOUNDED EXISTING-MODULE RECREATION — CONDITIONAL M3 — NO M2`

## 1. Authority and goal

Current accepted main must be `6e091920f6683f3761e470e36f46c999c04cd489`.

B4 established from the fixed Flutter-tools source that an existing module can repair/recreate missing generated platform tooling via `flutter create` on the existing module, with pub enabled and `--offline`; `--no-pub` must not be used. This task may execute that supported recreation only after strict product/root sentinel and manifest gates prove that non-generated module files will not be newly created or overwritten.

Goal: bounded guest-local module recreation -> prove `.android` Gradle sentinels -> prove protected non-generated state unchanged -> if all pass, run one direct-snapshot M3 and one exact AAR probe. M2 remains unauthorized.

## 2. FIRST and exact inputs

1. Fresh-fetch main; if not exactly `6e091920f6683f3761e470e36f46c999c04cd489`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B4 result blob `24693a27360cc2fbf09bbd152c022e55511dc0ce`.
5. Read accepted B3 result blob `e7e6be75cb778f737e47e47077beb47d79793375` and B2 result blob `071b8b5cab38c6dc9121d3e4bf36d469f0010849` only for established substrate/package context.

No repository-wide, host-wide, or alternate module search.

## 3. Sandbox and fixed guest roots

Exactly one running Sandbox must remain: `0087a898-5221-41df-a33d-65045ffea69a`.
Do not create, stop, close, reset, or kill any Sandbox.

Fixed guest roots:
- Flutter `C:/M3A/tools/flutter`
- Dart `C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`
- Flutter-tools package config `C:/M3A/tools/flutter/packages/flutter_tools/.dart_tool/package_config.json`
- snapshot `C:/M3A/tools/flutter/bin/cache/flutter_tools.snapshot`
- module `C:/M3A/work/apps/flutter_elitesync_module`
- Pub `C:/M3A/cache/pub`
- Android `C:/M3A/tools/android`
- JDK `C:/M3A/tools/jdk`
- Git `C:/M3A/tools/git`
- Gradle `C:/M3A/cache/gradle`

Recheck minimal established substrate only: SYSTEM, PowerShell 5.1, RemoteSigned, adapter=0, route=0, Dart/pubspec/snapshot fixed SHAs, package_config local roots for coverage 1.15.0 and code_builder 4.11.1, and all A7 guest roots. Do not rerun Flutter-tools pub.

## 4. Mandatory pre-recreation product/root gates

Before executing create, every exact `templates/module/common` destination identified by B4 must already exist in the current guest module:
- `.gitignore`
- `.idea/libraries/Dart_SDK.xml`
- `.idea/modules.xml`
- `.idea/workspace.xml`
- `.metadata`
- `analysis_options.yaml`
- `lib/main.dart`
- `flutter_elitesync_module_android.iml`
- `flutter_elitesync_module.iml`
- `pubspec.yaml`
- `README.md`
- `test/widget_test.dart`

Check only these exact paths. If any is missing, STOP:
`B5_PRODUCT_ROOT_DESTINATION_MISSING — RECREATION_NOT_AUTHORIZED`

Do not create the missing path. Do not run recreation.

## 5. Protected non-generated manifest

Before recreation, create a task-owned manifest for protected non-generated module state using exact fixed paths only:
- the 12 product/root destinations above;
- all files under `lib/**`;
- all files under `test/**`;
- all files under `assets/**` only if `assets` exists;
- `pubspec.yaml`, `pubspec.lock` if present, `.metadata`, `analysis_options.yaml`, `README.md`, `.gitignore`, and root `.iml` files.

The manifest may record relative path, Length, SHA-256 only. It must explicitly EXCLUDE generated/ephemeral paths:
- `.android/**`
- `.ios/**`
- `.dart_tool/**`
- `.flutter-plugins-dependencies`
- `build/**`

No technical-content interpretation. This manifest is only a mutation guard.

## 6. Pre-recreation generated-state observations

Record exact existence only for:
- `.android/settings.gradle`
- `.android/settings.gradle.kts`
- `.android/build.gradle`
- `.android/build.gradle.kts`
- `.ios` root
- `.dart_tool` root
- `.flutter-plugins-dependencies`

Do not broadly enumerate `.android` or `.ios` before recreation.

## 7. Single authorized existing-module recreation

Only after Sections 3-6 pass, run exactly one existing-module recreation using the fixed Flutter-tools package context, equivalent to:

`dart --packages=<flutter_tools_package_config> <flutter_tools_snapshot> --no-version-check create --template=module --offline .`

CWD:
`C:/M3A/work/apps/flutter_elitesync_module`

Required rules:
- do NOT pass `--overwrite`;
- do NOT pass `--no-pub`;
- do NOT run `flutter.bat` or `shared.bat`;
- use only guest-local PUB_CACHE/Android/JDK/Git/Gradle roots;
- no network/package fill;
- invocation count exactly 1; no retry.

Record exact executable, args, cwd, environment roots, timing, stdout/stderr, exit.

If genuine URL/socket/DNS/connection failure evidence occurs, STOP:
`B5_MODULE_RECREATION_NETWORK_ATTEMPT`

If nonzero without genuine network failure, STOP with narrowest observed recreation failure.

## 8. Post-recreation mandatory gates

After recreation exit=0:

A. Recheck the same 12 product/root destinations: all must still exist.

B. Recompute the protected non-generated manifest using exactly the same rules. It must be byte-for-byte logically identical by record count + Length + SHA per path. Any protected difference or new protected path => STOP:
`B5_PROTECTED_NON_GENERATED_STATE_CHANGED`

C. Check exact Android sentinels again:
- `.android/settings.gradle`
- `.android/settings.gradle.kts`
- `.android/build.gradle`
- `.android/build.gradle.kts`
At least one valid settings/build sentinel must exist, otherwise STOP:
`B5_MODULE_DOT_ANDROID_GRADLE_BUILD_NOT_GENERATED`

D. Record `.ios` / `.dart_tool` / `.flutter-plugins-dependencies` generated-state presence. These are allowed generated outputs.

E. Reconfirm snapshot SHA remains `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`.

## 9. Conditional unique direct-snapshot M3

Only if all post-recreation gates pass, run exactly one M3:

Executable:
`C:/M3A/tools/flutter/bin/cache/dart-sdk/bin/dart.exe`

Args equivalent to:
`--packages=<package_config> <snapshot> --no-version-check build aar --no-debug --no-profile --no-pub`

CWD:
`C:/M3A/work/apps/flutter_elitesync_module`

Use only guest-local roots. No retry. Record complete args/timing/stdout/stderr/exit. Classify any failure by the narrowest observed reason.

## 10. Exact AAR probe

If and only if M3 process started, perform exactly one probe of:
`C:/M3A/work/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

No alternate path search. Record HIT/NON-HIT, Length and SHA if HIT.

Success requires M3 exit=0 + exact AAR HIT, then conclude exactly:
`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`

M2 remains NOT_RUN.

## 11. Prohibited actions

Do NOT run:
- another Flutter-tools pub;
- another module pub;
- `flutter create` more than once;
- `--overwrite`;
- `--no-pub` on recreation;
- manual `.android` repair;
- template copy by hand;
- `gradlew init`;
- separate Gradle dependency resolution;
- network/package fill;
- M2;
- product implementation.

Do not modify host SDK/cache/source. Do not inspect unrelated default index/staged state. Do not run default `git status`.

## 12. Result and stop

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_ANDROID_RECREATION_AND_CONDITIONAL_DIRECT_SNAPSHOT_M3_RESULT_V0_1.md`

Record:
- all precondition path gates;
- protected manifest before/after;
- exact recreation command and result;
- generated-state observations;
- protected-state comparison;
- Android sentinels;
- snapshot identity;
- conditional M3 evidence;
- exact AAR probe;
- final Sandbox state;
- all NOT_RUN/NOT_CHECKED items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept, update main, or execute M2.