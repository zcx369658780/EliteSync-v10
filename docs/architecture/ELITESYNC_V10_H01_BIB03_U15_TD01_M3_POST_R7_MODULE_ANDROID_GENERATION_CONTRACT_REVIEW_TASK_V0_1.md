# EliteSync v10｜Post-R7 Module Android Generation Contract Review Task v0.1

Status: `PUBLISHED TASK SHEET — GENERATION CONTRACT REVIEW ONLY — NO GENERATION — NO M3 — NO AAR PROBE — NO M2`

## 1. Authority and goal

Current accepted main must be `7818c554d9547ecfd851b9dcc25a56a3a4d71720`.

Accepted B3 proves one module-level Flutter-tools `pub get --offline` does not create any of the four fixed `.android` Gradle sentinels. This task does not retry pub, does not generate `.android`, and does not run M3.

Sole goal: using the fixed guest Flutter SDK already established in the preserved Sandbox, determine the exact Flutter-supported generation contract for a Flutter module's ephemeral `.android` Gradle build: which command/code path creates it, required preconditions/metadata, exact destination paths, and whether that path is safe to run against the current copied module without altering host sources or product-authored files outside the ephemeral generated area.

## 2. Authority gate and exact repository inputs

1. Fresh-fetch GitHub `main`; if not exactly `7818c554d9547ecfd851b9dcc25a56a3a4d71720`, STOP `MAIN AUTHORITY CHANGED`.
2. FIRST read blob `18485c95262051e43892436fb52413132c5ee626`.
3. Read this task.
4. Read accepted B3 result blob `e7e6be75cb778f737e47e47077beb47d79793375` and accepted B2 result blob `071b8b5cab38c6dc9121d3e4bf36d469f0010849` only for the observed failure and already-closed offline package context.

No repository-wide search, default index inspection, protected staged-state inspection, or default `git status`.

## 3. Preserved Sandbox and fixed local inputs

Preserved Sandbox must still be uniquely running as `0087a898-5221-41df-a33d-65045ffea69a`. Do not create/stop/close/reset/kill it.

Fixed Flutter root:
`C:/M3A/tools/flutter`

Fixed Flutter-tools source root:
`C:/M3A/tools/flutter/packages/flutter_tools`

Fixed module root:
`C:/M3A/work/apps/flutter_elitesync_module`

This task is read-only with respect to Flutter SDK, module, SDK/cache roots and host sources.

## 4. Bounded Flutter-tools source inspection

Only the following local Flutter-tools areas are authorized for bounded read/search because they are the product-local implementation of the already invoked commands:

- `C:/M3A/tools/flutter/packages/flutter_tools/lib/src/commands`
- `C:/M3A/tools/flutter/packages/flutter_tools/lib/src/project.dart`
- `C:/M3A/tools/flutter/packages/flutter_tools/lib/src/flutter_project_metadata.dart`
- `C:/M3A/tools/flutter/packages/flutter_tools/lib/src/template.dart`
- `C:/M3A/tools/flutter/packages/flutter_tools/templates/module`

Within those exact roots/files, bounded textual search is allowed only for these terms/concepts:

- `build aar`
- `BuildAarCommand`
- `.android`
- `FlutterProject`
- `FlutterModuleProject`
- `create`
- `module`
- `template`
- `ephemeral`
- `settings.gradle`
- `settings.gradle.kts`
- `build.gradle`
- `build.gradle.kts`

Do not search other Flutter SDK directories unless one of the authorized files contains an exact referenced local path; one-hop follow is allowed only for that exact referenced implementation file and must be recorded.

Do not modify any Flutter SDK file.

## 5. Exact current module metadata inspection

Read only the minimum current module metadata files that the inspected Flutter-tools code explicitly requires to decide module type/generation behavior. Likely examples may include `pubspec.yaml` or `.metadata`, but do not assume them: only read an exact module file after the inspected Flutter-tools source proves it is part of the generation decision.

Do not inspect application source code, `.android` contents broadly, or product semantics.

## 6. Required findings

The result must establish, with exact local source path + relevant symbol/function/command names:

1. Which Flutter-tools command or internal code path is responsible for creating/regenerating a module `.android` Gradle build.
2. Whether ordinary `flutter pub get` is expected to create it. B3 says empirically no; B4 must explain the code contract, not override the empirical result.
3. Whether `flutter create` / `flutter create --template=module` / a project regeneration path is the supported mechanism, or whether `build aar` itself normally calls a generation path that was bypassed by `--no-pub` / direct snapshot / missing metadata.
4. The exact preconditions needed for generation, including module/project metadata if any.
5. The exact path scope expected to be written. Distinguish ephemeral generated `.android/**` from product-authored module files.
6. Whether running the identified generation action against `C:/M3A/work/apps/flutter_elitesync_module` can be bounded so that only guest-local ephemeral/generated paths are written.
7. Whether that action can run with the already-closed offline package context and no network/package fill.
8. The narrowest safe next execution action and exact command shape if supported.

## 7. Classification

If an exact supported bounded generation path is established, classify:

`MODULE_DOT_ANDROID_GENERATION_CONTRACT_ESTABLISHED — READY FOR B5 EXECUTION TASK`

If Flutter-tools evidence shows generation would require unbounded/product-authored mutation or unavailable metadata/source authority, classify the narrowest blocker and STOP.

If the authorized source budget cannot prove the generation mechanism, classify:

`MODULE_DOT_ANDROID_GENERATION_CONTRACT_NOT_PROVEN`

Do not guess.

## 8. Explicit non-authority

Do NOT run:
- any Flutter pub / Dart pub
- `flutter create`
- any regeneration command
- direct-snapshot M3
- Gradle resolution
- AAR probe
- M2
- network/download/package fill
- product implementation

Do not create/modify/delete `.android` files in this task.
Do not alter host or guest SDK/cache/source identities.

## 9. Result candidate

Create only:
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_MODULE_ANDROID_GENERATION_CONTRACT_REVIEW_RESULT_V0_1.md`

Record every exact Flutter-tools file/symbol inspected, any one-hop implementation file followed, minimal module metadata read, generation contract findings, write-scope conclusion, offline feasibility, final classification, and all NOT_RUN items.

Candidate sole parent must be this task commit. Then STOP.
Do not self-accept, update `main`, generate `.android`, run M3, or execute M2.